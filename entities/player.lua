local player = entities.derive('base')

player.hitRadius = 16
player.speed = 600
player.color = { 240, 240, 240 }
player.vertices = {16,8, 8,16, -7,16, -16,7, -16,-7, -7,-16, 8,-16, 16,-8, -3,-8, -7,-4, -7,4, -3,8}
player.controller = nil
player.type = 'player'

player.canFire = true
player.lastFired = 0
player.lastFiredMissile = 0

player.weapon = {}
player.weapon.spread = 10 -- degrees
player.weapon.shotsPerSecond = 10
player.weapon.bulletsPerShot = 1
player.weapon.damagePerBullet = 5
-- player.weapon.damagePerSecond = player.weapon.damagePerBullet * player.weapon.bulletsPerShot * player.weapon.shotsPerSecond

function player:load(x, y)
    self.spawnPoint = {x, y}
    self.respawnAt = 0
    self.alive = false
    self.birth = love.timer.getTime()
    self.body = love.physics.newBody(level.world, x, y, 'dynamic')
    self.shape = love.physics.newCircleShape(self.hitRadius)
    self.fixture = love.physics.newFixture(self.body, self.shape, 0.25)
    self.fixture:setRestitution(0.1)
    self.fixture:setUserData('player')
    self.body:setFixedRotation(false)
    self.body:setLinearDamping(5)
    self.gridWarpFactor = 500
    self.gridWarpRadius = 50
    self.gridWarpRadiusSquared = self.gridWarpRadius * self.gridWarpRadius

    -- Set up particle trail
    local trailParticle = love.graphics.newCanvas(32, 32)
    trailParticle:renderTo(function ()
        love.graphics.setLineWidth(3)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.line(0, 16, 32, 16)
    end)
    self.trail = love.graphics.newParticleSystem(trailParticle, 100)
    self.trail:setEmissionRate(50)
    self.trail:setParticleLifetime(1)
    self.trail:setRelativeRotation(true)
    -- self.trail:setSpread(math.pi / 9)
    self.trail:setSpread(0.001)
    self.trail:setOffset(-1.25 * self.hitRadius, 16)
    self.trail:setSpeed(0.5 * self.speed)
    self.trail:setSizes(1, 1, 0)
    self.trail:setColors(255, 255, 255, 128, 255, 255, 255, 0)
end

function player:die()
    if self.alive then
        self.alive = false
        -- Respawn after three seconds
        self.respawnAt = love.timer.getTime() + 3
        -- self.spawnPoint = {self.body:getX(), self.body:getY()}
        self.trail:pause()
    end
end

function player:respawn()
    self.birth = love.timer.getTime()
    self.body:setX(self.spawnPoint[1])
    self.body:setY(self.spawnPoint[2])
    self.body:setLinearVelocity(0, 0)
    self.body:setAngle(0)
    self.body:setAngularVelocity(0)
    self.trail:start()
end

function player:move(dist, angle)
    if dist > 0 then
        -- Angle is relative to player's forward direction
        -- Left is positive
        -- local theta = self.body:getAngle() + math.pi / 2 + angle
        local theta = angle
        local ix = math.sin(theta) * dist
        local iy = -math.cos(theta) * dist
        self.body:applyForce(ix, iy)
    end
end

function player:fireMissile()
    local dt = love.timer.getTime() - player.lastFiredMissile
    if dt < 1 or not player.canFire then
        return
    end

    -- Set missile start position slightly in front of player
    local theta = self.body:getAngle()
    local x = 1.25 * player.hitRadius * math.cos(theta) + self.body:getX()
    local y = 1.25 * player.hitRadius * math.sin(theta) + self.body:getY()
    local spread = math.rad(player.weapon.spread)
    local vx, vy = self.body:getLinearVelocity()

    local missile = entities.create('missile', x, y)
    missile:setOwner(self)
    level.warpGrid:register(missile)
    missile.body:setAngle(theta - math.pi / 2)
    missile.body:setAngularVelocity(0)
    missile.body:setLinearVelocity(vx, vy)
    local fx = missile.speed * math.cos(theta) / 100
    local fy = missile.speed * math.sin(theta) / 100
    missile.body:applyLinearImpulse(fx, fy)
    self.body:applyLinearImpulse(-fx, -fy)

    self.lastFiredMissile = love.timer.getTime()
