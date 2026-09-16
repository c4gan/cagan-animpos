if not Config.AnimPos.active then
    return
end

local isAnimPosOpen = false
local isAnimPosActive = false
local currentAttachedObject = nil
local initialCoords = nil
local initialRot = nil
local isGizmoActive = false
local gizmoResult = nil
local gizmoCam = nil
local gizmoMode = "translate"
local currentEntityCoords = nil
local currentEntityRot = nil

local function deleteAttachedObject()
    local ped = PlayerPedId()
    if DoesEntityExist(ped) then
        DetachEntity(ped, true, true)
        FreezeEntityPosition(ped, false)
        SetEntityCollision(ped, true, true)
    end
    if currentAttachedObject and DoesEntityExist(currentAttachedObject) then
        DeleteEntity(currentAttachedObject)
        currentAttachedObject = nil
    end
end

local function createAttachedObject(ped, coords, rotation)
    deleteAttachedObject()

    local pedCoords = coords or GetEntityCoords(ped)
    local modelHash = joaat(Config.AnimPos.anchorModel or "scriptedball")

    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        local timeout = GetGameTimer() + 3000
        while not HasModelLoaded(modelHash) and GetGameTimer() < timeout do
            Wait(10)
        end
    end

    local obj = CreateObjectNoOffset(modelHash, pedCoords.x, pedCoords.y, pedCoords.z, true, false, false, false)
    FreezeEntityPosition(obj, true)

    if not rotation then
        rotation = GetEntityRotation(ped, 2)
    end

    SetEntityCollision(obj, false, false)
    SetEntityVisible(obj, false)

    AttachEntityToEntity(
        ped, obj, 0,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        false, false, false, false, 2, true
    )

    if coords then
        SetEntityCoords(obj, coords.x, coords.y, coords.z, false, false, false, false)
    end

    if rotation then
        SetEntityRotation(obj, rotation.x, rotation.y, rotation.z, 2, false)
    end

    currentAttachedObject = obj
    return obj
end

local AnimPosPromptGroup = GetRandomIntInRange(0, 0xffffff)
local PromptRotate = nil
local PromptGround = nil
local PromptCam = nil
local PromptConfirm = nil
local PromptCancel = nil

local function SafePromptSetGroup(prompt, group)
    if UiPromptSetGroup then
        pcall(UiPromptSetGroup, prompt, group, 0)
    end
    if PromptSetGroup then
        pcall(PromptSetGroup, prompt, group)
    end
end

local function SafePromptSetActiveGroup(group, title)
    if UiPromptSetActiveGroupThisFrame then
        pcall(UiPromptSetActiveGroupThisFrame, group, title, 0, 0, 0, 0)
    end
    if PromptSetActiveGroupThisFrame then
        pcall(PromptSetActiveGroupThisFrame, group, title)
    end
end

