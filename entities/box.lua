local ent = entities.derive('base')

function ent:load(x, y)
    self:setPosition(x, y)
    self.width = 64
    self.height = 64
end

function ent:setSize(w, h)
    self.width = w
    self.height = h
end

function ent:getSize(w, h)
    return self.width, self.height;
end

function ent:update(dt)
    self.y = self.y + 32*dt
end

function ent:draw(dt)
    local x, y = self:getPosition()
    local w, h = self:getSize()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.rectangle('fill', x, y, w, h)
end

return ent;
