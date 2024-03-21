-- hub-beacon.lua

-- Most common settings for the animations (deepcopied multiple times to keep the code short)
local animationTemplate = {
  animation = {
      width = 198,
      height = 340,
      scale = 0.625,
      line_length = 1,
      frame_count = 1,
      shift = {0, -1.4}
  }
}

-- Includes 3 still images, 3 animated images that cover the still images when the machine is active, and a shadow.
-- Because of a combination of 'always_draw' and 'render_layer', layers couldn't be used to fit them in the same animation list.
local beacon_graphics = {
  animation_list = {
      table.deepcopy(animationTemplate),
      table.deepcopy(animationTemplate),
      table.deepcopy(animationTemplate),
      table.deepcopy(animationTemplate),
      table.deepcopy(animationTemplate),
      table.deepcopy(animationTemplate),
      table.deepcopy(animationTemplate)
  }
}
-- Additional settings changes
beacon_graphics.animation_list[1].render_layer = "lower-object-above-shadow"
beacon_graphics.animation_list[1].animation.filename = "__alternative-beacons__/graphics/hr-hub-base.png"
beacon_graphics.animation_list[2].animation.filename = "__alternative-beacons__/graphics/hr-hub-antenna.png"
beacon_graphics.animation_list[3].animation.filename = "__alternative-beacons__/graphics/hr-hub-body.png"

beacon_graphics.animation_list[4].render_layer = "lower-object-above-shadow"
beacon_graphics.animation_list[4].always_draw = false
beacon_graphics.animation_list[4].animation.filename = "__alternative-beacons__/graphics/hr-hub-base-animated.png"
beacon_graphics.animation_list[4].animation.line_length = 8
beacon_graphics.animation_list[4].animation.frame_count = 32
beacon_graphics.animation_list[4].animation.animation_speed = 0.5
beacon_graphics.animation_list[4].animation.draw_as_glow = true

beacon_graphics.animation_list[5].always_draw = false
beacon_graphics.animation_list[5].animation.filename = "__alternative-beacons__/graphics/hr-hub-antenna-animated.png"
beacon_graphics.animation_list[5].animation.line_length = 8
beacon_graphics.animation_list[5].animation.frame_count = 32
beacon_graphics.animation_list[5].animation.animation_speed = 0.5
beacon_graphics.animation_list[5].animation.draw_as_glow = true

beacon_graphics.animation_list[6].always_draw = false
beacon_graphics.animation_list[6].animation.filename = "__alternative-beacons__/graphics/hr-hub-body-animated.png"
beacon_graphics.animation_list[6].animation.line_length = 8
beacon_graphics.animation_list[6].animation.frame_count = 32
beacon_graphics.animation_list[6].animation.animation_speed = 0.5
beacon_graphics.animation_list[6].animation.draw_as_glow = true

beacon_graphics.animation_list[7].animation.draw_as_shadow = true
beacon_graphics.animation_list[7].animation.filename = "__alternative-beacons__/graphics/hr-hub-shadow.png"
beacon_graphics.animation_list[7].animation.width = 366
beacon_graphics.animation_list[7].animation.height = 204
beacon_graphics.animation_list[7].animation.shift = {1.59, 0}

local beacon = {
  type = "beacon",
  name = "ab-hub-beacon",
  icon = "__alternative-beacons__/graphics/icon-hub.png",
  icon_mipmaps = 4,
  icon_size = 64,
  flags = { "placeable-player", "player-creation" },
  minable = {
    mining_time = 0.5,
    result = "ab-hub-beacon"
  },
  allowed_effects = { "consumption", "speed", "pollution" },
  energy_source = {
    type = "electric",
    usage_priority = "secondary-input"
  },
  energy_usage = "15000kW",
  max_health = 500,
  module_specification = {
    module_info_icon_shift = { 0, 0.1 },
    module_info_max_icons_per_row = 3,
    module_info_max_icon_rows = 3,
    module_info_multi_row_initial_height_modifier = -0.3,
    module_slots = 9
  },
  distribution_effectivity = 0.5,
  supply_area_distance = 14.05, -- extends from edge of collision box (32x32)
  -- exclusion_area_distance = 34 (72x72; hardcoded in control.lua)
  collision_box = { { -1.7, -1.7 }, { 1.7, 1.7 } },
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
  corpse = "big-remnants"
}

return beacon