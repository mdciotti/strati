local box = entities.derive('base')

box.vertices = {0,0, 0,16, 16,16, 0,0, 16,0, 16,-16, 0,0, 0,-16, -16,-16, 0,0, -16,0, -16,16}

function box:load(x, y)
    self.body = love.physics.newBody(level.world, x, y, 'dynamic')
    self.shape = love.physics.newRectangleShape(32, 32)
    self.fixture = love.physics.newFixture(self.body, self.shape, 0.25)
    self.fixture:setRestitution(0.1)
    self.body:setFixedRotation(false)
    self.body:setLinearDamping(3.5)
    self.speed = 100
    self.birth = love.timer.getTime()
    self.health = 5
end

function box:hit(damage)
    self.health = self.health - damage
end

function box:setTarget(player)
    self.target = player
end

function box:move(dx, dy)
    local d = math.sqrt(dx * dx + dy * dy)
    self.body:applyForce(self.speed * dx / d, self.speed * dy / d)
end

function box:update(dt)
    if self.health <= 0 then
        entities.destroy(self.id)
    end

    -- Follow player
    if self.target ~= nil then
        local dx = self.target.body:getX() - self.body:getX()
        local dy = self.target.body:getY() - self.body:getY()
        self:move(dx, dy)
    else
        -- Wander?
    end

    -- Spin
    local t = love.timer.getTime()
    self.body:setAngularVelocity(5 * math.cos(t - self.birth))
end

function box:draw(dt)
    love.graphics.push()
    love.graphics.setColor(255, 0, 255, 196)
    love.graphics.polygon('line', self.body:getWorldPoints(unpack(self.vertices)))
    love.graphics.pop()
end

return box;
