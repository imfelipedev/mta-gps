local Arrow = {}

function Arrow:constructor()
    self.gps = {}
    self.config = {}
    self.handler = false
    return self:setup()
end

function Arrow:getRotation(x1, y1, x2, y2)
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end

function Arrow:getDistance3D(x1, y1, z1, x2, y2, z2)
    local vectorX, vectorY, vectorZ = x2 - x1, y2 - y1, z2 - z1
    return (vectorX * vectorX + vectorY * vectorY + vectorZ * vectorZ) ^ 0.5
end

function Arrow:getCount()
    local count = 0
    for _ in pairs(self.gps) do 
        count = count + 1
    end
    return count
end

function Arrow:remove(player)
    if not self.gps[player] then 
        return false 
    end

    if isElement(self.gps[player].object) then 
        destroyElement(self.gps[player].object)
    end

    self.gps[player] = nil
    return self:manage() 
end

function Arrow:add(player, x, y, z)
    if self.gps[player] then 
        return self:remove(player)
    end

    self.gps[player] = {
        object = createObject(self.config.main.object_id, 0, 0, 0),
        target = {
            x = x,
            y = y,
            z = z
        }
    }
    setObjectScale(self.gps[player].object, self.config.main.object_size)
    return self:manage()
end

function Arrow:render()
    for player, value in pairs(self.gps) do
        if not isElement(player) then 
            return self:remove(player)
        end

        local playerX, playerY, playerZ = getPedBonePosition(player, 8)
        local distance = self:getDistance3D(playerX, playerY, playerZ, value.target.x, value.target.y, value.target.z)
        if distance <= self.config.main.remove_limite then 
            return self:remove(player)
        end

        local rotation = self:getRotation(playerX, playerY, value.target.x, value.target.y)
        setElementRotation(value.object, 0, 90, rotation - 90)
        setElementPosition(value.object, playerX, playerY, playerZ + 0.3)
    end
    return true
end

function Arrow:addHandler()
    self.handler = true
    addEventHandler("onClientRender", root, self.__render__)
    return true
end

function Arrow:removeHandler()
    local count = self:getCount()
    if count > 0 then 
        return false 
    end

    self.handler = false
    removeEventHandler("onClientRender", root, self.__render__)
    return true
end

function Arrow:manage()
    if self.handler then 
        return self:removeHandler() 
    end

    return self:addHandler()
end

function Arrow:setup()
    self.config = getConfig()

    self.__render__ = function()
        return self:render()
    end
    return true
end

--// Global functions

function setGPS(player, x, y, z)
    return Arrow:add(player, x, y, z)
end

--// Custom events

addEvent("arrow_gps:setGPS", true)
addEventHandler("arrow_gps:setGPS", root, function(x, y, z)
    return Arrow:add(source, x, y, z)
end)

--// Mta events

addEventHandler("onClientResourceStart", resourceRoot, function()
    return Arrow:constructor()
end)

addEventHandler("onClientPlayerQuit", root, function()
    return Arrow:remove(source)
end)