--[[
    Renders background, and inits players and all enemies
--]]

Map = Class{}

function Map:init(w, h)
    self.mapWidth = w
    self.mapHeight = h

    -- contains info on stars that make up background
    starSpeed = 200
    stars = {}
    atStarLimit = false

    -- init player ship
    self.ship = Ship(self)

    -- used to determine which cutscene to play
    self.cutscene = 'opening'
end

function Map:update(dt)
    -- update stars
    self:updateStars(dt)

    -- can't control ship till cutscene' is complete
    if atStarLimit then
        self.ship.state = 'neutral'
    end

    self.ship:update(dt)
end

function Map:render()
    love.graphics.clear(0, 0, 1, 0.25)

    -- draw stars
    for i = 1, #stars do
        love.graphics.circle('fill', math.floor(stars[i].x), math.floor(stars[i].y), 1)
    end

    if not atStarLimit then
        -- renders sun over area w/o stars till all stars generated
        for i = stars[1].x, 1, -1 do
            gray = (stars[1].x - i) / self.mapWidth
            love.graphics.setColor(gray * 3, gray * 2, gray, 1)
            love.graphics.rectangle('fill', 0, 0, i - 1, self.mapHeight)
        end
    end

    -- render ship
    self.ship:render()
end


-- ====================================================================================================================
-- ====================================================================================================================
-- helper functions ===================================================================================================
-- ====================================================================================================================
-- ====================================================================================================================


function Map:updateStars(dt)
    -- move all stars forward
    for i = 1, #stars do
        -- move any stars that goe past screen back to start of screen; 
        -- also sets star limit flag to true, preventing any more stars from spawning
        if stars[i].x < 0 then
            stars[i].x, stars[i].y = self.mapWidth, math.random(self.mapHeight)
            atStarLimit = true
        else
            stars[i].x = stars[i].x - starSpeed * dt
        end
    end
    -- add addtional stars at beginning of screen
    if not atStarLimit then
        table.insert(stars, {
            x = self.mapWidth,
            y = math.random(self.mapHeight)
        })
    end
end