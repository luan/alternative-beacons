--- adjustments.lua

local adjustments = {}

function adjustments.adjust(beacons, custom_exclusion_ranges, max_moduled_building_size)

  if mods["Krastorio2"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    if not mods["space-exploration"] then -- singularity beacons are disabled if SE is also active
      localise("kr-singularity-beacon", {"item", "beacon"}, "description", {"description.kr_singularity"})
      localise("beacon", {"item", "beacon", "recipe"}, "name", {"name.ab-standard-beacon"})
      localise("beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_standard_kr_addon"}} })
      override_localisation = false
      if se_technologies then
        table.insert(data.raw.technology["se-compact-beacon-2"].prerequisites, "kr-singularity-tech-card")
        data.raw.technology["se-compact-beacon-2"].unit.ingredients = { {"production-science-pack", 1}, {"utility-science-pack", 1}, {"space-science-pack", 1}, {"matter-tech-card", 1}, {"advanced-tech-card", 1}, {"singularity-tech-card", 1} }
        table.insert(data.raw.technology["se-wide-beacon-2"].prerequisites, "kr-singularity-tech-card")
        data.raw.technology["se-wide-beacon-2"].unit.ingredients = data.raw.technology["se-compact-beacon-2"].unit.ingredients
      end
      for _,v in pairs(possible_techs) do
        if data.raw.technology[v] then data.raw.technology[v].unit.count = 500 end
      end
    end

    -- enables singularity beacons while Space Exploration is enabled
    if startup["ab-enable-k2-beacons"].value and mods["space-exploration"] then
      local recipe_singularity = {
        type = "recipe",
        name = "k2-singularity-beacon",
        result = "kr-singularity-beacon",
        enabled = false,
        energy_required = 10,
        ingredients = {{type = "item", name = "processing-unit", amount = 20}, {type = "item", name = "se-holmium-solenoid", amount = 10}, {type = "item", name = "energy-control-unit", amount = 10}, {type = "item", name = "ab-standard-beacon", amount = 1}}
      }
      data:extend({recipe_singularity})
      if data.raw.beacon["kr-singularity-beacon"] and data.raw.technology["se-compact-beacon"] then table.insert( data.raw.technology["se-compact-beacon"].effects, { type = "unlock-recipe", recipe = "k2-singularity-beacon" } ) end
      -- TODO: Add separate technology for singularity beacons?
      data.raw.beacon["kr-singularity-beacon"].selection_box = {{-1,-1}, {1, 1}}
      data.raw.beacon["kr-singularity-beacon"].drawing_box = {{-1,-1.5}, {1, 1}}
      data.raw.beacon["kr-singularity-beacon"].module_slots = 2
      data.raw.beacon["kr-singularity-beacon"].supply_area_distance = 2
      data.raw.item["kr-singularity-beacon"].place_result = "kr-singularity-beacon"
      data.raw.recipe["k2-singularity-beacon"].localised_name = {"name.kr_singularity"}
      localise("kr-singularity-beacon", {"item", "beacon"}, "name", {"name.kr_singularity"})
      localise("kr-singularity-beacon", {"item", "beacon"}, "description", {"description.kr_singularity"})
      -- TODO: Revert Compact Beacon 2 to using its original art?
    end
  end

  if mods["space-exploration"] then -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    for _, beacon in pairs(data.raw.beacon) do
      if not beacon["se_allow_in_space"] then beacon["se_allow_in_space"] = true end
    end
    --if ab_technologies == 1 then data.raw.technology["ab-novel-effect-transmission"].prerequisites = {"effect-transmission", "efficiency-module-3", "speed-module-3"} end
    for _,v in pairs(possible_techs) do
      if data.raw.technology[v] then
        for index,prerequisite in pairs(data.raw.technology[v].prerequisites) do
          if prerequisite == "efficiency-module-2" then data.raw.technology[v].prerequisites[index] = "efficiency-module-3" end
          if prerequisite == "speed-module-2" then data.raw.technology[v].prerequisites[index] = "speed-module-3" end
        end
      end
    end
    data.raw.recipe.beacon.order = "z-a[beacon]-a"
    data.raw.item.beacon.order = "z-a[beacon]-a"
    custom_exclusion_ranges["beacon"] = {value="solo", mode="strict"}
    localise("beacon", {"item", "beacon"}, "description", {"description.ab_strict"})
    localise("se-compact-beacon", {"item", "beacon"}, "description", {"description.ab_strict"})
    localise("se-compact-beacon-2", {"item", "beacon"}, "description", {"description.ab_strict"})
    localise("se-wide-beacon", {"item", "beacon"}, "description", {"description.ab_strict"})
    localise("se-wide-beacon-2", {"item", "beacon"}, "description", {"description.ab_strict"})
    data.raw.technology["se-compact-beacon"].localised_description = {"technology-description.se_compact"}
    if startup["ab-enable-k2-beacons"].value then data.raw.technology["se-compact-beacon"].localised_description = {"technology-description.k2se_compact"} end
    data.raw.technology["se-compact-beacon-2"].localised_description = {"technology-description.se_compact_2"}
    data.raw.technology["se-wide-beacon"].localised_description = {"technology-description.se_wide"}
    data.raw.technology["se-wide-beacon-2"].localised_description = {"technology-description.se_wide_2"}
    data.raw.technology["effect-transmission"].localised_description = {"technology-description.effect_transmission_default"}
    -- TODO: Disable beacon overloading or limit it to basic/compact/wide beacons
  end

  if mods["nullius"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    order_beacons("nullius-large-beacon-2", 2, "nullius-cx", "nullius-cx") -- the internal name/order for items/recipes/technologies needs to begin with "nullius-" for them to appear
    for tier=1,3,1 do
      localise("nullius-beacon-" .. tier, {"item", "beacon"}, "description", {"description.nullius"})
      if tier <= 2 then localise("nullius-large-beacon-" .. tier, {"item", "beacon"}, "description", {"description.nullius_large"}) end
      for count=1,4,1 do
        data.raw.beacon["nullius-beacon-" .. tier .. "-" .. count].localised_description = {'?', {'', {"description.nullius"}, ' ', {"description.nullius_1_2_3_4_addon", tostring(count)}} }
      end
    end
    data.raw.technology["nullius-broadcasting-2"].localised_description = {"technology-description.effect_transmission_default"}
    data.raw.technology["nullius-broadcasting-3"].localised_description = {"technology-description.effect_transmission_default"}
    data.raw.technology["nullius-broadcasting-4"].localised_description = {"technology-description.effect_transmission_default"}
    -- TODO: boxing/unboxing recipes?
  end

  if mods["exotic-industries"] then -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    for i=1,#beacons,1 do
      if data.raw.item[ beacons[i] ] then
        if beacons[i] == "beacon" or beacons[i] == "ab-standard-beacon" or beacons[i] == "se-basic-beacon" or (ab_technologies < 3 and beacons[i] == "ab-focused-beacon") or (ab_technologies < 2 and beacons[i] == "ab-node-beacon") or (ab_technologies == 0 and (beacons[i] == "ab-conflux-beacon" or beacons[i] == "ab-hub-beacon" or beacons[i] == "ab-isolation-beacon")) then
          table.insert( data.raw.technology["ei_copper-beacon"].effects, { type = "unlock-recipe", recipe = beacons[i] } )
        end
      end
    end
    localise("ei_copper-beacon", {"item", "beacon", "recipe"}, "name", {"name.ei_copper"})
    localise("ei_iron-beacon", {"item", "beacon", "recipe", "technology"}, "name", {"name.ei_iron"})
    localise("ei_copper-beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ei_both"}, '\n', {"description.ei_copper"}}})
    localise("ei_iron-beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ei_both"}, '\n', {"description.ei_iron"}}})
    localise("ei_alien-beacon", {"item", "beacon"}, "description", {"description.ab_bypass"})
    data.raw.technology["ei_copper-beacon"].localised_name = {"technology-name.effect_transmission_default"}
    data.raw.technology["ei_copper-beacon"].localised_description = {'?', {'', {"technology-description.effect_transmission_default"}, '\n\n', {"technology-description.ei_copper_addon"}}}
    data.raw.technology["ei_iron-beacon"].localised_description = {"technology-description.ei_iron"}
    max_moduled_building_size = math.max(11, max_moduled_building_size)
    -- TODO: Is there a way to make these beacons fair if beacon overloading is disabled in the settings? They can't be disabled since their liquid requirements already enable/disable them in a separate way.
    -- Note: beacon overloading seems to happen inconsistently in some cases when additional beacons are within 6 tiles but not affecting the machine due to their distribution ranges (different behavior depending on whether the machine or the additional beacon were placed last)
  end

  if mods["248k"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- beacons have 2/6/18 module slots and 3/4/5 range normally; with Space Exploration, they have 10/15/45 module slots and 5/9/18 range while each core has 5 module slots instead of 2
    local modules = {"2", "6", "6"}
    if mods["space-exploration"] then
      -- beacons cannot be returned to their original stats here or in data-final-fixes.lua (the relevant changes are overridden) so they are instead made into "solo" beacons and disable each other to mimic the same functionality they have with beacon overloading
      -- stats just match the new expected values so the descriptions will be correct (the actual stats will be overridden)
      data.raw.beacon["el_ki_beacon_entity"].supply_area_distance = 5
      data.raw.beacon["el_ki_beacon_entity"].module_slots = 10
      data.raw.beacon["fi_ki_beacon_entity"].supply_area_distance = 9
      data.raw.beacon["fi_ki_beacon_entity"].module_slots = 15
      data.raw.beacon["fu_ki_beacon_entity"].supply_area_distance = 18
      data.raw.beacon["fu_ki_beacon_entity"].module_slots = 45
      data.raw.beacon["el_ki_core_slave_entity"].module_slots = 5
      data.raw.beacon["fi_ki_core_slave_entity"].module_slots = 5
      data.raw.beacon["fu_ki_core_slave_entity"].module_slots = 5
      modules = {"5", "15", "15"}
    else
      -- the usual normalization somehow prevents 248k's beacons from interacting with machines at the correct range even though the visualization appears correct; the KI1 and KI3 beacons have a lower apparent range so those can be increased for a better approximation
      if math.ceil(get_distribution_range(data.raw.beacon["el_ki_beacon_entity"])) == 3 then data.raw.beacon["el_ki_beacon_entity"].supply_area_distance = data.raw.beacon["el_ki_beacon_entity"].supply_area_distance + 0.075 end
      if math.ceil(get_distribution_range(data.raw.beacon["fu_ki_beacon_entity"])) == 3 then data.raw.beacon["fu_ki_beacon_entity"].supply_area_distance = data.raw.beacon["fu_ki_beacon_entity"].supply_area_distance + 0.075 end
    end
    local ki_beacons = {"el_ki_beacon_entity", "fi_ki_beacon_entity", "fu_ki_beacon_entity"}
    for _, name in pairs(ki_beacons) do
      local entity = data.raw.beacon[name]
      entity.radius_visualisation_picture.filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png"
      entity.radius_visualisation_picture.size = {10, 10}
      --entity.drawing_box = entity.selection_box
      local min = 0.3
      if entity.collision_box[1][1] - min < entity.selection_box[1][1] then entity.collision_box[1][1] = entity.selection_box[1][1] + min end
      if entity.collision_box[1][2] - min < entity.selection_box[1][2] then entity.collision_box[1][2] = entity.selection_box[1][2] + min end
      if entity.collision_box[2][1] + min > entity.selection_box[2][1] then entity.collision_box[2][1] = entity.selection_box[2][1] - min end
      if entity.collision_box[2][2] + min > entity.selection_box[2][2] then entity.collision_box[2][2] = entity.selection_box[2][2] - min end
    end
    data.raw.item["el_ki_beacon_item"].localised_description = {"description.ki_1_2", modules[1]}
    data.raw.item["fi_ki_beacon_item"].localised_description = {"description.ki_1_2", modules[2]}
    data.raw.item["fu_ki_beacon_item"].localised_description = {"description.ki_3", modules[3]}
    data.raw.beacon["el_ki_beacon_entity"].localised_description = {"description.ki_1_2", modules[1]}
    data.raw.beacon["fi_ki_beacon_entity"].localised_description = {"description.ki_1_2", modules[2]}
    data.raw.beacon["fu_ki_beacon_entity"].localised_description = {"description.ki_3", modules[3]}
    if mods["informatron"] or mods["Booktorio"] then
      data.raw.item["el_ki_core_item"].localised_description = {'?', {'', {"description.ki_core_1"}, ' ', {"description.ki_core_item_addon"}}}
      data.raw.item["fi_ki_core_item"].localised_description = {'?', {'', {"description.ki_core_2_3"}, ' ', {"description.ki_core_item_addon"}}}
      data.raw.item["fu_ki_core_item"].localised_description = {'?', {'', {"description.ki_core_2_3"}, ' ', {"description.ki_core_item_addon"}}}
    else
      data.raw.item["el_ki_core_item"].localised_description = {"description.ki_core_1"}
      data.raw.item["fi_ki_core_item"].localised_description = {"description.ki_core_1"}
      data.raw.item["fu_ki_core_item"].localised_description = {"description.ki_core_1"}
    end
    data.raw["assembling-machine"]["el_ki_core_entity"].localised_description = {"description.ki_core_1"}
    data.raw["assembling-machine"]["fi_ki_core_entity"].localised_description = {"description.ki_core_2_3"}
    data.raw["assembling-machine"]["fu_ki_core_entity"].localised_description = {"description.ki_core_2_3"}
    data.raw.beacon["el_ki_core_slave_entity"].localised_description = {"description.ki_core_slave_entity_1"}
    data.raw.beacon["fi_ki_core_slave_entity"].localised_description = {"description.ki_core_slave_entity_2_3"}
    data.raw.beacon["fu_ki_core_slave_entity"].localised_description = {"description.ki_core_slave_entity_2_3"}
  end

  if mods["pycoalprocessing"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- replacement standard beacon may be enabled in data.lua
    -- beacon recipe unlocks are added to "diet-beacon" instead of "effect-transmission" in data.lua
    order_beacons("beacon", 2, "a[beacon]x", "a[beacon]x")
    for _,v in pairs(possible_techs) do
      if data.raw.technology[v] then
        data.raw.technology[v].unit = data.raw.technology["diet-beacon"].unit
        for index,prerequisite in pairs(data.raw.technology[v].prerequisites) do
          if prerequisite == "effect-transmission" then data.raw.technology[v].prerequisites[index] = "diet-beacon" end
        end
      end
    end
    table.insert(data.raw.technology["effect-transmission"].prerequisites, "diet-beacon")
    if se_technologies then
      data.raw.technology["se-compact-beacon"].prerequisites = {"diet-beacon", "efficiency-module-2", "speed-module-2"}
      data.raw.technology["se-compact-beacon"].unit = data.raw.technology["diet-beacon"].unit
      data.raw.technology["se-wide-beacon"].prerequisites = {"diet-beacon", "efficiency-module-2", "speed-module-2"}
      data.raw.technology["se-wide-beacon"].unit = data.raw.technology["diet-beacon"].unit
      data.raw.technology["se-compact-beacon-2"].prerequisites = {"se-compact-beacon", "effect-transmission", "efficiency-module-3", "speed-module-3"}
      data.raw.technology["se-compact-beacon-2"].unit = data.raw.technology["effect-transmission"].unit
      data.raw.technology["se-wide-beacon-2"].prerequisites = {"se-wide-beacon", "effect-transmission", "efficiency-module-3", "speed-module-3"}
      data.raw.technology["se-wide-beacon-2"].unit = data.raw.technology["se-compact-beacon-2"].unit
    end
    data.raw.item["beacon"].localised_description = {"description.py_AM_FM"}
    data.raw.technology["diet-beacon"].localised_name = {"technology-name.py_diet_transmission"}
    data.raw.technology["diet-beacon"].localised_description = {'?', {'', {"technology-description.effect_transmission_default"}, '\n\n', {"technology-description.py_diet_addon"}}}
    data.raw.technology["effect-transmission"].localised_description = {"technology-description.py_main"}
    for am=1,5,1 do
      for fm=1,5,1 do
        data.raw.beacon["beacon-AM" .. tostring(am) .. "-FM" .. tostring(fm)].localised_description = {"description.py_AM_FM"}
        data.raw.beacon["diet-beacon-AM" .. tostring(am) .. "-FM" .. tostring(fm)].localised_description = {"description.py_AM_FM"}
        custom_exclusion_ranges["beacon-AM" .. am .. "-FM" .. fm] = {value = "solo", mode = "strict"}
        custom_exclusion_ranges["diet-beacon-AM" .. am .. "-FM" .. fm] = {value = "solo", mode = "strict"}
      end
    end
    max_moduled_building_size = math.max(11, max_moduled_building_size)
    if mods["pypetroleumhandling"] then max_moduled_building_size = math.max(15, max_moduled_building_size) end
    --if mods["pyrawores"] then max_moduled_building_size = 19 end -- the only module-able structures larger than 15x15 are the aluminum mine (19x19) and titanium mine (23x23); TODO: test whether belts even have the throughput to support 4x the normal maximum for larger buildings like this
    exclusion_range_values["beacon"] = 64 + max_moduled_building_size-1
  end

  if mods["Ultracube"] then -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    for i=1,#beacons,1 do
      if data.raw.item[ beacons[i] ] then
        table.insert( data.raw.technology["cube-beacon"].effects, { type = "unlock-recipe", recipe = beacons[i] } )
        data.raw.beacon[ beacons[i] ].distribution_effectivity = data.raw.beacon[ beacons[i] ].distribution_effectivity * 0.2
      end
    end
    cancel_override = true
    localise("cube-beacon", {"item", "beacon", "recipe"}, "name", {"name.ultra_cube"})
    localise("cube-beacon", {"item", "beacon"}, "description", {"description.ultra_cube"})
    data.raw["assembling-machine"]["cube-beacon-fluid-source"].localised_name = {"name.ultra_cube"}
    data.raw["assembling-machine"]["cube-beacon-fluid-source"].localised_description = {"description.ultra_cube"}
    data.raw.technology["cube-beacon"].localised_description = {'?', {'', {"technology-description.effect_transmission_default"}, ' ', {"technology-description.ultra_cube_addon"}}}
    -- TODO: Disable beacon overloading or limit it to arcane beacons, make arcane beacons strict?
  end

  if mods["5dim_module"] or mods["OD27_5dim_module"] then -----------------------------------------------------------------------------------------------------------------------------------------------------
    data.raw.recipe.beacon.order = "a[beacon]"
    data.raw.item.beacon.order = "a[beacon]"
    if mods["pycoalprocessing"] then
      localise("ab-standard-beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_standard_tiers_addon"}} })
      data.raw.recipe["beacon"].icon = data.raw.item["beacon"].icon
      order_beacons("beacon-mk01", 2, "x[beacon]x", "x")
    else
      localise("beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_standard_tiers_addon"}} })
      order_beacons("beacon", 2, "x[beacon]x", "x")
    end
    override_localisation = false
    for tier=2,10,1 do
      local kind = "ab_same"
      local tier_string = "0" .. tier
      if tier <= 4 then kind = "ab_standard" end
      if tier > 9 then tier_string = tostring(tier) end
      localise("5d-beacon-" .. tier_string, {"item", "beacon"}, "description", {"description." .. kind})
    end
    -- Balance: rescaled linearly at +0.2 module power per tier; beacons with 3 range won't disable standard beacons and vice versa
    if startup["ab-balance-other-beacons"].value then
      local eff = data.raw.beacon["beacon"].distribution_effectivity/0.5
      data.raw.beacon["5d-beacon-02"].energy_usage = "960kW"
      data.raw.beacon["5d-beacon-02"].distribution_effectivity = 0.6*eff
      data.raw.beacon["5d-beacon-02"].module_slots = 2
      data.raw.beacon["5d-beacon-03"].energy_usage = "1440kW"
      data.raw.beacon["5d-beacon-03"].distribution_effectivity = 0.4667*eff
      data.raw.beacon["5d-beacon-03"].module_slots = 3
      data.raw.beacon["5d-beacon-04"].energy_usage = "2000kW"
      data.raw.beacon["5d-beacon-04"].distribution_effectivity = 0.4*eff
      data.raw.beacon["5d-beacon-04"].module_slots = 4
      data.raw.beacon["5d-beacon-05"].energy_usage = "2500kW"
      data.raw.beacon["5d-beacon-05"].distribution_effectivity = 0.36*eff
      data.raw.beacon["5d-beacon-05"].module_slots = 5
      data.raw.beacon["5d-beacon-05"].icons_positioning[1].max_icons_per_row = 3
      data.raw.beacon["5d-beacon-06"].energy_usage = "3000kW"
      data.raw.beacon["5d-beacon-06"].distribution_effectivity = 0.4*eff
      data.raw.beacon["5d-beacon-06"].module_slots = 5
      data.raw.beacon["5d-beacon-06"].icons_positioning[1].max_icons_per_row = 3
      data.raw.beacon["5d-beacon-07"].energy_usage = "3500kW"
      data.raw.beacon["5d-beacon-07"].distribution_effectivity = 0.3667*eff
      data.raw.beacon["5d-beacon-07"].module_slots = 6
      data.raw.beacon["5d-beacon-07"].icons_positioning[1].max_icons_per_row = 3
      data.raw.beacon["5d-beacon-08"].energy_usage = "4000kW"
      data.raw.beacon["5d-beacon-08"].distribution_effectivity = 0.4*eff
      data.raw.beacon["5d-beacon-08"].module_slots = 6
      data.raw.beacon["5d-beacon-08"].icons_positioning[1].max_icons_per_row = 3
      data.raw.beacon["5d-beacon-09"].energy_usage = "4500kW"
      data.raw.beacon["5d-beacon-09"].distribution_effectivity = 0.3715*eff
      data.raw.beacon["5d-beacon-09"].module_slots = 7
      data.raw.beacon["5d-beacon-09"].icons_positioning[1].max_icons_per_row = 4
      data.raw.beacon["5d-beacon-10"].energy_usage = "5000kW"
      data.raw.beacon["5d-beacon-10"].distribution_effectivity = 0.4*eff
      data.raw.beacon["5d-beacon-10"].module_slots = 7
      data.raw.beacon["5d-beacon-10"].icons_positioning[1].max_icons_per_row = 4
    end
  end

  if mods["Advanced_Modules"] or mods["Advanced_Sky_Modules"] or mods["Advanced_beacons"] then ------------------------------------------------------------------------------------------------------------
    -- same names used among these three mods; productivity beacons have 0.5/0.75/1.0 efficiency, 2/4/6 module slots, 3 range, and 480/240/120 kW power usage; speed beacons are the same except they have 6 range (in the "sky" version they have 1?/0.75/2 efficiency, 2/8/12 module slots, and 8/12/20 range); efficiency beacons have 1/2/4 efficiency, 2 module slots, 9/18/36 range, and 240/120/60 kW power usage
    local kinds = {"clean", "speed", "productivity"}
    for index, kind in pairs(kinds) do
      for tier=1,3,1 do
        localise(kind .. "-beacon-" .. tier, {"item", "beacon"}, "description", {'?', {'', {"description.ab_same"}, ' ', {"description." .. kind .. "_1_2_3_addon"}}})
        data.raw.beacon[kind .. "-beacon-" .. tier].radius_visualisation_picture.filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png"
      end
    end
    data.raw["item-group"]["a-modules"].localised_name = {"name.advanced-modules-group"} -- fixes item group spelling & scale
    data.raw["item-group"]["a-modules"].icon_size = 256
    --data.raw["item-group"]["a-modules"].icon_mipmaps = 4
    -- Beacons/modules only getting speed or productivity effects is not a downside (those are the most powerful effects) so these mods canot be balanced to the same level as others without also modifying module stats
    -- Balance: productivity beacons have lower range and are given +3/+4/+5 exclusion range, speed beacons are given +0/+2/+5 exclusion range
    if startup["ab-balance-other-beacons"].value then
      data.raw.beacon["productivity-beacon-1"].energy_usage = "1000kW"
      data.raw.beacon["productivity-beacon-1"].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity/2 -- 0.25
      data.raw.beacon["productivity-beacon-1"].supply_area_distance = 2
      custom_exclusion_ranges["productivity-beacon-1"] = {add=3}
      data.raw.beacon["productivity-beacon-2"].energy_usage = "2500kW"
      data.raw.beacon["productivity-beacon-2"].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity/2 -- 0.25
      data.raw.beacon["productivity-beacon-2"].supply_area_distance = 2
      custom_exclusion_ranges["productivity-beacon-2"] = {add=4}
      data.raw.beacon["productivity-beacon-3"].energy_usage = "6000kW"
      data.raw.beacon["productivity-beacon-3"].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity/2 -- 0.25
      data.raw.beacon["productivity-beacon-3"].supply_area_distance = 2
      custom_exclusion_ranges["productivity-beacon-3"] = {add=5}
      data.raw.beacon["speed-beacon-1"].energy_usage = "1000kW"
      data.raw.beacon["speed-beacon-1"].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity -- 0.5
      data.raw.beacon["speed-beacon-1"].supply_area_distance = 6
      data.raw.beacon["speed-beacon-2"].energy_usage = "2500kW"
      data.raw.beacon["speed-beacon-2"].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity -- 0.5
      data.raw.beacon["speed-beacon-2"].module_slots = 4
      data.raw.beacon["speed-beacon-2"].supply_area_distance = 6
      custom_exclusion_ranges["speed-beacon-2"] = {add=2}
      data.raw.beacon["speed-beacon-3"].energy_usage = "6000kW"
      data.raw.beacon["speed-beacon-3"].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity -- 0.5
      data.raw.beacon["speed-beacon-3"].module_slots = 6
      data.raw.beacon["speed-beacon-3"].supply_area_distance = 6
      custom_exclusion_ranges["speed-beacon-3"] = {add=5}
      localise("productivity-beacon-1", {"item", "beacon"}, "description", {'?', {'', {"description.ab_same"}, ' ', {"description.productivity_1_2_3_addon"}}})
      localise("productivity-beacon-2", {"item", "beacon"}, "description", {'?', {'', {"description.ab_same"}, ' ', {"description.productivity_1_2_3_addon"}}})
      localise("productivity-beacon-3", {"item", "beacon"}, "description", {'?', {'', {"description.ab_same"}, ' ', {"description.productivity_1_2_3_addon"}}})
      localise("speed-beacon-2", {"item", "beacon"}, "description", {'?', {'', {"description.ab_same"}, ' ', {"description.speed_1_2_3_addon"}}})
      localise("speed-beacon-3", {"item", "beacon"}, "description", {'?', {'', {"description.ab_same"}, ' ', {"description.speed_1_2_3_addon"}}})
      -- TODO: Balance efficiency beacons?
    end
  end

  if mods["bobmodules"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- same names as Endgame Extension and Beacon 2; beacon-2 has 6 range, 4 modules, and 0.75 efficiency; beacon-3 has 9 range, 6 modules, and 1.0 efficiency (they both use 480 kW power, same as the vanilla beacon) ...assemblers could get 12000% speed instead of 600%
    localise("beacon-2", {"item", "beacon"}, "description", {"description.ab_same"})
    localise("beacon-3", {"item", "beacon"}, "description", {"description.ab_same"})
    if mods["CoppermineBobModuleRebalancing"] and startup["coppermine-bob-module-nerfed-beacons"] and startup["coppermine-bob-module-nerfed-beacons"].value then -- let other mods handle balance if they're more specialised for it
      -- beacon-2 changed to 3 modules, 5 range, 1 MW power; beacon-3 changed to 4 modules, 7 range, 1.5 MW (both keep their previous efficiency: 0.75 and 1.0)
      override_descriptions["beacon-2"] = {slots=3, d_range=5}
      override_descriptions["beacon-3"] = {slots=4, d_range=7}
    elseif mods["SeaBlockMetaPack"] then
      -- beacons changed to 2 modules and 0.5 efficiency each, beacon-2 uses 960 KW, beacon-3 uses 1.92 MW, also adjusts module startup settings and hides them ...assemblers could get 3000% speed instead of 600%
      -- Balance: beacons have smaller exclusion areas than distribution areas and don't disable or get disabled by standard beacons
      custom_exclusion_ranges["beacon-2"] = {add=-3}
      custom_exclusion_ranges["beacon-3"] = {add=-6}
      localise("beacon-2", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except_small"}, ' ', {"description.ab_standard_addon"}} })
      localise("beacon-3", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except_small"}, ' ', {"description.ab_standard_addon"}} })
    elseif startup["ab-balance-other-beacons"].value then
      -- Balance: power requirements adjusted upward, efficiencies reduced, reduced range of beacon-2, beacon-3 given +2 exclusion range; they are still superior to node/conflux beacons, although they are at least somewhat comparable now
      data.raw.beacon["beacon-2"].energy_usage = "3000kW"
      data.raw.beacon["beacon-2"].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity -- 0.5
      data.raw.beacon["beacon-2"].supply_area_distance = 5
      data.raw.beacon["beacon-3"].energy_usage = "6000kW"
      data.raw.beacon["beacon-3"].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity -- 0.5
      custom_exclusion_ranges["beacon-3"] = {add=2}
      localise("beacon-3", {"item", "beacon"}, "description", {"description.ab_different"})
    end
  end

  if mods["EndgameExtension"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- same names as Bob's and Beacon 2; beacon-2 has 5 range, 0.75 efficiency, 3 module slots; beacon-3 has 7 range, 1.0 efficiency, 5 module slots; productivity-beacon has 3 range, 1.0 efficiency, 5 module slots
    localise("beacon-2", {"item", "beacon"}, "description", {"description.ab_same"})
    localise("beacon-3", {"item", "beacon"}, "description", {"description.ab_same"})
    localise("productivity-beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_same"}, ' ', {"description.productivity_addon"}}})
    local beacons = {"beacon-2", "beacon-3", "productivity-beacon"}
    for index, name in pairs(beacons) do
      data.raw.recipe[name].order = "a[beacon]n2[" .. name .. "]"
      data.raw.item[name].order = "a[beacon]n2[" .. name .. "]"
    end
    -- Balance: beacon-2 and beacon-3 changed to match Bob's versions since they're similar enough; productivity beacon given +3 exclusion range
    if startup["ab-balance-other-beacons"].value then
      data.raw.beacon["beacon-2"].energy_usage = "3000kW"
      data.raw.beacon["beacon-2"].max_health = 300
      data.raw.beacon["beacon-2"].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity -- 0.5
      data.raw.beacon["beacon-2"].module_slots = 4
      data.raw.beacon["beacon-3"].energy_usage = "6000kW"
      data.raw.beacon["beacon-3"].max_health = 400
      data.raw.beacon["beacon-3"].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity -- 0.5
      data.raw.beacon["beacon-3"].module_slots = 6
      data.raw.beacon["beacon-3"].supply_area_distance = 9
      custom_exclusion_ranges["beacon-3"] = {add=2}
      custom_exclusion_ranges["productivity-beacon"] = {add=3}
      localise("beacon-3", {"item", "beacon"}, "description", {"description.ab_different"})
      localise("productivity-beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_different"}, ' ', {"description.productivity_addon"}}})
    end
  end

  if mods["Beacon2"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- same name as Bob's and Endgame Extension; beacon-2 has 3 range, 0.5 efficiency, 4 module slots
    localise("beacon-2", {"item", "beacon"}, "description", {"description.ab_standard"})
    localise("beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_standard_tiers_addon"}} })
    -- Balance: doesn't disable standard beacons or vice versa
  end

  if mods["FactorioExtended-Plus-Module"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- same names as Zombies Extended: beacon-mk2, beacon-mk3; beacons have 3 range and 2 module slots with 0.75 and 1.0 efficiency each
    -- Balance: these don't disable standard beacons or vice versa
    localise("beacon-mk2", {"item", "beacon"}, "description", {"description.ab_standard"})
    localise("beacon-mk3", {"item", "beacon"}, "description", {"description.ab_standard"})
    localise("beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_standard_tiers_addon"}} })
  end

  if mods["zombiesextended-modules"] then -----------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- same names as Factorio Extended: beacon-mk1, beacon-mk2, beacon-mk3; beacons have 3 range and 2 module slots with 1, 2, and 3 efficiency each
    localise("beacon-mk1", {"item", "beacon"}, "description", {"description.ab_standard"})
    localise("beacon-mk2", {"item", "beacon"}, "description", {"description.ab_standard"})
    localise("beacon-mk3", {"item", "beacon"}, "description", {"description.ab_standard"})
    localise("beacon", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_standard_tiers_addon"}} })
    -- Balance: rescaled to max out at 1 efficiency instead of 3 (similar to Factorio Extended); they don't disable standard beacons and vice versa
    if startup["ab-balance-other-beacons"].value then
      local eff = data.raw.beacon["beacon"].distribution_effectivity/0.5
      data.raw.beacon["beacon-mk1"].distribution_effectivity = 0.65*eff
      data.raw.beacon["beacon-mk2"].distribution_effectivity = 0.8*eff
      data.raw.beacon["beacon-mk3"].distribution_effectivity = 1*eff
    end
  end

  if mods["BeaconMk2"] then -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- beaconmk2 has 5 range, 0.5 efficiency, 4 module slots
    localise("beaconmk2", {"item", "beacon"}, "description", {"description.ab_same"})
    data.raw.recipe["beaconmk2"].order = "a[beacon]mk2"
    data.raw.item["beaconmk2"].order = "a[beacon]mk2"
  end

  if mods["beacons"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- beacon2 has 4 range, 0.75 efficiency, 4 module slots; beacon3 has 5 range, 1.0 efficiency, 6 module slots
    for tier=2,3,1 do
      localise("beacon" .. tostring(tier), {"item", "beacon"}, "description", {"description.ab_same"})
      data.raw.recipe["beacon" .. tostring(tier)].order = "a[beacon]n" .. tostring(tier)
      data.raw.item["beacon" .. tostring(tier)].order = "a[beacon]n" .. tostring(tier)
    end
    -- Balance: reduced efficiency, increased range, beacon3 gains +2 exclusion range
    if startup["ab-balance-other-beacons"].value then
      data.raw.beacon["beacon2"].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity -- 0.5
      data.raw.beacon["beacon2"].supply_area_distance = 5
      data.raw.beacon["beacon3"].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity -- 0.5
      data.raw.beacon["beacon3"].supply_area_distance = 6
      custom_exclusion_ranges["beacon3"] = {add=2}
      localise("beacon3", {"item", "beacon"}, "description", {"description.ab_different"})
    end
  end
--function generate_new_beacon(base_name, name, localised_name, localised_description, size, range, modules, efficiency, power, effects)
  if mods["mini-machines"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- mini-beacon-1 and other mini beacons are 2x2
    if startup["mini-beacon"].value == true then
      if startup["ab-balance-other-beacons"].value == true then
        local eff = data.raw.beacon["beacon"].distribution_effectivity/0.5
        local profile = {1, 0.7071, 0.5773, 0.5, 0.4472, 0.4082, 0.3779, 0.3535, 0.3333, 0.3162, 0.3015, 0.2887, 0.2773, 0.2672, 0.2582, 0.25, 0.2425, 0.2357, 0.2294, 0.2236, 0.2182, 0.2132, 0.2085, 0.2041, 0.2, 0.1961, 0.1924, 0.189, 0.1857, 0.1825, 0.1796, 0.1768, 0.1741, 0.1715, 0.169, 0.1666, 0.1644, 0.1622, 0.1601, 0.1581, 0.1561, 0.1543, 0.1525, 0.1507, 0.149, 0.1474, 0.1458, 0.1443, 0.1428, 0.1414, 0.14, 0.1387, 0.1373, 0.1361, 0.1348, 0.1336, 0.1324, 0.1313, 0.1302, 0.1291, 0.128, 0.127, 0.126, 0.125, 0.124, 0.1231, 0.1221, 0.1212, 0.1204, 0.1195, 0.1187, 0.1178, 0.117, 0.1162, 0.1154, 0.1147, 0.1139, 0.1132, 0.1125, 0.1118, 0.1111, 0.1104, 0.1097, 0.1091, 0.1084, 0.1078, 0.1072, 0.1066, 0.106, 0.1054, 0.1048, 0.1042, 0.1037, 0.1031, 0.1026, 0.102, 0.1015, 0.101, 0.1005, 0.1}
        -- Balance: range scaled down to match size difference, efficiency (and module slots in some cases) adjusted so that the module power is roughly 3/4 of the full-size version ...mini-beacon-2 and mini-beacon-3 are based on the non-seablock versions, but still can be used if seablock is active
        if data.raw.beacon["ab-standard-beacon"] then
          generate_new_beacon("ab-standard-beacon", "mini-beacon-1", "Mini standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, 2, 2, 0.375*eff, "360kW")
        else
          generate_new_beacon("beacon", "mini-beacon-1", "Mini standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, 2, 2, 0.375*eff, "360kW")
        end
        if mods["bobmodules"] then
          generate_new_beacon("beacon-2", "mini-beacon-2", "Mini beacon 2", {"description.ab_same"}, 2, 4, 3, 0.5*eff, "2250kW")
          generate_new_beacon("beacon-3", "mini-beacon-3", "Mini beacon 3", {"description.ab_different"}, 2, 6, 5, 0.5*eff, "4500kW")
          custom_exclusion_ranges["mini-beacon-3"] = {add = 2}
        elseif mods["FactorioExtended-Plus-Module"] then
          localise("mini-beacon-1", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_tiers_addon"}}})
          generate_new_beacon("beacon-mk2", "mini-beacon-2", "Mini beacon Mk2", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, 2, 2, 0.55*eff, "450kW")
          generate_new_beacon("beacon-mk3", "mini-beacon-3", "Mini beacon Mk3", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, 2, 2, 0.75*eff, "540kW")
        elseif mods["5dim_module"] then
          localise("mini-beacon-1", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_tiers_addon"}}})
          generate_new_beacon("5d-beacon-02", "mini-beacon-2", "Mini beacon MK2", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, 2, 2, 0.45*eff, "720kW")
          generate_new_beacon("5d-beacon-03", "mini-beacon-3", "Mini beacon MK3", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, 2, 2, 0.5*eff, "1080kW")
        end
        if mods["5dim_module"] then
          generate_new_beacon("5d-beacon-04", "mini-beacon-4", "Mini beacon MK4", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, 2, 2, 0.55*eff, "1500kW")
          generate_new_beacon("5d-beacon-05", "mini-beacon-5", "Mini beacon MK5", {"description.ab_same"}, 2, 3, 3, 0.4*eff, "1875kW")
          generate_new_beacon("5d-beacon-06", "mini-beacon-6", "Mini beacon MK6", {"description.ab_same"}, 2, 3, 3, 0.4667*eff, "2250kW")
          generate_new_beacon("5d-beacon-07", "mini-beacon-7", "Mini beacon MK7", {"description.ab_same"}, 2, 4, 3, 0.5334*eff, "2625kW")
          generate_new_beacon("5d-beacon-08", "mini-beacon-8", "Mini beacon MK8", {"description.ab_same"}, 2, 4, 4, 0.45*eff, "3000kW")
          generate_new_beacon("5d-beacon-09", "mini-beacon-9", "Mini beacon MK9", {"description.ab_same"}, 2, 5, 4, 0.5*eff, "3375kW")
          generate_new_beacon("5d-beacon-10", "mini-beacon-10", "Mini beacon MK10", {"description.ab_same"}, 2, 5, 4, 0.55*eff, "3750kW")
        end
      else
        local fewer_modules = 0
        if startup["mini-balance-module"].value == true then fewer_modules = 1 end
        if data.raw.beacon["ab-standard-beacon"] then
          generate_new_beacon("ab-standard-beacon", "mini-beacon-1", "Mini standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, nil, math.max(1, data.raw.beacon["ab-standard-beacon"].module_slots-fewer_modules))
        else
          generate_new_beacon("beacon", "mini-beacon-1", "Mini standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_mini_addon"}}}, 2, nil, math.max(1, data.raw.beacon["beacon"].module_slots-fewer_modules))
        end
        if mods["bobmodules"] then
          generate_new_beacon("beacon-2", "mini-beacon-2", "Mini beacon 2", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["beacon-2"].module_slots-fewer_modules))
          generate_new_beacon("beacon-3", "mini-beacon-3", "Mini beacon 3", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["beacon-3"].module_slots-fewer_modules))
        elseif mods["FactorioExtended-Plus-Module"] then
          generate_new_beacon("beacon-mk2", "mini-beacon-2", "Mini beacon Mk2", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["beacon-mk2"].module_slots-fewer_modules))
          generate_new_beacon("beacon-mk3", "mini-beacon-3", "Mini beacon Mk3", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["beacon-mk3"].module_slots-fewer_modules))
        elseif mods["5dim_module"] then
          generate_new_beacon("5d-beacon-02", "mini-beacon-2", "Mini beacon MK2", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-02"].module_slots-fewer_modules))
          generate_new_beacon("5d-beacon-03", "mini-beacon-3", "Mini beacon MK3", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-03"].module_slots-fewer_modules))
        end
        if mods["5dim_module"] then
          generate_new_beacon("5d-beacon-04", "mini-beacon-4", "Mini beacon MK4", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-04"].module_slots-fewer_modules))
          generate_new_beacon("5d-beacon-05", "mini-beacon-5", "Mini beacon MK5", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-05"].module_slots-fewer_modules))
          generate_new_beacon("5d-beacon-06", "mini-beacon-6", "Mini beacon MK6", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-06"].module_slots-fewer_modules))
          generate_new_beacon("5d-beacon-07", "mini-beacon-7", "Mini beacon MK7", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-07"].module_slots-fewer_modules))
          generate_new_beacon("5d-beacon-08", "mini-beacon-8", "Mini beacon MK8", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-08"].module_slots-fewer_modules))
          generate_new_beacon("5d-beacon-09", "mini-beacon-9", "Mini beacon MK9", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-09"].module_slots-fewer_modules))
          generate_new_beacon("5d-beacon-10", "mini-beacon-10", "Mini beacon MK10", {"description.ab_same"}, 2, nil, math.max(1, data.raw.beacon["5d-beacon-10"].module_slots-fewer_modules))
        end
      end
      data.raw.item["mini-beacon-1"].order = "a[beacon]-1-z"
      data.raw.recipe["mini-beacon-1"].order = "a[beacon]-1-z"
    end
  end

  if mods["micro-machines"] then --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- micro-beacon-1 and other micro beacons are 1x1
    if startup["micro-beacon"].value == true then
      if startup["ab-balance-other-beacons"].value == true then
        local eff = data.raw.beacon["beacon"].distribution_effectivity/0.5
        local profile = {1, 0.7071, 0.5773, 0.5, 0.4472, 0.4082, 0.3779, 0.3535, 0.3333, 0.3162, 0.3015, 0.2887, 0.2773, 0.2672, 0.2582, 0.25, 0.2425, 0.2357, 0.2294, 0.2236, 0.2182, 0.2132, 0.2085, 0.2041, 0.2, 0.1961, 0.1924, 0.189, 0.1857, 0.1825, 0.1796, 0.1768, 0.1741, 0.1715, 0.169, 0.1666, 0.1644, 0.1622, 0.1601, 0.1581, 0.1561, 0.1543, 0.1525, 0.1507, 0.149, 0.1474, 0.1458, 0.1443, 0.1428, 0.1414, 0.14, 0.1387, 0.1373, 0.1361, 0.1348, 0.1336, 0.1324, 0.1313, 0.1302, 0.1291, 0.128, 0.127, 0.126, 0.125, 0.124, 0.1231, 0.1221, 0.1212, 0.1204, 0.1195, 0.1187, 0.1178, 0.117, 0.1162, 0.1154, 0.1147, 0.1139, 0.1132, 0.1125, 0.1118, 0.1111, 0.1104, 0.1097, 0.1091, 0.1084, 0.1078, 0.1072, 0.1066, 0.106, 0.1054, 0.1048, 0.1042, 0.1037, 0.1031, 0.1026, 0.102, 0.1015, 0.101, 0.1005, 0.1}
        -- Balance: range scaled down to match size difference, most only have 1 module slot, efficiency adjusted so that the module power is roughly half of the full-size version ...micro-beacon-2 and micro-beacon-3 are based on the non-seablock versions, but still can be used if seablock is active
        if data.raw.beacon["ab-standard-beacon"] then
          generate_new_beacon("ab-standard-beacon", "micro-beacon-1", "Micro standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1, 1, 1, 0.5*eff, "240kW")
        else
          generate_new_beacon("beacon", "micro-beacon-1", "Micro standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1, 1, 1, 0.5*eff, "240kW")
        end
        if mods["bobmodules"] then
          generate_new_beacon("beacon-2", "micro-beacon-2", "Micro beacon 2", {"description.ab_same"}, 1, 2, 2, 0.5*eff, "1500kW")
          generate_new_beacon("beacon-3", "micro-beacon-3", "Micro beacon 3", {"description.ab_different"}, 1, 3, 4, 0.5*eff, "3000kW")
          custom_exclusion_ranges["micro-beacon-3"] = {add = 2}
        elseif mods["FactorioExtended-Plus-Module"] then
          localise("micro-beacon-1", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_tiers_addon"}}})
          generate_new_beacon("beacon-mk2", "micro-beacon-2", "Micro beacon Mk2", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1, 1, 1, 0.75*eff, "300kW")
          generate_new_beacon("beacon-mk3", "micro-beacon-3", "Micro beacon Mk3", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1, 1, 1, 1*eff, "360kW")
        elseif mods["5dim_module"] then
          localise("micro-beacon-1", {"item", "beacon"}, "description", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_tiers_addon"}}})
          generate_new_beacon("5d-beacon-02", "micro-beacon-2", "Micro beacon MK2", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1, 1, 1, 0.6*eff, "480kW")
          generate_new_beacon("5d-beacon-03", "micro-beacon-3", "Micro beacon MK3", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1, 1, 1, 0.7*eff, "720kW")
        end
        if mods["5dim_module"] then
          generate_new_beacon("5d-beacon-04", "micro-beacon-4", "Micro beacon MK4", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1, 1, 1, 0.8*eff, "1000kW")
          generate_new_beacon("5d-beacon-05", "micro-beacon-5", "Micro beacon MK5", {"description.ab_same"}, 1, 2, 1, 0.9*eff, "1250kW")
          generate_new_beacon("5d-beacon-06", "micro-beacon-6", "Micro beacon MK6", {"description.ab_same"}, 1, 2, 1, 1*eff, "1500kW")
          generate_new_beacon("5d-beacon-07", "micro-beacon-7", "Micro beacon MK7", {"description.ab_same"}, 1, 2, 1, 1.1*eff, "1750kW")
          generate_new_beacon("5d-beacon-08", "micro-beacon-8", "Micro beacon MK8", {"description.ab_same"}, 1, 3, 1, 1.2*eff, "2000kW")
          generate_new_beacon("5d-beacon-09", "micro-beacon-9", "Micro beacon MK9", {"description.ab_same"}, 1, 3, 1, 1.3*eff, "2250kW")
          generate_new_beacon("5d-beacon-10", "micro-beacon-10", "Micro beacon MK10", {"description.ab_same"}, 1, 3, 1, 1.4*eff, "2500kW")
        end
      else
        if data.raw.beacon["ab-standard-beacon"] then
          generate_new_beacon("ab-standard-beacon", "micro-beacon-1", "Micro standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1)
        else
          generate_new_beacon("beacon", "micro-beacon-1", "Micro standard beacon", {'?', {'', {"description.ab_except"}, ' ', {"description.ab_micro_addon"}}}, 1)
        end
        if mods["bobmodules"] then
          generate_new_beacon("beacon-2", "micro-beacon-2", "Micro beacon 2", {"description.ab_same"}, 1)
          generate_new_beacon("beacon-3", "micro-beacon-3", "Micro beacon 3", {"description.ab_same"}, 1)
        elseif mods["FactorioExtended-Plus-Module"] then
          generate_new_beacon("beacon-mk2", "micro-beacon-2", "Micro beacon Mk2", {"description.ab_same"}, 1)
          generate_new_beacon("beacon-mk3", "micro-beacon-3", "Micro beacon Mk3", {"description.ab_same"}, 1)
        elseif mods["5dim_module"] then
          generate_new_beacon("5d-beacon-02", "micro-beacon-2", "Micro beacon MK2", {"description.ab_same"}, 1)
          generate_new_beacon("5d-beacon-03", "micro-beacon-3", "Micro beacon MK3", {"description.ab_same"}, 1)
        end
        if mods["5dim_module"] then
          generate_new_beacon("5d-beacon-04", "micro-beacon-4", "Micro beacon MK4", {"description.ab_same"}, 1)
          generate_new_beacon("5d-beacon-05", "micro-beacon-5", "Micro beacon MK5", {"description.ab_same"}, 1)
          generate_new_beacon("5d-beacon-06", "micro-beacon-6", "Micro beacon MK6", {"description.ab_same"}, 1)
          generate_new_beacon("5d-beacon-07", "micro-beacon-7", "Micro beacon MK7", {"description.ab_same"}, 1)
          generate_new_beacon("5d-beacon-08", "micro-beacon-8", "Micro beacon MK8", {"description.ab_same"}, 1)
          generate_new_beacon("5d-beacon-09", "micro-beacon-9", "Micro beacon MK9", {"description.ab_same"}, 1)
          generate_new_beacon("5d-beacon-10", "micro-beacon-10", "Micro beacon MK10", {"description.ab_same"}, 1)
        end
      end
      data.raw.item["micro-beacon-1"].order = "a[beacon]-1-zz"
      data.raw.recipe["micro-beacon-1"].order = "a[beacon]-1-zz"
    end
  end

  if mods["TarawindBeaconsRE"] or mods["TarawindBeaconsRE3x3"] then ---------------------------------------------------------------------------------------------------------------------------------------
    -- Balance: range and efficiency adjusted
    if startup["ab-balance-other-beacons"].value then
      for tier=1,7,1 do
        if startup["tarawind-reloaded-reducerange"] and startup["tarawind-reloaded-reducerange"].value == false then
          data.raw.beacon["twBeacon" .. tostring(tier)].supply_area_distance = data.raw.beacon["twBeacon" .. tostring(tier)].module_slots
          data.raw.beacon["twBeacon" .. tostring(tier)].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity*0.6 -- 0.3
        else
          data.raw.beacon["twBeacon" .. tostring(tier)].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity -- 0.5
        end
      end
    end
    for tier=1,7,1 do
      localise("twBeacon" .. tostring(tier), {"item", "beacon"}, "description", {"description.ab_same"})
      data.raw.recipe["twBeacon" .. tostring(tier)].order = "a[beacon]tw" .. tostring(tier)
      data.raw.item["twBeacon" .. tostring(tier)].order = "a[beacon]tw" .. tostring(tier)
      data.raw.beacon["twBeacon" .. tostring(tier)].radius_visualisation_picture.filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png"
      data.raw.beacon["twBeacon" .. tostring(tier)].radius_visualisation_picture.size = {10, 10}
      override_descriptions["twBeacon" .. tostring(tier)] = {}
      if startup["tarawind-reloaded-reducerange"] and startup["tarawind-reloaded-reducerange"].value == true then
        override_descriptions["twBeacon" .. tostring(tier)].d_range = 3
      end
      if startup["tarawind-reloaded-3x3mode"] and startup["tarawind-reloaded-3x3mode"].value == false then
        local range = math.ceil(get_distribution_range(data.raw.beacon["twBeacon" .. tostring(tier)]))
        override_descriptions["twBeacon" .. tostring(tier)] = {dimensions={1,1}, d_range=range}
        if startup["tarawind-reloaded-reducerange"] and startup["tarawind-reloaded-reducerange"].value == false then
          override_descriptions["twBeacon" .. tostring(tier)].d_range = range + 1
        end
      end
    end
  end

  if mods["Darkstar_utilities"] or mods["Darkstar_utilities_fixed"] then ----------------------------------------------------------------------------------------------------------------------------------
    -- each beacon is 3x3: basic-beacon-mk2 has 8 range, 1 module slot, 0.5 efficiency, can use all effects; efficiency-beacon has 25 range, 12 module slots, 3 efficiency, can only use efficiency modules; ultra-beacon has 25 range, 3 module slots, 0.5 efficiency; power-boost-beacon has 2 range, 1 module slot, 2.5 efficiency; world-array has 64 range, 10 module slots, 0.5 efficiency
    localise("basic-beacon-mk2", {"item", "beacon"}, "description", {"description.ab_same"})
    localise("efficiency-beacon", {"item", "beacon"}, "description", {"description.ab_same"})
    localise("ultra-beacon", {"item", "beacon"}, "description", {"description.ab_same"})
    localise("power-boost-beacon", {"item", "beacon"}, "description", {"description.ab_same"})
    localise("world-array", {"item", "beacon"}, "description", {"description.ab_same"})
    -- TODO: Balance?
  end

  if mods["FastFurnaces"] then ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- reika-fast-beacon has 6 range, 4 module slots, 0.8 efficiency, 800kW power; reika-fast-beacon-2 has 9 range, 12 module slots, 1 efficiency, 4MW power
    localise("reika-fast-beacon", {"item", "beacon"}, "description", {"description.ab_same"})
    localise("reika-fast-beacon-2", {"item", "beacon"}, "description", {"description.ab_same"})
    data.raw.item["reika-fast-beacon"].order = "a[beacon]-reika-fast-1"
    data.raw.recipe["reika-fast-beacon"].order = "a[beacon]-reika-fast-1"
    data.raw.item["reika-fast-beacon-2"].order = "a[beacon]-reika-fast-2"
    data.raw.recipe["reika-fast-beacon-2"].order = "a[beacon]-reika-fast-2"
    -- Balance: reika-fast-beacon is given +2 exclusion range, reika-fast-beacon-2 is given a strict exclusion range
    if startup["ab-balance-other-beacons"].value then
      custom_exclusion_ranges["reika-fast-beacon"] = {add=2}
      custom_exclusion_ranges["reika-fast-beacon-2"] = {value="solo", mode="strict"}
      localise("reika-fast-beacon", {"item", "beacon"}, "description", {"description.ab_different"})
      localise("reika-fast-beacon-2", {"item", "beacon"}, "description", {"description.ab_different"})
    end
  end

  if mods["starry-sakura"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- all beacons have 3 range: tiny-beacon is 1x1 and has 1 module slot, 0.5 efficiency; small-beacon is 2x2 and has 2 module slots, 0.5 efficiency; sakura-beacon has 4 module slots, 0.65 efficiency; star-beacon has 8 module slots, 0.8 efficiency
    data.raw.beacon["tiny-beacon"].selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
    -- Balance: reduced range to match width, changed module power of small-beacon to be halfway between standard beacons and tiny beacons; tiny beacons and small beacons also only disable other types of beacons
    if startup["ab-balance-other-beacons"].value then
      data.raw.beacon["tiny-beacon"].supply_area_distance = 1
      data.raw.beacon["small-beacon"].supply_area_distance = 2
      data.raw.beacon["small-beacon"].distribution_effectivity = data.raw.beacon["beacon"].distribution_effectivity*0.75 -- 0.375
      -- TODO: Reduce recipe costs for tiny/small beacons?
    end
  end

  if mods["warptorio2"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- warp beacons neither disable nor get disabled by other beacons via the "exclusion area" system
    for i=1,10,1 do
      data.raw.beacon["warptorio-beacon-" .. i].localised_description = {"description.ab_bypass"}
    end
  end

  if mods["PowerCrystals"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- next_upgrade removed in case other mods add it (would cause a crash since they aren't minable)
    local kinds = {"productivity", "speed", "effectivity"}
    for tier=1,3,1 do
      for _, kind in pairs(kinds) do
        data.raw.beacon["model-power-crystal-" .. kind .. "-" .. tier].next_upgrade = nil
      end
      data.raw.beacon["base-power-crystal-" .. tier].next_upgrade = nil
      if tier <= 2 then
        data.raw.beacon["model-power-crystal-instability-" .. tier].next_upgrade = nil
        data.raw.beacon["base-power-crystal-negative-" .. tier].next_upgrade = nil
      end
    end
    -- Balance: Power crystals neither disable nor get disabled by other beacons via the "exclusion area" system
  end

  if mods["early-modules"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    if startup["em-enable-beacon-0"].value then
      localise("beacon-0", {"item", "beacon"}, "description", {"description.ab_same"})
    end
  end

  --if mods["LunarLandings"] then -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- ll-oxygen-diffuser uses a beacon prototype but has zero module slots and doesn't behave like a beacon so it was changed within control.lua accordingly
  --end

  --if mods["EditorExtensions"] then ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- ee-super-beacon is only available in the editor so it was changed within control.lua to not interact with the "exclusion area" system
  --end

  --if mods["creative-mod"] then --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- creative-mod_super-beacon is only available in the editor so it was changed within control.lua to not interact with the "exclusion area" system
  --end

  -- The mods below do not add beacons themselves:

  if mods["IndustrialRevolution3"] then -------------------------------------------------------------------------------------------------------------------------------------------------------------------
    order_beacons("beacon", 1, "zz", "zz")
  end

  if mods["SeaBlockMetaPack"] then --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    order_beacons("beacon", 1, "a[beacon]-x", "a[beacon]-x")
  end

  if mods["FreightForwarding"] then -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    if se_technologies then
      local possible_se_techs = {"se-compact-beacon", "se-wide-beacon", "se-compact-beacon-2", "se-wide-beacon-2"}
      for _,v in pairs(possible_se_techs) do
        local is_updated = false
        for _,ingredient in pairs(data.raw.technology[v].unit.ingredients) do
          if ingredient.name == "ff-transport-science-pack" and ingredient.amount > 0 then is_updated = true end
        end
        if not is_updated then
          table.insert(data.raw.technology[v].unit.ingredients, {"ff-transport-science-pack", 1})
        end
      end
    end
  end

  if mods["mini"] then ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- replacement standard beacon created in data.lua since its properties get overridden otherwise
    override_descriptions["beacon"] = {dimensions={1,1}}
  end

  --if mods["Custom-Mods"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- replacement standard beacon created in data.lua since its properties get overridden otherwise
  --end

  if mods["more-module-slots"] then -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    if startup["more-module-slots_beacon"].value and startup["ab-show-extended-stats"].value and startup["more-module-slots_factor"] and startup["more-module-slots_multiplicative-module-slots"] then
      local factor = startup["more-module-slots_factor"].value
      local multiply = startup["more-module-slots_multiplicative-module-slots"].value
      for name, beacon in pairs(data.raw.beacon) do
        local new_slots = beacon.module_slots
        if multiply then
          new_slots = new_slots * factor
        else
          new_slots = new_slots + factor
        end
        override_descriptions[name] = {slots=new_slots}
      end
    end
  end

  if mods["Li-Module-Fix"] then ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- The startup setting which adjusts beacon range is disabled (supporting it would require somehow passing info between the data and control stages)
    if startup["ab-show-extended-stats"].value and startup["more_slots_unm"] and startup["beacon_de"] then
      for name, beacon in pairs(data.raw.beacon) do
        local new_slots = beacon.module_slots + startup["more_slots_unm"].value
        local new_efficiency = beacon.distribution_effectivity * startup["beacon_de"].value
        override_descriptions[name] = {slots=new_slots, efficiency=new_efficiency}
      end
    end
  end

  return {beacons = beacons, custom_exclusion_ranges = custom_exclusion_ranges, max_moduled_building_size = max_moduled_building_size}
end

-- scales a field by a given amount
function scale(object, scale)
  local function scale_subtable(object, scale)
      for key, value in pairs(object) do
          if type(value) == "table" then
              scale_subtable(value, scale)
          elseif type(value) == "number" then
              object[key] = value*scale
          end
      end
  end
  if type(object) == "number" then
      return object*scale
  elseif type(object) == "table" then
      object = table.deepcopy(object)
      scale_subtable(object, scale)
      return object
  end
end

-- scales a beacon to be a different size
function rescale_entity(entity, scalar)
  local fields = {"shift", "scale", "collision_box", "selection_box", "drawing_box", "mining_time"}
	for key, value in pairs(entity) do
		if key == "hr_version" then
			entity.scale = entity.scale or 0.5
		elseif entity.filename then
			entity.scale = entity.scale or 1
		end
    for n = 1, #fields do
      if fields[n] == key then entity[key] = scale(value, scalar) end
    end
    if type(value) == "table" then rescale_entity(value, scalar) end
  end
  if scalar < 1 and entity.collision_box then -- ensures a minimum walkable area on all sides of the entity; this fixes distribution areas for resized beacons
    local min = 0.3
    if entity.collision_box[1][1] - min < entity.selection_box[1][1] then entity.collision_box[1][1] = entity.selection_box[1][1] + min end
    if entity.collision_box[1][2] - min < entity.selection_box[1][2] then entity.collision_box[1][2] = entity.selection_box[1][2] + min end
    if entity.collision_box[2][1] + min > entity.selection_box[2][1] then entity.collision_box[2][1] = entity.selection_box[2][1] - min end
    if entity.collision_box[2][2] + min > entity.selection_box[2][2] then entity.collision_box[2][2] = entity.selection_box[2][2] - min end
  end
end

-- creates a new beacon with the given criteria
function generate_new_beacon(base_name, name, localised_name, localised_description, size, range, modules, efficiency, power, effects)
  local new_beacon = table.deepcopy(data.raw.beacon[base_name])
  local new_beacon_item = table.deepcopy(data.raw.item[base_name])
  local new_beacon_recipe = table.deepcopy(data.raw.recipe[base_name])
  new_beacon.name = name
  new_beacon.minable.result = name
  new_beacon_item.name = name
  new_beacon_item.place_result = name
  new_beacon_recipe.name = name
  new_beacon_recipe.results = {{type="item", name=name, amount=1}}
  new_beacon.next_upgrade = nil
  local original_size = new_beacon.selection_box[2][1] - new_beacon.selection_box[1][1] -- selection box assumed to be in full tiles
  size = math.ceil(size)
  if size ~= original_size then rescale_entity(new_beacon, size/original_size) end
  local style = string.sub(name,1,4)
  local icon_indicator = nil
  if style == "mini" then
    icon_indicator = "__mini-machines__/graphics/shrink.png"
  elseif style == "micr" then
    icon_indicator = "__micro-machines__/graphics/shrink3.png"
    new_beacon_item.order = new_beacon_item.order .. "b-micro"
    new_beacon_recipe.order = new_beacon_item.order
  end
  if icon_indicator ~= nil then
    new_beacon_recipe.base_machine = base_name -- causes technologies to be handled by mini/micro mods
    if not new_beacon_item.icons then new_beacon_item.icons = {{icon=data.raw.beacon[base_name].icon, icon_size=data.raw.beacon[base_name].icon_size or 64}} end
    if not new_beacon_recipe.icons then new_beacon_recipe.icons = {{icon=data.raw.beacon[base_name].icon, icon_size=data.raw.beacon[base_name].icon_size or 64}} end
    if new_beacon_item.icons then
      table.insert(new_beacon_item.icons, {icon=icon_indicator, icon_size=64})
      table.insert(new_beacon_recipe.icons, {icon=icon_indicator, icon_size=64})
    elseif new_beacon_item.icon then
      new_beacon_item.icons = {{icon=new_beacon_item.icon, icon_size=new_beacon_item.icon_size, icon_mipmaps=new_beacon_item.icon_mipmaps}, {icon=icon_indicator, icon_size=64}}
      new_beacon_recipe.icons = new_beacon_item.icons
    end
  end
  local brv = { layers = {{filename = "__alternative-beacons__/graphics/visualization/brv-dist.png", size = {10, 10}, scale = 1, priority = "extra-high-no-scale"}} }
  new_beacon.radius_visualisation_picture = brv
  if range ~= nil then new_beacon.supply_area_distance = range end
  if modules ~= nil then new_beacon.module_slots = modules end
  if efficiency ~= nil then new_beacon.distribution_effectivity = efficiency end
  if power ~= nil then new_beacon.energy_usage = power end
  if effects ~= nil then new_beacon.allowed_effects = effects end
  data:extend({new_beacon_item})
  data:extend({new_beacon})
  data:extend({new_beacon_recipe})
  localise(name, {"item", "beacon"}, "name", localised_name)
  localise(name, {"item", "beacon"}, "description", localised_description)
  if icon_indicator == nil then table.insert( data.raw.technology["effect-transmission"].effects, { type = "unlock-recipe", recipe = name } ) end
end

return adjustments
