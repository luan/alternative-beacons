--- data-updates.lua

local custom_exclusion_ranges = { -- these beacons are given custom exclusion ranges: "strict" ranges disable beacons whose distribution areas overlap them, "solo" means the smallest range which is large enough to prevent synergy with other beacons; the same values are also provided in control.lua
  ["ab-focused-beacon"] = {value=3},
  ["ab-conflux-beacon"] = {value=12},
  ["ab-hub-beacon"] = {value=34},
  ["ab-isolation-beacon"] = {value=38, mode="strict"},
  ["se-basic-beacon"] = {value = "solo", mode = "strict"},
  ["se-compact-beacon"] = {value = "solo", mode = "strict"},
  ["se-compact-beacon-2"] = {value = "solo", mode = "strict"},
  ["se-wide-beacon"] = {value = "solo", mode = "strict"},
  ["se-wide-beacon-2"] = {value = "solo", mode = "strict"},
  ["ei_copper-beacon"] = {value = "solo", mode = "strict"},
  ["ei_iron-beacon"] = {value = "solo", mode = "strict"},
  ["el_ki_beacon_entity"] = {value = "solo", mode = "strict"},
  ["fi_ki_beacon_entity"] = {value = "solo", mode = "strict"},
  ["fu_ki_beacon_entity"] = {value = "solo", mode = "strict"},
  ["productivity-beacon"] = {value = 6},
  ["productivity-beacon-1"] = {value = 5},
  ["productivity-beacon-2"] = {value = 6},
  ["productivity-beacon-3"] = {value = 7},
  ["speed-beacon-2"] = {value = 8},
  ["speed-beacon-3"] = {value = 11},
  ["beacon-3"] = {value = 11},
  ["beacon3"] = {value = 8},
  -- pyanodons AM-FM entries are added below
}
local distribution_range_indent = 0.25 -- how close distribution ranges are to the edge of their affected area in tiles (should be between 0 and 0.5; vanilla default is 0.3)
local max_moduled_building_size = 9 -- by default, rocket silo (9x9) is the largest building which can use modules

local cancel_override = false
local override_localisation = true
local ordered = false
local beacons = { -- list of beacons available without other mods
  "beacon",
  "ab-focused-beacon",
  "ab-node-beacon",
  "ab-conflux-beacon",  
  "ab-hub-beacon",
  "ab-isolation-beacon",
}
local exclusion_range_values = {}

local beacon_standard = require("prototypes/standard-beacon")
local startup = settings.startup

if startup["ab-enable-se-beacons"].value then
  table.insert(beacons, "se-basic-beacon")
  table.insert(beacons, "se-compact-beacon")
  table.insert(beacons, "se-wide-beacon")
  table.insert(beacons, "se-compact-beacon-2")
  table.insert(beacons, "se-wide-beacon-2")
end

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

