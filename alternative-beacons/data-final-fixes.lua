--- data-final-fixes.lua
--  should only make changes which cannot be made earlier due to other mod changes; changes should be for specific mods or mod combinations

local ingredient_multipliers = {
    ["ab-focused-beacon"] = 2,
    ["ab-node-beacon"] = 5,
    ["ab-conflux-beacon"] = 10,
    ["ab-hub-beacon"] = 20,
    ["ab-isolation-beacon"] = 20,
  }
beacon_exclusion_ranges = {}

local startup = settings.startup
local beacon = table.deepcopy(data.raw.beacon.beacon)

local function add_to_description(type, beacon, localised_string)
	if beacon.localised_description and beacon.localised_description ~= '' then
		beacon.localised_description = {'', beacon.localised_description, '\n', localised_string}
		return
	end
  if type == item then
    beacon.localised_description = {'?', {'', {'item-description.' .. beacon.name}, '\n', localised_string} }
  else
    beacon.localised_description = {'?', {'', {'entity-description.' .. beacon.name}, '\n', localised_string} }
  end
end

-- remakes an ingredient list with multiplied amounts
-- TODO: account for other possible ingredient variables (fluids and catalysts)
function match_ingredients(ingredients, new_ingredients, multiplier)
  local mult = multiplier
  for index, ingredient in pairs(ingredients) do
    multiplier = mult
    if (ingredient.type ~= nil and ingredient.name ~= nil and ingredient.amount ~= nil) then
      if ingredient.amount * multiplier > 400 then multiplier = multiplier / 2 end
      if multiplier > 5 and ingredient.amount * multiplier > 400 then multiplier = multiplier / 2 end
      table.insert(new_ingredients, {["type"] = ingredient.type, ["name"] = ingredient.name, ["amount"] = ingredient.amount * multiplier})
    elseif (ingredient.name ~= nil and ingredient.amount ~= nil) then
      if ingredient.amount * multiplier > 400 then multiplier = multiplier / 2 end
      if multiplier > 5 and ingredient.amount * multiplier > 400 then multiplier = multiplier / 2 end
      table.insert(new_ingredients, {["type"] = "item", ["name"] = ingredient.name, ["amount"] = ingredient.amount * multiplier})
    elseif #ingredient == 2 and type(ingredient[2]) == "number" then
      if ingredient[2] * multiplier > 400 then multiplier = multiplier / 2 end
      if multiplier > 5 and ingredient[2] * multiplier > 400 then multiplier = multiplier / 2 end
      table.insert(new_ingredients, {["type"] = "item", ["name"] = ingredient[1], ["amount"] = ingredient[2] * multiplier})
    end
  end
  do return new_ingredients end
end

-- adjusts recipes to use the same ingredient types as standard beacons (or another beacon if one is deemed more suitable for specific mods)
-- TODO: move to data-updates.lua and only do this again here if necessary (i.e. if other mods update recipes in their own data-updates.lua files)
if data.raw.recipe.beacon ~= nil then
  if startup["ab-update-recipes"].value then
    local common = "beacon"
    if mods["nullius"] then common = "nullius-beacon-3" end
    if mods["5dim_module"] or mods["OD27_5dim_module"] then common = "5d-beacon-02" end
    if mods["exotic-industries"] then
      common = "ei_copper-beacon"
      ingredient_multipliers["beacon"] = 1
    end
    if mods["pypostprocessing"] then
      common = "beacon-mk01"
      ingredient_multipliers["ab-standard-beacon"] = 1
    end
    if mods["Ultracube"] then
      common = "cube-beacon"
      ingredient_multipliers["beacon"] = 1
    end
    for beacon_name, multiplier in pairs(ingredient_multipliers) do
      if data.raw.recipe[beacon_name] ~= nil then
        local new_ingredients = {}
        local new_ingredients_normal = {}
        local new_ingredients_expensive = {}
        if data.raw.recipe[common].ingredients ~= nil then new_ingredients = match_ingredients(data.raw.recipe[common].ingredients, new_ingredients, multiplier) end
        if data.raw.recipe[common].normal ~= nil and data.raw.recipe[common].normal.ingredients ~= nil then new_ingredients_normal = match_ingredients(data.raw.recipe[common].normal.ingredients, new_ingredients_normal, multiplier) end
        if data.raw.recipe[common].expensive ~= nil and data.raw.recipe[common].expensive.ingredients ~= nil then new_ingredients_expensive = match_ingredients(data.raw.recipe[common].expensive.ingredients, new_ingredients_expensive, multiplier) end
        if #new_ingredients > 0 then data.raw.recipe[beacon_name].ingredients = new_ingredients else data.raw.recipe[beacon_name].ingredients = nil end
        if #new_ingredients_normal > 0 then data.raw.recipe[beacon_name].normal.ingredients = new_ingredients_normal else data.raw.recipe[beacon_name].normal = nil end
        if #new_ingredients_expensive > 0 then data.raw.recipe[beacon_name].expensive.ingredients = new_ingredients_expensive else data.raw.recipe[beacon_name].expensive = nil end
      end
    end
  end
