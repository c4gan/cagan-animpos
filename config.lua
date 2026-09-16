Config = {}

Config.Locale = "tr" -- Language: "tr" (Turkish), "en" (English), "de" (German), "fr" (French)
Config.Framework = "auto" -- "auto", "vorp", "rsg", "standalone"

Config.AnimPos = {
    active = true,
    command = "animpos",

    -- Require player to be currently playing an animation to open animpos
    requireAnimation = false,

    -- Anchor model used for positioning
    anchorModel = "scriptedball",

    -- Maximum distance leash from the starting emote position
    maxDistance = {
        xy = 4.0, -- Horizontal limit in meters
        z = 2.0   -- Vertical limit in meters
    },

    -- Abuse control: if true, returns player to starting position when animation finishes (anti-exploit).
    -- If false, player stays at their new adjusted position and gets up from there.
    abuseControl = false,

    -- Player ghost opacity during placement
    playerOpacity = {
        active = true,
        opacity = 200 -- 0 (invisible) to 255 (solid)
    },

    -- 3D floating text above head (disabled)
    headText = {
        active = false,
        dist = 0.0
    },

    -- Orbit camera settings during positioning
    camera = {
        distance = 2.8,
        height = 0.35,
        fov = 55.0,
        minDistance = 1.0,
        maxDistance = 6.0
    },

    -- Ground snap offset from ground level
    groundSnapOffset = 0.98
}
