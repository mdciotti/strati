ParticleEmitter = {}
ParticleEmitter.objectpath = 'emitters/'
local emitters = {}
local register = {}
local id = 0

function ParticleEmitter.startup()
    register['firework'] = love.filesystem.load(ParticleEmitter.objectpath .. 'firework.lua')
    -- register['player'] = love.filesystem.load(ParticleEmitter.objectpath .. 'player.lua')
    -- register['bullet'] = love.filesystem.load(ParticleEmitter.objectpath .. 'bullet.lua')
    -- register['missile'] = love.filesystem.load(ParticleEmitter.objectpath .. 'missile.lua')
    -- register['box'] = love.filesystem.load(ParticleEmitter.objectpath .. 'box.lua')
    -- register['evader'] = love.filesystem.load(ParticleEmitter.objectpath .. 'evader.lua')
end

function ParticleEmitter.get(id)
    return ParticleEmitter.emitters[id]
end

function ParticleEmitter.create(name, x, y)
    if not x then x = 0 end
    if not y then y = 0 end

    if register[name] then
        id = id + 1
        local emitter = register[name]()
        emitter.type = name
        emitter.id = id
        ParticleEmitter.emitters[id] = emitter
        return emitter
    else
        print('Error: emitter "' .. '" does not exist in the register.')
        return false
    end
end

function ParticleEmitter.destroy(id)
    if ParticleEmitter.emitters[id] then
        ParticleEmitter.emitters[id] = nil
    end
end

function ParticleEmitter.update(dt)
    for i, emitter in pairs(ParticleEmitter.emitters) do
        if emitter.update then
            emitter:update(dt)
        end
    end
end

function ParticleEmitter.draw(dt)
    for i, emitter in pairs(ParticleEmitter.emitters) do
        if emitter.draw then
            emitter:draw(dt)
        end
    end
end