end

-- override stats of vanilla beacons (again) for specific mods
if data.raw.item.beacon ~= nil and data.raw.beacon.beacon ~= nil then
  if mods["beacons"] then
    data.raw.item.beacon.localised_name = {"item-name.override-beacon"}
    data.raw.beacon.beacon.localised_name = {"entity-name.override-beacon"}
  end
  if (mods["space-exploration"] or mods["exotic-industries"]) then
    if startup["ab-override-vanilla-beacons"].value then
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
      if data.raw.recipe.beacon ~= nil then data.raw.recipe.beacon.localised_name = {"recipe-name.override-beacon"} end
      data.raw.item.beacon.localised_name = {"item-name.override-beacon"}
      data.raw.beacon.beacon.localised_name = {"entity-name.override-beacon"}
      data.raw.item.beacon.localised_description = {"item-description.override-beacon"}
      data.raw.beacon.beacon.localised_description = {"entity-description.override-beacon"}
      if data.raw.technology["effect-transmission"] ~= nil then data.raw.technology["effect-transmission"].localised_description = {"technology-description.override-effect-transmission"} end
    elseif mods["space-exploration"] then
      data.raw.item["beacon"].localised_description = {"item-description.se-standard-beacon-overload"}
      data.raw.beacon["beacon"].localised_description = {"entity-description.se-standard-beacon-overload"}
      beacon_exclusion_ranges["beacon"] = 11
    end
  end
end

-- adds extended stats to descriptions of standard beacons (again) for specific mods
if data.raw.item.beacon ~= nil and data.raw.beacon.beacon ~= nil then
  if mods["space-exploration"] or mods["exotic-industries"] then
    if startup["ab-show-extended-stats"] then
      if beacon_exclusion_ranges[beacon.name] == nil then beacon_exclusion_ranges[beacon.name] = math.ceil(get_distribution_range(beacon)) end
      if startup["ab-override-vanilla-beacons"].value == true then
        add_to_description("beacon", beacon, {"description.ab-module-slots", tostring(beacon.module_specification.module_slots), tostring(math.floor(100*beacon.distribution_effectivity*beacon.module_specification.module_slots)/100)})
        add_to_description("beacon", beacon, {"description.ab-distribution-range", tostring(math.ceil(get_distribution_range(beacon)))})
        if beacon_exclusion_ranges[beacon.name] == 11 then
          add_to_description("beacon", beacon, {"description.ab-exclusion-range-strict", tostring(beacon_exclusion_ranges[beacon.name])})
        else
          add_to_description("beacon", beacon, {"description.ab-exclusion-range", tostring(beacon_exclusion_ranges[beacon.name])})
        end
        add_to_description("beacon", beacon, {"description.ab-dimensions", tostring(math.ceil(beacon.selection_box[2][1] - beacon.selection_box[1][1]))})
      end
      local item = data.raw.item[beacon.name]
      if item ~= nil then
        add_to_description("item", item, {"description.ab-module-slots", tostring(beacon.module_specification.module_slots), tostring(math.floor(100*beacon.distribution_effectivity*beacon.module_specification.module_slots)/100)})
        add_to_description("item", item, {"description.ab-distribution-efficiency", tostring(beacon.distribution_effectivity)})
        add_to_description("item", item, {"description.ab-distribution-range", tostring(math.ceil(get_distribution_range(beacon)))})
        if beacon_exclusion_ranges[beacon.name] == 11 then
          add_to_description("item", item, {"description.ab-exclusion-range-strict", tostring(beacon_exclusion_ranges[beacon.name])})
        else
          add_to_description("item", item, {"description.ab-exclusion-range", tostring(beacon_exclusion_ranges[beacon.name])})
        end
        add_to_description("item", item, {"description.ab-dimensions", tostring(math.ceil(beacon.selection_box[2][1] - beacon.selection_box[1][1]))})
        add_to_description("item", item, {"description.ab-stack-size", tostring(item.stack_size)})
      end
      data.raw.item.beacon.localised_description = item.localised_description
      data.raw.beacon.beacon.localised_description = beacon.localised_description
    end
  end
end