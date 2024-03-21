--- data.lua
--  available objects: data, mods, settings

local beacon_focused = require("prototypes/focused-beacon")
local beacon_node = require("prototypes/node-beacon")
local beacon_conflux = require("prototypes/conflux-beacon")
local beacon_hub = require("prototypes/hub-beacon")
local beacon_isolation = require("prototypes/isolation-beacon")
local beacon_basic = require("prototypes/basic-beacon")
local beacon_compact = require("prototypes/compact-beacon")
local beacon_wide = require("prototypes/wide-beacon")
local startup = settings.startup

function localise_new_beacon(name, description, addon)
  data.raw.item[name].localised_name = {"name." .. name}
  data.raw.recipe[name].localised_name = {"name." .. name}
  data.raw.beacon[name].localised_name = {"name." .. name}
  if addon ~= nil then
    data.raw.item[name].localised_description = {'?', {'', {"description." .. description}, ' ', {"description." .. addon}} }
    data.raw.beacon[name].localised_description = {'?', {'', {"description." .. description}, ' ', {"description." .. addon}} }
  else
    data.raw.item[name].localised_description = {"description." .. description}
    data.raw.beacon[name].localised_description = {"description." .. description}
  end
end

function rename_beacon(item, beacon, recipe, name)
  item.name = name
  item.place_result = name
  beacon.name = name
  beacon.minable.result = name
  recipe.name = name
  recipe.result = name
end

-- enables "focused" beacons
if startup["ab-enable-focused-beacons"].value then
  data:extend({
    {
      type = "item",
      name = "ab-focused-beacon",
      place_result = "ab-focused-beacon",
      icon = "__alternative-beacons__/graphics/icon-focused.png",
      icon_size = 64,
      stack_size = 20,
      subgroup = "module",
      order = "a[beacon]b"
    }
  })
  data:extend({beacon_focused})
  data:extend({
    {
      type = "recipe",
      name = "ab-focused-beacon",
      result = "ab-focused-beacon",
      enabled = false,
      energy_required = 20,
      ingredients = {{type = "item", name = "advanced-circuit", amount = 40}, {type = "item", name = "electronic-circuit", amount = 40}, {type = "item", name = "copper-cable", amount = 20}, {type = "item", name = "steel-plate", amount = 20}},
      normal = { result = "ab-focused-beacon", enabled = false, energy_required = 20, ingredients = {{type = "item", name = "advanced-circuit", amount = 40}, {type = "item", name = "electronic-circuit", amount = 40}, {type = "item", name = "copper-cable", amount = 20}, {type = "item", name = "steel-plate", amount = 20}} },
      expensive = { result = "ab-focused-beacon", enabled = false, energy_required = 20, ingredients = {{type = "item", name = "advanced-circuit", amount = 40}, {type = "item", name = "electronic-circuit", amount = 40}, {type = "item", name = "copper-cable", amount = 20}, {type = "item", name = "steel-plate", amount = 20}} }
    }
  })
  table.insert( data.raw["technology"]["effect-transmission"].effects, { type = "unlock-recipe", recipe = "ab-focused-beacon" } )
  localise_new_beacon("ab-focused-beacon", "ab_different", nil)
end

-- enables "node" beacons
if startup["ab-enable-node-beacons"].value then
  data:extend({
    {
      type = "item",
      name = "ab-node-beacon",
      place_result = "ab-node-beacon",
      icon = "__alternative-beacons__/graphics/icon-node.png",
      icon_size = 64,
      stack_size = 20,
      subgroup = "module",
      order = "a[beacon]c"
    }
  })
  data:extend({beacon_node})
  data:extend({
    {
      type = "recipe",
      name = "ab-node-beacon",
      result = "ab-node-beacon",
      enabled = false,
      energy_required = 30,
      ingredients = {{type = "item", name = "advanced-circuit", amount = 100}, {type = "item", name = "electronic-circuit", amount = 100}, {type = "item", name = "copper-cable", amount = 50}, {type = "item", name = "steel-plate", amount = 50}},
      normal = { result = "ab-node-beacon", enabled = false, energy_required = 30, ingredients = {{type = "item", name = "advanced-circuit", amount = 100}, {type = "item", name = "electronic-circuit", amount = 100}, {type = "item", name = "copper-cable", amount = 50}, {type = "item", name = "steel-plate", amount = 50}} },
      expensive = { result = "ab-node-beacon", enabled = false, energy_required = 30, ingredients = {{type = "item", name = "advanced-circuit", amount = 100}, {type = "item", name = "electronic-circuit", amount = 100}, {type = "item", name = "copper-cable", amount = 50}, {type = "item", name = "steel-plate", amount = 50}} }
    }
  })
  table.insert( data.raw["technology"]["effect-transmission"].effects, { type = "unlock-recipe", recipe = "ab-node-beacon" } )
  localise_new_beacon("ab-node-beacon", "ab_same", nil)
