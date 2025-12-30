local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    RequestIpl("gr_case6_bunkerclosed")

    for stationName, data in pairs(Config.CraftingStations) do
        if data.coordsList then
            for i, coordinate in ipairs(data.coordsList) do
                exports['qb-target']:AddBoxZone("AmmoTech_" .. stationName .. "_" .. i, coordinate, data.length,
                    data.width, {
                        name = "AmmoTech_" .. stationName .. "_" .. i,
                        heading = data.heading or 0,
                        debugPoly = false,
                        minZ = coordinate.z - 1.0,
                        maxZ = coordinate.z + 2.0
                    }, {
                        options = {{
                            type = "client",
                            event = "qb-ammotech:client:OpenMenu",
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

RegisterNetEvent('qb-ammotech:client:EnterBunker', function()
    DoScreenFadeOut(500)
    Wait(1000)
    SetEntityCoords(PlayerPedId(), Config.BunkerSystem.interiorSpawn.x, Config.BunkerSystem.interiorSpawn.y,
        Config.BunkerSystem.interiorSpawn.z)
    Wait(1000)
    DoScreenFadeIn(500)
end)

RegisterNetEvent('qb-ammotech:client:ExitBunker', function()
    DoScreenFadeOut(500)
    Wait(1000)
    SetEntityCoords(PlayerPedId(), Config.BunkerSystem.entrance.x, Config.BunkerSystem.entrance.y,
        Config.BunkerSystem.entrance.z)
    Wait(1000)
    DoScreenFadeIn(500)
end)

RegisterNetEvent('qb-ammotech:client:OpenMenu', function(data)
    if not data.station then
        return
    end

    QBCore.Functions.TriggerCallback('qb-ammotech:server:GetAllowedRecipes', function(allowedRecipes)
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
    TriggerServerEvent('qb-ammotech:server:AttemptCraft', data.weapon)
    cb('ok')
end)

RegisterNetEvent('qb-ammotech:client:StartAnimation', function(itemKey, duration)
    local ped = PlayerPedId()
    local animDict = "anim@amb@business@coc/coc_unpack_cut_left@"
    local animName = "coke_cut_v1_coccutter"

    if duration > 15000 then
        animDict = "mini@repair"
        animName = "fixing_a_ped"
    end

    QBCore.Functions.Progressbar("ammo_crafting", "A produzir munição...", duration, false, true, {
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
        TriggerServerEvent('qb-ammotech:server:CraftFinish', itemKey)
    end, function()
        StopAnimTask(ped, animDict, animName, 1.0)
        QBCore.Functions.Notify("Cancelado!", "error")
    end)
end)
