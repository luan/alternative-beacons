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
local do_se_technologies = false
startup = settings["startup"]

beacon_techs = {
  ["ab-standard-beacon"] = "effect-transmission",
  ["ab-focused-beacon"] = "effect-transmission",
  ["ab-node-beacon"] = "effect-transmission",
  ["ab-conflux-beacon"] = "effect-transmission",
  ["ab-hub-beacon"] = "effect-transmission",
  ["ab-isolation-beacon"] = "effect-transmission",
  ["se-basic-beacon"] = "effect-transmission",
  ["se-compact-beacon"] = "se-compact-beacon",
  ["se-wide-beacon"] = "se-wide-beacon",
  ["se-compact-beacon-2"] = "se-compact-beacon-2",
  ["se-wide-beacon-2"] = "se-wide-beacon-2",
  ["k2-singularity-beacon"] = "effect-transmission"
}
possible_techs = {"ab-novel-effect-transmission", "ab-medium-effect-transmission", "ab-long-effect-transmission", "ab-focused-beacon", "ab-node-beacon", "ab-conflux-beacon", "ab-hub-beacon", "ab-isolation-beacon"}
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
  recipe.results = {{type="item", name=name, amount=1}}
end

if (mods["pycoalprocessing"] or mods["space-exploration"] or mods["mini"] or mods["Custom-Mods"]) then cancel_override = true end

-- enables a separate version of "standard" beacons in some circumstances
if startup["ab-override-vanilla-beacons"].value and cancel_override == true then
  data:extend({beacon_standard.item})
  data:extend({beacon_standard.entity})
  data:extend({beacon_standard.recipe})
  localise_new_beacon("ab-standard-beacon", "ab_standard", nil)
end

-- enables new beacons from this mod
if startup["ab-enable-focused-beacons"].value then
  data:extend({beacon_focused.item})
  data:extend({beacon_focused.entity})
  data:extend({beacon_focused.recipe})
  localise_new_beacon("ab-focused-beacon", "ab_different", nil)
end
if startup["ab-enable-node-beacons"].value then
  data:extend({beacon_node.item})
  data:extend({beacon_node.entity})
  data:extend({beacon_node.recipe})
  localise_new_beacon("ab-node-beacon", "ab_same", nil)
end
if startup["ab-enable-conflux-beacons"].value then
  data:extend({beacon_conflux.item})
  data:extend({beacon_conflux.entity})
  data:extend({beacon_conflux.recipe})
  localise_new_beacon("ab-conflux-beacon", "ab_different", "ab_conflux_addon")
end
if startup["ab-enable-hub-beacons"].value then
  data:extend({beacon_hub.item})
  data:extend({beacon_hub.entity})
  data:extend({beacon_hub.recipe})
  localise_new_beacon("ab-hub-beacon", "ab_different", "ab_hub_addon")
end
if startup["ab-enable-isolation-beacons"].value then
  data:extend({beacon_isolation.item})
  data:extend({beacon_isolation.entity})
  data:extend({beacon_isolation.recipe})
  localise_new_beacon("ab-isolation-beacon", "ab_strict", nil)
end