end

-- enables "conflux" beacons
if startup["ab-enable-conflux-beacons"].value then
  data:extend({
    {
      type = "item",
      name = "ab-conflux-beacon",
      place_result = "ab-conflux-beacon",
      icon = "__alternative-beacons__/graphics/icon-conflux.png",
      icon_size = 64,
      stack_size = 20,
      subgroup = "module",
      order = "a[beacon]d"
    }
  })
  data:extend({beacon_conflux})
  data:extend({
    {
      type = "recipe",
      name = "ab-conflux-beacon",
      result = "ab-conflux-beacon",
      enabled = false,
      energy_required = 45,
      ingredients = {{type = "item", name = "advanced-circuit", amount = 200}, {type = "item", name = "electronic-circuit", amount = 200}, {type = "item", name = "copper-cable", amount = 100}, {type = "item", name = "steel-plate", amount = 100}},
      normal = { result = "ab-conflux-beacon", enabled = false, energy_required = 45, ingredients = {{type = "item", name = "advanced-circuit", amount = 200}, {type = "item", name = "electronic-circuit", amount = 200}, {type = "item", name = "copper-cable", amount = 100}, {type = "item", name = "steel-plate", amount = 100}} },
      expensive = { result = "ab-conflux-beacon", enabled = false, energy_required = 45, ingredients = {{type = "item", name = "advanced-circuit", amount = 200}, {type = "item", name = "electronic-circuit", amount = 200}, {type = "item", name = "copper-cable", amount = 100}, {type = "item", name = "steel-plate", amount = 100}} }
    }
  })
  table.insert( data.raw["technology"]["effect-transmission"].effects, { type = "unlock-recipe", recipe = "ab-conflux-beacon" } )
  localise_new_beacon("ab-conflux-beacon", "ab_different", "ab_conflux_addon")
end

-- enables "hub" beacons
if startup["ab-enable-hub-beacons"].value then
  data:extend({
    {
      type = "item",
      name = "ab-hub-beacon",
      place_result = "ab-hub-beacon",
      icon = "__alternative-beacons__/graphics/icon-hub.png",
      icon_size = 64,
      stack_size = 20,
      subgroup = "module",
      order = "a[beacon]e"
    }
  })
  data:extend({beacon_hub})
  data:extend({
    {
      type = "recipe",
      name = "ab-hub-beacon",
      result = "ab-hub-beacon",
      enabled = false,
      energy_required = 60,
      ingredients = {{type = "item", name = "advanced-circuit", amount = 400}, {type = "item", name = "electronic-circuit", amount = 400}, {type = "item", name = "copper-cable", amount = 200}, {type = "item", name = "steel-plate", amount = 200}},
      normal = { result = "ab-hub-beacon", enabled = false, energy_required = 60, ingredients = {{type = "item", name = "advanced-circuit", amount = 400}, {type = "item", name = "electronic-circuit", amount = 400}, {type = "item", name = "copper-cable", amount = 200}, {type = "item", name = "steel-plate", amount = 200}} },
      expensive = { result = "ab-hub-beacon", enabled = false, energy_required = 60, ingredients = {{type = "item", name = "advanced-circuit", amount = 400}, {type = "item", name = "electronic-circuit", amount = 400}, {type = "item", name = "copper-cable", amount = 200}, {type = "item", name = "steel-plate", amount = 200}} }
    }
  })
  table.insert( data.raw["technology"]["effect-transmission"].effects, { type = "unlock-recipe", recipe = "ab-hub-beacon" } )
  localise_new_beacon("ab-hub-beacon", "ab_different", "ab_hub_addon")
end