local function initAnimPosPrompts()
    if PromptRotate then return end

    PromptRotate = (UiPromptRegisterBegin and UiPromptRegisterBegin()) or PromptRegisterBegin()
    PromptSetControlAction(PromptRotate, 0xCEE12B50)
    PromptSetText(PromptRotate, CreateVarString(10, 'LITERAL_STRING', _U("PROMPT_CHANGE_MODE")))
    PromptSetEnabled(PromptRotate, true)
    PromptSetVisible(PromptRotate, true)
    PromptSetStandardMode(PromptRotate, true)
    SafePromptSetGroup(PromptRotate, AnimPosPromptGroup)
    if UiPromptRegisterEnd then UiPromptRegisterEnd(PromptRotate) else PromptRegisterEnd(PromptRotate) end

    PromptGround = (UiPromptRegisterBegin and UiPromptRegisterBegin()) or PromptRegisterBegin()
    PromptSetControlAction(PromptGround, 0xD9D0E1C0)
    PromptSetText(PromptGround, CreateVarString(10, 'LITERAL_STRING', _U("PROMPT_SNAP_GROUND")))
    PromptSetEnabled(PromptGround, true)
    PromptSetVisible(PromptGround, true)
    PromptSetStandardMode(PromptGround, true)
    SafePromptSetGroup(PromptGround, AnimPosPromptGroup)
    if UiPromptRegisterEnd then UiPromptRegisterEnd(PromptGround) else PromptRegisterEnd(PromptGround) end

    PromptCam = (UiPromptRegisterBegin and UiPromptRegisterBegin()) or PromptRegisterBegin()
    PromptSetControlAction(PromptCam, 0xF84FA74F)
    PromptSetText(PromptCam, CreateVarString(10, 'LITERAL_STRING', _U("PROMPT_ORBIT_CAM")))
    PromptSetEnabled(PromptCam, true)
    PromptSetVisible(PromptCam, true)
    PromptSetStandardMode(PromptCam, true)
    SafePromptSetGroup(PromptCam, AnimPosPromptGroup)
    if UiPromptRegisterEnd then UiPromptRegisterEnd(PromptCam) else PromptRegisterEnd(PromptCam) end

    PromptConfirm = (UiPromptRegisterBegin and UiPromptRegisterBegin()) or PromptRegisterBegin()
    PromptSetControlAction(PromptConfirm, 0xC7B5340A)
    PromptSetText(PromptConfirm, CreateVarString(10, 'LITERAL_STRING', _U("PROMPT_CONFIRM")))
    PromptSetEnabled(PromptConfirm, true)
    PromptSetVisible(PromptConfirm, true)
    PromptSetStandardMode(PromptConfirm, true)
    SafePromptSetGroup(PromptConfirm, AnimPosPromptGroup)
    if UiPromptRegisterEnd then UiPromptRegisterEnd(PromptConfirm) else PromptRegisterEnd(PromptConfirm) end

    PromptCancel = (UiPromptRegisterBegin and UiPromptRegisterBegin()) or PromptRegisterBegin()
    PromptSetControlAction(PromptCancel, 0x156F7119)
    PromptSetText(PromptCancel, CreateVarString(10, 'LITERAL_STRING', _U("PROMPT_CANCEL")))
    PromptSetEnabled(PromptCancel, true)
    PromptSetVisible(PromptCancel, true)
    PromptSetStandardMode(PromptCancel, true)
    SafePromptSetGroup(PromptCancel, AnimPosPromptGroup)
    if UiPromptRegisterEnd then UiPromptRegisterEnd(PromptCancel) else PromptRegisterEnd(PromptCancel) end
end

