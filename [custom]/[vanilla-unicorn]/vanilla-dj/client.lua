local QBCore = exports['qb-core']:GetCoreObject()
local cam = nil
local screenObjects = {}
local screensState = false
local lightsActive = false
local currentLightMode = 'OFF'
local manualColor = {
    r = 255,
    g = 255,
    b = 255
}
local strobeState = false

-- Variáveis Vídeo
local currentDui = nil
local videoDict = "vanilla_video_dict"
local videoName = "vanilla_video_tex"

local function ExtractYoutubeId(url)
    if not url then
        return nil
    end
    local id = string.match(url, "v=([%w-_]+)")
    if not id then
        id = string.match(url, "youtu.be/([%w-_]+)")
    end
    if not id then
        id = string.match(url, "embed/([%w-_]+)")
    end
    return id
end

local function DestroyVideo()
    if currentDui then
        DestroyDui(currentDui);
        currentDui = nil
    end
    local model = GetHashKey(Config.Screens.prop)
    -- Lista de todas as texturas possíveis para limpar
    RemoveReplaceTexture(model, "script_rt_tvscreen")
    RemoveReplaceTexture(model, "tv_screen")
    RemoveReplaceTexture(model, "big_disp_def")
end

local function PlayVideoOnScreens(url)
    DestroyVideo()
    Wait(250) -- Pausa maior para garantir limpeza

    local videoId = ExtractYoutubeId(url)
    if not videoId then
        return
    end

    local resourceName = GetCurrentResourceName()
    local embedUrl = string.format("https://cfx-nui-%s/html/monitor.html?id=%s", resourceName, videoId)

    print("[DEBUG] URL Final: " .. embedUrl)

    currentDui = CreateDui(embedUrl, 1280, 720)

    local timeout = 0
    while not IsDuiAvailable(currentDui) and timeout < 200 do
        Wait(10)
        timeout = timeout + 1
    end

    if not IsDuiAvailable(currentDui) then
        print("[DEBUG] ERRO: DUI falhou.")
        return
    end

    local duiHandle = GetDuiHandle(currentDui)
    local txd = CreateRuntimeTxd(videoDict)
    local tex = CreateRuntimeTextureFromDuiHandle(txd, videoName, duiHandle)

    local model = GetHashKey(Config.Screens.prop)

    -- FORÇA BRUTA: Substitui todas as texturas conhecidas de TV neste prop
    AddReplaceTexture(model, "script_rt_tvscreen", videoDict, videoName) -- Heist TV (Principal)
    AddReplaceTexture(model, "tv_screen", videoDict, videoName) -- Genérico
    AddReplaceTexture(model, "big_disp_def", videoDict, videoName) -- Alguns props grandes

    print("[DEBUG] Texturas aplicadas.")
end

-- ============================================================
-- SPAWN DE TELAS
-- ============================================================
local function SpawnScreens()
    for _, item in pairs(screenObjects) do
        if DoesEntityExist(item.handle) then
            DeleteEntity(item.handle)
        end
    end
    screenObjects = {}

    local model = GetHashKey(Config.Screens.prop)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local r = Config.Screens.radius
    local offset = Config.Screens.headingOffset
    local rad = math.rad(offset)
    local cos = math.cos(rad)
    local sin = math.sin(rad)

    local baseDefs = {{
        x = 0.0,
        y = r,
        h = 180.0
    }, {
        x = 0.0,
        y = -r,
        h = 0.0
    }, {
        x = r,
        y = 0.0,
        h = 90.0
    }, {
        x = -r,
        y = 0.0,
        h = 270.0
    }}

    local initialZ = screensState and Config.Screens.z_down or Config.Screens.z_up

    for _, def in ipairs(baseDefs) do
        local finalX = (def.x * cos) - (def.y * sin)
        local finalY = (def.x * sin) + (def.y * cos)

        local obj = CreateObject(model, Config.Screens.center.x + finalX, Config.Screens.center.y + finalY, initialZ,
            false, false, false)

        SetEntityHeading(obj, def.h + offset)
        FreezeEntityPosition(obj, true)
        SetEntityCollision(obj, false, false)
        SetEntityCoords(obj, Config.Screens.center.x + finalX, Config.Screens.center.y + finalY, initialZ, false, false,
            false, true)
        SetEntityLodDist(obj, 1000)

        table.insert(screenObjects, {
            handle = obj,
            baseX = finalX,
            baseY = finalY
        })
    end
    SetModelAsNoLongerNeeded(model)
end

local function MoveScreens(goDown)
    screensState = goDown
    local targetZ = goDown and Config.Screens.z_down or Config.Screens.z_up
    CreateThread(function()
        local moving = true;
        local lerpSpeed = 0.02
        while moving do
            if #screenObjects == 0 then
                break
            end
            local firstItem = screenObjects[1]
            if not DoesEntityExist(firstItem.handle) then
                break
            end
            local currentZ = GetEntityCoords(firstItem.handle).z
            local dist = targetZ - currentZ
            local nextZ = currentZ + (dist * lerpSpeed)
            if math.abs(dist) < 0.02 then
                nextZ = targetZ;
                moving = false
            end
            for _, item in ipairs(screenObjects) do
                if DoesEntityExist(item.handle) then
                    SetEntityCoords(item.handle, Config.Screens.center.x + item.baseX,
                        Config.Screens.center.y + item.baseY, nextZ, false, false, false, false)
                end
            end
            Wait(0)
        end
    end)
end

