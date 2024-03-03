--- settings-updates.lua

if mods["pycoalprocessing"] then
    if data.raw["bool-setting"]["future-beacons"] ~= nil then
        data.raw["bool-setting"]["future-beacons"].hidden = true
        data.raw["bool-setting"]["future-beacons"].forced_value = true
    end
end
--[[
if mods["248k"] and not mods["space-exploration"] then
    if data.raw["double-setting"]["el_ki_beacon_effectivity"] ~= nil then data.raw["double-setting"]["el_ki_beacon_effectivity"].maximum_value = 1 end
    if data.raw["double-setting"]["el_ki_beacon_effectivity_2"] ~= nil then data.raw["double-setting"]["el_ki_beacon_effectivity_2"].maximum_value = 1 end
    if data.raw["double-setting"]["el_ki_beacon_effectivity_3"] ~= nil then data.raw["double-setting"]["el_ki_beacon_effectivity_3"].maximum_value = 1 end
    if data.raw["int-setting"]["el_ki_beacon_supply_area"] ~= nil then data.raw["int-setting"]["el_ki_beacon_supply_area"].maximum_value = 6 end
    if data.raw["int-setting"]["el_ki_beacon_supply_area_2"] ~= nil then data.raw["int-setting"]["el_ki_beacon_supply_area_2"].maximum_value = 8 end
    if data.raw["int-setting"]["el_ki_beacon_supply_area_3"] ~= nil then data.raw["int-setting"]["el_ki_beacon_supply_area_3"].maximum_value = 10 end
end
]]