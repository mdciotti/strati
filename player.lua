player = {}
player.x = 0
player.y = 0
player.hitRadius = 16
player.speed = 300
player.color = { 240, 240, 240 }
player.vertices = {16,8, -3,8, -7,4, -7,4, -3,-8, 16,-8, 8,-16, -7,-16, -16,-7, -16,7, -7,16, 8,16}
player.body = love.physics.newBody(level.world, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 'dynamic')
player.shape = love.physics.newCircleShape(player.hitRadius)
player.fixture = love.physics.newFixture(player.body, player.shape, 0.25)
player.fixture:setRestitution(0.1)
player.fixture:setUserData('player')
player.body:setFixedRotation(false)
player.body:setLinearDamping(2.5)
player.controller = nil

player.canFire = true
player.lastFired = 0

local weapon = {}
weapon.spread = 10 -- degrees
weapon.shotsPerSecond = 10 -- shots per second
weapon.bulletsPerShot = 1
-- weapon.damagePerBullet = 1
-- weapon.damagePerSecond = weapon.damagePerBullet * weapon.bulletsPerShot * weapon.shotsPerSecond

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

function player:fire()
    local dt = love.timer.getTime() - player.lastFired
    if dt * weapon.shotsPerSecond < 1 or not player.canFire then
        return
    end

    local theta = self.body:getAngle()

    -- Set bullet start position slightly in front of player
    local x = 1.25 * player.hitRadius * math.cos(theta) + self.body:getX()
    local y = 1.25 * player.hitRadius * math.sin(theta) + self.body:getY()
    local spread = math.rad(weapon.spread)
    local vx, vy = self.body:getLinearVelocity()

    if weapon.bulletsPerShot == 1 then
        -- Add variance to the direction, within (-spread/2, +spread/2) degrees
        local angle = theta - spread / 2 + spread * math.random()
        local bullet = entities.create('bullet', x, y)
        local fx = bullet.speed * math.cos(angle) / 100
        local fy = bullet.speed * math.sin(angle) / 100
        bullet.body:setLinearVelocity(vx, vy)
        bullet.body:applyLinearImpulse(fx, fy)
        self.body:applyLinearImpulse(-fx, -fy)
    else
        -- Fire n+1 bullets
        local n = weapon.bulletsPerShot - 1
        for i = 0, n do
            local bullet = entities.create('bullet', x, y)
            local angle = theta - spread / 2 + i * spread / n

            local fx = bullet.speed * math.cos(angle) / 100
            local fy = bullet.speed * math.sin(angle) / 100
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

function player:update(dt)
    if self.controller ~= nil then
        -- getGamepadAxis returns a value between -1 and 1 (0 at rest)
        -- Movement
        local leftX = self.controller:getGamepadAxis('leftx')
        local leftY = self.controller:getGamepadAxis('lefty')
        self:move(self.speed, math.atan2(leftY, leftX) + math.pi / 2)

        -- Direction
        local rightX = self.controller:getGamepadAxis('rightx')
        local rightY = self.controller:getGamepadAxis('righty')
        self.body:setAngle(math.atan2(rightY, rightX))

        -- Fire weapon
        local trigger = self.controller:getGamepadAxis('triggerright')
        if trigger > 0.5 then
            self:fire()
        end

    else
        -- Use keyboard + mouse
        local dx = (love.mouse.getX() + level.camera.body:getX()) - self.body:getX()
        local dy = (love.mouse.getY() + level.camera.body:getY()) - self.body:getY()
        self.body:setAngle(math.atan2(dy, dx))

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
    end
end

function player:draw(dt)
    love.graphics.push()
    love.graphics.setColor(self.color)
    love.graphics.polygon('line', self.body:getWorldPoints(unpack(self.vertices)))

    -- Debug firing lines
    if debug then
        local theta = self.body:getAngle()
        local n = weapon.bulletsPerShot - 1
        local x = 1.25 * player.hitRadius * math.cos(theta) + self.body:getX()
        local y = 1.25 * player.hitRadius * math.sin(theta) + self.body:getY()
        local spread = math.rad(weapon.spread)
        love.graphics.setColor(255, 0, 0, 128)

        if weapon.bulletsPerShot == 1 then
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
