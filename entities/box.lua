local box = entities.derive('base')

function box:load(x, y)
    self.body = love.physics.newBody(level.world, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 'dynamic')
    self.shape = love.physics.newRectangleShape(32, 32)
    self.fixture = love.physics.newFixture(self.body, self.shape, 0.25)
    self.fixture:setRestitution(0.1)
    self.body:setFixedRotation(false)
end

function box:update(dt)
end

function box:draw(dt)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
end

return box;
