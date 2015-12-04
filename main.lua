require('level')
require('player')
require('entities')

debug = false

function love.conf(t)
    t.title = "Strati"
    t.version = "0.9.2"
    t.console = true
end

function love.load()
    local pixelcode = [[
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            vec4 texcolor = Texel(texture, texture_coords);
            return texcolor * color;
            // return vec4(1.0, 1.0, 1.0. 1.0);
        }
    ]]

    local vertexcode = [[
        vec4 position( mat4 transform_projection, vec4 vertex_position )
        {
            return transform_projection * vertex_position;
        }
    ]]

    local shader = love.graphics.newShader(pixelcode, vertexcode)
    -- This can be called within love.draw() to swap shaders on the fly
    love.graphics.setShader(shader)
    love.graphics.setBlendMode('additive')

    entities.startup()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

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
    level.camera:follow(player)
    local boxEnt = entities.create('box', 128, 128)
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
    player:update(dt)
    -- end
end

function love.draw()
    if debug then
        local fps = love.timer.getFPS()
        love.graphics.print(fps, 2, 2)
    end

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

    -- player
    player:draw(dt)

    level.camera:unset()
end
