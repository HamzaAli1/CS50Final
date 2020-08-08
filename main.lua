--[[
    TITLE GOES HERE
    By: Hamza Ali

    Final project for CS50x
--]]

-- required libs and src
push = require 'lib.push'
Class = require 'lib.class'

require 'src.Animation'
require 'src.Map'
require 'src.Ship'
require 'src.Enemy'


-- variables to setup window
WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- seed RNG
math.randomseed(os.time())

function love.load()
    -- window setup
    love.window.setTitle('Final Project')
    love.graphics.setDefaultFilter('nearest')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, { fullscreen = true })

    -- create map
    map = Map(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

function love.update(dt)
    -- update map
    map:update(dt)
end

function love.draw()
    push:apply('start')

    -- render map
    map:render()

    --[[
    -- debug
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setNewFont(10)
    love.graphics.print("Width: " .. tostring(WINDOW_WIDTH), 20, 0)
    love.graphics.print("Height: " .. tostring(WINDOW_HEIGHT), 20, 10)
    love.graphics.print("Virtual Width: " .. tostring(VIRTUAL_WIDTH), 20, 20)
    love.graphics.print("Virtual Height: " .. tostring(VIRTUAL_HEIGHT), 20, 30)
    love.graphics.print("Ship state: " .. tostring(map.ship.state), 20, 40)
    love.graphics.print("Ship coords: x = " .. tostring(map.ship.x) .. '; y = ' .. tostring(map.ship.y), 20, 50)
    love.graphics.print("Ship velocity: dx = " .. tostring(map.ship.dx) .. '; dy = ' .. tostring(map.ship.dy), 20, 60)
    love.graphics.print('key down left?: ' .. tostring(love.keyboard.isDown('left')), 20, 70)
    --]]

    push:apply('end')
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.focus()
end

function love.quit()
end