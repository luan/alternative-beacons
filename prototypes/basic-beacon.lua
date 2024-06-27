-- basic-beacon.lua

local item = {
  type = "item",
  name = "se-basic-beacon",
  place_result = "se-basic-beacon",
  icon = "__base__/graphics/icons/beacon.png",
  icon_size = 64,
  stack_size = 25,
  subgroup = "module",
  order = "a[beacon]i1"
}

local recipe = {
  type = "recipe",
  name = "se-basic-beacon",
  result = "se-basic-beacon",
  enabled = false,
  energy_required = 10,
  ingredients = {{type = "item", name = "advanced-circuit", amount = 60}, {type = "item", name = "electronic-circuit", amount = 60}, {type = "item", name = "copper-cable", amount = 30}, {type = "item", name = "steel-plate", amount = 30}},
}

local beacon = {
  type = "beacon",
  name = "se-basic-beacon",
  icon = "__base__/graphics/icons/beacon.png",
  icon_size = 64, icon_mipmaps = 4,
  flags = {"placeable-player", "player-creation"},
  minable = {mining_time = 0.2, result = "se-basic-beacon"},
  max_health = 200,
  corpse = "beacon-remnants",
  dying_explosion = "beacon-explosion",
  collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  damaged_trigger_effect = {
    entity_name = "spark-explosion",
    offset_deviation = { { -0.5, -0.5 }, { 0.5, 0.5 } },
    offsets = { { 0, 1 } },
    type = "create-entity"
  },
  drawing_box = {{-1.5, -2.2}, {1.5, 1.3}},
  allowed_effects = {"consumption", "speed", "pollution"},
  graphics_set = require("__base__/prototypes/entity/beacon-animations.lua"),
  radius_visualisation_picture =
  {
    filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png",
    priority = "extra-high-no-scale",
    size = {10, 10}
  },
  supply_area_distance = 3.05,
  energy_source =
  {
    type = "electric",
    usage_priority = "secondary-input"
  },
  vehicle_impact_sound = {
    {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-2.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-3.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-4.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-5.ogg", volume = 0.5},
    {filename = "__base__/sound/car-metal-impact-6.ogg", volume = 0.5}
  },
  open_sound = data.raw.beacon.beacon.open_sound,
  close_sound = data.raw.beacon.beacon.close_sound,
  working_sound =
  {
    sound =
    {
      {filename = "__base__/sound/beacon-1.ogg", volume = 0.2},
      {filename = "__base__/sound/beacon-2.ogg", volume = 0.2}
    },
    audible_distance_modifier = 0.33,
    max_sounds_per_type = 3
  },
  energy_usage = "100kW",
  distribution_effectivity = 0.5,
  module_specification =  {
    module_slots = 8, -- 
    module_info_icon_shift = {0, 0.5},
    module_info_multi_row_initial_height_modifier = -0.3,
    module_info_max_icons_per_row = 4, -- 
    module_info_max_icon_rows = 2 -- 
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

return {item = item, entity = beacon, recipe = recipe}