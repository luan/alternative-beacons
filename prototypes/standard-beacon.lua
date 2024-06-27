-- standard-beacon.lua
-- this prototype is practically the same as the vanilla prototype and is only necessary for compatibility reasons when using other mods that alter vanilla beacons

item = {
  type = "item",
  name = "ab-standard-beacon",
  place_result = "ab-standard-beacon",
  icon = "__base__/graphics/icons/beacon.png",
  icon_size = 64,
  stack_size = 20,
  subgroup = "module",
  order = "a[beacon]a"
}

recipe = {
  type = "recipe",
  name = "ab-standard-beacon",
  result = "ab-standard-beacon",
  enabled = false,
  energy_required = 15,
  ingredients = {{type = "item", name = "advanced-circuit", amount = 20}, {type = "item", name = "electronic-circuit", amount = 20}, {type = "item", name = "copper-cable", amount = 10}, {type = "item", name = "steel-plate", amount = 10}},
  normal = { result = "ab-standard-beacon", enabled = false, energy_required = 15, ingredients = {{type = "item", name = "advanced-circuit", amount = 20}, {type = "item", name = "electronic-circuit", amount = 20}, {type = "item", name = "copper-cable", amount = 10}, {type = "item", name = "steel-plate", amount = 10}} },
  expensive = { result = "ab-standard-beacon", enabled = false, energy_required = 15, ingredients = {{type = "item", name = "advanced-circuit", amount = 20}, {type = "item", name = "electronic-circuit", amount = 20}, {type = "item", name = "copper-cable", amount = 10}, {type = "item", name = "steel-plate", amount = 10}} }
}

-- copied from \base\prototypes\entity\entities.lua with minor changes
local beacon = {
  type = "beacon",
  name = "ab-standard-beacon",
  icon = "__base__/graphics/icons/beacon.png",
  icon_size = 64, icon_mipmaps = 4,
  flags = {"placeable-player", "player-creation"},
  minable = {mining_time = 0.2, result = "ab-standard-beacon"},
  max_health = 200,
  corpse = "beacon-remnants",
  dying_explosion = "beacon-explosion",
  collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  damaged_trigger_effect = { -- changed from: damaged_trigger_effect = hit_effects.entity(),
    entity_name = "spark-explosion",
    offset_deviation = { { -0.5, -0.5 }, { 0.5, 0.5 } },
    offsets = { { 0, 1 } },
    type = "create-entity"
  },
  drawing_box = {{-1.5, -2.2}, {1.5, 1.3}},
  allowed_effects = {"consumption", "speed", "pollution"},
  --graphics_set = beacon_graphics,
  graphics_set = require("__base__/prototypes/entity/beacon-animations.lua"),
  radius_visualisation_picture =
  {
    filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png",
    priority = "extra-high-no-scale",
    size = {10, 10}
  },
  supply_area_distance = 3.05, -- changed from 3.0 so the range is exactly 1/4 of a tile away from the edge of the distribution area to match other beacons
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input"
  },
  vehicle_impact_sound = { -- changed from: vehicle_impact_sound = sounds.generic_impact,
    {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-2.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-3.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-4.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-5.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-6.ogg", volume = 0.5}
  },
  open_sound = data.raw.beacon.beacon.open_sound, -- changed from: open_sound = sounds.machine_open,
  close_sound = data.raw.beacon.beacon.close_sound, -- changed from: close_sound = sounds.machine_close,
  working_sound =
  {
    sound =
    {
      {
        filename = "__base__/sound/beacon-1.ogg",
        volume = 0.2
      },
      {
        filename = "__base__/sound/beacon-2.ogg",
        volume = 0.2
      }
    },
    audible_distance_modifier = 0.33,
    max_sounds_per_type = 3
    -- fade_in_ticks = 4,
    -- fade_out_ticks = 60
  },
  energy_usage = "480kW",
  distribution_effectivity = 0.5,
  module_specification =
  {
    module_slots = 2,
    module_info_icon_shift = {0, 0.5}, -- changed from {0, 0} to match other beacons
    module_info_multi_row_initial_height_modifier = -0.3,
    module_info_max_icons_per_row = 2
  },
  water_reflection =
  {
    pictures =
    {
      filename = "__base__/graphics/entity/beacon/beacon-reflection.png",
      priority = "extra-high",
      width = 24,
      height = 28,
      shift = util.by_pixel(0, 55),
      variation_count = 1,
      scale = 5
    },
    rotate = false,
    orientation_to_variation = false
  }
}

return {item = item, entity = beacon, recipe = recipe}