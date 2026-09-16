RegisterNetEvent("cagan-animpos:server:syncPlayer", function(coords, heading, alpha)
    local src = source
    TriggerClientEvent("cagan-animpos:client:syncPlayer", -1, src, coords, heading, alpha)
end)
