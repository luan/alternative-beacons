--- data.lua
--  available objects: data, mods, settings

local beacon_standard = require("prototypes/standard-beacon")
local beacon_focused = require("prototypes/focused-beacon")
local beacon_node = require("prototypes/node-beacon")
local beacon_conflux = require("prototypes/conflux-beacon")
local beacon_hub = require("prototypes/hub-beacon")
local beacon_isolation = require("prototypes/isolation-beacon")
local beacon_basic = require("prototypes/basic-beacon")
local beacon_compact = require("prototypes/compact-beacon")
local beacon_wide = require("prototypes/wide-beacon")
local do_new_technologies = false
startup = settings["startup"]

beacon_techs = {
  ["ab-standard-beacon"] = "effect-transmission",
  ["ab-focused-beacon"] = "effect-transmission",
  ["ab-node-beacon"] = "effect-transmission",
  ["ab-conflux-beacon"] = "ab-novel-effect-transmission",
  ["ab-hub-beacon"] = "ab-novel-effect-transmission",
  ["ab-isolation-beacon"] = "ab-novel-effect-transmission",
  ["se-basic-beacon"] = "effect-transmission",
  ["se-compact-beacon"] = "se-compact-beacon",
  ["se-wide-beacon"] = "se-wide-beacon",
  ["se-compact-beacon-2"] = "se-compact-beacon-2",
  ["se-wide-beacon-2"] = "se-wide-beacon-2",
  ["k2-singularity-beacon-2"] = "effect-transmission"
}
cancel_override = false

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

if (mods["pycoalprocessing"] or mods["space-exploration"] or mods["mini"] or mods["Custom-Mods"]) then cancel_override = true end

-- enables a separate version of "standard" beacons in some circumstances
if startup["ab-override-vanilla-beacons"].value and cancel_override == true then
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
  localise_new_beacon("ab-standard-beacon", "ab_standard", nil)
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
      ingredients = {{type = "item", name = "advanced-circuit", amount = 80}, {type = "item", name = "electronic-circuit", amount = 80}, {type = "item", name = "copper-cable", amount = 40}, {type = "item", name = "steel-plate", amount = 40}},
      normal = { result = "ab-node-beacon", enabled = false, energy_required = 30, ingredients = {{type = "item", name = "advanced-circuit", amount = 80}, {type = "item", name = "electronic-circuit", amount = 80}, {type = "item", name = "copper-cable", amount = 40}, {type = "item", name = "steel-plate", amount = 40}} },
      expensive = { result = "ab-node-beacon", enabled = false, energy_required = 30, ingredients = {{type = "item", name = "advanced-circuit", amount = 80}, {type = "item", name = "electronic-circuit", amount = 80}, {type = "item", name = "copper-cable", amount = 40}, {type = "item", name = "steel-plate", amount = 40}} }
    }
  })
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
      energy_required = 40,
      ingredients = {{type = "item", name = "advanced-circuit", amount = 200}, {type = "item", name = "electronic-circuit", amount = 200}, {type = "item", name = "copper-cable", amount = 100}, {type = "item", name = "steel-plate", amount = 100}},
      normal = { result = "ab-conflux-beacon", enabled = false, energy_required = 40, ingredients = {{type = "item", name = "advanced-circuit", amount = 200}, {type = "item", name = "electronic-circuit", amount = 200}, {type = "item", name = "copper-cable", amount = 100}, {type = "item", name = "steel-plate", amount = 100}} },
      expensive = { result = "ab-conflux-beacon", enabled = false, energy_required = 40, ingredients = {{type = "item", name = "advanced-circuit", amount = 200}, {type = "item", name = "electronic-circuit", amount = 200}, {type = "item", name = "copper-cable", amount = 100}, {type = "item", name = "steel-plate", amount = 100}} }
    }
  })
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
      energy_required = 50,
      ingredients = {{type = "item", name = "advanced-circuit", amount = 300}, {type = "item", name = "electronic-circuit", amount = 300}, {type = "item", name = "copper-cable", amount = 150}, {type = "item", name = "steel-plate", amount = 150}},
      normal = { result = "ab-hub-beacon", enabled = false, energy_required = 50, ingredients = {{type = "item", name = "advanced-circuit", amount = 300}, {type = "item", name = "electronic-circuit", amount = 300}, {type = "item", name = "copper-cable", amount = 150}, {type = "item", name = "steel-plate", amount = 150}} },
      expensive = { result = "ab-hub-beacon", enabled = false, energy_required = 50, ingredients = {{type = "item", name = "advanced-circuit", amount = 300}, {type = "item", name = "electronic-circuit", amount = 300}, {type = "item", name = "copper-cable", amount = 150}, {type = "item", name = "steel-plate", amount = 150}} }
    }
  })
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
  localise_new_beacon("ab-isolation-beacon", "ab_strict", nil)
