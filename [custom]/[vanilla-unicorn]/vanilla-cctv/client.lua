local QBCore = exports['qb-core']:GetCoreObject()
local activeCam = nil
local currentCamsData = {}
local currentCamIndex = 1

local savedCoords = nil
local savedHeading = nil

local animDict = "anim@amb@office@laptops_v1@male@var_b@base@"
local animName = "base"

CreateThread(function()
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
                label = "Aceder Sistema CCTV"
            }},
            distance = 2.0
        })
    end

    local chairModel = GetHashKey("v_club_officechair")
    local chairCoords = vector3(95.2, -1294.2, 29.3)

    while true do
        Wait(2000)
        local chairObject = GetClosestObjectOfType(chairCoords.x, chairCoords.y, chairCoords.z, 2.0, chairModel, false,
            false, false)
        if chairObject ~= 0 then
            FreezeEntityPosition(chairObject, true)
            break
        end
    end
end)

function OpenSystem(locationData)
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
    local data = currentCamsData[currentCamIndex]
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

    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(activeCam, false)
    activeCam = nil
    ClearTimecycleModifier()

    FreezeEntityPosition(ped, false)

    ClearPedTasksImmediately(ped)

    if savedCoords then
        SetEntityCoords(ped, savedCoords.x, savedCoords.y, savedCoords.z - 0.9)
        SetEntityHeading(ped, savedHeading)
    else
        local off = GetOffsetFromEntityInWorldCoords(ped, 0.0, -1.5, 0.0)
        SetEntityCoords(ped, off.x, off.y, off.z)
    end

    SetEntityCollision(ped, true, true)

    DoScreenFadeIn(500)
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