-- DEBUG COMMANDS
RegisterCommand("debugtv", function()
    -- Link direto de imagem para teste (deve ficar estático)
    PlayVideoOnScreens("https://cfx-nui-qb-inventory/html/ui/images/logo.png")
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        SpawnScreens()
    end
end)
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DestroyVideo();
        for _, item in pairs(screenObjects) do
            if DoesEntityExist(item.handle) then
                DeleteEntity(item.handle)
            end
        end
    end
end)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    SpawnScreens()
end)
RegisterNetEvent('vanilla-dj:client:toggleScreens', function(state)
    MoveScreens(state)
end)
RegisterNetEvent('vanilla-dj:client:playMusic', function(url)
    PlayVideoOnScreens(url)
end)
RegisterNetEvent('vanilla-dj:client:stopMusic', function()
    DestroyVideo()
end)

-- Luzes (Manter código anterior ou este bloco compacto)
CreateThread(function()
    while true do
        if lightsActive then
            local r, g, b = 255, 255, 255
            if currentLightMode == 'STATIC' then
                r, g, b = manualColor.r, manualColor.g, manualColor.b
            elseif currentLightMode == 'STROBE' then
                if strobeState then
                    r, g, b = 255, 255, 255
                else
                    r, g, b = 0, 0, 0
                end
            elseif currentLightMode == 'RGB' then
                local t = GetGameTimer() / 1000;
                r = math.floor(math.sin(t) * 127 + 128);
                g = math.floor(math.sin(t + 2) * 127 + 128);
                b = math.floor(math.sin(t + 4) * 127 + 128)
            end
            if currentLightMode ~= 'OFF' then
                for _, light in ipairs(Config.Lights) do
                    DrawSpotLight(light.pos.x, light.pos.y, light.pos.z, light.dir.x, light.dir.y, light.dir.z, r, g, b,
                        Config.LightSettings.distance, Config.LightSettings.brightness, Config.LightSettings.hardness,
                        Config.LightSettings.radius, Config.LightSettings.falloff)
                end
            end
            Wait(0)
        else
            Wait(1000)
        end
    end
end)
CreateThread(function()
    while true do
        if lightsActive and currentLightMode == 'STROBE' then
            strobeState = not strobeState;
            Wait(150)
        else
            Wait(500)
        end
    end
end)
CreateThread(function()
    exports['qb-target']:AddBoxZone("VanillaDJ", Config.DJBoothLocation, 2.5, 2.5, {
        name = "VanillaDJ",
        heading = 0,
        debugPoly = false,
        minZ = 20.0,
        maxZ = 40.0
    }, {
        options = {{
            type = "client",
            event = "vanilla-dj:client:openMenu",
            icon = "fas fa-music",
            label = "Acessar Sistema DJ"
        }},
        distance = 3.5
    })
end)
local function EnableCam()
    DoScreenFadeOut(500);
    Wait(500);
    SetFocusArea(Config.Camera.pos.x, Config.Camera.pos.y, Config.Camera.pos.z, 0.0, 0.0, 0.0);
    RequestCollisionAtCoord(Config.Camera.pos.x, Config.Camera.pos.y, Config.Camera.pos.z);
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true);
    SetCamCoord(cam, Config.Camera.pos.x, Config.Camera.pos.y, Config.Camera.pos.z);
    SetCamRot(cam, Config.Camera.defaultRot.x, Config.Camera.defaultRot.y, Config.Camera.defaultRot.z, 2);
    SetCamFov(cam, Config.Camera.defaultFov);
    RenderScriptCams(true, false, 0, true, true);
    DisplayRadar(false);
    SetNuiFocus(true, true);
    SendNUIMessage({
        action = "open"
    });
    Wait(100);
    DoScreenFadeIn(500)
end
local function DisableCam()
    DoScreenFadeOut(500);
    Wait(500);
    SetNuiFocus(false, false);
    RenderScriptCams(false, false, 0, true, true);
    DestroyCam(cam, false);
    cam = nil;
    ClearFocus();
    DisplayRadar(true);
    Wait(500);
    DoScreenFadeIn(500)
end
RegisterNetEvent('vanilla-dj:client:openMenu', function()
    EnableCam()
end)
RegisterNetEvent('vanilla-dj:client:syncLights', function(mode, color)
    lightsActive = (mode ~= 'OFF');
    currentLightMode = mode;
    if color then
        manualColor = color
    end
end)
RegisterNUICallback('close', function(_, cb)
    DisableCam();
    cb('ok')
end)
RegisterNUICallback('playMusic', function(data, cb)
    TriggerServerEvent('vanilla-dj:server:playMusic', data.url);
    cb('ok')
end)
RegisterNUICallback('stopMusic', function(_, cb)
    TriggerServerEvent('vanilla-dj:server:stopMusic');
    cb('ok')
end)
RegisterNUICallback('setVolume', function(data, cb)
    TriggerServerEvent('vanilla-dj:server:setVolume', data.volume);
    cb('ok')
end)
RegisterNUICallback('updateLights', function(data, cb)
    TriggerServerEvent('vanilla-dj:server:syncLights', data.mode, data.color);
    cb('ok')
end)
RegisterNUICallback('toggleScreens', function(data, cb)
    TriggerServerEvent('vanilla-dj:server:toggleScreens', data.state);
    cb('ok')
end)
RegisterNUICallback('updateCam', function(data, cb)
    if cam then
        local rotZ = tonumber(data.rot);
        local fov = tonumber(data.fov);
        if rotZ then
            local newRot = Config.Camera.defaultRot.z + rotZ;
            SetCamRot(cam, Config.Camera.defaultRot.x, Config.Camera.defaultRot.y, newRot, 2)
        end
        if fov then
            SetCamFov(cam, fov)
        end
    end
    cb('ok')
end)
