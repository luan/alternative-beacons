--- data-updates.lua

-- TODO: Move common tables used in both data and control stages into a separate single file
-- TODO: Move new files (globals, adjustments, whatever) into a single extra folder instead of having them spread between scripts/prototypes/whatever?
local adjustments = require("prototypes/adjustments")
local custom_exclusion_ranges = { -- these beacons are given custom exclusion ranges: "strict" ranges disable beacons whose distribution areas overlap them, "solo" means the smallest range for "strict" beacons which is large enough to prevent synergy with other beacons; the same values are also provided in control.lua
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
local distribution_range_indent = 0.25 -- how close distribution ranges are to the edge of their affected area in tiles (should be between 0 and 0.5; vanilla default is 0.3)
local max_moduled_building_size = 9 -- by default, rocket silo (9x9) is the largest building which can use modules

local override_localisation = true
local ordered = false
local beacons = { -- list of beacons available without other mods
  "beacon",
  "ab-focused-beacon",
  "ab-node-beacon",
  "ab-conflux-beacon",
  "ab-hub-beacon",
  "ab-isolation-beacon"
}
override_descriptions = {}
exclusion_range_values = {}
se_technologies = false
ab_technologies = 0

if startup["ab-override-vanilla-beacons"].value and cancel_override then beacons[1] = "ab-standard-beacon" end
if startup["ab-enable-se-beacons"].value and not mods["space-exploration"] then
  table.insert(beacons, "se-basic-beacon")
  table.insert(beacons, "se-compact-beacon")
  table.insert(beacons, "se-wide-beacon")
  table.insert(beacons, "se-compact-beacon-2")
  table.insert(beacons, "se-wide-beacon-2")
end
if data.raw.technology["se-compact-beacon"] and data.raw.technology["se-wide-beacon"] and data.raw.technology["se-compact-beacon-2"] and data.raw.technology["se-wide-beacon-2"] then se_technologies = true end
if data.raw.technology["ab-novel-effect-transmission"] then ab_technologies = 1 end
if data.raw.technology["ab-medium-effect-transmission"] or data.raw.technology["ab-medium-effect-transmission"] then ab_technologies = 2 end
if data.raw.technology["ab-focused-beacon"] or data.raw.technology["ab-node-beacon"] or data.raw.technology["ab-conflux-beacon"] or data.raw.technology["ab-hub-beacon"] or data.raw.technology["ab-isolation-beacon"] then ab_technologies = 3 end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- functions
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- aligns distribution ranges of all beacons using the given indent
function normalize_distribution_ranges(indent)
  for _, beacon in pairs(data.raw.beacon) do
    if (beacon.collision_box ~= nil and beacon.selection_box ~= nil and exclusion_range_values[beacon.name] == nil and not (beacon.minable == nil and beacon.next_upgrade ~= nil)) then -- Note: the minable/next_upgrade case is related to an error with "PowerCrystals" and visual mods like "walkable-beacons" or "classic-beacon" (included so this mod doesn't get implicated as well)
        local collision_radius = (beacon.collision_box[2][1] - beacon.collision_box[1][1]) / 2 -- beacon's collision is assumed to be centered on its origin; standard format assumed (leftTop, rightBottom)
        local selection_radius = (beacon.selection_box[2][1] - beacon.selection_box[1][1]) / 2 -- selection box is assumed to be in full tiles
        local offset = selection_radius - collision_radius
        local new_range = math.min(64, math.ceil(beacon.supply_area_distance - offset) - indent + offset) -- may not be aligned with other beacons if the range is too close to the limit of 64
        if selection_radius < collision_radius then new_range = data.raw.beacon[beacon.name].supply_area_distance end
        data.raw.beacon[beacon.name].supply_area_distance = new_range
    end
  end
end

-- returns the distribution range for the given beacon (from the edge of selection rather than edge of collision)
function get_distribution_range(beacon)
  local range = 0
  if beacon.collision_box ~= nil and beacon.selection_box ~= nil then
    local collision_radius = (beacon.collision_box[2][1] - beacon.collision_box[1][1]) / 2 -- beacon's collision is assumed to be centered on its origin; standard format assumed (leftTop, rightBottom)
    local selection_radius = (beacon.selection_box[2][1] - beacon.selection_box[1][1]) / 2 -- selection box is assumed to be in full tiles
    if selection_radius < collision_radius then range = beacon.supply_area_distance else range = beacon.supply_area_distance - (selection_radius - collision_radius) end
  end
  do return range end -- note: use ceil() on the returned range to get the total tiles affected
end

function override_vanilla_beacon(do_localisation, do_technology)
  local beacon = data.raw.beacon.beacon
  beacon.energy_usage = "480kW"
  beacon.module_specification = {
    module_info_icon_shift = { 0, 0.25 },
    module_info_max_icons_per_row = 2,
    module_info_max_icon_rows = 1,
    module_slots = 2
  }
  beacon.distribution_effectivity = 0.5
  if beacon.collision_box[2][1] + beacon.supply_area_distance ~= 4.25 then
    beacon.selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } }
    beacon.collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } }
    beacon.drawing_box = { {-1.5, -2.2}, {1.5, 1.3} }
    beacon.supply_area_distance = 3.05 -- extends from edge of collision box (9x9) but visualized area is 0.25 tiles shorter in each direction
  end
  data.raw.item.beacon.order = "a[beacon]"
  data.raw.recipe.beacon.order = "a[beacon]"
  if data.raw.item.beacon.stack_size < 20 then data.raw.item.beacon.stack_size = 20 end
  if do_localisation == true then
    localise("beacon", {"item", "beacon", "recipe"}, "name", {"name.ab-standard-beacon"})
    localise("beacon", {"item", "beacon"}, "description", {"description.ab_standard"})
  end
  if do_technology then data.raw.technology["effect-transmission"].localised_description = {"technology-description.effect_transmission_default"} end
