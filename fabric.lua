require('ndarray')
inspect = require('inspect')

Fabric = {}
Fabric.__index = Fabric

function Fabric.new(w, h, cols, rows)
    local self = {}
    setmetatable(self, Fabric)

    self.width = w
    self.height = h
    self.cols = cols
    self.rows = rows
    self.manipulators = {}
    self.nodes = ndarray.new(cols + 1, rows + 1)
    self.springConstant = 2.5
    self.damping = 0.975
    self.nodeMass = 0.1

    self.nodes:init(function (i, j)
        local initialX = i * self.width / self.cols
        local static = i == 0 or i == self.cols or j == 0 or j == self.rows
        local initialY = j * self.height / self.rows
        return {
            fixed = static,
            ox = initialX,
            oy = initialY,
            x = initialX,
            y = initialY,
            _x = initialX,
            _y = initialY,
            fx = 0,
            fy = 0
        }
    end)

    return self
end

function Fabric:register(entity)
    print('registering ' .. entity.type .. ' (' .. entity.id .. ') #' .. entity.gridWarpFactor)
    -- table.insert(self.manipulators, entity.id)
    -- self.manipulators[#self.manipulators + 1] = entity.id
    -- table.insert(self.manipulators, entity)
    self.manipulators[entity.id] = true
    -- entity.gridWarpEnabled = true
end

function Fabric:deregister(entity)
    print('deregistering ' .. entity.type .. ' (' .. entity.id .. ')')
    -- table.remove(self.manipulators, entity.id)
    -- table.remove(self.manipulators, entity.id)
    -- entity.gridWarpEnabled = false
    self.manipulators[entity.id] = nil
end

-- Collect all manipulating forces on a node
function Fabric:calculateForce(node)
    local sum_fx = 0
    local sum_fy = 0

    -- if node == self.nodes.data[1] then
    --     print(inspect(self.manipulators))
    -- end

    -- for id, enabled in pairs(self.manipulators) do
    for id, ent in pairs(entities.objects) do
        -- local ent = entities.get(id)
        -- if ent == nil or not enabled then break end
        -- if ent == nil then break end
        if self.manipulators[id] == nil then break end

        -- Calculate distance from ent to node
        local dx = node.x - ent.body:getX()
        local dy = node.y - ent.body:getY()
        local dSquared = dx * dx + dy * dy
        if dSquared > ent.gridWarpRadiusSquared then break end

        local tSquared = dSquared / ent.gridWarpRadiusSquared
        local d = math.sqrt(dSquared)
        -- Bubble effect
        local pull = ent.gridWarpFactor * math.sqrt(1 - tSquared)
        -- Gravity effect
        -- local pull = ent.gridWarpFactor / dSquared
        -- local pull = ent.gridWarpFactor / d
        sum_fx = sum_fx + pull * dx / d
        sum_fy = sum_fy + pull * dy / d
        -- local blackhole = ent.gridWarpFactor * -math.exp(-tSquared)
        -- sum_fx = sum_fx + blackhole * dx / d
        -- sum_fy = sum_fy + blackhole * dy / d
        -- fx, fy = ent:warpGrid(t)
        -- sum_fx = sum_fx + fx
        -- sum_fy = sum_fy + fy
    end

    node.fx = node.fx + sum_fx
    node.fy = node.fy + sum_fy
end

function Fabric:applySpring(A, B)
    local dx, dox = A.x - B.x, A.ox - B.ox
    local dy, doy = A.y - B.y, A.oy - B.oy

    local fx = self.springConstant * (dx - dox)
    local fy = self.springConstant * (dy - doy)

    if not A.fixed then
        A.fx = A.fx - fx
        A.fy = A.fy - fy
    end
    if not B.fixed then
        B.fx = B.fx + fx
        B.fy = B.fy + fy
    end
end

function Fabric:update(dt)
    -- Don't simulate if running slowly
    if (dt > 0.1) then
        return
    end

    for _, node in pairs(self.nodes.data) do
        -- Reset node forces for this frame
        node.fx = 0
        node.fy = 0

        if not node.fixed then
            self:calculateForce(node)
        end
    end

    -- Horizontal pass 1 (even)
    for j = 0, self.rows, 1 do
        for i = 0, self.cols - 1, 2 do
            local A = self.nodes:get(i, j)
            local B = self.nodes:get(i + 1, j)
            self:applySpring(A, B)
        end
    end

    -- Horizontal pass 2 (odd)
    for j = 0, self.rows, 1 do
        for i = 1, self.cols - 1, 2 do
            local A = self.nodes:get(i, j)
            local B = self.nodes:get(i + 1, j)
            self:applySpring(A, B)
        end
    end

    -- Vertical pass 1 (even)
    for i = 0, self.cols, 1 do
        for j = 0, self.rows - 1, 2 do
            local A = self.nodes:get(i, j)
            local B = self.nodes:get(i, j + 1)
            self:applySpring(A, B)
        end
    end

    -- Vertical pass 2 (odd)
    for i = 0, self.cols, 1 do
        for j = 1, self.rows - 1, 2 do
            local A = self.nodes:get(i, j)
            local B = self.nodes:get(i, j + 1)
            self:applySpring(A, B)
        end
    end

    -- -- Diagonal pass 1
    -- for j = 0, self.rows - 1, 1 do
    --     for i = 0, self.cols - 1, 1 do
    --         local A = self.nodes[j * self.cols + i]
    --         local B = self.nodes[(j + 1) * self.cols + i + 1]
    --         self:applySpring(A, B)
    --     end
    -- end
    --
    -- -- Diagonal pass 2
    -- for j = 1, self.rows, 1 do
    --     for i = 1, self.cols, 1 do
    --         local A = self.nodes[j * self.cols + i]
    --         local B = self.nodes[(j - 1) * self.cols + i - 1]
    --         self:applySpring(A, B)
    --     end
    -- end

    for _, node in pairs(self.nodes.data) do
        -- Integrate net force to change in position
        -- (Stormer Verlet integration)
        local ax = node.fx / self.nodeMass
        local ay = node.fy / self.nodeMass
        local _x, _y = node.x, node.y
        node.x = node.x + self.damping * (node.x - node._x) + ax * dt * dt
        node.y = node.y + self.damping * (node.y - node._y) + ay * dt * dt

        node._x = _x
        node._y = _y
    end
end

function Fabric:draw()
    love.graphics.push()
    love.graphics.setLineWidth(5)

    -- Draw all columns
    for i = 1, self.cols - 1 do
        if i % 5 == 0 then
            love.graphics.setColor(64, 0, 128, 92)
        else
            love.graphics.setColor(64, 0, 128, 64)
        end
        for j = 1, self.rows do
            local A = self.nodes:get(i, j - 1)
            local B = self.nodes:get(i, j)
            love.graphics.line(A.x, A.y, B.x, B.y)
        end
    end

    -- Draw all rows
    for j = 1, self.rows - 1 do
        if j % 5 == 0 then
            love.graphics.setColor(64, 0, 128, 92)
        else
            love.graphics.setColor(64, 0, 128, 64)
        end
        for i = 1, self.cols do
            local A = self.nodes:get(i - 1, j)
            local B = self.nodes:get(i, j)
            love.graphics.line(A.x, A.y, B.x, B.y)
        end
    end
    love.graphics.pop()
end
