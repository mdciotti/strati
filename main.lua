require('camera')
require('level')
require('player')
require('entities')

function love.conf(t)
    t.title = "Strati"
    t.version = "0.9.2"
    -- t.window.width =
    -- t.window.height =
    t.console = true
    -- t.window.srgb = true
    -- love.window.setMode(800, 600)
end

function love.load()
    entities.startup()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    camera:setBounds(-width / 2, -height / 2, 1.5 * width, 1.5 * height)

    stuff = {}

    for i = 1, 10 do
        table.insert(stuff, {
            x = math.random(100, width * 2 - 100),
            y = math.random(100, height * 2 - 100),
            width = math.random(100, 300),
            height = math.random(100, 300),
            color = { 255, 255, 255 }
        })
    end

    local boxEnt = entities.create('box', 128, 128)
end

function love.update(dt)
    if love.keyboard.isDown('escape') then
        love.event.push('quit')
    end

    entities:update(dt)
    player:update(dt)

    camera:setPosition(player.body:getX() - width / 2, player.body:getY() - height / 2)
end

function love.draw()
    camera:set()

    -- box
    level:draw(dt)

    -- stuff
    love.graphics.setLineWidth(1)
    for _, v in pairs(stuff) do
        love.graphics.setColor(v.color)
        love.graphics.rectangle('line', v.x, v.y, v.width, v.height)
    end

    -- Gamma test
    for v = 0, 20, 1 do
        local x = v / 20 * 255
        love.graphics.setColor({x, x, x})
        love.graphics.rectangle('fill', 10 * v, 0, 10, 100)
        love.graphics.setColor(love.math.gammaToLinear({x, x, x}))
        love.graphics.rectangle('fill', 10 * v, 100, 10, 100)
    end

    entities:draw(dt)

    -- player
    player:draw(dt)

    camera:unset()
end
