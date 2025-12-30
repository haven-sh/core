local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

local function HasAccess(authorizedList)
    if not authorizedList then
        return true
    end
    local myJob = PlayerData.job.name
    if authorizedList[myJob] then
        return true
    end
    return false
end

CreateThread(function()
    if Config.Elevator then
        -- 1. ENTRADA (RUA)
        local entrance = Config.Elevator.Entrance
        exports['qb-target']:AddBoxZone("Elevator_Entrance", entrance.coords, 2.5, 2.5, {
            name = "Elevator_Entrance",
            heading = entrance.heading,
            debugPoly = false,
            minZ = entrance.coords.z - 2.0,
            maxZ = entrance.coords.z + 2.0
        }, {
            options = {{
                icon = "fas fa-id-card",
                label = entrance.label,
                action = function()
                    TeleportPlayer(entrance.targetLoc, entrance.targetHeading)
                end,
                canInteract = function()
                    return HasAccess(entrance.authorized)
                end
            }},
            distance = 2.5
        })

        -- 2. SAÍDA (ESCRITÓRIO)
        local exit = Config.Elevator.OfficeExit
        exports['qb-target']:AddBoxZone("Elevator_Exit", exit.coords, 2.5, 2.5, {
            name = "Elevator_Exit",
            heading = exit.heading,
            debugPoly = false,
            minZ = exit.coords.z - 2.0,
            maxZ = exit.coords.z + 2.0
        }, {
            options = {{
                icon = "fas fa-arrow-down",
                label = exit.label,
                action = function()
                    TeleportPlayer(exit.targetLoc, exit.targetHeading)
                end,
                canInteract = function()
                    return HasAccess(exit.authorized)
                end
            }},
            distance = 2.5
        })
    end
end)

function TeleportPlayer(coords, heading)
    local ped = PlayerPedId()
    PlaySoundFrontend(-1, "Collated_Pass_Out", "PIS_Gel_Pay_Soundset", true)
    DoScreenFadeOut(500)
    Wait(1000)
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
    SetEntityHeading(ped, heading)
    Wait(500)
    DoScreenFadeIn(500)
end

-- =============================================================
-- CARREGAR INTERIOR "ICE" (ARCADIUS MODERN TECH)
-- =============================================================
CreateThread(function()
    -- Carrega o estilo "ICE" (Branco e Vidro) do escritório Arcadius
    RequestIpl("ex_dt1_02_office_02b")

    -- Garante que o interior atualiza
    local interiorID = GetInteriorAtCoords(-141.1987, -620.913, 168.82)

    if IsValidInterior(interiorID) then
        RefreshInterior(interiorID)
    end
end)