-- enables a separate version of "standard" beacons - used in cases where the original changed version should be preserved ahead of the vanilla version due to complexity or importance
function enable_replacement_standard_beacon(technology_name, order_string)
  data:extend({
    {
      type = "item",
      name = "ab-standard-beacon",
      place_result = "ab-standard-beacon",
      icon = "__base__/graphics/icons/beacon.png",
      icon_size = 64,
      stack_size = 20,
      subgroup = "module",
      order = order_string
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
  table.insert( data.raw["technology"][technology_name].effects, { type = "unlock-recipe", recipe = "ab-standard-beacon" } )
  localise_new_beacon("ab-standard-beacon", "ab_other", nil)
  if mods["space-exploration"] then data.raw.beacon["ab-standard-beacon"].se_allow_in_space = true end
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
    beacon.supply_area_distance = 3.05 -- extends from edge of collision box (9x9) but visualized area is 0.25 tiles shorter in each direction
  end
  data.raw.item.beacon.order = "a[beacon]"
  data.raw.recipe.beacon.order = "a[beacon]"
  if data.raw.item.beacon.stack_size < 20 then data.raw.item.beacon.stack_size = 20 end
  if do_localisation == true then
    localise("beacon", {"item", "beacon", "recipe"}, "name", {"name.ab-standard-beacon"})
    localise("beacon", {"item", "beacon"}, "description", {"description.ab_other"})
  end
  if do_technology then data.raw.technology["effect-transmission"].localised_description = {"technology-description.effect_transmission_default"} end
end

function scale(object, scale)
  local function scale_subtable(object, scale)
      for key, value in pairs(object) do
          if type(value) == "table" then
              scale_subtable(value, scale)
          elseif type(value) == "number" then
              object[key] = value*scale
          end
      end
  end
  if type(object) == "number" then
      return object*scale
  elseif type(object) == "table" then
      object = table.deepcopy(object)
      scale_subtable(object, scale)
      return object
  end
end

function rescale_entity(entity, scalar)
  local fields = {"shift", "scale", "collision_box", "selection_box", "drawing_box", "mining_time"}
	for key, value in pairs(entity) do
		if key == "hr_version" then
			entity.scale = entity.scale or 0.5
		elseif entity.filename then
			entity.scale = entity.scale or 1
		end
    for n = 1, #fields do
      if fields[n] == key then entity[key] = scale(value, scalar) end
    end
    if type(value) == "table" then rescale_entity(value, scalar) end
  end
  if scalar < 1 and entity.collision_box then -- ensures a minimum walkable area on all sides of the entity; this fixes distribution areas for resized beacons
    local min = 0.3
    if entity.collision_box[1][1] - min < entity.selection_box[1][1] then entity.collision_box[1][1] = entity.selection_box[1][1] + min end
    if entity.collision_box[1][2] - min < entity.selection_box[1][2] then entity.collision_box[1][2] = entity.selection_box[1][2] + min end
    if entity.collision_box[2][1] + min > entity.selection_box[2][1] then entity.collision_box[2][1] = entity.selection_box[2][1] - min end
    if entity.collision_box[2][2] + min > entity.selection_box[2][2] then entity.collision_box[2][2] = entity.selection_box[2][2] - min end
  end
end

-- creates a new beacon with the given criteria
function generate_new_beacon(base_name, name, localised_name, localised_description, size, range, modules, efficiency, power, effects)
  local new_beacon = table.deepcopy(data.raw.beacon[base_name])
  local new_beacon_item = table.deepcopy(data.raw.item[base_name])
  local new_beacon_recipe = table.deepcopy(data.raw.recipe[base_name])
  new_beacon.name = name
  new_beacon.minable.result = name
  new_beacon_item.name = name
  new_beacon_item.place_result = name
  new_beacon_recipe.name = name
  new_beacon_recipe.result = name
  if new_beacon_recipe.normal then new_beacon_recipe.normal.result = name end
  if new_beacon_recipe.expensive then new_beacon_recipe.expensive.result = name end
  new_beacon.next_upgrade = nil
  local original_size = new_beacon.selection_box[2][1] - new_beacon.selection_box[1][1] -- selection box assumed to be in full tiles
  size = math.ceil(size)
  if size ~= original_size then rescale_entity(new_beacon, size/original_size) end
  local style = string.sub(name,1,4)
  local icon_indicator = nil
  if style == "mini" then
    icon_indicator = "__mini-machines__/graphics/shrink.png"
    if new_beacon_item.stack_size < 30 then new_beacon_item.stack_size = 30 end
  elseif style == "micr" then
    icon_indicator = "__micro-machines__/graphics/shrink3.png"
    new_beacon_item.order = new_beacon_item.order .. "b-micro"
    new_beacon_recipe.order = new_beacon_item.order
    if new_beacon_item.stack_size < 50 then new_beacon_item.stack_size = 50 end
  end
  if icon_indicator ~= nil then
    new_beacon_recipe.base_machine = base_name -- causes technologies to be handled by mini/micro mods
    if new_beacon_item.icons then
      table.insert(new_beacon_item.icons, {icon=icon_indicator, icon_size=64})
      table.insert(new_beacon_recipe.icons, {icon=icon_indicator, icon_size=64})
    elseif new_beacon_item.icon then  
      new_beacon_item.icons = {{icon=new_beacon_item.icon, icon_size=new_beacon_item.icon_size, icon_mipmaps=new_beacon_item.icon_mipmaps}, {icon=icon_indicator, icon_size=64}}
      new_beacon_recipe.icons = new_beacon_item.icons
    end
  end
  local brv = { layers = {{filename = "__alternative-beacons__/graphics/visualization/brv-dist.png", size = {10, 10}, scale = 1, priority = "extra-high-no-scale"}} }
  new_beacon.radius_visualisation_picture = brv
  if range ~= nil then new_beacon.supply_area_distance = range end
  if modules ~= nil then new_beacon.module_specification.module_slots = modules end
  if efficiency ~= nil then new_beacon.distribution_effectivity = efficiency end
  if effects ~= nil then new_beacon.allowed_effects = effects end
  if power ~= nil then new_beacon.energy_usage = power end
  data:extend({new_beacon_item})
  data:extend({new_beacon})
  data:extend({new_beacon_recipe})
  localise(name, {"item", "beacon"}, "name", localised_name)
  localise(name, {"item", "beacon"}, "description", localised_description)
  if icon_indicator == nil then table.insert( data.raw["technology"]["effect-transmission"].effects, { type = "unlock-recipe", recipe = name } ) end
end

-- orders beacons and increases stack size to match other mods
function order_beacons(anchor, start_at, order_if_nil, filler)
  if data.raw.recipe.beacon ~= nil and data.raw.item.beacon ~= nil and data.raw.beacon.beacon ~= nil then
    local category_recipe = data.raw.recipe[anchor].category -- TODO: Is it necessary to copy category info?
    local group_recipe = data.raw.recipe[anchor].group
    local subgroup_recipe = data.raw.recipe[anchor].subgroup
    local order_recipe = data.raw.recipe[anchor].order or ""
    local category_item = data.raw.item[anchor].category
    local group_item = data.raw.item[anchor].group
    local subgroup_item = data.raw.item[anchor].subgroup
    local order_item = data.raw.item[anchor].order or ""
    for i=start_at,#beacons,1 do
      if data.raw.item[beacons[i]] then
        data.raw.recipe[beacons[i]].category = category_recipe
        data.raw.item[beacons[i]].category = category_item
        data.raw.recipe[beacons[i]].group = group_recipe
        data.raw.item[beacons[i]].group = group_item
        data.raw.recipe[beacons[i]].subgroup = subgroup_recipe
        data.raw.item[beacons[i]].subgroup = subgroup_item
        local text = tostring(i)
        if i > 9 then text = "9" .. text end
        if order_recipe == "" then data.raw.recipe[beacons[i]].order = order_if_nil .. text else data.raw.recipe[beacons[i]].order = order_recipe .. filler .. text end
        if order_item == "" then data.raw.item[beacons[i]].order = order_if_nil .. text else data.raw.item[beacons[i]].order = order_item .. filler .. text end
        if data.raw.item[beacons[i]].stack_size < data.raw.item[anchor].stack_size then data.raw.item[beacons[i]].stack_size = data.raw.item[anchor].stack_size end
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
  if group == item then
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


if mods["Krastorio2"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  if not mods["space-exploration"] then -- singularity beacons are disabled if SE is also active
    for i=1,#beacons,1 do
      if data.raw.beacon[beacons[i]] then
        if data.raw.item[beacons[i]].stack_size < data.raw.item["kr-singularity-beacon"].stack_size then data.raw.item[beacons[i]].stack_size = data.raw.item["kr-singularity-beacon"].stack_size end
      end
    end
    localise("kr-singularity-beacon", {"item", "beacon"}, "description", {"description.kr_singularity"})
    localise("beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_standard_kr_addon"}} })
    override_localisation = false
    if data.raw.technology["se-compact-beacon-2"] and data.raw.technology["se-wide-beacon-2"] then
      data.raw.technology["se-compact-beacon-2"].prerequisites = {"se-compact-beacon", "kr-singularity-tech-card"}
      data.raw.technology["se-compact-beacon-2"].unit = {count=1000, time=60, ingredients={{name="production-science-pack", amount=1}, {name="utility-science-pack", amount=1}, {name="space-science-pack", amount=1}, {name="matter-tech-card", amount=1}, {name="advanced-tech-card", amount=1}, {name="singularity-tech-card", amount=1}}}
      data.raw.technology["se-wide-beacon-2"].prerequisites = {"se-wide-beacon", "kr-singularity-tech-card"}
      data.raw.technology["se-wide-beacon-2"].unit = data.raw.technology["se-compact-beacon-2"].unit
    end
  end
end

if mods["space-exploration"] then -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  for i=1,#beacons,1 do
    if data.raw.beacon[beacons[i]] then
      if data.raw.item[beacons[i]].stack_size < data.raw.item["se-compact-beacon"].stack_size then data.raw.item[beacons[i]].stack_size = data.raw.item["se-compact-beacon"].stack_size end
    end
    for i, beacon in pairs(data.raw.beacon) do
      beacon.se_allow_in_space = true
    end
  end
  localise("se-compact-beacon", {"item", "beacon"}, "description", {"description.ab_strict"})
  localise("se-compact-beacon-2", {"item", "beacon"}, "description", {"description.ab_strict"})
  localise("se-wide-beacon", {"item", "beacon"}, "description", {"description.ab_strict"})
  localise("se-wide-beacon-2", {"item", "beacon"}, "description", {"description.ab_strict"})
  data.raw.technology["se-compact-beacon"].localised_description = {"technology-description.se_compact"}
  data.raw.technology["se-compact-beacon-2"].localised_description = {"technology-description.se_compact_2"}
  data.raw.technology["se-wide-beacon"].localised_description = {"technology-description.se_wide"}
  data.raw.technology["se-wide-beacon-2"].localised_description = {"technology-description.se_wide_2"}
  data.raw.technology["effect-transmission"].localised_description = {"technology-description.effect_transmission_default"}
  if not startup["ab-override-vanilla-beacons"].value then
    localise("beacon", {"item", "beacon"}, "description", {"description.ab_strict"})
    custom_exclusion_ranges["beacon"] = {value = "solo", mode = "strict"}
  end
  -- TODO: Disable beacon overloading or limit it to basic/compact/wide beacons
end

if mods["nullius"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  order_beacons("nullius-large-beacon-2", 2, "nullius-cx", "nullius-cx") -- also prevents beacons from being hidden
  for i=2,#beacons,1 do
    if data.raw.item[beacons[i]] then
      if beacons[i] == "se-compact-beacon-2" or beacons[i] == "se-wide-beacon-2" then
        table.insert( data.raw["technology"]["nullius-broadcasting-4"].effects, { type = "unlock-recipe", recipe = beacons[i] } )
      else
        table.insert( data.raw["technology"]["nullius-broadcasting-3"].effects, { type = "unlock-recipe", recipe = beacons[i] } )
      end
    end
  end
  for tier=1,3,1 do
    localise("nullius-beacon-" .. tier, {"item", "beacon"}, "description", {"description.nullius"})
    if tier <= 2 then localise("nullius-large-beacon-" .. tier, {"item", "beacon"}, "description", {"description.nullius_large"}) end
    for count=1,4,1 do
      data.raw.beacon["nullius-beacon-" .. tier .. "-" .. count].localised_description = {'?', {'', {"description.nullius"}, ' ', {"description.nullius_1_2_3_4_addon", count}} }
    end
  end
  data.raw.technology["nullius-broadcasting-3"].localised_description = {"technology-description.effect_transmission_default"}
  -- TODO: boxing/unboxing recipes?
end

if mods["exotic-industries"] then -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
  for i=1,#beacons,1 do
    if data.raw.item[beacons[i]] then
      if beacons[i] == "se-compact-beacon-2" or beacons[i] == "se-wide-beacon-2" then
        table.insert( data.raw["technology"]["ei_iron-beacon"].effects, { type = "unlock-recipe", recipe = beacons[i] } )
      else
        table.insert( data.raw["technology"]["ei_copper-beacon"].effects, { type = "unlock-recipe", recipe = beacons[i] } )
      end
    end
  end
  localise("ei_copper-beacon", {"item", "beacon", "recipe"}, "name", {"name.ei_copper"})
  localise("ei_iron-beacon", {"item", "beacon", "recipe", "technology"}, "name", {"name.ei_iron"})
  localise("ei_copper-beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ei_both"}, '\n', {"description.ei_copper"}}})
  localise("ei_iron-beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ei_both"}, '\n', {"description.ei_iron"}}})
  localise("ei_alien-beacon", {"item", "beacon"}, "description", {"description.ab_bypass"})
  data.raw.technology["ei_copper-beacon"].localised_name = {"technology-name.effect_transmission_default"}
  data.raw.technology["ei_copper-beacon"].localised_description = {'?', {'', {"technology-description.effect_transmission_default"}, '\n\n', {"technology-description.ei_copper_addon"}}}
  data.raw.technology["ei_iron-beacon"].localised_description = {"technology-description.ei_iron"}
  max_moduled_building_size = 11
  -- Note: beacon overloading seems to happen inconsistently in some cases when additional beacons are within 6 tiles but not affecting the machine due to their distribution ranges (different behavior depending on whether the machine or the additional beacon were placed last)