end

function player:fire()
    local dt = love.timer.getTime() - player.lastFired
    if dt * player.weapon.shotsPerSecond < 1 or not player.canFire then
        return
    end

    local theta = self.body:getAngle()

    -- Set bullet start position slightly in front of player
    local x = 1.25 * player.hitRadius * math.cos(theta) + self.body:getX()
    local y = 1.25 * player.hitRadius * math.sin(theta) + self.body:getY()
    local spread = math.rad(player.weapon.spread)
    local vx, vy = self.body:getLinearVelocity()

    if player.weapon.bulletsPerShot == 1 then
        -- Add variance to the direction, within (-spread/2, +spread/2) degrees
        local angle = theta - spread / 2 + spread * math.random()
        local bullet = entities.create('bullet', x, y)
        bullet:setOwner(self)
        bullet.body:setAngle(angle - math.pi / 2)
        bullet.body:setAngularVelocity(0)
        bullet.body:setLinearVelocity(vx, vy)
        local fx = bullet.speed * math.cos(angle) / 100
        local fy = bullet.speed * math.sin(angle) / 100
        bullet.body:applyLinearImpulse(fx, fy)
        self.body:applyLinearImpulse(-fx, -fy)
    else
        -- Fire n+1 bullets
        local n = player.weapon.bulletsPerShot - 1
        for i = 0, n do
            local angle = theta - spread / 2 + i * spread / n
            local bullet = entities.create('bullet', x, y)
            bullet:setOwner(self)
            local fx = bullet.speed * math.cos(angle) / 100
            local fy = bullet.speed * math.sin(angle) / 100
            bullet.body:setAngle(angle - math.pi / 2)
            bullet.body:setAngularVelocity(0)
            bullet.body:setLinearVelocity(vx, vy)
            bullet.body:applyLinearImpulse(fx, fy)
            self.body:applyLinearImpulse(-fx, -fy)
        end
    end

    self.lastFired = love.timer.getTime()
end

function player:registerController(joystick)
    if not self.controller or not self.controller:isConnected() then
        self.controller = joystick
    end
end

local flipflop = false

