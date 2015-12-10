local missile = entities.derive('base')

missile.vertices = {0,16, 6,10, 6,-16, -6,-16, -6,10}

function missile:load(x, y)
    self.body = love.physics.newBody(level.world, x, y, 'dynamic')
    self.shape = love.physics.newCircleShape(8)
    self.fixture = love.physics.newFixture(self.body, self.shape, 0.5)
    self.body:setBullet(true)
    self.thrust = 50
    self.speed = 4000
    self.birth = love.timer.getTime()
    self.owner = nil
    self._exploding = false
end

function missile:setOwner(player)
    self.owner = player
end

function missile:explode()
    self._exploding = true
end

function missile:update(dt)
    if self._exploding then
        -- Explode into n bullets
        local n = 12
        local angle = 0
        local vx, vy = self.body:getLinearVelocity()
        local x, y = self.body:getX(), self.body:getY()

        for i = 0, n do
            angle = i * 2 * math.pi / n
            local bullet = entities.create('bullet', x, y)
            bullet:setOwner(self.owner)
            local fx = bullet.speed * math.cos(angle) / 100
            local fy = bullet.speed * math.sin(angle) / 100
            bullet.body:setAngle(angle - math.pi / 2)
            bullet.body:setAngularVelocity(0)
            bullet.body:setLinearVelocity(vx, vy)
            bullet.body:applyLinearImpulse(fx, fy)
        end
        entities.destroy(self.id)
    else
        local angle = self.body:getAngle() + math.pi / 2
        local fx = self.thrust * math.cos(angle)
        local fy = self.thrust * math.sin(angle)
        self.body:applyForce(fx, fy)
    end
end

function missile:draw(dt)
    love.graphics.push()
    love.graphics.setColor(255, 255, 0, 255)
    love.graphics.polygon('line', self.body:getWorldPoints(unpack(self.vertices)))
    -- love.graphics.circle('line', self.body:getX(), self.body:getY(), self.shape:getRadius())
    love.graphics.pop()
end

return missile;
