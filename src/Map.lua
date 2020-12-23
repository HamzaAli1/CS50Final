--[[
    Renders background, and inits players and all enemies
--]]

Map = Class{}

function Map:init(w, h)
    self.mapWidth = w
    self.mapHeight = h

    -- contains info on stars that make up background
    self.starSpeed = 200
    self.stars = {}

    -- map controls states of all other entities
    self.state = 'title'
    -- tracks current level
    self.level = 1
    -- used to determine which cutscene to play, if any
    self.cutscene = 'opening'

    -- init player ship
    self.ship = Ship(self)

    -- contains all enemies currently on the map
    self.enemies = {}

    -- power up constants
    self.POWERUP_X = self.mapWidth - 2 * self.ship.width
    self.POWERUP_R = 16
    self.ATK_UP_Y = 64
    self.HP_UP_Y = self.mapHeight / 2
    self.SPD_UP_Y = self.mapHeight - 64

    -- actions map:update takes depending on game state
    self.behaviors = {
        ['cutscene'] = function(dt)
            -- wait till ship moves out of sun
            if self.cutscene == 'opening' then
                self.music_menu:stop()
                self.music_level:play()
                if self.stars[#self.stars].x < 0 then
                    self.state = 'neutral'
                end
            -- wait till ship returns to starting position
            elseif self.cutscene == 'setup' then
                if self.ship.x < self.ship.DEFAULT_X then
                    self.state = 'neutral'
                end
            end

            -- update stars
            self:updateStars(dt)
            -- update ship
            self.ship:update(dt)
        end,
        ['neutral'] = function(dt)
            -- update enemies if game is active (player hp > 0)
            if self.ship.hp > 0 then
                if #self.enemies == 0 then
                    -- init level
                    level_mod = self.level % 10  -- one's digit of level
                    diff = math.floor(self.level / 10)  -- ten's digit of level
                    if level_mod == 5 then
                        -- miniboss
                        self.music_level:stop()
                        self.music_boss:play()
                        for i = 1, self.level / 5 do
                            self.enemies[i] = Enemy(self, 'bigBlock', diff, self.mapWidth - 57 * 4, math.random(44, self.mapHeight - 44))
                        end
                    elseif level_mod == 0 then
                        -- boss
                        self.music_level:stop()
                        self.music_boss:play()
                        self.enemies[1] = Enemy(self, 'sun', diff - 1, self.mapWidth - 57 * 3, self.mapHeight / 2 - 115)
                    else
                        -- block enemies
                        self.music_level:play()
                        self.music_boss:stop()
                        for i = 1, self.level do
                            -- y block
                            if i % 2 == 0 then
                                if math.random() < 0.5 then
                                    self.enemies[i] = Enemy(self, 'yBlock', diff, math.random(self.mapWidth / 3, self.mapWidth), 0)
                                else
                                    self.enemies[i] = Enemy(self, 'yBlock', diff, math.random(self.mapWidth / 3, self.mapWidth), self.mapHeight - 54)
                                end
                            -- x block
                            else
                                self.enemies[i] = Enemy(self, 'xBlock', diff, math.random(self.mapWidth - 57, self.mapWidth), math.random(10, self.mapHeight - 54))
                            end
                        end
                    end
                else
                    -- update all enemies
                    for i = #self.enemies, 1, -1 do
                        if self.enemies[i].hp > 0 then
                            self.enemies[i]:update(dt)
                        else
                            self.sound_explosion:play()
                            table.remove(self.enemies, i)
                            if #self.enemies == 0 then 
                                self.state = 'complete'
                                self.sound_complete:play()
                            end  -- level complete
                        end
                    end
                end
            -- else signal game over
            else
                self.sound_explosion:play()
                self.state = 'defeat'
            end

            -- update stars
            self:updateStars(dt)
            -- update ship
            self.ship:update(dt)
        end,
        ['complete'] = function(dt)
            self.music_level:pause()
            self.music_boss:stop()
            -- between each level, allow player to choose an upgrade before the next level
            if self.ship.x + self.ship.width / 2 > self.POWERUP_X - self.POWERUP_R then
                -- upgrades
                if self.ship.y + self.ship.height > self.ATK_UP_Y - self.POWERUP_R and self.ship.y < self.ATK_UP_Y + self.POWERUP_R  then
                    -- atk up
                    self.ship.max_atk = self.ship.max_atk + 1
                elseif self.ship.y + self.ship.height > self.HP_UP_Y - self.POWERUP_R and self.ship.y < self.HP_UP_Y + self.POWERUP_R then
                    -- hp up
                    self.ship.max_hp = self.ship.max_hp + 1
                elseif self.ship.y + self.ship.height > self.SPD_UP_Y - self.POWERUP_R and self.ship.y < self.SPD_UP_Y + self.POWERUP_R then
                    -- increase speed
                    self.ship.speed = self.ship.speed + 10
                end
                -- you can avoid touching any of the upgrades, making the game much harder
                -- hp will be restored each round
                self.ship.hp = self.ship.max_hp

                self.level = self.level + 1
                self.state = 'cutscene'
                self.cutscene = 'setup'
            end

            -- update stars
            self:updateStars(dt)
            -- update ship
            self.ship:update(dt)
        end,
        ['defeat'] = function(dt)
            self.music_level:stop()
            self.music_boss:stop()

            self.enemies = {}
            self.music_end:play()
            -- waiting for user to press key
        end,
        ['title'] = function(dt)
            self.music_end:stop()
            self.music_menu:play()
            -- waiting for user to press key
        end
    }

    -- actions map:render takes depending on game state
    self.renderState = {
        ['cutscene'] = function()
            if self.cutscene == 'opening' then
                -- renders sun
                for i = self.stars[1].x, 0, -1 do
                    local brightness = (self.stars[1].x - i) / self.mapWidth
                    love.graphics.setColor(SUN_YELLOW[1], SUN_YELLOW[2], SUN_YELLOW[3], brightness)
                    love.graphics.circle('fill', -(self.mapWidth / 2) + 1 - (self.mapHeight - i), self.mapHeight / 2, self.mapWidth)
                end
            end
        end,
        ['neutral'] = function()

        end,
        ['complete'] = function()
            -- make it clear that the level is complete
            love.graphics.setNewFont(16)
            love.graphics.setColor(WHITE)
            love.graphics.printf("Level " .. tostring(self.level) .. " Complete", 5, 15, self.mapWidth, 'center')

            -- render power ups
            -- atk up
            love.graphics.setColor(BULLET_RED)
            love.graphics.circle('fill', self.POWERUP_X, self.ATK_UP_Y, self.POWERUP_R)

            love.graphics.setNewFont(16)
            love.graphics.setColor(SUN_YELLOW)
            love.graphics.print('ATK', self.POWERUP_X - self.POWERUP_R + 1, self.ATK_UP_Y - self.POWERUP_R / 2, 0, 1, 1, 1, 1)
            -- hp up
            love.graphics.setColor(SUN_YELLOW)
            love.graphics.circle('fill', self.POWERUP_X, self.HP_UP_Y, self.POWERUP_R)

            love.graphics.setNewFont(16)
            love.graphics.setColor(WHITE)
            love.graphics.print('HP', self.POWERUP_X - self.POWERUP_R + 5, self.HP_UP_Y - self.POWERUP_R / 2, 0, 1, 1, 1, 1)
            -- speed up
            love.graphics.setColor(WHITE)
            love.graphics.circle('fill', self.POWERUP_X, self.SPD_UP_Y, self.POWERUP_R)

            love.graphics.setNewFont(16)
            love.graphics.setColor(BULLET_RED)
            love.graphics.print('SPD', self.POWERUP_X - self.POWERUP_R + 1, self.SPD_UP_Y - self.POWERUP_R / 2, 0, 1, 1, 1, 1)
        end,
        ['defeat'] = function()
            love.graphics.setNewFont(32)
            love.graphics.setColor(BULLET_RED)
            love.graphics.printf("GAME OVER", 5, self.mapHeight / 2 - 32, self.mapWidth, 'center')

            love.graphics.setNewFont(16)
            love.graphics.printf("Press enter to return to main menu", 5, self.mapHeight / 2 + 10, self.mapWidth, 'center')
        end,
        ['title'] = function()
            love.graphics.setColor(SUN_YELLOW)
            love.graphics.setNewFont(48)
            love.graphics.printf("SUN PIERCER", 5, self.mapHeight / 2 - 48, self.mapWidth, 'center')

            love.graphics.setNewFont(16)
            love.graphics.printf("Press enter to start", 5, self.mapHeight / 2 + 10, self.mapWidth, 'center')
        end
    }

    self:initStars()

    self.music_menu = love.audio.newSource('res/MainTheme.wav', 'static')
    self.music_level = love.audio.newSource('res/LevelTheme.wav', 'static')
    self.music_end = love.audio.newSource('res/gameover.wav', 'static')
    self.music_boss = love.audio.newSource('res/boss.wav', 'static')

    self.sound_complete = love.audio.newSource('res/levelcomplete.wav', 'static')
    self.sound_explosion = love.audio.newSource('res/explode.wav', 'static')


    self.music_menu:setLooping(true)
    self.music_level:setLooping(true)
    self.music_end:setLooping(true)
    self.music_boss:setLooping(true)
end

function Map:update(dt)
    -- perform actions depending on game state
    self.behaviors[self.state](dt)
end

function Map:render()
    -- dark blue/black background
    love.graphics.clear(DARK_GRAY)

    -- draw stars
    love.graphics.setColor(WHITE)
    for i = 1, #self.stars do
        love.graphics.circle('fill', math.floor(self.stars[i].x), self.stars[i].y, 1)
    end

    -- render other things based on game state
    self.renderState[self.state]()

    -- render any enemies
    if #self.enemies > 0 then
        for i = 1, #self.enemies do
            self.enemies[i]:render()
        end
    end

    -- render ship
    self.ship:render()
end

-- resets map
function Map:reset()
    self.state = 'title'
    self.level = 1
    self.cutscene = 'opening'
    self.ship = Ship(self)
    self.enemies = {}
    self.stars = {}

    self:initStars()

end

-- ====================================================================================================================
-- ====================================================================================================================
-- helper functions ===================================================================================================
-- ====================================================================================================================
-- ====================================================================================================================

function Map:initStars()
    repeat
        -- add additional stars at beginning of screen
        table.insert(self.stars, {
            x = self.mapWidth,
            y = math.random(self.mapHeight)
        })
        -- move all stars forward
        for i = 1, #self.stars do
            self.stars[i].x = self.stars[i].x - self.starSpeed / 20
        end
    until self.stars[1].x < 0
end

function Map:updateStars(dt)
    for i = 1, #self.stars do
        -- move any stars that go past screen back to start of screen; 
        if self.stars[i].x < 0 then
            self.stars[i].x, self.stars[i].y = self.mapWidth, math.random(self.mapHeight)
        -- else move all stars forward
        else
            self.stars[i].x = self.stars[i].x - self.starSpeed * dt
        end
    end
end

-- determines whether given object collides with another object at given coords
function Map:collides(obj)
    -- if obj is ship, checking player bullet collision, iterate through enemies
    if obj == self.ship then
        for i = 1, #self.enemies do
            if self.enemies[i]:collides(obj.bulletX, obj.bulletY) and not self.enemies[i].hit then
                local temp = self.enemies[i].hp
                self.enemies[i].hp = math.max(self.enemies[i].hp - self.ship.atk, 0)
                self.enemies[i].hit = true
                self.ship.atk = math.max(self.ship.atk - temp, 0)
                return true
            end
        end
    -- if curr is enemy, checking enemy collision, use ship xy
    else
        if obj:collides(self.ship.x + self.ship.width / 2, self.ship.y + self.ship.height / 2) and not self.ship.hit then
            self.ship.hp = self.ship.hp - 1
            self.ship.hit = true
            return true
        end
    end
    return false
end

-- spawns an enemy; used by sun boss
function Map:spawn(type, diff)
    self.enemies[#self.enemies + 1] = Enemy(self, type, diff, self.mapWidth - 57 * 2, math.random(44, self.mapHeight - 44))
end