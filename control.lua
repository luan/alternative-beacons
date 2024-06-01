--- control.lua
--  this file is loaded prior to any scripts/functions and reloaded each time a game is saved/loaded so changes here can be tested without relaunching the game; available objects: script, remote, commands

local exclusion_ranges = {}     -- beacon prototype name -> range for affected beacons
local distribution_ranges = {}  -- beacon prototype name -> range for affected crafting machines
local search_ranges = {}        -- beacon prototype name -> maximum range that other beacons could be interacted with
local types = {}                -- beacon prototype name -> "strict", "hub", or "conflux" for beacons with distinct behaviors
local repeating_beacons = {}    -- beacon prototype name -> list of beacons which won't be disabled
local offline_beacons = {}      -- beacon unit number -> attached warning sprite, entity reference (for disabled beacons)
local update_rate               -- integer; if above zero, how many seconds elapse between updating all beacons (beacons are only updated via triggered events by default)
local persistent_alerts         -- boolean; whether or not alerts are refreshed for disabled beacons

--- Mod Initialization - called on first startup after the mod is installed; available objects: global, game, rendering, settings
script.on_init(
  function()
    global = { exclusion_ranges = {}, distribution_ranges = {}, search_ranges = {}, strict_beacons = {}, repeating_beacons = {}, offline_beacons = {} } -- TODO: refactor/migrate "strict_beacons" as "types" instead
    populate_beacon_data()
  end
)

--- Migrations are handled between on_init() and on_load()

--- Mod Load - called on subsequent startups
script.on_load(
  function()
    -- global is a global table that preserves data between saves which can store: nil, strings, numbers, booleans, tables, references to Factorio's LuaObjects; can read from global in on_load(), but not write to it
    exclusion_ranges = global.exclusion_ranges
    distribution_ranges = global.distribution_ranges
    search_ranges = global.search_ranges
    types = global.strict_beacons
    repeating_beacons = global.repeating_beacons
    offline_beacons = global.offline_beacons
    update_rate = settings.global["ab-update-rate"].value
    persistent_alerts = settings.global["ab-persistent-alerts"].value
    if settings.startup["ab-disable-exclusion-areas"].value == false then enable_scripts(script.active_mods) end
  end
)

-- Mod Configuration - called next if the game version or any mod version has changed, any mod was added or removed, a startup setting was changed, any prototypes were added or removed, or if a migration was applied
script.on_configuration_changed(
  function()
    populate_beacon_data()
  end
)


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- scripts and startup functions
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Enables all scripting to make exclusion areas function - can be disabled by other mods via a hidden startup setting if necessary
function enable_scripts(mods)
  script.on_event( defines.events.on_built_entity,          function(event) check_nearby(event.created_entity, "added") end, {{filter = "type", type = "beacon"}} )
  script.on_event( defines.events.on_robot_built_entity,    function(event) check_nearby(event.created_entity, "added") end, {{filter = "type", type = "beacon"}} )
  script.on_event( defines.events.script_raised_built,      function(event) check_nearby(event.entity, "added") end, {{filter = "type", type = "beacon"}} )
  script.on_event( defines.events.script_raised_revive,     function(event) check_nearby(event.entity, "added") end, {{filter = "type", type = "beacon"}} )
  script.on_event( defines.events.on_player_mined_entity,   function(event) check_nearby(event.entity, "removed") end, {{filter = "type", type = "beacon"}} )
  script.on_event( defines.events.on_robot_mined_entity,    function(event) check_nearby(event.entity, "removed") end, {{filter = "type", type = "beacon"}} )
  script.on_event( defines.events.on_entity_died,           function(event) check_nearby(event.entity, "removed") end, {{filter = "type", type = "beacon"}} )
  script.on_event( defines.events.script_raised_destroy,    function(event) check_nearby(event.entity, "removed") end, {{filter = "type", type = "beacon"}} )
  --script.on_event( defines.events.on_entity_cloned,         function(event) check_nearby(event.destination, "added") end, {{filter = "type", type = "beacon"}} ) -- TODO: Test this. What clones entities?
  script.on_event( defines.events.script_raised_teleported, function(event) check_global_list() end, {{filter = "type", type = "beacon"}} ) --TODO: Find a reliable way to trigger this event so a check_moved() function can be tested instead of just checking all beacons
  script.on_event(
    defines.events.on_runtime_mod_setting_changed,
    function(event)
      if event.setting == "ab-update-rate" then
        local previous_update_rate = update_rate
        update_rate = settings.global["ab-update-rate"].value
        if previous_update_rate ~= update_rate then
          if previous_update_rate > 0 then unregister_periodic_updates(previous_update_rate * 60) end
          if update_rate > 0 then register_periodic_updates(update_rate * 60) end
        end
      end
      if event.setting == "ab-persistent-alerts" then -- TODO: Allow this to be adjusted per player in multiplayer while still allowing the admin to make it available or not?
        local previous_setting = persistent_alerts
        persistent_alerts = settings.global["ab-persistent-alerts"].value
        if previous_setting == false and persistent_alerts == true then
          register_alert_refreshing()
        elseif previous_setting == true and persistent_alerts == false then
          unregister_alert_refreshing()
        end
      end
    end
  )
  if update_rate > 0 then register_periodic_updates(update_rate * 60) end
  if persistent_alerts == true then register_alert_refreshing() end
  if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
    script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), function(event) check_remote(event["moved_entity"], "added", 1) end) -- rechecks nearby beacons when a beacon is moved; a maximum moved distance of 1 is assumed
  end
  if mods["pycoalprocessing"] then
    remote.remove_interface("cryogenic-distillation")
    remote.add_interface("cryogenic-distillation", {
      am_fm_beacon_settings_changed = function(new_beacon) check_remote(new_beacon, "added", 0) end, -- rechecks nearby beacons when an AM:FM beacon is updated
      am_fm_beacon_destroyed = function(receivers, surface) end -- unused
    })
  end
  if mods["informatron"] then
    remote.remove_interface("alternative-beacons")
    remote.add_interface("alternative-beacons", {
      informatron_menu = function(data) return informatron_beacon_menu(data.player_index) end,
      informatron_page_content = function(data) return informatron_beacon_page_content(data.page_name, data.player_index, data.element) end
    })
  end
