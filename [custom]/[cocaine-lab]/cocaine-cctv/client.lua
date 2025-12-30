local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()

local activeCam = nil
local currentCamsData = {}
local currentCamIndex = 1

local savedCoords = nil
local savedHeading = nil
local spawnedProps = {}

local animDict = "mp_prison_break"
local animName = "hack_loop"
local animExit = "hack_exit"

local defaultCamModel = "prop_cctv_cam_06a"

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo)
    PlayerData.gang = GangInfo
end)

local function HasAccess(authorizedList)
    if not authorizedList then
        return true
    end

    local myJob = PlayerData.job.name
    local myGang = PlayerData.gang.name

    if authorizedList[myJob] or authorizedList[myGang] then
        return true
    end

    return false
end

CreateThread(function()
    if not Config or not Config.Locations then
        return
    end

    for k, v in pairs(Config.Locations) do
        exports['qb-target']:AddBoxZone("CamSys_" .. k, v.target.coords, v.target.length, v.target.width, {
            name = "CamSys_" .. k,
            heading = v.target.heading,
            debugPoly = v.target.debugPoly,
            minZ = v.target.minZ,
            maxZ = v.target.maxZ
        }, {
            options = {{
                action = function()
                    OpenSystem(v)
                end,
                icon = "fas fa-video",
                label = "Aceder Sistema CCTV",

                canInteract = function()
                    return HasAccess(v.authorized)
                end
            }},
            distance = 2.0
        })
    end

    SpawnPhysicalCameras()
end)

function SpawnPhysicalCameras()
    for _, location in pairs(Config.Locations) do
        for _, cam in pairs(location.cams) do
            if cam.spawnProp ~= false then
                local modelToUse = cam.model or defaultCamModel

                RequestModel(modelToUse)
                local timeout = 0
                while not HasModelLoaded(modelToUse) do
                    Wait(10)
                    timeout = timeout + 1
                    if timeout > 100 then
                        modelToUse = defaultCamModel
                        RequestModel(modelToUse)
                    end
                end

                local finalCoords = cam.propCoords or cam.coords
                local finalRot = cam.propRot or cam.rot

                local obj = CreateObject(GetHashKey(modelToUse), finalCoords.x, finalCoords.y, finalCoords.z, false,
                    false, false)

                SetEntityRotation(obj, finalRot.x, finalRot.y, finalRot.z, 2, true)

                FreezeEntityPosition(obj, true)
                table.insert(spawnedProps, obj)

                SetModelAsNoLongerNeeded(modelToUse)
            end
        end
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    for _, obj in pairs(spawnedProps) do
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
    end
end)

function OpenSystem(locationData)
    if not HasAccess(locationData.authorized) then
        QBCore.Functions.Notify("Não tens permissão para aceder a este sistema.", "error")
        return
    end

    local ped = PlayerPedId()

    savedCoords = GetEntityCoords(ped)
    savedHeading = GetEntityHeading(ped)

    currentCamsData = locationData.cams
    currentCamIndex = 1

    DoScreenFadeOut(500)
    Wait(500)

    RequestAnimDict(animDict)
    local timeout = 0
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
        timeout = timeout + 1
        if timeout > 100 then
            break
        end
    end

    SetEntityCollision(ped, false, false)

    SetEntityCoords(ped, locationData.anim.coords)
    SetEntityHeading(ped, locationData.anim.heading)

    FreezeEntityPosition(ped, true)

    if HasAnimDictLoaded(animDict) then
        TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
    end

    activeCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    UpdateCameraPosition()
    RenderScriptCams(true, false, 0, true, true)

    DoScreenFadeIn(500)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        label = locationData.label,
        camName = currentCamsData[currentCamIndex].name
    })
end

function UpdateCameraPosition()
    if not currentCamsData or not currentCamsData[currentCamIndex] then
        return
    end

    local data = currentCamsData[currentCamIndex]

    SetFocusArea(data.coords.x, data.coords.y, data.coords.z, 0.0, 0.0, 0.0)

    SetCamCoord(activeCam, data.coords)
    SetCamRot(activeCam, data.rot, 2)
    SetTimecycleModifier("scanline_cam_cheap")
    SetTimecycleModifierStrength(1.0)
end

RegisterNUICallback('close', function(data, cb)
    local ped = PlayerPedId()

    SetNuiFocus(false, false)

    DoScreenFadeOut(500)
    Wait(500)

    ClearFocus()
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(activeCam, false)
    activeCam = nil
    ClearTimecycleModifier()

    DoScreenFadeIn(500)

    if HasAnimDictLoaded(animDict) then
        TaskPlayAnim(ped, animDict, animExit, 8.0, -8.0, -1, 0, 0, false, false, false)

        local duration = GetAnimDuration(animDict, animExit) * 1000
        Wait(duration)
    end

    FreezeEntityPosition(ped, false)
    ClearPedTasks(ped)

    if savedCoords then
        SetEntityCoords(ped, savedCoords.x, savedCoords.y, savedCoords.z - 0.9)
        SetEntityHeading(ped, savedHeading)
    else
        local off = GetOffsetFromEntityInWorldCoords(ped, 0.0, -1.5, 0.0)
        SetEntityCoords(ped, off.x, off.y, off.z)
    end

    SetEntityCollision(ped, true, true)

    cb('ok')
end)

RegisterNUICallback('change', function(data, cb)
    if data.direction == "next" then
        currentCamIndex = currentCamIndex + 1
        if currentCamIndex > #currentCamsData then
            currentCamIndex = 1
        end
    elseif data.direction == "prev" then
        currentCamIndex = currentCamIndex - 1
        if currentCamIndex < 1 then
            currentCamIndex = #currentCamsData
        end
    end

    UpdateCameraPosition()
    cb(currentCamsData[currentCamIndex].name)
end)
