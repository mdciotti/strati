local bullet = entities.derive('base')

function bullet:load(x, y)
    self.body = love.physics.newBody(level.world, x, y, 'dynamic')
    self.shape = love.physics.newCircleShape(4)
    self.fixture = love.physics.newFixture(self.body, self.shape, 0.25)
    self.body:setFixedRotation(true)
    self.body:setBullet(true)
    self.speed = 1000
    self.birth = love.timer.getTime()
    self.owner = nil
end

function bullet:setOwner(player)
    self.owner = player
end


function bullet:update(dt)
end

function bullet:draw(dt)
    love.graphics.setColor(255, 255, 0, 255)
    -- love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
    love.graphics.circle('line', self.body:getX(), self.body:getY(), self.shape:getRadius())
end

return bullet;
