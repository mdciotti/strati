require('pid-controller')

entities = {}
entities.objects = {}
entities.objectpath = 'entities/'
local register = {}
local id = 0

function entities.startup()
    register['player'] = love.filesystem.load(entities.objectpath .. 'player.lua')
    register['box'] = love.filesystem.load(entities.objectpath .. 'box.lua')
    register['bullet'] = love.filesystem.load(entities.objectpath .. 'bullet.lua')
    register['missile'] = love.filesystem.load(entities.objectpath .. 'missile.lua')
    register['evader'] = love.filesystem.load(entities.objectpath .. 'evader.lua')
end

function entities.derive(name)
    if not register[name] then
        register[name] = love.filesystem.load(entities.objectpath .. name .. '.lua')
    end
    return register[name]()
end

function entities.get(id)
    return entities.objects[id]
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
        ent.type = name
        ent.id = id
        ent:load(x, y)
        if ent.fixture then
            ent.fixture:setUserData(id)
        end
        entities.objects[id] = ent
        return ent
    else
        print('Error: entity "' .. '" does not exist in the register.')
        return false
    end
end

function entities.destroy(id)
    if entities.objects[id] then
        if entities.objects[id].destroy then
            entities.objects[id]:destroy()
        end
        entities.objects[id] = nil
    end
end

function entities.update(dt)
    for i, ent in pairs(entities.objects) do
        if ent.update then
            ent:update(dt)
        end
    end
end

function entities.draw(dt)
    for i, ent in pairs(entities.objects) do
        if ent.draw then
            ent:draw(dt)
        end
    end
end
