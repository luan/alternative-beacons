-- conflux-beacon.lua

local item = {
  type = "item",
  name = "ab-conflux-beacon",
  place_result = "ab-conflux-beacon",
  icon = "__alternative-beacons-ex__/graphics/icon-conflux.png",
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
            filename = "__alternative-beacons-ex__/graphics/hr-conflux-base.png",
            width = 232,
            height = 186,
            shift = util.by_pixel(15, 3),
            scale = 0.67
          },
          {
            filename = "__alternative-beacons-ex__/graphics/hr-classic-base-shadow.png",
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
            filename = "__alternative-beacons-ex__/graphics/hr-classic-antenna.png",
            width = 108,
            height = 100,
            line_length = 8,
            frame_count = 32,
            animation_speed = 0.5,
            shift = util.by_pixel(-1.5, -73),
            scale = 0.67
          },
          {
            filename = "__alternative-beacons-ex__/graphics/hr-classic-antenna-shadow.png",
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
  icon = "__alternative-beacons-ex__/graphics/icon-conflux.png",
  icon_size = 64,
  icon_mipmaps = 4,
  flags = {"placeable-player", "player-creation"},
  minable = {mining_time = 0.3, result = "ab-conflux-beacon"},
  energy_source = {type = "electric", usage_priority = "secondary-input"},
  energy_usage = "8000kW",
  heating_energy = "6500kW",
  max_health = 400,
  collision_box = { { -1.75, -1.75 }, { 1.75, 1.75 } },
  drawing_box = { { -2, -2.7 }, { 2, 2 } },
  selection_box = { { -2, -2 }, { 2, 2 } },
  drawing_box_vertical_extension = 1.3,
  allowed_effects = {"consumption", "speed", "pollution"},
  distribution_effectivity = 0.5,
  distribution_effectivity_bonus_per_quality_level = 0.1,
  profile = {1.3334, 1.2, 1.08, 1, 0.9, 0.7978, 0.7042, 0.6258, 0.567, 0.5158, 0.4741, 0.438, 0.4052, 0.3786, 0.3534, 0.3313, 0.3118, 0.2945, 0.2789, 0.265},
  beacon_counter = "total",
  supply_area_distance = settings.startup["ab-conflux-beacon-supply-area-distance"].value, -- extends from edge of collision box (22x22)
  -- exclusion_area_distance = 12 (28x28; hardcoded in control.lua)
  module_slots = settings.startup["ab-conflux-beacon-module-slots"].value,
  icons_positioning = {{
    inventory_index = defines.inventory.beacon_modules,
    shift = {0, 0.5},
    max_icons_per_row = 3,
    max_icon_rows = 2,
    multi_row_initial_height_modifier = -0.3,
  }},
  graphics_set = beacon_graphics,
  radius_visualisation_picture = {
    filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png",
    priority = "extra-high-no-scale",
    size = {10, 10}
  },
  water_reflection = {
    pictures = {
      filename = "__alternative-beacons-ex__/graphics/reflection-classic.png",
      priority = "extra-high",
      width = 24,
      height = 28,
      scale = 6.66,
      shift = {0, 3.2},
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
  impact_category = "metal",
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
  icon = "__alternative-beacons-ex__/graphics/tech-conflux.png",
  icon_size = 256
}}

return {item = item, entity = beacon, recipe = recipe, technology = technology}