function player:update(dt)
    local now = love.timer.getTime()
    flipflop = not flipflop

    -- Update trail particle system
    self.trail:setPosition(self.body:getX(), self.body:getY())
    local vx, vy = self.body:getLinearVelocity()
    local vel_angle = math.atan2(vy, vx)
    self.body:setAngle(vel_angle)
    self.body:setAngularVelocity(0)


    local offset = (math.pi / 16) * math.cos(8 * now)
    if flipflop then
        offset = -offset
    end

    self.trail:setDirection(vel_angle + math.pi + offset)
    -- if self.trail:isPaused() and math.sqrt(vx * vx + vy * vy) >= 100 then
    --     -- self.trail:setEmissionRate(50)
    --     self.trail:start()
    -- else
    --     -- self.trail:setEmissionRate(0)
    --     self.trail:pause()
    -- end
    self.trail:update(dt)

    -- Respawn player if needed
    if not self.alive and now >= self.respawnAt then
        self:respawn()
        self.alive = true
        player.lastFired = 0
        player.lastFiredMissile = 0
    end

    -- Don't let player move or fire when dead
    if not player.alive then
        return
    end

    if self.controller ~= nil then
        -- getGamepadAxis returns a value between -1 and 1 (0 at rest)
        -- Movement
        local leftX = self.controller:getGamepadAxis('leftx')
        local leftY = self.controller:getGamepadAxis('lefty')
        local leftMagnitude = math.min(math.sqrt(leftX * leftX + leftY * leftY), 1)

        if leftMagnitude > 0.1 then -- Account for deadzone
            self:move(leftMagnitude * self.speed, math.atan2(leftY, leftX) + math.pi / 2)
        end

        -- Direction
        local rightX = self.controller:getGamepadAxis('rightx')
        local rightY = self.controller:getGamepadAxis('righty')
        local rightMagnitude = math.sqrt(rightX * rightX + rightY * rightY)

        if rightMagnitude > 0.25 then
            self.body:setAngle(math.atan2(rightY, rightX))
        end
        self.body:setAngularVelocity(0)

        local rightTrigger = self.controller:getGamepadAxis('triggerright')
        local leftTrigger = self.controller:getGamepadAxis('triggerleft')

        -- Fire weapon
        if rightTrigger > 0.5 then
            self:fire()
        end
        if leftTrigger > 0.5 then
            self:fireMissile()
        end

    else
        -- Use keyboard + mouse
        local mx = level.camera.body:getX() + (-love.graphics.getWidth() / 2 + love.mouse.getX()) / level.camera._scaleX
        local my = level.camera.body:getY() + (-love.graphics.getHeight() / 2 + love.mouse.getY()) / level.camera._scaleY
        local dx = mx - self.body:getX()
        local dy = my - self.body:getY()
        self.body:setAngle(math.atan2(dy, dx))
        self.body:setAngularVelocity(0)

        local dist = 0
        local dirX = 0
        local dirY = 0

        local up = love.keyboard.isDown('up') or love.keyboard.isDown('w')
        local left = love.keyboard.isDown('left') or love.keyboard.isDown('a')
        local down = love.keyboard.isDown('down') or love.keyboard.isDown('s')
        local right = love.keyboard.isDown('right') or love.keyboard.isDown('d')

        if up and right then
            self:move(self.speed, math.pi / 4)
        elseif up and left then
            self:move(self.speed, -math.pi / 4)
        elseif down and left then
            self:move(self.speed, -3 * math.pi / 4)
        elseif down and right then
            self:move(self.speed, 3 * math.pi / 4)
        elseif up then
            self:move(self.speed, 0)
        elseif down then
            self:move(self.speed, math.pi)
        elseif left then
            self:move(self.speed, -math.pi / 2)
        elseif right then
            self:move(self.speed, math.pi / 2)
        end

        if love.mouse.isDown('l') then
            self:fire()
        end
        if love.mouse.isDown('r') then
            self:fireMissile()
        end
    end
end

function player:draw(dt)
    love.graphics.push()

    if self.alive then
        love.graphics.setColor(self.color)
    else
        love.graphics.setColor(240, 15, 15)
    end
    -- Draw particle trail
    love.graphics.draw(self.trail, 0, 0)
    love.graphics.polygon('line', self.body:getWorldPoints(unpack(self.vertices)))

    -- Debug firing lines
    if debugMode then
        local theta = self.body:getAngle()
        local n = player.weapon.bulletsPerShot - 1
        local x = 1.25 * player.hitRadius * math.cos(theta) + self.body:getX()
        local y = 1.25 * player.hitRadius * math.sin(theta) + self.body:getY()
        local spread = math.rad(player.weapon.spread)
        love.graphics.setColor(255, 0, 0, 128)

        if player.weapon.bulletsPerShot == 1 then
            local fx = 100 * math.cos(theta)
            local fy = 100 * math.sin(theta)
            love.graphics.line(x, y, x + fx, y + fy)

            fx = 100 * math.cos(theta - spread / 2)
            fy = 100 * math.sin(theta - spread / 2)
            love.graphics.line(x, y, x + fx, y + fy)

            fx = 100 * math.cos(theta + spread / 2)
            fy = 100 * math.sin(theta + spread / 2)
            love.graphics.line(x, y, x + fx, y + fy)

        else
            for i = 0, n do
                local angle = theta - spread / 2 + i * spread / n
                local fx = 100 * math.cos(angle)
                local fy = 100 * math.sin(angle)
                love.graphics.line(x, y, x + fx, y + fy)
            end
        end
    end

    -- love.graphics.circle('line', self.body:getX(), self.body:getY(), self.shape:getRadius())
    love.graphics.pop()
end

return player;
