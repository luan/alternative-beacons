-- settings.lua

data:extend ({
    {
        type = 'bool-setting',
        name = 'ab-enable-standard-beacons',
        setting_type = 'startup',
        default_value = true,
        hidden = true,
        order = aa
    },
    {
        type = 'bool-setting',
        name = 'ab-enable-focused-beacons',
        setting_type = 'startup',
        default_value = true,
        order = ab
    },
    {
        type = 'bool-setting',
        name = 'ab-enable-node-beacons',
        setting_type = 'startup',
        default_value = true,
        order = ac
    },
    {
        type = 'bool-setting',
        name = 'ab-enable-hub-beacons',
        setting_type = 'startup',
        default_value = true,
        order = ad
    },
    {
        type = 'bool-setting',
        name = 'ab-enable-isolation-beacons',
        setting_type = 'startup',
        default_value = true,
        order = ae
    },
})
