local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('vanilla-dj:server:playMusic', function(url)
    exports.xsound:PlayUrl(-1, "vanilla_dj", url, Config.MaxVolume, false)
    exports.xsound:Distance(-1, "vanilla_dj", Config.SoundRange)
    exports.xsound:Position(-1, "vanilla_dj", Config.SoundPos)
    TriggerClientEvent('vanilla-dj:client:playMusic', -1, url)
end)

RegisterNetEvent('vanilla-dj:server:stopMusic', function()
    exports.xsound:Destroy(-1, "vanilla_dj")
    TriggerClientEvent('vanilla-dj:client:stopMusic', -1)
end)

RegisterNetEvent('vanilla-dj:server:setVolume', function(volume)
    local vol = tonumber(volume) / 100
    if vol > Config.MaxVolume then
        vol = Config.MaxVolume
    end
    exports.xsound:setVolume(-1, "vanilla_dj", vol)
end)

RegisterNetEvent('vanilla-dj:server:syncLights', function(mode, color)
    TriggerClientEvent('vanilla-dj:client:syncLights', -1, mode, color)
end)

RegisterNetEvent('vanilla-dj:server:toggleScreens', function(state)
    TriggerClientEvent('vanilla-dj:client:toggleScreens', -1, state)
end)
