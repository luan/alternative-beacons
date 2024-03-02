-- standard-beacon.lua
-- this entity is practically the same as the vanilla entity and is only necessary for compatibility reasons when using other mods that alter vanilla beacons

-- copied from \base\prototypes\entity\beacon-animations.lua
local beacon_graphics = {
  module_icons_suppressed = true,

  animation_progress = 1,
  min_animation_progress = 0,

  module_tint_mode = "mix", -- "single-module"
  no_modules_tint = {1, 0, 0},
  random_animation_offset = true,

  apply_module_tint = "secondary",
  apply_module_tint_to_light = "none",

  -- light = { shift = {0, 0}, color = {1, 1, 1}, intensity = 1, size = 3 },
  animation_list =
  {
    {
      render_layer = "floor-mechanics",
      always_draw = true,
      animation =
      {
        layers =
        {
          {
            filename = "__base__/graphics/entity/beacon/beacon-bottom.png",
            width = 106,
            height = 96,
            shift = util.by_pixel(0, 1),
            hr_version =
            {
              filename = "__base__/graphics/entity/beacon/hr-beacon-bottom.png",
              width = 212,
              height = 192,
              scale = 0.5,
              shift = util.by_pixel(0.5, 1)
            }
          },
          {
            filename = "__base__/graphics/entity/beacon/beacon-shadow.png",
            width = 122,
            height = 90,
            draw_as_shadow = true,
            shift = util.by_pixel(12, 1),
            hr_version =
            {
              filename = "__base__/graphics/entity/beacon/hr-beacon-shadow.png",
              width = 244,
              height = 176,
              scale = 0.5,
              draw_as_shadow = true,
              shift = util.by_pixel(12.5, 0.5)
            }
          }
        }
      }
    },
    {
      render_layer = "object",
      always_draw = true,
      animation =
      {
        filename = "__base__/graphics/entity/beacon/beacon-top.png",
        width = 48,
        height = 70,
        repeat_count = 45,
        animation_speed = 0.5,
        shift = util.by_pixel(3, -19),
        hr_version =
        {
          filename = "__base__/graphics/entity/beacon/hr-beacon-top.png",
          width = 96,
          height = 140,
          scale = 0.5,
          repeat_count = 45,
          animation_speed = 0.5,
          shift = util.by_pixel(3, -19)
        }
      }
    },
    {
      render_layer = "object",
      apply_tint = true,
      draw_as_sprite = true,
      draw_as_light = true,
      always_draw = false,
      animation =
      {
        filename = "__base__/graphics/entity/beacon/beacon-light.png",
        line_length = 9,
        width = 56,
        height = 94,
        frame_count = 45,
        animation_speed = 0.5,
        shift = util.by_pixel(1, -18),
        blend_mode = "additive",
        hr_version =
        {
          filename = "__base__/graphics/entity/beacon/hr-beacon-light.png",
          line_length = 9,
          width = 110,
          height = 186,
          frame_count = 45,
          animation_speed = 0.5,
          scale = 0.5,
          shift = util.by_pixel(0.5, -18),
          blend_mode = "additive"
        }
      }
    }
  },

  module_visualisations =
  {
    {
      art_style = "vanilla",
      use_for_empty_slots = true,
      tier_offset = 0,
      slots =
      {
        -- slot 1
        {
          {
            has_empty_slot = true,
            render_layer = "lower-object",
            pictures =
            {
              filename = "__base__/graphics/entity/beacon/beacon-module-slot-1.png",
              line_length = 4,
              width = 26,
              height = 34,
              variation_count = 4,
              shift = util.by_pixel(-16, 15),
              hr_version =
              {
                filename = "__base__/graphics/entity/beacon/hr-beacon-module-slot-1.png",
                line_length = 4,
                width = 50,
                height = 66,
                variation_count = 4,
                scale = 0.5,
                shift = util.by_pixel(-16, 14.5)
              }
            }
          },
          {
            apply_module_tint = "primary",
            render_layer = "lower-object",
            pictures =
            {
              filename = "__base__/graphics/entity/beacon/beacon-module-mask-box-1.png",
              line_length = 3,
              width = 18,
              height = 16,
              variation_count = 3,
              shift = util.by_pixel(-17, 15),
              hr_version =
              {
                filename = "__base__/graphics/entity/beacon/hr-beacon-module-mask-box-1.png",
                line_length = 3,
                width = 36,
                height = 32,
                variation_count = 3,
                scale = 0.5,
                shift = util.by_pixel(-17, 15)
              }
            }
          },
          {
            apply_module_tint = "secondary",
            render_layer = "lower-object-above-shadow",
            pictures =
            {
              filename = "__base__/graphics/entity/beacon/beacon-module-mask-lights-1.png",
              line_length = 3,
              width = 14,
              height = 6,
              variation_count = 3,
              shift = util.by_pixel(-18, 13),
              hr_version =
              {
                filename = "__base__/graphics/entity/beacon/hr-beacon-module-mask-lights-1.png",
                line_length = 3,
                width = 26,
                height = 12,
                variation_count = 3,
                scale = 0.5,
                shift = util.by_pixel(-18.5, 13)
              }
            }
          },
          {
            apply_module_tint = "secondary",
            draw_as_light = true,
            draw_as_sprite = false,
            pictures =
            {
              filename = "__base__/graphics/entity/beacon/beacon-module-lights-1.png",
              line_length = 3,
              width = 28,
              height = 22,
              variation_count = 3,
              shift = util.by_pixel(-18, 13),
              hr_version =
              {
                filename = "__base__/graphics/entity/beacon/hr-beacon-module-lights-1.png",
                line_length = 3,
                width = 56,
                height = 42,
                variation_count = 3,
                shift = util.by_pixel(-18, 13),
                scale = 0.5
              }
            }
          }
        },
        -- slot 2
        {
          {
            has_empty_slot = true,
            render_layer = "lower-object",
            pictures =
            {
              filename = "__base__/graphics/entity/beacon/beacon-module-slot-2.png",
              line_length = 4,
              width = 24,
              height = 22,
              variation_count = 4,
              shift = util.by_pixel(19, -12),
              hr_version =
              {
                filename = "__base__/graphics/entity/beacon/hr-beacon-module-slot-2.png",
                line_length = 4,
                width = 46,
                height = 44,
                variation_count = 4,
                scale = 0.5,
                shift = util.by_pixel(19, -12)
              }
            }
          },
          {
            apply_module_tint = "primary",
            render_layer = "lower-object",
            pictures =
            {
              filename = "__base__/graphics/entity/beacon/beacon-module-mask-box-2.png",
              line_length = 3,
              width = 18,
              height = 14,
              variation_count = 3,
              shift = util.by_pixel(20, -12),
              hr_version =
              {
                filename = "__base__/graphics/entity/beacon/hr-beacon-module-mask-box-2.png",
                line_length = 3,
                width = 36,
                height = 26,
                variation_count = 3,
                scale = 0.5,
                shift = util.by_pixel(20.5, -12)
              }
            }
          },
          {
            apply_module_tint = "secondary",
            render_layer = "lower-object-above-shadow",
            pictures =
            {
              filename = "__base__/graphics/entity/beacon/beacon-module-mask-lights-2.png",
              line_length = 3,
              width = 12,
              height = 8,
              variation_count = 3,
              shift = util.by_pixel(22, -15),
              hr_version =
              {
                filename = "__base__/graphics/entity/beacon/hr-beacon-module-mask-lights-2.png",
                line_length = 3,
                width = 24,
                height = 14,
                variation_count = 3,
                scale = 0.5,
                shift = util.by_pixel(22, -15.5)
              }
            }
          },
          {
            apply_module_tint = "secondary",
            draw_as_light = true,
            draw_as_sprite = false,
            pictures =
            {
              filename = "__base__/graphics/entity/beacon/beacon-module-lights-2.png",
              line_length = 3,
              width = 34,
              height = 24,
              variation_count = 3,
              shift = util.by_pixel(22, -16),
              hr_version = {
                filename = "__base__/graphics/entity/beacon/hr-beacon-module-lights-2.png",
                line_length = 3,
                width = 66,
                height = 46,
                variation_count = 3,
                shift = util.by_pixel(22, -16),
                scale = 0.5
              }
            }
          }
        }
      }
    }
  }
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
    width = 10,
    height = 10
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

return beacon