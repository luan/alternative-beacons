-- compact-beacon.lua

local item = {
  type = "item",
  name = "se-compact-beacon",
  place_result = "se-compact-beacon",
  icon = "__alternative-beacons__/graphics/icon-compact-1.png",
  icon_size = 64,
  stack_size = 25,
  subgroup = "module",
  order = "a[beacon]i2"
}

local recipe = {
  type = "recipe",
  name = "se-compact-beacon",
  results = {{type="item", name="se-compact-beacon", amount=1}},
  enabled = false,
  energy_required = 10,
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
            filename = "__alternative-beacons__/graphics/sr-compact-1-base.png",
            width = 116,
            height = 93,
            shift = util.by_pixel(8, 1),
            scale = 0.67,
            hr_version = {
              filename = "__alternative-beacons__/graphics/hr-compact-1-base.png",
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
  name = "se-compact-beacon",
  icon = "__alternative-beacons__/graphics/icon-compact-1.png",
  icon_size = 64,
  icon_mipmaps = 1,
  flags = {"placeable-player", "player-creation"},
  minable = {mining_time = 0.2, result = "se-compact-beacon"},
  energy_source = {type = "electric", usage_priority = "secondary-input"},
  energy_usage = "800kW",
  heating_energy = "650kW",
  max_health = 400,
  collision_box = { { -0.75, -0.75 }, { 0.75, 0.75 } },
  drawing_box = { { -1, -1.7 }, { 1, 1 } },
  selection_box = { { -1, -1 }, { 1, 1 } },
  allowed_effects = {"consumption", "speed", "pollution"},
  distribution_effectivity = 0.75,
  distribution_effectivity_bonus_per_quality_level = 0.1,
  profile = {1,0},
  beacon_counter = "same_type",
  supply_area_distance = 2,
  module_slots = 10,
  icons_positioning = {{
    inventory_index = defines.inventory.beacon_modules,
    shift = {0, 0.25},
    max_icons_per_row = 4,
    max_icon_rows = 3,
    multi_row_initial_height_modifier = -0.75,
  }},
  graphics_set = beacon_graphics,
  radius_visualisation_picture = {
    filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png",
    priority = "extra-high-no-scale",
    size = {10, 10}
  },
  water_reflection = {
    pictures = {
      filename = "__alternative-beacons__/graphics/reflection-classic.png",
      priority = "extra-high",
      width = 24,
      height = 28,
      scale = 3.33,
      shift = {0, 1.8},
      variation_count = 1
    },
    rotate = false,
    orientation_to_variation = false
  },
  open_sound = {filename = "__base__/sound/open-close/beacon-open.ogg", volume = 0.4},
  close_sound = {filename = "__base__/sound/open-close/beacon-close.ogg", volume = 0.4},
  working_sound = {
    audible_distance_modifier = 0.33,
    max_sounds_per_type = 3,
    sound = {
      {filename = "__base__/sound/beacon-1.ogg", volume = 0.2},
      {filename = "__base__/sound/beacon-2.ogg", volume = 0.2}
    }
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

if not feature_flags["freezing"] then beacon.heating_energy = nil end
if not feature_flags["quality"] then beacon.distribution_effectivity_bonus_per_quality_level = nil end

local technology = {{
  icon = "__alternative-beacons__/graphics/tech-compact-1.png",
  icon_size = 256
}}

return {item = item, entity = beacon, recipe = recipe, technology = technology}