-- enables beacons which emulate those from Space Exploration
if startup["ab-enable-se-beacons"].value and not mods["space-exploration"] then
  -- basic
  data:extend({beacon_basic.item})
  data:extend({beacon_basic.entity})
  data:extend({beacon_basic.recipe})
  localise_new_beacon("se-basic-beacon", "ab_strict", nil)
  -- compact
  data:extend({beacon_compact.item})
  data:extend({beacon_compact.entity})
  data:extend({beacon_compact.recipe})
  localise_new_beacon("se-compact-beacon", "ab_strict", nil)
  data.raw.beacon["se-compact-beacon"].fast_replaceable_group = "compact-beacon"
  -- compact 2
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
  -- wide
  data:extend({beacon_wide.item})
  data:extend({beacon_wide.entity})
  data:extend({beacon_wide.recipe})
  localise_new_beacon("se-wide-beacon", "ab_strict", nil)
  data.raw.beacon["se-wide-beacon"].fast_replaceable_group = "wide-beacon"
  -- wide 2
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
  data.raw.beacon["se-wide-beacon-2"].module_slots = 20
  data.raw.beacon["se-wide-beacon-2"].icons_positioning[1].max_icon_rows = 4
  data.raw.beacon["se-wide-beacon-2"].icons_positioning[1].multi_row_initial_height_modifier = -0.9
  data.raw.recipe["se-wide-beacon-2"].ingredients = {{type = "item", name = "advanced-circuit", amount = 600}, {type = "item", name = "electronic-circuit", amount = 600}, {type = "item", name = "copper-cable", amount = 300}, {type = "item", name = "steel-plate", amount = 300}}
  data.raw.item["se-wide-beacon-2"].order = "a[beacon]i5"
  data.raw.beacon["se-wide-beacon-2"].fast_replaceable_group = "wide-beacon"

  local technology = {
    {
      icon = "__alternative-beacons__/graphics/tech-compact-1.png",
      icon_size = 256
    },
  }

  -- sets technologies for SE-like beacons_count
  if data.raw.technology["effect-transmission"] == nil or mods["Ultracube"] or mods["Satisfactorio"] then do_se_technologies = false end
  if do_se_technologies and data.raw.technology["effect-transmission"] then
    local tech_compact_1 = table.deepcopy(data.raw.technology["effect-transmission"])
    tech_compact_1.effects = {}
    tech_compact_1.prerequisites = {"effect-transmission", "utility-science-pack"}
    tech_compact_1.unit = {count=500, time=60, ingredients={{name="automation-science-pack", amount=1}, {name="logistic-science-pack", amount=1}, {name="chemical-science-pack", amount=1}, {name="production-science-pack", amount=1}, {name="utility-science-pack", amount=1}}}
    tech_compact_1.name = "se-compact-beacon"
    tech_compact_1.localised_name = {"name.se-compact-beacon"}
    tech_compact_1.localised_description = {"technology-description.se_compact"}
    tech_compact_1.order = (tech_compact_1.order or "") .. "y"
    tech_compact_1.icons = beacon_compact.technology

    local tech_compact_2 = table.deepcopy(tech_compact_1)
    tech_compact_2.prerequisites = {"se-compact-beacon", "space-science-pack"}
    tech_compact_2.unit = {count=1000, time=60, ingredients={{name="automation-science-pack", amount=1}, {name="logistic-science-pack", amount=1}, {name="chemical-science-pack", amount=1}, {name="production-science-pack", amount=1}, {name="utility-science-pack", amount=1}, {name="space-science-pack", amount=1}}}
    tech_compact_2.name = "se-compact-beacon-2"
    tech_compact_2.localised_name = {"name.se-compact-beacon-2"}
    tech_compact_2.localised_description = {"technology-description.se_compact_2"}
    tech_compact_2.order = (tech_compact_1.order or "") .. "z"
    tech_compact_2.icons = {{icon = "__alternative-beacons__/graphics/tech-compact-2.png", icon_size = 256}}

    local tech_wide_1 = table.deepcopy(tech_compact_1)
    tech_compact_1.prerequisites = {"effect-transmission", "utility-science-pack"}
    tech_wide_1.name = "se-wide-beacon"
    tech_wide_1.localised_name = {"name.se-wide-beacon"}
    tech_wide_1.localised_description = {"technology-description.se_wide"}
    tech_wide_1.icons = beacon_wide.technology

    local tech_wide_2 = table.deepcopy(tech_compact_2)
    tech_wide_2.prerequisites = {"se-wide-beacon", "space-science-pack"}
    tech_wide_2.name = "se-wide-beacon-2"
    tech_wide_2.localised_name = {"name.se-wide-beacon-2"}
    tech_wide_2.localised_description = {"technology-description.se_wide_2"}
    tech_wide_2.icons = {{icon = "__alternative-beacons__/graphics/tech-wide-2.png", icon_size = 256}}

    data:extend({tech_compact_1})
    data:extend({tech_wide_1})
    data:extend({tech_compact_2})
    data:extend({tech_wide_2})

    data.raw.beacon["se-compact-beacon"].next_upgrade = "se-compact-beacon-2"
    data.raw.beacon["se-wide-beacon"].next_upgrade = "se-wide-beacon-2"
  end
