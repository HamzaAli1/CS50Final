--[[
    Renders space ship and controls its movement
--]]

Ship = Class{}

function Ship:init(map)
    -- reference to map to determine position
    self.map = map
    self.x = 25
    self.y = 25

    -- load in sprite sheet
    self.spritesheet = love.graphics.newImage('res/temp_ship.png')
    
    -- instantiate other class variables
    self.state = 'neutral'
    self.dx = 0
    self.dy = 0
    SHIP_SPEED = 150

    -- TODO: replace this with an actual animation
    -- create animation table
    self.animations = {
        ['neutral'] = Animation{
            texture = self.spritesheet,
            frames = {
                love.graphics.newQuad(0, 0, 55, 46, self.spritesheet:getDimensions())
            }
        }
    }
    self.animation = self.animations[self.state]
    self.current_frame = self.animation:getCurrentFrame()

    -- create behavior table
    self.behaviors = {
        ['neutral'] = function(dt)
            -- movement based on arrow key input
            if love.keyboard.isDown('left') and self.x > -10 then
                self.dx = -SHIP_SPEED
            elseif love.keyboard.isDown('right') and self.x < map.mapWidth - 50 then
                self.dx = SHIP_SPEED
            else
                self.dx = 0
            end
            -- x and y movement seperate
            if love.keyboard.isDown('up') and self.y > -10 then
                self.dy = -SHIP_SPEED
            elseif love.keyboard.isDown('down') and self.y < map.mapHeight - 40 then
                self.dy = SHIP_SPEED
            else
                self.dy = 0
            end
        end
    }
end

function Ship:update(dt)
    -- run behavior function based on state
    self.behaviors[self.state](dt)

    -- update animation
    self.animation:update(dt)
    self.current_frame = self.animation:getCurrentFrame()

    -- change x and y as needed
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

end

function Ship:render()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.spritesheet, self.current_frame, math.floor(self.x + 0.5), math.floor(self.y + 0.5))
end