Config = {}

Config.Locations = {{
    label = "Laboratório | Cocaina",

    authorized = {
        ['cctv'] = true,
        ['cctv-cocaine'] = true
    },

    target = {
        coords = vector3(1086.1499, -3198.1726, -38.9935),
        heading = 304.0992,
        length = 0.8,
        width = 0.8,
        minZ = -39.9,
        maxZ = -37.5,
        debugPoly = false
    },
    anim = {
        coords = vector3(1087.1528, -3198.1970, -39.9934),
        heading = 100.0
    },
    cams = {{
        name = "[EXT] Porta Principal",
        coords = vector3(198.9964, -1273.5436, 31.68),
        rot = vector3(-20.0, 0.0, 210.0),

        propRot = vector3(0.0, 0.0, 20.0),
        model = "prop_cctv_cam_05a"
    }, {
        name = "[INT] Hall de Entrada",
        coords = vector3(1090.45, -3190.80, -37.0),
        rot = vector3(-20.0, 0.0, 35.0),

        spawnProp = false
    }, {
        name = "[INT] Área de Produção",
        coords = vector3(1097.5088, -3200.191, -37.8038),
        rot = vector3(0.0, 0.0, 35.0),

        propRot = vector3(0.0, 0.0, 180.0),
        model = "prop_cctv_cam_01a"
    }, {
        name = "[EXT] Portão de Saída",
        coords = vector3(162.34, -1267.87, 34.63),
        rot = vector3(-25.0, 0.0, 205.0),

        propRot = vector3(0.0, 0.0, -20.0),
        model = "ba_prop_battle_cctv_cam_01a"
    }}
}}
