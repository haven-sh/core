Config = {}

Config.BunkerSystem = {
    entrance = vector3(1573.5, 2245.57, 79.9),
    interiorSpawn = vector3(894.63, -3245.87, -98.26),
    exitZone = vector3(894.63, -3245.87, -98.26)
}

Config.CraftingStations = {
    ["foundry"] = {
        type = "zones",
        coordsList = {vector3(1112.94, -2008.24, 30.92)},
        length = 2.0,
        width = 3.0,
        heading = 0,
        label = "Fundição Industrial",
        icon = "fas fa-fire",
        targetLabel = "Fundir Metais"
    },
    ["drill_station"] = {
        type = "zones",
        coordsList = {vector3(888.63, -3206.77, -98.2)},
        length = 1.6,
        width = 1.0,
        heading = 90,
        label = "Coluna de Furar",
        icon = "fas fa-sort-amount-down",
        targetLabel = "Perfurar Canos"
    },
    ["precision_station"] = {
        type = "zones",
        coordsList = {vector3(910.12, -3222.29, -98.27), vector3(899.17, -3223.71, -98.26)},
        length = 1.6,
        width = 1.0,
        heading = 90,
        label = "Morsa de Bancada",
        icon = "fas fa-cog",
        targetLabel = "Cortar Receivers"
    },
    ["assembly"] = {
        type = "zones",
        coordsList = {vector3(884.72, -3199.75, -98.2), vector3(896.46, -3217.42, -98.23),
                      vector3(905.93, -3230.74, -98.29)},
        length = 3.6,
        width = 1.0,
        heading = 90,
        label = "Mesa de Montagem",
        icon = "fas fa-hammer",
        targetLabel = "Montar Arma Final"
    }
}

Config.Recipes = {
    ["steel_billet"] = {
        label = "Tarugo de Aço",
        station = "foundry",
        jobs = {"lostmc", "ballas", "vagos", "cartel", "admin"},
        items = {{
            item = "iron_scrap",
            amount = 10,
            label = "Sucata de Ferro"
        }},
        craftTime = 15000
    },
    ["weapon_barrel_pro"] = {
        label = "Cano de Precisão",
        station = "drill_station",
        jobs = {"lostmc", "ballas", "vagos", "cartel", "admin"},
        items = {{
            item = "steel_billet",
            amount = 2,
            label = "Tarugo de Aço"
        }},
        craftTime = 25000
    },
    ["weapon_receiver"] = {
        label = "Receiver (Corpo)",
        station = "precision_station",
        jobs = {"lostmc", "ballas", "vagos", "cartel", "admin"},
        items = {{
            item = "steel_billet",
            amount = 3,
            label = "Tarugo de Aço"
        }},
        craftTime = 30000
    },
    ["weapon_trigger_group"] = {
        label = "Grupo de Gatilho",
        station = "precision_station",
        jobs = {"lostmc", "ballas", "vagos", "cartel", "admin"},
        items = {{
            item = "steel_billet",
            amount = 1,
            label = "Tarugo de Aço"
        }},
        craftTime = 15000
    },
    ["weapon_pistol_mk2"] = {
        label = "Pistola Five-Seven",
        station = "assembly",
        blueprint = "blueprint_pistol",
        jobs = {"ballas", "vagos", "admin"},
        items = {{
            item = "weapon_receiver",
            amount = 1,
            label = "Receiver"
        }, {
            item = "weapon_barrel_pro",
            amount = 1,
            label = "Cano Preciso"
        }, {
            item = "weapon_trigger_group",
            amount = 1,
            label = "Gatilho"
        }},
        craftTime = 40000
    },
    ["weapon_smg"] = {
        label = "Submetralhadora SMG",
        station = "assembly",
        blueprint = "blueprint_smg",
        jobs = {"lostmc", "admin"},
        items = {{
            item = "weapon_receiver",
            amount = 1,
            label = "Receiver"
        }, {
            item = "weapon_barrel_pro",
            amount = 1,
            label = "Cano Preciso"
        }, {
            item = "weapon_trigger_group",
            amount = 1,
            label = "Gatilho"
        }, {
            item = "weapon_spring",
            amount = 2,
            label = "Molas"
        }},
        craftTime = 60000
    },
    ["weapon_assaultrifle"] = {
        label = "AK-47",
        station = "assembly",
        blueprint = "blueprint_ak47",
        jobs = {"cartel", "admin"},
        items = {{
            item = "weapon_receiver",
            amount = 1,
            label = "Receiver"
        }, {
            item = "weapon_barrel_pro",
            amount = 1,
            label = "Cano Preciso"
        }, {
            item = "weapon_trigger_group",
            amount = 1,
            label = "Gatilho"
        }, {
            item = "weapon_spring",
            amount = 4,
            label = "Molas"
        }},
        craftTime = 80000
    }
}
