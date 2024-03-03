--- data-updates.lua

local custom_exclusion_ranges = { -- these beacons are given custom exclusion ranges: "strict" ranges disable beacons whose distribution areas overlap them, "solo" means the smallest range which is large enough to prevent synergy with other beacons; the same values are also provided in control.lua
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
  -- pyanodons AM-FM entries are added below
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
local max_moduled_building_size = 9 -- by default, rocket silo (9x9) is the largest building which can use modules

local cancel_override = false
local cancel_localisation = false
local ordered = false
local exclusion_range_values = { -- used internally; pre-populated entries are not given visualizations since they already have them
  ["ab-focused-beacon"] = 3,
  ["ab-conflux-beacon"] = 12,
  ["ab-hub-beacon"] = 34,
  ["ab-isolation-beacon"] = 68,
}

local beacon_standard = require("prototypes/standard-beacon")
local startup = settings.startup
local beacon = table.deepcopy(data.raw.beacon.beacon)


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- functions
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- aligns distribution ranges of all beacons using the given indent
function normalize_distribution_ranges(indent)
  for _, beacon in pairs(data.raw.beacon) do
    if (beacon.collision_box ~= nil and beacon.selection_box ~= nil and not (beacon.minable == nil and beacon.next_upgrade ~= nil)) then -- Note: the minable/next_upgrade case is related to an error with "PowerCrystals" and visual mods like "walkable-beacons" or "classic-beacon" (included so this mod doesn't get implicated as well)
      if (beacon.name ~= "el_ki_beacon_entity" and beacon.name ~= "fi_ki_beacon_entity" and beacon.name ~= "fu_ki_beacon_entity") then -- TODO: find out why these are different and if it can be fixed instead of having hardcoded values for them
        local collision_radius = (beacon.collision_box[2][1] - beacon.collision_box[1][1]) / 2 -- beacon's collision is assumed to be centered on its origin; standard format assumed (leftTop, rightBottom)
        local selection_radius = (beacon.selection_box[2][1] - beacon.selection_box[1][1]) / 2 -- selection box is assumed to be in full tiles
        local offset = selection_radius - collision_radius
        local new_range = math.min(64, math.ceil(beacon.supply_area_distance - offset) - indent + offset) -- may not be aligned with other beacons if the range is too close to the limit of 64
        if selection_radius < collision_radius then new_range = data.raw.beacon[beacon.name].supply_area_distance end
        data.raw.beacon[beacon.name].supply_area_distance = new_range
      end
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
  if mods["space-exploration"] then data.raw.beacon["ab-standard-beacon"].se_allow_in_space = true end
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
        if order_recipe == "" then data.raw.recipe[beacons[i]].order = order_if_nil .. tostring(i) else data.raw.recipe[beacons[i]].order = order_recipe .. filler .. tostring(i) end
        if order_item == "" then data.raw.item[beacons[i]].order = order_if_nil .. tostring(i) else data.raw.item[beacons[i]].order = order_item .. filler .. tostring(i) end
        if data.raw.item[beacons[i]].stack_size < data.raw.item[anchor].stack_size then data.raw.item[beacons[i]].stack_size = data.raw.item[anchor].stack_size end
      end
    end
    ordered = true
  end
end

local function add_to_description(type, beacon, localised_string)
	if beacon.localised_description and beacon.localised_description ~= '' then
		beacon.localised_description = {'', beacon.localised_description, '\n', localised_string} -- TODO: Should this also apply to beacons without descriptions? Are there any beacons without descriptions?
		return
	end
  if type == item then
    beacon.localised_description = {'?', {'', {'item-description.' .. beacon.name}, '\n', localised_string} }
  else
    beacon.localised_description = {'?', {'', {'entity-description.' .. beacon.name}, '\n', localised_string} }
  end
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- adjustments for specific mods
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


if mods["Krastorio2"] then
  if not mods["space-exploration"] then -- singularity beacons are disabled if SE is also active
    for i=1,#beacons,1 do
      if data.raw.beacon[beacons[i]] then
        if data.raw.item[beacons[i]].stack_size < data.raw.item["kr-singularity-beacon"].stack_size then data.raw.item[beacons[i]].stack_size = data.raw.item["kr-singularity-beacon"].stack_size end
      end
    end
    data.raw.item["beacon"].localised_description = {"item-description.kr-standard-beacon"}
    data.raw.beacon["beacon"].localised_description = {"entity-description.kr-standard-beacon"}
    cancel_localisation = true
  end
end

if mods["space-exploration"] then
  for i=1,#beacons,1 do
    if data.raw.beacon[beacons[i]] then
      if data.raw.item[beacons[i]].stack_size < data.raw.item["se-compact-beacon"].stack_size then data.raw.item[beacons[i]].stack_size = data.raw.item["se-compact-beacon"].stack_size end
    end
    for i, beacon in pairs(data.raw.beacon) do
      beacon.se_allow_in_space = true
    end
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
    custom_exclusion_ranges["beacon"] = {value = "solo", mode = "strict"}
  end
  -- TODO: Disable beacon overloading or limit it to compact/wide beacons
end

if mods["nullius"] then
  order_beacons("nullius-large-beacon-2", 2, "nullius-cx", "nullius-cx")
  for i=2,#beacons,1 do
    if data.raw.item[beacons[i]] then
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
  max_moduled_building_size = 11
  -- Note: beacon overloading seems to happen inconsistently in some cases when additional beacons are within 6 tiles but not affecting the machine due to their distribution ranges (different behavior depending on whether the machine or the additional beacon were placed last)
end

if mods["248k"] then
  -- beacons have 2/6/18 module slots and 3/4/5 range normally; with Space Exploration, they have 10/15/45 module slots and 5/9/18 range while each core has 5 module slots instead of 2 (they are changed back in data-final-fixes.lua)
  if not mods["space-exploration"] then
    data.raw.item["el_ki_core_item"].localised_description = {"item-description.compatibility-el_ki_core_item"}
    data.raw.item["fi_ki_core_item"].localised_description = {"item-description.compatibility-fi_ki_core_item"}
    data.raw.item["fu_ki_core_item"].localised_description = {"item-description.compatibility-fu_ki_core_item"}
    -- the usual normalization somehow prevents 248k's beacons from interacting with machines at the correct range even though the visualization appears correct; the KI1 and KI3 beacons have a lower apparent range so those can be increased for a better approximation; exclusion range visualizations are also adjusted further below
    if math.ceil(get_distribution_range(data.raw.beacon["el_ki_beacon_entity"])) == 3 then data.raw.beacon["el_ki_beacon_entity"].supply_area_distance = data.raw.beacon["el_ki_beacon_entity"].supply_area_distance + 0.075 end
    if math.ceil(get_distribution_range(data.raw.beacon["fu_ki_beacon_entity"])) == 3 then data.raw.beacon["fu_ki_beacon_entity"].supply_area_distance = data.raw.beacon["fu_ki_beacon_entity"].supply_area_distance + 0.075 end
  else
    -- beacons cannot be returned to their original stats here or in data-final-fixes.lua (the relevant changes are overridden) so they are instead made into "solo" beacons and disable each other to mimic their functionality under beacon overloading
    data.raw.item["el_ki_beacon_item"].localised_description = {"item-description.alternative-el_ki_beacon_item"}
    data.raw.item["fi_ki_beacon_item"].localised_description = {"item-description.alternative-fi_ki_beacon_item"}
    data.raw.item["fu_ki_beacon_item"].localised_description = {"item-description.alternative-fu_ki_beacon_item"}
    data.raw.beacon["el_ki_beacon_entity"].localised_description = {"entity-description.alternative-el_ki_beacon_entity"}
    data.raw.beacon["fi_ki_beacon_entity"].localised_description = {"entity-description.alternative-fi_ki_beacon_entity"}
    data.raw.beacon["fu_ki_beacon_entity"].localised_description = {"entity-description.alternative-fu_ki_beacon_entity"}
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
  end
end

if mods["pycoalprocessing"] then
    data.raw["technology"]["effect-transmission"].effects = {} -- TODO: remove recipes individually instead of resetting or just hide them?
    table.insert( data.raw["technology"]["effect-transmission"].effects, { type = "unlock-recipe", recipe = "beacon" } )
    enable_replacement_standard_beacon("diet-beacon", "a[beacon]a")
    order_beacons("beacon", 2, "a[beacon]x", "a[beacon]x")
    if data.raw.item["ab-standard-beacon"].stack_size < data.raw.item["beacon-mk01"].stack_size then data.raw.item["ab-standard-beacon"].stack_size = data.raw.item["beacon-mk01"].stack_size end
    for i=2,#beacons,1 do
      if data.raw.item[beacons[i]] then
        table.insert( data.raw["technology"]["diet-beacon"].effects, { type = "unlock-recipe", recipe = beacons[i] } )
      end
    end
    cancel_override = true
    data.raw.item["beacon"].localised_description = {"item-description.compatibility-beacon-AM1-FM1"}
    data.raw.technology["diet-beacon"].localised_name = {"technology-name.compatibility-diet-beacon"}
    data.raw.technology["diet-beacon"].localised_description = {"technology-description.compatibility-diet-beacon"}
    data.raw.technology["effect-transmission"].localised_description = {"technology-description.py-effect-transmission"}
    for am=1,5,1 do
      for fm=1,5,1 do
        data.raw.beacon["beacon-AM" .. tostring(am) .. "-FM" .. tostring(fm)].localised_description = {"entity-description.beacon-AM1-FM1"}
        data.raw.beacon["diet-beacon-AM" .. tostring(am) .. "-FM" .. tostring(fm)].localised_description = {"entity-description.diet-beacon-AM1-FM1"}
      end
    end
    exclusion_range_values["beacon"] = 72
    -- populate reference tables with repetitive info
    for am=1,5,1 do
      for fm=1,5,1 do
        custom_exclusion_ranges["beacon-AM" .. am .. "-FM" .. fm] = {value = "solo", mode = "strict"}
        custom_exclusion_ranges["diet-beacon-AM" .. am .. "-FM" .. fm] = {value = "solo", mode = "strict"}
      end
    end
end

if mods["Ultracube"] then
  for i=1,#beacons,1 do
    if data.raw.item[beacons[i]] then
      table.insert( data.raw["technology"]["cube-beacon"].effects, { type = "unlock-recipe", recipe = beacons[i] } )
      data.raw.beacon[beacons[i]].distribution_effectivity = data.raw.beacon[beacons[i]].distribution_effectivity * 0.2
    end
  end
  cancel_override = true
  data.raw.recipe["cube-beacon"].localised_name = {"recipe-name.compatibility-cube-beacon"}
  data.raw.item["cube-beacon"].localised_name = {"item-name.compatibility-cube-beacon"}
  data.raw.beacon["cube-beacon"].localised_name = {"entity-name.compatibility-cube-beacon"}
  data.raw["assembling-machine"]["cube-beacon-fluid-source"].localised_name = {"entity-name.compatibility-cube-beacon"}
  data.raw.item["cube-beacon"].localised_description = {"item-description.compatibility-cube-beacon"}
  data.raw.beacon["cube-beacon"].localised_description = {"entity-description.compatibility-cube-beacon"}
  data.raw["assembling-machine"]["cube-beacon-fluid-source"].localised_description = {"entity-description.compatibility-cube-beacon"}
  data.raw.technology["cube-beacon"].localised_description = {"technology-description.compatibility-cube-beacon"}
  -- TODO: Disable beacon overloading or limit it to arcane beacons
end

if mods["5dim_core"] or mods["OD27_5dim_core"] then
  order_beacons("beacon", 2, "x[beacon]x", "x")
  if not mods["pycoalprocessing"] then
    data.raw.item["beacon"].localised_description = {"item-description.5dim-standard-beacon"}
    data.raw.beacon["beacon"].localised_description = {"entity-description.5dim-standard-beacon"}
  end
  cancel_localisation = true
  -- Balance: rescaled linearly at +10% module power per tier; beacons with 3 range won't disable standard beacons and vice versa
  if ((mods["5dim_module"] or mods["OD27_5dim_module"]) and startup["ab-balance-other-beacons"].value) then
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

if mods["Advanced_Modules"] or mods["Advanced_Sky_Modules"] or mods["Advanced_beacons"] then
  -- same names used among these three mods; productivity beacons have 0.5/0.75/1.0 efficiency, 2/4/6 module slots, 3 range, and 480/240/120 kW power usage; speed beacons are the same except they have 6 range (in the "sky" version they have 1?/0.75/2 efficiency, 2/8/12 module slots, and 8/12/20 range); efficiency beacons have 1/2/4 efficiency, 2 module slots, 9/18/36 range, and 240/120/60 kW power usage
  local kinds = {"clean", "speed", "productivity"}
  for index, kind in pairs(kinds) do
    for tier=1,3,1 do
      data.raw.item[kind .. "-beacon-" .. tier].localised_description = {"item-description.compatibility-" .. kind .. "-beacon-1,2,3"}
      data.raw.beacon[kind .. "-beacon-" .. tier].localised_description = {"item-description.compatibility-" .. kind .. "-beacon-1,2,3"}
      data.raw.beacon[kind .. "-beacon-" .. tier].radius_visualisation_picture.filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png"
    end
  end
  data.raw.item["speed-beacon-1"].localised_description = {"item-description.compatibility-speed-beacon-1"} -- overrides the above descriptions (speed-beacon-1 doesn't have a wider exclusion area)
  data.raw.beacon["speed-beacon-1"].localised_description = {"item-description.compatibility-speed-beacon-1"}
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

if mods["IndustrialRevolution3"] then
  order_beacons("beacon", 1, "zz", "zz")
end

if mods["SeaBlock"] then
  order_beacons("beacon", 1, "a[beacon]-x", "a[beacon]-x")
end

if mods["bobmodules"] then
  -- same names as Endgame Extension and Beacon 2; beacon-2 has 6 range, 4 modules, and 0.75 efficiency; beacon-3 has 9 range, 6 modules, and 1.0 efficiency
  -- Balance: power requirements adjusted upward, efficiencies reduced, reduced range of beacon-2, beacon-3 given +2 exclusion range; they are still superior to node/conflux beacons, although they are at least somewhat comparable now
  if startup["ab-balance-other-beacons"].value then
    data.raw.beacon["beacon-2"].energy_usage = "3000kW"
    data.raw.beacon["beacon-2"].distribution_effectivity = 0.5
    data.raw.beacon["beacon-2"].supply_area_distance = 5
    data.raw.beacon["beacon-3"].energy_usage = "6000kW"
    data.raw.beacon["beacon-3"].distribution_effectivity = 0.5
  end
end

if mods["EndgameExtension"] then
  -- same names as Bob's and Beacon 2; beacon-2 has 5 range, 0.75 efficiency, 3 module slots; beacon-3 has 7 range, 1.0 efficiency, 5 module slots; productivity-beacon has 3 range, 1.0 efficiency, 5 module slots
  local beacons = {"beacon-2", "beacon-3", "productivity-beacon"}
  for index, name in pairs(beacons) do
    data.raw.recipe[name].order = "a[beacon]n2[" .. beacon.name .. "]"
    data.raw.item[name].order = "a[beacon]n2[" .. beacon.name .. "]"
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
end

if mods["Beacon2"] then
  -- same name as Bob's and Endgame Extension; beacon-2 has 3 range, 0.5 efficiency, 4 module slots
  data.raw.item["beacon-2"].localised_description = {"item-description.compatibility-beacon-2-other"}
  data.raw.item["beacon-2"].localised_description = {"entity-description.compatibility-beacon-2-other"}
  -- Balance: doesn't disable standard beacons or vice versa
end

if mods["FactorioExtended-Plus-Module"] then
  -- same names as Zombies Extended: beacon-mk2, beacon-mk3; beacons have 3 range and 2 module slots with 0.75 and 1.0 efficiency each
  -- Balance: these don't disable standard beacons or vice versa
end

if mods["zombiesextended-modules"] then
  -- same names as Factorio Extended: beacon-mk1, beacon-mk2, beacon-mk3; beacons have 3 range and 2 module slots with 1, 2, and 3 efficiency each
  -- Balance: rescaled to max out at 1 efficiency instead of 3 (similar to Factorio Extended); they don't disable standard beacons and vice versa
  if startup["ab-balance-other-beacons"].value then
    data.raw.beacon["beacon-mk1"].distribution_effectivity = 0.65
    data.raw.beacon["beacon-mk2"].distribution_effectivity = 0.8
    data.raw.beacon["beacon-mk3"].distribution_effectivity = 1
  end
end

if mods["BeaconMk2"] then
  data.raw.item["beaconmk2"].localised_description = {"item-description.compatibility-beaconmk2"}
  data.raw.beacon["beaconmk2"].localised_description = {"entity-description.compatibility-beaconmk2"}
  data.raw.recipe["beaconmk2"].order = "a[beacon]mk2"
  data.raw.item["beaconmk2"].order = "a[beacon]mk2"
  -- beaconmk2 has 5 range, 0.5 efficiency, 4 module slots
end

if mods["beacons"] then
  -- beacon2 has 4 range, 0.75 efficiency, 4 module slots; beacon3 has 5 range, 1.0 efficiency, 6 module slots
  for tier=2,3,1 do
    data.raw.item["beacon" .. tostring(tier)].localised_description = {"item-description.compatibility-beacon" .. tostring(tier)}
    data.raw.beacon["beacon" .. tostring(tier)].localised_description = {"entity-description.compatibility-beacon" .. tostring(tier)}
    data.raw.recipe["beacon" .. tostring(tier)].order = "a[beacon]n" .. tostring(tier)
    data.raw.item["beacon" .. tostring(tier)].order = "a[beacon]n" .. tostring(tier)
  end
  -- Balance: reduced efficiency, increased range
  if startup["ab-balance-other-beacons"].value then
    data.raw.beacon["beacon2"].distribution_effectivity = 0.5
    data.raw.beacon["beacon2"].supply_area_distance = 5
    data.raw.beacon["beacon3"].distribution_effectivity = 0.5
    data.raw.beacon["beacon3"].supply_area_distance = 6
    -- TODO: give beacon3 an exclusion area of +2 or more
  end
end

if mods["TarawindBeaconsRE"] or mods["TarawindBeaconsRE3x3"] then
  for tier=1,7,1 do
    data.raw.recipe["twBeacon" .. tostring(tier)].order = "a[beacon]tw" .. tostring(tier)
    data.raw.item["twBeacon" .. tostring(tier)].order = "a[beacon]tw" .. tostring(tier)
    data.raw.beacon["twBeacon" .. tostring(tier)].radius_visualisation_picture.filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png"
    data.raw.beacon["twBeacon" .. tostring(tier)].radius_visualisation_picture.size = {10, 10}
    -- TODO: Correct dimensions (says 3x3 even if they are 1x1)
  end
  if startup["ab-balance-other-beacons"].value then
    for tier=1,7,1 do
      data.raw.beacon["twBeacon" .. tostring(tier)].supply_area_distance = data.raw.beacon["twBeacon" .. tostring(tier)].module_specification.module_slots
      data.raw.beacon["twBeacon" .. tostring(tier)].distribution_effectivity = 0.3
    end
  end
end

if mods["PowerCrystals"] then
  -- Balance: Power crystals neither disable or get disabled by other beacons via the "exclusion area" system
end

if mods["Darkstar_utilities"] or mods["Darkstar_utilities_fixed"] then
  -- TODO: ?
end

if mods["starry-sakura"] then
  -- TODO: ?
end

if mods["mini-machines"] then
  -- TODO: ?
end

if mods["micro-machines"] then
  -- TODO: ?
end

if mods["EditorExtensions"] then
  -- TODO: disable exclusion area for data.raw.beacon["ee-super-beacon"]
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- adjustments for all mods
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- override stats of vanilla beacons
if startup["ab-override-vanilla-beacons"].value and cancel_override == false then
  if data.raw.recipe.beacon ~= nil and data.raw.item.beacon ~= nil and data.raw.beacon.beacon ~= nil and data.raw.technology["effect-transmission"] ~= nil then
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
    data.raw.beacon.beacon = beacon
    if data.raw.item.beacon.stack_size < 20 then data.raw.item.beacon.stack_size = 20 end
    if cancel_localisation == false then
      data.raw.recipe.beacon.localised_name = {"recipe-name.override-beacon"}
      data.raw.item.beacon.localised_name = {"item-name.override-beacon"}
      data.raw.beacon.beacon.localised_name = {"entity-name.override-beacon"}
      data.raw.item.beacon.localised_description = {"item-description.override-beacon"}
      data.raw.beacon.beacon.localised_description = {"entity-description.override-beacon"}
      data.raw.technology["effect-transmission"].localised_description = {"technology-description.override-effect-transmission"}
    end
  end
end

normalize_distribution_ranges(distribution_range_indent)

if ordered == false then order_beacons("beacon", 2, "a[beacon]x", "x") end

-- other customizations
for beacon_name, efficiency in pairs(custom_beacon_efficiency) do
  local beacon = data.raw.beacon[beacon_name]
  if beacon ~= nil then
    data.raw.beacon[beacon_name].distribution_effectivity = efficiency
  end
end

-- add visualization for beacons from other mods which use custom exclusion ranges; does not do error checking for invalid possibilities within custom_exclusion_ranges
if startup["ab-enable-exclusion-areas"].value then
  for name, range in pairs(custom_exclusion_ranges) do
    local beacon = data.raw.beacon[name]
    if beacon ~= nil and beacon.collision_box ~= nil and beacon.selection_box ~= nil then
      local distribution_range = get_distribution_range(beacon)
      local exclusion_range = range.value
      if range.value == "solo" then
        if range.mode == nil or range.mode == "basic" then
          exclusion_range = 2*distribution_range + max_moduled_building_size-1
        elseif range.mode == "strict" then
          exclusion_range = distribution_range + max_moduled_building_size-1
        end
      else
        exclusion_range = range.value - distribution_range_indent
      end
      exclusion_range_values[name] = math.ceil(exclusion_range)
      local width = beacon.selection_box[2][1] - beacon.selection_box[1][1] -- selection box is assumed to be in full tiles and at least as wide as the collision box; symmetry is assumed
      local scale_distrib = (2*distribution_range + width) * 2 / 10
      local scale_exclude = (2*exclusion_range + width) * 2 / 10
      if beacon.supply_area_distance == 64 then scale_exclude = scale_exclude + 0.2 end -- adjusts the visualization of the exclusion range if the distribution range is high enough to be artificially capped - this value is specific to the AM:FM beacon from Pyanodons but could also be decent for other beacons with the same issue
      if mods["248k"] and max_moduled_building_size == 9 and distribution_range_indent == 0.25 then
        if beacon.name == "el_ki_beacon_entity" and math.ceil(distribution_range) == 3 then scale_exclude = scale_exclude + 0.105 end
        if beacon.name == "fi_ki_beacon_entity" and math.ceil(distribution_range) == 4 then scale_exclude = scale_exclude + 0.04 end
        if beacon.name == "fu_ki_beacon_entity" and math.ceil(distribution_range) == 5 then scale_exclude = scale_exclude + 0.06 end
        if beacon.name == "el_ki_beacon_entity" and math.ceil(distribution_range) == 5 then scale_exclude = scale_exclude + 0.172 end
        if beacon.name == "fi_ki_beacon_entity" and math.ceil(distribution_range) == 9 then scale_exclude = scale_exclude + 0.01 end
        if beacon.name == "fu_ki_beacon_entity" and math.ceil(distribution_range) == 18 then scale_exclude = scale_exclude + 0.096 end
      end
      local brv = {
        layers = {
          {filename = "__alternative-beacons__/graphics/visualization/brv-dist.png", size = {10, 10}, scale = scale_distrib, priority = "extra-high-no-scale"},
          {filename = "__alternative-beacons__/graphics/visualization/brv-full.png", size = {10, 10}, scale = scale_exclude, priority = "extra-high-no-scale"}
        }
      }
      data.raw.beacon[name].radius_visualisation_picture = brv
    end
  end
end

-- adds extended stats to descriptions of beacons
-- TODO: Organize into a callable function with parameters so that mod-specific changes don't need to be included in multiple places
if startup["ab-show-extended-stats"] then
  local no_stats = {} -- stats aren't shown for the naturally-generated beacons from the Power Crystals mod or the inner part of KI cores
  for tier=1,3,1 do
    no_stats["model-power-crystal-productivity-" .. tier] = 0
    no_stats["model-power-crystal-effectivity-" .. tier] = 0
    no_stats["model-power-crystal-speed-" .. tier] = 0
    no_stats["base-power-crystal-" .. tier] = 0
    if tier <= 2 then
      no_stats["model-power-crystal-instability-" .. tier] = 0
      no_stats["base-power-crystal-negative-" .. tier] = 0
    end
  end
  no_stats["el_ki_core_slave_entity"] = 0
  no_stats["fi_ki_core_slave_entity"] = 0
  no_stats["fu_ki_core_slave_entity"] = 0
  for name, beacon in pairs(data.raw.beacon) do
    if no_stats[name] == nil then
      local distribution_range = math.ceil(get_distribution_range(beacon))
      if exclusion_range_values[beacon.name] == nil then exclusion_range_values[beacon.name] = distribution_range end
      if (beacon.name ~= "el_ki_beacon_entity" and beacon.name ~= "fi_ki_beacon_entity" and beacon.name ~= "fu_ki_beacon_entity") then
        add_to_description("beacon", beacon, {"description.ab-module-slots", tostring(beacon.module_specification.module_slots), tostring(math.floor(100*beacon.distribution_effectivity*beacon.module_specification.module_slots)/100)})
      end
      add_to_description("beacon", beacon, {"description.ab-distribution-range", tostring(distribution_range)})
      if exclusion_range_values[name] ~= distribution_range then
        if custom_exclusion_ranges[name] and custom_exclusion_ranges[name].mode ~= nil and custom_exclusion_ranges[name].mode == "strict" then
          add_to_description("beacon", beacon, {"description.ab-exclusion-range-strict", tostring(exclusion_range_values[name])})
        elseif beacon.name ~= "ei_alien-beacon" then
          add_to_description("beacon", beacon, {"description.ab-exclusion-range", tostring(exclusion_range_values[name])})
        end
      end
      if not mods["extended-descriptions"] then add_to_description("beacon", beacon, {"description.ab-dimensions", tostring(math.ceil(beacon.selection_box[2][1] - beacon.selection_box[1][1])), tostring(math.ceil(beacon.selection_box[2][2] - beacon.selection_box[1][2]))}) end
      local skip = false
      if mods["pycoalprocessing"] and name == "beacon" then skip = true end
      if data.raw.item[beacon.name] ~= nil and skip == false then
        local item = data.raw.item[beacon.name]
        if (beacon.name ~= "el_ki_beacon_entity" and beacon.name ~= "fi_ki_beacon_entity" and beacon.name ~= "fu_ki_beacon_entity") then
          add_to_description("item", item, {"description.ab-module-slots", tostring(beacon.module_specification.module_slots), tostring(math.floor(100*beacon.distribution_effectivity*beacon.module_specification.module_slots)/100)})
        end
        add_to_description("item", item, {"description.ab-distribution-efficiency", tostring(beacon.distribution_effectivity)})
        add_to_description("item", item, {"description.ab-distribution-range", tostring(distribution_range)})
        if exclusion_range_values[name] ~= distribution_range then
          if custom_exclusion_ranges[name] and custom_exclusion_ranges[beacon.name].mode ~= nil and custom_exclusion_ranges[beacon.name].mode == "strict" then
            add_to_description("item", item, {"description.ab-exclusion-range-strict", tostring(exclusion_range_values[name])})
          elseif beacon.name ~= "ei_alien-beacon" then
            add_to_description("item", item, {"description.ab-exclusion-range", tostring(exclusion_range_values[name])})
          end
        end
        if not mods["extended-descriptions"] then add_to_description("item", item, {"description.ab-stack-size", tostring(item.stack_size)}) end
      end   
    end
  end
  -- beacon items that don't have a corresponding beacon entity of the same name
  for name, item in pairs(data.raw.item) do
    if no_stats[name] == nil then
      local place_result = item.place_result
      local beacon = data.raw.beacon[place_result]
      if place_result and beacon and place_result ~= item.name then
        local distribution_range = math.ceil(get_distribution_range(beacon))
        if (beacon.name ~= "el_ki_beacon_entity" and beacon.name ~= "fi_ki_beacon_entity" and beacon.name ~= "fu_ki_beacon_entity") then
          add_to_description("item", item, {"description.ab-module-slots", tostring(beacon.module_specification.module_slots), tostring(math.floor(100*beacon.distribution_effectivity*beacon.module_specification.module_slots)/100)})
        end
        add_to_description("item", item, {"description.ab-distribution-efficiency", tostring(beacon.distribution_effectivity)})
        add_to_description("item", item, {"description.ab-distribution-range", tostring(distribution_range)})
        if exclusion_range_values[beacon.name] ~= distribution_range then
          if custom_exclusion_ranges[beacon.name] and custom_exclusion_ranges[place_result].mode ~= nil and custom_exclusion_ranges[place_result].mode == "strict" then
            add_to_description("item", item, {"description.ab-exclusion-range-strict", tostring(exclusion_range_values[beacon.name])})
          else
            add_to_description("item", item, {"description.ab-exclusion-range", tostring(exclusion_range_values[beacon.name])})
          end
        end
        if not mods["extended-descriptions"] then add_to_description("item", item, {"description.ab-stack-size", tostring(item.stack_size)}) end
      end
    end
  end
end

-- TODO: If fewer than 10 modules and beacons/modules share a subcategory, separate beacons & modules onto their own rows
-- TODO: Make alerts persist and add per-player settings to enable/disable them
-- TODO: Implement "ab-organize-groups" setting: Organize beacons into item groups if new groups were created by other mods: Advanced Modules, Bob's Modules, 5Dim's, Factorio Extended, etc
-- TODO: Update localised names/descriptions programmatically to dramatically reduce duplicated locale text and lua code