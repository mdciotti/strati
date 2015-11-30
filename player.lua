player = {}
player.x = 0
player.y = 0
player.hwidth = 15
player.hheight = 20
player.speed = 300
player.color = { 240, 240, 240 }
player.rotation = 0
player.turn_speed = 3
-- player.vertices = {0, 10, -8, -10, 0, 0, 8, -10}
player.vertices = {0, 10, -8, -10, 8, -10}
-- player.body = love.physics.newBody(level.world, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
-- player.body:setMassData(0, 0, 10, 10)
-- player.body:setType('dynamic')

function player:move(dist)
    self.x = self.x + math.sin(self.rotation) * dist
    self.y = self.y - math.cos(self.rotation) * dist
    -- ix = math.sin(self.rotation) * dist
    -- iy = -math.cos(self.rotation) * dist
    -- self.body:applyForce(ix, iy)
end

function player:turn(amount)
    self.rotation = self.rotation + amount
end

function player:update(dt)
    dx = (love.mouse.getX() + camera._x) - self.x
    dy = (love.mouse.getY() + camera._y) - self.y
    -- dx = (love.mouse.getX() + camera._x) - self.body:getX()
    -- dy = (love.mouse.getY() + camera._y) - self.body:getY()
    self.rotation = math.atan2(dy, dx) + math.pi / 2

    if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
        self:move(self.speed * dt)
    elseif love.keyboard.isDown('down') or love.keyboard.isDown('s') then
        self:move(-self.speed * dt)
    end

    -- if love.keyboard.isDown('left') then
    --     self:turn(-self.turn_speed * dt)
    -- elseif love.keyboard.isDown('right') then
    --     self:turn(self.turn_speed * dt)
    -- end
end

function player:draw(dt)
    love.graphics.push()
    -- Rotate the player
    -- love.graphics.translate(self.body:getX(), self.body:getY())
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.rotation)
    -- love.graphics.translate(-self.body:getX(), -self.body:getY())
    love.graphics.translate(-self.x, -self.y)
    -- Set draw style
    love.graphics.setColor(self.color)
    -- Draw
    -- love.graphics.rectangle('line', self.body:getX() - self.hwidth, self.body:getY() - self.hheight, self.hwidth * 2, self.hheight * 2)
    love.graphics.rectangle('line', self.x - self.hwidth, self.y - self.hheight, self.hwidth * 2, self.hheight * 2)
    -- love.graphics.polygon('line', self.vertices)
    love.graphics.pop()
end
