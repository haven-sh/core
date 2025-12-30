local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('tablet', function()
    local Player = QBCore.Functions.GetPlayerData()
    if Player.job.name == "police" and Player.job.onduty then
        QBCore.Functions.TriggerCallback('pe-mdt:server:getDataInicial', function(data)
            if data then
                SetNuiFocus(true, true)
                SendNUIMessage({ action = "abrir", nomeOficial = data.nome, cargoOficial = data.cargo })
            end
        end)
    end
end)

RegisterNUICallback('getListaCrimes', function(data, cb)
    QBCore.Functions.TriggerCallback('pe-mdt:server:getListaCrimes', function(crimes)
        cb(crimes)
    end)
end)

RegisterNUICallback('aplicarMulta', function(data, cb)
    TriggerServerEvent('pe-mdt:server:aplicarMulta', data)
    cb('ok')
end)

RegisterNUICallback('pesquisarPessoa', function(data, cb)
    QBCore.Functions.TriggerCallback('pe-mdt:server:pesquisarCidadao', function(res) cb(res) end, data.busca)
end)

RegisterNUICallback('getFicha', function(data, cb)
    QBCore.Functions.TriggerCallback('pe-mdt:server:getFichaCidadao', function(res) cb(res) end, data.cid)
end)

RegisterNUICallback('getMandados', function(data, cb)
    QBCore.Functions.TriggerCallback('pe-mdt:server:getMandados', function(res) cb(res) end)
end)

RegisterNUICallback('adicionarMandado', function(data, cb)
    TriggerServerEvent('pe-mdt:server:adicionarMandado', data.cid, data.nome, data.motivo)
    cb('ok')
end)

RegisterNUICallback('removerMandado', function(data, cb)
    TriggerServerEvent('pe-mdt:server:removerMandado', data.id)
    cb('ok')
end)

RegisterNUICallback('getUnidades', function(data, cb)
    QBCore.Functions.TriggerCallback('pe-mdt:server:getUnidades', function(result)
        cb(result)
    end)
end)

RegisterNUICallback('fechar', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
