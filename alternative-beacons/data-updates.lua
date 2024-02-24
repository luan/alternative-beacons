--data-updates.lua

local overload_beacons = { -- these beacons are given the smallest generic exclusion range which is large enough to prevent them from synergizing with other beacons
  --["example-beacon"] = 0.5,
}
local custom_beacon_exclusion_ranges = { -- these beacons are given custom exclusion ranges - so far, all use the smallest "strict" exclusion range which is large enough to prevent them from synergizing with other beacons
  ["se-compact-beacon"] = 10,
  ["se-compact-beacon-2"] = 10,
  ["se-wide-beacon"] = 22,
  ["se-wide-beacon-2"] = 22,
  ["ei_copper-beacon"] = 16,
  ["ei_iron-beacon"] = 16,
}
local custom_beacon_efficiency = {
  --["example-beacon"] = 0.5,
}
local beacons = { -- list of beacons available without other mods
  "beacon",
  "ab-focused-beacon",
  "ab-node-beacon",
  "ab-conflux-beacon",  
  "ab-hub-beacon",
  "ab-isolation-beacon",
}
local distribution_range_indent = 0.25 -- how close distribution ranges are to the edge of their affected area in tiles (should be between 0 and 0.5; vanilla default is 0.3)

local beacon_standard = require("prototypes/standard-beacon")
local startup = settings.startup
local beacon = table.deepcopy(data.raw.beacon.beacon)

-- override stats of vanilla beacons
if startup["ab-override-vanilla-beacons"].value and not mods["pypostprocessing"] then
  beacon.energy_usage = "480kW"
  beacon.module_specification = {
    module_info_icon_shift = { 0, 0.5 },
    module_info_max_icons_per_row = 2,
    module_info_max_icon_rows = 1,
    module_slots = 2
  }
  beacon.distribution_effectivity = 0.5
  if beacon.collision_box[2][1] + beacon.supply_area_distance ~= 4.25 then
    beacon.selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } }
    beacon.collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } }
    beacon.supply_area_distance = 3.05 -- extends from edge of collision box (9x9) but visualized area is 0.25 tiles shorter in each direction
  end
  data.raw.beacon.beacon = beacon
  if data.raw.item.beacon.stack_size < 20 then data.raw.item.beacon.stack_size = 20 end
  data.raw.recipe.beacon.localised_name = {"recipe-name.override-beacon"}
  data.raw.item.beacon.localised_name = {"item-name.override-beacon"}
  data.raw.beacon.beacon.localised_name = {"entity-name.override-beacon"}
  data.raw.item.beacon.localised_description = {"item-description.override-beacon"}
  data.raw.beacon.beacon.localised_description = {"entity-description.override-beacon"}
  data.raw.technology["effect-transmission"].localised_description = {"technology-description.override-effect-transmission"}
end

-- normalizes the distribution range for the given beacon using the given indent
function normalize_distribution_range(beacon, indent)
  local collision_offset = (beacon.collision_box[2][1] - beacon.collision_box[1][1]) / 2 -- beacon is assumed to be centered on its origin; standard format assumed (leftTop, rightBottom)
  local selection_offset = (beacon.selection_box[2][1] - beacon.selection_box[1][1]) / 2 -- selection box is assumed to be in full tiles
  data.raw.beacon[beacon.name].supply_area_distance = math.min(64, math.ceil(beacon.supply_area_distance - (selection_offset - collision_offset)) - indent + (selection_offset - collision_offset))
end

-- returns the distribution range for the given beacon (from the edge of selection rather than edge of collision)
function get_distribution_range(beacon)
  local collision_offset = (beacon.collision_box[2][1] - beacon.collision_box[1][1]) / 2 -- beacon is assumed to be centered on its origin; standard format assumed (leftTop, rightBottom)
  local selection_offset = (beacon.selection_box[2][1] - beacon.selection_box[1][1]) / 2 -- selection box is assumed to be in full tiles
  local range = beacon.supply_area_distance - (selection_offset - collision_offset)
  do return range end -- note: use ceil() on the returned range to get the total tiles affected
end

if not mods["pypostprocessing"] then
  -- normalize distribution ranges
  for i, beacon in pairs(data.raw.beacon) do
    normalize_distribution_range(beacon, distribution_range_indent)
    -- TODO: Move other general changes here
  end
end

