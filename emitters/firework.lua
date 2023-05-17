local firework = {}

-- These should be set in derived entities
firework.body = nil
firework.shape = nil
firework.fixture = nil

-- Virtual method headers (to be implemented by derived entities)
function firework:load()
end

function firework:update(dt)
end

-- This is an internal method to be called from the entities controller
-- example: entities.destroy(id)
function firework:destroy()
    self.fixture:destroy()
    -- self.shape:destroy()
    -- self.body:destroy()
    -- print('destroying ' .. self.type .. ' ' .. self.id)
end

return firework