end

-- enables beacons which emulate those from Space Exploration
if startup["ab-enable-se-beacons"].value and not mods["space-exploration"] then
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
  data.raw.recipe["se-compact-beacon-2"].ingredients = {{type = "item", name = "advanced-circuit", amount = 300}, {type = "item", name = "electronic-circuit", amount = 300}, {type = "item", name = "copper-cable", amount = 150}, {type = "item", name = "steel-plate", amount = 150}}
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
  data.raw.recipe["se-wide-beacon-2"].ingredients = {{type = "item", name = "advanced-circuit", amount = 600}, {type = "item", name = "electronic-circuit", amount = 600}, {type = "item", name = "copper-cable", amount = 300}, {type = "item", name = "steel-plate", amount = 300}}
  data.raw.item["se-wide-beacon-2"].order = "a[beacon]i5"
  data.raw.beacon["se-wide-beacon-2"].fast_replaceable_group = "wide-beacon"

  do_new_technologies = true
  if data.raw.technology["effect-transmission"] == nil or mods["Ultracube"] or mods["Satisfactorio"] then do_new_technologies = false end
  if do_new_technologies and data.raw.technology["effect-transmission"] then
    local tech_compact_1 = table.deepcopy(data.raw.technology["effect-transmission"])
    tech_compact_1.effects = {}
    tech_compact_1.prerequisites = {"effect-transmission", "utility-science-pack"}
    tech_compact_1.unit = {count=500, time=60, ingredients={{name="automation-science-pack", amount=1}, {name="logistic-science-pack", amount=1}, {name="chemical-science-pack", amount=1}, {name="production-science-pack", amount=1}, {name="utility-science-pack", amount=1}}}
    tech_compact_1.name = "se-compact-beacon"
    tech_compact_1.localised_name = {"name.se-compact-beacon"}
    tech_compact_1.localised_description = {"technology-description.se_compact"}
    tech_compact_1.order = tech_compact_1.order .. "y"

    local tech_compact_2 = table.deepcopy(tech_compact_1)
    tech_compact_2.prerequisites = {"se-compact-beacon", "space-science-pack"}
    tech_compact_2.unit = {count=1000, time=60, ingredients={{name="automation-science-pack", amount=1}, {name="logistic-science-pack", amount=1}, {name="chemical-science-pack", amount=1}, {name="production-science-pack", amount=1}, {name="utility-science-pack", amount=1}, {name="space-science-pack", amount=1}}}
    tech_compact_2.name = "se-compact-beacon-2"
    tech_compact_2.localised_name = {"name.se-compact-beacon-2"}
    tech_compact_2.localised_description = {"technology-description.se_compact_2"}
    tech_compact_2.order = tech_compact_1.order .. "z"

    local tech_wide_1 = table.deepcopy(tech_compact_1)
    tech_compact_1.prerequisites = {"effect-transmission", "utility-science-pack"}
    tech_wide_1.name = "se-wide-beacon"
    tech_wide_1.localised_name = {"name.se-wide-beacon"}
    tech_wide_1.localised_description = {"technology-description.se_wide"}

    local tech_wide_2 = table.deepcopy(tech_compact_2)
    tech_wide_2.prerequisites = {"se-wide-beacon", "space-science-pack"}
    tech_wide_2.name = "se-wide-beacon-2"
    tech_wide_2.localised_name = {"name.se-wide-beacon-2"}
    tech_wide_2.localised_description = {"technology-description.se_wide_2"}

    data:extend({tech_compact_1})
    data:extend({tech_wide_1})
    data:extend({tech_compact_2})
    data:extend({tech_wide_2})

    data.raw.beacon["se-compact-beacon"].next_upgrade = "se-compact-beacon-2"
    data.raw.beacon["se-wide-beacon"].next_upgrade = "se-wide-beacon-2"
  end
