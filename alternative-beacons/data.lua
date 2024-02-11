--data.lua

-- enables "focused" beacons
if settings.startup["ab-enable-focused-beacons"].value then
  data:extend({
    {
      type = "item",
      name = "ab-focused-beacon",
      place_result = "ab-focused-beacon",
      icon = "__alternative-beacons__/graphics/focused-beacon-icon.png",
      icon_size = 64,
      stack_size = 10,
      subgroup = "module",
      order = "a[beacon]b"
    }
  })
  require("prototypes/focused-beacon")
  data:extend({
    {
      type = "recipe",
      name = "ab-focused-beacon",
      result = "ab-focused-beacon",
      enabled = false,
      energy_required = 20,
      ingredients = {{"advanced-circuit", 30}, {"electronic-circuit", 30}, {"copper-cable", 15}, {"steel-plate", 15}},
      order = "a[beacon]b"
    }
  })
  table.insert( data.raw["technology"]["effect-transmission"].effects, { type = "unlock-recipe", recipe = "ab-focused-beacon" } )
end

-- enables "node" beacons
if settings.startup["ab-enable-node-beacons"].value then
  data:extend({
    {
      type = "item",
      name = "ab-node-beacon",
      place_result = "ab-node-beacon",
      icon = "__alternative-beacons__/graphics/node-beacon-icon.png",
      icon_size = 64,
      stack_size = 10,
      subgroup = "module",
      order = "a[beacon]c"
    }
  })
  require("prototypes/node-beacon")
  data:extend({
    {
      type = "recipe",
      name = "ab-node-beacon",
      result = "ab-node-beacon",
      enabled = false,
      energy_required = 30,
      ingredients = {{"advanced-circuit", 40}, {"electronic-circuit", 40}, {"copper-cable", 20}, {"steel-plate", 20}},
      order = "a[beacon]c"
    }
  })
  table.insert( data.raw["technology"]["effect-transmission"].effects, { type = "unlock-recipe", recipe = "ab-node-beacon" } )
end

-- enables "hub" beacons
if settings.startup["ab-enable-hub-beacons"].value then
  data:extend({
    {
      type = "item",
      name = "ab-hub-beacon",
      place_result = "ab-hub-beacon",
      icon = "__alternative-beacons__/graphics/hub-beacon-icon.png",
      icon_size = 64,
      stack_size = 10,
      subgroup = "module",
      order = "a[beacon]d"
    }
  })
  require("prototypes/hub-beacon")
  data:extend({
    {
      type = "recipe",
      name = "ab-hub-beacon",
      result = "ab-hub-beacon",
      enabled = false,
      energy_required = 60,
      ingredients = {{"advanced-circuit", 200}, {"electronic-circuit", 200}, {"copper-cable", 100}, {"steel-plate", 100}},
      order = "a[beacon]d"
    }
  })
  table.insert( data.raw["technology"]["effect-transmission"].effects, { type = "unlock-recipe", recipe = "ab-hub-beacon" } )
end

-- enables "isolation" beacons
if settings.startup["ab-enable-isolation-beacons"].value then
  data:extend({
    {
      type = "item",
      name = "ab-isolation-beacon",
      place_result = "ab-isolation-beacon",
      icon = "__alternative-beacons__/graphics/isolation-beacon-icon.png",
      icon_size = 64,
      stack_size = 10,
      subgroup = "module",
      order = "a[beacon]e"
    }
  })
  require("prototypes/isolation-beacon")
  data:extend({
    {
      type = "recipe",
      name = "ab-isolation-beacon",
      result = "ab-isolation-beacon", 
      enabled = false,
      energy_required = 60,
      ingredients = {{"advanced-circuit", 200}, {"electronic-circuit", 200}, {"copper-cable", 100}, {"steel-plate", 100}},
      order = "a[beacon]e"
    }
  })
  table.insert( data.raw["technology"]["effect-transmission"].effects, { type = "unlock-recipe", recipe = "ab-isolation-beacon" } )
end

-- forces vanilla beacon default values if any part of the mod is enabled
if (settings.startup["ab-enable-focused-beacons"].value or settings.startup["ab-enable-hub-beacons"].value or settings.startup["ab-enable-node-beacons"].value or settings.startup["ab-enable-isolation-beacons"].value) then
  data.raw.beacon.beacon.energy_usage = "480kW"
  data.raw.beacon.beacon.module_specification = {
    module_info_icon_shift = { 0, 0.5 },
    module_info_max_icons_per_row = 2,
    module_info_max_icon_rows = 1,
    module_slots = 2
  }
  data.raw.beacon.beacon.tile_width = 3
  data.raw.beacon.beacon.tile_height = 3
  data.raw.beacon.beacon.collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } }
  data.raw.beacon.beacon.distribution_effectivity = 0.5
  data.raw.beacon.beacon.supply_area_distance = 3.05 -- extends from edge of collision box, total is 4.5 per direction (9x9)
  data.raw.beacon.beacon.order = "a[beacon]a"
  data.raw.recipe.beacon.order = "a[beacon]a"
  data.raw.item.beacon.order = "a[beacon]a"
end