--- settings-updates.lua

if mods["space-exploration"] then
    data.raw["bool-setting"]["ab-enable-se-beacons"].hidden = true
    data.raw["bool-setting"]["ab-enable-se-beacons"].forced_value = false
end
if mods["pycoalprocessing"] then
    if data.raw["bool-setting"]["future-beacons"] ~= nil then
        data.raw["bool-setting"]["future-beacons"].hidden = true
        data.raw["bool-setting"]["future-beacons"].forced_value = true
    end
end
if mods["mini-machines"] then
    if data.raw["bool-setting"]["mini-tech"] ~= nil then
        data.raw["bool-setting"]["mini-tech"].default_value = false
    end
end
if mods["micro-machines"] then
    if data.raw["bool-setting"]["micro-tech"] ~= nil then
        data.raw["bool-setting"]["micro-tech"].default_value = false
    end
end
if mods["TarawindBeaconsRE3x3"] then
    if data.raw["bool-setting"]["tarawind-reloaded-3x3mode"] ~= nil then
        data.raw["bool-setting"]["tarawind-reloaded-3x3mode"].default_value = true
    end
    if data.raw["bool-setting"]["tarawind-reloaded-productivityreduce"] ~= nil then
        data.raw["bool-setting"]["tarawind-reloaded-productivityreduce"].default_value = true
    end
end