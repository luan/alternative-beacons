--- control.lua
--  this file is loaded prior to any scripts/functions and reloaded each time a game is saved/loaded so changes here can be tested without relaunching the game; available objects: script, remote, commands

local exclusion_ranges = {}     -- beacon prototype name -> range for affected beacons
local distribution_ranges = {}  -- beacon prototype name -> range for affected crafting machines
local strict_beacon_ranges = {} -- beacon prototype names for those with "strict" exclusion ranges
local repeating_beacons = {}    -- beacon prototype name -> list of beacons which won't be disabled
local offline_beacons = {}      -- beacon unit numbers -> their attached warning sprites
local update_rate = -1          -- if non-negative, how many seconds elapse between updating all beacons (beacons are only updated on triggered events by default)

--- Mod Initialization - called on first startup after the mod is installed; available objects: global, game, rendering, settings
script.on_init(
  function()
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
    strict_beacon_ranges = global.strict_beacon_ranges
    repeating_beacons = global.repeating_beacons
    offline_beacons = global.offline_beacons
    update_rate = settings.global["ab-update-rate"].value
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


-- TODO: Add a setting or remote interface for other mods to disable exclusion areas for all beacons and/or individual beacons
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
    if event.setting == "ab-update-rate" then update_rate = settings.global["ab-update-rate"].value end
  end
)

script.on_event(
  defines.events.on_tick,
  function(event)
    if (update_rate >= 0) then -- only runs if user adjusts settings (update_rate is -1 by default)
      if event.tick % 60 == 0 then
        if event.tick % (60 * update_rate) == 0 then check_global_list() end -- verifies proper behavior intermittently in case the above events don't catch everything
      end
    end
  end
)

