--control.lua

-- this file is loaded prior to any scripts/functions and reloaded each time a game is saved/loaded so changes here can be tested without relaunching the game
-- available variables: script, remote, commands

local exclusion_ranges = {}

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
  global = { exclusion_ranges = {} }
  local updated_exclusion_ranges = {
    ["beacon"] = 3,
    ["ab-focused-beacon"] = 3,
    ["ab-node-beacon"] = 7,
    ["ab-hub-beacon"] = 34,
    ["ab-isolation-beacon"] = 68,
  }
  local beacon_prototypes = game.get_filtered_entity_prototypes({{filter = "type", type = "beacon"}})
  for i,v in pairs(beacon_prototypes) do
    if updated_exclusion_ranges[beacon_prototypes[i].name] == nil then
      updated_exclusion_ranges[beacon_prototypes[i].name] = get_distribution_range(beacon_prototypes[i])
    end
  end
  global.exclusion_ranges = updated_exclusion_ranges
  exclusion_ranges = updated_exclusion_ranges
end

-- returns the distribution range for the given beacon (entity)
function get_distribution_range(entity)
  local collison_offset = (entity.collision_box.right_bottom.x - entity.collision_box.left_top.x) / 2
  local selection_offset = (entity.selection_box.right_bottom.x - entity.selection_box.left_top.x) / 2
  local range = entity.supply_area_distance - (selection_offset - collison_offset)
  do return range end
end

script.on_event(
  defines.events.on_built_entity,
  function(event)
    check_nearby(event.created_entity, "added")
  end,
  {{filter = "type", type = "beacon"}}
)

script.on_event(
  defines.events.on_robot_built_entity,
  function(event)
    check_nearby(event.created_entity, "added")
  end,
  {{filter = "type", type = "beacon"}}
)

script.on_event(
  defines.events.on_player_mined_entity,
  function(event)
    check_nearby(event.entity, "removed")
  end,
  {{filter = "type", type = "beacon"}}
)

script.on_event(
  defines.events.on_robot_mined_entity,
  function(event)
    check_nearby(event.entity, "removed")
  end,
  {{filter = "type", type = "beacon"}}
)

script.on_event(
  defines.events.on_entity_died,
  function(event)
    check_nearby(event.entity, "removed")
  end,
  {{filter = "type", type = "beacon"}}
)

script.on_event(
  defines.events.script_raised_built,
  function(event)
    check_nearby(event.entity, "added")
  end,
  {{filter = "type", type = "beacon"}}
)

script.on_event(
  defines.events.script_raised_revive,
  function(event)
    check_nearby(event.entity, "added")
  end,
  {{filter = "type", type = "beacon"}}
)

script.on_event(
  defines.events.script_raised_destroy,
  function(event)
    check_nearby(event.entity, "removed")
  end,
  {{filter = "type", type = "beacon"}}
)

script.on_event(
  defines.events.script_raised_teleported,
  function(event)
    --TODO: Find a reliable way to trigger this event so a check_moved() function can be tested instead of just checking all beacons
    check_global_list()
  end,
  {{filter = "type", type = "beacon"}}
)

script.on_event(
  defines.events.on_tick,
  function(event)
    if (event.tick % 1200 == 0) then check_global_list() end -- verifies proper behavior intermittently in case the above events don't catch everything (1200 = 20 seconds) ...this should become unnecessary eventually
  end
)

-- checks all beacons
function check_global_list()
  for s=0,#game.surfaces,1 do -- assumes "surfaces" table doesn't have gaps
    if game.surfaces[s] ~= nil then
      local beacons = game.surfaces[s].find_entities_filtered({type = "beacon"})
      for i,v in pairs(beacons) do
        check_self(beacons[i], -1)
      end
    end
  end
end