end

function register_periodic_updates(tick_rate)
  script.on_nth_tick(tick_rate, function(event) check_global_list() end)
end

function unregister_periodic_updates(tick_rate)
  script.on_nth_tick(tick_rate, nil)
end

function register_alert_refreshing()
  script.on_nth_tick(601, function(event) refresh_beacon_alerts() end)
end

function unregister_alert_refreshing()
  script.on_nth_tick(601, nil)
end

function informatron_beacon_menu(player_index) return {} end

function informatron_beacon_page_content(page_name, player_index, element)
  if page_name == "alternative-beacons" then
    element.add{type="label", name="text_1", caption={"alternative-beacons.page_alternative-beacons_text_1"}}
    local image_container = element.add{type = "flow"}
    image_container.style.horizontal_align = "center"
    image_container.style.horizontally_stretchable = true
    image_container.add{type = "sprite", sprite = "ab_informatron_1"}
    element.add{type="label", name="text_2", caption={"alternative-beacons.page_alternative-beacons_text_2"}}
  end
end

--- updates global data
--  creates and updates exclusion ranges for all beacons - beacons from other mods will use their distribution range as their exclusion range unless otherwise noted
function populate_beacon_data()
  local updated_distribution_ranges = {}
  local updated_exclusion_ranges = {}
  local updated_types = {
    ["ab-hub-beacon"] = {hub=true},
    ["ab-conflux-beacon"] = {conflux=true}
    -- entries are added below for all strict beacons
  }

  local custom_exclusion_ranges = { -- these beacons are given custom exclusion ranges: "strict" ranges disable beacons whose distribution areas overlap them, "solo" means the smallest range for "strict" beacons which is large enough to prevent synergy with other beacons
    ["ab-focused-beacon"] = {add=1},
    ["ab-conflux-beacon"] = {add=3},
    ["ab-hub-beacon"] = {add=20},
    ["ab-isolation-beacon"] = {add=8, mode="strict"},
    ["se-basic-beacon"] = {value="solo", mode="strict"},
    ["se-compact-beacon"] = {value="solo", mode="strict"},
    ["se-compact-beacon-2"] = {value="solo", mode="strict"},
    ["se-wide-beacon"] = {value="solo", mode="strict"},
    ["se-wide-beacon-2"] = {value="solo", mode="strict"},
    ["ei_copper-beacon"] = {value="solo", mode="strict"},
    ["ei_iron-beacon"] = {value="solo", mode="strict"},
    ["el_ki_beacon_entity"] = {value="solo", mode="strict"},
    ["fi_ki_beacon_entity"] = {value="solo", mode="strict"},
    ["fu_ki_beacon_entity"] = {value="solo", mode="strict"}
    -- entries are added below for: Pyanodons AM-FM beacons, Bob's "beacon-3" (and mini/micro versions), productivity/speed beacons from Advanced Modules, beacons from Fast Furnaces, "beacon3", and "productivity-beacon"
  }
  local updated_repeating_beacons = { -- these beacons don't disable any of the beacons in the list associated with them
    ["beacon"] = {"beacon", "ab-standard-beacon", "kr-singularity-beacon", "beacon-mk1", "beacon-mk2", "beacon-mk3", "5d-beacon-02", "5d-beacon-03", "5d-beacon-04"}, -- additional entries added below
    ["ab-standard-beacon"] = {"beacon", "ab-standard-beacon", "kr-singularity-beacon", "beacon-mk1", "beacon-mk2", "beacon-mk3", "5d-beacon-02", "5d-beacon-03", "5d-beacon-04"}, -- additional entries added below
    ["kr-singularity-beacon"] = {"kr-singularity-beacon"},
    ["ei_copper-beacon"] = {"ei_copper-beacon","ei_iron-beacon"},
    ["ei_iron-beacon"] = {"ei_copper-beacon","ei_iron-beacon"},
    ["beacon-mk1"] = {"beacon", "ab-standard-beacon", "nullius-beacon-3"},
    ["beacon-mk2"] = {"beacon", "ab-standard-beacon", "nullius-beacon-3"},
    ["beacon-mk3"] = {"beacon", "ab-standard-beacon", "nullius-beacon-3"},
    ["el_ki_beacon_entity"] = {"el_ki_beacon_entity", "fi_ki_beacon_entity", "fu_ki_beacon_entity", "el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"},
    ["fi_ki_beacon_entity"] = {"el_ki_beacon_entity", "fi_ki_beacon_entity", "fu_ki_beacon_entity", "el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"},
    ["fu_ki_beacon_entity"] = {"el_ki_beacon_entity", "fi_ki_beacon_entity", "fu_ki_beacon_entity", "el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"},
    ["el_ki_core_slave_entity"] = {"el_ki_beacon_entity", "fi_ki_beacon_entity", "fu_ki_beacon_entity", "el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"},
    ["fi_ki_core_slave_entity"] = {"el_ki_beacon_entity", "fi_ki_beacon_entity", "fu_ki_beacon_entity", "el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"},
    ["fu_ki_core_slave_entity"] = {"el_ki_beacon_entity", "fi_ki_beacon_entity", "fu_ki_beacon_entity", "el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"},
    ["5d-beacon-02"] = {"beacon", "ab-standard-beacon", "nullius-beacon-3"},
    ["5d-beacon-03"] = {"beacon", "ab-standard-beacon", "nullius-beacon-3"},
    ["5d-beacon-04"] = {"beacon", "ab-standard-beacon", "nullius-beacon-3"},
    ["mini-beacon-1"] = {"mini-beacon-1"},
    ["micro-beacon-1"] = {"micro-beacon-1"}
    -- entries are added below for: pyanodons AM-FM beacons, nullius small/large beacons, mini/micro beacons, power crystals, alien beacons, warp beacons, editor beacons
  }

  local max_moduled_building_size = 9 -- by default, rocket silo (9x9) is the largest building which can use modules
  local standard = true
  local beacon_prototypes = game.get_filtered_entity_prototypes({{filter = "type", type = "beacon"}})
  local mods = script.active_mods
  if (mods["pycoalprocessing"] or mods["space-exploration"] or mods["mini"] or mods["Custom-Mods"]) then standard = false end

  -- adjusts reference tables
  if not standard then
    for name, beacon_list in pairs(updated_repeating_beacons) do
      for i=1,#beacon_list,1 do
        if beacon_list[i] == "beacon" then table.remove(updated_repeating_beacons[name], i) end
      end
    end
    updated_repeating_beacons["beacon"] = {}
  end
  if mods["space-exploration"] then
    custom_exclusion_ranges["beacon"] = {value = "solo", mode = "strict"}
    if mods["248k"] then -- changes KI beacons to solo-style beacons
      updated_repeating_beacons["el_ki_beacon_entity"] = {"el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"}
      updated_repeating_beacons["fi_ki_beacon_entity"] = {"el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"}
      updated_repeating_beacons["fu_ki_beacon_entity"] = {"el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"}
    end
  end
  -- TODO: prevent 248K beacon cores from being "disabled" even though it has no effect on them relaying module effects to beacons
  if mods["Beacon2"] then
    for _, beacon in pairs(beacon_prototypes) do                              -- TODO: can the beacon stats be checked directly instead of iterating through all beacons?
      if beacon.name == "beacon-2" and beacon.supply_area_distance < 3.5 then -- only allow repeating if it's a specific version (multiple mods use the same name)
        updated_repeating_beacons["beacon-2"] = {"ab-standard-beacon"}
        if standard then updated_repeating_beacons["beacon-2"] = {"beacon", "ab-standard-beacon"} end
        table.insert(updated_repeating_beacons["ab-standard-beacon"], "beacon-2")
        if standard then table.insert(updated_repeating_beacons["beacon"], "beacon-2") end
      end
    end
  end

  -- populate reference tables with repetitive and conditional info
  local repeaters_all = {}
  for name, beacon in pairs(beacon_prototypes) do
    table.insert(repeaters_all, beacon.name)
    if updated_types[name] == nil then updated_types[name] = {} end
  end
  if mods["Advanced_Modules"] or mods["Advanced_Sky_Modules"] or mods["Advanced_beacons"] then ------------------------------------------------------------------------------------------------------------
    if settings.startup["ab-balance-other-beacons"].value then
      custom_exclusion_ranges["productivity-beacon-1"] = {add=3}
      custom_exclusion_ranges["productivity-beacon-2"] = {add=4}
      custom_exclusion_ranges["productivity-beacon-3"] = {add=5}
      custom_exclusion_ranges["speed-beacon-2"] = {add=2}
      custom_exclusion_ranges["speed-beacon-3"] = {add=5}
    end
  end
  if mods["bobmodules"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    if settings.startup["ab-balance-other-beacons"].value and not (mods["CoppermineBobModuleRebalancing"] and settings.startup["coppermine-bob-module-nerfed-beacons"] and settings.startup["coppermine-bob-module-nerfed-beacons"].value) then
      custom_exclusion_ranges["beacon-3"] = {add=2}
    end
  end
  if mods["EndgameExtension"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    if settings.startup["ab-balance-other-beacons"].value then
      custom_exclusion_ranges["beacon-3"] = {add=2}
      custom_exclusion_ranges["productivity-beacon"] = {add=3}
    end
  end
  if mods["beacons"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    if settings.startup["ab-balance-other-beacons"].value then
      custom_exclusion_ranges["beacon3"] = {add=2}
    end
  end
  if mods["FastFurnaces"] then ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    if settings.startup["ab-balance-other-beacons"].value then
      custom_exclusion_ranges["reika-fast-beacon"] = {add=2}
      custom_exclusion_ranges["reika-fast-beacon-2"] = {value="solo", mode="strict"}
    end
  end
  if mods["starry-sakura"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    if startup["ab-balance-other-beacons"].value then
      updated_repeating_beacons["tiny-beacon"] = {"tiny-beacon"}
      updated_repeating_beacons["small-beacon"] = {"small-beacon"}
    end
  end
  if mods["nullius"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local repeaters_small = {"beacon", "ab-standard-beacon"}
    local repeaters_large = {}
    if not standard then repeaters_small = {"ab-standard-beacon"} end
    for tier=1,3,1 do
      if tier <= 2 then table.insert(repeaters_small, "nullius-large-beacon-" .. tier) end
      table.insert(repeaters_small, "nullius-beacon-" .. tier)
      table.insert(repeaters_large, "nullius-beacon-" .. tier)
      if standard then table.insert(updated_repeating_beacons["beacon"], "nullius-beacon-" .. tier) end
      table.insert(updated_repeating_beacons["ab-standard-beacon"], "nullius-beacon-" .. tier)
      for count=1,4,1 do
        table.insert(repeaters_small, "nullius-beacon-" .. tier .. "-" .. count)
        table.insert(repeaters_large, "nullius-beacon-" .. tier .. "-" .. count)
        if standard then table.insert(updated_repeating_beacons["beacon"], "nullius-beacon-" .. tier .. "-" .. count) end
        table.insert(updated_repeating_beacons["ab-standard-beacon"], "nullius-beacon-" .. tier .. "-" .. count)
      end
    end
    for tier=1,3,1 do
      if tier <= 2 then updated_repeating_beacons["nullius-large-beacon-" .. tier] = repeaters_large end
      updated_repeating_beacons["nullius-beacon-" .. tier] = repeaters_small
      for count=1,4,1 do
        updated_repeating_beacons["nullius-beacon-" .. tier .. "-" .. count] = repeaters_small
      end
    end
    for _, beacon_to_compare in pairs(updated_repeating_beacons["ab-standard-beacon"]) do -- small beacon 3 acts as a standard beacon
      local added = false
      for _, beacon in pairs (updated_repeating_beacons["nullius-beacon-3"]) do
        if beacon == beacon_to_compare then added = true end
      end
      if not added then table.insert(updated_repeating_beacons["nullius-beacon-3"], beacon_to_compare) end
    end
  end
  if mods["pycoalprocessing"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local repeaters_AM_FM = {}
    for am=1,5,1 do
      for fm=1,5,1 do
        table.insert(repeaters_AM_FM, "beacon-AM" .. am .. "-FM" .. fm)
        table.insert(repeaters_AM_FM, "diet-beacon-AM" .. am .. "-FM" .. fm)
      end
    end
    for am=1,5,1 do
      for fm=1,5,1 do
        custom_exclusion_ranges["beacon-AM" .. am .. "-FM" .. fm] = {value = "solo", mode = "strict"}
        custom_exclusion_ranges["diet-beacon-AM" .. am .. "-FM" .. fm] = {value = "solo", mode = "strict"}
        updated_repeating_beacons["beacon-AM" .. am .. "-FM" .. fm] = repeaters_AM_FM
        updated_repeating_beacons["diet-beacon-AM" .. am .. "-FM" .. fm] = repeaters_AM_FM
      end
    end
    max_moduled_building_size = math.max(11, max_moduled_building_size)
    if mods["pypetroleumhandling"] then max_moduled_building_size = math.max(15, max_moduled_building_size) end
  end
  if mods["PowerCrystals"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local repeaters_crystal = {}
    for tier=1,3,1 do
      table.insert(repeaters_crystal, "model-power-crystal-productivity-" .. tier)
      table.insert(repeaters_crystal, "model-power-crystal-effectivity-" .. tier)
      table.insert(repeaters_crystal, "model-power-crystal-speed-" .. tier)
      table.insert(repeaters_crystal, "base-power-crystal-" .. tier)
      if tier <= 2 then
        table.insert(repeaters_crystal, "model-power-crystal-instability-" .. tier)
        table.insert(repeaters_crystal, "base-power-crystal-negative-" .. tier)
      end
    end
    for _, beacon in pairs(beacon_prototypes) do
      if updated_repeating_beacons[beacon.name] == nil then updated_repeating_beacons[beacon.name] = {} end
      for i=1,#repeaters_crystal,1 do
        table.insert(updated_repeating_beacons[beacon.name], repeaters_crystal[i])
      end
    end
    for tier=1,3,1 do
      custom_exclusion_ranges["model-power-crystal-productivity-" .. tier] = {value = 0}
      custom_exclusion_ranges["model-power-crystal-effectivity-" .. tier] = {value = 0}
      custom_exclusion_ranges["model-power-crystal-speed-" .. tier] = {value = 0}
      custom_exclusion_ranges["base-power-crystal-" .. tier] = {value = 0}
      updated_repeating_beacons["model-power-crystal-productivity-" .. tier] = repeaters_all
      updated_repeating_beacons["model-power-crystal-effectivity-" .. tier] = repeaters_all
      updated_repeating_beacons["model-power-crystal-speed-" .. tier] = repeaters_all
      updated_repeating_beacons["base-power-crystal-" .. tier] = repeaters_all
      if tier <= 2 then
        custom_exclusion_ranges["model-power-crystal-instability-" .. tier] = {value = 0}
        custom_exclusion_ranges["base-power-crystal-negative-" .. tier] = {value = 0}
        updated_repeating_beacons["model-power-crystal-instability-" .. tier] = repeaters_all
        updated_repeating_beacons["base-power-crystal-negative-" .. tier] = repeaters_all
      end
    end
  end
  if mods["mini-machines"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    if settings.startup["ab-balance-other-beacons"].value == true then
      if mods["bobmodules"] then
        custom_exclusion_ranges["mini-beacon-3"] = {add=3}
      elseif mods["FactorioExtended-Plus-Module"] then
        updated_repeating_beacons["mini-beacon-1"] = {"mini-beacon-1", "mini-beacon-2", "mini-beacon-3", "mini-beacon-4"}
        updated_repeating_beacons["mini-beacon-2"] = {"mini-beacon-1"}
        updated_repeating_beacons["mini-beacon-3"] = {"mini-beacon-1"}
      elseif mods["5dim_module"] then
        updated_repeating_beacons["mini-beacon-1"] = {"mini-beacon-1", "mini-beacon-2", "mini-beacon-3", "mini-beacon-4"}
        updated_repeating_beacons["mini-beacon-2"] = {"mini-beacon-1"}
        updated_repeating_beacons["mini-beacon-3"] = {"mini-beacon-1"}
      end
      if mods["5dim_module"] then updated_repeating_beacons["mini-beacon-4"] = {"mini-beacon-1"} end
    end
  end
  if mods["micro-machines"] then --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    if settings.startup["ab-balance-other-beacons"].value == true then
      if mods["bobmodules"] then
        custom_exclusion_ranges["micro-beacon-3"] = {add=2}
      elseif mods["FactorioExtended-Plus-Module"] then
        updated_repeating_beacons["micro-beacon-1"] = {"micro-beacon-1", "micro-beacon-2", "micro-beacon-3", "micro-beacon-4"}
        updated_repeating_beacons["micro-beacon-2"] = {"micro-beacon-1"}
        updated_repeating_beacons["micro-beacon-3"] = {"micro-beacon-1"}
      elseif mods["5dim_module"] then
        updated_repeating_beacons["micro-beacon-1"] = {"micro-beacon-1", "micro-beacon-2", "micro-beacon-3", "micro-beacon-4"}
        updated_repeating_beacons["micro-beacon-2"] = {"micro-beacon-1"}
        updated_repeating_beacons["micro-beacon-3"] = {"micro-beacon-1"}
      end
      if mods["5dim_module"] then updated_repeating_beacons["micro-beacon-4"] = {"micro-beacon-1"} end
    end
  end
  if mods["exotic-industries"] then -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    max_moduled_building_size = math.max(11, max_moduled_building_size)
    for _, beacon in pairs(beacon_prototypes) do
      if updated_repeating_beacons[beacon.name] == nil then updated_repeating_beacons[beacon.name] = {} end
      table.insert(updated_repeating_beacons[beacon.name], "ei_alien-beacon")
    end
    custom_exclusion_ranges["ei_alien-beacon"] = {value=0}
    updated_repeating_beacons["ei_alien-beacon"] = repeaters_all
    -- TODO: Make copper/iron beacons repeatable for all other beacons since they can't be disabled anyway
  end
  if mods["warptorio2"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    for _, beacon in pairs(beacon_prototypes) do
      if updated_repeating_beacons[beacon.name] == nil then updated_repeating_beacons[beacon.name] = {} end
      for i=1,10,1 do
        table.insert(updated_repeating_beacons[beacon.name], "warptorio-beacon-" .. tostring(i))
      end
    end
    for i=1,10,1 do
      custom_exclusion_ranges["warptorio-beacon-" .. tostring(i)] = {value=0}
      updated_repeating_beacons["warptorio-beacon-" .. tostring(i)] = repeaters_all
    end
  end
  if mods["LunarLandings"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    for _, beacon in pairs(beacon_prototypes) do
      if updated_repeating_beacons[beacon.name] == nil then updated_repeating_beacons[beacon.name] = {} end
      table.insert(updated_repeating_beacons[beacon.name], "ll-oxygen-diffuser")
    end
    custom_exclusion_ranges["ll-oxygen-diffuser"] = {value=0}
    updated_repeating_beacons["ll-oxygen-diffuser"] = repeaters_all
  end
  if mods["EditorExtensions"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    for _, beacon in pairs(beacon_prototypes) do
      if updated_repeating_beacons[beacon.name] == nil then updated_repeating_beacons[beacon.name] = {} end
      table.insert(updated_repeating_beacons[beacon.name], "ee-super-beacon")
    end
    custom_exclusion_ranges["ee-super-beacon"] = {value=0}
    updated_repeating_beacons["ee-super-beacon"] = repeaters_all
  end
  if mods["creative-mod"] then ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    for _, beacon in pairs(beacon_prototypes) do
      if updated_repeating_beacons[beacon.name] == nil then updated_repeating_beacons[beacon.name] = {} end
      table.insert(updated_repeating_beacons[beacon.name], "creative-mod_super-beacon")
    end
    custom_exclusion_ranges["creative-mod_super-beacon"] = {value=0}
    updated_repeating_beacons["creative-mod_super-beacon"] = repeaters_all
  end
  if mods["janky-beacon-rebalance"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local repeaters_janky = {"beacon", "ab-standard-beacon"}
    for count=1,24,1 do
      for quality=1,5,1 do
        if quality == 1 then
          table.insert(repeaters_janky, "janky-beacon-" .. count)
        else
          table.insert(repeaters_janky, "janky-beacon-" .. count .. "-quality-" .. quality)
        end
      end
    end
    for count=1,24,1 do
      for quality=1,5,1 do
        updated_repeating_beacons["janky-beacon-" .. count] = repeaters_janky
        updated_repeating_beacons["janky-beacon-" .. count .. "-quality-" .. quality] = repeaters_janky
      end
    end
  end
  if mods["modular-beacon-power"] then --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    for urbname,urb in pairs(updated_repeating_beacons) do
      local urb_addons = {}
      for _,repname in pairs(urb) do
        local variants = {}
        for name,_ in pairs(beacon_prototypes) do
          if base_name(name) == repname and name ~= repname then table.insert(variants, name) end
        end
        for _,variant in pairs(variants) do
          table.insert(urb_addons, variant)
        end
      end
      for _,addon in pairs(urb_addons) do
        table.insert(urb, addon) -- adds variants of each beacon in the ordered lists to those lists
      end
      local variants = {}
      for name,_ in pairs(beacon_prototypes) do
        if base_name(name) == urbname and name ~= urbname then table.insert(variants, name) end
      end
      for _,variant in pairs(variants) do
        updated_repeating_beacons[variant] = urb -- variants have the same lists
      end
    end
    for cername,cer in pairs(custom_exclusion_ranges) do
      local variants = {}
      for name,_ in pairs(beacon_prototypes) do
        if base_name(name) == cername and name ~= cername then table.insert(variants, name) end
      end
      for _,variant in pairs(variants) do
        custom_exclusion_ranges[variant] = cer -- variants have the same exclusion ranges
      end
    end
    for typename,type in pairs(updated_types) do
      if type.conflux or type.hub then
        local variants = {}
        for name,_ in pairs(beacon_prototypes) do
          if base_name(name) == typename and name ~= typename then table.insert(variants, name) end
        end
        for _,variant in pairs(variants) do
          updated_types[variant] = type -- variant conflux/hub beacons behave the same
        end
      end
    end
  end

  -- set distribution/exclusion ranges
  for _, beacon in pairs(beacon_prototypes) do
    updated_distribution_ranges[beacon.name] = math.ceil(get_distribution_range(beacon))
    if updated_exclusion_ranges[beacon.name] == nil then
      local exclusion_range = updated_distribution_ranges[beacon.name]
      local range = custom_exclusion_ranges[beacon.name]
      if range then
        if range.value == nil then
          if range.add then exclusion_range = exclusion_range + range.add end
        elseif range.value == "solo" then
          if range.mode == nil or range.mode == "basic" then
            exclusion_range = 2*updated_distribution_ranges[beacon.name] + max_moduled_building_size-1
          elseif range.mode == "strict" then
            exclusion_range = updated_distribution_ranges[beacon.name] + max_moduled_building_size-1
          end
        else
          exclusion_range = range.value
        end
        if range.mode and range.mode == "strict" then updated_types[beacon.name].strict = true end
      end
      updated_exclusion_ranges[beacon.name] = exclusion_range
    end
  end

  -- setup relationship table of beacons which should be able to repeat without extra interference (they won't disable each other)
  for _, beacon in pairs(beacon_prototypes) do
    if updated_repeating_beacons[beacon.name] ~= nil then
      local affected_beacons = {}
      for i=1,#updated_repeating_beacons[beacon.name],1 do
        local is_valid = false
        for _, beacon_to_compare in pairs(beacon_prototypes) do
          if beacon_to_compare.name == updated_repeating_beacons[beacon.name][i] then is_valid = true end
        end
        if is_valid == true then affected_beacons[ updated_repeating_beacons[beacon.name][i] ] = true end
      end
      global.repeating_beacons[beacon.name] = affected_beacons
    end
  end

  -- setup table of the maximum ranges at which each beacon could affect or be affected by others
  local updated_search_ranges = {}
  for name1, beacon1 in pairs(beacon_prototypes) do
    local highest_exclusion_range = 0
    local highest_distribution_range = 0
    local highest_strict_range = 0
    for name2, beacon2 in pairs(beacon_prototypes) do
      if not ((global.repeating_beacons[name1] and global.repeating_beacons[name1][name2]) or (global.repeating_beacons[name2] and global.repeating_beacons[name2][name1])) then
        if updated_exclusion_ranges[name2] > highest_exclusion_range then highest_exclusion_range = updated_exclusion_ranges[name2] end
        if updated_distribution_ranges[name2] > highest_distribution_range then highest_distribution_range = updated_distribution_ranges[name2] end
        if updated_types[name2].strict and updated_exclusion_ranges[name2] > highest_strict_range then highest_strict_range = updated_exclusion_ranges[name2] end
      end
    end
    local range = math.max(updated_exclusion_ranges[name1], highest_exclusion_range)
    if updated_types[name1].strict then range = math.max(range, updated_exclusion_ranges[name1] + highest_distribution_range) end
    range = math.max(range, updated_distribution_ranges[name1] + highest_strict_range)
    updated_search_ranges[name1] = range
  end

  global.exclusion_ranges = updated_exclusion_ranges
  global.distribution_ranges = updated_distribution_ranges
  global.search_ranges = updated_search_ranges
  global.strict_beacons = updated_types
  exclusion_ranges = updated_exclusion_ranges
  distribution_ranges = updated_distribution_ranges
  search_ranges = updated_search_ranges
  types = updated_types
  repeating_beacons = global.repeating_beacons
  offline_beacons = global.offline_beacons
  update_rate = settings.global["ab-update-rate"].value
  persistent_alerts = settings.global["ab-persistent-alerts"].value

  if settings.startup["ab-disable-exclusion-areas"].value == false then
    enable_scripts(mods)
    check_global_list()
  end
end

-- returns the distribution range for the given beacon (from the edge of selection rather than edge of collision)
function get_distribution_range(beacon)
  local collision_radius = (beacon.collision_box.right_bottom.x - beacon.collision_box.left_top.x) / 2 -- beacon's collision is assumed to be centered on its origin; standard format assumed (leftTop, rightBottom)
  local selection_radius = (beacon.selection_box.right_bottom.x - beacon.selection_box.left_top.x) / 2 -- selection box is assumed to be in full tiles
  local range = beacon.supply_area_distance - (selection_radius - collision_radius)
  if selection_radius < collision_radius then range = beacon.supply_area_distance end
  do return range end -- note: use ceil() on the returned range to get the total tiles affected
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- runtime functions
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- checks all beacons
function check_global_list()
  -- TODO: Spread actions over many ticks instead of just letting it go as quickly as possible
  for _, surface in pairs(game.surfaces) do
    if surface ~= nil then
      local beacons = surface.find_entities_filtered({type = "beacon"})
      for _, beacon in pairs(beacons) do
        check_self(beacon, -1, nil)
      end
    end
  end
end

-- returns the distance between two bounding boxes
function get_distance(box_a, box_b)
  local x1 = box_a.right_bottom.x - box_b.left_top.x
  local x2 = box_b.right_bottom.x - box_a.left_top.x
  local y1 = box_a.right_bottom.y - box_b.left_top.y
  local y2 = box_b.right_bottom.y - box_a.left_top.y
  local dx = math.min(math.abs(x1), math.abs(x2))
  local dy = math.min(math.abs(y1), math.abs(y2))
  if x1 > 0 and x2 > 0 then dx = 0 end
  if y1 > 0 and y2 > 0 then dy = 0 end
  do return math.max(dx, dy) end
end

-- enables or disables beacons within the exclusion field (or other effective range) of an added/removed beacon entity
--   @behavior: either "added" or "removed"
function check_nearby(entity, behavior)
  if behavior == "removed" then remove_beacon_alert(entity) end
  local exclusion_mode = "normal"
  local exclusion_range = exclusion_ranges[entity.name]
  local search_range = search_ranges[entity.name]
  if types[entity.name].strict ~= nil then exclusion_mode = "strict" end
  local search_area = {
    {entity.selection_box.left_top.x - search_range, entity.selection_box.left_top.y - search_range},
    {entity.selection_box.right_bottom.x + search_range, entity.selection_box.right_bottom.y + search_range}
  }
  -- find surrounding beacons and setup general info needed to determine correct behaviors
  local hubCount = 0
  local hubIDs = {}
  local nearby_entities = entity.surface.find_entities_filtered({area = search_area, type = "beacon"})
  if types[entity.name].hub == nil and entity.name ~= "ll-oxygen-diffuser" then
    for _, nearby_entity in pairs(nearby_entities) do
      if types[nearby_entity.name].hub then
        if get_distance(entity.selection_box, nearby_entity.selection_box) < exclusion_ranges[nearby_entity.name] then
          hubCount = hubCount + 1
          table.insert(hubIDs, nearby_entity.unit_number)
        end
      end
    end
  end
  -- adjust nearby beacons as needed
  for _, nearby_entity in pairs(nearby_entities) do
    if nearby_entity.unit_number ~= entity.unit_number and nearby_entity.name ~= "ll-oxygen-diffuser" then
      local nearby_distance = get_distance(entity.selection_box, nearby_entity.selection_box)
      local disabling_range = exclusion_range
      if hubCount > 0 then
        if check_influence(nearby_entity, hubIDs) then exclusion_mode = "super" end -- beacons within a single hub's area affect each other differently
      end
      if exclusion_mode == "strict" then disabling_range = math.max(disabling_range, exclusion_range + distribution_ranges[nearby_entity.name]) end
      if exclusion_mode == "super" then disabling_range = math.max(disabling_range, exclusion_range + exclusion_ranges[nearby_entity.name]) end
      if types[nearby_entity.name].conflux then
        local nearby_distribution_width = 2*distribution_ranges[nearby_entity.name] + nearby_entity.selection_box.right_bottom.x - nearby_entity.selection_box.left_top.x
        local distribution_width = 2*distribution_ranges[entity.name] + entity.selection_box.right_bottom.x - entity.selection_box.left_top.x
        if distribution_width >= nearby_distribution_width then disabling_range = math.max(disabling_range, distribution_ranges[entity.name] + distribution_ranges[nearby_entity.name]) end -- semi-strict
      end
      if nearby_distance < disabling_range then
        local wasEnabled = nearby_entity.active
        local removed_id = -1
        if behavior ~= "added" then removed_id = entity.unit_number end
        if use_repeating_behavior(entity, nearby_entity) == false then -- some beacons don't affect each other
          if behavior == "added" then
            nearby_entity.active = false
          else
            nearby_entity.active = true
          end
        end
        check_self(nearby_entity, removed_id, wasEnabled)
      end
    end
  end
  if behavior == "added" then
    local wasEnabled = entity.active
    check_self(entity, -1, wasEnabled)
  end
end

-- enables or disables a beacon entity based on exclusion fields and behaviors of surrounding beacons
--   @removed_id: the unit_number of a removed beacon or -1 if no beacon was removed
--   @wasEnabled: whether the beacon was active or not prior to the current checking process
function check_self(entity, removed_id, wasEnabled)
  local isEnabled = true
  local search_range = search_ranges[entity.name]
  local search_area = {
    {entity.selection_box.left_top.x - search_range, entity.selection_box.left_top.y - search_range},
    {entity.selection_box.right_bottom.x + search_range, entity.selection_box.right_bottom.y + search_range}
  }
  -- find surrounding beacons and setup general info needed to determine correct behaviors
  local hubCount = 0
  local hubID = -1
  local hubIDs = {}
  local nearby_entities = entity.surface.find_entities_filtered({area = search_area, type = "beacon"})
  if types[entity.name].hub == nil and entity.name ~= "ll-oxygen-diffuser" then
    for _, nearby_entity in pairs(nearby_entities) do
      if types[nearby_entity.name].hub and nearby_entity.unit_number ~= removed_id then
        if get_distance(entity.selection_box, nearby_entity.selection_box) < exclusion_ranges[nearby_entity.name] then
          hubCount = hubCount + 1
          if hubCount == 1 then hubID = nearby_entity.unit_number end
          table.insert(hubIDs, nearby_entity.unit_number)
          isEnabled = false
        end
      end
    end
    if hubCount > 1 then hubID = -1 end
    if hubCount == 1 then isEnabled = true end
  end
  -- adjust beacon based on surrounding beacons
  for _, nearby_entity in pairs(nearby_entities) do
    if (nearby_entity.unit_number ~= entity.unit_number and nearby_entity.unit_number ~= removed_id and nearby_entity.name ~= "ll-oxygen-diffuser") then
      local exclusion_mode = "normal"
      local nearby_distance = get_distance(entity.selection_box, nearby_entity.selection_box)
      local disabling_range = exclusion_ranges[nearby_entity.name]
      if types[nearby_entity.name].strict ~= nil then exclusion_mode = "strict" end
      if hubCount > 0 and types[nearby_entity.name].hub == nil then
        if check_influence(nearby_entity, hubIDs) then exclusion_mode = "super" end -- beacons within a single hub's area affect each other differently
      end
      if exclusion_mode == "strict" then disabling_range = math.max(disabling_range, exclusion_ranges[nearby_entity.name] + distribution_ranges[entity.name]) end
      if exclusion_mode == "super" then disabling_range = math.max(disabling_range, exclusion_ranges[nearby_entity.name] + exclusion_ranges[entity.name]) end
      if types[entity.name].conflux then
        local nearby_distribution_width = 2*distribution_ranges[nearby_entity.name] + nearby_entity.selection_box.right_bottom.x - nearby_entity.selection_box.left_top.x
        local distribution_width = 2*distribution_ranges[entity.name] + entity.selection_box.right_bottom.x - entity.selection_box.left_top.x
        if nearby_distribution_width >= distribution_width then disabling_range = math.max(disabling_range, distribution_ranges[entity.name] + distribution_ranges[nearby_entity.name]) end -- semi-strict
      end
      if types[nearby_entity.name].hub == nil then
        if nearby_distance < disabling_range then
          if exclusion_mode == "super" or use_repeating_behavior(nearby_entity, entity) == false then isEnabled = false end -- some beacons don't affect each other
        end
      elseif (types[nearby_entity.name].hub and types[entity.name].conflux) then
        disabling_range = distribution_ranges[entity.name] + distribution_ranges[nearby_entity.name]
        if nearby_distance < disabling_range then isEnabled = false end
      elseif (types[nearby_entity.name].hub and types[entity.name].hub) then
        disabling_range = exclusion_ranges[nearby_entity.name]
        if nearby_distance < disabling_range then isEnabled = false end
      end
    end
  end
  if (isEnabled == false and (entity.name == "ei_copper-beacon" or entity.name == "ei_iron-beacon")) then isEnabled = true end
  if (entity.name == "base-power-crystal-1" or entity.name == "base-power-crystal-2" or entity.name == "base-power-crystal-3" or entity.name == "base-power-crystal-negative-1" or entity.name == "base-power-crystal-negative-2") then isEnabled = true end
  entity.active = isEnabled
  handle_change(entity, wasEnabled, isEnabled)
end

-- handles warning sprites, flying text, and alerts
function handle_change(entity, wasEnabled, isEnabled)
  if (wasEnabled == true and isEnabled == false) then -- beacon deactivated
    entity.surface.create_entity{
      name = "flying-text",
      position = entity.position,
      text = {"description.ab_beacon_deactivated"}
    }
    if offline_beacons[entity.unit_number] == nil then
      add_beacon_warning(entity)
      for _, player in pairs(entity.force.players) do
        add_beacon_alert(entity, player)
      end
    end
  elseif (wasEnabled == false and isEnabled == true) then -- beacon activated
    --entity.surface.create_entity{
    --  name = "flying-text",
    --  position = entity.position,
    --  text = {"description.ab_beacon_activated"}
    --}
    remove_beacon_warning(entity)
  elseif (isEnabled == false and offline_beacons[entity.unit_number] == nil) then -- adds icons to old deactivated beacons (may not be necessary)
    add_beacon_warning(entity)
  elseif (isEnabled == true and offline_beacons[entity.unit_number] ~= nil) then -- removes icons in other cases (may not be necessary)
    remove_beacon_warning(entity)
  end
end

-- adds a warning sprite to a disabled beacon
function add_beacon_warning(entity)
  offline_beacons[entity.unit_number] = {
    rendering.draw_sprite{
      sprite = "ab_beacon_offline",
      target = entity,
      surface = entity.surface,
      x_scale = 0.5,
      y_scale = 0.5
    },
    entity
  }
end

-- removes a warning sprite from a beacon
function remove_beacon_warning(entity)
  if offline_beacons[entity.unit_number] ~= nil then
    remove_beacon_alert(offline_beacons[entity.unit_number][2])
    rendering.destroy(offline_beacons[entity.unit_number][1])
    offline_beacons[entity.unit_number] = nil
  end
end

-- adds a flashing alert to the bottom right of the GUI for a disabled beacon and player 
function add_beacon_alert(entity, player)
  player.add_custom_alert(entity,
  {type="virtual", name="ab_beacon_offline"},
  {"description.ab_beacon_offline_alert", "[img=virtual-signal/ab_beacon_offline]", "[img=entity/" .. entity.name .. "]"},
  true)
  --if persistent_alerts == true and #offline_beacons > 0 then register_alert_refreshing() end -- TODO: Can persistent alerts be modified to have zero performance impact whenever there are no offline beacons?
end

-- removes flashing alerts for the given beacon (all players)
function remove_beacon_alert(beacon_entity)
  for _, player in pairs(beacon_entity.force.players) do
    --player.remove_alert({entity=beacon_entity, type=defines.alert_type.custom, position=beacon_entity.position, surface=beacon_entity.surface, message={"description.ab_beacon_offline_alert"}, icon={type="virtual", name="ab_beacon_offline"}})
    player.remove_alert({entity=beacon_entity}) -- this applies to any of the filters rather than requiring all of them to match
  end
  --if persistent_alerts == true and #offline_beacons == 0 then unregister_alert_refreshing() end
end

-- returns true if the given beacon (entity) is within the exclusion field of a specific hub (hubID)
--   used to determine if the beacon's overlapping area should apply to another beacon near the specific hub (it only applies for beacons within the same hub's exclusion area)
function check_influence(entity, hubIDs)
  local isInfluenced = false
  if exclusion_ranges["ab-hub-beacon"] ~= nil then
    local exclusion_range = exclusion_ranges["ab-hub-beacon"]
    local exclusion_area = {
      {entity.selection_box.left_top.x - exclusion_range, entity.selection_box.left_top.y - exclusion_range},
      {entity.selection_box.right_bottom.x + exclusion_range, entity.selection_box.right_bottom.y + exclusion_range}
    }
    local nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon"})
    for _, beacon in pairs(nearby_beacons) do
      if types[beacon.name].hub then
        for _, hub_number in pairs(hubIDs) do
          if beacon.unit_number == hub_number then isInfluenced = true end
        end
      end
    end
  end
  do return isInfluenced end
end

-- returns true if the the beacons shouldn't disable each other
function use_repeating_behavior(entity1, entity2)
  local result = false
  if entity1.unit_number ~= entity2.unit_number then
    if repeating_beacons[entity1.name] and repeating_beacons[entity1.name][entity2.name] then result = true end
  end
  do return result end
end

-- checks all beacons within range of the given beacon
function check_remote(entity, behavior, extra_search_range)
  if entity.type == "beacon" then
    local search_range = search_ranges[entity.name] + extra_search_range
    local search_area = {
      {entity.selection_box.left_top.x - search_range, entity.selection_box.left_top.y - search_range},
      {entity.selection_box.right_bottom.x + search_range, entity.selection_box.right_bottom.y + search_range}
    }
    local nearby_beacons = entity.surface.find_entities_filtered({area = search_area, type = "beacon"})
    for _, beacon in pairs(nearby_beacons) do
      local wasEnabled = beacon.active
      if behavior == "added" then
        check_self(beacon, -1, wasEnabled)
      elseif (beacon.unit_number ~= entity.unit_number) then
        check_self(beacon, entity.unit_number, wasEnabled)
      end
    end
  end
end

-- re-issues alerts for beacons which were disabled by this mod (they naturally end after 10 seconds)
function refresh_beacon_alerts()
  for i, offline_beacon in pairs(offline_beacons) do
    if offline_beacon ~= nil then
      local beacon = offline_beacon[2]
      if beacon and beacon.valid then
        for _, player in pairs(beacon.force.players) do
          add_beacon_alert(beacon, player)
        end
      end
    end
  end
end

--- Returns the "base" part of a beacon name to the left of the separator for the modular-beacon-power mod
--- @param name string
--- @return string
function base_name(name)
  local t = {}
  for s in string.gmatch(name, "([^__MBP]+)") do
    table.insert(t,s)
  end
  return t[1]
end
