--- settings-updates.lua

if mods["pycoalprocessing"] then
    if data.raw["bool-setting"]["future-beacons"] ~= nil then
        data.raw["bool-setting"]["future-beacons"].hidden = true
        data.raw["bool-setting"]["future-beacons"].forced_value = true
    end
end