--[[
    renders and different types of enemies depending on constructor
--]]

Enemy = Class{}

function Enemy:init(map, type, diff, x, y)
    -- reference to map to determine position and game state
    self.map = map
    self.x = x
    self.y = y

    -- load in sprite sheet
    self.spritesheet = love.graphics.newImage('res/temp_ship.png')
    
    -- enemy type and difficulty
    self.type = type
    self.diff = diff

    -- instantiate other class variables
    self.dx = 0
    self.dy = 0
    ENEMY_SPEED = 50 * diff
    self.width = 47
    self.height = 44
    self.color_scheme = {1, 1, 1, 1}

    -- hit points starts at 5
    self.hp = 5

    -- TODO: replace this with an actual animation
    -- create animation table
    self.animations = {
        ['neutral'] = Animation{
            texture = self.spritesheet,
            frames = {
                love.graphics.newQuad(202, 2, self.width, self.height, self.spritesheet:getDimensions())
            }
        }, 
        ['cutscene'] = Animation{  -- TODO change this later
            texture = self.spritesheet,
            frames = {
                love.graphics.newQuad(202, 2, self.width, self.height, self.spritesheet:getDimensions())
            }
        }
    }
    self.animation = self.animations[self.map.state]
    self.current_frame = self.animation:getCurrentFrame()

    -- create behavior table
    self.behaviors = {
        ['block'] = function(dt)
            -- float towards ship
            if self.x > self.map.ship.x then
                self.dx = -ENEMY_SPEED
            else
                self.dx = ENEMY_SPEED
            end
            if self.y > self.map.ship.y then
                self.dy = -ENEMY_SPEED
            else
                self.dy = ENEMY_SPEED
            end
        end
    }
end

function Enemy:update(dt)
    -- run behavior function based on map state and type
    if self.map.state == 'neutral' then
        self.behaviors[self.type](dt)
    end

    -- update animation
    self.animation:update(dt)
    self.current_frame = self.animation:getCurrentFrame()

    -- change x and y as needed
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

end

function Enemy:render()
    love.graphics.draw(self.spritesheet, self.current_frame, self.x, self.y, 0, -1, 1, self.width, 0)
end