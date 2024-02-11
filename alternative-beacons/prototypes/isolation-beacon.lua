-- isolation-beacon.lua

local animationTemplate = {
  animation = {
      width = 191,
      height = 335,
      scale = 0.78125,
      line_length = 1,
      frame_count = 1,
      shift = {0, -1.75}
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
beacon_graphics.animation_list[1].render_layer = "lower-object-above-shadow"
beacon_graphics.animation_list[1].animation.filename = "__alternative-beacons__/graphics/isolation-beacon-full-off.png"

beacon_graphics.animation_list[2].render_layer = "lower-object-above-shadow"
beacon_graphics.animation_list[2].always_draw = false
beacon_graphics.animation_list[2].animation.filename = "__alternative-beacons__/graphics/isolation-beacon-full-animated.png"
beacon_graphics.animation_list[2].animation.line_length = 8
beacon_graphics.animation_list[2].animation.frame_count = 32
beacon_graphics.animation_list[2].animation.animation_speed = 0.5
beacon_graphics.animation_list[2].animation.draw_as_glow = true

beacon_graphics.animation_list[3].animation.draw_as_shadow = true
beacon_graphics.animation_list[3].animation.filename = "__alternative-beacons__/graphics/isolation-beacon-shadow.png"
beacon_graphics.animation_list[3].animation.width = 366
beacon_graphics.animation_list[3].animation.height = 204
beacon_graphics.animation_list[3].animation.shift = {2, 0}

local blank_image = {
    filename = "__alternative-beacons__/graphics/blank.png",
    width = 1,
    height = 1,
    frame_count = 1,
    line_length = 1,
    shift = { 0, 0 },
    repeat_count = 32,
}

data:extend({
  {
    type = "beacon",
    name = "ab-isolation-beacon",
    icon = "__alternative-beacons__/graphics/isolation-beacon-icon.png",
    icon_mipmaps = 1,
    icon_size = 64,
    flags = { "placeable-player", "player-creation" },
    minable = {
      mining_time = 0.5,
      result = "ab-isolation-beacon"
    },
    allowed_effects = { "consumption", "speed", "pollution" },
    graphics_set = beacon_graphics,
    animation_shadow = blank_image,
    base_picture = blank_image,
    collision_box = { { -2.2, -2.2 }, { 2.2, 2.2 } },
    drawing_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
    selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
    corpse = "big-remnants",
    damaged_trigger_effect = {
      entity_name = "spark-explosion",
      offset_deviation = { { -0.5, -0.5 }, { 0.5, 0.5 } },
      offsets = { { 0, 1 } },
      type = "create-entity"
    },
    dying_explosion = "beacon-explosion",
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage = "36000kW",
    max_health = 600,
    module_specification = {
      module_info_icon_shift = { 0, 0.5 },
      module_info_max_icons_per_row = 5,
      module_info_max_icon_rows = 2,
      module_info_multi_row_initial_height_modifier = -0.3,
      module_slots = 10
    },
    distribution_effectivity = 0.5,
    supply_area_distance = 30.05, -- extends from edge of collision box (65x65)
    -- exclusion_area_distance = 68 (141x141; hardcoded in control.lua)
    radius_visualisation_picture = {
      layers = {
        {filename = "__alternative-beacons__/graphics/visualization/beacon-radius-visualization-isolation.png", size = {129, 129}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-isolation-top-left.png", shift = {-4.03125,-4.03125}, size = {129, 129}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-isolation-top-mid.png", shift = {0,-4.03125}, size = {129, 129}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-isolation-top-right.png", shift = {4.03125,-4.03125}, size = {129, 129}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-isolation-mid-left.png", shift = {-4.03125,0}, size = {129, 129}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-isolation-mid-right.png", shift = {4.03125,0}, size = {129, 129}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-isolation-bottom-left.png", shift = {-4.03125,4.03125}, size = {129, 129}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-isolation-bottom-mid.png", shift = {0,4.03125}, size = {129, 129}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-isolation-bottom-right.png", shift = {4.03125,4.03125}, size = {129, 129}, priority = "extra-high-no-scale"}
      }
    },
    vehicle_impact_sound = {
      {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.5},
      {filename = "__base__/sound/car-metal-impact-2.ogg", volume = 0.5},
      {filename = "__base__/sound/car-metal-impact-3.ogg", volume = 0.5},
      {filename = "__base__/sound/car-metal-impact-4.ogg", volume = 0.5},
      {filename = "__base__/sound/car-metal-impact-5.ogg", volume = 0.5},
      {filename = "__base__/sound/car-metal-impact-6.ogg", volume = 0.5}
    },
    water_reflection = {
      orientation_to_variation = false,
      pictures = {
        filename = "__base__/graphics/entity/beacon/beacon-reflection.png",
        height = 28,
        priority = "extra-high",
        scale = 5,
        shift = {
          0,
          1.71875
        },
        variation_count = 1,
        width = 24
      },
      rotate = false
    },
    open_sound = data.raw.beacon.beacon.open_sound,
    close_sound = data.raw.beacon.beacon.close_sound
  }
})
