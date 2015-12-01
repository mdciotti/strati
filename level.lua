level = {}
level.x = 0
level.y = 0
level.width = love.graphics.getWidth() * 2
level.height = love.graphics.getHeight() * 2
level.color = { 255, 20, 20 }
level.world = love.physics.newWorld(0, 0, level.width, level.height, 0, 0, true)
level.camera = require('camera')

function level:load()
    self.camera:load()

    love.physics.setMeter(32)

    -- Top wall
    self.wall_top = {}
    self.wall_top.body = love.physics.newBody(self.world, self.width / 2, -10)
    self.wall_top.shape = love.physics.newRectangleShape(self.width, 20)
    self.wall_top.fixture = love.physics.newFixture(self.wall_top.body, self.wall_top.shape)

    -- Right wall
    self.wall_right = {}
    self.wall_right.body = love.physics.newBody(self.world, self.width + 10, self.height / 2)
    self.wall_right.shape = love.physics.newRectangleShape(20, self.height)
    self.wall_right.fixture = love.physics.newFixture(self.wall_right.body, self.wall_right.shape)

    -- Bottom wall
    self.wall_bottom = {}
    self.wall_bottom.body = love.physics.newBody(self.world, self.width / 2, self.height + 10)
    self.wall_bottom.shape = love.physics.newRectangleShape(self.width, 20)
    self.wall_bottom.fixture = love.physics.newFixture(self.wall_bottom.body, self.wall_bottom.shape)

    -- Left wall
    self.wall_left = {}
    self.wall_left.body = love.physics.newBody(self.world, -10, self.height / 2)
    self.wall_left.shape = love.physics.newRectangleShape(20, self.height)
    self.wall_left.fixture = love.physics.newFixture(self.wall_left.body, self.wall_left.shape)
end

function level:update(dt)
    self.world:update(dt)
    self.camera:update(dt)
end

function level:draw(dt)
    love.graphics.push()
    -- Set draw style
    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(4)
    love.graphics.setColor({ 240, 240, 240 })
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    love.graphics.pop()
end
