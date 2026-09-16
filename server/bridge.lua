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

function NotifyPlayer(src, text, nType)
    TriggerClientEvent("cagan-animpos:client:notify", src, text, nType)
end

function CheckPlayerHasItem(src, itemName, count)
    count = count or 1
    if Framework == "vorp" and Core then
        local user = Core.getUser(src)
        if not user then return false end
        local character = user.getUsedCharacter
        if not character then return false end
        local inv = exports.vorp_inventory:getUserInventory(src)
        if inv then
            for _, item in pairs(inv) do
                if item.name == itemName and item.count >= count then
                    return true
                end
            end
        end
        return false
    elseif Framework == "rsg" and Core then
        local player = Core.Functions.GetPlayer(src)
        if not player then return false end
        local item = player.Functions.GetItemByName(itemName)
        return item and item.amount >= count
    end
    return true
end

function RemovePlayerItem(src, itemName, count)
    count = count or 1
    if Framework == "vorp" then
        local success = exports.vorp_inventory:subItem(src, itemName, count)
        return success ~= false
    elseif Framework == "rsg" and Core then
        local player = Core.Functions.GetPlayer(src)
        if player then
            return player.Functions.RemoveItem(itemName, count)
        end
    end
    return true
end

function AddPlayerItem(src, itemName, count, metadata)
    count = count or 1
    metadata = metadata or {}
    if Framework == "vorp" then
        exports.vorp_inventory:addItem(src, itemName, count, metadata)
        return true
    elseif Framework == "rsg" and Core then
        local player = Core.Functions.GetPlayer(src)
        if player then
            return player.Functions.AddItem(itemName, count, nil, metadata)
        end
    end
    return true
end
