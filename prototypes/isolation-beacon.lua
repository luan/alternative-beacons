-- isolation-beacon.lua

local item = {
  type = "item",
  name = "ab-isolation-beacon",
  place_result = "ab-isolation-beacon",
  icon = "__alternative-beacons__/graphics/icon-isolation.png",
  icon_size = 64,
  stack_size = 20,
  subgroup = "module",
  order = "a[beacon]f"
}

local recipe = {
  type = "recipe",
  name = "ab-isolation-beacon",
  result = "ab-isolation-beacon",
  enabled = false,
  energy_required = 60,
  ingredients = {{type = "item", name = "advanced-circuit", amount = 400}, {type = "item", name = "electronic-circuit", amount = 400}, {type = "item", name = "copper-cable", amount = 200}, {type = "item", name = "steel-plate", amount = 200}},
  normal = { result = "ab-isolation-beacon", enabled = false, energy_required = 60, ingredients = {{type = "item", name = "advanced-circuit", amount = 400}, {type = "item", name = "electronic-circuit", amount = 400}, {type = "item", name = "copper-cable", amount = 200}, {type = "item", name = "steel-plate", amount = 200}} },
  expensive = { result = "ab-isolation-beacon", enabled = false, energy_required = 60, ingredients = {{type = "item", name = "advanced-circuit", amount = 400}, {type = "item", name = "electronic-circuit", amount = 400}, {type = "item", name = "copper-cable", amount = 200}, {type = "item", name = "steel-plate", amount = 200}} }
}

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
beacon_graphics.animation_list[1].animation.filename = "__alternative-beacons__/graphics/hr-isolation-off.png"

beacon_graphics.animation_list[2].always_draw = false
beacon_graphics.animation_list[2].animation.filename = "__alternative-beacons__/graphics/hr-isolation-animated.png"
beacon_graphics.animation_list[2].animation.line_length = 8
beacon_graphics.animation_list[2].animation.frame_count = 32
beacon_graphics.animation_list[2].animation.animation_speed = 0.5
beacon_graphics.animation_list[2].animation.draw_as_glow = true

beacon_graphics.animation_list[3].animation.draw_as_shadow = true
beacon_graphics.animation_list[3].animation.filename = "__alternative-beacons__/graphics/hr-isolation-shadow.png"
beacon_graphics.animation_list[3].animation.width = 366
beacon_graphics.animation_list[3].animation.height = 204
beacon_graphics.animation_list[3].animation.shift = {2, 0}

local beacon = {
  type = "beacon",
  name = "ab-isolation-beacon",
  icon = "__alternative-beacons__/graphics/icon-isolation.png",
  icon_mipmaps = 1,
  icon_size = 64,
  flags = { "placeable-player", "player-creation" },
  minable = {
    mining_time = 0.5,
    result = "ab-isolation-beacon"
  },
  allowed_effects = { "consumption", "speed", "pollution" },
  energy_source = {
    type = "electric",
    usage_priority = "secondary-input"
  },
  energy_usage = "40000kW",
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
  -- exclusion_area_distance = 38 (81x81 strict; hardcoded in control.lua)
  collision_box = { { -2.2, -2.2 }, { 2.2, 2.2 } },
  drawing_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
  selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
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
  corpse = "big-remnants"
}

local technology = {
  {
    icon = "__alternative-beacons__/graphics/tech-isolation.png",
    icon_size = 256
  },
}

return {item = item, entity = beacon, recipe = recipe, technology = technology}