end

-- orders beacons and increases stack size to match other mods
function order_beacons(anchor, start_at, order_if_nil, filler)
  if data.raw.recipe.beacon ~= nil and data.raw.item.beacon ~= nil and data.raw.beacon.beacon ~= nil then
    local category_recipe = data.raw.recipe[anchor].category -- "category" is used to specify which machines can craft the item (it may not be necessary here)
    local subgroup_recipe = data.raw.recipe[anchor].subgroup
    local subgroup_item = data.raw.item[anchor].subgroup
    local order_recipe = data.raw.recipe[anchor].order or ""
    local order_item = data.raw.item[anchor].order or ""
    for i=start_at,#beacons,1 do
      if data.raw.item[ beacons[i] ] then
        data.raw.recipe[ beacons[i] ].category = category_recipe
        data.raw.recipe[ beacons[i] ].subgroup = subgroup_recipe
        data.raw.item[ beacons[i] ].subgroup = subgroup_item
        local text = tostring(i)
        if i > 9 then text = "9" .. text end
        if order_recipe == "" then data.raw.recipe[ beacons[i] ].order = order_if_nil .. text else data.raw.recipe[ beacons[i] ].order = order_recipe .. filler .. text end
        if order_item == "" then data.raw.item[ beacons[i] ].order = order_if_nil .. text else data.raw.item[ beacons[i] ].order = order_item .. filler .. text end
        if data.raw.item[ beacons[i] ].stack_size < data.raw.item[anchor].stack_size then data.raw.item[ beacons[i] ].stack_size = data.raw.item[anchor].stack_size end
      end
    end
    ordered = true
  end
end

function add_to_description(group, beacon, localised_string)
	if beacon.localised_description and beacon.localised_description ~= '' then
		beacon.localised_description = {'', beacon.localised_description, '\n', localised_string}
		return
	end
  if group == "item" then
    beacon.localised_description = {'?', {'', {'item-description.' .. beacon.name}, '\n', localised_string} }
  else
    beacon.localised_description = {'?', {'', {'entity-description.' .. beacon.name}, '\n', localised_string} }
  end
end