-- enables "isolation" beacons
if startup["ab-enable-isolation-beacons"].value then
  data:extend({
    {
      type = "item",
      name = "ab-isolation-beacon",
      place_result = "ab-isolation-beacon",
      icon = "__alternative-beacons__/graphics/icon-isolation.png",
      icon_size = 64,
      stack_size = 20,
      subgroup = "module",
      order = "a[beacon]f"
    }
  })
  data:extend({beacon_isolation})
  data:extend({
    {
      type = "recipe",
      name = "ab-isolation-beacon",
      result = "ab-isolation-beacon", 
      enabled = false,
      energy_required = 60,
      ingredients = {{type = "item", name = "advanced-circuit", amount = 400}, {type = "item", name = "electronic-circuit", amount = 400}, {type = "item", name = "copper-cable", amount = 200}, {type = "item", name = "steel-plate", amount = 200}},
      normal = { result = "ab-isolation-beacon", enabled = false, energy_required = 60, ingredients = {{type = "item", name = "advanced-circuit", amount = 400}, {type = "item", name = "electronic-circuit", amount = 400}, {type = "item", name = "copper-cable", amount = 200}, {type = "item", name = "steel-plate", amount = 200}} },
      expensive = { result = "ab-isolation-beacon", enabled = false, energy_required = 60, ingredients = {{type = "item", name = "advanced-circuit", amount = 400}, {type = "item", name = "electronic-circuit", amount = 400}, {type = "item", name = "copper-cable", amount = 200}, {type = "item", name = "steel-plate", amount = 200}} }
    }
  })
  table.insert( data.raw["technology"]["effect-transmission"].effects, { type = "unlock-recipe", recipe = "ab-isolation-beacon" } )
  localise_new_beacon("ab-isolation-beacon", "ab_strict", nil)
end

