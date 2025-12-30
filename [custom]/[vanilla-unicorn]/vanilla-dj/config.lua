Config = {}

Config.DJBoothLocation = vector3(120.95, -1281.24, 29.48)
Config.SoundPos = vector3(120.95, -1281.24, 29.48)
Config.MaxVolume = 1.0
Config.SoundRange = 40.0

Config.Camera = {
    pos = vector3(119.5, -1282.6, 31.5),
    defaultRot = vector3(-20.0, 0.0, 130.0),
    defaultFov = 60.0
}

Config.Screens = {
    center = vector3(108.2882, -1289.5657, 30.7),

    z_up = 30.7,
    z_down = 30.7,

    headingOffset = 0.0,

    radius = 1.15,

    prop = "xm_prop_x17_tv_scrn_08"
}

Config.Lights = {{
    pos = vector3(127.4, -1282.5, 33.0),
    dir = vector3(-0.2, 0.0, -1.0)
}, {
    pos = vector3(124.0, -1288.0, 33.0),
    dir = vector3(0.0, 0.5, -1.0)
}, {
    pos = vector3(116.0, -1288.0, 33.0),
    dir = vector3(0.0, 0.5, -1.0)
}, {
    pos = vector3(120.0, -1281.0, 33.0),
    dir = vector3(0.0, -0.5, -1.0)
}}

Config.LightSettings = {
    distance = 40.0,
    brightness = 15.0,
    hardness = 10.0,
    radius = 8.0,
    falloff = 4.0
}
