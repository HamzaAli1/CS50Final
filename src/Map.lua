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
    self.level = 0
    -- used to determine which cutscene to play, if any
    self.cutscene = 'opening'

    -- init player ship
    self.ship = Ship(self)

    -- contains all enemies currently on the map
    self.enemies = {}

    -- table contains functions that inits each level
    self.init_level = {
        [1] = function()
            self.enemies[1] = Enemy(self, 'block', 1, self.mapWidth - 57, math.random(10, self.mapHeight - 54))
        end
    }
end

function Map:update(dt)
    -- update stars
    self:updateStars(dt)

    -- can't control ship till cutscene is complete
    if self.atStarLimit then
        self.level = 1
        self.state = 'neutral'
    end
    self.ship:update(dt)

    -- generate or update enemies as needed
    if #self.enemies == 0 and self.level > 0 then
        self.init_level[self.level]()
    else
        for i = 1, #self.enemies do
            self.enemies[i]:update(dt)
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