end

if mods["248k"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- beacons have 2/6/18 module slots and 3/4/5 range normally; with Space Exploration, they have 10/15/45 module slots and 5/9/18 range while each core has 5 module slots instead of 2
  local modules = {"2", "6", "6"}
  if mods["space-exploration"] then
    -- beacons cannot be returned to their original stats here or in data-final-fixes.lua (the relevant changes are overridden) so they are instead made into "solo" beacons and disable each other to mimic the same functionality they have with beacon overloading
    -- stats just match the new expected values so the descriptions will be correct (the actual stats will be overridden)
    data.raw.beacon["el_ki_beacon_entity"].supply_area_distance = 5
    data.raw.beacon["el_ki_beacon_entity"].module_specification.module_slots = 10
    data.raw.beacon["fi_ki_beacon_entity"].supply_area_distance = 9
    data.raw.beacon["fi_ki_beacon_entity"].module_specification.module_slots = 15
    data.raw.beacon["fu_ki_beacon_entity"].supply_area_distance = 18
    data.raw.beacon["fu_ki_beacon_entity"].module_specification.module_slots = 45
    data.raw.beacon["el_ki_core_slave_entity"].module_specification.module_slots = 5
    data.raw.beacon["fi_ki_core_slave_entity"].module_specification.module_slots = 5
    data.raw.beacon["fu_ki_core_slave_entity"].module_specification.module_slots = 5
    modules = {"5", "15", "15"}
  else
    -- the usual normalization somehow prevents 248k's beacons from interacting with machines at the correct range even though the visualization appears correct; the KI1 and KI3 beacons have a lower apparent range so those can be increased for a better approximation; exclusion range visualizations are also adjusted further below
    if math.ceil(get_distribution_range(data.raw.beacon["el_ki_beacon_entity"])) == 3 then data.raw.beacon["el_ki_beacon_entity"].supply_area_distance = data.raw.beacon["el_ki_beacon_entity"].supply_area_distance + 0.075 end
    if math.ceil(get_distribution_range(data.raw.beacon["fu_ki_beacon_entity"])) == 3 then data.raw.beacon["fu_ki_beacon_entity"].supply_area_distance = data.raw.beacon["fu_ki_beacon_entity"].supply_area_distance + 0.075 end
  end
  local beacons = {"el_ki_beacon_entity", "fi_ki_beacon_entity", "fu_ki_beacon_entity"}
  for _, name in pairs(beacons) do
    local entity = data.raw.beacon[name]
    entity.radius_visualisation_picture.filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png"
    entity.radius_visualisation_picture.size = {10, 10}
    entity.drawing_box = entity.selection_box
    local min = 0.3
    if entity.collision_box[1][1] - min < entity.selection_box[1][1] then entity.collision_box[1][1] = entity.selection_box[1][1] + min end
    if entity.collision_box[1][2] - min < entity.selection_box[1][2] then entity.collision_box[1][2] = entity.selection_box[1][2] + min end
    if entity.collision_box[2][1] + min > entity.selection_box[2][1] then entity.collision_box[2][1] = entity.selection_box[2][1] - min end
    if entity.collision_box[2][2] + min > entity.selection_box[2][2] then entity.collision_box[2][2] = entity.selection_box[2][2] - min end
  end
  data.raw.item["el_ki_beacon_item"].localised_description = {"description.ki_1_2", modules[1]}
  data.raw.item["fi_ki_beacon_item"].localised_description = {"description.ki_1_2", modules[2]}
  data.raw.item["fu_ki_beacon_item"].localised_description = {"description.ki_3", modules[3]}
  data.raw.beacon["el_ki_beacon_entity"].localised_description = {"description.ki_1_2", modules[1]}
  data.raw.beacon["fi_ki_beacon_entity"].localised_description = {"description.ki_1_2", modules[2]}
  data.raw.beacon["fu_ki_beacon_entity"].localised_description = {"description.ki_3", modules[3]}
  data.raw.item["el_ki_core_item"].localised_description = {'?', {'', {"description.ki_core_1"}, ' ', {"description.ki_core_item_addon"}}}
  data.raw.item["fi_ki_core_item"].localised_description = {'?', {'', {"description.ki_core_2_3"}, ' ', {"description.ki_core_item_addon"}}}
  data.raw.item["fu_ki_core_item"].localised_description = {'?', {'', {"description.ki_core_2_3"}, ' ', {"description.ki_core_item_addon"}}}
  data.raw["assembling-machine"]["el_ki_core_entity"].localised_description = {"description.ki_core_1"}
  data.raw["assembling-machine"]["fi_ki_core_entity"].localised_description = {"description.ki_core_2_3"}
  data.raw["assembling-machine"]["fu_ki_core_entity"].localised_description = {"description.ki_core_2_3"}
  data.raw.beacon["el_ki_core_slave_entity"].localised_description = {"description.ki_core_slave_entity_1"}
  data.raw.beacon["fi_ki_core_slave_entity"].localised_description = {"description.ki_core_slave_entity_2_3"}
  data.raw.beacon["fu_ki_core_slave_entity"].localised_description = {"description.ki_core_slave_entity_2_3"}
end

if mods["pycoalprocessing"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  local old_effects = table.deepcopy(data.raw["technology"]["effect-transmission"].effects)
  data.raw["technology"]["effect-transmission"].effects = {}
  for i, effect in pairs(old_effects) do
    local skip = false
    if effect.type == "unlock-recipe" then
      for i=2,#beacons,1 do
        if beacons[i] == effect.recipe then skip = true end
      end
    end
    if skip == false then table.insert( data.raw["technology"]["effect-transmission"].effects, effect ) end
  end
  enable_replacement_standard_beacon("diet-beacon", "a[beacon]a")
  order_beacons("beacon", 2, "a[beacon]x", "a[beacon]x")
  if data.raw.item["ab-standard-beacon"].stack_size < data.raw.item["beacon-mk01"].stack_size then data.raw.item["ab-standard-beacon"].stack_size = data.raw.item["beacon-mk01"].stack_size end
  for i=2,6,1 do -- only 5 beacons are added here, the others have their own technologies
    if data.raw.item[beacons[i]] then
      table.insert( data.raw["technology"]["diet-beacon"].effects, { type = "unlock-recipe", recipe = beacons[i] } )
    end
  end
  cancel_override = true
  data.raw.item["beacon"].localised_description = {"description.py_AM_FM"}
  data.raw.technology["diet-beacon"].localised_name = {"technology-name.py_diet_transmission"}
  data.raw.technology["diet-beacon"].localised_description = {'?', {'', {"technology-description.effect_transmission_default"}, '\n\n', {"technology-description.py_diet_addon"}}}
  data.raw.technology["effect-transmission"].localised_description = {"technology-description.py_main"}
  table.insert(data.raw.technology["effect-transmission"].prerequisites, "diet-beacon")
  for am=1,5,1 do
    for fm=1,5,1 do
      data.raw.beacon["beacon-AM" .. tostring(am) .. "-FM" .. tostring(fm)].localised_description = {"description.py_AM_FM"}
      data.raw.beacon["diet-beacon-AM" .. tostring(am) .. "-FM" .. tostring(fm)].localised_description = {"description.py_AM_FM"}
      custom_exclusion_ranges["beacon-AM" .. am .. "-FM" .. fm] = {value = "solo", mode = "strict"}
      custom_exclusion_ranges["diet-beacon-AM" .. am .. "-FM" .. fm] = {value = "solo", mode = "strict"}
    end
  end
  if data.raw.technology["se-compact-beacon"] and data.raw.technology["se-wide-beacon"] and data.raw.technology["se-compact-beacon-2"] and data.raw.technology["se-wide-beacon-2"] then
    table.insert( data.raw["technology"]["diet-beacon"].effects, { type = "unlock-recipe", recipe = "se-basic-beacon" } )
    data.raw.technology["se-compact-beacon"].prerequisites = {"diet-beacon"}
    data.raw.technology["se-compact-beacon"].unit = {count=500, time=60, ingredients={{name="automation-science-pack", amount=3}, {name="logistic-science-pack", amount=2}, {name="chemical-science-pack", amount=1}}}
    data.raw.technology["se-wide-beacon"].prerequisites = {"diet-beacon"}
    data.raw.technology["se-wide-beacon"].unit = data.raw.technology["se-compact-beacon"].unit
    data.raw.technology["se-compact-beacon-2"].prerequisites = {"se-compact-beacon", "effect-transmission"}
    data.raw.technology["se-compact-beacon-2"].unit = {count=1000, time=60, ingredients={{name="automation-science-pack", amount=6}, {name="logistic-science-pack", amount=3}, {name="chemical-science-pack", amount=2}, {name="production-science-pack", amount=1}}}
    data.raw.technology["se-wide-beacon-2"].prerequisites = {"se-wide-beacon", "effect-transmission"}
    data.raw.technology["se-wide-beacon-2"].unit = data.raw.technology["se-compact-beacon-2"].unit
  end
  max_moduled_building_size = 11
  if mods["pypetroleumhandling"] then max_moduled_building_size = 15 end
  --if mods["pyrawores"] then max_moduled_building_size = 19 end -- the only module-able structures larger than 15x15 are the aluminum mine (19x19) and titanium mine (23x23); TODO: test whether belts even have the throughput to support 4x the normal maximum for larger buildings like this
  exclusion_range_values["beacon"] = 64 + max_moduled_building_size-1
end

if mods["Ultracube"] then -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  for i=1,#beacons,1 do
    if data.raw.item[beacons[i]] then
      table.insert( data.raw["technology"]["cube-beacon"].effects, { type = "unlock-recipe", recipe = beacons[i] } )
      data.raw.beacon[beacons[i]].distribution_effectivity = data.raw.beacon[beacons[i]].distribution_effectivity * 0.2
    end
  end
  cancel_override = true
  localise("cube-beacon", {"item", "beacon", "recipe"}, "name", {"name.ultra_cube"})
  localise("cube-beacon", {"item", "beacon"}, "description", {"description.ultra_cube"})
  data.raw["assembling-machine"]["cube-beacon-fluid-source"].localised_name = {"name.ultra_cube"}
  data.raw["assembling-machine"]["cube-beacon-fluid-source"].localised_description = {"description.ultra_cube"}
  data.raw.technology["cube-beacon"].localised_description = {'?', {'', {"technology-description.effect_transmission_default"}, ' ', {"technology-description.ultra_cube_addon"}}}
  -- TODO: Disable beacon overloading or limit it to arcane beacons
end

if mods["5dim_module"] or mods["OD27_5dim_module"] then -----------------------------------------------------------------------------------------------------------------------------------------------------
  data.raw.recipe.beacon.order = "a[beacon]"
  data.raw.item.beacon.order = "a[beacon]"
  if mods["pycoalprocessing"] then
    localise("ab-standard-beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_standard_tiers_addon"}} })
    data.raw.recipe["beacon"].icon = data.raw.item["beacon"].icon
    order_beacons("beacon-mk01", 2, "x[beacon]x", "x")
  else
    localise("beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_standard_tiers_addon"}} })
    order_beacons("beacon", 2, "x[beacon]x", "x")
  end
  override_localisation = false
  for tier=2,10,1 do
    local kind = "ab_same"
    local tier_string = "0" .. tier
    if tier <= 4 then kind = "ab_standard" end
    if tier > 9 then tier_string = tier end
    localise("5d-beacon-" .. tier_string, {"item", "beacon"}, "description", {"description." .. kind})
  end
  -- Balance: rescaled linearly at +0.2 module power per tier; beacons with 3 range won't disable standard beacons and vice versa
  if startup["ab-balance-other-beacons"].value then
    data.raw.beacon["5d-beacon-02"].energy_usage = "960kW"
    data.raw.beacon["5d-beacon-02"].distribution_effectivity = 0.6
    data.raw.beacon["5d-beacon-02"].module_specification.module_slots = 2
    data.raw.beacon["5d-beacon-03"].energy_usage = "1440kW"
    data.raw.beacon["5d-beacon-03"].distribution_effectivity = 0.4667
    data.raw.beacon["5d-beacon-03"].module_specification.module_slots = 3
    data.raw.beacon["5d-beacon-04"].energy_usage = "2000kW"
    data.raw.beacon["5d-beacon-04"].distribution_effectivity = 0.4
    data.raw.beacon["5d-beacon-04"].module_specification.module_slots = 4
    data.raw.beacon["5d-beacon-05"].energy_usage = "2500kW"
    data.raw.beacon["5d-beacon-05"].distribution_effectivity = 0.36
    data.raw.beacon["5d-beacon-05"].module_specification.module_slots = 5
    data.raw.beacon["5d-beacon-05"].module_specification.module_info_max_icons_per_row = 3
    data.raw.beacon["5d-beacon-06"].energy_usage = "3000kW"
    data.raw.beacon["5d-beacon-06"].distribution_effectivity = 0.4
    data.raw.beacon["5d-beacon-06"].module_specification.module_slots = 5
    data.raw.beacon["5d-beacon-06"].module_specification.module_info_max_icons_per_row = 3
    data.raw.beacon["5d-beacon-07"].energy_usage = "3500kW"
    data.raw.beacon["5d-beacon-07"].distribution_effectivity = 0.3667
    data.raw.beacon["5d-beacon-07"].module_specification.module_slots = 6
    data.raw.beacon["5d-beacon-07"].module_specification.module_info_max_icons_per_row = 3
    data.raw.beacon["5d-beacon-08"].energy_usage = "4000kW"
    data.raw.beacon["5d-beacon-08"].distribution_effectivity = 0.4
    data.raw.beacon["5d-beacon-08"].module_specification.module_slots = 6
    data.raw.beacon["5d-beacon-08"].module_specification.module_info_max_icons_per_row = 3
    data.raw.beacon["5d-beacon-09"].energy_usage = "4500kW"
    data.raw.beacon["5d-beacon-09"].distribution_effectivity = 0.3715
    data.raw.beacon["5d-beacon-09"].module_specification.module_slots = 7
    data.raw.beacon["5d-beacon-09"].module_specification.module_info_max_icons_per_row = 4
    data.raw.beacon["5d-beacon-10"].energy_usage = "5000kW"
    data.raw.beacon["5d-beacon-10"].distribution_effectivity = 0.4
    data.raw.beacon["5d-beacon-10"].module_specification.module_slots = 7
    data.raw.beacon["5d-beacon-10"].module_specification.module_info_max_icons_per_row = 4
  end