-- enables or disables beacons within the exclusion field of an added/removed beacon (entity)
--   disables nearby beacons that would be in the new beacon's exclusion field (use behavior of "added")
--   enables nearby beacons that were in the removed beacon's exclusion exclusion field if no other exclusion field applies (use behavior of anything besides "added")
function check_nearby(entity, behavior)
  local wasEnabled = entity.active
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
    for i,v in pairs(nearby_beacons) do
      if (nearby_beacons[i].name == "ab-hub-beacon" and nearby_beacons[i].unit_number ~= entity.unit_number) then
        countNearbyHubBeacons = countNearbyHubBeacons + 1
        if countNearbyHubBeacons == 1 then nearbyHubBeaconID = nearby_beacons[i].unit_number end
      end
      -- TODO: Get the maximum exclusion range here (or list of different exclusion ranges to check) since all these beacons are being found here anyway?
      -- TODO: Compile a list of all nearby beacons and how far away they are? Then that list could be used to enable/disable beacons instead of needing to search again
    end
  end
  if countNearbyHubBeacons > 0 then
    for i,v in pairs(exclusion_ranges) do
      local exclusion_range = 0
      if exclusion_ranges[entity.name] ~= nil then exclusion_range = exclusion_ranges[entity.name] end
      if exclusion_ranges[i] ~= nil then exclusion_range = exclusion_range + exclusion_ranges[i] end
      local exclusion_area = {
        {entity.selection_box.left_top.x - exclusion_range, entity.selection_box.left_top.y - exclusion_range},
        {entity.selection_box.right_bottom.x + exclusion_range, entity.selection_box.right_bottom.y + exclusion_range}
      }
      local nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon", name = i})
      for ii,vv in pairs(nearby_beacons) do
        local wasEnabled = nearby_beacons[ii].active
        if behavior == "added" then
          nearby_beacons[ii].active = false
          check_self(nearby_beacons[ii], -1, wasEnabled)
        elseif (nearby_beacons[ii].unit_number ~= entity.unit_number) then
          nearby_beacons[ii].active = true
          check_self(nearby_beacons[ii], entity.unit_number, wasEnabled)
        end
      end
    end
  else
    local exclusion_range = 0
    if exclusion_ranges[entity.name] ~= nil then exclusion_range = exclusion_ranges[entity.name] end
    -- checks all beacons in the exclusion field of the added/removed beacon
    if exclusion_range > 0 then
      local exclusion_area = {
        {entity.selection_box.left_top.x - exclusion_range, entity.selection_box.left_top.y - exclusion_range},
        {entity.selection_box.right_bottom.x + exclusion_range, entity.selection_box.right_bottom.y + exclusion_range}
      }
      local nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon"})
      -- standard beacons' exclusion fields don't normally apply to other standard beacons
      if (entity.name == "beacon" and countNearbyHubBeacons ~= 1) then
        for i,v in pairs(nearby_beacons) do
          local wasEnabled = nearby_beacons[i].active
          if behavior == "added" then
            if nearby_beacons[i].name ~= "beacon" then nearby_beacons[i].active = false end
            check_self(nearby_beacons[i], -1, wasEnabled)
          elseif (nearby_beacons[i].unit_number ~= entity.unit_number) then
            if nearby_beacons[i].name ~= "beacon" then nearby_beacons[i].active = true end
            check_self(nearby_beacons[i], entity.unit_number, wasEnabled)
          end
        end
      -- other beacons
      else
        for i,v in pairs(nearby_beacons) do
          local wasEnabled = nearby_beacons[i].active
          if behavior == "added" then
            nearby_beacons[i].active = false
            check_self(nearby_beacons[i], -1, wasEnabled)
          elseif (nearby_beacons[i].unit_number ~= entity.unit_number) then
            nearby_beacons[i].active = true
            check_self(nearby_beacons[i], entity.unit_number, wasEnabled)
          end
        end
      end
    else -- never reached except for beacons from other mods
      if behavior == "added" then check_self(entity, -1, false)
      else check_self(entity, entity.unit_number, false)
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
  for i,v in pairs(nearby_beacons) do
    if (nearby_beacons[i].unit_number ~= entity.unit_number and nearby_beacons[i].unit_number ~= removed_id) then
      if entity.name ~= "ab-hub-beacon" then
        countNearbyHubBeacons = countNearbyHubBeacons + 1
        table.insert( nearbyHubBeaconIDs, nearby_beacons[i].unit_number )
      end
      if countNearbyHubBeacons == 1 then nearbyHubBeaconID = nearby_beacons[i].unit_number end
      isEnabled = false
    end
  end
  -- checks nearby beacons for overlapping distribution/exclusion areas (modified behavior for non-hub beacons within a single hub beacon's area)
  if countNearbyHubBeacons > 0 then
    if countNearbyHubBeacons == 1 then isEnabled = true end -- resets the boolean from above if only one hub beacon is nearby
    for i,v in pairs(exclusion_ranges) do
      local exclusion_range = 0 
      if exclusion_ranges[entity.name] ~= nil then exclusion_range = exclusion_ranges[entity.name] end
      if exclusion_ranges[i] ~= nil then exclusion_range = exclusion_range + exclusion_ranges[i] end
      exclusion_area = {
        {entity.selection_box.left_top.x - exclusion_range, entity.selection_box.left_top.y - exclusion_range},
        {entity.selection_box.right_bottom.x + exclusion_range, entity.selection_box.right_bottom.y + exclusion_range}
      }
      nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon", name = i})
      for ii,vv in pairs(nearby_beacons) do
        if (nearby_beacons[ii].unit_number ~= entity.unit_number and nearby_beacons[ii].unit_number ~= removed_id and nearby_beacons[ii].name ~= "ab-hub-beacon") then
            local valid = check_influence(nearby_beacons[ii], nearbyHubBeaconIDs)
            if valid == true then isEnabled = false end
            -- TODO: A similar check ought to be performed on hub beacons (even though there's no reason to put one inside another hub beacon's exclusion field)
        end
      end
    end
  end
  -- checks nearby beacons using their exclusion field range
  for i,v in pairs(exclusion_ranges) do
    if i ~= "beacon" or entity.name ~= "beacon" then -- skips standard beacons if the current beacon is also a standard beacon (they don't disable each other)
      local exclusion_range = 0
      if exclusion_ranges[i] ~= nil then exclusion_range = exclusion_ranges[i] end
      exclusion_area = {
        {entity.selection_box.left_top.x - exclusion_range, entity.selection_box.left_top.y - exclusion_range},
        {entity.selection_box.right_bottom.x + exclusion_range, entity.selection_box.right_bottom.y + exclusion_range}
      }
      nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon", name = i})
      for ii,vv in pairs(nearby_beacons) do
        if (nearby_beacons[ii].unit_number ~= entity.unit_number and nearby_beacons[ii].unit_number ~= removed_id and nearby_beacons[ii].unit_number ~= nearbyHubBeaconID) then
          isEnabled = false
        end
      end
    end
  end
  entity.active = isEnabled
  if (wasEnabled == true and isEnabled == false) then
    entity.surface.create_entity{
      name = "flying-text",
      position = entity.position,
      text = {"ab-beacon-deactivated"}
    }
  elseif (wasEnabled == false and isEnabled == true) then
    entity.surface.create_entity{
      name = "flying-text",
      position = entity.position,
      text = {"ab-beacon-activated"}
    }
  end
end

-- returns true if the given beacon (entity) is within the exclusion field of a specific hub (hubID) and not within range of any other hubs
--   used to determine if the beacon's overlapping area should apply to another beacon near the specific hub (it only applies for beacons within the same hub's exclusion area)
function check_influence(entity, hubIDs)
  local isInfluenced = false
  local exclusion_range = exclusion_ranges["ab-hub-beacon"]
  local exclusion_area = {
    {entity.selection_box.left_top.x - exclusion_range, entity.selection_box.left_top.y - exclusion_range},
    {entity.selection_box.right_bottom.x + exclusion_range, entity.selection_box.right_bottom.y + exclusion_range}
  }
  local nearby_beacons = entity.surface.find_entities_filtered({area = exclusion_area, type = "beacon", name = "ab-hub-beacon"})
  for i,v in pairs(nearby_beacons) do
    for ii,vv in pairs(hubIDs) do
      if nearby_beacons[i].unit_number == vv then isInfluenced = true end
    end
  end
  do return isInfluenced end
end
