player = {}
player.x = 0
player.y = 0
player.hwidth = 15
player.hheight = 20
player.speed = 300
player.color = { 240, 240, 240 }
player.vertices = {16,8, -3,8, -7,4, -7,4, -3,-8, 16,-8, 8,-16, -7,-16, -16,-7, -16,7, -7,16, 8,16}
player.body = love.physics.newBody(level.world, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, 'dynamic')
player.shape = love.physics.newCircleShape(16)
player.fixture = love.physics.newFixture(player.body, player.shape, 0.25)
player.fixture:setRestitution(0.1)
player.body:setFixedRotation(false)
player.body:setLinearDamping(2.5)

function player:move(dist)
    local theta = self.body:getAngle() + math.pi / 2
    local ix = math.sin(theta) * dist
    local iy = -math.cos(theta) * dist
    self.body:applyForce(ix, iy)
end

function player:update(dt)
    local dx = (love.mouse.getX() + level.camera.body:getX()) - self.body:getX()
    local dy = (love.mouse.getY() + level.camera.body:getY()) - self.body:getY()
    self.body:setAngle(math.atan2(dy, dx))

    if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
        self:move(self.speed)
    elseif love.keyboard.isDown('down') or love.keyboard.isDown('s') then
        self:move(-self.speed)
    end
end

function player:draw(dt)
    love.graphics.push()
    love.graphics.setColor(self.color)
    love.graphics.polygon('line', self.body:getWorldPoints(unpack(self.vertices)))
    -- love.graphics.circle('line', self.body:getX(), self.body:getY(), self.shape:getRadius())
    love.graphics.pop()
end