-- adds additional info to a beacon's description
--  @name: beacon entity's name
--  @pair: {item = beacon item, beacon = beacon entity}
--  @exclusion_range: the beacon's exclusion range
--  @strict: whether or not the beacon's exclusion range is strict
function add_extended_description(name, pair, exclusion_range, strict)
  local beacon = pair.beacon
  local stats_to_use = {
    item = {slots=true, efficiency=true, d_range=true, e_range=true, stack_size=true},
    beacon = {slots=true, d_range=true, e_range=true, dimensions=true},
  }
  local distribution_range = math.ceil(get_distribution_range(beacon))
  if exclusion_range == nil then exclusion_range = distribution_range end
  local stats = {
    slots = {"description.ab_module_slots", tostring(beacon.module_specification.module_slots), tostring(math.floor(100*beacon.distribution_effectivity*beacon.module_specification.module_slots)/100)},
    efficiency = {"description.ab_distribution_efficiency", tostring(beacon.distribution_effectivity)},
    d_range = {"description.ab_distribution_range", tostring(distribution_range)},
    e_range = {"description.ab_exclusion_range", tostring(exclusion_range)},
    dimensions = {"description.ab_dimensions", tostring(math.ceil(beacon.selection_box[2][1] - beacon.selection_box[1][1])), tostring(math.ceil(beacon.selection_box[2][2] - beacon.selection_box[1][2]))}
  }
  if override_descriptions[name] then
    local new_efficiency = beacon.distribution_effectivity
    if override_descriptions[name].efficiency then
      new_efficiency = override_descriptions[name].efficiency
      stats.efficiency = {"description.ab_distribution_efficiency", tostring(new_efficiency)}
    end
    if override_descriptions[name].slots then stats.slots = {"description.ab_module_slots", tostring(override_descriptions[name].slots), tostring(math.floor(100*new_efficiency*override_descriptions[name].slots)/100)} end
    if override_descriptions[name].d_range then stats.d_range = {"description.ab_distribution_range", tostring(override_descriptions[name].d_range)} end
    if override_descriptions[name].dimensions then stats.dimensions = {"description.ab_dimensions", tostring(override_descriptions[name].dimensions[1]), tostring(override_descriptions[name].dimensions[2])} end
  end
  if pair.item ~= nil then stats.stack_size = {"description.ab_stack_size", tostring(pair.item.stack_size)} end
  if strict == true then
    stats.e_range = {'?', {'', {"description.ab_exclusion_range", tostring(exclusion_range)}, ' ', {"description.ab_strict_range_addon"}}}
  end
  if exclusion_range == distribution_range then
    if strict == true then
      stats.d_range = {'?', {'', {"description.ab_distribution_range", tostring(distribution_range)}, ' ', {"description.ab_strict_range_addon"}}}
    end
    stats_to_use.item.e_range = nil
    stats_to_use.beacon.e_range = nil
  end
  if (name == "el_ki_beacon_entity" or name == "fi_ki_beacon_entity" or name == "fu_ki_beacon_entity") then
    stats_to_use.item.slots = nil
    stats_to_use.beacon.slots = nil
  end
  if mods["extended-descriptions"] then
    stats_to_use.item.stack_size = nil
    stats_to_use.beacon.dimensions = nil
  end
  for kind, object in pairs(pair) do
    if data.raw[kind][object.name] then
      for stat, value in pairs(stats_to_use[kind]) do
        if value == true then add_to_description(kind, object, stats[stat]) end
      end
    end
  end
end

function localise(name, groups, field, description)
  for _, group in pairs(groups) do
    data.raw[group][name]["localised_" .. field] = description
  end
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- adjustments for specific mods
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local adjusted = adjustments.adjust(beacons, custom_exclusion_ranges, max_moduled_building_size)
beacons = adjusted.beacons
custom_exclusion_ranges = adjusted.custom_exclusion_ranges
max_moduled_building_size = adjusted.max_moduled_building_size

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- adjustments for all mods
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- TODO: experiment with adjusting draw area to include exclusion areas? (to prevent them from disappearing on the edge of the screen)

-- adds beacon recipe unlocks to technologies that might not have existed in previous data stage
for name, tech in pairs(beacon_techs) do
  if data.raw.beacon[name] and data.raw.technology[tech] then
    local added = false
    for i, effect in pairs(data.raw.technology[tech].effects) do
      if effect.type == "unlock-recipe" and effect.recipe == name then added = true end
    end
    if added == false then table.insert( data.raw.technology[tech].effects, { type = "unlock-recipe", recipe = name } ) end
  end
end

