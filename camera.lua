local camera2 = {}
camera2.scaleX = 1
camera2.scaleY = 1
camera2.rotation = 0
camera2.following = nil
local centerX = love.graphics.getWidth() / 2
local centerY = love.graphics.getHeight() / 2
camera2.body = love.physics.newBody(level.world, centerX, centerY, 'dynamic')
-- camera2.body:setMassData(0, 0, 10, 10)
camera2.body:setLinearDamping(10)
camera2.body:setFixedRotation(true)
camera2.springConstant = 100

function camera2:load()
end

function camera2:set()
    love.graphics.push()
    love.graphics.rotate(-self.rotation)
    love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
    love.graphics.translate(-self.body:getX(), -self.body:getY())
end

function camera2:unset()
    love.graphics.pop()
end

function camera2:follow(entity)
    self.following = entity
    self.body:setX(math.floor(self.following.body:getX()))
    self.body:setY(math.floor(self.following.body:getY()))
    self.body:setLinearVelocity(0, 0)
end

function camera2:unfollow()
    self.following = nil
end

function camera2:update(dt)
    if self.following then
        -- Apply spring force
        local dx = self.following.body:getX() - self.body:getX() - centerX
        local dy = self.following.body:getY() - self.body:getY() - centerY
        -- Fx = -k * dx
        self.body:applyForce(self.springConstant * dx, self.springConstant * dy)
    end
end

function camera2:rotate(dr)
    self.rotation = self.rotation + dr
end

function camera2:scale(sx, sy)
    sx = sx or 1
    self.scaleX = self.scaleX * sx
    self.scaleY = self.scaleY * (sy or sx)
end

function camera2:setScale(sx, sy)
    self.scaleX = sx or self.scaleX
    self.scaleY = sy or self.scaleY
end

return camera2;