end

-- sets technologies for enabled beacons
if startup["ab-additional-technologies"].value then
  if data.raw.technology["effect-transmission"] and (data.raw.beacon["ab-conflux-beacon"] or data.raw.beacon["ab-hub-beacon"] or data.raw.beacon["ab-isolation-beacon"]) then
    local tech_novel = table.deepcopy(data.raw.technology["effect-transmission"])
    tech_novel.effects = {}
    tech_novel.prerequisites = {"effect-transmission", "effectivity-module-2", "speed-module-2"}
    tech_novel.unit.count = tech_novel.unit.count * 2
    tech_novel.order = tech_novel.order .. "x"
    tech_novel.name = "ab-novel-effect-transmission"
    tech_novel.localised_name = {"technology-name.effect_transmission_novel"}
    tech_novel.localised_description = {"technology-description.effect_transmission_novel"}
    data:extend({tech_novel})
  end
else
  beacon_techs["ab-conflux-beacon"] = "effect-transmission"
  beacon_techs["ab-hub-beacon"] = "effect-transmission"
  beacon_techs["ab-isolation-beacon"] = "effect-transmission"
end
if mods["pycoalprocessing"] then
  beacon_techs["ab-standard-beacon"] = "diet-beacon"
  beacon_techs["ab-focused-beacon"] = "diet-beacon"
  beacon_techs["ab-node-beacon"] = "diet-beacon"
  beacon_techs["se-basic-beacon"] = "diet-beacon"
  if startup["ab-additional-technologies"].value == false then
    beacon_techs["ab-conflux-beacon"] = "diet-beacon"
    beacon_techs["ab-hub-beacon"] = "diet-beacon"
    beacon_techs["ab-isolation-beacon"] = "diet-beacon"
  end
end
if mods["exotic-industries"] then
  if data.raw.technology["ab-novel-effect-transmission"] then
    data.raw.technology["ab-novel-effect-transmission"].unit.time = 20
    data.raw.technology["ab-novel-effect-transmission"].prerequisites = {"ei_copper-beacon", "effectivity-module-2", "speed-module-2"}
  end
  if do_new_technologies then
    data.raw.technology["se-compact-beacon"].prerequisites = {"ei_copper-beacon", "effectivity-module-2", "speed-module-2"}
    data.raw.technology["se-wide-beacon"].prerequisites = {"ei_copper-beacon", "effectivity-module-2", "speed-module-2"}
    data.raw.technology["se-compact-beacon-2"].prerequisites = {"se-compact-beacon", "ei_iron-beacon"}
    data.raw.technology["se-wide-beacon-2"].prerequisites = {"se-wide-beacon", "ei_iron-beacon"}
    data.raw.technology["se-compact-beacon"].unit = data.raw.technology["rocket-silo"].unit -- in between copper/iron beacon technologies (they may not exist until data-updates.lua)
    data.raw.technology["se-wide-beacon"].unit = data.raw.technology["rocket-silo"].unit
    data.raw.technology["se-compact-beacon-2"].unit = data.raw.technology["atomic-bomb"].unit -- same as iron beacon technology (it may not exist until data-updates.lua)
    data.raw.technology["se-wide-beacon-2"].unit = data.raw.technology["atomic-bomb"].unit
    data.raw.technology["se-compact-beacon"].unit.time = 20
    data.raw.technology["se-wide-beacon"].unit.time = 20
    data.raw.technology["se-compact-beacon-2"].unit.time = 20
    data.raw.technology["se-wide-beacon-2"].unit.time = 20
  end
