StarField = {}
StarField.__index = StarField

function StarField.new(x, y, z, w, h, d, numStars)
    local self = {}
    setmetatable(self, StarField)

    self.x = x
    self.y = y
    self.z = z
    self.width = w
    self.height = h
    self.depth = d
    self.numStars = numStars
    self.stars_x = {}
    self.stars_y = {}
    self.stars_z = {}
    self.stars_r = {}
    self.maxRadius = 5
    self.minRadius = 1
    local r = self.maxRadius - self.minRadius

    for i = 1, numStars do
        self.stars_x[i] = love.math.random() * w + x
        self.stars_y[i] = love.math.random() * h + y
        self.stars_z[i] = love.math.random() * d + z
        self.stars_r[i] = love.math.random() * r + self.minRadius
    end

    return self
end

function StarField:draw()
    love.graphics.push()
    love.graphics.translate(-0.25 * level.width, -0.25 * level.height)
    love.graphics.setColor(255, 255, 255)

    for i = 1, self.numStars do
        local x = self.stars_x[i]
        local y = self.stars_y[i]
        local z = self.stars_z[i]
        local r = self.stars_r[i]

        local camera_x = level.camera.body:getX()
        local camera_y = level.camera.body:getY()
        local screen_x = x + camera_x * z / (self.depth + self.z)
        local screen_y = y + camera_y * z / (self.depth + self.z)

        local c = math.log(self.maxRadius) / self.depth
        love.graphics.setPointSize(r * math.exp(-c * (z - self.z)))
        love.graphics.point(screen_x, screen_y)
    end

    love.graphics.pop()
end
