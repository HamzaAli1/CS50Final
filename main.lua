--[[
    SunPiercer
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

-- color scheme
SUN_YELLOW = {254 / 255, 199 / 255, 64 / 255, 1}
DARK_GRAY = {80 / 255, 71 / 255, 70 / 255, 1}
WHITE = {225 / 255, 229 / 255, 238 / 255, 1}
BULLET_RED = {242 / 255, 87 / 255, 87 / 255, 1}

function love.load()
    -- window setup
    love.graphics.setDefaultFilter('nearest', 'nearest')
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
    love.graphics.print("Width: " .. tostring(WINDOW_WIDTH) .. '; ' .. "Height: " .. tostring(WINDOW_HEIGHT), 10, 0)
    love.graphics.print("Virtual Width: " .. tostring(VIRTUAL_WIDTH) .. '; ' .. "Virtual Height: " .. tostring(VIRTUAL_HEIGHT), 10, 10)
    love.graphics.print("Game state: " .. tostring(map.state), 10, 20)
    love.graphics.print('Level ' .. tostring(map.level), 10, 30)
    love.graphics.print('Num Enemies: ' .. tostring(#map.enemies), 10, 40)
    --]]

    push:apply('end')
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    -- escape exits from game
    if key == 'escape' then
        -- TODO: add some sort of warning
        love.event.quit()
    -- enter used to move from title screen to game or from game over screen to title or to pause/unpause the game
    elseif key == 'return' then
        if map.state == 'title' then
            map.state = 'cutscene'
        elseif map.state == 'defeat' then
            map.state = 'title'
            -- reset map for next game
            map:reset()
        else
            -- pause/unpause game
            paused = not paused
        end
    end
end

function love.focus(f)
    -- pause when unfocused
    paused = not f
end

function love.quit()
end