end

local function create_technology(source, id, prerequisites, count_multiplier, order_addon, name, description)
  local new_tech = table.deepcopy(data.raw.technology[source])
  new_tech.effects = {}
  new_tech.prerequisites = prerequisites
  new_tech.unit.count = new_tech.unit.count * count_multiplier
  new_tech.order = (new_tech.order or "") .. order_addon
  new_tech.name = id
  if
    name == id then new_tech.localised_name = {"name." .. name}
  else
    new_tech.localised_name = {"technology-name." .. name}
  end
  new_tech.localised_description = {"technology-description." .. description}
  data:extend({new_tech})
end

-- sets technologies for enabled beacons
if data.raw.technology["effect-transmission"] then
  if startup["ab-technology-layout"].value == "tech-2" then
    if data.raw.beacon["ab-conflux-beacon"] or data.raw.beacon["ab-hub-beacon"] or data.raw.beacon["ab-isolation-beacon"] then
      create_technology("effect-transmission", "ab-novel-effect-transmission", {"effect-transmission", "efficiency-module-2", "speed-module-2"}, 2, "x", "effect_transmission_novel", "effect_transmission_novel")
      beacon_techs["ab-conflux-beacon"] = "ab-novel-effect-transmission"
      beacon_techs["ab-hub-beacon"] = "ab-novel-effect-transmission"
      beacon_techs["ab-isolation-beacon"] = "ab-novel-effect-transmission"
    end
  elseif startup["ab-technology-layout"].value == "tech-3" then
    local long_prerequisite = "effect-transmission"
    if data.raw.beacon["ab-node-beacon"] or data.raw.beacon["ab-conflux-beacon"] then
      create_technology("effect-transmission", "ab-medium-effect-transmission", {"effect-transmission"}, 1, "x1", "effect_transmission_medium_range", "effect_transmission_medium_range")
      long_prerequisite = "ab-medium-effect-transmission"
      beacon_techs["ab-node-beacon"] = "ab-medium-effect-transmission"
      beacon_techs["ab-conflux-beacon"] = "ab-medium-effect-transmission"
    end
    if data.raw.beacon["ab-hub-beacon"] or data.raw.beacon["ab-isolation-beacon"] then
      create_technology("effect-transmission", "ab-long-effect-transmission", {long_prerequisite, "efficiency-module-2", "speed-module-2"}, 1, "x2", "effect_transmission_long_range", "effect_transmission_long_range")
      beacon_techs["ab-hub-beacon"] = "ab-long-effect-transmission"
      beacon_techs["ab-isolation-beacon"] = "ab-long-effect-transmission"
    end
  elseif startup["ab-technology-layout"].value == "tech-4" then
    local new_beacons = {"focused", "node", "conflux", "hub", "isolation"}
    local tech_icons = {beacon_focused.technology, beacon_node.technology, beacon_conflux.technology, beacon_hub.technology, beacon_isolation.technology}
    for i=1,#new_beacons do
      local name = "ab-"..new_beacons[i].."-beacon"
      if data.raw.beacon[name] then
        local mult = 1
        if new_beacons[i] == "isolation" then mult = 2 end
        local prerequisites = {"effect-transmission"}
        if new_beacons[i] == "conflux" and data.raw.beacon["ab-node-beacon"] then prerequisites = {"ab-node-beacon"} end
        if new_beacons[i] == "hub" and data.raw.beacon["ab-focused-beacon"] then prerequisites = {"ab-focused-beacon"} end
        if i > 2 then
          table.insert(prerequisites, "efficiency-module-2")
          table.insert(prerequisites, "speed-module-2")
        end
        create_technology("effect-transmission", name, prerequisites, mult, "x"..i, name, name)
        beacon_techs[name] = name
        data.raw.technology[name].icons = tech_icons[i]
      end
    end
  end
