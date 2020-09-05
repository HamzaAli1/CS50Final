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
    -- maximum number of levels TODO: change as needed
    self.max_level = 5
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
    self.RESTORE_HP_Y = self.mapHeight - 64

    -- table contains functions that inits each level, TODO adjust this
    self.init_level = {}
    for i = 1, self.max_level do
        self.init_level[i] = function()
            for j = 1, 3*i, 3 do
                self.enemies[j] = Enemy(self, 'xBlock', 1, math.random(self.mapWidth - 57, self.mapWidth), math.random(10, self.mapHeight - 54))
                self.enemies[j + 1] = Enemy(self, 'yBlock', 1, math.random(0, self.mapWidth), 0)
                self.enemies[j + 2] = Enemy(self, 'yBlock', 1, math.random(0, self.mapWidth), self.mapHeight - 54)
            end
        end
    end

    -- actions map:update takes depending on game state
    self.behaviors = {
        ['cutscene'] = function(dt)
            -- wait till ship moves out of sun
            if self.cutscene == 'opening' then
                if self.stars[#self.stars].x < 0 then
                    self.state = 'neutral'
                end
            -- wait till ship returns to starting position
            elseif self.cutscene == 'setup' then
                if self.ship.x < self.ship.DEFAULT_X then
                    self.state = 'neutral'
                end
            end -- TODO add more as needed

            -- update stars
            self:updateStars(dt)
            -- update ship
            self.ship:update(dt)
        end,
        ['neutral'] = function(dt)
            -- update enemies if game is active (player hp > 0)
            if self.ship.hp > 0 then
                if #self.enemies == 0 then
                    self.init_level[self.level]()
                else
                    for i = #self.enemies, 1, -1 do
                        if self.enemies[i].hp > 0 then
                            self.enemies[i]:update(dt)
                        else
                            table.remove(self.enemies, i)
                            if #self.enemies == 0 then self.state = 'complete' end
                        end
                    end
                end
            -- else signal game over
            else
                self.state = 'defeat'
            end

            -- update stars
            self:updateStars(dt)
            -- update ship
            self.ship:update(dt)
        end,
        ['complete'] = function(dt)
            -- if max level not reached, stay in complete state
            if self.level < self.max_level then
                -- between each level, allow player to choose an upgrade before the next level
                if self.ship.x + self.ship.width / 2 > self.POWERUP_X - self.POWERUP_R then
                    -- upgrades
                    if self.ship.y + self.ship.height > self.ATK_UP_Y - self.POWERUP_R and self.ship.y < self.ATK_UP_Y + self.POWERUP_R  then
                        -- atk up
                        self.ship.max_atk = self.ship.max_atk + 1
                    elseif self.ship.y + self.ship.height > self.HP_UP_Y - self.POWERUP_R and self.ship.y < self.HP_UP_Y + self.POWERUP_R then
                        -- hp up
                        self.ship.max_hp = self.ship.max_hp + 1
                    elseif self.ship.y + self.ship.height > self.RESTORE_HP_Y - self.POWERUP_R and self.ship.y < self.RESTORE_HP_Y + self.POWERUP_R then
                        -- restore hp
                        self.ship.hp = self.ship.max_hp
                    end
                    -- you can avoid touching any of the upgrades, making the game much harder

                    self.level = self.level + 1
                    self.state = 'cutscene'
                    self.cutscene = 'setup'
                end
            -- else to to victory screen
            else
                self.state = 'victory'
            end

            -- update stars
            self:updateStars(dt)
            -- update ship
            self.ship:update(dt)
        end,
        ['victory'] = function(dt)
            -- waiting for user to press key
        end,
        ['defeat'] = function(dt)
            self.enemies = {}
            -- waiting for user to press key
        end,
        ['title'] = function(dt)
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
                -- TODO add more as needed
            end
        end,
        ['neutral'] = function()

        end,
        ['complete'] = function()
            if self.level < self.max_level then
                -- make it clear that the level is complete
                love.graphics.setNewFont(16)
                love.graphics.setColor(WHITE)
                love.graphics.printf("Level " .. tostring(self.level) .. " Complete", 5, 15, self.mapWidth, 'center')

                -- render power ups; TODO replace with actual sprites
                -- atk up
                love.graphics.setColor(BULLET_RED)
                love.graphics.circle('fill', self.POWERUP_X, self.ATK_UP_Y, self.POWERUP_R)
                -- hp up
                love.graphics.setColor(SUN_YELLOW)
                love.graphics.circle('fill', self.POWERUP_X, self.HP_UP_Y, self.POWERUP_R)
                -- restore hp
                love.graphics.setColor(WHITE)
                love.graphics.circle('fill', self.POWERUP_X, self.RESTORE_HP_Y, self.POWERUP_R)
            end
        end,
        ['victory'] = function()
            -- victory screen TODO: change this eventually, its way too boring :)
            love.graphics.setColor(WHITE)
            love.graphics.setNewFont(32)
            love.graphics.printf("Congratulations, you won!", 2, self.mapHeight / 2 - 32, self.mapWidth, 'center')

            love.graphics.setNewFont(16)
            love.graphics.printf("Press enter to return to main menu", 5, self.mapHeight / 2 + 15, self.mapWidth, 'center')
        end,
        ['defeat'] = function()
            -- TODO ditto above
            love.graphics.setNewFont(32)
            love.graphics.setColor(BULLET_RED)
            love.graphics.printf("GAME OVER", 5, self.mapHeight / 2 - 32, self.mapWidth, 'center')

            love.graphics.setNewFont(16)
            love.graphics.printf("Press enter to return to main menu", 5, self.mapHeight / 2 + 10, self.mapWidth, 'center')
        end,
        ['title'] = function()
            love.graphics.setColor(SUN_YELLOW)
            love.graphics.setNewFont(48)
            love.graphics.printf("SUN PIERCER", 5, self.mapHeight / 2 - 48, self.mapWidth, 'center')  -- TODO, come up with cool title

            love.graphics.setNewFont(16)
            love.graphics.printf("Press enter to start", 5, self.mapHeight / 2 + 10, self.mapWidth, 'center')
        end
    }

    self:initStars()
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