-- adjusts technologies to have higher count & time properties if their prerequisites do
techs = {"ab-novel-effect-transmission", "ab-medium-effect-transmission", "ab-long-effect-transmission", "ab-focused-beacon", "ab-node-beacon", "ab-conflux-beacon", "ab-hub-beacon", "ab-isolation-beacon", "se-compact-beacon", "se-wide-beacon", "se-compact-beacon-2", "se-wide-beacon-2"}
for i, tech_name in pairs(techs) do
  tech = data.raw.technology[tech_name]
  if tech then
    for _, prerequisite in pairs(tech.prerequisites) do
      if data.raw.technology[prerequisite] and prerequisite ~= "space-science-pack" then
        if tech.unit.count < data.raw.technology[prerequisite].unit.count then tech.unit.count = data.raw.technology[prerequisite].unit.count end
        if tech.unit.time < data.raw.technology[prerequisite].unit.time then tech.unit.time = data.raw.technology[prerequisite].unit.time end
      end
      if data.raw.technology[prerequisite] and prerequisite == "effect-transmission" and i < 9 then
        tech.unit.ingredients = data.raw.technology[prerequisite].unit.ingredients
      end
    end
  end
end

-- override stats of vanilla beacons
if startup["ab-override-vanilla-beacons"].value and cancel_override == false then
  if data.raw.recipe.beacon ~= nil and data.raw.item.beacon ~= nil and data.raw.beacon.beacon ~= nil and data.raw.technology["effect-transmission"] ~= nil then
    override_vanilla_beacon(override_localisation, true)
  end
end

normalize_distribution_ranges(distribution_range_indent)

if ordered == false then
  local anchor = "beacon"
  if data.raw.beacon["ab-standard-beacon"] then anchor = "ab-standard-beacon" end
  order_beacons(anchor, 2, "a[beacon]x", "x")
end

-- add visualizations for exclusion ranges
if startup["ab-disable-exclusion-areas"].value == false then
  for name, range in pairs(custom_exclusion_ranges) do
    local beacon = data.raw.beacon[name]
    if beacon ~= nil and beacon.collision_box ~= nil and beacon.selection_box ~= nil then
      local distribution_range = get_distribution_range(beacon)
      local exclusion_range = distribution_range
      if range.value == nil then
        if range.add then exclusion_range = distribution_range + range.add end
      elseif range.value == "solo" then
        if range.mode == nil or range.mode == "basic" then
          exclusion_range = 2*math.ceil(distribution_range) + max_moduled_building_size-1 - distribution_range_indent
        elseif range.mode == "strict" then
          exclusion_range = distribution_range + max_moduled_building_size-1
        end
      else
        exclusion_range = range.value - distribution_range_indent
      end
      exclusion_range_values[name] = math.ceil(exclusion_range)
      if exclusion_range_values[name] ~= math.ceil(distribution_range) then
        local width = beacon.selection_box[2][1] - beacon.selection_box[1][1] -- selection box is assumed to be in full tiles and at least as wide as the collision box; symmetry is assumed
        local scale_distrib = (2*distribution_range + width) * 2 / 10
        local scale_exclude = (2*exclusion_range + width) * 2 / 10
        if beacon.supply_area_distance == 64 then scale_exclude = scale_exclude + 0.2 end -- adjusts the visualization of the exclusion range if the distribution range is high enough to be artificially capped - this value is specific to the AM:FM beacon from Pyanodons but could also be decent for other beacons with the same issue
        local brv = {
          layers = {
            {filename = "__alternative-beacons__/graphics/visualization/brv-dist.png", size = {10, 10}, scale = scale_distrib, priority = "extra-high-no-scale"},
            {filename = "__alternative-beacons__/graphics/visualization/brv-full.png", size = {10, 10}, scale = scale_exclude, priority = "extra-high-no-scale"}
          }
        }
        local image_size = 129
        local base = (2*distribution_range + width) * 2 -- may require the distribution_range_indent to be 0.25
        if base <= image_size and exclusion_range_values[name] > math.ceil(distribution_range) then
          local image_exclusion = "__alternative-beacons__/graphics/visualization/exclude.png"
          if custom_exclusion_ranges[name].mode == "strict" then image_exclusion = "__alternative-beacons__/graphics/visualization/exclude_strict.png" end
          local side = (exclusion_range_values[name] - math.ceil(distribution_range)) * 2
          local scalar = image_size/base
          local offset = ((0.5*base + 0.5*side) / base) * image_size/32
          brv = {
            layers = {
              {filename="__alternative-beacons__/graphics/visualization/distrib.png", priority="extra-high-no-scale", size={base, base}, scale=scalar}, -- middle
              {filename=image_exclusion, priority="extra-high-no-scale", size={side, side}, scale=scalar, shift={-offset, -offset}}, -- top left
              {filename=image_exclusion, priority="extra-high-no-scale", size={base, side}, scale=scalar, shift={0, -offset}},       -- top mid
              {filename=image_exclusion, priority="extra-high-no-scale", size={side, side}, scale=scalar, shift={offset, -offset}},  -- top right
              {filename=image_exclusion, priority="extra-high-no-scale", size={side, base}, scale=scalar, shift={-offset, 0}},       -- mid left
              {filename=image_exclusion, priority="extra-high-no-scale", size={side, base}, scale=scalar, shift={offset, 0}},        -- mid right
              {filename=image_exclusion, priority="extra-high-no-scale", size={side, side}, scale=scalar, shift={-offset, offset}},  -- bottom left
              {filename=image_exclusion, priority="extra-high-no-scale", size={base, side}, scale=scalar, shift={0, offset}},        -- bottom mid
              {filename=image_exclusion, priority="extra-high-no-scale", size={side, side}, scale=scalar, shift={offset, offset}}    -- bottom right
            }
          }
        end
        data.raw.beacon[name].radius_visualisation_picture = brv
      end
    end
  end
