local QBCore = exports['qb-core']:GetCoreObject()

-- ==========================================================
--  SISTEMA DE MULTAS (VERSÃO FINAL COMPATÍVEL)
-- ==========================================================

-- Callback para carregar a lista de crimes no menu do Tablet
QBCore.Functions.CreateCallback('pe-mdt:server:getListaCrimes', function(source, cb)
    local crimes = {
        {label = "Excesso de Velocidade", multa = 500},
        {label = "Condução sem Carta", multa = 1000},
        {label = "Desobediência", multa = 1500},
        {label = "Uso de Máscara", multa = 2000},
        {label = "Posse de Arma Ilegal", multa = 5000},
        {label = "Tentativa de Fuga", multa = 3000},
    }
    cb(crimes)
end)

-- Evento para aplicar a multa e registar na base de dados
RegisterNetEvent('pe-mdt:server:aplicarMulta', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local targetCid = data.cid
    local valorMulta = tonumber(data.valor) or 0
    local motivo = data.motivo
    local oficialNome = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname

    -- Inserção corrigida com todos os campos que a DB costuma exigir
    MySQL.insert('INSERT INTO mdt_reports (citizenid, title, fine, officer_name, incident, jail, charges) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        targetCid, 
        motivo, 
        valorMulta, 
        oficialNome,
        "Multa aplicada via Tablet", -- Coluna incident
        0,                            -- Coluna jail
        json.encode({motivo})         -- Coluna charges (JSON)
    }, function(id)
        if id then
            TriggerClientEvent('QBCore:Notify', src, "Multa registada no sistema!", "success")
            
            -- Tenta retirar o dinheiro se o cidadão estiver online
            local Cidadao = QBCore.Functions.GetPlayerByCitizenId(targetCid)
            if Cidadao then
                Cidadao.Functions.RemoveMoney('bank', valorMulta, "Multa MDT: " .. motivo)
                TriggerClientEvent('QBCore:Notify', Cidadao.PlayerData.source, "Foste multado em $"..valorMulta.." por "..motivo, "error")
            end
        end
    end)
end)

-- ==========================================================
--  SISTEMA DE MANDADOS
-- ==========================================================

QBCore.Functions.CreateCallback('pe-mdt:server:getMandados', function(source, cb)
    local mandados = MySQL.query.await('SELECT * FROM mdt_warrants ORDER BY id DESC')
    cb(mandados or {})
end)

RegisterNetEvent('pe-mdt:server:adicionarMandado', function(cid, nome, motivo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local oficialNome = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname

    MySQL.insert('INSERT INTO mdt_warrants (citizenid, nome, motivo, oficial) VALUES (?, ?, ?, ?)', {
        cid, nome, motivo, oficialNome
    }, function(id)
        if id then TriggerClientEvent('QBCore:Notify', src, "Mandado Emitido!", "success") end
    end)
end)

RegisterNetEvent('pe-mdt:server:removerMandado', function(id)
    MySQL.query.await('DELETE FROM mdt_warrants WHERE id = ?', {id})
    TriggerClientEvent('QBCore:Notify', source, "Mandado Removido.", "primary")
end)

-- ==========================================================
--  DADOS E PESQUISA (QBCORE)
-- ==========================================================

QBCore.Functions.CreateCallback('pe-mdt:server:getDataInicial', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end
    local jobLabel = (Player.PlayerData.job and Player.PlayerData.job.grade) and Player.PlayerData.job.grade.label or "Oficial"
    cb({ 
        nome = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, 
        cargo = jobLabel 
    })
end)

QBCore.Functions.CreateCallback('pe-mdt:server:getUnidades', function(source, cb)
    local unidades = {}
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v.PlayerData.job.name == "police" and v.PlayerData.job.onduty then
            table.insert(unidades, {
                nome = v.PlayerData.charinfo.firstname .. " " .. v.PlayerData.charinfo.lastname,
                cargo = v.PlayerData.job.grade.label or "Oficial",
                callsign = v.PlayerData.metadata["callsign"] or "S/N"
            })
        end
    end
    cb(unidades)
end)

QBCore.Functions.CreateCallback('pe-mdt:server:pesquisarCidadao', function(source, cb, busca)
    local results = MySQL.query.await("SELECT * FROM players WHERE citizenid = ? OR charinfo LIKE ?", {busca, '%'..busca..'%'})
    cb(results or {})
end)

QBCore.Functions.CreateCallback('pe-mdt:server:getFichaCidadao', function(source, cb, citizenid)
    local playerResult = MySQL.single.await('SELECT * FROM players WHERE citizenid = ?', {citizenid})
    local profile = MySQL.single.await('SELECT * FROM mdt_profiles WHERE citizenid = ?', {citizenid})
    local reports = MySQL.query.await('SELECT * FROM mdt_reports WHERE citizenid = ? ORDER BY created_at DESC', {citizenid})
    local warrant = MySQL.single.await('SELECT id FROM mdt_warrants WHERE citizenid = ?', {citizenid})

    if playerResult then
        local charinfo = json.decode(playerResult.charinfo) or {}
        local money = json.decode(playerResult.money) or {bank = 0}
        local job = json.decode(playerResult.job) or {label = "Desempregado"}

        cb({
            exist = true,
            charinfo = charinfo,
            money = money.bank or 0,
            jobLabel = job.label or "Desempregado",
            isWarranted = warrant ~= nil,
            profile = profile,
            reports = reports or {}
        })
    else
        cb({ exist = false })
    end
end)