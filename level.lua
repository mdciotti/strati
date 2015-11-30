level = {}
level.x = 0
level.y = 0
level.width = love.graphics.getWidth() * 2
level.height = love.graphics.getHeight() * 2
level.color = { 255, 20, 20 }
level.world = love.physics.newWorld(0, 0, level.width, level.height, 0, 0, true)

function level:draw(dt)
    love.graphics.push()
    -- Set draw style
    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(4)
    love.graphics.setColor({ 240, 240, 240 })
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    love.graphics.pop()
end