end

-- creates a list of all beacon items/entities
local beacon_list = {}
for name, beacon_item in pairs(data.raw.item) do
  local place_result = beacon_item.place_result
  local beacon_entity = data.raw.beacon[place_result]
  if beacon_entity then beacon_list[beacon_entity.name] = {item=beacon_item, beacon=beacon_entity} end
end
for name, beacon_entity in pairs(data.raw.beacon) do
  if beacon_list[beacon_entity.name] == nil then beacon_list[beacon_entity.name] = {beacon=beacon_entity} end
end
if mods["pycoalprocessing"] then
  beacon_list["beacon-AM1-FM1"].item = data.raw.item["beacon"]
  beacon_list["diet-beacon-AM1-FM1"].item = data.raw.item["beacon-mk01"]
end

-- raises stack size to match the maximum among beacons
local max_stack_size = 0
for _, pair in pairs(beacon_list) do
  if pair.item and pair.item.stack_size > max_stack_size then max_stack_size = pair.item.stack_size end
end
for _, pair in pairs(beacon_list) do
  if pair.item and (mods["mini-machines"] or mods["micro-machines"]) then -- mini/micro beacons are given higher default stack sizes
    local name_prefix = string.sub(pair.item.name,1,4)
    if name_prefix == "mini" then
      pair.item.stack_size = 30
    elseif name_prefix == "micr" then
      pair.item.stack_size = 50
    end
  end
  if pair.item and pair.item.stack_size < max_stack_size then pair.item.stack_size = max_stack_size end
end

-- adds extended stats for most beacon items & entities
if startup["ab-show-extended-stats"].value then
  local no_stats = {} -- stats aren't shown for the naturally-generated beacons from the Power Crystals mod or entities which don't act like beacons
  for tier=1,3,1 do
    no_stats["model-power-crystal-productivity-" .. tier] = true
    no_stats["model-power-crystal-effectivity-" .. tier] = true
    no_stats["model-power-crystal-speed-" .. tier] = true
    no_stats["base-power-crystal-" .. tier] = true
    if tier <= 2 then
      no_stats["model-power-crystal-instability-" .. tier] = true
      no_stats["base-power-crystal-negative-" .. tier] = true
    end
  end
  no_stats["el_ki_core_slave_entity"] = true
  no_stats["fi_ki_core_slave_entity"] = true
  no_stats["fu_ki_core_slave_entity"] = true
  no_stats["bt-waste-electricity"] = true
  no_stats["ll-oxygen-diffuser"] = true

  for name, pair in pairs(beacon_list) do
    if data.raw.beacon[name].selection_box then
      local strict = false
      if exclusion_range_values[name] == nil then exclusion_range_values[name] = math.ceil(get_distribution_range(data.raw.beacon[name])) end
      if custom_exclusion_ranges[name] and custom_exclusion_ranges[name].mode ~= nil and custom_exclusion_ranges[name].mode == "strict" then strict = true end
      if no_stats[name] == nil then add_extended_description(name, pair, exclusion_range_values[name], strict) end
    end
  end
end