-- add visualization for beacons from other mods which are designed using "beacon overload"
local overloadBeacons = false
local maximum_modular_building_size = 9 -- by default, rocket silo is the largest at 9x9
if mods["exotic-industries"] then maximum_modular_building_size = 11 end
for i=1,#overload_beacons,1 do
  local beacon = data.raw.beacon[overload_beacons[i]]
  if beacon ~= nil then
    overloadBeacons = true
    local scale_dist = (2*beacon.supply_area_distance + 2*beacon.selection_box[2][1] - 2*(beacon.selection_box[2][1] - beacon.collision_box[2][1])) * 2 / 10
    local scale_full = (2*(2*beacon.supply_area_distance + maximum_modular_building_size-1) + 2*beacon.selection_box[2][1] - 2*(beacon.selection_box[2][1] - beacon.collision_box[2][1])) * 2 / 10
    local brv = {
      layers = {
        {filename = "__alternative-beacons__/graphics/visualization/brv-dist.png", size = {10, 10}, scale = scale_dist, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-full.png", size = {10, 10}, scale = scale_full, priority = "extra-high-no-scale"}
      }
    }
    data.raw.beacon[overload_beacons[i]].radius_visualisation_picture = brv
  end
end
-- if any overload-style beacons are used and the vanilla beacon is not overridden, add visualization for the vanilla beacon
if overloadBeacons == true and startup["ab-override-vanilla-beacons"].value == false then
  local beacon = data.raw.beacon.beacon
  local scale_dist = (2*beacon.supply_area_distance + 2*beacon.selection_box[2][1] - 2*(beacon.selection_box[2][1] - beacon.collision_box[2][1])) * 2 / 10
  local scale_full = (2*(2*beacon.supply_area_distance + maximum_modular_building_size-1) + 2*beacon.selection_box[2][1] - 2*(beacon.selection_box[2][1] - beacon.collision_box[2][1])) * 2 / 10
  local brv = {
    layers = {
      {filename = "__alternative-beacons__/graphics/visualization/brv-dist.png", size = {10, 10}, scale = scale_dist, priority = "extra-high-no-scale"},
      {filename = "__alternative-beacons__/graphics/visualization/brv-full.png", size = {10, 10}, scale = scale_full, priority = "extra-high-no-scale"}
    }
  }
  data.raw.beacon.beacon.radius_visualisation_picture = brv
end

-- add visualization for additional beacons from other mods which should use custom exclusion ranges
for beacon_name, range in pairs(custom_beacon_exclusion_ranges) do
  local beacon = data.raw.beacon[beacon_name]
  if beacon ~= nil then

    local scale_dist = (2*beacon.supply_area_distance + 2*beacon.selection_box[2][1] - 2*(beacon.selection_box[2][1] - beacon.collision_box[2][1])) * 2 / 10
    local scale_full = (2*range + 2*beacon.selection_box[2][1] - 2*(beacon.selection_box[2][1] - beacon.collision_box[2][1])) * 2 / 10
    local brv = {
      layers = {
        {filename = "__alternative-beacons__/graphics/visualization/brv-dist.png", size = {10, 10}, scale = scale_dist, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-full.png", size = {10, 10}, scale = scale_full, priority = "extra-high-no-scale"}
      }
    }
    data.raw.beacon[beacon_name].radius_visualisation_picture = brv
  end
end

-- other customizations
for beacon_name, efficiency in pairs(custom_beacon_efficiency) do
  local beacon = data.raw.beacon[beacon_name]
  if beacon ~= nil then
    data.raw.beacon[beacon_name].distribution_effectivity = efficiency
  end
end

if mods["Krastorio2"] then
  if not mods["space-exploration"] then -- singularity beacons are disabled if SE is also active
    data.raw.item["beacon"].localised_description = {"item-description.kr-standard-beacon"}
    data.raw.beacon["beacon"].localised_description = {"entity-description.kr-standard-beacon"}
  end
end

if mods["space-exploration"] then
  for i=1,#beacons,1 do
    if data.raw.beacon[beacons[i]] then data.raw.beacon[beacons[i]].se_allow_in_space = true end
  end
  data.raw.item["se-compact-beacon"].localised_description = {"item-description.compatibility-se-compact-beacon"}
  data.raw.item["se-compact-beacon-2"].localised_description = {"item-description.compatibility-se-compact-beacon-2"}
  data.raw.item["se-wide-beacon"].localised_description = {"item-description.compatibility-se-wide-beacon"}
  data.raw.item["se-wide-beacon-2"].localised_description = {"item-description.compatibility-se-wide-beacon-2"}
  data.raw.beacon["se-compact-beacon"].localised_description = {"entity-description.compatibility-se-compact-beacon"}
  data.raw.beacon["se-compact-beacon-2"].localised_description = {"entity-description.compatibility-se-compact-beacon-2"}
  data.raw.beacon["se-wide-beacon"].localised_description = {"entity-description.compatibility-se-wide-beacon"}
  data.raw.beacon["se-wide-beacon-2"].localised_description = {"entity-description.compatibility-se-wide-beacon-2"}
  data.raw.technology["se-compact-beacon"].localised_description = {"technology-description.compatibility-se-compact-beacon"}
  data.raw.technology["se-compact-beacon-2"].localised_description = {"technology-description.compatibility-se-compact-beacon-2"}
  data.raw.technology["se-wide-beacon"].localised_description = {"technology-description.compatibility-se-wide-beacon"}
  data.raw.technology["se-wide-beacon-2"].localised_description = {"technology-description.compatibility-se-wide-beacon-2"}
  if not startup["ab-override-vanilla-beacons"].value then
    data.raw.item["beacon"].localised_description = {"item-description.se-standard-beacon-overload"}
    data.raw.beacon["beacon"].localised_description = {"entity-description.se-standard-beacon-overload"}
  end
end

if mods["IndustrialRevolution3"] then
  local subgroup = "ir-machines-labs"
  if data.raw.item["beacon"] then subgroup = data.raw.item["beacon"].subgroup end
  for i=1,#beacons,1 do
    if data.raw.item[beacons[i]] then
      data.raw.recipe[beacons[i]].subgroup = subgroup
      data.raw.item[beacons[i]].subgroup = subgroup
      data.raw.recipe[beacons[i]].order = "zz" .. tostring(i)
      data.raw.item[beacons[i]].order = "zz" .. tostring(i)
    end
  end
end

if mods["SeaBlock"] then
  local subgroup = "module-beacon"
  for i=1,#beacons,1 do
    if data.raw.item[beacons[i]] then
      data.raw.recipe[beacons[i]].subgroup = subgroup
      data.raw.item[beacons[i]].subgroup = subgroup
      data.raw.recipe[beacons[i]].order = "a[beacon]-1" .. tostring(i)
      data.raw.item[beacons[i]].order = "a[beacon]-1" .. tostring(i)
    end
  end
end

if mods["nullius"] then
  local category = "large-crafting"
  local subgroup = "beacon"
  for i=2,#beacons,1 do -- standard beacon isn't enabled since small beacon 3 is practically identical
    if data.raw.item[beacons[i]] then
      data.raw.recipe[beacons[i]].category = category
      data.raw.item[beacons[i]].category = category
      data.raw.recipe[beacons[i]].subgroup = subgroup
      data.raw.item[beacons[i]].subgroup = subgroup
      data.raw.recipe[beacons[i]].order = "nullius-cx" .. tostring(i)
      data.raw.item[beacons[i]].order = "nullius-cx" .. tostring(i)
      table.insert( data.raw["technology"]["nullius-broadcasting-3"].effects, { type = "unlock-recipe", recipe = beacons[i] } )
    end
  end
  data.raw.beacon["nullius-beacon-1"].localised_description = {"entity-description.compatibility-nullius-beacon-1"}
  data.raw.beacon["nullius-beacon-1-1"].localised_description = {"entity-description.compatibility-nullius-beacon-1-1"}
  data.raw.beacon["nullius-beacon-1-2"].localised_description = {"entity-description.compatibility-nullius-beacon-1-2"}
  data.raw.beacon["nullius-beacon-1-3"].localised_description = {"entity-description.compatibility-nullius-beacon-1-3"}
  data.raw.beacon["nullius-beacon-1-4"].localised_description = {"entity-description.compatibility-nullius-beacon-1-4"}
  data.raw.beacon["nullius-beacon-2"].localised_description = {"entity-description.compatibility-nullius-beacon-2"}
  data.raw.beacon["nullius-beacon-2-1"].localised_description = {"entity-description.compatibility-nullius-beacon-2-1"}
  data.raw.beacon["nullius-beacon-2-2"].localised_description = {"entity-description.compatibility-nullius-beacon-2-2"}
  data.raw.beacon["nullius-beacon-2-3"].localised_description = {"entity-description.compatibility-nullius-beacon-2-3"}
  data.raw.beacon["nullius-beacon-2-4"].localised_description = {"entity-description.compatibility-nullius-beacon-2-4"}
  data.raw.beacon["nullius-beacon-3"].localised_description = {"entity-description.compatibility-nullius-beacon-3"}
  data.raw.beacon["nullius-beacon-3-1"].localised_description = {"entity-description.compatibility-nullius-beacon-3-1"}
  data.raw.beacon["nullius-beacon-3-2"].localised_description = {"entity-description.compatibility-nullius-beacon-3-2"}
  data.raw.beacon["nullius-beacon-3-3"].localised_description = {"entity-description.compatibility-nullius-beacon-3-3"}
  data.raw.beacon["nullius-beacon-3-4"].localised_description = {"entity-description.compatibility-nullius-beacon-3-4"}
  data.raw.beacon["nullius-large-beacon-1"].localised_description = {"entity-description.compatibility-nullius-large-beacon-1"}
  data.raw.beacon["nullius-large-beacon-2"].localised_description = {"entity-description.compatibility-nullius-large-beacon-2"}
  data.raw.technology["nullius-broadcasting-3"].localised_description = {"technology-description.compatibility-nullius-broadcasting-3"}
end

if mods["exotic-industries"] then
  for i=1,#beacons,1 do
    if data.raw.item[beacons[i]] then
      table.insert( data.raw["technology"]["ei_copper-beacon"].effects, { type = "unlock-recipe", recipe = beacons[i] } )
    end
  end
  data.raw.recipe["ei_copper-beacon"].localised_name = {"recipe-name.compatibility-ei_copper-beacon"}
  data.raw.recipe["ei_iron-beacon"].localised_name = {"recipe-name.compatibility-ei_iron-beacon"}
  data.raw.item["ei_copper-beacon"].localised_name = {"item-name.compatibility-ei_copper-beacon"}
  data.raw.item["ei_iron-beacon"].localised_name = {"item-name.compatibility-ei_iron-beacon"}
  data.raw.beacon["ei_copper-beacon"].localised_name = {"entity-name.compatibility-ei_copper-beacon"}
  data.raw.beacon["ei_iron-beacon"].localised_name = {"entity-name.compatibility-ei_iron-beacon"}
  data.raw.technology["ei_copper-beacon"].localised_name = {"technology-name.compatibility-ei_copper-beacon"}
  data.raw.technology["ei_iron-beacon"].localised_name = {"technology-name.compatibility-ei_iron-beacon"}
  data.raw.item["ei_copper-beacon"].localised_description = {"item-description.compatibility-ei_copper-beacon"}
  data.raw.item["ei_iron-beacon"].localised_description = {"item-description.compatibility-ei_iron-beacon"}
  data.raw.beacon["ei_copper-beacon"].localised_description = {"entity-description.compatibility-ei_copper-beacon"}
  data.raw.beacon["ei_iron-beacon"].localised_description = {"entity-description.compatibility-ei_iron-beacon"}
end

if mods["pypostprocessing"] then
  data.raw.recipe["beacon"].localised_name = {"recipe-name.compatibility-beacon-AM1-FM1"}
  data.raw.item["beacon"].localised_name = {"item-name.compatibility-beacon-AM1-FM1"}
  data.raw.beacon["beacon"].localised_name = {"entity-name.compatibility-beacon-AM1-FM1"}
  data.raw.item["beacon"].localised_description = {"item-description.compatibility-beacon-AM1-FM1"}
  data.raw.beacon["beacon"].localised_description = {"entity-description.compatibility-beacon-AM1-FM1"}
  data.raw.technology["effect-transmission"].localised_description = {"technology-description.py-effect-transmission"}
  --TODO: prevent AM:FM beacons from interacting with others

  -- enables a separate version of "standard" beacons since py replaces it with something complex
  data:extend({
    {
      type = "item",
      name = "ab-standard-beacon",
      place_result = "ab-standard-beacon",
      icon = "__base__/graphics/icons/beacon.png",
      icon_size = 64,
      stack_size = 20,
      subgroup = "module",
      order = "a[beacon]a"
    }
  })
  data:extend({beacon_standard})
  data:extend({
    {
      type = "recipe",
      name = "ab-standard-beacon",
      result = "ab-standard-beacon",
      enabled = false,
      energy_required = 15,
      ingredients = {{type = "item", name = "advanced-circuit", amount = 20}, {type = "item", name = "electronic-circuit", amount = 20}, {type = "item", name = "copper-cable", amount = 10}, {type = "item", name = "steel-plate", amount = 10}},
      normal = { result = "ab-standard-beacon", enabled = false, energy_required = 15, ingredients = {{type = "item", name = "advanced-circuit", amount = 20}, {type = "item", name = "electronic-circuit", amount = 20}, {type = "item", name = "copper-cable", amount = 10}, {type = "item", name = "steel-plate", amount = 10}} },
      expensive = { result = "ab-standard-beacon", enabled = false, energy_required = 15, ingredients = {{type = "item", name = "advanced-circuit", amount = 20}, {type = "item", name = "electronic-circuit", amount = 20}, {type = "item", name = "copper-cable", amount = 10}, {type = "item", name = "steel-plate", amount = 10}} }
    }
  })
  table.insert( data.raw["technology"]["effect-transmission"].effects, { type = "unlock-recipe", recipe = "ab-standard-beacon" } )
end

-- TODO: If fewer than 10 modules, separate beacons & modules onto their own rows
