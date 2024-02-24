--control.lua

-- this file is loaded prior to any scripts/functions and reloaded each time a game is saved/loaded so changes here can be tested without relaunching the game
-- available variables: script, remote, commands

local exclusion_ranges = {}
local distribution_ranges = {}
local strict_beacon_ranges = {}
local offline_beacons = {}
local repeating_beacons = {}
local standard_repeating = true
local update_rate = -1

-- Mod initialization (called on first startup after the mod is installed)
--   available variables: global, game, rendering
script.on_init(
  function()
    populate_beacon_data()
  end
)

-- Migrations are handled between on_init() and on_load()

-- Mod Load (called on subsequent startups)
script.on_load(
  function()
    -- global is a global table that preserves data between saves which can store: nil, strings, numbers, booleans, tables, references to Factorio's LuaObjects
    -- can read from global in on_load(), but not write to it
    exclusion_ranges = global.exclusion_ranges
    distribution_ranges = global.distribution_ranges
    strict_beacon_ranges = global.strict_beacon_ranges
    offline_beacons = global.offline_beacons
    repeating_beacons = global.repeating_beacons
    standard_repeating = global.standard_repeating
    update_rate = settings.global["ab-update-rate"].value
  end
)

-- Mod Configuration (called next if the game version or any mod version has changed, any mod was added or removed, a startup setting was changed, any prototypes were added or removed, or if a migration was applied)
script.on_configuration_changed(
  function()
    populate_beacon_data()
  end
)