end
if mods["pycoalprocessing"] then
  beacon_techs["ab-standard-beacon"] = "diet-beacon"
  beacon_techs["se-basic-beacon"] = "diet-beacon"
  if startup["ab-technology-layout"].value == "tech-1" then
    beacon_techs["ab-focused-beacon"] = "diet-beacon"
    beacon_techs["ab-node-beacon"] = "diet-beacon"
    beacon_techs["ab-conflux-beacon"] = "diet-beacon"
    beacon_techs["ab-hub-beacon"] = "diet-beacon"
    beacon_techs["ab-isolation-beacon"] = "diet-beacon"
  elseif startup["ab-technology-layout"].value == "tech-2" then
    beacon_techs["ab-focused-beacon"] = "diet-beacon"
    beacon_techs["ab-node-beacon"] = "diet-beacon"
  elseif startup["ab-technology-layout"].value == "tech-3" then
    beacon_techs["ab-focused-beacon"] = "diet-beacon"
  end
end
if mods["exotic-industries"] then
  for _,v in pairs(possible_techs) do
    if data.raw.technology[v] then
      data.raw.technology[v].unit.time = 20
      for index,prerequisite in pairs(data.raw.technology[v].prerequisites) do
        if prerequisite == "effect-transmission" then data.raw.technology[v].prerequisites[index] = "ei_copper-beacon" end
      end
    end
  end
  if do_se_technologies then
    data.raw.technology["se-compact-beacon"].prerequisites = {"ei_copper-beacon", "efficiency-module-2", "speed-module-2"}
    data.raw.technology["se-wide-beacon"].prerequisites = {"ei_copper-beacon", "efficiency-module-2", "speed-module-2"}
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
  local techs = {"ab-novel-effect-transmission", "ab-medium-effect-transmission", "ab-long-effect-transmission", "ab-focused-beacon", "ab-node-beacon", "ab-conflux-beacon", "ab-hub-beacon", "ab-isolation-beacon", "se-compact-beacon", "se-wide-beacon", "se-compact-beacon-2", "se-wide-beacon-2"}
  for i=1,#techs,1 do
    if data.raw.technology[ techs[i] ] then data.raw.technology[ techs[i] ].order = "nullius-" .. data.raw.technology[ techs[i] ].order end
  end
  local base_tech = data.raw.technology["effect-transmission"]
  base_tech.effects = {}
  base_tech.prerequisites = {"nullius-physics", "nullius-broadcasting-2"}
  base_tech.unit = {count=1200, time=40, ingredients={{name="nullius-climatology-pack", amount=1}, {name="nullius-electrical-pack", amount=1}, {name="nullius-physics-pack", amount=1}}}
  local separate_techs = false
  for _,v in pairs(possible_techs) do
    if data.raw.technology[v] then
      separate_techs = true
      data.raw.technology[v].unit = base_tech.unit
    end
  end
  if separate_techs then
    base_tech.order = "nullius-" .. base_tech.order
  else
    beacon_techs["ab-focused-beacon"] = "nullius-broadcasting-2"
    beacon_techs["ab-node-beacon"] = "nullius-broadcasting-2"
    beacon_techs["ab-conflux-beacon"] = "nullius-broadcasting-2"
    beacon_techs["ab-hub-beacon"] = "nullius-broadcasting-2"
    beacon_techs["ab-isolation-beacon"] = "nullius-broadcasting-2"
  end
  if do_se_technologies then
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
--if cancel_override == false and data.raw.beacon.beacon.collision_box[2][1] == 1.2 and data.raw.beacon.beacon.supply_area_distance == 3 then data.raw.beacon.beacon.supply_area_distance = 3.05 end -- extends from edge of collision box (9x9) but visualized area is 0.25 tiles shorter in each direction
if cancel_override == false and data.raw.item.beacon.stack_size < 20 then data.raw.item.beacon.stack_size = 20 end
if mods["aai-industry"] then -- fixes a potential crash with Exotic Industries
  local beacon_recipe = data.raw.recipe.beacon
  if beacon_recipe and beacon_recipe.normal == nil then
    beacon_recipe.normal = {
      ingredients = beacon_recipe.ingredients,
      results = beacon_recipe.results,
      energy_required = beacon_recipe.energy_required,
      enabled = beacon_recipe.enabled
    }
  end
end

-- warning/alert images for disabled beacons
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
-- images for informatron
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
