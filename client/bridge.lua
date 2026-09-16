local Core = nil
local Framework = "standalone"

CreateThread(function()
    if Config.Framework == "vorp" or (Config.Framework == "auto" and GetResourceState("vorp_core") == "started") then
        Framework = "vorp"
        TriggerEvent("getCore", function(core)
            Core = core
        end)
    elseif Config.Framework == "rsg" or (Config.Framework == "auto" and GetResourceState("rsg-core") == "started") then
        Framework = "rsg"
        Core = exports["rsg-core"]:GetCoreObject()
    else
        Framework = "standalone"
    end
end)

function ShowNotification(text, nType)
    if not text or text == "" then return end
    nType = nType or "info"

    if Framework == "vorp" and Core and Core.NotifyRightTip then
        Core.NotifyRightTip(text, 4000)
    elseif Framework == "rsg" and Core and Core.Functions and Core.Functions.Notify then
        Core.Functions.Notify(text, nType, 4000)
    else
        BeginTextCommandPrint("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandPrint(3500, true)
    end
end

RegisterNetEvent("cagan-animpos:client:notify", function(text, nType)
    ShowNotification(text, nType)
end)

function DrawText3D(x, y, z, text)
end
