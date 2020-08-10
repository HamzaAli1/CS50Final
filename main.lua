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

-- pause bool
paused = false

function love.load()
    -- window setup
    love.window.setTitle('Final Project')
    love.graphics.setDefaultFilter('nearest')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, { fullscreen = true })

    -- create map
    map = Map(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

function love.update(dt)
    if not paused then
        -- update map
        map:update(dt)        
    end
end

function love.draw()
    push:apply('start')

    -- render map
    map:render()

    --[[
    -- debug
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setNewFont(10)
    love.graphics.print("Width: " .. tostring(WINDOW_WIDTH) .. '; ' .. "Height: " .. tostring(WINDOW_HEIGHT), 20, 0)
    love.graphics.print("Virtual Width: " .. tostring(VIRTUAL_WIDTH) .. '; ' .. "Virtual Height: " .. tostring(VIRTUAL_HEIGHT), 20, 10)
    love.graphics.print("Game state: " .. tostring(map.state), 20, 20)
    love.graphics.print("Ship coords: x = " .. tostring(math.floor(map.ship.x)) .. '; y = ' .. tostring(math.floor(map.ship.y)), 20, 30)
    love.graphics.print("Ship velocity: dx = " .. tostring(map.ship.dx) .. '; dy = ' .. tostring(map.ship.dy), 20, 40)
    love.graphics.print('Level ' .. tostring(map.level), 20, 50)
    love.graphics.print('Num Enemies: ' .. tostring(#map.enemies), 20, 60)

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

function love.focus(f)
    -- pause when unfocused
    paused = not f
end

function love.quit()
end