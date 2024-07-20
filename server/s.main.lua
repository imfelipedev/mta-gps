--// Global functions

function setGPS(player, x, y, z)
    return triggerClientEvent(player, "arrow_gps:setGPS", player, x, y, z)
end