end

if mods["Advanced_Modules"] or mods["Advanced_Sky_Modules"] or mods["Advanced_beacons"] then ------------------------------------------------------------------------------------------------------------
  -- same names used among these three mods; productivity beacons have 0.5/0.75/1.0 efficiency, 2/4/6 module slots, 3 range, and 480/240/120 kW power usage; speed beacons are the same except they have 6 range (in the "sky" version they have 1?/0.75/2 efficiency, 2/8/12 module slots, and 8/12/20 range); efficiency beacons have 1/2/4 efficiency, 2 module slots, 9/18/36 range, and 240/120/60 kW power usage
  local kinds = {"clean", "speed", "productivity"}
  for index, kind in pairs(kinds) do
    for tier=1,3,1 do
      local mode = {"description.ab_different"}
      if kind == "clean" or (kind == "speed" and tier == 1) then mode = {"description.ab_same"} end
      localise(kind .. "-beacon-" .. tier, {"item", "beacon"}, "description", {'?', {'', mode, ' ', {"description." .. kind .. "_1_2_3_addon"}}})
      data.raw.beacon[kind .. "-beacon-" .. tier].radius_visualisation_picture.filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png"
    end
  end
  data.raw["item-group"]["a-modules"].localised_name = {"name.advanced-modules-group"}
  data.raw["item-group"]["a-modules"].icon_size = 256
  data.raw["item-group"]["a-modules"].icon_mipmaps = 4
  -- Beacons/modules only getting speed or productivity effects is not a downside (those are the most powerful effects) so these mods canot be balanced to the same level as others without also modifying module stats
  -- Balance: productivity beacons have lower range and are given +3/+4/+5 exclusion range, speed beacons are given +0/+2/+5 exclusion range
  if startup["ab-balance-other-beacons"].value then
    data.raw.beacon["productivity-beacon-1"].energy_usage = "1000kW"
    data.raw.beacon["productivity-beacon-1"].distribution_effectivity = 0.25
    data.raw.beacon["productivity-beacon-1"].supply_area_distance = 2
    data.raw.beacon["productivity-beacon-2"].energy_usage = "2500kW"
    data.raw.beacon["productivity-beacon-2"].distribution_effectivity = 0.25
    data.raw.beacon["productivity-beacon-2"].supply_area_distance = 2
    data.raw.beacon["productivity-beacon-3"].energy_usage = "6000kW"
    data.raw.beacon["productivity-beacon-3"].distribution_effectivity = 0.25
    data.raw.beacon["productivity-beacon-3"].supply_area_distance = 2
    data.raw.beacon["speed-beacon-1"].energy_usage = "1000kW"
    data.raw.beacon["speed-beacon-1"].distribution_effectivity = 0.5
    data.raw.beacon["speed-beacon-2"].energy_usage = "2500kW"
    data.raw.beacon["speed-beacon-2"].distribution_effectivity = 0.5
    data.raw.beacon["speed-beacon-2"].module_specification.module_slots = 4
    data.raw.beacon["speed-beacon-3"].energy_usage = "6000kW"
    data.raw.beacon["speed-beacon-3"].distribution_effectivity = 0.5
    data.raw.beacon["speed-beacon-3"].module_specification.module_slots = 6
    -- Balance: modules
    local kinds = {["speed"] = {20,40,60,80,100,120}, ["productivity"] = {5,10,15,20,25,30}}
    if mods["Advanced_Sky_Modules"] == nil then
      for kind, values in pairs(kinds) do
        for tier=1,6,1 do
          data.raw.module["pure-" .. kind .. "-module-" .. tostring(tier)].effect[kind].bonus = values[tier]/100 * 0.6 -- pure speed/productivity modules originally matched the normal versions while also removing the negatives so there was no tradeoff; rebalanced to be 3/5 of the value instead
        end
      end
      data.raw.module["god-module"].effect = { consumption = {bonus=-0.15}, speed = {bonus=0.15}, productivity = {bonus=0.15}, pollution = {bonus=-0.15} } -- also reduced to 3/5 of previous values
    else
      for kind, values in pairs(kinds) do
        for tier=1,6,1 do
          data.raw.module["pure-" .. kind .. "-module-" .. tostring(tier)].effect[kind].bonus = values[tier]/100 -- "sky" versions simply match the normal values
        end
      end
        data.raw.module["effectivity-module-4"].effect.pollution.bonus = -0.40 -- fixes higher tier efficiency modules so they reduce pollution instead of increase it
        data.raw.module["effectivity-module-5"].effect.pollution.bonus = -0.50
        data.raw.module["effectivity-module-6"].effect.pollution.bonus = -0.60
      data.raw.module["god-module"].effect = { consumption = {bonus=-0.25}, speed = {bonus=0.25}, productivity = {bonus=0.25}, pollution = {bonus=-0.25} } -- reduced to match original version; fixes pollution so it gets reduced instead of increased
    end
  end
  data.raw.beacon["speed-beacon-1"].supply_area_distance = 6  -- TODO: add more functionality in control.lua so the setting which enables/disables balance changes can also correctly handle different ranges for entities with the same names (exclusion ranges are currently hardcoded based on item name)
  data.raw.beacon["speed-beacon-2"].supply_area_distance = 6
  data.raw.beacon["speed-beacon-3"].supply_area_distance = 6
  -- TODO: Balance more? less?
