--- settings.lua

data:extend ({
    {
        type = "bool-setting",
        name = "ab-override-vanilla-beacons",
        setting_type = "startup",
        default_value = true,
        order = "a"
    },
    {
        type = "bool-setting",
        name = "ab-enable-focused-beacons",
        setting_type = "startup",
        default_value = true,
        order = "b"
    },
    {
        type = "bool-setting",
        name = "ab-enable-node-beacons",
        setting_type = "startup",
        default_value = true,
        order = "c"
    },
    {
        type = "bool-setting",
        name = "ab-enable-conflux-beacons",
        setting_type = "startup",
        default_value = true,
        order = "d"
    },
    {
        type = "bool-setting",
        name = "ab-enable-hub-beacons",
        setting_type = "startup",
        default_value = true,
        order = "e"
    },
    {
        type = "bool-setting",
        name = "ab-enable-isolation-beacons",
        setting_type = "startup",
        default_value = true,
        order = "f"
    },
    {
        type = "bool-setting",
        name = "ab-update-recipes",
        setting_type = "startup",
        default_value = true,
        order = "xa"
    },
    {
        type = "bool-setting",
        name = "ab-balance-other-beacons",
        setting_type = "startup",
        default_value = true,
        order = "xb"
    },
    {
        type = "bool-setting",
        name = "ab-show-extended-stats",
        setting_type = "startup",
        default_value = true,
        order = "xb"
    },
    {
        type = "int-setting",
        name = "ab-update-rate",
        setting_type = "runtime-global",
        default_value = -1,
        order = "z"
    },
})