--- updates global data
--  creates and updates exclusion ranges for all beacons - beacons from other mods will use their distribution range as their exclusion range
function populate_beacon_data()
  global = { exclusion_ranges = {}, distribution_ranges = {}, strict_beacon_ranges = {}, offline_beacons = {},  repeating_beacons = {} }
  local updated_distribution_ranges = {}
  local updated_strict_beacon_ranges = {}
  local updated_offline_beacons = {}
  local updated_exclusion_ranges = {}
  local custom_beacon_exclusion_ranges = { -- these beacons are given custom exclusion ranges: "strict" means the smallest exclusion range which is large enough to prevent them from synergizing with other beacons
    ["ab-focused-beacon"] = 3,
    ["ab-conflux-beacon"] = 12,
    ["ab-hub-beacon"] = 34,
    ["ab-isolation-beacon"] = 68,
    ["se-compact-beacon"] = "strict",
    ["se-compact-beacon-2"] = "strict",
    ["se-wide-beacon"] = "strict",
    ["se-wide-beacon-2"] = "strict",
    ["ei_copper-beacon"] = "strict",
    ["ei_iron-beacon"] = "strict",
    ["el_ki_beacon_entity"] = "strict",
    ["fi_ki_beacon_entity"] = "strict",
    ["fu_ki_beacon_entity"] = "strict",
    ["el_ki_core_slave_entity"] = "strict",
    ["productivity-beacon"] = 6,
    ["productivity-beacon-1"] = 5,
    ["productivity-beacon-2"] = 6,
    ["productivity-beacon-3"] = 7,
    ["speed-beacon-2"] = 8,
    ["speed-beacon-3"] = 11,
    -- pyanodons AM-FM entries are added below
  }
  local updated_repeating_beacons = {
    ["beacon"] = {"beacon", "ab-standard-beacon", "kr-singularity-beacon", "beacon-mk1", "beacon-mk2", "beacon-mk3", "5d-beacon-02", "5d-beacon-03", "5d-beacon-04"}, -- additional entries added below
    ["ab-standard-beacon"] = {"beacon", "ab-standard-beacon", "kr-singularity-beacon", "beacon-mk1", "beacon-mk2", "beacon-mk3", "5d-beacon-02", "5d-beacon-03", "5d-beacon-04"}, -- additional entries added below
    ["kr-singularity-beacon"] = {"kr-singularity-beacon"},
    ["ei_copper-beacon"] = {"ei_copper-beacon","ei_iron-beacon"}, -- TODO: only if beacon overloading is enabled
    ["ei_iron-beacon"] = {"ei_copper-beacon","ei_iron-beacon"},
    ["beacon-mk1"] = {"beacon"},
    ["beacon-mk2"] = {"beacon"},
    ["beacon-mk3"] = {"beacon"},
    ["el_ki_beacon_entity"] = {"el_ki_beacon_entity", "fi_ki_beacon_entity", "fu_ki_beacon_entity", "el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"},
    ["fi_ki_beacon_entity"] = {"el_ki_beacon_entity", "fi_ki_beacon_entity", "fu_ki_beacon_entity", "el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"},
    ["fu_ki_beacon_entity"] = {"el_ki_beacon_entity", "fi_ki_beacon_entity", "fu_ki_beacon_entity", "el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"},
    ["el_ki_core_slave_entity"] = {"el_ki_beacon_entity", "fi_ki_beacon_entity", "fu_ki_beacon_entity", "el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"},
    ["fi_ki_core_slave_entity"] = {"el_ki_beacon_entity", "fi_ki_beacon_entity", "fu_ki_beacon_entity", "el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"},
    ["fu_ki_core_slave_entity"] = {"el_ki_beacon_entity", "fi_ki_beacon_entity", "fu_ki_beacon_entity", "el_ki_core_slave_entity", "fi_ki_core_slave_entity", "fu_ki_core_slave_entity"},
    ["5d-beacon-02"] = {"beacon"},
    ["5d-beacon-03"] = {"beacon"},
    ["5d-beacon-04"] = {"beacon"},
    -- nullius small/large entries are added below
    -- pyanodons AM-FM entries are added below
    -- power crystal entries are added below
  }

  -- TODO: add function to allow more balance changes involving exclusion ranges to be enabled/disabled in the settings?

  -- general variables & flow control
  local max_moduled_building_size = 9 -- by default, rocket silo (9x9) is the largest building which can use modules
  local strict_standard_beacon = false
  local add_interface = false
  local do_crystals = false
  local do_exotic = false
  local beacon_prototypes = game.get_filtered_entity_prototypes({{filter = "type", type = "beacon"}}) -- TODO generalize (this shouldn't require a loop to check if specific beacons exist)
  for _, beacon in pairs(beacon_prototypes) do
    if beacon.name == "ei_copper-beacon" then do_exotic = true end                -- if mods["exotic-industries"]
    if beacon.name == "se-compact-beacon" then strict_standard_beacon = true end  -- if mods["space-exploration"]
    if beacon.name == "beacon-AM1-FM1" then add_interface = true end              -- if mods["pypostprocessing"]
    if beacon.name == "beacon-2" and beacon.supply_area_distance < 3.5 then       -- only allow repeating if it's a specific version (multiple mods use the same name)
      updated_repeating_beacons["beacon-2"] = {"beacon"}
      table.insert(updated_repeating_beacons["beacon"], "beacon-2")
    end
    if beacon.name == "model-power-crystal-speed-1" or beacon.name == "model-power-crystal-speed-" then do_crystals = true end   -- if mods["PowerCrystals"]
  end
  if strict_standard_beacon == true and settings.startup["ab-override-vanilla-beacons"].value == false then custom_beacon_exclusion_ranges["beacon"] = "strict" end
  
  -- populate reference tables with repetitive info
  local repeaters_small = {"beacon"}
  local repeaters_large = {}
  for tier=1,3,1 do
    if tier <= 2 then table.insert(repeaters_small, "nullius-large-beacon-" .. tier) end
    table.insert(repeaters_small, "nullius-beacon-" .. tier)
    table.insert(repeaters_large, "nullius-beacon-" .. tier)
    table.insert(updated_repeating_beacons["beacon"], "nullius-beacon-" .. tier)
    table.insert(updated_repeating_beacons["ab-standard-beacon"], "nullius-beacon-" .. tier)
    for count=1,4,1 do
      table.insert(repeaters_small, "nullius-beacon-" .. tier .. "-" .. count)
      table.insert(repeaters_large, "nullius-beacon-" .. tier .. "-" .. count)
      table.insert(updated_repeating_beacons["beacon"], "nullius-beacon-" .. tier .. "-" .. count)
      table.insert(updated_repeating_beacons["ab-standard-beacon"], "nullius-beacon-" .. tier .. "-" .. count)
    end
  end
  for i=1,3,1 do
    if i <= 2 then updated_repeating_beacons["nullius-large-beacon-" .. i] = repeaters_large end
    updated_repeating_beacons["nullius-beacon-" .. i] = repeaters_small
    for j=1,4,1 do
      updated_repeating_beacons["nullius-beacon-" .. i .. "-" .. j] = repeaters_small
    end
  end
  local repeaters_AM_FM = {}
  for am=1,5,1 do
    for fm=1,5,1 do
      table.insert(repeaters_AM_FM, "beacon-AM" .. am .. "-FM" .. fm)
      table.insert(repeaters_AM_FM, "diet-beacon-AM" .. am .. "-FM" .. fm)
    end
  end
  for i=1,5,1 do
    for j=1,5,1 do
      custom_beacon_exclusion_ranges["beacon-AM" .. i .. "-FM" .. j] = "strict"
      custom_beacon_exclusion_ranges["diet-beacon-AM" .. i .. "-FM" .. j] = "strict"
      updated_repeating_beacons["beacon-AM" .. i .. "-FM" .. j] = repeaters_AM_FM
      updated_repeating_beacons["diet-beacon-AM" .. i .. "-FM" .. j] = repeaters_AM_FM
    end
  end
  if do_crystals then
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
    local repeaters_all = {}
    for _, beacon in pairs(beacon_prototypes) do
      table.insert(repeaters_all, beacon.name)
    end
    for tier=1,3,1 do
      custom_beacon_exclusion_ranges["model-power-crystal-productivity-" .. tier] = 0
      custom_beacon_exclusion_ranges["model-power-crystal-effectivity-" .. tier] = 0
      custom_beacon_exclusion_ranges["model-power-crystal-speed-" .. tier] = 0
      custom_beacon_exclusion_ranges["base-power-crystal-" .. tier] = 0
      updated_repeating_beacons["model-power-crystal-productivity-" .. tier] = repeaters_all
      updated_repeating_beacons["model-power-crystal-effectivity-" .. tier] = repeaters_all
      updated_repeating_beacons["model-power-crystal-speed-" .. tier] = repeaters_all
      updated_repeating_beacons["base-power-crystal-" .. tier] = repeaters_all
      if tier <= 2 then
        custom_beacon_exclusion_ranges["model-power-crystal-instability-" .. tier] = 0
        custom_beacon_exclusion_ranges["base-power-crystal-negative-" .. tier] = 0
        updated_repeating_beacons["model-power-crystal-instability-" .. tier] = repeaters_all
        updated_repeating_beacons["base-power-crystal-negative-" .. tier] = repeaters_all
      end
    end
  end
  if do_exotic then
    max_moduled_building_size = 11
    for _, beacon in pairs(beacon_prototypes) do
      if updated_repeating_beacons[beacon.name] == nil then updated_repeating_beacons[beacon.name] = {} end
      table.insert(updated_repeating_beacons[beacon.name], "ei_alien-beacon")
    end
  end

  -- set distribution/exclusion ranges
  -- TODO: Change exclusion range to be based on how much is added from distribution range? if other mods change the distribution range, everything would be messed up but it might be less broken if the exclusion ranges are based on the changed values instead of hardcoded
  for _, beacon in pairs(beacon_prototypes) do
    updated_distribution_ranges[beacon.name] = math.ceil(get_distribution_range(beacon))
    if updated_exclusion_ranges[beacon.name] == nil then
      local exclusion_range = updated_distribution_ranges[beacon.name]
      if custom_beacon_exclusion_ranges[beacon.name] ~= nil then
        if custom_beacon_exclusion_ranges[beacon.name] == "strict" then
          exclusion_range = exclusion_range + max_moduled_building_size-1
          updated_strict_beacon_ranges[beacon.name] = exclusion_range
        elseif custom_beacon_exclusion_ranges[beacon.name] == "basic" then
          exclusion_range = 2*beacon.supply_area_distance + max_moduled_building_size-1
        else
          exclusion_range = custom_beacon_exclusion_ranges[beacon.name]
        end
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
          if beacon_to_compare.name == updated_repeating_beacons[beacon.name][i] then
            is_valid = true
            if (beacon.name == "beacon" and beacon_to_compare.name == "beacon" and strict_standard_beacon == true and settings.startup["ab-override-vanilla-beacons"].value == false) then is_valid = false end
          end
        end
        if is_valid == true then
          table.insert(affected_beacons, updated_repeating_beacons[beacon.name][i])
        end
      end
      global.repeating_beacons[beacon.name] = affected_beacons
    end
  end

  global.exclusion_ranges = updated_exclusion_ranges
  global.distribution_ranges = updated_distribution_ranges
  global.strict_beacon_ranges = updated_strict_beacon_ranges
  global.offline_beacons = updated_offline_beacons
  exclusion_ranges = updated_exclusion_ranges
  distribution_ranges = updated_distribution_ranges
  strict_beacon_ranges = updated_strict_beacon_ranges
  offline_beacons = updated_offline_beacons
  repeating_beacons = global.repeating_beacons
  update_rate = settings.global["ab-update-rate"].value
  check_global_list()
  
  if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["add_blacklist_name"] then
    remote.call("PickerDollies", "add_blacklist_name", "beacon")
    remote.call("PickerDollies", "add_blacklist_name", "ab-focused-beacon")
    remote.call("PickerDollies", "add_blacklist_name", "ab-node-beacon")
    remote.call("PickerDollies", "add_blacklist_name", "ab-conflux-beacon")
    remote.call("PickerDollies", "add_blacklist_name", "ab-hub-beacon")
    remote.call("PickerDollies", "add_blacklist_name", "ab-isolation-beacon")
  end

  -- beacon manipulation within Pyanodons
  if add_interface then
    remote.add_interface("cryogenic-distillation",
    {am_fm_beacon_settings_changed = function(new_beacon) check_remote(new_beacon, 102, "added") end, -- recheck nearby beacons - this value is specific to the max range of the AM:FM beacon
    am_fm_beacon_destroyed = function(receivers, surface) end}) -- do nothing
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
  for _, surface in pairs(game.surfaces) do
    if surface ~= nil then
      local beacons = surface.find_entities_filtered({type = "beacon"})
      for _, beacon in pairs(beacons) do
        check_self(beacon, -1, nil)
      end
    end
  end
end

-- enables or disables beacons within the exclusion field of an added/removed beacon (entity)
--   disables nearby beacons that would be in the new beacon's exclusion field (use behavior of "added")
--   enables nearby beacons that were in the removed beacon's exclusion exclusion field if no other exclusion field applies (use behavior of anything besides "added")
function check_nearby(entity, behavior)
  local countNearbyHubBeacons = 0
  local nearbyHubBeaconID = -1
  -- checks nearby hub beacons to determine whether behavior should be modified
  if entity.name ~= "ab-hub-beacon" and exclusion_ranges["ab-hub-beacon"] ~= nil then
    local exclusion_range = exclusion_ranges["ab-hub-beacon"]
    local exclusion_area = {
      {entity.selection_box.left_top.x - exclusion_range, entity.selection_box.left_top.y - exclusion_range},
      {entity.selection_box.right_bottom.x + exclusion_range, entity.selection_box.right_bottom.y + exclusion_range}
    }
    local nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon", name = "ab-hub-beacon"})
    for _, beacon in pairs(nearby_beacons) do
      if (beacon.name == "ab-hub-beacon" and beacon.unit_number ~= entity.unit_number) then
        countNearbyHubBeacons = countNearbyHubBeacons + 1
        if countNearbyHubBeacons == 1 then nearbyHubBeaconID = beacon.unit_number end
      end
      -- TODO: Get the maximum exclusion range here (or list of different exclusion ranges to check) since all these beacons are being found here anyway?
      -- TODO: Compile a list of all nearby beacons and how far away they are? Then that list could be used to enable/disable beacons instead of needing to search again
    end
  end
  -- handles special cases within hub areas first
  if countNearbyHubBeacons > 0 then
    for beacon_name, range in pairs(exclusion_ranges) do
      local exclusion_range = 0
      if exclusion_ranges[entity.name] ~= nil then exclusion_range = exclusion_ranges[entity.name] end
      if range ~= nil then exclusion_range = exclusion_range + range end
      local exclusion_area = {
        {entity.selection_box.left_top.x - exclusion_range, entity.selection_box.left_top.y - exclusion_range},
        {entity.selection_box.right_bottom.x + exclusion_range, entity.selection_box.right_bottom.y + exclusion_range}
      }
      local nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon", name = beacon_name})
      for _, beacon in pairs(nearby_beacons) do
        local skip = false
        if (entity.name == "ab-conflux-beacon" and distribution_ranges[beacon_name] >= distribution_ranges[entity.name]) then skip = true end
        if skip == false then -- don't continue for conflux+hub combination
          local wasEnabled = beacon.active
          if behavior == "added" then
            beacon.active = false
            check_self(beacon, -1, wasEnabled)
          elseif (beacon.unit_number ~= entity.unit_number) then
            beacon.active = true
            check_self(beacon, entity.unit_number, wasEnabled)
          end
        end
      end
    end
    -- handle conflux+hub combination here instead -- TODO: is this still necessary?
    if entity.name == "ab-conflux-beacon" then
      for beacon_name, range in pairs(exclusion_ranges) do
        if (distribution_ranges[beacon_name] >= distribution_ranges[entity.name]) then
          exclusion_range = distribution_ranges[entity.name] + distribution_ranges[beacon_name]
          local exclusion_area = {
            {entity.selection_box.left_top.x - exclusion_range, entity.selection_box.left_top.y - exclusion_range},
            {entity.selection_box.right_bottom.x + exclusion_range, entity.selection_box.right_bottom.y + exclusion_range}
          }
          local nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon", name = beacon_name})
          for _, beacon in pairs(nearby_beacons) do
            local wasEnabled = beacon.active
            if behavior == "added" then
              beacon.active = false
              check_self(beacon, -1, wasEnabled)
            elseif (beacon.unit_number ~= entity.unit_number) then
              beacon.active = true
              check_self(beacon, entity.unit_number, wasEnabled)
            end
          end
        end
      end
    end
  else
    -- checks all beacons in the exclusion field of the added/removed beacon
    for beacon_name, range in pairs(exclusion_ranges) do
      local exclusion_range = 0
      local temp = 0
      if strict_beacon_ranges[entity.name] ~= nil then temp = exclusion_ranges[entity.name] + distribution_ranges[beacon_name] end
      if temp > exclusion_range then exclusion_range = temp end
      if strict_beacon_ranges[beacon_name] ~= nil then temp = distribution_ranges[entity.name] + exclusion_ranges[beacon_name] end -- inverted behavior
      if temp > exclusion_range then exclusion_range = temp end
      if entity.name == "ab-conflux-beacon" and distribution_ranges[beacon_name] >= distribution_ranges[entity.name] then temp = distribution_ranges[entity.name] + distribution_ranges[beacon_name] end
      if temp > exclusion_range then exclusion_range = temp end
      if exclusion_range < exclusion_ranges[entity.name] then exclusion_range = exclusion_ranges[entity.name] end
      if exclusion_range < range then exclusion_range = range end
      local exclusion_area = {
        {entity.selection_box.left_top.x - exclusion_range, entity.selection_box.left_top.y - exclusion_range},
        {entity.selection_box.right_bottom.x + exclusion_range, entity.selection_box.right_bottom.y + exclusion_range}
      }
      local nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon", name = beacon_name})
      for _, beacon in pairs(nearby_beacons) do
        local wasEnabled = beacon.active
        if use_repeating_behavior(entity, beacon) == false then
          if behavior == "added" then
            beacon.active = false
            check_self(beacon, -1, wasEnabled)
          elseif (beacon.unit_number ~= entity.unit_number) then
            beacon.active = true
            check_self(beacon, entity.unit_number, wasEnabled)
          end
        end
      end
    end
  end
end

-- enables or disables a beacon (entity) based on exclusion fields and "separation" rules
--   enables a beacon if it isn't within any exclusion fields or only within a single hub beacon's exclusion field and its own distribution/exclusion fields don't overlap with others or the hub beacon itself
--   otherwise disables it (removed_id is the unit_number of the removed beacon, or -1)
function check_self(entity, removed_id, wasEnabled)
  local isEnabled = true
  local countNearbyHubBeacons = 0
  local nearbyHubBeaconID = -1
  local nearbyHubBeaconIDs = {}
  -- checks nearby hub beacons using their exclusion field range (also determines whether behavior should be modified)
  if exclusion_ranges["ab-hub-beacon"] ~= nil then
    local exclusion_range = exclusion_ranges["ab-hub-beacon"]
    local exclusion_area = {
      {entity.selection_box.left_top.x - exclusion_range, entity.selection_box.left_top.y - exclusion_range},
      {entity.selection_box.right_bottom.x + exclusion_range, entity.selection_box.right_bottom.y + exclusion_range}
    }
    local nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon", name = "ab-hub-beacon"})
    for _, beacon in pairs(nearby_beacons) do
      if (beacon.unit_number ~= entity.unit_number and beacon.unit_number ~= removed_id) then
        if entity.name ~= "ab-hub-beacon" then
          countNearbyHubBeacons = countNearbyHubBeacons + 1
          table.insert( nearbyHubBeaconIDs, beacon.unit_number )
        end
        if countNearbyHubBeacons == 1 then nearbyHubBeaconID = beacon.unit_number end
        isEnabled = false
      end
    end
  end
  -- checks nearby beacons for overlapping distribution/exclusion areas (modified behavior for non-hub beacons within a single hub beacon's area)
  if countNearbyHubBeacons > 0 then
    if countNearbyHubBeacons == 1 then isEnabled = true end -- resets the boolean from above if only one hub beacon is nearby
    for beacon_name, range in pairs(exclusion_ranges) do
      local exclusion_range = 0
      if exclusion_ranges[entity.name] ~= nil then exclusion_range = exclusion_ranges[entity.name] end
      if range ~= nil then exclusion_range = exclusion_range + range end
      if (entity.name == "ab-conflux-beacon" and beacon_name == "ab-hub-beacon") then exclusion_range = distribution_ranges[entity.name] + distribution_ranges[beacon_name] end
      exclusion_area = {
        {entity.selection_box.left_top.x - exclusion_range, entity.selection_box.left_top.y - exclusion_range},
        {entity.selection_box.right_bottom.x + exclusion_range, entity.selection_box.right_bottom.y + exclusion_range}
      }
      nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon", name = beacon_name})
      for _, beacon in pairs(nearby_beacons) do
        if (beacon.unit_number ~= entity.unit_number and beacon.unit_number ~= removed_id and beacon.name ~= "ab-hub-beacon") then
          local valid = check_influence(beacon, nearbyHubBeaconIDs)
          if valid == true then isEnabled = false end
          -- TODO: A similar check ought to be performed on hub beacons (even though there's no reason to put one inside another hub beacon's exclusion field)
        elseif (beacon.unit_number ~= entity.unit_number and beacon.unit_number ~= removed_id and beacon.name == "ab-hub-beacon" and entity.name == "ab-conflux-beacon") then
          isEnabled = false
        end
      end
    end
  end
  -- checks each type of beacon against each other type
  for beacon_name, range in pairs(exclusion_ranges) do
    local exclusion_range = 0
    local temp = 0
    if range ~= nil then exclusion_range = range end
    if (entity.name == "ab-conflux-beacon" and distribution_ranges[beacon_name] >= distribution_ranges[entity.name]) then temp = distribution_ranges[entity.name] + distribution_ranges[beacon_name] end
    if temp > exclusion_range then exclusion_range = temp end
    if strict_beacon_ranges[entity.name] ~= nil then temp = exclusion_ranges[entity.name] + distribution_ranges[beacon_name] end
    if temp > exclusion_range then exclusion_range = temp end
    if strict_beacon_ranges[beacon_name] ~= nil then temp = distribution_ranges[entity.name] + exclusion_ranges[beacon_name] end -- inverted behavior
    if temp > exclusion_range then exclusion_range = temp end
    if range > exclusion_range then exclusion_range = range end
    exclusion_area = {
      {entity.selection_box.left_top.x - exclusion_range, entity.selection_box.left_top.y - exclusion_range},
      {entity.selection_box.right_bottom.x + exclusion_range, entity.selection_box.right_bottom.y + exclusion_range}
    }
    nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon", name = beacon_name})
    for _, beacon in pairs(nearby_beacons) do
      if (beacon.unit_number ~= entity.unit_number and beacon.unit_number ~= removed_id and beacon.unit_number ~= nearbyHubBeaconID) then
        if use_repeating_behavior(entity, beacon) == false then isEnabled = false end
      end
    end
  end
  if (isEnabled == false and (entity.name == "ei_copper-beacon" or entity.name == "ei_iron-beacon")) then isEnabled = true end
  if (entity.name == "base-power-crystal-1" or entity.name == "base-power-crystal-2" or entity.name == "base-power-crystal-3" or entity.name == "base-power-crystal-negative-1" or entity.name == "base-power-crystal-negative-2") then isEnabled = true end
  entity.active = isEnabled
  -- beacon deactivated
  if (wasEnabled == true and isEnabled == false) then
    entity.surface.create_entity{
      name = "flying-text",
      position = entity.position,
      text = {"ab-beacon-deactivated"}
    }
    if offline_beacons[entity.unit_number] == nil then
      offline_beacons[entity.unit_number] = {
        rendering.draw_sprite{
          sprite = "ab-beacon-offline",
          target = entity,
          surface = entity.surface
        }
      }
    end
  -- beacon activated
  elseif (wasEnabled == false and isEnabled == true) then
    --entity.surface.create_entity{
    --  name = "flying-text",
    --  position = entity.position,
    --  text = {"ab-beacon-activated"}
    --}
    if offline_beacons[entity.unit_number] ~= nil then
      rendering.destroy(offline_beacons[entity.unit_number][1])
      offline_beacons[entity.unit_number] = nil
    end
  -- adds icons to old deactivated beacons
  elseif (isEnabled == false and offline_beacons[entity.unit_number] == nil) then
    offline_beacons[entity.unit_number] = {
      rendering.draw_sprite{
        sprite = "ab-beacon-offline",
        target = entity,
        surface = entity.surface
      }
    }
  elseif (isEnabled == true and offline_beacons[entity.unit_number] ~= nil) then
    rendering.destroy(offline_beacons[entity.unit_number][1])
    offline_beacons[entity.unit_number] = nil
  end
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
    local nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon", name = "ab-hub-beacon"})
    for _, beacon in pairs(nearby_beacons) do
      for _, hub_number in pairs(hubIDs) do
        if beacon.unit_number == hub_number then isInfluenced = true end
      end
    end
  end
  do return isInfluenced end
end

-- returns true if the the beacons shouldn't disable each other
function use_repeating_behavior(entity1, entity2)
  local result = false
  if entity1.unit_number ~= entity2.unit_number then
    if repeating_beacons[entity1.name] ~= nil then
      -- TODO: Consider changing repeating_beacons table to use objects instead of strings to reduce lookup times for mods with many combinations such as nullius/pyanodons
      for i=1,#repeating_beacons[entity1.name],1 do
        if repeating_beacons[entity1.name][i] == entity2.name then result = true end
      end
    end
  end
  do return result end
end

-- checks all beacons within the specified range of the given beacon
function check_remote(entity, range, behavior)
  -- TODO: Use smaller range for diet beacons
  local exclusion_area = {
    {entity.selection_box.left_top.x - range, entity.selection_box.left_top.y - range},
    {entity.selection_box.right_bottom.x + range, entity.selection_box.right_bottom.y + range}
  }
  local nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon"})
  for _, beacon in pairs(nearby_beacons) do
    local wasEnabled = beacon.active
    if behavior == "added" then
      check_self(beacon, -1, wasEnabled)
    elseif (beacon.unit_number ~= entity.unit_number) then
      check_self(beacon, entity.unit_number, wasEnabled)
    end
  end
end
