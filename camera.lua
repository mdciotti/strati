require('pid-controller')

local camera2 = {}
camera2._scaleX = 0.5
camera2._scaleY = 0.5
camera2.zoomFactor = 0.666
camera2.rotation = 0
camera2.following = nil
local centerX = love.graphics.getWidth() / 2
local centerY = love.graphics.getHeight() / 2
camera2.body = love.physics.newBody(level.world, level.width / 2, level.height / 2, 'dynamic')
-- camera2.body:setMassData(0, 0, 10, 10)
camera2.body:setLinearDamping(7.5)
camera2.body:setFixedRotation(true)
camera2.springConstant = 25
-- camera2.pid_x = PID.new(5, 0, 3)
-- camera2.pid_y = PID.new(5, 0, 3)

function camera2:load()
end

function camera2:set()
    love.graphics.push()
    -- Move origin to center of screen
    love.graphics.translate(centerX, centerY)
    -- Rotate
    love.graphics.rotate(-self.rotation)
    -- Scale
    love.graphics.scale(self._scaleX, self._scaleY)
    -- Move origin to camera location
    love.graphics.translate(-self.body:getX(), -self.body:getY())
end

function camera2:unset()
    love.graphics.pop()
end

function camera2:follow(entity)
    self.following = entity
end

function camera2:unfollow()
    self.following = nil
end

function camera2:update(dt)
    -- Simplified PID controller: no I or D term
    -- Zoom is the target value
    self._scaleX = self._scaleX + 0.1 * (self.zoomFactor - self._scaleX)
    self._scaleY = self._scaleY + 0.1 * (self.zoomFactor - self._scaleY)

    if self.following then
        -- PID Controller
        -- local fx = self.pid_x:update(self.following.body:getX(), self.body:getX(), dt)
        -- local fy = self.pid_y:update(self.following.body:getY(), self.body:getY(), dt)
        -- self.body:applyForce(fx, fy)

        -- Apply spring force
        local tx = 0.5 * (self.following.body:getX() + 0.5 * level.width)
        local ty = 0.5 * (self.following.body:getY() + 0.5 * level.height)
        local dx = tx - self.body:getX()
        local dy = ty - self.body:getY()
        -- Fx = -k * dx
        self.body:applyForce(self.springConstant * dx, self.springConstant * dy)
    end
end

function camera2:rotate(dr)
    self.rotation = self.rotation + dr
end

-- Smoothly scales between the old zoom and the new
function camera2:zoom(factor)
    self.zoomFactor = self.zoomFactor * factor
end

return camera2;
