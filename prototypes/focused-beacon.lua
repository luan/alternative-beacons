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
  profile = {1.556, 1.334, 1.15, 1, 0.86, 0.75, 0.66, 0.59, 0.5333, 0.4868, 0.45, 0.414, 0.3872, 0.3635, 0.3423, 0.3233, 0.3059, 0.2901, 0.2755, 0.2621},
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