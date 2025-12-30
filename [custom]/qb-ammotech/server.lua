local QBCore = exports['qb-core']:GetCoreObject()

local function CheckPermission(source, recipeJobs)
    if not recipeJobs or #recipeJobs == 0 then
        return true
    end

    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        return false
    end

    local myJob = Player.PlayerData.job.name
    local myGang = Player.PlayerData.gang.name
    local isAdmin = QBCore.Functions.HasPermission(source, 'admin') or QBCore.Functions.HasPermission(source, 'god')

    for _, jobName in pairs(recipeJobs) do
        if myJob == jobName or myGang == jobName then
            return true
        end
        if jobName == "admin" and isAdmin then
            return true
        end
    end
    return false
end

QBCore.Functions.CreateCallback('qb-ammotech:server:GetAllowedRecipes', function(source, cb, station)
    local allowed = {}
    for k, v in pairs(Config.Recipes) do
        if v.station == station then
            if CheckPermission(source, v.jobs) then
                allowed[k] = v
            end
        end
    end
    cb(allowed)
end)

RegisterNetEvent('qb-ammotech:server:AttemptCraft', function(itemKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local recipe = Config.Recipes[itemKey]

    if not recipe then
        return
    end

    if not CheckPermission(src, recipe.jobs) then
        TriggerClientEvent('QBCore:Notify', src, "Não tens permissão para isto.", "error")
        return
    end

    local canCraft = true
    for _, material in pairs(recipe.items) do
        local item = Player.Functions.GetItemByName(material.item)
        if not item or item.amount < material.amount then
            canCraft = false
            break
        end
    end

    if canCraft then
        for _, material in pairs(recipe.items) do
            Player.Functions.RemoveItem(material.item, material.amount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[material.item], "remove")
        end
        TriggerClientEvent('qb-ammotech:client:StartAnimation', src, itemKey, recipe.craftTime)
    else
        TriggerClientEvent('QBCore:Notify', src, "Faltam componentes.", "error")
    end
end)

RegisterNetEvent('qb-ammotech:server:CraftFinish', function(itemKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Config.Recipes[itemKey] then
        return
    end

    if Player.Functions.AddItem(itemKey, 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemKey], "add")
        TriggerClientEvent('QBCore:Notify', src, "Produção finalizada!", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Bolsos cheios!", "error")
    end
end)
