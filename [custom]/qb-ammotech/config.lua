Config = {}

Config.BunkerSystem = {
    entrance = vector3(1573.5, 2245.57, 79.9),
    interiorSpawn = vector3(894.63, -3245.87, -98.26),
    exitZone = vector3(894.63, -3245.87, -98.26)
}

Config.CraftingStations = {
    ["lead_station"] = {
        type = "zones",
        coordsList = {vector3(1111.03, -2011.01, 30.98)},
        length = 2.0,
        width = 3.0,
        heading = 0,
        label = "Fundição de Chumbo",
        icon = "fas fa-fire",
        targetLabel = "Fundir Pontas"
    },
    ["brass_station"] = {
        type = "zones",
        coordsList = {vector3(891.99, -3196.86, -98.2)},
        length = 1.6,
        width = 1.0,
        heading = 90,
        label = "Prensa Hidráulica",
        icon = "fas fa-compress-arrows-alt",
        targetLabel = "Moldar Cartuchos"
    },
    ["reloading_bench"] = {
        type = "zones",
        coordsList = {vector3(907.8, -3211.08, -98.22), vector3(909.72, -3210.19, -98.22)},
        length = 2.0,
        width = 1.0,
        heading = 90,
        label = "Estação de Recarga",
        icon = "fas fa-boxes",
        targetLabel = "Recarregar Munições"
    }
}

Config.Recipes = {
    ["bullet_tip"] = {
        label = "Pontas de Projétil (x50)",
        station = "lead_station",
        jobs = {"lostmc", "ballas", "vagos", "cartel", "admin"},
        items = {{
            item = "lead_scrap",
            amount = 5,
            label = "Sucata de Chumbo"
        }},
        craftTime = 10000
    },
    ["brass_casing"] = {
        label = "Cartuchos de Latão (x50)",
        station = "brass_station",
        jobs = {"lostmc", "ballas", "vagos", "cartel", "admin"},
        items = {{
            item = "brass_scrap",
            amount = 5,
            label = "Sucata de Latão"
        }},
        craftTime = 10000
    },
    ["pistol_ammo_box"] = {
        label = "Caixa 9mm (x50)",
        station = "reloading_bench",
        jobs = {"ballas", "vagos", "admin"},
        items = {{
            item = "brass_casing",
            amount = 1,
            label = "Cartuchos"
        }, {
            item = "bullet_tip",
            amount = 1,
            label = "Pontas"
        }, {
            item = "gunpowder_blue",
            amount = 2,
            label = "Pólvora Fina"
        }, {
            item = "primer_small",
            amount = 5,
            label = "Espoleta Pequena"
        }},
        craftTime = 20000
    },
    ["rifle_ammo_box"] = {
        label = "Caixa 7.62mm (x50)",
        station = "reloading_bench",
        jobs = {"cartel", "admin"},
        items = {{
            item = "brass_casing",
            amount = 2,
            label = "Cartuchos"
        }, {
            item = "bullet_tip",
            amount = 2,
            label = "Pontas"
        }, {
            item = "gunpowder_red",
            amount = 3,
            label = "Pólvora Grossa"
        }, {
            item = "primer_large",
            amount = 5,
            label = "Espoleta Grande"
        }},
        craftTime = 30000
    },
    ["shotgun_ammo_box"] = {
        label = "Caixa Calibre 12 (x20)",
        station = "reloading_bench",
        jobs = {"lostmc", "admin"},
        items = {{
            item = "plastic_shell",
            amount = 2,
            label = "Cartucho Plástico"
        }, {
            item = "lead_scrap",
            amount = 2,
            label = "Chumbo Grosso"
        }, {
            item = "gunpowder_green",
            amount = 2,
            label = "Pólvora Média"
        }, {
            item = "primer_large",
            amount = 2,
            label = "Espoleta Grande"
        }},
        craftTime = 25000
    }
}
