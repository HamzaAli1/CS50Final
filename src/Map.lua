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
    self.atStarLimit = false

    -- map controls states of all other entities
    self.state = 'cutscene'
    -- tracks current level
    self.level = 1
    -- maximum number of levels TODO: change as needed
    self.max_level = 10
    -- used to determine which cutscene to play, if any
    self.cutscene = 'opening'

    -- init player ship
    self.ship = Ship(self)

    -- contains all enemies currently on the map
    self.enemies = {}

    -- table contains functions that inits each level
    self.init_level = {}
    for i = 1, self.max_level do
        self.init_level[i] = function()
            for j = 1, i do
                self.enemies[j] = Enemy(self, 'block', 1, math.random(self.mapWidth - 57, self.mapWidth), math.random(10, self.mapHeight - 54))
            end
        end
    end
end

function Map:update(dt)
    -- update stars
    self:updateStars(dt)

    -- can't control ship till cutscene is complete
    if self.atStarLimit and self.state == 'cutscene' then
        self.state = 'neutral'
    end
    self.ship:update(dt)

    -- generate or update enemies as needed
    if self.state == 'neutral' then
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
    -- if level complete
    elseif self.state == 'complete' then
        if self.level < self.max_level then
            self.level = self.level + 1
            self.state = 'neutral'
        else
            self.state = 'victory'  -- TODO do something once you reach this
        end
    end
end

function Map:render()
    love.graphics.clear(0, 0, 1, 0.25)

    -- draw stars
    for i = 1, #self.stars do
        love.graphics.circle('fill', math.floor(self.stars[i].x), math.floor(self.stars[i].y), 1)
    end

    if not self.atStarLimit then
        -- renders sun over area w/o stars till all stars generated
        for i = self.stars[1].x, 1, -1 do
            gray = (self.stars[1].x - i) / self.mapWidth
            love.graphics.setColor(gray * 3, gray * 2, gray, 1)
            love.graphics.rectangle('fill', 0, 0, i - 1, self.mapHeight)
        end
    end

    -- render ship
    self.ship:render()

    -- render enemies
    if #self.enemies > 0 then
        for i = 1, #self.enemies do
            self.enemies[i]:render()
        end
    end

    -- victory screen TODO: change this eventually, its way too boring :)
    if self.state == 'victory' then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Congratulations, you won! Press escape to quit.", 10, 10)
    end
end


-- ====================================================================================================================
-- ====================================================================================================================
-- helper functions ===================================================================================================
-- ====================================================================================================================
-- ====================================================================================================================


function Map:updateStars(dt)
    -- move all stars forward
    for i = 1, #self.stars do
        -- move any stars that goe past screen back to start of screen; 
        -- also sets star limit flag to true, preventing any more stars from spawning
        if self.stars[i].x < 0 then
            self.stars[i].x, self.stars[i].y = self.mapWidth, math.random(self.mapHeight)
            self.atStarLimit = true
        else
            self.stars[i].x = self.stars[i].x - self.starSpeed * dt
        end
    end
    -- add addtional stars at beginning of screen
    if not self.atStarLimit then
        table.insert(self.stars, {
            x = self.mapWidth,
            y = math.random(self.mapHeight)
        })
    end
end

-- determines whether given object collides at given coords
function Map:collides(object, x, y)
    -- make sure coords are within screen
    if x > self.mapWidth or x < 0 or y > self.mapHeight or y < 0 then
        return true
    -- if checking bullet collision, iterate over enemies list
    elseif object == self.ship then
        for i = 1, #self.enemies do
            if self.enemies[i]:collides(x, y) and self.enemies[i].hit == false then
                self.enemies[i].hp = self.enemies[i].hp - 1
                self.enemies[i].hit = true
                return true
            end
        end
    -- if checking enemy bullet collision, check ship xy
    else
        if self.ship:collides(x, y) then
            self.ship.hp = self.ship.hp - 1
            return true
        end
    end
    return false
end