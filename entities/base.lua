local base = {}

base.x = 0
base.y = 0
base.health = 1

function base:setPosition(x, y)
    base.x = x
    base.y = y
end

function base:getPosition()
    return base.x, base.y;
end

-- This is a virtual method header (to be implemented by derived entities)
function base:load()
end

return base;
