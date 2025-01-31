-- wide-beacon.lua

local item = {
  type = "item",
  name = "se-wide-beacon",
  place_result = "se-wide-beacon",
  icon = "__alternative-beacons__/graphics/icon-wide-1.png",
  icon_size = 64,
  stack_size = 25,
  subgroup = "module",
  order = "a[beacon]i3"
}

local recipe = {
  type = "recipe",
  name = "se-wide-beacon",
  results = {{type="item", name="se-wide-beacon", amount=1}},
  enabled = false,
  energy_required = 10,
  ingredients = {{type = "item", name = "advanced-circuit", amount = 400}, {type = "item", name = "electronic-circuit", amount = 400}, {type = "item", name = "copper-cable", amount = 200}, {type = "item", name = "steel-plate", amount = 200}}
}

local animationTemplate = {
  animation = {
      width = 191,
      height = 335,
      scale = 0.625,
      line_length = 1,
      frame_count = 1,
      shift = {0, -1.4}
  }
}

local beacon_graphics = {
  animation_list = {
      table.deepcopy(animationTemplate),
      table.deepcopy(animationTemplate),
      table.deepcopy(animationTemplate)
  }
}
-- Additional settings changes
beacon_graphics.animation_list[1].animation.filename = "__alternative-beacons__/graphics/hr-wide-1-off.png"

beacon_graphics.animation_list[2].always_draw = false
beacon_graphics.animation_list[2].animation.filename = "__alternative-beacons__/graphics/hr-wide-1-animated.png"
beacon_graphics.animation_list[2].animation.line_length = 8
beacon_graphics.animation_list[2].animation.frame_count = 32
beacon_graphics.animation_list[2].animation.animation_speed = 0.5
beacon_graphics.animation_list[2].animation.draw_as_glow = true

beacon_graphics.animation_list[3].animation.draw_as_shadow = true
beacon_graphics.animation_list[3].animation.filename = "__alternative-beacons__/graphics/hr-isolation-shadow.png"
beacon_graphics.animation_list[3].animation.width = 366
beacon_graphics.animation_list[3].animation.height = 204
beacon_graphics.animation_list[3].animation.shift = {1.6125, 0}

local beacon = {
  type = "beacon",
  name = "se-wide-beacon",
  icon = "__alternative-beacons__/graphics/icon-wide-1.png",
  icon_size = 64,
  icon_mipmaps = 1,
  flags = {"placeable-player", "player-creation"},
  minable = {mining_time = 0.5, result = "se-wide-beacon"},
  energy_source = {type = "electric", usage_priority = "secondary-input"},
  energy_usage = "10000kW",
  heating_energy = "8000kW",
  max_health = 800,
  collision_box = { { -1.75, -1.75 }, { 1.75, 1.75 } },
  drawing_box = { { -2, -2.7 }, { 2, 2 } },
  selection_box = { { -2, -2 }, { 2, 2 } },
  allowed_effects = {"consumption", "speed", "pollution"},
  distribution_effectivity = 0.5,
  distribution_effectivity_bonus_per_quality_level = 0.1,
  profile = {1,0},
  beacon_count = "same_type",
  supply_area_distance = 14,
  module_slots = 15,
  icons_positioning = {{
    inventory_index = defines.inventory.beacon_modules,
    shift = {0, 0.5},
    max_icons_per_row = 5,
    max_icon_rows = 3,
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
      filename = "__alternative-beacons__/graphics/reflection-isolation.png",
      priority = "extra-high",
      width = 24,
      height = 37,
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
  damaged_trigger_effect = {
    entity_name = "spark-explosion",
    offset_deviation = { { -0.5, -0.5 }, { 0.5, 0.5 } },
    offsets = { { 0, 1 } },
    type = "create-entity"
  },
  dying_explosion = "beacon-explosion",
  corpse = "big-remnants"
}

local technology = {{
  icon = "__alternative-beacons__/graphics/tech-wide-1.png",
  icon_size = 256
}}

return {item = item, entity = beacon, recipe = recipe, technology = technology}