end
if mods["nullius"] and data.raw.technology["effect-transmission"] then
  local techs = {"ab-novel-effect-transmission", "se-compact-beacon", "se-wide-beacon", "se-compact-beacon-2", "se-wide-beacon-2"}
  for i=1,#techs,1 do
    if data.raw.technology[ techs[i] ] then data.raw.technology[ techs[i] ].order = "nullius-" .. data.raw.technology[ techs[i] ].order end
  end
  local base_tech = data.raw.technology["effect-transmission"]
  base_tech.effects = {}
  base_tech.prerequisites = {"nullius-physics", "nullius-broadcasting-2"}
  base_tech.unit = {count=1200, time=40, ingredients={{name="nullius-climatology-pack", amount=1}, {name="nullius-electrical-pack", amount=1}, {name="nullius-physics-pack", amount=1}}}
  if data.raw.technology["ab-novel-effect-transmission"] then
    base_tech.order = "nullius-" .. base_tech.order
    data.raw.technology["ab-novel-effect-transmission"].unit = base_tech.unit
  else
    beacon_techs["ab-focused-beacon"] = "nullius-broadcasting-2"
    beacon_techs["ab-node-beacon"] = "nullius-broadcasting-2"
    beacon_techs["ab-conflux-beacon"] = "nullius-broadcasting-2"
    beacon_techs["ab-hub-beacon"] = "nullius-broadcasting-2"
    beacon_techs["ab-isolation-beacon"] = "nullius-broadcasting-2"
  end
  if do_new_technologies then
    base_tech.order = "nullius-" .. base_tech.order
    data.raw.technology["se-compact-beacon"].unit = {count=2500, time=50, ingredients={{name="nullius-climatology-pack", amount=1}, {name="nullius-electrical-pack", amount=1}, {name="nullius-physics-pack", amount=1}}}
    data.raw.technology["se-wide-beacon"].unit = {count=2500, time=50, ingredients={{name="nullius-climatology-pack", amount=1}, {name="nullius-electrical-pack", amount=1}, {name="nullius-physics-pack", amount=1}}}
    data.raw.technology["se-compact-beacon-2"].unit = {count=15000, time=60, ingredients={{name="nullius-climatology-pack", amount=1}, {name="nullius-electrical-pack", amount=1}, {name="nullius-physics-pack", amount=1}}}
    data.raw.technology["se-wide-beacon-2"].unit = {count=15000, time=60, ingredients={{name="nullius-climatology-pack", amount=1}, {name="nullius-electrical-pack", amount=1}, {name="nullius-physics-pack", amount=1}}}
    data.raw.technology["se-compact-beacon"].prerequisites = {"effect-transmission", "nullius-optimization-5"}
    data.raw.technology["se-wide-beacon"].prerequisites = {"effect-transmission", "nullius-optimization-5"}
    data.raw.technology["se-compact-beacon-2"].prerequisites = {"se-compact-beacon", "nullius-optimization-7"}
    data.raw.technology["se-wide-beacon-2"].prerequisites = {"se-wide-beacon", "nullius-optimization-7"}
  end
end
for name, tech in pairs(beacon_techs) do
  if data.raw.beacon[name] and data.raw.technology[tech] then table.insert( data.raw.technology[tech].effects, { type = "unlock-recipe", recipe = name } ) end
end
if data.raw.technology["effect-transmission"] then data.raw.technology["effect-transmission"].localised_description = {"technology-description.effect_transmission_default"} end

-- adjusts "standard" vanilla beacons
if cancel_override == false and data.raw.beacon.beacon.collision_box[2][1] == 1.2 and data.raw.beacon.beacon.supply_area_distance == 3 then data.raw.beacon.beacon.supply_area_distance = 3.05 end -- extends from edge of collision box (9x9) but visualized area is 0.25 tiles shorter in each direction
if cancel_override == false and data.raw.item.beacon.stack_size < 20 then data.raw.item.beacon.stack_size = 20 end
if mods["aai-industry"] then -- fixes a potential crash with Exotic Industries
  local beacon_recipe = data.raw.recipe.beacon
  if beacon_recipe and beacon_recipe.normal == nil then
    beacon_recipe.normal = {
      ingredients = beacon_recipe.ingredients,
      results = beacon_recipe.results,
      result = beacon_recipe.result,
      energy_required = beacon_recipe.energy_required,
      enabled = beacon_recipe.enabled
    }
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
    beacon["se_allow_in_space"] = true
    if (beacon.allowed_effects and (beacon.allowed_effects == "productivity" or (#beacon.allowed_effects == 1 and beacon.allowed_effects[1] == "productivity"))) then
      beacon.allowed_effects = {"productivity", "consumption"}
    end -- Space Exploration only checks non-productivity effects when validating space entities so at least one of those is required in addition to productivity
  end
end
