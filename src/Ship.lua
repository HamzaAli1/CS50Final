--[[
    Renders space ship and controls its movement
--]]

Ship = Class{}

function Ship:init(map)
    -- reference to map to determine position and game state
    self.map = map
    self.x = 0
    self.y = 0

    -- load in sprite sheet
    self.spritesheet = love.graphics.newImage('res/temp_ship.png')
    
    -- instantiate other class variables
    self.dx = 0
    self.dy = 0
    SHIP_SPEED = 150
    self.width = 36
    self.height = 18
    self.color_scheme = {}

    -- hit points starts at 5
    self.hp = 5
    self.hit = false
    self.invulnerableFrames = 30

    -- bullet coords and velocity
    self.bulletX = self.x + self.width / 2
    self.bulletY = self.y + self.height / 2 + 5
    self.bulletDx = 0
    self.bullet_fired = false

    -- TODO: replace this with an actual animation
    -- create animation table
    self.animations = {
        ['neutral'] = Animation{
            texture = self.spritesheet,
            frames = {
                love.graphics.newQuad(14, 14, self.width, self.height, self.spritesheet:getDimensions())
            }
        },
        ['cutscene'] = Animation{
            texture = self.spritesheet,
            frames = {
                love.graphics.newQuad(14, 14, self.width, self.height, self.spritesheet:getDimensions())
            }
        }
    }
    self.animation = self.animations['neutral']
    self.current_frame = self.animation:getCurrentFrame()

    -- create behavior table
    self.behaviors = {
        ['neutral'] = function(dt)
            -- set color scheme to default
            self.color_scheme[1] = WHITE[1]
            self.color_scheme[2] = WHITE[2] * self.hp / 5
            self.color_scheme[3] = WHITE[3] * self.hp / 5
            self.color_scheme[4] = WHITE[4]

            -- movement based on arrow key input
            if love.keyboard.isDown('left') and self.x > 0 then
                self.dx = -SHIP_SPEED
            elseif love.keyboard.isDown('right') and self.x < map.mapWidth - self.width then
                self.dx = SHIP_SPEED
            else
                self.dx = 0
            end
            -- x and y movement seperate
            if love.keyboard.isDown('up') and self.y > 0 then
                self.dy = -SHIP_SPEED
            elseif love.keyboard.isDown('down') and self.y < map.mapHeight - self.height then
                self.dy = SHIP_SPEED
            else
                self.dy = 0
            end

            -- space to shoot bullet
            if love.keyboard.isDown('space') and not self.bullet_fired then
                self.bullet_fired = true
                self.bulletDx = 10
            end

            -- hit invulnerability
            if self.hit then
                -- if invulnerablity frames done, hit becomes false
                if self.invulnerableFrames == 0 then
                    self.invulnerableFrames = 10
                    self.hit = false
                -- else decrease invulnerability frame count
                else
                    self.invulnerableFrames = self.invulnerableFrames - 1
                    self.color_scheme[1] = WHITE[1]
                    self.color_scheme[2] = WHITE[2] * self.hp / 5
                    self.color_scheme[3] = WHITE[3] * self.hp / 5
                    self.color_scheme[4] = self.invulnerableFrames % 2
                end
            end

        end, 
        ['cutscene'] = function(dt)
            -- beginning cutscene
            if self.map.cutscene == 'opening' then
                local temp = 0.1 + self.x / 100 * 0.9
                self.color_scheme = {temp, temp, temp, temp}
                self.dx = 50
            end
            -- TODO: add more as needed
        end,
        ['complete'] = function(dt)
            self.dx = 0
            self.dy = 0
        end,
        ['victory'] = function(dt)
            self.dx = 0
            self.dy = 0
        end,
        ['defeat'] = function(dt)
            self.dx = 0
            self.dy = 0
            self.color_scheme = {1, 0, 0, 0.75}
        end
    }

    -- move ship to center of screen for cutscene
    self.y = map.mapHeight / 2 - self.width / 2
end

function Ship:update(dt)
    -- run behavior function based on map state
    self.behaviors[self.map.state](dt)

    -- update animation
    self.animation:update(dt)
    self.current_frame = self.animation:getCurrentFrame()

    -- change x and y as needed
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- move bullet if bullet fired
    if self.bullet_fired then
        if not self.map:collides(self) and self.bulletX < self.map.mapWidth then
            self.bulletX = self.bulletX + self.bulletDx
        else
            self.bullet_fired = false
            self.bulletX = self.x + self.width / 2
            self.bulletY = self.y + self.height / 2 + 5
        end
    -- else stay with ship
    else
        self.bulletX = self.x + self.width / 2
        self.bulletY = self.y + self.height / 2 + 5
    end
end

function Ship:render()
    -- color scheme determined by behavior
    love.graphics.setColor(self.color_scheme)
    -- render ship
    love.graphics.draw(self.spritesheet, self.current_frame, math.floor(self.x + 0.5), math.floor(self.y + 0.5))

    -- render hp as mini ships in top left corner of screen
    if self.map.state == 'neutral' then
        for i = 1, self.hp do
            love.graphics.draw(self.spritesheet, self.current_frame, 20 * i - 10, 10, 0, 0.5, 0.5)
        end
    end

    -- render bullet when bullet fired
    if self.bullet_fired then
        love.graphics.setColor(BULLET_RED)
        love.graphics.circle('fill', self.bulletX, self.bulletY, 2.5)
    end
end


-- ====================================================================================================================
-- ====================================================================================================================
-- helper functions ===================================================================================================
-- ====================================================================================================================
-- ====================================================================================================================

--[[
-- check if ship collides at input coords
function Ship:collides(x, y)
    return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
end
--]]