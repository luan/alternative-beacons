-- conflux-beacon.lua

local item = {
  type = "item",
  name = "ab-conflux-beacon",
  place_result = "ab-conflux-beacon",
  icon = "__alternative-beacons__/graphics/icon-conflux.png",
  icon_size = 64,
  stack_size = 20,
  subgroup = "module",
  order = "a[beacon]d"
}

local recipe = {
  type = "recipe",
  name = "ab-conflux-beacon",
  results = {{type="item", name="ab-conflux-beacon", amount=1}},
  enabled = false,
  energy_required = 40,
  ingredients = {{type = "item", name = "advanced-circuit", amount = 200}, {type = "item", name = "electronic-circuit", amount = 200}, {type = "item", name = "copper-cable", amount = 100}, {type = "item", name = "steel-plate", amount = 100}}
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
            filename = "__alternative-beacons__/graphics/hr-conflux-base.png",
            width = 232,
            height = 186,
            shift = util.by_pixel(15, 3),
            scale = 0.67
          },
          {
            filename = "__alternative-beacons__/graphics/hr-classic-base-shadow.png",
            width = 232,
            height = 186,
            shift = util.by_pixel(15, 3),
            draw_as_shadow = true,
            scale = 0.67
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
            filename = "__alternative-beacons__/graphics/hr-classic-antenna.png",
            width = 108,
            height = 100,
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.5,
            shift = util.by_pixel(-1.5, -73),
            scale = 0.67
          },
          {
            filename = "__alternative-beacons__/graphics/hr-classic-antenna-shadow.png",
            width = 126,
            height = 98,
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.5,
            shift = util.by_pixel(134, 21),
            draw_as_shadow = true,
            scale = 0.67
          }
        }
      }
    }
  }
}

local beacon = {
  type = "beacon",
  name = "ab-conflux-beacon",
  icon = "__alternative-beacons__/graphics/icon-conflux.png",
  icon_mipmaps = 4,
  icon_size = 64,
  flags = { "placeable-player", "player-creation" },
  minable = {
    mining_time = 0.3,
    result = "ab-conflux-beacon"
  },
  allowed_effects = { "consumption", "speed", "pollution" },
  energy_source = {
    type = "electric",
    usage_priority = "secondary-input"
  },
  energy_usage = "8000kW",
  max_health = 400,
  module_slots = 6,
  icons_positioning = {{
    inventory_index = defines.inventory.beacon_modules,
    shift = { 0, 0.5 },
    max_icons_per_row = 3,
    max_icon_rows = 2,
    multi_row_initial_height_modifier = -0.3,
  }},
  distribution_effectivity = 0.5,
  distribution_effectivity_bonus_per_quality_level = 0.2,
  --profile = {1, 0.7071, 0.5773, 0.5, 0.4472, 0.4082, 0.3779, 0.3535, 0.3333, 0.3162, 0.3015, 0.2887, 0.2773, 0.2672, 0.2582, 0.25, 0.2425, 0.2357, 0.2294, 0.2236, 0.2182, 0.2132, 0.2085, 0.2041, 0.2, 0.1961, 0.1924, 0.189, 0.1857, 0.1825, 0.1796, 0.1768, 0.1741, 0.1715, 0.169, 0.1666, 0.1644, 0.1622, 0.1601, 0.1581, 0.1561, 0.1543, 0.1525, 0.1507, 0.149, 0.1474, 0.1458, 0.1443, 0.1428, 0.1414, 0.14, 0.1387, 0.1373, 0.1361, 0.1348, 0.1336, 0.1324, 0.1313, 0.1302, 0.1291, 0.128, 0.127, 0.126, 0.125, 0.124, 0.1231, 0.1221, 0.1212, 0.1204, 0.1195, 0.1187, 0.1178, 0.117, 0.1162, 0.1154, 0.1147, 0.1139, 0.1132, 0.1125, 0.1118, 0.1111, 0.1104, 0.1097, 0.1091, 0.1084, 0.1078, 0.1072, 0.1066, 0.106, 0.1054, 0.1048, 0.1042, 0.1037, 0.1031, 0.1026, 0.102, 0.1015, 0.101, 0.1005, 0.1},
  --profile = {1.25, 1.0233, 0.8601, 0.7595, 0.6711, 0.5906, 0.5263, 0.4737, 0.4307, 0.396, 0.3662, 0.3415, 0.3209, 0.3027, 0.2864, 0.2718, 0.2584, 0.2462, 0.235, 0.2247},
  --profile = {3.75, 3.07, 2.58, 2.28, 2.01, 1.77, 1.58, 1.42, 1.29, 1.19, 1.1, 1.03, 0.96, 0.91, 0.86, 0.82, 0.78, 0.74, 0.71, 0.67},
  profile = {1.625, 1.3303, 1.1181, 0.9874, 0.8724, 0.7678, 0.6842, 0.6158, 0.5599, 0.5148, 0.4761, 0.444, 0.4172, 0.3935, 0.3723, 0.3533, 0.3359, 0.3201, 0.3055, 0.2921},
  supply_area_distance = 9, -- extends from edge of collision box (22x22)
  -- exclusion_area_distance = 12 (28x28; hardcoded in control.lua)
  collision_box = { { -1.75, -1.75 }, { 1.75, 1.75 } },
  drawing_box = { { -2, -2.7 }, { 2, 2 } },
  selection_box = { { -2, -2 }, { 2, 2 } },
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
    icon = "__alternative-beacons__/graphics/tech-conflux.png",
    icon_size = 256
  },
}

return {item = item, entity = beacon, recipe = recipe, technology = technology}