end

if mods["IndustrialRevolution3"] then -------------------------------------------------------------------------------------------------------------------------------------------------------------------
  order_beacons("beacon", 1, "zz", "zz")
end

if mods["SeaBlock"] then --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  order_beacons("beacon", 1, "a[beacon]-x", "a[beacon]-x")
end

if mods["bobmodules"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- same names as Endgame Extension and Beacon 2; beacon-2 has 6 range, 4 modules, and 0.75 efficiency; beacon-3 has 9 range, 6 modules, and 1.0 efficiency
  localise("beacon-2", {"item", "beacon"}, "description", {"description.ab_same"})
  localise("beacon-3", {"item", "beacon"}, "description", {"description.ab_different"})
  -- Balance: power requirements adjusted upward, efficiencies reduced, reduced range of beacon-2, beacon-3 given +2 exclusion range; they are still superior to node/conflux beacons, although they are at least somewhat comparable now
  if startup["ab-balance-other-beacons"].value then
    data.raw.beacon["beacon-2"].energy_usage = "3000kW"
    data.raw.beacon["beacon-2"].distribution_effectivity = 0.5
    data.raw.beacon["beacon-2"].supply_area_distance = 5
    data.raw.beacon["beacon-3"].energy_usage = "6000kW"
    data.raw.beacon["beacon-3"].distribution_effectivity = 0.5
  end
end

if mods["EndgameExtension"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- same names as Bob's and Beacon 2; beacon-2 has 5 range, 0.75 efficiency, 3 module slots; beacon-3 has 7 range, 1.0 efficiency, 5 module slots; productivity-beacon has 3 range, 1.0 efficiency, 5 module slots
  localise("beacon-2", {"item", "beacon"}, "description", {"description.ab_same"})
  localise("beacon-3", {"item", "beacon"}, "description", {"description.ab_different"})
  localise("productivity-beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_different"}, ' ', {"description.productivity_addon"}}})
  local beacons = {"beacon-2", "beacon-3", "productivity-beacon"}
  for index, name in pairs(beacons) do
    data.raw.recipe[name].order = "a[beacon]n2[" .. name .. "]"
    data.raw.item[name].order = "a[beacon]n2[" .. name .. "]"
  end
  -- Balance: beacon-2 and beacon-3 changed to match Bob's versions since they're similar enough; productivity beacon given +3 exclusion range
  if startup["ab-balance-other-beacons"].value then
    data.raw.beacon["beacon-2"].energy_usage = "3000kW"
    data.raw.beacon["beacon-2"].max_health = 300
    data.raw.beacon["beacon-2"].distribution_effectivity = 0.5
    data.raw.beacon["beacon-2"].module_specification.module_slots = 4
    data.raw.beacon["beacon-3"].energy_usage = "6000kW"
    data.raw.beacon["beacon-3"].max_health = 400
    data.raw.beacon["beacon-3"].distribution_effectivity = 0.5
    data.raw.beacon["beacon-3"].module_specification.module_slots = 6
    data.raw.beacon["beacon-3"].supply_area_distance = 9
  end
  -- TODO: fix crash with Nullius?
