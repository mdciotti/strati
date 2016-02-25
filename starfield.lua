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
    self.stars = {}
    self.maxRadius = 5
    self.minRadius = 1
    local r = self.maxRadius - self.minRadius

    for i = 1, numStars do
        self.stars[i] = {}
        self.stars[i].x = love.math.random() * w + x
        self.stars[i].y = love.math.random() * h + y
        self.stars[i].z = love.math.random() * d + z
        self.stars[i].r = love.math.random() * r + self.minRadius
    end

    return self
end

function StarField:draw()
    love.graphics.push()
    love.graphics.translate(-0.25 * level.width, -0.25 * level.height)
    love.graphics.setColor(255, 255, 255)

    local camera_x = level.camera.body:getX()
    local camera_y = level.camera.body:getY()
    local c = math.log(self.maxRadius) / self.depth

    for i, star in ipairs(self.stars) do
        local screen_x = star.x + camera_x * star.z / (self.depth + self.z)
        local screen_y = star.y + camera_y * star.z / (self.depth + self.z)

        love.graphics.setPointSize(star.r * math.exp(-c * (star.z - self.z)))
        love.graphics.point(screen_x, screen_y)
    end

    love.graphics.pop()
end