local function UseGizmo(entity, opts)
    opts = opts or {}
    initAnimPosPrompts()
    local initialPos = GetEntityCoords(entity)
    local initialRotation = GetEntityRotation(entity, 2)
    currentEntityCoords = initialPos
    currentEntityRot = initialRotation
    gizmoMode = "translate"
    isGizmoActive = true
    gizmoResult = { success = false }

    local camDistance = 3.0
    local camPitch = -10.0
    local camYaw = GetEntityHeading(entity) - 180.0
    local camHeight = 0.35

    gizmoCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local radY = math.rad(camYaw)
    local radP = math.rad(camPitch)
    local cx = initialPos.x + camDistance * math.cos(radP) * math.sin(radY)
    local cy = initialPos.y + camDistance * math.cos(radP) * math.cos(radY)
    local cz = initialPos.z + camHeight + camDistance * math.sin(radP)
    SetCamCoord(gizmoCam, cx, cy, cz)
    PointCamAtCoord(gizmoCam, initialPos.x, initialPos.y, initialPos.z + camHeight)
    SetCamFov(gizmoCam, 55.0)
    RenderScriptCams(true, true, 500, true, true)

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)

    local function sendEntityToGizmo()
        local currentLang = (Config and Config.Locale) or "tr"
        SendNUIMessage({
            action = "setGizmoEntity",
            data = {
                handle = entity,
                position = { x = currentEntityCoords.x, y = currentEntityCoords.y, z = currentEntityCoords.z },
                rotation = { x = currentEntityRot.x, y = currentEntityRot.y, z = currentEntityRot.z },
                rotationOrder = 2,
                locale = currentLang,
                locales = (Locales and (Locales[currentLang] or Locales["en"])) or {}
            }
        })
    end

    local function sendCameraToGizmo()
        local cPos = GetCamCoord(gizmoCam)
        local cRot = GetCamRot(gizmoCam, 2)
        SendNUIMessage({
            action = "setGizmoCamera",
            data = {
                position = { x = cPos.x, y = cPos.y, z = cPos.z },
                rotation = { x = cRot.x, y = cRot.y, z = cRot.z }
            }
        })
    end

    sendEntityToGizmo()
    sendCameraToGizmo()

    while isGizmoActive do
        Wait(0)

        DisableControlAction(0, 0x8FD015D8, true)
        DisableControlAction(0, 0xD27782E3, true)
        DisableControlAction(0, 0x7065027D, true)
        DisableControlAction(0, 0xB4E465B4, true)
        DisableControlAction(0, 0x07CE1E0D, true)
        DisableControlAction(0, 0xB2F377E8, true)
        DisableControlAction(0, 0xAC4FC4F2, true)
        DisableControlAction(0, 0x8FF9E6F2, true)

        EnableControlAction(0, 0xCEE12B50, true)
        EnableControlAction(0, 0xE30CD707, true)
        EnableControlAction(0, 0xD9D0E1C0, true)
        EnableControlAction(0, 0xC7B5340A, true)
        EnableControlAction(0, 0x156F7119, true)
        EnableControlAction(0, 0x308588E6, true)
        EnableControlAction(0, 0xF84FA74F, true)

        local promptTitle = CreateVarString(10, 'LITERAL_STRING', gizmoMode == "translate" and _U("PROMPT_TITLE_TRANSLATE") or _U("PROMPT_TITLE_ROTATE"))
        SafePromptSetActiveGroup(AnimPosPromptGroup, promptTitle)

        if IsDisabledControlPressed(0, 0xF84FA74F) or IsControlPressed(0, 0xF84FA74F) then
            local mouseX = GetDisabledControlNormal(0, 0xA987235F)
            local mouseY = GetDisabledControlNormal(0, 0xD2047988)
            if math.abs(mouseX) > 0.0005 or math.abs(mouseY) > 0.0005 then
                camYaw = (camYaw - mouseX * 8.0) % 360.0
                camPitch = math.max(-60.0, math.min(65.0, camPitch - mouseY * 8.0))
                local rY = math.rad(camYaw)
                local rP = math.rad(camPitch)
                local nx = currentEntityCoords.x + camDistance * math.cos(rP) * math.sin(rY)
                local ny = currentEntityCoords.y + camDistance * math.cos(rP) * math.cos(rY)
                local nz = currentEntityCoords.z + camHeight + camDistance * math.sin(rP)
                SetCamCoord(gizmoCam, nx, ny, nz)
                PointCamAtCoord(gizmoCam, currentEntityCoords.x, currentEntityCoords.y, currentEntityCoords.z + camHeight)
                sendCameraToGizmo()
            end
        end

        if IsDisabledControlJustPressed(0, 0x3BB70DE1) or IsControlJustPressed(0, 0x3BB70DE1) then
            camDistance = math.max(1.2, camDistance - 0.25)
            local rY = math.rad(camYaw)
            local rP = math.rad(camPitch)
            local nx = currentEntityCoords.x + camDistance * math.cos(rP) * math.sin(rY)
            local ny = currentEntityCoords.y + camDistance * math.cos(rP) * math.cos(rY)
            local nz = currentEntityCoords.z + camHeight + camDistance * math.sin(rP)
            SetCamCoord(gizmoCam, nx, ny, nz)
            sendCameraToGizmo()
        elseif IsDisabledControlJustPressed(0, 0x446258B6) or IsControlJustPressed(0, 0x446258B6) then
            camDistance = math.min(6.0, camDistance + 0.25)
            local rY = math.rad(camYaw)
            local rP = math.rad(camPitch)
            local nx = currentEntityCoords.x + camDistance * math.cos(rP) * math.sin(rY)
            local ny = currentEntityCoords.y + camDistance * math.cos(rP) * math.cos(rY)
            local nz = currentEntityCoords.z + camHeight + camDistance * math.sin(rP)
            SetCamCoord(gizmoCam, nx, ny, nz)
            sendCameraToGizmo()
        end

        local rotateCompleted = (UiPromptHasStandardModeCompleted and UiPromptHasStandardModeCompleted(PromptRotate)) or (PromptHasStandardModeCompleted and PromptHasStandardModeCompleted(PromptRotate))
        if rotateCompleted or
           IsDisabledControlJustPressed(0, 0xCEE12B50) or IsControlJustPressed(0, 0xCEE12B50) or
           IsDisabledControlJustPressed(0, 0xE30CD707) or IsControlJustPressed(0, 0xE30CD707) then
            gizmoMode = (gizmoMode == "translate") and "rotate" or "translate"
            SendNUIMessage({
                action = "gizmoMode",
                data = { uiMode = (gizmoMode == "rotate") }
            })
        end

        local groundCompleted = (UiPromptHasStandardModeCompleted and UiPromptHasStandardModeCompleted(PromptGround)) or (PromptHasStandardModeCompleted and PromptHasStandardModeCompleted(PromptGround))
        if groundCompleted or
           IsDisabledControlJustPressed(0, 0xD9D0E1C0) or IsControlJustPressed(0, 0xD9D0E1C0) then
            if opts.customSnapGround then
                opts.customSnapGround()
            else
                local success, groundZ = GetGroundZFor_3dCoord(currentEntityCoords.x, currentEntityCoords.y, currentEntityCoords.z + 1.0, true)
                if success then
                    currentEntityCoords = vector3(currentEntityCoords.x, currentEntityCoords.y, groundZ + 0.98)
                    SetEntityCoords(entity, currentEntityCoords.x, currentEntityCoords.y, currentEntityCoords.z, false, false, false, false)
                end
            end
            currentEntityCoords = GetEntityCoords(entity)
            currentEntityRot = GetEntityRotation(entity, 2)
            sendEntityToGizmo()
        end

        local confirmCompleted = (UiPromptHasStandardModeCompleted and UiPromptHasStandardModeCompleted(PromptConfirm)) or (PromptHasStandardModeCompleted and PromptHasStandardModeCompleted(PromptConfirm))
        if confirmCompleted or
           IsDisabledControlJustPressed(0, 0xC7B5340A) or IsControlJustPressed(0, 0xC7B5340A) then
            gizmoResult = {
                success = true,
                position = currentEntityCoords,
                rotation = currentEntityRot
            }
            break
        end

        local cancelCompleted = (UiPromptHasStandardModeCompleted and UiPromptHasStandardModeCompleted(PromptCancel)) or (PromptHasStandardModeCompleted and PromptHasStandardModeCompleted(PromptCancel))
        if cancelCompleted or
           IsDisabledControlJustPressed(0, 0x156F7119) or IsControlJustPressed(0, 0x156F7119) or
           IsDisabledControlJustPressed(0, 0x308588E6) or IsControlJustPressed(0, 0x308588E6) then
            gizmoResult = { success = false }
            break
        end
    end

    SendNUIMessage({ action = "setGizmoEntity", data = nil })

    if gizmoCam then
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(gizmoCam, true)
        gizmoCam = nil
    end

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    isGizmoActive = false

    return gizmoResult
