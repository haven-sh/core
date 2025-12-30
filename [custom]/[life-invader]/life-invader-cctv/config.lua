Config = {}

Config.Elevator = {
    -- Entrada Principal (Arcadius Business Centre)
    Entrance = {
        coords = vector3(-126.2403, -626.8715, 48.4158), -- As tuas coords
        heading = 132.9,
        label = "Subir para Escritórios CCTV",

        -- Destino: Escritório "Ice" (Piso Executivo)
        targetLoc = vector3(-141.1987, -620.913, 168.82),
        targetHeading = 360.0,

        -- Quem pode subir?
        authorized = {
            ['cctv'] = true,
            ['police'] = true,
            ['admin'] = true
        }
    },

    -- Saída (Escritório lá em cima)
    OfficeExit = {
        coords = vector3(-141.40, -620.20, 168.82), -- Porta do escritório por dentro
        heading = 180.0,
        label = "Descer para a Rua",

        -- Destino: Volta para a entrada do Arcadius
        targetLoc = vector3(-126.2403, -626.8715, 48.4158),
        targetHeading = 312.0, -- Virado para a rua

        authorized = nil -- Qualquer pessoa que esteja lá dentro pode sair
    }
}
