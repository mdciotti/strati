local playerTrail = {}

-- Create line sprite
local trailParticle = love.graphics.newCanvas(32, 32)
trailParticle:renderTo(function ()
    love.graphics.setLineWidth(3)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.line(0, 16, 32, 16)
end)
-- TODO: pre-blur line sprite for glow effect

local trail = love.graphics.newParticleSystem(trailParticle, 100)
trail:setEmissionRate(50)
trail:setParticleLifetime(1)
trail:setRelativeRotation(true)
-- trail:setSpread(math.pi / 9)
trail:setSpread(0.001)
trail:setOffset(-1.25 * self.hitRadius, 16)
trail:setSpeed(0.5 * self.speed)
trail:setSizes(1, 1, 0)
trail:setColors(255, 255, 255, 128, 255, 255, 255, 0)

function playerTrail:update()
    trail:update()
end

function playerTrail:draw()
    trail:draw()
end

return playerTrail