end

if mods["Beacon2"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- same name as Bob's and Endgame Extension; beacon-2 has 3 range, 0.5 efficiency, 4 module slots
  localise("beacon-2", {"item", "beacon"}, "description", {"description.ab_standard"})
  localise("beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_standard_tiers_addon"}} })
  -- Balance: doesn't disable standard beacons or vice versa
end

if mods["FactorioExtended-Plus-Module"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- same names as Zombies Extended: beacon-mk2, beacon-mk3; beacons have 3 range and 2 module slots with 0.75 and 1.0 efficiency each
  -- Balance: these don't disable standard beacons or vice versa
  localise("beacon-mk2", {"item", "beacon"}, "description", {"description.ab_standard"})
  localise("beacon-mk3", {"item", "beacon"}, "description", {"description.ab_standard"})
  localise("beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_standard_tiers_addon"}} })
end

if mods["zombiesextended-modules"] then -----------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- same names as Factorio Extended: beacon-mk1, beacon-mk2, beacon-mk3; beacons have 3 range and 2 module slots with 1, 2, and 3 efficiency each
  localise("beacon-mk1", {"item", "beacon"}, "description", {"description.ab_standard"})
  localise("beacon-mk2", {"item", "beacon"}, "description", {"description.ab_standard"})
  localise("beacon-mk3", {"item", "beacon"}, "description", {"description.ab_standard"})
  localise("beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_standard_tiers_addon"}} })
  -- Balance: rescaled to max out at 1 efficiency instead of 3 (similar to Factorio Extended); they don't disable standard beacons and vice versa
  if startup["ab-balance-other-beacons"].value then
    data.raw.beacon["beacon-mk1"].distribution_effectivity = 0.65
    data.raw.beacon["beacon-mk2"].distribution_effectivity = 0.8
    data.raw.beacon["beacon-mk3"].distribution_effectivity = 1
  end
end

if mods["BeaconMk2"] then -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  localise("beaconmk2", {"item", "beacon"}, "description", {"description.ab_same"})
  data.raw.recipe["beaconmk2"].order = "a[beacon]mk2"
  data.raw.item["beaconmk2"].order = "a[beacon]mk2"
  -- beaconmk2 has 5 range, 0.5 efficiency, 4 module slots
end

