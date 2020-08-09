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
    self.hit = false

    -- TODO: replace this with an actual animation
    -- create animation table
    self.animations = {
        ['neutral'] = Animation{
            texture = self.spritesheet,
            frames = {
                love.graphics.newQuad(202, 2, self.width, self.height, self.spritesheet:getDimensions())
            }
        }, 
        ['cutscene'] = Animation{
            texture = self.spritesheet,
            frames = {
                love.graphics.newQuad(202, 2, self.width, self.height, self.spritesheet:getDimensions())
            }
        }, 
        ['complete'] = Animation{
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
            if not self.hit then
                -- float towards ship
                if self.x + self.width / 2 > self.map.ship.x - self.map.ship.width / 2 and self.x > 0 then
                    self.dx = -ENEMY_SPEED
                elseif self.x + self.width / 2 < self.map.ship.x - self.map.ship.width / 2 and self.x < map.mapWidth - self.width then
                    self.dx = ENEMY_SPEED
                end
                if self.y + self.height / 2 > self.map.ship.y + self.map.ship.height / 2 and self.y > 0 then
                    self.dy = -ENEMY_SPEED / 5
                elseif self.y + self.height / 2 < self.map.ship.y + self.map.ship.height / 2 and self.y < map.mapHeight - self.height then
                    self.dy = ENEMY_SPEED / 5
                end
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

    -- if hit flee from ship
    if self.hit then
        if self:distanceTo(self.map.ship) < 200 then
            self.dx = (self.map.ship.x > self.map.mapWidth - self.map.ship.x) and -ENEMY_SPEED * 2 or ENEMY_SPEED * 2
            self.dy = (self.map.ship.y > self.map.mapHeight - self.map.ship.y) and -ENEMY_SPEED * 2 or ENEMY_SPEED * 2
        else
            self.hit = false
        end
    end

    -- change x and y as needed
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

end

function Enemy:render()
    self.color_scheme = {1, self.hp / 5, self.hp / 5, 1}
    love.graphics.setColor(self.color_scheme)
    love.graphics.draw(self.spritesheet, self.current_frame, self.x, self.y, 0, -1, 1, self.width, 0)

    --[[
    -- debug
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setNewFont(10)
    love.graphics.print("Enemy coords: x = " .. tostring(math.floor(self.x)) .. '; y = ' .. tostring(math.floor(self.y)), 20, 70)
    love.graphics.print("Enemy velocity: dx = " .. tostring(self.dx) .. '; dy = ' .. tostring(self.dy), 20, 80)
    love.graphics.print("Hit? = " .. tostring(self.hit), 20, 90)
    --]]
end

function Enemy:collides(x, y)
    return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
end

function Enemy:distanceTo(obj)
    return math.sqrt(math.pow(self.x - obj.x, 2) + math.pow(self.y - obj.y, 2))
end