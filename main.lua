require('level')
require('entities')

debugMode = false
screenBuffer = nil
glowShader = nil
glowCanvas1 = nil
glowCanvas2 = nil
glowMap = nil
glowMapShader = nil

function love.conf(t)
    t.title = "Strati"
    t.version = "0.9.2"
    t.console = true

    if not love.graphics.isSupported('canvas') then
        print('Your graphics card is incompatible with this game.')
        print('(off-screen rendering support)')
        love.event.push('quit')
    end

    if not love.graphics.isSupported('npot') then
        print('Your graphics card is incompatible with this game.')
        print('(non-power of two texture support)')
        love.event.push('quit')
    end
end

function love.load()
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    screenBuffer = love.graphics.newCanvas(width, height, 'rgba8', 0)

    local glowMapWidth = 512
    local glowMapHeight = 512
    glowMap = love.graphics.newCanvas(glowMapWidth, glowMapHeight, 'rgba8', 0)
    glowMapShader = love.graphics.newShader('effects/glowmap.glsl')

    glowCanvas1 = love.graphics.newCanvas(glowMapWidth, glowMapHeight, 'rgba8', 0)
    glowCanvas2 = love.graphics.newCanvas(glowMapWidth, glowMapHeight, 'rgba8', 0)
    glowShader = love.graphics.newShader('effects/overglow.glsl')
    -- The number of neighboring samples to take for the blur
    glowShader:sendInt('blurRadius', 10)
    -- The distance between samples taken for the blur
    glowShader:send('blurScale', 1)
    -- A scaling factor to control the strength of the blur (between 0 and 1)
    glowShader:send('blurStrength', 0.3)
    -- The size of a single pixel in the glowmap
    glowShader:send('texelSize', {1.0 / glowMap:getWidth(), 1.0 / glowMap:getHeight()})

    abberationShader = love.graphics.newShader('effects/abberation.glsl')
    abberationShader:send('abberation', 2 / love.graphics.getWidth())

    entities.startup()

    stuff = {}

    for i = 1, 50 do
        table.insert(stuff, {
            x = math.random(0, width * 2 - 300),
            y = math.random(0, height * 2 - 300),
            width = math.random(100, 300),
            height = math.random(100, 300),
            color = { 32, 32, 32 }
        })
    end

    level:load()
end

function love.joystickadded(joystick)
    if joystick:isGamepad() then
        -- TODO: confirm joystick has required layout
        local name_id = joystick:getName() .. ' ' .. joystick:getID()
        print('A controller was connected (' .. name_id .. ')')
        player:registerController(joystick)
    end
end

function love.joystickremoved(joystick)
    local name_id = joystick:getName() .. ' ' .. joystick:getID()
    print('A controller was disconnected (' .. name_id .. ')')
    -- TODO: pause game
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.push('quit')
    elseif key == '=' then
        level.camera:zoom(1.25)
    elseif key == '-' then
        level.camera:zoom(0.8)
    end
end

function love.update(dt)
    -- if not game.paused then
    level:update(dt)
    entities.update(dt)
    -- end
end

function love.draw()
    -- Draw to the screen buffer
    love.graphics.setCanvas(screenBuffer)
    love.graphics.setBlendMode('additive')
    screenBuffer:clear()
    -- love.graphics.setBackgroundColor(0, 0, 0)

    level.camera:set()

    -- box
    level:draw(dt)

    -- stuff
    love.graphics.setLineWidth(3)
    for _, v in pairs(stuff) do
        love.graphics.setColor(v.color)
        love.graphics.rectangle('line', v.x, v.y, v.width, v.height)
    end

    entities.draw(dt)

    level.camera:unset()

    -- Generate glowmap
    love.graphics.setCanvas(glowMap)
    love.graphics.setShader(glowMapShader)
    glowMap:clear()
    local sx, sy = glowMap:getWidth() / screenBuffer:getWidth(), glowMap:getHeight() / screenBuffer:getHeight()
    local ox, oy = glowMap:getWidth() / 2, glowMap:getHeight() / 2
    love.graphics.draw(screenBuffer, 0, 0, 0, sx, sy, 0, 0, 0, 0)

    -- Generate overglow
    love.graphics.setShader(glowShader)
    love.graphics.setBlendMode('screen')

    -- Horizontal blur pass
    love.graphics.setCanvas(glowCanvas1)
    glowCanvas1:clear()
    glowShader:send('dir', {1, 0})
    love.graphics.draw(glowMap)

    -- Vertical blur pass
    love.graphics.setCanvas(glowCanvas2)
    glowCanvas2:clear()
    -- love.graphics.setBlendMode('replace')
    -- love.graphics.setBackgroundColor(255,0,0,255)
    -- love.graphics.setBlendMode('screen')
    glowShader:send('dir', {0, 1})
    love.graphics.draw(glowCanvas1)

    -- Now set drawing to the window
    love.graphics.setShader(abberationShader)
    love.graphics.setCanvas()

    -- Draw normal
    love.graphics.setBlendMode('screen')
    love.graphics.draw(screenBuffer)

    -- Draw glow
    love.graphics.setBlendMode('screen')
    love.graphics.draw(glowCanvas2, 0, 0, 0, 1 / sx, 1 / sy, 0, 0, 0)

    love.graphics.setShader()

    if debugMode then
        love.graphics.setBlendMode('alpha')
        local fps = love.timer.getFPS()
        love.graphics.print('FPS: ' .. fps, 2, 2)
    end
end