-- enables beacons which emulate those from Space Exploration
if startup["ab-enable-se-beacons"].value then
  local do_new_technologies = true
  if mods["exotic-industries"] or mods["Ultracube"] or mods["Satisfactorio"] then do_new_technologies = false end
  if do_new_technologies and data.raw.technology["effect-transmission"] then
    local tech_compact_1 = table.deepcopy(data.raw.technology["effect-transmission"])
    tech_compact_1.effects = {}
    tech_compact_1.prerequisites = {"effect-transmission", "utility-science-pack"}
    tech_compact_1.unit = {count=500, time=60, ingredients={{name="automation-science-pack", amount=1}, {name="logistic-science-pack", amount=1}, {name="chemical-science-pack", amount=1}, {name="production-science-pack", amount=1}, {name="utility-science-pack", amount=1}}}
    tech_compact_1.name = "se-compact-beacon"
    tech_compact_1.localised_name = {"name.se-compact-beacon"}
    tech_compact_1.localised_description = {"technology-description.se_compact"}

    local tech_compact_2 = table.deepcopy(tech_compact_1)
    tech_compact_2.prerequisites = {"se-compact-beacon", "space-science-pack"}
    tech_compact_2.unit = {count=1000, time=60, ingredients={{name="automation-science-pack", amount=1}, {name="logistic-science-pack", amount=1}, {name="chemical-science-pack", amount=1}, {name="production-science-pack", amount=1}, {name="utility-science-pack", amount=1}, {name="space-science-pack", amount=1}}}
    tech_compact_2.name = "se-compact-beacon-2"
    tech_compact_2.localised_name = {"name.se-compact-beacon-2"}
    tech_compact_2.localised_description = {"technology-description.se_compact_2"}

    local tech_wide_1 = table.deepcopy(tech_compact_1)
    tech_compact_1.prerequisites = {"effect-transmission", "utility-science-pack"}
    tech_wide_1.name = "se-wide-beacon"
    tech_wide_1.localised_name = {"name.se-wide-beacon"}
    tech_wide_1.localised_description = {"technology-description.se_wide"}
    
    local tech_wide_2 = table.deepcopy(tech_compact_2)
    tech_compact_2.prerequisites = {"se-wide-beacon", "space-science-pack"}
    tech_wide_2.name = "se-wide-beacon-2"
    tech_wide_2.localised_name = {"name.se-wide-beacon-2"}
    tech_wide_2.localised_description = {"technology-description.se_wide_2"}

    data:extend({tech_compact_1})
    data:extend({tech_compact_2})
    data:extend({tech_wide_1})
    data:extend({tech_wide_2})
  end

  local item_basic = {
    type = "item",
    name = "se-basic-beacon",
    place_result = "se-basic-beacon",
    icon = "__base__/graphics/icons/beacon.png",
    icon_size = 64,
    stack_size = 25,
    subgroup = "module",
    order = "a[beacon]i1"
  }
  local recipe_basic = {
    type = "recipe",
    name = "se-basic-beacon",
    result = "se-basic-beacon",
    enabled = false,
    energy_required = 10,
    ingredients = {{type = "item", name = "advanced-circuit", amount = 60}, {type = "item", name = "electronic-circuit", amount = 60}, {type = "item", name = "copper-cable", amount = 30}, {type = "item", name = "steel-plate", amount = 30}},
  }
  data:extend({item_basic})
  data:extend({beacon_basic})
  data:extend({recipe_basic})
  table.insert( data.raw["technology"]["effect-transmission"].effects, { type = "unlock-recipe", recipe = "se-basic-beacon" } )
  localise_new_beacon("se-basic-beacon", "ab_strict", nil)

  local item_compact = {
    type = "item",
    name = "se-compact-beacon",
    place_result = "se-compact-beacon",
    icon = "__alternative-beacons__/graphics/icon-compact-1.png",
    icon_size = 64,
    stack_size = 25,
    subgroup = "module",
    order = "a[beacon]i2"
  }
  local recipe_compact = {
    type = "recipe",
    name = "se-compact-beacon",
    result = "se-compact-beacon",
    enabled = false,
    energy_required = 10,
    ingredients = {{type = "item", name = "advanced-circuit", amount = 200}, {type = "item", name = "electronic-circuit", amount = 200}, {type = "item", name = "copper-cable", amount = 100}, {type = "item", name = "steel-plate", amount = 100}}
  }
  data:extend({item_compact})
  data:extend({beacon_compact})
  data:extend({recipe_compact})
  localise_new_beacon("se-compact-beacon", "ab_strict", nil)
  data.raw.beacon["se-compact-beacon"].fast_replaceable_group = "compact-beacon"

  local item_compact_2 = table.deepcopy(data.raw.item["se-compact-beacon"])
  local beacon_compact_2 = table.deepcopy(data.raw.beacon["se-compact-beacon"])
  local recipe_compact_2 = table.deepcopy(data.raw.recipe["se-compact-beacon"])
  rename_beacon(item_compact_2, beacon_compact_2, recipe_compact_2, "se-compact-beacon-2")
  item_compact_2.icon = "__alternative-beacons__/graphics/icon-compact-2.png"
  beacon_compact_2.graphics_set.animation_list[1].animation.layers[1].filename = "__alternative-beacons__/graphics/sr-compact-2-base.png"
  beacon_compact_2.graphics_set.animation_list[1].animation.layers[1].hr_version.filename = "__alternative-beacons__/graphics/hr-compact-2-base.png"
  data:extend({item_compact_2})
  data:extend({beacon_compact_2})
  data:extend({recipe_compact_2})
  localise_new_beacon("se-compact-beacon-2", "ab_strict", nil)
  data.raw.beacon["se-compact-beacon-2"].distribution_effectivity = 1
  data.raw.beacon["se-compact-beacon-2"].ingredients = {{type = "item", name = "advanced-circuit", amount = 300}, {type = "item", name = "electronic-circuit", amount = 300}, {type = "item", name = "copper-cable", amount = 150}, {type = "item", name = "steel-plate", amount = 150}}
  data.raw.item["se-compact-beacon-2"].order = "a[beacon]i4"
  data.raw.beacon["se-compact-beacon-2"].fast_replaceable_group = "compact-beacon"

  local item_wide = {
    type = "item",
    name = "se-wide-beacon",
    place_result = "se-wide-beacon",
    icon = "__alternative-beacons__/graphics/icon-wide-1.png",
    icon_size = 64,
    stack_size = 25,
    subgroup = "module",
    order = "a[beacon]i3"
  }
  local recipe_wide = {
    type = "recipe",
    name = "se-wide-beacon",
    result = "se-wide-beacon",
    enabled = false,
    energy_required = 10,
    ingredients = {{type = "item", name = "advanced-circuit", amount = 400}, {type = "item", name = "electronic-circuit", amount = 400}, {type = "item", name = "copper-cable", amount = 200}, {type = "item", name = "steel-plate", amount = 200}}
  }
  data:extend({item_wide})
  data:extend({beacon_wide})
  data:extend({recipe_wide})
  localise_new_beacon("se-wide-beacon", "ab_strict", nil)
  data.raw.beacon["se-wide-beacon"].fast_replaceable_group = "wide-beacon"

  local item_wide_2 = table.deepcopy(data.raw.item["se-wide-beacon"])
  local beacon_wide_2 = table.deepcopy(data.raw.beacon["se-wide-beacon"])
  local recipe_wide_2 = table.deepcopy(data.raw.recipe["se-wide-beacon"])
  rename_beacon(item_wide_2, beacon_wide_2, recipe_wide_2, "se-wide-beacon-2")
  item_wide_2.icon = "__alternative-beacons__/graphics/icon-wide-2.png"
  beacon_wide_2.graphics_set.animation_list[1].animation.filename = "__alternative-beacons__/graphics/hr-wide-2-off.png"
  beacon_wide_2.graphics_set.animation_list[2].animation.filename = "__alternative-beacons__/graphics/hr-wide-2-animated.png"
  data:extend({item_wide_2})
  data:extend({beacon_wide_2})
  data:extend({recipe_wide_2})
  localise_new_beacon("se-wide-beacon-2", "ab_strict", nil)
  data.raw.beacon["se-wide-beacon-2"].module_specification.module_slots = 20
  data.raw.beacon["se-wide-beacon-2"].module_specification.module_info_max_icon_rows = 4
  data.raw.beacon["se-wide-beacon-2"].module_specification.module_info_multi_row_initial_height_modifier = -0.9
  data.raw.beacon["se-wide-beacon-2"].ingredients = {{type = "item", name = "advanced-circuit", amount = 600}, {type = "item", name = "electronic-circuit", amount = 600}, {type = "item", name = "copper-cable", amount = 300}, {type = "item", name = "steel-plate", amount = 300}}
  data.raw.item["se-wide-beacon-2"].order = "a[beacon]i5"
  data.raw.beacon["se-wide-beacon-2"].fast_replaceable_group = "wide-beacon"

  if do_new_technologies and data.raw.technology["effect-transmission"] then
    table.insert( data.raw["technology"]["se-compact-beacon"].effects, { type = "unlock-recipe", recipe = "se-compact-beacon" } )
    table.insert( data.raw["technology"]["se-wide-beacon"].effects, { type = "unlock-recipe", recipe = "se-wide-beacon" } )
    table.insert( data.raw["technology"]["se-compact-beacon-2"].effects, { type = "unlock-recipe", recipe = "se-compact-beacon-2" } )
    table.insert( data.raw["technology"]["se-wide-beacon-2"].effects, { type = "unlock-recipe", recipe = "se-wide-beacon-2" } )
    data.raw.beacon["se-compact-beacon"].next_upgrade = "se-compact-beacon-2"
    data.raw.beacon["se-wide-beacon"].next_upgrade = "se-wide-beacon-2"
  end
