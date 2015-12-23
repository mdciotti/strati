local bullet = entities.derive('base')

bullet.vertices = {0,8, 3,5, 3,-8, -3,-8, -3,5}

function bullet:load(x, y)
    self.body = love.physics.newBody(level.world, x, y, 'dynamic')
    self.shape = love.physics.newCircleShape(4)
    self.fixture = love.physics.newFixture(self.body, self.shape, 0.25)
    self.body:setBullet(true)
    self.speed = 2000
    self.birth = love.timer.getTime()
    self.owner = nil
end

function bullet:setOwner(player)
    self.owner = player
end


function bullet:update(dt)
end

function bullet:draw(dt)
    love.graphics.push()
    love.graphics.setColor(255, 255, 0, 255)
    love.graphics.polygon('line', self.body:getWorldPoints(unpack(self.vertices)))
    -- love.graphics.circle('line', self.body:getX(), self.body:getY(), self.shape:getRadius())
    love.graphics.pop()
end

return bullet;