if mods["beacons"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- beacon2 has 4 range, 0.75 efficiency, 4 module slots; beacon3 has 5 range, 1.0 efficiency, 6 module slots
  for tier=2,3,1 do
    localise("beacon" .. tostring(tier), {"item", "beacon"}, "description", {"description.ab_same"})
    data.raw.recipe["beacon" .. tostring(tier)].order = "a[beacon]n" .. tostring(tier)
    data.raw.item["beacon" .. tostring(tier)].order = "a[beacon]n" .. tostring(tier)
  end
  -- Balance: reduced efficiency, increased range
  if startup["ab-balance-other-beacons"].value then
    data.raw.beacon["beacon2"].distribution_effectivity = 0.5
    data.raw.beacon["beacon2"].supply_area_distance = 5
    data.raw.beacon["beacon3"].distribution_effectivity = 0.5
  end
  data.raw.beacon["beacon3"].supply_area_distance = 6
end

if mods["mini-machines"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- mini-beacon-1 and other mini beacons are 2x2
  if startup["mini-beacon"].value == true then
    if startup["ab-balance-other-beacons"].value == true then
      -- Balance: range scaled down to match size difference, efficiency (and module slots in some cases) adjusted so that the module power is roughly 3/4 of the full-size version
      if data.raw.beacon["ab-standard-beacon"] then
        generate_new_beacon("ab-standard-beacon", "mini-beacon-1", "Mini standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, 2, 2, 0.375, "360kW")
      else
        generate_new_beacon("beacon", "mini-beacon-1", "Mini standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, 2, 2, 0.375, "360kW")
      end
      if mods["bobmodules"] then
        generate_new_beacon("beacon-2", "mini-beacon-2", "Mini beacon 2", {"description.ab_same"}, 2, 4, 3, 0.5, "2250kW")
        generate_new_beacon("beacon-3", "mini-beacon-3", "Mini beacon 3", {"description.ab_different"}, 2, 6, 5, 0.5, "4500kW")
        custom_exclusion_ranges["mini-beacon-3"] = {value = 8}
      elseif mods["FactorioExtended-Plus-Module"] then
        localise("mini-beacon-1", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_tiers_addon"}}})
        generate_new_beacon("beacon-mk2", "mini-beacon-2", "Mini beacon Mk2", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, 2, 2, 0.55, "450kW")
        generate_new_beacon("beacon-mk3", "mini-beacon-3", "Mini beacon Mk3", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, 2, 2, 0.75, "540kW")
      elseif mods["5dim_module"] then
        localise("mini-beacon-1", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_tiers_addon"}}})
        generate_new_beacon("5d-beacon-02", "mini-beacon-2", "Mini beacon MK2", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, 2, 2, 0.45, "720kW")
        generate_new_beacon("5d-beacon-03", "mini-beacon-3", "Mini beacon MK3", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, 2, 2, 0.5, "1080kW")
      end
      if mods["5dim_module"] then
        generate_new_beacon("5d-beacon-04", "mini-beacon-4", "Mini beacon MK4", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, 2, 2, 0.55, "1500kW")
        generate_new_beacon("5d-beacon-05", "mini-beacon-5", "Mini beacon MK5", {"description.ab_same"}, 2, 3, 3, 0.4, "1875kW")
        generate_new_beacon("5d-beacon-06", "mini-beacon-6", "Mini beacon MK6", {"description.ab_same"}, 2, 3, 3, 0.4667, "2250kW")
        generate_new_beacon("5d-beacon-07", "mini-beacon-7", "Mini beacon MK7", {"description.ab_same"}, 2, 4, 3, 0.5334, "2625kW")
        generate_new_beacon("5d-beacon-08", "mini-beacon-8", "Mini beacon MK8", {"description.ab_same"}, 2, 4, 4, 0.45, "3000kW")
        generate_new_beacon("5d-beacon-09", "mini-beacon-9", "Mini beacon MK9", {"description.ab_same"}, 2, 5, 4, 0.5, "3375kW")
        generate_new_beacon("5d-beacon-10", "mini-beacon-10", "Mini beacon MK10", {"description.ab_same"}, 2, 5, 4, 0.55, "3750kW")
      end
    else
      local fewer_modules = 0
      if startup["mini-balance-module"].value == true then fewer_modules = 1 end
      if data.raw.beacon["ab-standard-beacon"] then
        generate_new_beacon("ab-standard-beacon", "mini-beacon-1", "Mini standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, nil, math.max(1, data.raw.beacon["ab-standard-beacon"].module_specification.module_slots-fewer_modules))
      else
        generate_new_beacon("beacon", "mini-beacon-1", "Mini standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, nil, math.max(1, data.raw.beacon["beacon"].module_specification.module_slots-fewer_modules))
      end
      if mods["bobmodules"] then
        generate_new_beacon("beacon-2", "mini-beacon-2", "Mini beacon 2", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["beacon-2"].module_specification.module_slots-fewer_modules))
        generate_new_beacon("beacon-3", "mini-beacon-3", "Mini beacon 3", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["beacon-3"].module_specification.module_slots-fewer_modules))
      elseif mods["FactorioExtended-Plus-Module"] then
        generate_new_beacon("beacon-mk2", "mini-beacon-2", "Mini beacon Mk2", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["beacon-mk2"].module_specification.module_slots-fewer_modules))
        generate_new_beacon("beacon-mk3", "mini-beacon-3", "Mini beacon Mk3", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["beacon-mk3"].module_specification.module_slots-fewer_modules))
      elseif mods["5dim_module"] then
        generate_new_beacon("5d-beacon-02", "mini-beacon-2", "Mini beacon MK2", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-02"].module_specification.module_slots-fewer_modules))
        generate_new_beacon("5d-beacon-03", "mini-beacon-3", "Mini beacon MK3", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-03"].module_specification.module_slots-fewer_modules))
      end
      if mods["5dim_module"] then
        generate_new_beacon("5d-beacon-04", "mini-beacon-4", "Mini beacon MK4", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-04"].module_specification.module_slots-fewer_modules))
        generate_new_beacon("5d-beacon-05", "mini-beacon-5", "Mini beacon MK5", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-05"].module_specification.module_slots-fewer_modules))
        generate_new_beacon("5d-beacon-06", "mini-beacon-6", "Mini beacon MK6", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-06"].module_specification.module_slots-fewer_modules))
        generate_new_beacon("5d-beacon-07", "mini-beacon-7", "Mini beacon MK7", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-07"].module_specification.module_slots-fewer_modules))
        generate_new_beacon("5d-beacon-08", "mini-beacon-8", "Mini beacon MK8", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-08"].module_specification.module_slots-fewer_modules))
        generate_new_beacon("5d-beacon-09", "mini-beacon-9", "Mini beacon MK9", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-09"].module_specification.module_slots-fewer_modules))
        generate_new_beacon("5d-beacon-10", "mini-beacon-10", "Mini beacon MK10", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-10"].module_specification.module_slots-fewer_modules))
      end
    end
    data.raw.item["mini-beacon-1"].order = "a[beacon]-1-z"
    data.raw.recipe["mini-beacon-1"].order = "a[beacon]-1-z"
  end
end

if mods["micro-machines"] then --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- micro-beacon-1 and other micro beacons are 1x1
  if startup["micro-beacon"].value == true then
    if startup["ab-balance-other-beacons"].value == true then
      -- Balance: range scaled down to match size difference, most only have 1 module slot, efficiency adjusted so that the module power is roughly half of the full-size version
      if data.raw.beacon["ab-standard-beacon"] then
        generate_new_beacon("ab-standard-beacon", "micro-beacon-1", "Micro standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1, 1, 1, 0.5, "240kW")
      else
        generate_new_beacon("beacon", "micro-beacon-1", "Micro standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1, 1, 1, 0.5, "240kW")
      end
      if mods["bobmodules"] then
        generate_new_beacon("beacon-2", "micro-beacon-2", "Micro beacon 2", {"description.ab_same"}, 1, 2, 2, 0.5, "1500kW")
        generate_new_beacon("beacon-3", "micro-beacon-3", "Micro beacon 3", {"description.ab_different"}, 1, 3, 4, 0.5, "3000kW")
        custom_exclusion_ranges["micro-beacon-3"] = {value = 5}
      elseif mods["FactorioExtended-Plus-Module"] then
        localise("micro-beacon-1", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_tiers_addon"}}})
        generate_new_beacon("beacon-mk2", "micro-beacon-2", "Micro beacon Mk2", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1, 1, 1, 0.75, "300kW")
        generate_new_beacon("beacon-mk3", "micro-beacon-3", "Micro beacon Mk3", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1, 1, 1, 1, "360kW")
      elseif mods["5dim_module"] then
        localise("micro-beacon-1", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_tiers_addon"}}})
        generate_new_beacon("5d-beacon-02", "micro-beacon-2", "Micro beacon MK2", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1, 1, 1, 0.6, "480kW")
        generate_new_beacon("5d-beacon-03", "micro-beacon-3", "Micro beacon MK3", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1, 1, 1, 0.7, "720kW")
      end
      if mods["5dim_module"] then
        generate_new_beacon("5d-beacon-04", "micro-beacon-4", "Micro beacon MK4", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1, 1, 1, 0.8, "1000kW")
        generate_new_beacon("5d-beacon-05", "micro-beacon-5", "Micro beacon MK5", {"description.ab_same"}, 1, 2, 1, 0.9, "1250kW")
        generate_new_beacon("5d-beacon-06", "micro-beacon-6", "Micro beacon MK6", {"description.ab_same"}, 1, 2, 1, 1, "1500kW")
        generate_new_beacon("5d-beacon-07", "micro-beacon-7", "Micro beacon MK7", {"description.ab_same"}, 1, 2, 1, 1.1, "1750kW")
        generate_new_beacon("5d-beacon-08", "micro-beacon-8", "Micro beacon MK8", {"description.ab_same"}, 1, 3, 1, 1.2, "2000kW")
        generate_new_beacon("5d-beacon-09", "micro-beacon-9", "Micro beacon MK9", {"description.ab_same"}, 1, 3, 1, 1.3, "2250kW")
        generate_new_beacon("5d-beacon-10", "micro-beacon-10", "Micro beacon MK10", {"description.ab_same"}, 1, 3, 1, 1.4, "2500kW")
      end
    else
      if data.raw.beacon["ab-standard-beacon"] then
        generate_new_beacon("ab-standard-beacon", "micro-beacon-1", "Micro standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1)
      else
        generate_new_beacon("beacon", "micro-beacon-1", "Micro standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1)
      end
      if mods["bobmodules"] then
        generate_new_beacon("beacon-2", "micro-beacon-2", "Micro beacon 2", {"description.ab_same"}, 1)
        generate_new_beacon("beacon-3", "micro-beacon-3", "Micro beacon 3", {"description.ab_same"}, 1)
      elseif mods["FactorioExtended-Plus-Module"] then
        generate_new_beacon("beacon-mk2", "micro-beacon-2", "Micro beacon Mk2", {"description.ab_same"}, 1)
        generate_new_beacon("beacon-mk3", "micro-beacon-3", "Micro beacon Mk3", {"description.ab_same"}, 1)
      elseif mods["5dim_module"] then
        generate_new_beacon("5d-beacon-02", "micro-beacon-2", "Micro beacon MK2", {"description.ab_same"}, 1)
        generate_new_beacon("5d-beacon-03", "micro-beacon-3", "Micro beacon MK3", {"description.ab_same"}, 1)
      end
      if mods["5dim_module"] then
        generate_new_beacon("5d-beacon-04", "micro-beacon-4", "Micro beacon MK4", {"description.ab_same"}, 1)
        generate_new_beacon("5d-beacon-05", "micro-beacon-5", "Micro beacon MK5", {"description.ab_same"}, 1)
        generate_new_beacon("5d-beacon-06", "micro-beacon-6", "Micro beacon MK6", {"description.ab_same"}, 1)
        generate_new_beacon("5d-beacon-07", "micro-beacon-7", "Micro beacon MK7", {"description.ab_same"}, 1)
        generate_new_beacon("5d-beacon-08", "micro-beacon-8", "Micro beacon MK8", {"description.ab_same"}, 1)
        generate_new_beacon("5d-beacon-09", "micro-beacon-9", "Micro beacon MK9", {"description.ab_same"}, 1)
        generate_new_beacon("5d-beacon-10", "micro-beacon-10", "Micro beacon MK10", {"description.ab_same"}, 1)
      end
    end
    data.raw.item["micro-beacon-1"].order = "a[beacon]-1-zz"
    data.raw.recipe["micro-beacon-1"].order = "a[beacon]-1-zz"
  end
end

if mods["TarawindBeaconsRE"] or mods["TarawindBeaconsRE3x3"] then ---------------------------------------------------------------------------------------------------------------------------------------
  if startup["ab-balance-other-beacons"].value then
    for tier=1,7,1 do
      if not startup["tarawind-reloaded-reducerange"].value then data.raw.beacon["twBeacon" .. tostring(tier)].supply_area_distance = data.raw.beacon["twBeacon" .. tostring(tier)].module_specification.module_slots end
      data.raw.beacon["twBeacon" .. tostring(tier)].distribution_effectivity = 0.3
    end
  end
  for tier=1,7,1 do
    localise("twBeacon" .. tostring(tier), {"item", "beacon"}, "description", {"description.ab_same"})
    data.raw.recipe["twBeacon" .. tostring(tier)].order = "a[beacon]tw" .. tostring(tier)
    data.raw.item["twBeacon" .. tostring(tier)].order = "a[beacon]tw" .. tostring(tier)
    data.raw.beacon["twBeacon" .. tostring(tier)].radius_visualisation_picture.filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png"
    data.raw.beacon["twBeacon" .. tostring(tier)].radius_visualisation_picture.size = {10, 10}
    if startup["tarawind-reloaded-3x3mode"].value == false then
      data.raw.beacon["twBeacon" .. tostring(tier)].selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
      data.raw.beacon["twBeacon" .. tostring(tier)].collision_box = {{-0.2, -0.2}, {0.2, 0.2}}
      data.raw.beacon["twBeacon" .. tostring(tier)].supply_area_distance = data.raw.beacon["twBeacon" .. tostring(tier)].supply_area_distance + 1 -- temporarily sets value so that descriptions will be correct
    end
  end
end

if mods["Darkstar_utilities"] or mods["Darkstar_utilities_fixed"] then ----------------------------------------------------------------------------------------------------------------------------------
  -- each beacon is 3x3: basic-beacon-mk2 has 8 range, 1 module slot, 0.5 efficiency, can use all effects; efficiency-beacon has 25 range, 12 module slots, 3 efficiency, can only use efficiency modules; ultra-beacon has 25 range, 3 module slots, 0.5 efficiency; power-boost-beacon has 2 range, 1 module slot, 2.5 efficiency; world-array has 64 range, 10 module slots, 0.5 efficiency
  localise("basic-beacon-mk2", {"item", "beacon"}, "description", {"description.ab_same"})
  localise("efficiency-beacon", {"item", "beacon"}, "description", {"description.ab_same"})
  localise("ultra-beacon", {"item", "beacon"}, "description", {"description.ab_same"})
  localise("power-boost-beacon", {"item", "beacon"}, "description", {"description.ab_same"})
  localise("world-array", {"item", "beacon"}, "description", {"description.ab_same"})
end

if mods["warptorio2"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- warp beacons neither disable nor get disabled by other beacons via the "exclusion area" system
  for i=1,10,1 do
    data.raw.beacon["warptorio-beacon-" .. i].localised_description = {"description.ab_bypass"}
  end
end

if mods["PowerCrystals"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- next_upgrade removed in case other mods add it (would cause a crash since they aren't minable)
  local kinds = {"productivity", "speed", "effectivity"}
  for tier=1,3,1 do
    for _, kind in pairs(kinds) do
      data.raw.beacon["model-power-crystal-" .. kind .. "-" .. tier].next_upgrade = nil
    end
    data.raw.beacon["base-power-crystal-" .. tier].next_upgrade = nil
    if tier <= 2 then
      data.raw.beacon["model-power-crystal-instability-" .. tier].next_upgrade = nil
      data.raw.beacon["base-power-crystal-negative-" .. tier].next_upgrade = nil
    end
  end
  -- Balance: Power crystals neither disable nor get disabled by other beacons via the "exclusion area" system
end

if mods["EditorExtensions"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- ee-super-beacon is only available in the editor so it was changed to not interact with the "exclusion area" system
end

if mods["starry-sakura"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  -- TODO: ?
end

if mods["FreightForwarding"] then
  if data.raw.technology["se-compact-beacon-2"] and data.raw.technology["se-wide-beacon-2"] then
    table.insert(data.raw.technology["se-compact-beacon"].unit.ingredients, {name="ff-transport-science-pack", amount=1})
    table.insert(data.raw.technology["se-wide-beacon"].unit.ingredients, {name="ff-transport-science-pack", amount=1})
    table.insert(data.raw.technology["se-compact-beacon-2"].unit.ingredients, {name="ff-transport-science-pack", amount=1})
    table.insert(data.raw.technology["se-wide-beacon-2"].unit.ingredients, {name="ff-transport-science-pack", amount=1})
  end
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- adjustments for all mods
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- override stats of vanilla beacons
if startup["ab-override-vanilla-beacons"].value and cancel_override == false then
  if data.raw.recipe.beacon ~= nil and data.raw.item.beacon ~= nil and data.raw.beacon.beacon ~= nil and data.raw.technology["effect-transmission"] ~= nil then
    override_vanilla_beacon(override_localisation, true)
  end
end

normalize_distribution_ranges(distribution_range_indent)
if ordered == false then order_beacons("beacon", 2, "a[beacon]x", "x") end

-- add visualization for beacons from other mods which use custom exclusion ranges; does not do error checking for invalid possibilities within custom_exclusion_ranges
if startup["ab-disable-exclusion-areas"].value == false then
  for name, range in pairs(custom_exclusion_ranges) do
    local beacon = data.raw.beacon[name]
    if beacon ~= nil and beacon.collision_box ~= nil and beacon.selection_box ~= nil then
      local distribution_range = get_distribution_range(beacon)
      local exclusion_range = range.value
      if range.value == nil then
        exclusion_range = distribution_range
      elseif range.value == "solo" then
        if range.mode == nil or range.mode == "basic" then
          exclusion_range = 2*distribution_range + max_moduled_building_size-1
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
        if base <= image_size then
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

-- adds extended stats for most beacon items & entities
if startup["ab-show-extended-stats"].value then
  local no_stats = {} -- stats aren't shown for the naturally-generated beacons from the Power Crystals mod or the inner part of KI cores
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

  local beacon_list = {}
  for name, beacon_item in pairs(data.raw.item) do
    local place_result = beacon_item.place_result
    local beacon_entity = data.raw.beacon[place_result]
    if beacon_entity then beacon_list[beacon_entity.name] = {item=beacon_item, beacon=beacon_entity} end
  end
  for name, beacon_entity in pairs(data.raw.beacon) do
    if beacon_list[beacon_entity.name] == nil then beacon_list[beacon_entity.name] = {beacon=beacon_entity} end
  end
  
  for name, pair in pairs(beacon_list) do
    if data.raw.beacon[name].selection_box then
      local strict = false
      if exclusion_range_values[name] == nil then exclusion_range_values[name] = distribution_range end
      if custom_exclusion_ranges[name] and custom_exclusion_ranges[name].mode ~= nil and custom_exclusion_ranges[name].mode == "strict" then strict = true end
      if no_stats[name] == nil then add_extended_description(name, pair, exclusion_range_values[name], strict) end
    end
  end
end

if mods["TarawindBeaconsRE"] or mods["TarawindBeaconsRE3x3"] then
  for tier=1,7,1 do
    if not startup["tarawind-reloaded-3x3mode"].value then data.raw.beacon["twBeacon" .. tostring(tier)].supply_area_distance = data.raw.beacon["twBeacon" .. tostring(tier)].supply_area_distance - 1 end -- removes temporary value
  end
end
