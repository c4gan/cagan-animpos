local function handleAnimPosCommand(args)
    if args and #args > 0 and (args[1]:lower() == "cancel" or args[1]:lower() == "reset" or args[1]:lower() == "iptal") then
        CloseAnimPos()
    else
        OpenAnimPos()
    end
end

RegisterCommand("animpos", function(_, args)
    handleAnimPosCommand(args)
end, false)

if Config.AnimPos.command and Config.AnimPos.command ~= "animpos" then
    RegisterCommand(Config.AnimPos.command, function(_, args)
        handleAnimPosCommand(args)
    end, false)
end

CreateThread(function()
    Wait(1500)
    TriggerEvent("chat:addSuggestion", "/animpos", _U("ANIM_POS_COMMAND_DESC"))
end)

RegisterNetEvent("cagan-animpos:client:openAnimPos", function()
    OpenAnimPos()
end)

RegisterNetEvent("cagan-animpos:client:syncPlayer", function(targetSrc, coords, heading, alpha)
    local localSrc = GetPlayerServerId(PlayerId())
    if targetSrc == localSrc then return end

    local targetPlayer = GetPlayerFromServerId(targetSrc)
    if targetPlayer and targetPlayer ~= -1 then
        local targetPed = GetPlayerPed(targetPlayer)
        if targetPed and targetPed ~= 0 then
            SetEntityCoords(targetPed, coords.x, coords.y, coords.z, false, false, false, false)
            SetEntityHeading(targetPed, heading)
            if alpha and alpha < 255 then
                SetEntityAlpha(targetPed, alpha, false)
            else
                ResetEntityAlpha(targetPed)
            end
        end
    end
end)
