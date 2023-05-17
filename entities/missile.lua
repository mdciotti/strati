local missile = entities.derive('base')

missile.vertices = {0,16, 6,10, 6,-16, -6,-16, -6,10}

function missile:load(x, y)
    self.thrust = 50
    self.speed = 4000
    self.birth = love.timer.getTime()
    self.owner = nil
    self._exploding = false

    -- Set physical properties
    self.body = love.physics.newBody(level.world, x, y, 'dynamic')
    self.shape = love.physics.newCircleShape(8)
    self.fixture = love.physics.newFixture(self.body, self.shape, 0.5)
    self.body:setBullet(true)

    -- Set grid warp
    self.gridWarpFactor = 1000
    self.gridWarpRadius = 50
    self.gridWarpRadiusSquared = self.gridWarpRadius * self.gridWarpRadius
    level.warpGrid:register(self)

    -- Set up particle trail
    local trailParticle = love.graphics.newCanvas(10, 10)
    trailParticle:renderTo(function ()
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.circle('fill', 5, 5, 5)
    end)
    self.trail = love.graphics.newParticleSystem(trailParticle, 100)
    self.trail:setEmissionRate(100)
    self.trail:setParticleLifetime(1)
    self.trail:setRelativeRotation(true)
    self.trail:setLinearDamping(5)
    self.trail:setSpread(math.pi / 9)
    self.trail:setOffset(-8, 5)
    self.trail:setSpeed(300)
    self.trail:setSizes(1, 2, 4, 8)
    self.trail:setColors(255, 128, 0, 128, 32, 32, 32, 0)
end

function missile:setOwner(player)
    self.owner = player
end

function missile:explode()
    self._exploding = true
    level.warpGrid:deregister(self)
end

function missile:update(dt)

    -- Update trail particle system
    self.trail:setPosition(self.body:getX(), self.body:getY())
    self.trail:setDirection(self.body:getAngle() - math.pi / 2)
    self.trail:update(dt)

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
            local fx = 1.5 * bullet.speed * math.cos(angle) / 100
            local fy = 1.5 * bullet.speed * math.sin(angle) / 100
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
    love.graphics.draw(self.trail, 0, 0)
    love.graphics.setColor(255, 255, 0, 255)
    love.graphics.polygon('line', self.body:getWorldPoints(unpack(self.vertices)))
    -- love.graphics.circle('line', self.body:getX(), self.body:getY(), self.shape:getRadius())
    love.graphics.pop()
end

return missile;
