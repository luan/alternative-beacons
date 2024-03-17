-- compact-beacon.lua

local beacon_graphics = {
  module_icons_suppressed = false,
  animation_list = {
    {
      render_layer = "lower-object-above-shadow",
      always_draw = true,
      animation = {
        layers = {
          {
            filename = "__alternative-beacons__/graphics/focused-beacon-base.png",
            width = 116,
            height = 93,
            shift = util.by_pixel(8, 1),
            scale = 0.67,
            hr_version = {
              filename = "__alternative-beacons__/graphics/hr-focused-beacon-base.png",
              width = 232,
              height = 186,
              shift = util.by_pixel(8, 1),
              scale = 0.335
            }
          },
          {
            filename = "__alternative-beacons__/graphics/node-beacon-base-shadow.png",
            width = 116,
            height = 93,
            shift = util.by_pixel(8, 1),
            draw_as_shadow = true,
            scale = 0.67,
            hr_version = {
              filename = "__alternative-beacons__/graphics/hr-node-beacon-base-shadow.png",
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
            filename = "__alternative-beacons__/graphics/node-beacon-antenna.png",
            width = 54,
            height = 50,
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.5,
            shift = util.by_pixel(-0.7, -36),
            scale = 0.67,
            hr_version = {
              filename = "__alternative-beacons__/graphics/hr-node-beacon-antenna.png",
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
            filename = "__alternative-beacons__/graphics/node-beacon-antenna-shadow.png",
            width = 63,
            height = 49,
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.5,
            shift = util.by_pixel(67, 10.5),
            draw_as_shadow = true,
            scale = 0.67,
            hr_version = {
              filename = "__alternative-beacons__/graphics/hr-node-beacon-antenna-shadow.png",
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
  name = "se-compact-beacon",
  icon = "__alternative-beacons__/graphics/focused-beacon-icon.png",
  icon_mipmaps = 1,
  icon_size = 64,
  flags = { "placeable-player", "player-creation" },
  minable = {
    mining_time = 0.2,
    result = "se-compact-beacon"
  },
  allowed_effects = { "consumption", "speed", "pollution" },
  energy_source = {
    type = "electric",
    usage_priority = "secondary-input"
  },
  energy_usage = "800kW",
  max_health = 400,
  module_specification = {
    module_info_icon_shift = { 0, 0.25 },
    module_info_max_icons_per_row = 5,
    module_info_max_icon_rows = 2,
    module_slots = 10
  },
  distribution_effectivity = 0.75,
  supply_area_distance = 2,
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

return beacon