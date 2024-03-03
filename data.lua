--- data.lua
--  available objects: data, mods, settings

local beacon_focused = require("prototypes/focused-beacon")
local beacon_node = require("prototypes/node-beacon")
local beacon_conflux = require("prototypes/conflux-beacon")
local beacon_hub = require("prototypes/hub-beacon")
local beacon_isolation = require("prototypes/isolation-beacon")
local startup = settings.startup

-- enables "focused" beacons
if startup["ab-enable-focused-beacons"].value then
  data:extend({
    {
      type = "item",
      name = "ab-focused-beacon",
      place_result = "ab-focused-beacon",
      icon = "__alternative-beacons__/graphics/focused-beacon-icon.png",
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
end

-- enables "node" beacons
if startup["ab-enable-node-beacons"].value then
  data:extend({
    {
      type = "item",
      name = "ab-node-beacon",
      place_result = "ab-node-beacon",
      icon = "__alternative-beacons__/graphics/node-beacon-icon.png",
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
end

-- enables "conflux" beacons
if startup["ab-enable-conflux-beacons"].value then
  data:extend({
    {
      type = "item",
      name = "ab-conflux-beacon",
      place_result = "ab-conflux-beacon",
      icon = "__alternative-beacons__/graphics/conflux-beacon-icon.png",
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
end

-- enables "hub" beacons
if startup["ab-enable-hub-beacons"].value then
  data:extend({
    {
      type = "item",
      name = "ab-hub-beacon",
      place_result = "ab-hub-beacon",
      icon = "__alternative-beacons__/graphics/hub-beacon-icon.png",
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
end

-- enables "isolation" beacons
if startup["ab-enable-isolation-beacons"].value then
  data:extend({
    {
      type = "item",
      name = "ab-isolation-beacon",
      place_result = "ab-isolation-beacon",
      icon = "__alternative-beacons__/graphics/isolation-beacon-icon.png",
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
end

-- adjusts "standard" vanilla beacons
if data.raw.beacon.beacon.collision_box[2][1] == 1.2 and data.raw.beacon.beacon.supply_area_distance == 3 then data.raw.beacon.beacon.supply_area_distance = 3.05 end -- extends from edge of collision box (9x9) but visualized area is 0.25 tiles shorter in each direction
if data.raw.item.beacon.stack_size < 20 then data.raw.item.beacon.stack_size = 20 end
if data.raw.recipe.beacon and data.raw.recipe.beacon.normal == nil then
  data.raw.recipe.beacon.normal = {}
  data.raw.recipe.beacon.normal.result = data.raw.recipe.beacon.result
  data.raw.recipe.beacon.normal.enabled = data.raw.recipe.beacon.enabled
  data.raw.recipe.beacon.normal.energy_required = data.raw.recipe.beacon.energy_required
  data.raw.recipe.beacon.normal.ingredients = data.raw.recipe.beacon.ingredients
end


-- warning/alert images for disabled beacons
data:extend({
  {
    type = "sprite",
    name = "ab-beacon-offline",
    filename = "__alternative-beacons__/graphics/beacon-offline.png",
    size = 64,
    scale = 0.5
  },
  {
    type = "virtual-signal",
    name = "ab-beacon-offline",
    icon = "__alternative-beacons__/graphics/beacon-offline.png",
    icon_size = 64,
  }
})

-- fixes potential incompatibility between Space Exploration and other beacon mods such as 5Dim's and Advanced Modules
if mods["space-exploration"] then
  for i, beacon in pairs(data.raw.beacon) do
    beacon.se_allow_in_space = true
    if (beacon.allowed_effects and (beacon.allowed_effects == "productivity" or (#beacon.allowed_effects == 1 and beacon.allowed_effects[1] == "productivity"))) then
      beacon.allowed_effects = {"productivity", "consumption"}
    end -- Space Exploration only checks non-productivity effects when validating space entities so at least one of those is required in addition to productivity
  end
end