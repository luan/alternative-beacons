--data-final-fixes.lua

local ingredient_multipliers = {
    ["beacon"] = 1,
    ["ab-focused-beacon"] = 2,
    ["ab-node-beacon"] = 5,
    ["ab-conflux-beacon"] = 10,
    ["ab-hub-beacon"] = 20,
    ["ab-isolation-beacon"] = 20
  }
  
local startup = settings.startup
local beacon = table.deepcopy(data.raw.beacon.beacon)

-- TODO: this version works for EI (in data-updates.lua too) but crashes for SE
if mods["exotic-industries"] then
  local common_beacon = "beacon"
  if mods["exotic-industries"] then common_beacon = "ei_copper-beacon" end
  local common = data.raw.recipe[common_beacon]
  for beacon_name, multiplier in pairs(ingredient_multipliers) do
    local current = data.raw.recipe[beacon_name]
    if common.ingredients ~= nil then
      for i, ingredient in pairs(common.ingredients) do
        if ingredient.amount ~= nil then
          current.ingredients[i] = ingredient
          current.ingredients[i].amount = ingredient.amount * multiplier
        else
          current.ingredients[i] = {["type"] = "item", ["name"] = ingredient[1], ["amount"] = ingredient[2]}
          current.ingredients[i].amount = ingredient[2] * multiplier
        end
      end
      data.raw.recipe[beacon_name].ingredients = current.ingredients
    else
      current.ingredients = nil
    end
    if common.normal ~= nil then
      for i, ingredient in pairs(common.normal.ingredients) do
        if ingredient.amount ~= nil then
          current.normal.ingredients[i] = ingredient
          current.normal.ingredients[i].amount = ingredient.amount * multiplier
        else
          current.normal.ingredients[i] = {["type"] = "item", ["name"] = ingredient[1], ["amount"] = ingredient[2]}
          current.normal.ingredients[i].amount = ingredient[2] * multiplier
        end
      end
      data.raw.recipe[beacon_name].normal.ingredients = current.normal.ingredients
    else
      current.normal = nil
    end
    if common.expensive ~= nil then
      for i, ingredient in pairs(common.expensive.ingredients) do
        if ingredient.amount ~= nil then
          current.expensive.ingredients[i] = ingredient
          current.expensive.ingredients[i].amount = ingredient.amount * multiplier
        else
          current.expensive.ingredients[i] = {["type"] = "item", ["name"] = ingredient[1], ["amount"] = ingredient[2]}
          current.expensive.ingredients[i].amount = ingredient[2] * multiplier
        end
      end
      data.raw.recipe[beacon_name].expensive.ingredients = current.expensive.ingredients
    else
      current.expensive = nil
    end
  end
end

-- adjust recipes to use the same ingredient types as standard beacons
-- TODO: Adjust to work in all cases: doesn't work for SE if it's in data-updates.lua instead
if not mods["pypostprocessing"] then
  local common = "beacon"
  if mods["nullius"] then common = "nullius-beacon-3" end
  if mods["exotic-industries"] then common = "ei_copper-beacon" end
  if startup["ab-update-recipes"].value then
    for beacon_name, multiplier in pairs(ingredient_multipliers) do
      local new_ingredients = {}
      local new_ingredients_normal = {}
      local new_ingredients_expensive = {}
      if data.raw.recipe[common].ingredients ~= nil then
        for index, ingredient in pairs(data.raw.recipe[common].ingredients) do
          if (ingredient.type ~= nil and ingredient.name ~= nil and ingredient.amount ~= nil) then
            table.insert(new_ingredients, {["type"] = ingredient.type, ["name"] = ingredient.name, ["amount"] = ingredient.amount*multiplier})
          elseif (ingredient.name ~= nil and ingredient.amount ~= nil) then
            table.insert(new_ingredients, {["type"] = "item", ["name"] = ingredient.name, ["amount"] = ingredient.amount*multiplier})
          end
        end
      end
      if data.raw.recipe[common].normal ~= nil and data.raw.recipe[common].normal.ingredients ~= nil then
        for index, ingredient in pairs(data.raw.recipe[common].normal.ingredients) do
          if (ingredient.type ~= nil and ingredient.name ~= nil and ingredient.amount ~= nil) then
            table.insert(new_ingredients_normal, {["type"] = ingredient.type, ["name"] = ingredient.name, ["amount"] = ingredient.amount*multiplier})
          elseif (ingredient.name ~= nil and ingredient.amount ~= nil) then
            table.insert(new_ingredients_normal, {["type"] = "item", ["name"] = ingredient.name, ["amount"] = ingredient.amount*multiplier})
          end
        end
      end
      if data.raw.recipe[common].expensive ~= nil and data.raw.recipe[common].expensive.ingredients ~= nil then
        for index, ingredient in pairs(data.raw.recipe[common].expensive.ingredients) do
          if (ingredient.type ~= nil and ingredient.name ~= nil and ingredient.amount ~= nil) then
            table.insert(new_ingredients_expensive, {["type"] = ingredient.type, ["name"] = ingredient.name, ["amount"] = ingredient.amount*multiplier})
          elseif (ingredient.name ~= nil and ingredient.amount ~= nil) then
            table.insert(new_ingredients_expensive, {["type"] = "item", ["name"] = ingredient.name, ["amount"] = ingredient.amount*multiplier})
          end
        end
      end
      if #new_ingredients > 0 then
        data.raw.recipe[beacon_name].ingredients = new_ingredients
        if #new_ingredients_normal == 0 then data.raw.recipe[beacon_name].normal = nil end
        if #new_ingredients_expensive == 0 then data.raw.recipe[beacon_name].expensive = nil end
      end
      if #new_ingredients_normal > 0 then
        data.raw.recipe[beacon_name].normal.ingredients = new_ingredients_normal
        if #new_ingredients == 0 then data.raw.recipe[beacon_name].ingredients = nil end
        if #new_ingredients_expensive == 0 then data.raw.recipe[beacon_name].expensive = nil end
      end
      if #new_ingredients_expensive > 0 then
        data.raw.recipe[beacon_name].expensive.ingredients = new_ingredients_expensive
        if #new_ingredients == 0 then data.raw.recipe[beacon_name].ingredients = nil end
        if #new_ingredients_normal == 0 then data.raw.recipe[beacon_name].normal = nil end
      end
    end
  end
end

-- override stats of vanilla beacons (again) for specific mods
if ((mods["Krastorio2"] and mods["space-exploration"]) or mods["exotic-industries"]) then
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
    data.raw.recipe.beacon.localised_name = {"recipe-name.override-beacon"}
    data.raw.item.beacon.localised_name = {"item-name.override-beacon"}
    data.raw.beacon.beacon.localised_name = {"entity-name.override-beacon"}
    data.raw.item.beacon.localised_description = {"item-description.override-beacon"}
    data.raw.beacon.beacon.localised_description = {"entity-description.override-beacon"}
    data.raw.technology["effect-transmission"].localised_description = {"technology-description.override-effect-transmission"}
  else
    data.raw.item["beacon"].localised_description = {"item-description.se-standard-beacon-overload"}
    data.raw.beacon["beacon"].localised_description = {"entity-description.se-standard-beacon-overload"}
  end
end