end

RegisterNUICallback("gizmoMoveEntity", function(data, cb)
    cb("")
    if not isGizmoActive or not currentAttachedObject then return end

    local newPos = vector3(data.position.x, data.position.y, data.position.z)
    local newRot = vector3(data.rotation.x, data.rotation.y, data.rotation.z)

    if initialCoords and #(newPos - initialCoords) <= (Config.AnimPos.maxDistance.xy or 4.0) then
        SetEntityCoords(currentAttachedObject, newPos.x, newPos.y, newPos.z, false, false, false, false)
        SetEntityRotation(currentAttachedObject, newRot.x, newRot.y, newRot.z, 2, false)
        currentEntityCoords = newPos
        currentEntityRot = newRot
    end
end)

RegisterNUICallback("gizmoSetPreferredMode", function(data, cb)
    cb("")
end)

RegisterNUICallback("uiReady", function(data, cb)
    cb("")
end)

function OpenAnimPos()
    if isAnimPosOpen then
        CloseAnimPos()
        return
    end

    local ped = PlayerPedId()

    if Config.AnimPos.requireAnimation and not isPlayingAnim() then
        return ShowNotification(_U("NOT_PLAYING_ANIM"), "error")
    end

    if IsPedInAnyVehicle(ped, false) then
        return ShowNotification(_U("ANIM_POS_CANT_USE_IN_VEH"), "error")
    end

    if Config.AnimPos.playerOpacity.active then
        SetEntityAlpha(ped, Config.AnimPos.playerOpacity.opacity or 200, false)
    end

    currentAttachedObject = createAttachedObject(ped)
    initialCoords = GetEntityCoords(currentAttachedObject)
    initialRot = GetEntityRotation(currentAttachedObject, 2)

    onAnimPosOpen()
    isAnimPosOpen = true

    local result = UseGizmo(currentAttachedObject, {
        keys = {
            { icon = "enterKey", label = _U("ANIM_POS_DONE") },
            { icon = "escKey", label = _U("ANIM_POS_CANCEL") }
        },
        customSnapGround = function()
            local pCoords = GetEntityCoords(ped)
            local success, groundZ = GetGroundZFor_3dCoord(pCoords.x, pCoords.y, pCoords.z, true)
            if success then
                SetEntityCoords(currentAttachedObject, pCoords.x, pCoords.y, groundZ + 0.98, false, false, false, false)
            end
        end,
        maxDistance = Config.AnimPos.maxDistance,
        cameraMaxDistance = Config.AnimPos.cameraMaxDistance or 20.0
    })

    onAnimPosClose()
    isAnimPosOpen = false

    if Config.AnimPos.playerOpacity.active then
        ResetEntityAlpha(ped)
    end

    if not result.success then
        currentAttachedObject = createAttachedObject(ped, initialCoords, initialRot)
        if not isAnimPosActive then
            Wait(100)
            deleteAttachedObject()
        end
        initialCoords = nil
        ShowNotification(_U("ANIM_POS_CANCEL"), "info")
        return
    end

    currentAttachedObject = createAttachedObject(ped, result.position, result.rotation)
    SetEntityCoords(currentAttachedObject, result.position.x, result.position.y, result.position.z, false, false, false, false)
    SetEntityRotation(currentAttachedObject, result.rotation.x, result.rotation.y, result.rotation.z, 2, false)
    ShowNotification(_U("ANIM_POS_DONE"), "success")
    TriggerServerEvent("cagan-animpos:server:syncPlayer", result.position, result.rotation.z, 255)

    if isAnimPosActive then
        return
    end

    isAnimPosActive = true

    while not isAnimPosOpen and isAnimPosActive do
        local pPed = PlayerPedId()
        if not isPlayingAnim() or IsEntityDead(pPed) or IsPedRagdoll(pPed) or IsPedInAnyVehicle(pPed, false) then
            break
        end

        if IsControlJustPressed(0, 0x8CC9CD42) or IsDisabledControlJustPressed(0, 0x8CC9CD42)
            or IsControlJustPressed(0, 0xD9D0E1C0) or IsDisabledControlJustPressed(0, 0xD9D0E1C0)
            or IsControlJustPressed(0, 0x8FD015D8) or IsControlJustPressed(0, 0xD27782E3)
            or IsControlJustPressed(0, 0x7065027D) or IsControlJustPressed(0, 0xB4E465B4)
            or IsControlJustPressed(0, 0x156F7119)  then
            break
        end
        Wait(100)
    end

    if Config.AnimPos.abuseControl and initialCoords then
        currentAttachedObject = createAttachedObject(ped, initialCoords, initialRot)
        initialCoords = nil
        initialRot = nil
        Wait(100)
    end

    deleteAttachedObject()
    isAnimPosActive = false
end

exports("OpenAnimPos", OpenAnimPos)

function CloseAnimPos()
    isAnimPosOpen = false
    isGizmoActive = false
    isAnimPosActive = false
    deleteAttachedObject()
end

exports("CloseAnimPos", CloseAnimPos)
exports("DetachAnimPos", CloseAnimPos)

RegisterNetEvent("cagan-animpos:client:detach", function()
    CloseAnimPos()
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if currentAttachedObject then
        deleteAttachedObject()
    end
    if isAnimPosOpen then
        CloseAnimPos()
    end
end)
