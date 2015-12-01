entities = {}
entities.objects = {}
entities.objectpath = 'entities/'
local register = {}
local id = 0

function entities.startup()
    register['box'] = love.filesystem.load(entities.objectpath .. 'box.lua')
    register['bullet'] = love.filesystem.load(entities.objectpath .. 'bullet.lua')
end

function entities.derive(name)
    if not register[name] then
        register[name] = love.filesystem.load(entities.objectpath .. name .. '.lua')
    end
    return register[name]()
end

function entities.create(name, x, y)
    if not x then
        x = 0
    end
    if not y then
        y = 0
    end

    if register[name] then
        id = id + 1
        local ent = register[name]()
        ent:load(x, y)
        ent.id = id
        entities.objects[#entities.objects + 1] = ent
        return entities.objects[#entities.objects]
    else
        print('Error: entity "' .. '" does not exist in the register.')
        return false
    end
end

function entities.destroy(id)
    if entites.objects[id] then
        if entities.objects[id].die then
            entities.objects[id]:die()
        end
        entities.objects[id] = nil
    end
end

function entities:update(dt)
    for i, ent in pairs(entities.objects) do
        if ent.update then
            ent:update(dt)
        end
    end
end

function entities:draw(dt)
    for i, ent in pairs(entities.objects) do
        if ent.draw then
            ent:draw(dt)
        end
    end
end
