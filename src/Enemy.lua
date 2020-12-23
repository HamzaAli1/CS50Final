--[[
    renders and different types of enemies depending on constructor
--]]

Enemy = Class{}

function Enemy:init(map, type, diff, x, y)
    -- reference to map to determine position and game state
    self.map = map
    self.x = x
    self.y = y
    
    -- enemy type and difficulty
    self.type = type
    self.diff = diff

    -- speed
    self.dx = 0
    self.dy = 0
    self.color_scheme = {WHITE[1], WHITE[2], WHITE[3], WHITE[4]}

    -- init vars based on type
    if type == 'xBlock' or type == 'yBlock' then
        -- load in sprite sheet
        self.spritesheet = love.graphics.newImage('res/temp_ship.png')  -- TODO change depending on enemy type

        -- instantiate other class variables
        self.ENEMY_SPEED = 50 + (25 * self.diff)
        self.sprite_width = 47
        self.sprite_height = 44

        self.width = self.sprite_width
        self.height = self.sprite_height
        self.offset = self.width
    
        -- hp vars
        self.max_hp = 5 + (5 * self.diff)
        self.hp = self.max_hp
        self.hit = false
    elseif type == 'bigBlock' then
        -- load in sprite sheet
        self.spritesheet = love.graphics.newImage('res/temp_ship.png')  -- TODO change depending on enemy type

        -- instantiate other class variables
        self.ENEMY_SPEED = 10 + (10 * self.diff)
        self.sprite_width = 47
        self.sprite_height = 44

        self.width = self.sprite_width * 2
        self.height = self.sprite_height * 2
        self.offset = self.width / 2
    
        -- hp vars
        self.max_hp = 25 + (25 * self.diff)
        self.hp = self.max_hp
        self.hit = false
        self.max_invulnerableFrames = 50
        self.invulnerableFrames = self.max_invulnerableFrames
    elseif type == 'sun' then
        -- load in sprite sheet
        self.spritesheet = love.graphics.newImage('res/temp_ship.png')  -- TODO change depending on enemy type

        -- instantiate other class variables
        self.ENEMY_SPEED = 0
        self.sprite_width = 47
        self.sprite_height = 44

        self.width = self.sprite_width * 5
        self.height = self.sprite_height * 5
        self.offset = self.width / 5
    
        -- hp vars
        self.max_hp = 100 + (100 * self.diff)
        self.hp = self.max_hp
        self.hit = false
        self.max_invulnerableFrames = 50
        self.invulnerableFrames = self.max_invulnerableFrames

        -- vars associated with bullet
        self.bulletX = self.x + self.width / 2
        self.bulletY = self.y + self.height / 2
        self.bulletDx = 0
        self.bulletDy = 0
        self.bullet_r = 10

        self.bullet_fired = false
        self.bullet_atk = 1 + self.diff
        self.bullet_spd = -5 - (5 * self.diff)
        self.bullet_type = 'straight'
        self.max_reloadFrames = 25
        self.reloadFrames = 0
    end

    -- TODO: replace this with an actual animation based on type, diff, etc.
    -- create animation table
    self.animations = {
        ['neutral'] = Animation{
            texture = self.spritesheet,
            frames = {
                love.graphics.newQuad(202, 2, self.sprite_width, self.sprite_height, self.spritesheet:getDimensions())
            }
        }, 
        ['cutscene'] = Animation{
            texture = self.spritesheet,
            frames = {
                love.graphics.newQuad(202, 2, self.sprite_width, self.sprite_height, self.spritesheet:getDimensions())
            }
        }, 
        ['complete'] = Animation{
            texture = self.spritesheet,
            frames = {
                love.graphics.newQuad(202, 2, self.sprite_width, self.sprite_height, self.spritesheet:getDimensions())
            }
        }
    }
    self.animation = self.animations[self.map.state]
    self.current_frame = self.animation:getCurrentFrame()

    -- create behavior table
    self.behaviors = {
        ['xBlock'] = function(dt)
            if not self.hit then
                -- float towards ship, more velocity in x direction
                if self.x + self.width / 2 > self.map.ship.x + self.map.ship.width and self.x > 0 then
                    self.dx = -self.ENEMY_SPEED
                elseif self.x + self.width / 2 < self.map.ship.x and self.x < map.mapWidth - self.width then
                    self.dx = self.ENEMY_SPEED
                else
                    self.dx = 0
                end
                if self.y + self.height / 2 > self.map.ship.y + self.map.ship.height and self.y > 0 then
                    self.dy = -self.ENEMY_SPEED / 2
                elseif self.y + self.height / 2 < self.map.ship.y and self.y < map.mapHeight - self.height then
                    self.dy = self.ENEMY_SPEED / 2
                else
                    self.dy = 0
                end
            else
                -- if hit flee from ship
                if self:distanceTo(self.map.ship) < 200 then
                    self.dx = (self.map.ship.x >= self.map.mapWidth - self.map.ship.x) and -self.ENEMY_SPEED * 3 or self.ENEMY_SPEED * 3
                    self.dy = (self.map.ship.y >= self.map.mapHeight - self.map.ship.y) and -self.ENEMY_SPEED * 3 or self.ENEMY_SPEED * 3
                else
                    self.hit = false
                end
            end

            -- check if touching ship
            if self.map:collides(self) then
                -- stop, and let ship move away
                self.dx = 0
                self.dy = 0

                self.sound_bullet:stop()
                self.sound_bullet:play()
            end
        end,
        ['yBlock'] = function(dt)
            if not self.hit then
                -- float towards ship, more velocity in y direction
                if self.x + self.width / 2 > self.map.ship.x + self.map.ship.width and self.x > 0 then
                    self.dx = -self.ENEMY_SPEED / 2
                elseif self.x + self.width / 2 < self.map.ship.x and self.x < map.mapWidth - self.width then
                    self.dx = self.ENEMY_SPEED / 2
                else
                    self.dx = 0
                end
                if self.y + self.height / 2 > self.map.ship.y + self.map.ship.height and self.y > 0 then
                    self.dy = -self.ENEMY_SPEED
                elseif self.y + self.height / 2 < self.map.ship.y and self.y < map.mapHeight - self.height then
                    self.dy = self.ENEMY_SPEED
                else
                    self.dy = 0
                end
            else
                -- if hit flee from ship
                if self:distanceTo(self.map.ship) < 200 then
                    self.dx = (self.map.ship.x >= self.map.mapWidth - self.map.ship.x) and -self.ENEMY_SPEED * 3 or self.ENEMY_SPEED * 3
                    self.dy = (self.map.ship.y >= self.map.mapHeight - self.map.ship.y) and -self.ENEMY_SPEED * 3 or self.ENEMY_SPEED * 3
                else
                    self.hit = false
                end
            end

            -- check if touching ship
            if self.map:collides(self) then
                -- stop, and let ship move away
                self.dx = 0
                self.dy = 0

                self.sound_bullet:stop()
                self.sound_bullet:play()
            end
        end,
        ['bigBlock'] = function(dt)
            if not self.hit then
                -- float towards ship, more velocity in y direction
                if self.x + self.width / 2 > self.map.ship.x + self.map.ship.width and self.x > 0 then
                    self.dx = -self.ENEMY_SPEED
                elseif self.x + self.width / 2 < self.map.ship.x and self.x < map.mapWidth - self.width then
                    self.dx = self.ENEMY_SPEED
                else
                    self.dx = 0
                end
                if self.y + self.height / 2 > self.map.ship.y + self.map.ship.height and self.y > 0 then
                    self.dy = -self.ENEMY_SPEED
                elseif self.y + self.height / 2 < self.map.ship.y and self.y < map.mapHeight - self.height then
                    self.dy = self.ENEMY_SPEED
                else
                    self.dy = 0
                end
            else
                -- if invulnerablity frames done, hit becomes false
                if self.invulnerableFrames == 0 then
                    self.invulnerableFrames = self.max_invulnerableFrames
                    self.hit = false
                    self.color_scheme[4] = 1
                -- else decrease invulnerability frame count
                else
                    self.invulnerableFrames = self.invulnerableFrames - 1
                    self.color_scheme[4] = self.invulnerableFrames % 2
                end
            end

            -- check if touching ship
            if self.map:collides(self) then
                -- stop, and let ship move away
                self.dx = 0
                self.dy = 0

                self.sound_bullet:stop()
                self.sound_bullet:play()
            end
        end,
        ['sun'] = function(dt)
            if self.hit then
                -- if invulnerablity frames done, hit becomes false
                if self.invulnerableFrames == 0 then
                    self.invulnerableFrames = self.max_invulnerableFrames
                    self.hit = false
                    self.color_scheme[4] = 1
                -- else decrease invulnerability frame count
                else
                    self.invulnerableFrames = self.invulnerableFrames - 1
                    self.color_scheme[4] = self.invulnerableFrames % 2
                end
            end
            
            -- perform attacks if not touching ship (if touching, ship will take damage)
            if not self.map:collides(self) then

                -- boss actions, 50% of spawning an enemy if possible, 50% chance of firing a projectile
                rand_num = math.random(10);
                num_enemies = #self.map.enemies

                -- bullet
                if not self.bullet_fired then
                    self.bulletY = self.map.ship.y
                end
                if rand_num == 10 and not self.bullet_fired and self.reloadFrames == 0 then
                    -- 10% chance to fire homing projectile
                    self.bullet_fired = true
                    self.bullet_type = 'homing'
                    self.bulletDx = self.bullet_spd
                    self.bulletDy = self.bullet_spd

                    self.sound_bullet:stop()
                    self.sound_bullet:play()
                elseif (rand_num == 8 or rand_num == 9) and not self.bullet_fired and self.reloadFrames == 0 then
                    -- 20% chance of firing a randomly curving projectile
                    self.bullet_fired = true
                    self.bullet_type = 'curving'
                    self.bulletDx = self.bullet_spd
                    self.sound_bullet:play()
                elseif (rand_num > 5 and rand_num < 8) and not self.bullet_fired and self.reloadFrames == 0 then
                    -- 20% chance of firing a straight projectile
                    self.bullet_fired = true
                    self.bullet_type = 'straight'
                    self.bulletDx = self.bullet_spd
                    self.bulletDy = 0
                    
                    self.sound_bullet:stop()
                    self.sound_bullet:play()

                -- spawn
                elseif num_enemies < self.map.level / 2 + 1 and rand_num <= math.min(self.diff, 2) then
                    -- spawn miniboss, percent dependant on diff, caps at 20%
                    self.map:spawn('bigBlock', diff)
                elseif num_enemies < self.map.level / 2 then
                    -- spawn enemies if nothing else, but only if number of enemies less than level / 2
                    for i = 1, self.diff + 1 do
                        if math.random() < 0.5 then
                            self.map:spawn('xBlock', diff)
                        else
                            self.map:spawn('yBlock', diff)
                        end
                    end
                end

            end
        end
    }

    -- sound effects
    self.sound_bullet = love.audio.newSource('res/bossbullet.wav', 'static')
