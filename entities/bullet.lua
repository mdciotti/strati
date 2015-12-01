local bullet = entities.derive('base')

function bullet:load(x, y)
    self.body = love.physics.newBody(level.world, x, y, 'dynamic')
    self.shape = love.physics.newCircleShape(4)
    self.fixture = love.physics.newFixture(self.body, self.shape, 0.25)
    self.body:setFixedRotation(true)
    self.body:setBullet(true)
    self.speed = 500
end

function bullet:setDirection(angle)
    local vx = self.speed * math.cos(angle)
    local vy = self.speed * math.sin(angle)
    self.body:setLinearVelocity(vx, vy)
end


function bullet:update(dt)
end

function bullet:draw(dt)
    love.graphics.setColor(255, 255, 0, 255)
    -- love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
    love.graphics.circle('line', self.body:getX(), self.body:getY(), self.shape:getRadius())
end

return bullet;
