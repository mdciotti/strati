require('collisions')

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
level.respawningPlayer = false
level.respawnPlayerAt = nil
level.spawners = {}
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

    -- Create player
    self:respawnPlayer(0)
end

-- Respawns a player after `delay` seconds
function level:respawnPlayer(delay)
    self.respawningPlayer = true
    self.respawnPlayerAt = love.timer.getTime() + delay
end

function level:update(dt)
    self.world:update(dt)
    self.camera:update(dt)
    local now = love.timer.getTime()

    -- Respawn player if needed
    if self.respawningPlayer and now >= self.respawnPlayerAt then
        self.player = entities.create('player', self.width / 2, self.height / 2)
        self.camera:follow(self.player)
        self.respawningPlayer = false
    end

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
    -- Set draw style
    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(4)
    love.graphics.setColor({ 240, 240, 240 })
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    love.graphics.pop()
end