-- creates and updates exclusion ranges for all beacons - beacons from other mods will use their distribution range as their exclusion range
function populate_beacon_data()
  global = { exclusion_ranges = {}, distribution_ranges = {}, strict_beacon_ranges = {}, offline_beacons = {},  repeating_beacons = {}, standard_repeating = true }
  local updated_distribution_ranges = {}
  local updated_offline_beacons = {}
  local updated_exclusion_ranges = {
    ["ab-focused-beacon"] = 3,
    ["ab-node-beacon"] = 8,
    ["ab-conflux-beacon"] = 12,
    ["ab-hub-beacon"] = 34,
    ["ab-isolation-beacon"] = 68,
  }
  local overload_beacon_ranges = {
    -- this category no longer used
    -- Space Exploration support requires the beacon overload mechanic to be disabled but is otherwise functional (i.e. comment out the Beacon = require('scripts/beacon') line within control.lua)
  }
  local updated_strict_beacon_ranges = {
    ["se-compact-beacon"] = 10,
    ["se-compact-beacon-2"] = 10,
    ["se-wide-beacon"] = 22,
    ["se-wide-beacon-2"] = 22,
    ["ei_copper-beacon"] = 16,
    ["ei_iron-beacon"] = 16,
  }
  local updated_repeating_beacons = {
    ["beacon"] = {"beacon", "ab-standard-beacon", "kr-singularity-beacon", "beacon-2", "beacon-3", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4"},
    ["ab-standard-beacon"] = {"beacon", "ab-standard-beacon", "kr-singularity-beacon", "beacon-2", "beacon-3", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4"},
    ["kr-singularity-beacon"] = {"kr-singularity-beacon"},
    ["ei_copper-beacon"] = {"ei_copper-beacon","ei_iron-beacon"},
    ["ei_iron-beacon"] = {"ei_copper-beacon","ei_iron-beacon"},
    ["beacon-2"] = {"beacon"},
    ["beacon-3"] = {"beacon"},
    ["nullius-beacon-1"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-beacon-1-1"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-beacon-1-2"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-beacon-1-3"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-beacon-1-4"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-beacon-2"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-beacon-2-1"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-beacon-2-2"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-beacon-2-3"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-beacon-2-4"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-beacon-3"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-beacon-3-1"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-beacon-3-2"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-beacon-3-3"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-beacon-3-4"] = {"beacon", "nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4", "nullius-large-beacon-1", "nullius-large-beacon-2"},
    ["nullius-large-beacon-1"] = {"nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4"},
    ["nullius-large-beacon-2"] = {"nullius-beacon-1", "nullius-beacon-1-1", "nullius-beacon-1-2", "nullius-beacon-1-3", "nullius-beacon-1-4", "nullius-beacon-2", "nullius-beacon-2-1", "nullius-beacon-2-2", "nullius-beacon-2-3", "nullius-beacon-2-4", "nullius-beacon-3", "nullius-beacon-3-1", "nullius-beacon-3-2", "nullius-beacon-3-3", "nullius-beacon-3-4"},
    --["beacon-AM1-FM1"] = {"beacon-AM1-FM1", "beacon-AM2-FM1", "beacon-AM3-FM1", "beacon-AM4-FM1", "beacon-AM5-FM1", "beacon-AM1-FM2", "beacon-AM2-FM2", "beacon-AM3-FM2", "beacon-AM4-FM2", "beacon-AM5-FM2", "beacon-AM1-FM3", "beacon-AM2-FM3", "beacon-AM3-FM3", "beacon-AM4-FM3", "beacon-AM5-FM3", "beacon-AM1-FM4", "beacon-AM2-FM4", "beacon-AM3-FM4", "beacon-AM4-FM4", "beacon-AM5-FM4", "beacon-AM1-FM5", "beacon-AM2-FM5", "beacon-AM3-FM5", "beacon-AM4-FM5", "beacon-AM5-FM5", "diet-beacon-AM1-FM1"}, -- wow this is going to take a lot of space
  }

  -- set distribution/exclusion ranges
  -- TODO: Change exclusion range to be based on how much is added from distribution range? if other mods change the distribution range, everything would be messed up but it might be less broken if the exclusion ranges are based on the changed values instead of hardcoded
  local overloadBeacons = false
  local beacon_prototypes = game.get_filtered_entity_prototypes({{filter = "type", type = "beacon"}})
  for _, beacon in pairs(beacon_prototypes) do
    updated_distribution_ranges[beacon.name] = get_distribution_range(beacon)
    if updated_exclusion_ranges[beacon.name] == nil then
      updated_exclusion_ranges[beacon.name] = updated_distribution_ranges[beacon.name]
    end
    for beacon_name, range in pairs(overload_beacon_ranges) do
      if beacon.name == beacon_name then
        overloadBeacons = true
        updated_exclusion_ranges[beacon.name] = range
      end
    end
    for beacon_name, range in pairs(updated_strict_beacon_ranges) do
      if beacon.name == beacon_name then
        updated_exclusion_ranges[beacon.name] = range
        if beacon_name == "se-wide-beacon" then overloadBeacons = true end
      end
    end
  end
  if (overloadBeacons == true and settings.startup["ab-override-vanilla-beacons"].value == false) then
    updated_exclusion_ranges["beacon"] = overload_beacon_ranges["se-basic-beacon"]
    global.standard_repeating = false
  end
  -- setup relationship table of beacons which should be able to repeat without extra interference (they won't disable each other)
  for _, beacon in pairs(beacon_prototypes) do
    if updated_repeating_beacons[beacon.name] ~= nil then
      local skip = false
      if beacon.name == "beacon" and global.standard_repeating == false then skip = true end
      if skip == false then
        local affected_beacons = {}
        for i=1,#updated_repeating_beacons[beacon.name],1 do
          local is_valid = false
          for _, beacon_to_compare in pairs(beacon_prototypes) do
            if beacon_to_compare.name == updated_repeating_beacons[beacon.name][i] then
              is_valid = true
              if beacon_to_compare.name == "beacon" and global.standard_repeating == false then is_valid = false end
            end
          end
          if is_valid == true then
            table.insert(affected_beacons, updated_repeating_beacons[beacon.name][i])
          end
        end
        table.insert(global.repeating_beacons, beacon.name)
        global.repeating_beacons[beacon.name] = affected_beacons
      end
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
  standard_repeating = global.standard_repeating
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
end

-- returns the distribution range for the given beacon (entity)
function get_distribution_range(entity)
  local collison_offset = (entity.collision_box.right_bottom.x - entity.collision_box.left_top.x) / 2
  local selection_offset = (entity.selection_box.right_bottom.x - entity.selection_box.left_top.x) / 2
  local range = entity.supply_area_distance - (selection_offset - collison_offset)
  do return range end
end

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
    if (update_rate >= 0) then
      if event.tick % 60 == 0 then
        if event.tick % (60 * update_rate) == 0 then check_global_list() end -- verifies proper behavior intermittently in case the above events don't catch everything
      end
    end
  end
)

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


-- TODO: Fix isolation beacon interaction with large nullius beacons

-- enables or disables beacons within the exclusion field of an added/removed beacon (entity)
--   disables nearby beacons that would be in the new beacon's exclusion field (use behavior of "added")
--   enables nearby beacons that were in the removed beacon's exclusion exclusion field if no other exclusion field applies (use behavior of anything besides "added")
function check_nearby(entity, behavior)
  local countNearbyHubBeacons = 0
  local nearbyHubBeaconID = -1
  -- checks nearby hub beacons to determine whether behavior should be modified
  if entity.name ~= "ab-hub-beacon" then
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
        if (entity.name == "ab-conflux-beacon" and beacon.name == "ab-hub-beacon") then skip = true end
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
    -- handle conflux+hub combination here instead
    if entity.name == "ab-conflux-beacon" then
      exclusion_range = distribution_ranges[entity.name] + distribution_ranges["ab-hub-beacon"]
      local exclusion_area = {
        {entity.selection_box.left_top.x - exclusion_range, entity.selection_box.left_top.y - exclusion_range},
        {entity.selection_box.right_bottom.x + exclusion_range, entity.selection_box.right_bottom.y + exclusion_range}
      }
      local nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon", name = "ab-hub-beacon"})
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
  else
    -- checks all beacons in the exclusion field of the added/removed beacon
    for beacon_name, range in pairs(exclusion_ranges) do
      local exclusion_range = 0
      local temp = 0
      if strict_beacon_ranges[entity.name] ~= nil then temp = exclusion_ranges[entity.name] + distribution_ranges[beacon_name] end
      if temp > exclusion_range then exclusion_range = temp end
      if strict_beacon_ranges[beacon_name] ~= nil then temp = distribution_ranges[entity.name] + exclusion_ranges[beacon_name] end
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
    if range ~= nil then exclusion_range = range end
    if (entity.name == "ab-conflux-beacon" and beacon_name == "ab-conflux-beacon") then exclusion_range = distribution_ranges[entity.name] + distribution_ranges[beacon_name] end
    if strict_beacon_ranges[beacon_name] ~= nil then exclusion_range = distribution_ranges[entity.name] + exclusion_ranges[beacon_name] end
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
  do return isInfluenced end
end

-- returns true if the the beacons shouldn't disable each other
function use_repeating_behavior(entity1, entity2)
  local result = false
  if entity1.unit_number ~= entity2.unit_number then
    if repeating_beacons[entity1.name] ~= nil then
      for i=1,#repeating_beacons[entity1.name],1 do
        if repeating_beacons[entity1.name][i] == entity2.name then result = true end
      end
    end
  end
  do return result end
end