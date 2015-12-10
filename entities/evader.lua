local box = entities.derive('base')

box.vertices = {0,16, 16,16, 16,-16, -16,-16, -16,16, 0,16, 16,0, 0,-16, -16,0}

function box:load(x, y)
    self.body = love.physics.newBody(level.world, x, y, 'dynamic')
    self.shape = love.physics.newRectangleShape(32, 32)
    self.fixture = love.physics.newFixture(self.body, self.shape, 0.25)
    self.fixture:setRestitution(0.1)
    self.body:setFixedRotation(false)
    self.body:setLinearDamping(2.5)
    self.speed = 300
    self.birth = love.timer.getTime()
    self.health = 5
    self.pid_x = PID.new(0.5, 0, 0.1)
    self.pid_y = PID.new(0.5, 0, 0.1)
    self.type = 'enemy'
end

function box:hit(damage)
    self.health = self.health - damage
end

-- Destroys the entity on the next update
function box:kill()
    self.health = 0
end

function box:setTarget(player)
    self.target = player
end

function box:update(dt)
    if self.health <= 0 then
        entities.destroy(self.id)
    end

    -- Follow player
    if self.target ~= nil then
        local fx = self.pid_x:update(self.target.body:getX(), self.body:getX(), dt)
        local fy = self.pid_y:update(self.target.body:getY(), self.body:getY(), dt)
        self.body:applyForce(fx, fy)
    else
        -- Wander?
    end

    -- Spin
    local t = love.timer.getTime()
    self.body:setAngularVelocity(5 * math.cos(t - self.birth))
end

function box:draw(dt)
    love.graphics.push()
    love.graphics.setLineWidth(2)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.polygon('line', self.body:getWorldPoints(unpack(self.vertices)))
    love.graphics.pop()
end

return box;
