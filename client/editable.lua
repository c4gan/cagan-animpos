function isPlayingAnim()
    local ped = PlayerPedId()

    if GetResourceState("cagan-emotemenu") == "started" then
        local ok, inAnim = pcall(function() return exports["cagan-emotemenu"]:IsPlayerInAnim() end)
        if ok and type(inAnim) == "boolean" then
            if inAnim then return true end
        end
    end

    if LocalPlayer and LocalPlayer.state and (LocalPlayer.state.isInAnimation or LocalPlayer.state.inAnimation or LocalPlayer.state.isEmoting) then
        return true
    end

    if GetResourceState("rpemotes-reborn") == "started" then
        local ok, inAnim = pcall(function() return exports["rpemotes-reborn"]:IsPlayerInAnim() end)
        if ok and inAnim == true then return true end
    end

    if GetResourceState("vorp_emotes") == "started" then
        local ok, inAnim = pcall(function() return exports["vorp_emotes"]:IsPlayerInAnim() end)
        if ok and inAnim == true then return true end
    end

    if IsPedUsingAnyScenario(ped) or IsPedActiveInScenario(ped) then
        return true
    end

    return false
end

function onAnimPosOpen()
    DisplayRadar(false)
end

function onAnimPosClose()
    DisplayRadar(true)
end
