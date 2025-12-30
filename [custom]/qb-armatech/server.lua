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

QBCore.Functions.CreateCallback('qb-armatech:server:GetAllowedRecipes', function(source, cb, station)
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

RegisterNetEvent('qb-armatech:server:AttemptCraft', function(weaponKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local recipe = Config.Recipes[weaponKey]

    if not recipe then
        return
    end

    if not CheckPermission(src, recipe.jobs) then
        TriggerClientEvent('QBCore:Notify', src, "Não tens permissão para fabricar isto.", "error")
        return
    end

    if recipe.blueprint then
        local hasBlueprint = Player.Functions.GetItemByName(recipe.blueprint)
        if not hasBlueprint then
            TriggerClientEvent('QBCore:Notify', src, "Falta o Esquema (Blueprint)!", "error")
            return
        end
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
        TriggerClientEvent('qb-armatech:client:StartAnimation', src, weaponKey, recipe.craftTime)
    else
        TriggerClientEvent('QBCore:Notify', src, "Materiais insuficientes.", "error")
    end
end)

RegisterNetEvent('qb-armatech:server:CraftFinish', function(weaponKey)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Config.Recipes[weaponKey] then
        return
    end

    if Player.Functions.AddItem(weaponKey, 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[weaponKey], "add")
        TriggerClientEvent('QBCore:Notify', src, "Produção concluída!", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Inventário cheio!", "error")
    end
end)
