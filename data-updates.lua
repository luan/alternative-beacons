--- data-updates.lua

local custom_beacon_exclusion_ranges = { -- these beacons are given custom exclusion ranges: "strict" means the smallest exclusion range which is large enough to prevent them from synergizing with other beacons; the same values are also provided in control.lua
  ["se-compact-beacon"] = "strict",
  ["se-compact-beacon-2"] = "strict",
  ["se-wide-beacon"] = "strict",
  ["se-wide-beacon-2"] = "strict",
  ["ei_copper-beacon"] = "strict",
  ["ei_iron-beacon"] = "strict",
  ["el_ki_beacon_entity"] = "strict",
  ["fi_ki_beacon_entity"] = "strict",
  ["fu_ki_beacon_entity"] = "strict",
  ["productivity-beacon"] = 6,
  ["productivity-beacon-1"] = 5,
  ["productivity-beacon-2"] = 6,
  ["productivity-beacon-3"] = 7,
  ["speed-beacon-2"] = 8,
  ["speed-beacon-3"] = 11,
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
local beacon_exclusion_ranges = {
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


-- normalizes the distribution range for the given beacon using the given indent
function normalize_distribution_range(beacon, indent)
  if beacon.collision_box ~= nil and beacon.selection_box ~= nil then
    local collision_radius = (beacon.collision_box[2][1] - beacon.collision_box[1][1]) / 2 -- beacon's collision is assumed to be centered on its origin; standard format assumed (leftTop, rightBottom)
    local selection_radius = (beacon.selection_box[2][1] - beacon.selection_box[1][1]) / 2 -- selection box is assumed to be in full tiles
    local offset = selection_radius - collision_radius
    local new_range = math.min(64, math.ceil(beacon.supply_area_distance - offset) - indent + offset) -- may be visually misaligned if it actually gets minimized to 64
    if selection_radius < collision_radius then new_range = data.raw.beacon[beacon.name].supply_area_distance end
    if (beacon.name == "el_ki_beacon_entity" or beacon.name == "fu_ki_beacon_entity") then new_range = data.raw.beacon[beacon.name].supply_area_distance + 0.084 end -- manually adjusted since the normal method was breaking things (even though the visuals looked fine)
    if (beacon.name == "fi_ki_beacon_entity") then new_range = data.raw.beacon[beacon.name].supply_area_distance end
    data.raw.beacon[beacon.name].supply_area_distance = new_range
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
    local category_recipe = data.raw.recipe[anchor].category
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
        if order_recipe == "" then data.raw.recipe[beacons[i]].order = order_if_nil .. tostring(i) else data.raw.recipe[beacons[i]].order = filler .. tostring(i) end
        if order_item == "" then data.raw.item[beacons[i]].order = order_if_nil .. tostring(i) else data.raw.item[beacons[i]].order = filler .. tostring(i) end
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
  end
end

if mods["space-exploration"] then
  for i=1,#beacons,1 do
    if data.raw.beacon[beacons[i]] then
      --data.raw.beacon[beacons[i]].se_allow_in_space = true -- handled in data.lua
      if data.raw.item[beacons[i]].stack_size < data.raw.item["se-compact-beacon"].stack_size then data.raw.item[beacons[i]].stack_size = data.raw.item["se-compact-beacon"].stack_size end
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
    custom_beacon_exclusion_ranges["beacon"] = "strict"
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

if mods["pypostprocessing"] then
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
  if startup["ab-balance-other-beacons"].value then
    -- TODO: Balance?
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
  order_beacons("beacon", 2, "zx", "zx")
  data.raw.item["beacon"].localised_description = {"item-description.5dim-standard-beacon"}
  data.raw.beacon["beacon"].localised_description = {"entity-description.5dim-standard-beacon"}
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
    local kinds = {"speed", "productivity"}
    if mods["Advanced_Sky_Modules"] == nil then
      for index, kind in pairs(kinds) do
        data.raw.module["pure-" .. kind .. "-module-1"].effect[kind].bonus = data.raw.module[kind .. "-module"].effect[kind].bonus * 0.6
        for tier=2,6,1 do
          data.raw.module["pure-" .. kind .. "-module-" .. tostring(tier)].effect[kind].bonus = data.raw.module[kind .. "-module-" .. tostring(tier)].effect[kind].bonus * 0.6 -- pure speed/productivity modules originally matched the normal versions while also removing the negatives so there was no tradeoff; rebalanced to be 3/5 of the value instead
        end
      end
      data.raw.module["god-module"].effect = { consumption = {bonus=-0.15}, speed = {bonus=0.15}, productivity = {bonus=0.15}, pollution = {bonus=-0.15} } -- also reduced to 3/5 of previous values
    else
      for index, kind in pairs(kinds) do
        data.raw.module["pure-" .. kind .. "-module-1"].effect[kind].bonus = data.raw.module[kind .. "-module"].effect[kind].bonus
        for tier=2,6,1 do
          data.raw.module["pure-" .. kind .. "-module-" .. tostring(tier)].effect[kind].bonus = data.raw.module[kind .. "-module-" .. tostring(tier)].effect[kind].bonus -- "sky" versions simply match the normal values
        end
      end
      data.raw.module["effectivity-module-4"].effect.pollution.bonus = data.raw.module["effectivity-module"].effect.pollution.bonus * 4 -- fixes higher tier efficiency modules so they reduce pollution instead of increase it
      data.raw.module["effectivity-module-5"].effect.pollution.bonus = data.raw.module["effectivity-module"].effect.pollution.bonus * 5
      data.raw.module["effectivity-module-6"].effect.pollution.bonus = data.raw.module["effectivity-module"].effect.pollution.bonus * 6
      data.raw.module["god-module"].effect = { consumption = {bonus=-0.25}, speed = {bonus=0.25}, productivity = {bonus=0.25}, pollution = {bonus=-0.25} } -- reduced to match original version; fixes pollution so it gets reduced instead of increased
    end
  end
  data.raw.beacon["speed-beacon-1"].supply_area_distance = 6  -- TODO: add more functionality in control.lua so the setting which enables/disables balance changes can also correctly handle different ranges for entities with the same names (exclusion ranges are currently hardcoded based on item name)
  data.raw.beacon["speed-beacon-2"].supply_area_distance = 6
  data.raw.beacon["speed-beacon-3"].supply_area_distance = 6
  -- TODO: Balance more
end

if mods["248k"] then
  data.raw.item["el_ki_core_item"].localised_description = {"item-description.compatibility-el_ki_core_item"}
  data.raw.item["fi_ki_core_item"].localised_description = {"item-description.compatibility-fi_ki_core_item"}
  data.raw.item["fu_ki_core_item"].localised_description = {"item-description.compatibility-fu_ki_core_item"}
  if startup["ab-balance-other-beacons"].value then
    -- TODO: Make beacons "solo" if their efficiency is adjusted beyond a certain threshold in the settings and/or adjust default balance?
  end
end

if mods["IndustrialRevolution3"] then
  order_beacons("beacon", 1, "zz", "zz")
end

if mods["SeaBlock"] then
  order_beacons("beacon", 1, "a[beacon]-x", "a[beacon]-x")
end

if mods["bobmodules"] then
  -- same names as Endgame Extension and Beacon 2; beacon-2 has 6 range, 4 modules, and 0.75 efficiency; beacon-3 has 9 range, 6 modules, and 1.0 efficiency
  -- Balance: power requirements adjusted upward, efficiencies reduced, reduced range of beacon-2; they are still superior to node/conflux beacons, although they are at least somewhat comparable now
  if startup["ab-balance-other-beacons"].value then
    data.raw.beacon["beacon-2"].energy_usage = "3000kW"
    data.raw.beacon["beacon-2"].distribution_effectivity = 0.5
    data.raw.beacon["beacon-2"].supply_area_distance = 5
    data.raw.beacon["beacon-3"].energy_usage = "6000kW"
    data.raw.beacon["beacon-3"].distribution_effectivity = 0.5
    -- TODO: give beacon-3 an exclusion area of +2 or more
  end
end

if mods["EndgameExtension"] then
  -- same names as Bob's and Beacon 2; beacon-2 has 5 range, 0.75 efficiency, 3 module slots; beacon-3 has 7 range, 1.0 efficiency, 5 module slots; productivity-beacon has 3 range, 1.0 efficiency, 5 module slots
  -- Balance: beacon-2 changed to match Bob's version (slightly less module power)
  if startup["ab-balance-other-beacons"].value then
    data.raw.beacon["productivity-beacon"].allowed_effects = {"productivity", "consumption", "pollution", "speed"}
    data.raw.beacon["beacon-2"].distribution_effectivity = 0.5
    data.raw.beacon["beacon-2"].module_specification.module_slots = 4
    data.raw.beacon["beacon-3"].energy_usage = "1000kW"
    data.raw.beacon["beacon-3"].distribution_effectivity = 0.5
    -- TODO: give beacon-3 an exclusion area of +1 or more
  end
end

if mods["Beacon2"] then
  -- same name as Bob's and Endgame Extension; beacon-2 has 3 range, 0.5 efficiency, 4 module slots
  -- Balance: doesn't disable standard beacons or vice versa
  data.raw.item["beacon-2"].localised_description = {"item-description.compatibility-beacon-2-other"}
  data.raw.item["beacon-2"].localised_description = {"entity-description.compatibility-beacon-2-other"}
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
  -- beaconmk2 has 5 range, 0.5 efficiency, 4 module slots
end

if mods["beacons"] then
  data.raw.item["beacon2"].localised_description = {"item-description.compatibility-beacon3"}
  data.raw.beacon["beacon2"].localised_description = {"entity-description.compatibility-beacon3"}
  data.raw.item["beacon3"].localised_description = {"item-description.compatibility-beacon3"}
  data.raw.beacon["beacon3"].localised_description = {"entity-description.compatibility-beacon3"}
  -- beacon2 has 4 range, 0.75 efficiency, 4 module slots; beacon3 has 5 range, 1.0 efficiency, 6 module slots
  -- Balance: reduced efficiency, increased range
  if startup["ab-balance-other-beacons"].value then
    data.raw.beacon["beacon2"].distribution_effectivity = 0.5
    data.raw.beacon["beacon2"].supply_area_distance = 5
    data.raw.beacon["beacon3"].distribution_effectivity = 0.5
    data.raw.beacon["beacon3"].supply_area_distance = 6
    -- TODO: give beacon-3 an exclusion area of +2 or more
  end
end

if mods["TarawindBeaconsRE"] or mods["TarawindBeaconsRE3x3"] then
  -- TODO: Balance?
end

if mods["PowerCrystals"] then
  -- Balance: Power crystals don't interact with the exclusion system - they cannot be crafted or relocated so should be relatively powerful
end

if mods["Darkstar_utilities"] or mods["Darkstar_utilities_fixed"] then
  -- TODO: ?
end

if mods["starry-sakura"] then
  -- TODO: ?
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- adjustments for all mods
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

cancel_localisation = true
-- populate reference tables with repetitive info
for am=1,5,1 do
  for fm=1,5,1 do
    custom_beacon_exclusion_ranges["beacon-AM" .. am .. "-FM" .. fm] = "strict"
    custom_beacon_exclusion_ranges["diet-beacon-AM" .. am .. "-FM" .. fm] = "strict"
  end
end

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

-- normalize distribution ranges
for i, beacon in pairs(data.raw.beacon) do
  normalize_distribution_range(beacon, distribution_range_indent)
end

if ordered == false then order_beacons("beacon", 2, "a[beacon]x", "x") end

-- other customizations
for beacon_name, efficiency in pairs(custom_beacon_efficiency) do
  local beacon = data.raw.beacon[beacon_name]
  if beacon ~= nil then
    data.raw.beacon[beacon_name].distribution_effectivity = efficiency
  end
end

-- add visualization for beacons from other mods which use custom exclusion ranges
if beacon.collision_box ~= nil and beacon.selection_box ~= nil then
  for beacon_name, value in pairs(custom_beacon_exclusion_ranges) do
    local beacon = data.raw.beacon[beacon_name]
    if beacon ~= nil then
      local distribution_range = get_distribution_range(beacon)
      local strict_separation_distance = distribution_range + max_moduled_building_size-1
      local basic_separation_distance = 2*distribution_range + max_moduled_building_size-1
      local exclusion_range = value
      if value == "strict" then exclusion_range = strict_separation_distance
      elseif value == "basic" then exclusion_range = basic_separation_distance
      else exclusion_range = value - distribution_range_indent end
      beacon_exclusion_ranges[beacon_name] = math.ceil(exclusion_range)
      local scale_distrib = (2*distribution_range + 2*beacon.selection_box[2][1]) * 2 / 10 -- beacon's collision is assumed to be centered on its origin; standard format assumed (leftTop, rightBottom)
      local scale_exclude = (2*exclusion_range + 2*beacon.selection_box[2][1]) * 2 / 10 -- selection box is assumed to be in full tiles
      if beacon.supply_area_distance == 64 then scale_exclude = scale_exclude + 0.2 end -- attempt to correct visual range if the distribution range was artificially capped - this value is specific to the AM:FM beacon from Pyanodons
      local brv = {
        layers = {
          {filename = "__alternative-beacons__/graphics/visualization/brv-dist.png", size = {10, 10}, scale = scale_distrib, priority = "extra-high-no-scale"},
          {filename = "__alternative-beacons__/graphics/visualization/brv-full.png", size = {10, 10}, scale = scale_exclude, priority = "extra-high-no-scale"}
        }
      }
      data.raw.beacon[beacon_name].radius_visualisation_picture = brv
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
  if mods["pypostprocessing"] then beacon_exclusion_ranges["beacon"] = 72 end
  for name, beacon in pairs(data.raw.beacon) do
    if no_stats[name] == nil then
      if beacon_exclusion_ranges[beacon.name] == nil then beacon_exclusion_ranges[beacon.name] = math.ceil(get_distribution_range(beacon)) end
      if (beacon.name ~= "el_ki_beacon_entity" and beacon.name ~= "fi_ki_beacon_entity" and beacon.name ~= "fu_ki_beacon_entity") then
        add_to_description("beacon", beacon, {"description.ab-module-slots", tostring(beacon.module_specification.module_slots), tostring(math.floor(100*beacon.distribution_effectivity*beacon.module_specification.module_slots)/100)})
      end
      add_to_description("beacon", beacon, {"description.ab-distribution-range", tostring(math.ceil(get_distribution_range(beacon)))})
      if custom_beacon_exclusion_ranges[name] == "strict" then
        add_to_description("beacon", beacon, {"description.ab-exclusion-range-strict", tostring(beacon_exclusion_ranges[name])})
      elseif beacon.name ~= "ei_alien-beacon" then
        add_to_description("beacon", beacon, {"description.ab-exclusion-range", tostring(beacon_exclusion_ranges[name])})
      end
      -- TODO: Add (+X) to note the difference between distribution range and exclusion range? Or only include exclusion range line if it's different than distribution range?
      add_to_description("beacon", beacon, {"description.ab-dimensions", tostring(math.ceil(beacon.selection_box[2][1] - beacon.selection_box[1][1]))})
      local skip = false
      if mods["pypostprocessing"] and name == "beacon" then skip = true end
      if data.raw.item[beacon.name] ~= nil and skip == false then
        local item = data.raw.item[beacon.name]
        if (beacon.name ~= "el_ki_beacon_entity" and beacon.name ~= "fi_ki_beacon_entity" and beacon.name ~= "fu_ki_beacon_entity") then
          add_to_description("item", item, {"description.ab-module-slots", tostring(beacon.module_specification.module_slots), tostring(math.floor(100*beacon.distribution_effectivity*beacon.module_specification.module_slots)/100)})
        end
        add_to_description("item", item, {"description.ab-distribution-efficiency", tostring(beacon.distribution_effectivity)})
        add_to_description("item", item, {"description.ab-distribution-range", tostring(math.ceil(get_distribution_range(beacon)))})
        if custom_beacon_exclusion_ranges[beacon.name] == "strict" then
          add_to_description("item", item, {"description.ab-exclusion-range-strict", tostring(beacon_exclusion_ranges[name])})
        elseif beacon.name ~= "ei_alien-beacon" then
          add_to_description("item", item, {"description.ab-exclusion-range", tostring(beacon_exclusion_ranges[name])})
        end
        add_to_description("item", item, {"description.ab-dimensions", tostring(math.ceil(beacon.selection_box[2][1] - beacon.selection_box[1][1]))})
        add_to_description("item", item, {"description.ab-stack-size", tostring(item.stack_size)})
      end
    end
  end
  -- beacon items that don't have a corresponding beacon entity of the same name
  for name, item in pairs(data.raw.item) do
    if no_stats[name] == nil then
      local place_result = item.place_result
      local beacon = data.raw.beacon[place_result]
      if place_result and beacon and place_result ~= item.name then
        if (beacon.name ~= "el_ki_beacon_entity" and beacon.name ~= "fi_ki_beacon_entity" and beacon.name ~= "fu_ki_beacon_entity") then
          add_to_description("item", item, {"description.ab-module-slots", tostring(beacon.module_specification.module_slots), tostring(math.floor(100*beacon.distribution_effectivity*beacon.module_specification.module_slots)/100)})
        end
        add_to_description("item", item, {"description.ab-distribution-efficiency", tostring(beacon.distribution_effectivity)})
        add_to_description("item", item, {"description.ab-distribution-range", tostring(math.ceil(get_distribution_range(beacon)))})
        if custom_beacon_exclusion_ranges[place_result] == "strict" then
          add_to_description("item", item, {"description.ab-exclusion-range-strict", tostring(beacon_exclusion_ranges[name])})
        else
          add_to_description("item", item, {"description.ab-exclusion-range", tostring(beacon_exclusion_ranges[name])})
        end
        add_to_description("item", item, {"description.ab-dimensions", tostring(math.ceil(beacon.selection_box[2][1] - beacon.selection_box[1][1]))})
        add_to_description("item", item, {"description.ab-stack-size", tostring(item.stack_size)})
      end
    end
  end
end

-- TODO: If fewer than 10 modules and beacons/modules share a subcategory, separate beacons & modules onto their own rows
-- TODO: Add (optional?) warnings that alert players of disabled beacons