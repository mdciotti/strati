-- Warp Grid

WarpGrid = {}

function WarpGrid:create(w, h, cols, rows)
    self.width = w
    self.height = h
    self.cols = cols
    self.rows = rows
    self.manipulators = {}
    self.nodes = {}
    self.springConstant = 5
    self.damping = 0.9
    self.nodeMass = 0.1

    for i = 0, self.cols - 1 do
        local initialX = (i + 1) * self.width / self.cols
        for j = 0, self.rows - 1 do
            local initialY = (j + 1) * self.height / self.rows
            self.nodes[j * self.cols + i] = {
                ox = initialX,
                oy = initialY,
                x = initialX,
                y = initialY,
                _x = initialX,
                _y = initialY
            }
        end
    end


    return self
end

function WarpGrid:register(entity)
    -- print('registering ' .. entity.type .. ' (' .. entity.id .. ')')
    -- table.insert(WarpGrid.manipulators, entity)
    self.manipulators[entity.id] = entity
end

function WarpGrid:deregister(entity)
    print('deregistering ' .. entity.type .. ' (' .. entity.id .. ')')
    table.remove(self.manipulators, entity.id)
end

function WarpGrid:update(dt)
    for _, node in pairs(self.nodes) do
        -- Reset node forces for this frame
        local fx = 0
        local fy = 0

        -- Collect all manipulating forces on the node
        for _, manipulator in pairs(self.manipulators) do
            local dx = node.x - manipulator.body:getX()
            local dy = node.y - manipulator.body:getY()
            local dSquared = dx * dx + dy * dy
            -- local d = math.sqrt(dSquared)
            -- local pull = manipulator.gridWarpFactor / d
            local pull = manipulator.gridWarpFactor
            fx = fx + pull * dx / dSquared
            fy = fy + pull * dy / dSquared
        end

        -- Apply spring force to node
        fx = fx - self.springConstant * (node.x - node.ox)
        fy = fy - self.springConstant * (node.y - node.oy)

        -- Integrate net force to change in position
        -- (Stormer Verlet integration)
        local ax = fx / self.nodeMass
        local ay = fy / self.nodeMass
        local _x, _y = node.x, node.y
        node.x = node.x + self.damping * (node.x - node._x) + ax * dt * dt
        node.y = node.y + self.damping * (node.y - node._y) + ay * dt * dt

        node._x = _x
        node._y = _y
    end
    debug.manipulators = self.manipulators
end

function WarpGrid:draw()
    love.graphics.push()
    love.graphics.setLineWidth(3)
    love.graphics.setPointSize(5)
    love.graphics.setColor(64, 0, 128, 64)

    for i, node in pairs(self.nodes) do
        love.graphics.point(node.x, node.y)
    end

    -- -- Draw all columns
    -- for i = 0, self.cols - 1 do
    --     for j = 1, self.rows - 1 do
    --         local A = self.nodes[(j - 1) * self.cols + i]
    --         local B = self.nodes[j * self.cols + i]
    --         love.graphics.line(A.x, A.y, B.x, B.y)
    --     end
    -- end
    --
    -- -- Draw all rows
    -- for i = 1, self.cols - 1 do
    --     for j = 0, self.rows - 1 do
    --         local A = self.nodes[j * self.cols + i - 1]
    --         local B = self.nodes[j * self.cols + i]
    --         love.graphics.line(A.x, A.y, B.x, B.y)
    --     end
    -- end
    love.graphics.pop()
end
