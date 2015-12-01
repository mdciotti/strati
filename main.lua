require('level')
require('player')
require('entities')

function love.conf(t)
    t.title = "Strati"
    t.version = "0.9.2"
    t.console = true
end

function love.load()
    entities.startup()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

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
    level:load()
    level.camera:follow(player)
end

function love.update(dt)
    if love.keyboard.isDown('escape') then
        love.event.push('quit')
    end

    level:update(dt)
    entities:update(dt)
    player:update(dt)

    -- camera:setPosition(player.body:getX() - width / 2, player.body:getY() - height / 2)
end

function love.draw()
    level.camera:set()

    -- box
    level:draw(dt)

    -- stuff
    love.graphics.setLineWidth(1)
    for _, v in pairs(stuff) do
        love.graphics.setColor(v.color)
        love.graphics.rectangle('line', v.x, v.y, v.width, v.height)
    end

    entities:draw(dt)

    -- player
    player:draw(dt)

    level.camera:unset()
end
