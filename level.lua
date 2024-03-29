require('collisions')
require('fabric')
require('starfield')

level = {}
level.x = 0
level.y = 0
level.width = love.graphics.getWidth() * 2
level.height = love.graphics.getHeight() * 2
level.color = { 255, 20, 20 }
level.world = love.physics.newWorld(0, 0, level.width, level.height, 0, 0, true)
level.world:setCallbacks(collisions.beginContact, collisions.endContact, collisions.preSolve, collisions.postSolve)
level.world:setContactFilter(collisions.contactFilter)
level.camera = require('camera')
level.player = nil
level.spawners = {}
level.warpGrid = nil
level.starfield = nil
local spawn_id = 0

function level:load()
    self.initialTime = love.timer.getTime()
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

    -- Create background warp grid
    self.warpGrid = Fabric.new(self.width, self.height, 40, 30)

    -- Create background star field
    -- self.starfield = StarField.new(1.5 * self.width, 1.5 * self.height, 50, 1000)
    local x, y = -0.25 * self.width, -0.25 * self.height
    local z = 50
    local w, h = 1.5 * self.width, 1.5 * self.height
    local depth = 50
    self.starfield = StarField.new(x, y, z, w, h, depth, 1000)

    -- Create spawners
    spawn_id = spawn_id + 1
    self.spawners[spawn_id] = {
        type = 'box', -- the type of entity to spawn
        x = 50, -- the x position of the spawn
        y = 50, -- the y position of the spawn
        interval = 1, -- the time in seconds between successive entity spawns
        count = 0, -- the number of entities that have spawned
        maxCount = 10, -- the maximum number of entities that will spawn
        lastSpawned = self.initialTime -- the time at which the last entity was spawned
    }

    spawn_id = spawn_id + 1
    self.spawners[spawn_id] = {
        type = 'evader',
        x = level.width - 50,
        y = 50,
        interval = 1,
        count = 0,
        maxCount = 10,
        lastSpawned = self.initialTime + 5
    }

    -- Create player
    self.player = entities.create('player', self.width / 2+1, self.height / 2+1)
    self.camera:follow(self.player)
    -- self.player:respawn()
end

function level:update(dt)
    self.world:update(dt)
    self.camera:update(dt)
    self.warpGrid:update(dt)
    local now = love.timer.getTime()

    -- Spawn enemies
    for i, spawn in pairs(self.spawners) do
        if now - spawn.lastSpawned > spawn.interval then
            -- Spawn an entity
            spawn.lastSpawned = now
            local enemy = entities.create(spawn.type, spawn.x, spawn.y)
            enemy:setTarget(self.player)

            -- Remove spawner when it has spawned more than maxCount
            spawn.count = spawn.count + 1
            if spawn.count >= spawn.maxCount then
                table.remove(self.spawners, i)
            end
        end
    end
end

function level:draw(dt)
    love.graphics.push()
    self.starfield:draw()
    self.warpGrid:draw()
    -- Set draw style
    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(4)
    love.graphics.setColor({ 240, 240, 240 })
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    love.graphics.pop()
end
