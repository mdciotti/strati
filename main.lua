require('level')
require('entities')

debugMode = false
screenBuffer = nil
glowShader = nil
glowCanvas = nil

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
    glowCanvas = love.graphics.newCanvas(width, height, 'rgba8', 0)
    glowShader = love.graphics.newShader('effects/overglow.glsl')
    glowShader:send('width', love.graphics.getWidth())
    glowShader:send('height', love.graphics.getHeight())
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

function love.update(dt)
    if love.keyboard.isDown('escape') then
        love.event.push('quit')
    end

    -- if not game.paused then
    level:update(dt)
    entities.update(dt)
    -- end
end

function love.draw()
    -- Draw to the screen buffer
    love.graphics.setCanvas(screenBuffer)
    love.graphics.setBlendMode('alpha')
    screenBuffer:clear()
    -- love.graphics.setBackgroundColor(0, 0, 0)

    level.camera:set()

    -- box
    level:draw(dt)

    -- stuff
    love.graphics.setLineWidth(1)
    for _, v in pairs(stuff) do
        love.graphics.setColor(v.color)
        love.graphics.rectangle('line', v.x, v.y, v.width, v.height)
    end

    entities.draw(dt)

    level.camera:unset()

    -- Draw overglow
    love.graphics.setBlendMode('premultiplied')
    love.graphics.setCanvas(glowCanvas)
    glowCanvas:clear()
    love.graphics.setShader(glowShader)
    glowShader:send('dir', {1, 0})
    love.graphics.draw(screenBuffer)
    love.graphics.setCanvas()
    glowShader:send('dir', {0, 1})
    love.graphics.draw(glowCanvas)

    -- Now draw to the window
    love.graphics.setShader(abberationShader)
    love.graphics.setCanvas()

    -- Draw normal
    love.graphics.setBlendMode('screen')
    love.graphics.draw(screenBuffer)

    love.graphics.setShader()

    if debugMode then
        love.graphics.setBlendMode('alpha')
        local fps = love.timer.getFPS()
        love.graphics.print('FPS: ' .. fps, 2, 2)
    end
end
