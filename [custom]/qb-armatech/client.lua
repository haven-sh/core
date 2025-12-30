local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    RequestIpl("gr_case6_bunkerclosed")

    exports['qb-target']:AddBoxZone("Bunker_Enter", Config.BunkerSystem.entrance, 3.0, 3.0, {
        name = "Bunker_Enter",
        heading = 0,
        debugPoly = false,
        minZ = Config.BunkerSystem.entrance.z - 1.0,
        maxZ = Config.BunkerSystem.entrance.z + 3.0
    }, {
        options = {{
            type = "client",
            event = "qb-armatech:client:EnterBunker",
            icon = "fas fa-door-open",
            label = "Entrar no Bunker"
        }},
        distance = 3.0
    })

    exports['qb-target']:AddBoxZone("Bunker_Exit", Config.BunkerSystem.exitZone, 4.0, 4.0, {
        name = "Bunker_Exit",
        heading = 0,
        debugPoly = false,
        minZ = Config.BunkerSystem.exitZone.z - 2.0,
        maxZ = Config.BunkerSystem.exitZone.z + 3.0
    }, {
        options = {{
            type = "client",
            event = "qb-armatech:client:ExitBunker",
            icon = "fas fa-door-open",
            label = "Sair do Bunker"
        }},
        distance = 3.0
    })

    for stationName, data in pairs(Config.CraftingStations) do
        if data.coordsList then
            for i, coordinate in ipairs(data.coordsList) do
                exports['qb-target']:AddBoxZone("ArmaTech_" .. stationName .. "_" .. i, coordinate, data.length,
                    data.width, {
                        name = "ArmaTech_" .. stationName .. "_" .. i,
                        heading = data.heading or 0,
                        debugPoly = false,
                        minZ = coordinate.z - 1.0,
                        maxZ = coordinate.z + 2.0
                    }, {
                        options = {{
                            type = "client",
                            event = "qb-armatech:client:OpenMenu",
                            icon = data.icon,
                            label = data.targetLabel,
                            station = stationName
                        }},
                        distance = 2.0
                    })
            end
        end
    end
end)

RegisterNetEvent('qb-armatech:client:EnterBunker', function()
    DoScreenFadeOut(500)
    Wait(1000)
    SetEntityCoords(PlayerPedId(), Config.BunkerSystem.interiorSpawn.x, Config.BunkerSystem.interiorSpawn.y,
        Config.BunkerSystem.interiorSpawn.z)
    Wait(1000)
    DoScreenFadeIn(500)
end)

RegisterNetEvent('qb-armatech:client:ExitBunker', function()
    DoScreenFadeOut(500)
    Wait(1000)
    SetEntityCoords(PlayerPedId(), Config.BunkerSystem.entrance.x, Config.BunkerSystem.entrance.y,
        Config.BunkerSystem.entrance.z)
    Wait(1000)
    DoScreenFadeIn(500)
end)

RegisterNetEvent('qb-armatech:client:OpenMenu', function(data)
    if not data.station then
        return
    end

    QBCore.Functions.TriggerCallback('qb-armatech:server:GetAllowedRecipes', function(allowedRecipes)
        if not allowedRecipes or next(allowedRecipes) == nil then
            QBCore.Functions.Notify("Não tens conhecimento para usar esta máquina.", "error")
            return
        end

        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "open",
            recipes = allowedRecipes,
            station = data.station
        })
    end, data.station)
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('startCrafting', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('qb-armatech:server:AttemptCraft', data.weapon)
    cb('ok')
end)

RegisterNetEvent('qb-armatech:client:StartAnimation', function(weaponKey, duration)
    local ped = PlayerPedId()
    local animDict = "amb@prop_human_bum_bin@base"
    local animName = "base"

    if duration > 20000 then
        animDict = "mini@repair"
        animName = "fixing_a_ped"
    end

    QBCore.Functions.Progressbar("crafting_process", "A trabalhar...", duration, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
        animDict = animDict,
        anim = animName,
        flags = 49
    }, {}, {}, function()
        StopAnimTask(ped, animDict, animName, 1.0)
        TriggerServerEvent('qb-armatech:server:CraftFinish', weaponKey)
    end, function()
        StopAnimTask(ped, animDict, animName, 1.0)
        QBCore.Functions.Notify("Cancelado!", "error")
    end)
end)
