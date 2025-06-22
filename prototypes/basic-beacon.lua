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
  results = {{type="item", name="se-basic-beacon", amount=1}},
  enabled = false,
  energy_required = 10,
  ingredients = {{type = "item", name = "advanced-circuit", amount = 60}, {type = "item", name = "electronic-circuit", amount = 60}, {type = "item", name = "copper-cable", amount = 30}, {type = "item", name = "steel-plate", amount = 30}},
}

local beacon = {
  type = "beacon",
  name = "se-basic-beacon",
  icon = "__base__/graphics/icons/beacon.png",
  icon_size = 64,
  icon_mipmaps = 4,
  flags = {"placeable-player", "player-creation"},
  minable = {mining_time = 0.2, result = "se-basic-beacon"},
  energy_source = {type = "electric", usage_priority = "secondary-input"},
  energy_usage = "100kW",
  heating_energy = "80kW",
  max_health = 200,
  collision_box = { { -1.25, -1.25 }, { 1.25, 1.25 } },
  drawing_box = { { -1.5, -2.2}, { 1.5, 1.3 } },
  selection_box = { { -1.5, -1.5}, { 1.5, 1.5 } },
  drawing_box_vertical_extension = 0.2,
  allowed_effects = {"consumption", "speed", "pollution"},
  distribution_effectivity = 0.5,
  distribution_effectivity_bonus_per_quality_level = 0.1,
  profile = {1,0},
  beacon_counter = "same_type",
  supply_area_distance = 3,
  module_slots = 8,
  icons_positioning = {{
    inventory_index = defines.inventory.beacon_modules,
    shift = {0, 0.5},
    max_icons_per_row = 4,
    max_icon_rows = 2,
    multi_row_initial_height_modifier = -0.3,
  }},
  graphics_set = require("__base__/prototypes/entity/beacon-animations.lua"),
  radius_visualisation_picture = {
    filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png",
    priority = "extra-high-no-scale",
    size = {10, 10}
  },
  water_reflection = {
    pictures = {
      filename = "__alternative-beacons-ex__/graphics/reflection-standard.png",
      priority = "extra-high",
      width = 18,
      height = 29,
      shift = util.by_pixel(0, 55),
      variation_count = 1,
      scale = 5
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
  corpse = "beacon-remnants",
}

if mods["space-age"] then
  local frozen_patch = {
    filename = "__space-age__/graphics/entity/frozen/beacon/beacon-frozen.png",
    height = 192,
    width = 212,
    scale = 0.5,
    shift = {0.015625, 0.03125}
  }
  beacon.graphics_set.frozen_patch = frozen_patch
end

if not feature_flags["freezing"] then beacon.heating_energy = nil end
if not feature_flags["quality"] then beacon.distribution_effectivity_bonus_per_quality_level = nil end

return {item = item, entity = beacon, recipe = recipe}