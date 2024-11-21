-- focused-beacon.lua

local item = {
  type = "item",
  name = "ab-focused-beacon",
  place_result = "ab-focused-beacon",
  icon = "__alternative-beacons__/graphics/icon-focused.png",
  icon_size = 64,
  stack_size = 20,
  subgroup = "module",
  order = "a[beacon]b"
}

local recipe = {
  type = "recipe",
  name = "ab-focused-beacon",
  results = {{type="item", name="ab-focused-beacon", amount=1}},
  enabled = false,
  energy_required = 20,
  ingredients = {{type = "item", name = "advanced-circuit", amount = 40}, {type = "item", name = "electronic-circuit", amount = 40}, {type = "item", name = "copper-cable", amount = 20}, {type = "item", name = "steel-plate", amount = 20}}
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
            filename = "__alternative-beacons__/graphics/sr-focused-base.png",
            width = 116,
            height = 93,
            shift = util.by_pixel(8, 1),
            scale = 0.67,
            hr_version = {
              filename = "__alternative-beacons__/graphics/hr-focused-base.png",
              width = 232,
              height = 186,
              shift = util.by_pixel(8, 1),
              scale = 0.335
            }
          },
          {
            filename = "__alternative-beacons__/graphics/sr-classic-base-shadow.png",
            width = 116,
            height = 93,
            shift = util.by_pixel(8, 1),
            draw_as_shadow = true,
            scale = 0.67,
            hr_version = {
              filename = "__alternative-beacons__/graphics/hr-classic-base-shadow.png",
              width = 232,
              height = 186,
              shift = util.by_pixel(8, 1),
              draw_as_shadow = true,
              scale = 0.335
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
            shift = util.by_pixel(-0.7, -36),
            scale = 0.67,
            hr_version = {
              filename = "__alternative-beacons__/graphics/hr-classic-antenna.png",
              width = 108,
              height = 100,
              line_length = 8,
              frame_count = 32,
              animation_speed = 0.5,
              shift = util.by_pixel(-0.7, -36),
              scale = 0.335
            }
          },
          {
            filename = "__alternative-beacons__/graphics/sr-classic-antenna-shadow.png",
            width = 63,
            height = 49,
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.5,
            shift = util.by_pixel(67, 10.5),
            draw_as_shadow = true,
            scale = 0.67,
            hr_version = {
              filename = "__alternative-beacons__/graphics/hr-classic-antenna-shadow.png",
              width = 126,
              height = 98,
              line_length = 8,
              frame_count = 32,
              animation_speed = 0.5,
              shift = util.by_pixel(67, 10.5),
              draw_as_shadow = true,
              scale = 0.335
            }
          }
        }
      }
    }
  }
}

local beacon = {
  type = "beacon",
  name = "ab-focused-beacon",
  icon = "__alternative-beacons__/graphics/icon-focused.png",
  icon_mipmaps = 4,
  icon_size = 64,
  flags = { "placeable-player", "player-creation" },
  minable = {
    mining_time = 0.2,
    result = "ab-focused-beacon"
  },
  allowed_effects = { "consumption", "speed", "pollution" },
  energy_source = {
    type = "electric",
    usage_priority = "secondary-input"
  },
  energy_usage = "1200kW",
  max_health = 150,
  module_slots = 3,
  icons_positioning = {{
    inventory_index = defines.inventory.beacon_modules,
    shift = { 0, 0.25 },
    max_icons_per_row = 3,
    max_icon_rows = 1,
  }},
  distribution_effectivity = 0.75,
  distribution_effectivity_bonus_per_quality_level = 0.1,
  --profile = {1, 0.7071, 0.5773, 0.5, 0.4472, 0.4082, 0.3779, 0.3535, 0.3333, 0.3162, 0.3015, 0.2887, 0.2773, 0.2672, 0.2582, 0.25, 0.2425, 0.2357, 0.2294, 0.2236, 0.2182, 0.2132, 0.2085, 0.2041, 0.2, 0.1961, 0.1924, 0.189, 0.1857, 0.1825, 0.1796, 0.1768, 0.1741, 0.1715, 0.169, 0.1666, 0.1644, 0.1622, 0.1601, 0.1581, 0.1561, 0.1543, 0.1525, 0.1507, 0.149, 0.1474, 0.1458, 0.1443, 0.1428, 0.1414, 0.14, 0.1387, 0.1373, 0.1361, 0.1348, 0.1336, 0.1324, 0.1313, 0.1302, 0.1291, 0.128, 0.127, 0.126, 0.125, 0.124, 0.1231, 0.1221, 0.1212, 0.1204, 0.1195, 0.1187, 0.1178, 0.117, 0.1162, 0.1154, 0.1147, 0.1139, 0.1132, 0.1125, 0.1118, 0.1111, 0.1104, 0.1097, 0.1091, 0.1084, 0.1078, 0.1072, 0.1066, 0.106, 0.1054, 0.1048, 0.1042, 0.1037, 0.1031, 0.1026, 0.102, 0.1015, 0.101, 0.1005, 0.1},
  --profile = {1.2, 0.95, 0.8, 0.7075, 0.6261, 0.552, 0.4896, 0.4425, 0.404, 0.373, 0.3463, 0.3253, 0.3064, 0.2907, 0.2767, 0.2642, 0.2529, 0.2425, 0.2331, 0.2244},
  --profile = {3.6, 2.85, 2.4, 2.12, 1.88, 1.66, 1.47, 1.33, 1.21, 1.12, 1.04, 0.98, 0.92, 0.87, 0.83, 0.79, 0.76, 0.73, 0.7, 0.67},
  profile = {1.6, 1.2667, 1.0667, 0.9433, 0.8348, 0.736, 0.6529, 0.59, 0.5387, 0.4974, 0.4617, 0.4337, 0.4086, 0.3877, 0.369, 0.3523, 0.3372, 0.3234, 0.3108, 0.2993},
  supply_area_distance = 2, -- extends from edge of collision box (6x6)
  -- exclusion_area_distance = 3 (8x8; hardcoded in control.lua)
  collision_box = { { -0.75, -0.75 }, { 0.75, 0.75 } },
  drawing_box = { { -1, -1.7 }, { 1, 1 } },
  selection_box = { { -1, -1 }, { 1, 1 } },
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
      shift = {0, 1.71875},
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
    icon = "__alternative-beacons__/graphics/tech-focused.png",
    icon_size = 256
  },
}

return {item = item, entity = beacon, recipe = recipe, technology = technology}