end

function Enemy:update(dt)
    -- sprite becomes more red as hp goes down
    self.color_scheme[2] = WHITE[2] * self.hp / self.max_hp
    self.color_scheme[3] = WHITE[3] * self.hp / self.max_hp
    self.color_scheme[4] = (self.hit) and 0.25 or WHITE[4]

    -- run behavior function based on map state and type
    if self.map.state == 'neutral' then
        self.behaviors[self.type](dt)
    end

    -- update bullet if needed (only for sun boss)
    if self.type == 'sun' then
        if self.bullet_fired then
            if not self.map:collides(self) and self:bulletWithinBounds() then
                -- change dircetion based on bullet type
                if self.bullet_type == 'homing' then
                    if self.bulletY - self.bullet_r < self.map.ship.y then
                        self.bulletDy = self.bullet_spd
                    elseif self.bulletY + self.bullet_r > self.map.ship.y then
                        self.bulletDy = -self.bullet_spd
                    else
                        self.bulletDy = 0
                    end
                elseif self.bullet_type == 'curving' then
                    rand = math.random()
                    if rand < 0.5 then
                        self.bulletDy = self.bullet_spd
                    elseif rand > 0.5 then
                        self.bulletDy = -self.bullet_spd
                    else
                        self.bulletDy = 0
                    end
                end

                self.bulletX = self.bulletX + self.bulletDx
                self.bulletY = self.bulletY + self.bulletDy
            elseif not self:bulletWithinBounds() then
                self.bullet_fired = false
                self.bulletX = self.x + self.width / 2
                self.bulletY = self.y + self.height / 2 + 5
                -- only start reload frames if bullet hit ship
                if self:bulletWithinBounds() then
                    self.reloadFrames = self.max_reloadFrames
                end
            end
        -- else stay with ship
        else
            self.bulletX = self.x + self.width / 2
            self.bulletY = self.y + self.height / 2
            -- reduce reload frames if > 0
            self.reloadFrames = math.max(0, self.reloadFrames - 1)
        end
    end

    -- update animation
    self.animation:update(dt)
    self.current_frame = self.animation:getCurrentFrame()

    -- change x and y as needed
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Enemy:render()
    -- debug
    --[[
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle('line', math.floor(self.x), math.floor(self.y), self.width, self.height, 0, 0, 1)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setNewFont(10)
    love.graphics.print("diff = " .. tostring(self.diff), math.floor(self.x), math.floor(self.y) - 10)
    love.graphics.print("x = " .. tostring(math.floor(self.x)) .. '; y = ' .. tostring(math.floor(self.y)), math.floor(self.x), math.floor(self.y) - 20)
    love.graphics.print("dx = " .. tostring(self.dx) .. '; dy = ' .. tostring(self.dy), math.floor(self.x), math.floor(self.y) - 30)
    love.graphics.print("Hit? = " .. tostring(self.hit), math.floor(self.x), math.floor(self.y) - 40)
    love.graphics.print("hp = " .. tostring(self.hp), math.floor(self.x), math.floor(self.y) - 50)
    --]]

    love.graphics.setColor(self.color_scheme)
    love.graphics.draw(self.spritesheet, self.current_frame, math.floor(self.x), math.floor(self.y), 0, (-self.width / self.sprite_width), (self.height / self.sprite_height), self.offset, 0)

    -- render bullet when bullet fired
    if self.type == 'sun' and self.bullet_fired then
        love.graphics.setColor(BULLET_RED)
        love.graphics.circle('fill', self.bulletX, self.bulletY, self.bullet_r)
    end
end


-- ====================================================================================================================
-- ====================================================================================================================
-- helper functions ===================================================================================================
-- ====================================================================================================================
-- ====================================================================================================================

-- check if enemy collides at input coords
function Enemy:collides(x, y)
    -- sun boss needs to check if ship is hitting bullet
    hit_bullet = false;
    if self.type == 'sun' and self.bullet_fired then
        hit_bullet = x >= self.bulletX - self.bullet_r and x <= self.bulletX + self.bullet_r and y >= self.bulletY - self.bullet_r and y <= self.bulletY + self.bullet_r
    end
    return hit_bullet or x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
end

-- calculate distance to obj
function Enemy:distanceTo(obj)
    return math.sqrt(math.pow((self.x + self.width / 2) - (obj.x + obj.width / 2), 2) + math.pow((self.y + self.height / 2) - (obj.y + self.height / 2), 2))
end

-- determine if the bullet is within bounds
function Enemy:bulletWithinBounds()
    return self.bulletX > 0 and self.bulletX + self.bullet_r < self.map.mapWidth and self.bulletY > 0 and self.bulletY + self.bullet_r < self.map.mapHeight
end