end

-- adjusts "standard" vanilla beacons
if data.raw.beacon.beacon.collision_box[2][1] == 1.2 and data.raw.beacon.beacon.supply_area_distance == 3 then data.raw.beacon.beacon.supply_area_distance = 3.05 end -- extends from edge of collision box (9x9) but visualized area is 0.25 tiles shorter in each direction
if data.raw.item.beacon.stack_size < 20 then data.raw.item.beacon.stack_size = 20 end
if mods["aai-industry"] then -- fixes a potential crash with Exotic Industries
  if data.raw.recipe.beacon ~= nil and data.raw.recipe.beacon.normal == nil then
    data.raw.recipe.beacon.normal = {}
    data.raw.recipe.beacon.normal.result = data.raw.recipe.beacon.result
    data.raw.recipe.beacon.normal.enabled = data.raw.recipe.beacon.enabled
    data.raw.recipe.beacon.normal.energy_required = data.raw.recipe.beacon.energy_required
    data.raw.recipe.beacon.normal.ingredients = data.raw.recipe.beacon.ingredients
  end
end

-- warning/alert images for disabled beacons and images for informatron
data:extend({
  {
    type = "sprite",
    name = "ab_beacon_offline",
    filename = "__alternative-beacons__/graphics/beacon-offline.png",
    size = 64
  },
  {
    type = "virtual-signal",
    name = "ab_beacon_offline",
    icon = "__alternative-beacons__/graphics/beacon-offline.png",
    icon_size = 64,
    localised_name = {"description.ab_beacon_deactivated"}
  }
})

if mods["informatron"] then
  data:extend({
    {
      type = "sprite",
      name = "ab_informatron_1",
      filename = "__alternative-beacons__/graphics/hr-wide-1-off.png",
      size = {191, 335},
      scale = 0.5
    }
  })
end

-- fixes potential incompatibility between Space Exploration and other beacon mods such as 5Dim's and Advanced Modules
if mods["space-exploration"] then
  for i, beacon in pairs(data.raw.beacon) do
    beacon.se_allow_in_space = true
    if (beacon.allowed_effects and (beacon.allowed_effects == "productivity" or (#beacon.allowed_effects == 1 and beacon.allowed_effects[1] == "productivity"))) then
      beacon.allowed_effects = {"productivity", "consumption"}
    end -- Space Exploration only checks non-productivity effects when validating space entities so at least one of those is required in addition to productivity
  end
end
