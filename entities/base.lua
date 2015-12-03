local base = {}

-- These should be set in derived entities
base.body = nil
base.shape = nil
base.fixture = nil

-- Virtual method headers (to be implemented by derived entities)
function base:load()
end

function base:update(dt)
end

-- This is an internal method to be called from the entities controller
-- example: entities.destroy(id)
function base:destroy()
    -- self.body:destroy()
    -- self.shape:destroy()
    -- self.fixture:destroy()
    print('destroying ' .. self.name .. ' ' .. self.id)
end

return base;
