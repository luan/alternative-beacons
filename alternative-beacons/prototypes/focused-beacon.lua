-- focused-beacon.lua

local beacon_animation = {
  layers = {
    {
      filename = "__alternative-beacons__/graphics/focused-beacon-base.png",
      priority = "high",
      width = 116,
      height = 93,
      frame_count = 1,
      line_length = 1,
      repeat_count = 32,
      scale = 0.66,
      shift = { 0.25 , 0 },
      hr_version = {
        filename = "__alternative-beacons__/graphics/hr-focused-beacon-base.png",
        priority = "high",
        width = 116*2,
        height = 93*2,
        frame_count = 1,
        line_length = 1,
        repeat_count = 32,
        scale = 0.66/2,
        shift = { 0.25 , 0 },
      }
    },
    {
      animation_speed = 1,
      filename = "__alternative-beacons__/graphics/node-beacon-antenna.png",
      priority = "high",
      frame_count = 32,
      width = 54,
      height = 50,
      line_length = 8,
      scale = 0.66,
      shift = { 0 , -1-5/32},
      hr_version = {
        animation_speed = 1,
        filename = "__alternative-beacons__/graphics/hr-node-beacon-antenna.png",
        priority = "high",
        frame_count = 32,
        width = 54*2,
        height = 50*2,
        line_length = 8,
        scale = 0.66/2,
        shift = { 0 , -1-5/32},
      }
    },
    {
      draw_as_shadow = true,
      filename = "__alternative-beacons__/graphics/node-beacon-base-shadow.png",
      width = 116,
      height = 93,
      frame_count = 1,
      line_length = 1,
      repeat_count = 32,
      scale = 0.66,
      shift = { 0.25 , 0 },
      hr_version = {
        draw_as_shadow = true,
        filename = "__alternative-beacons__/graphics/hr-node-beacon-base-shadow.png",
        width = 116*2,
        height = 93*2,
        frame_count = 1,
        line_length = 1,
        repeat_count = 32,
        scale = 0.66/2,
        shift = { 0.25 , 0 },
      }
    },
    {
      draw_as_shadow = true,
      animation_speed = 1,
      filename = "__alternative-beacons__/graphics/node-beacon-antenna-shadow.png",
      frame_count = 32,
      width = 63,
      height = 49,
      line_length = 8,
      scale = 0.66,
      shift = { 2+3/32 , 0+9/32 },
      hr_version = {
        draw_as_shadow = true,
        animation_speed = 1,
        filename = "__alternative-beacons__/graphics/hr-node-beacon-antenna-shadow.png",
        frame_count = 32,
        width = 63*2,
        height = 49*2,
        line_length = 8,
        scale = 0.66/2,
        shift = { 2+3/32 , 0+9/32 },
      }
    },
  }
}

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
    name = "ab-focused-beacon",
    icon = "__alternative-beacons__/graphics/focused-beacon-icon.png",
    icon_mipmaps = 1,
    icon_size = 64,
    flags = { "placeable-player", "player-creation" },
    minable = {
      mining_time = 0.2,
      result = "ab-focused-beacon"
    },
    allowed_effects = { "consumption", "speed", "pollution" },
    animation = beacon_animation,
    animation_shadow = blank_image,
    base_picture = blank_image,
    collision_box = { { -0.75, -0.75 }, { 0.75, 0.75 } },
    drawing_box = { { -1, -1.7 }, { 1, 1 } },
    selection_box = { { -1, -1 }, { 1, 1 } },
    corpse = "medium-remnants",
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
    energy_usage = "1200kW",
    max_health = 150,
    module_specification = {
      module_info_icon_shift = { 0, 0.25 },
      module_info_max_icons_per_row = 3,
      module_info_max_icon_rows = 1,
      module_slots = 3
    },
    distribution_effectivity = 0.75,
    supply_area_distance = 2, -- extends from edge of collision box (6x6)
    -- exclusion_area_distance = 3 (8x8; hardcoded in control.lua)
    radius_visualisation_picture = {
      layers = {
        {filename = "__alternative-beacons__/graphics/visualization/beacon-radius-visualization-focused.png", size = {11, 11}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-focused-top-left.png", shift = {-0.34375,-0.34375}, size = {11, 11}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-focused-top-mid.png", shift = {0,-0.34375}, size = {11, 11}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-focused-top-right.png", shift = {0.34375,-0.34375}, size = {11, 11}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-focused-mid-left.png", shift = {-0.34375,0}, size = {11, 11}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-focused-mid-right.png", shift = {0.34375,0}, size = {11, 11}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-focused-bottom-left.png", shift = {-0.34375,0.34375}, size = {11, 11}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-focused-bottom-mid.png", shift = {0,0.34375}, size = {11, 11}, priority = "extra-high-no-scale"},
        {filename = "__alternative-beacons__/graphics/visualization/brv-focused-bottom-right.png", shift = {0.34375,0.34375}, size = {11, 11}, priority = "extra-high-no-scale"}
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
