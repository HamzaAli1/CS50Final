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
    self.state = 'cutscene'
    -- tracks current level
    self.level = 1
    -- maximum number of levels TODO: change as needed
    self.max_level = 6
    -- used to determine which cutscene to play, if any
    self.cutscene = 'opening'

    -- init player ship
    self.ship = Ship(self)

    -- contains all enemies currently on the map
    self.enemies = {}

    -- table contains functions that inits each level, TODO adjust this
    self.init_level = {}
    for i = 1, self.max_level / 2 do
        self.init_level[i] = function()
            for j = 1, i do
                self.enemies[j] = Enemy(self, 'block', 1, math.random(self.mapWidth - 57, self.mapWidth), math.random(10, self.mapHeight - 54))
            end
        end
    end
    for i = self.max_level / 2 + 1, self.max_level do
        self.init_level[i] = function()
            for j = 1, i * 2, 2 do
                self.enemies[j] = Enemy(self, 'block', 1, math.random(self.mapWidth - 57, self.mapWidth), math.random(10, self.mapHeight - 54))
                self.enemies[j + 1] = Enemy(self, 'block', 2, math.random(self.mapWidth - 57, self.mapWidth), math.random(10, self.mapHeight - 54))
            end
        end
    end

    -- actions map:update takes depending on game state
    self.behaviors = {
        ['cutscene'] = function(dt)
            if self.cutscene == 'opening' and self.ship.x >= 100 then
                self.state = 'neutral'
            end -- TODO add moe as needed
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
        end,
        ['complete'] = function(dt)
            if self.level < self.max_level then
                self.level = self.level + 1
                self.state = 'neutral'
            else
                self.state = 'victory'  -- TODO do something once you reach this
            end
        end,
        ['victory'] = function(dt)
        end,
        ['defeat'] = function(dt)
            self.enemies = {}
        end
    }

    -- actions map:render takes depending on game state
    self.renderState = {
        ['cutscene'] = function()
            if self.cutscene == 'opening' and self.ship.x < 100 then
                -- renders sun
                for i = self.stars[1].x, 1, -1 do
                    gray = (self.stars[1].x - i) / self.mapWidth
                    love.graphics.setColor(gray * 3, gray * 2, gray, 1)
                    love.graphics.rectangle('fill', 0, 0, i - 1, self.mapHeight)
                end
                -- TODO add more as needed
            end
        end,
        ['neutral'] = function()
        end,
        ['complete'] = function()
        end,
        ['victory'] = function()
            -- victory screen TODO: change this eventually, its way too boring :)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print("Congratulations, you won! Press escape to quit.", 10, 10)
        end,
        ['defeat'] = function()
            -- TODO ditto above
            love.graphics.clear(0, 0, 0, 0)
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.print("GAME OVER", self.mapWidth / 2 - 30, self.mapHeight / 2 - 2)
        end
    }

    self:initStars(1)
end

function Map:update(dt)
    -- update stars
    self:updateStars(dt)

    -- perform actions depending on game state
    self.behaviors[self.state](dt)

    -- update ship
    self.ship:update(dt)
end

function Map:render()
    -- dark blue/black background
    love.graphics.clear(0, 0, 1, 0.25)

    -- draw stars
    for i = 1, #self.stars do
        love.graphics.circle('fill', math.floor(self.stars[i].x), math.floor(self.stars[i].y), 1)
    end

    -- render other things based on game state
    self.renderState[self.state]()

    -- render ship
    self.ship:render()

    -- render any enemies
    if #self.enemies > 0 then
        for i = 1, #self.enemies do
            self.enemies[i]:render()
        end
    end
end


-- ====================================================================================================================
-- ====================================================================================================================
-- helper functions ===================================================================================================
-- ====================================================================================================================
-- ====================================================================================================================

function Map:initStars(dt)
    repeat
        -- add additional stars at beginning of screen
        table.insert(self.stars, {
            x = self.mapWidth,
            y = math.random(self.mapHeight)
        })
        -- move all stars forward
        for i = 1, #self.stars do
            self.stars[i].x = self.stars[i].x - self.starSpeed / 20 * dt
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
                self.enemies[i].hp = self.enemies[i].hp - 1
                self.enemies[i].hit = true
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