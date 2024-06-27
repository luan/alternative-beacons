-- node-beacon.lua

local item = {
  type = "item",
  name = "ab-node-beacon",
  place_result = "ab-node-beacon",
  icon = "__alternative-beacons__/graphics/icon-node.png",
  icon_size = 64,
  stack_size = 20,
  subgroup = "module",
  order = "a[beacon]c"
}

local recipe = {
  type = "recipe",
  name = "ab-node-beacon",
  result = "ab-node-beacon",
  enabled = false,
  energy_required = 30,
  ingredients = {{type = "item", name = "advanced-circuit", amount = 80}, {type = "item", name = "electronic-circuit", amount = 80}, {type = "item", name = "copper-cable", amount = 40}, {type = "item", name = "steel-plate", amount = 40}},
  normal = { result = "ab-node-beacon", enabled = false, energy_required = 30, ingredients = {{type = "item", name = "advanced-circuit", amount = 80}, {type = "item", name = "electronic-circuit", amount = 80}, {type = "item", name = "copper-cable", amount = 40}, {type = "item", name = "steel-plate", amount = 40}} },
  expensive = { result = "ab-node-beacon", enabled = false, energy_required = 30, ingredients = {{type = "item", name = "advanced-circuit", amount = 80}, {type = "item", name = "electronic-circuit", amount = 80}, {type = "item", name = "copper-cable", amount = 40}, {type = "item", name = "steel-plate", amount = 40}} }
}

local beacon_graphics = {
  module_icons_suppressed = false,
  animation_list = {
    {
      render_layer = "lower-object-above-shadow",
      always_draw = true,
      animation = {
        layers = {
          {
            filename = "__alternative-beacons__/graphics/sr-node-base.png",
            width = 116,
            height = 93,
            shift = util.by_pixel(11, 1.5),
            hr_version = {
              filename = "__alternative-beacons__/graphics/hr-node-base.png",
              width = 232,
              height = 186,
              shift = util.by_pixel(11, 1.5),
              scale = 0.5
            }
          },
          {
            filename = "__alternative-beacons__/graphics/sr-classic-base-shadow.png",
            width = 116,
            height = 93,
            shift = util.by_pixel(11, 1.5),
            draw_as_shadow = true,
            hr_version = {
              filename = "__alternative-beacons__/graphics/hr-classic-base-shadow.png",
              width = 232,
              height = 186,
              shift = util.by_pixel(11, 1.5),
              draw_as_shadow = true,
              scale = 0.5
            }
          }
        }
      }
    },
    {
      render_layer = "object",
      always_draw = true,
      animation = {
        layers = {
          {
            filename = "__alternative-beacons__/graphics/sr-classic-antenna.png",
            width = 54,
            height = 50,
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.5,
            shift = util.by_pixel(-1, -55),
            hr_version = {
              filename = "__alternative-beacons__/graphics/hr-classic-antenna.png",
              width = 108,
              height = 100,
              line_length = 8,
              frame_count = 32,
              animation_speed = 0.5,
              shift = util.by_pixel(-1, -55),
              scale = 0.5
            }
          },
          {
            filename = "__alternative-beacons__/graphics/sr-classic-antenna-shadow.png",
            width = 63,
            height = 49,
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.5,
            shift = util.by_pixel(100.5, 15.5),
            draw_as_shadow = true,
            hr_version = {
              filename = "__alternative-beacons__/graphics/hr-classic-antenna-shadow.png",
              width = 126,
              height = 98,
              line_length = 8,
              frame_count = 32,
              animation_speed = 0.5,
              shift = util.by_pixel(100.5, 15.5),
              draw_as_shadow = true,
              scale = 0.5
            }
          }
        }
      }
    }
  }
}

local beacon = {
  type = "beacon",
  name = "ab-node-beacon",
  icon = "__alternative-beacons__/graphics/icon-node.png",
  icon_mipmaps = 4,
  icon_size = 64,
  flags = { "placeable-player", "player-creation" },
  minable = {
    mining_time = 0.3,
    result = "ab-node-beacon"
  },
  allowed_effects = { "consumption", "speed", "pollution" },
  energy_source = {
    type = "electric",
    usage_priority = "secondary-input"
  },
  energy_usage = "3600kW",
  max_health = 300,
  module_specification = {
    module_info_icon_shift = { 0, 0.5 },
    module_info_max_icons_per_row = 3,
    module_info_max_icon_rows = 1,
    module_slots = 3
  },
  distribution_effectivity = 0.5,
  supply_area_distance = 8.05, -- extends from edge of collision box (19x19)
  -- exclusion_area_distance = 8 (19x19; coded in control.lua)
  collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
  drawing_box = { { -1.5, -2.025 }, { 1.5, 1.5 } },
  selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
  graphics_set = beacon_graphics,
  radius_visualisation_picture =
  {
    filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png",
    priority = "extra-high-no-scale",
    size = {10, 10}
  },
  water_reflection = {
    pictures = {
      filename = "__base__/graphics/entity/beacon/beacon-reflection.png",
      priority = "extra-high",
      width = 24,
      height = 28,
      scale = 5,
      shift = { 0, 1.71875 },
      variation_count = 1
    },
    rotate = false,
    orientation_to_variation = false
  },
  open_sound = data.raw.beacon.beacon.open_sound,
  close_sound = data.raw.beacon.beacon.close_sound,
  vehicle_impact_sound = {
    {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-2.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-3.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-4.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-5.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-6.ogg", volume = 0.5}
  },
  damaged_trigger_effect = {
    entity_name = "spark-explosion",
    offset_deviation = { { -0.5, -0.5 }, { 0.5, 0.5 } },
    offsets = { { 0, 1 } },
    type = "create-entity"
  },
  dying_explosion = "beacon-explosion",
  corpse = "medium-remnants"
}

local technology = {
  {
    icon = "__alternative-beacons__/graphics/tech-node.png",
    icon_size = 256
  },
}

return {item = item, entity = beacon, recipe = recipe, technology = technology}