local box = entities.derive('base')

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

function box:move(dx, dy)
    local d = math.sqrt(dx * dx + dy * dy)
    self.body:applyForce(self.speed * dx / d, self.speed * dy / d)
end

function box:update(dt)
    if self.health <= 0 then
        entities.destroy(self.id)
    end

    -- Follow player
    local dx = player.body:getX() - self.body:getX()
    local dy = player.body:getY() - self.body:getY()
    self:move(dx, dy)

    -- Spin
    local t = love.timer.getTime()
    self.body:setAngularVelocity(5 * math.cos(t - self.birth))
end

function box:draw(dt)
    love.graphics.setColor(255, 0, 255, 255)
    love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
end

return box;
