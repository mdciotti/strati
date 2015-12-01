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

return base;
