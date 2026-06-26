--[[
    CS50 2D
    Angry Birds

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

AlienLaunchMarker = Class{}

function AlienLaunchMarker:init(world)
    self.world = world

    -- starting coordinates for launcher used to calculate launch vector
    self.baseX = 90
    self.baseY = VIRTUAL_HEIGHT - 100

    -- shifted coordinates when clicking and dragging launch alien
    self.shiftedX = self.baseX
    self.shiftedY = self.baseY

    -- whether our arrow is showing where we're aiming
    self.aiming = false

    -- whether we launched the alien and should stop rendering the preview
    self.launched = false

    -- our alien we will eventually spawn
    self.alien = nil
    self.aliens = {}
    self.split = false
    self.collided = false
end

function AlienLaunchMarker:update(dt)
    
    -- perform everything here as long as we haven't launched yet
    if not self.launched then

        -- grab mouse coordinates
        local x, y = push.toGame(love.mouse.getPosition())
        
        -- if we click the mouse and haven't launched, show arrow preview
        if love.mouse.wasPressed(1) and not self.launched then
            self.aiming = true

        -- if we release the mouse, launch an Alien
        elseif love.mouse.wasReleased(1) and self.aiming then
            self.launched = true

            -- spawn new alien in the world, passing in user data of player
            self.alien = self:spawnAlien(self.shiftedX, self.shiftedY,
                (self.baseX - self.shiftedX) * 10,
                (self.baseY - self.shiftedY) * 10)
            
            table.insert(self.aliens, self.alien)

            -- we're no longer aiming
            self.aiming = false

        -- re-render trajectory
        elseif self.aiming then
            
            self.shiftedX = math.min(self.baseX + 30, math.max(x, self.baseX - 30))
            self.shiftedY = math.min(self.baseY + 30, math.max(y, self.baseY - 30))
        end
    -- Split on space press
    elseif love.keyboard.wasPressed('space') and not self.collided and not self.split then
        self:splitAlien()
    end
end

function AlienLaunchMarker:render()
    if not self.launched then
        
        -- render base alien, non physics based
        love.graphics.draw(gTextures['aliens'], gFrames['aliens'][9], 
            self.shiftedX - 17.5, self.shiftedY - 17.5)

        if self.aiming then
            
            -- render arrow if we're aiming, with transparency based on slingshot distance
            local impulseX = (self.baseX - self.shiftedX) * 10
            local impulseY = (self.baseY - self.shiftedY) * 10

            -- draw 18 circles simulating trajectory of estimated impulse
            local trajX, trajY = self.shiftedX, self.shiftedY
            local gravX, gravY = self.world:getGravity()

            -- http://www.iforce2d.net/b2dtut/projected-trajectory
            for i = 1, 90 do
                
                -- magenta color that starts off slightly transparent
                love.graphics.setColor(255/255, 80/255, 255/255, ((255 / 24) * i) / 255)
                
                -- trajectory X and Y for this iteration of the simulation
                trajX = self.shiftedX + i * 1/60 * impulseX
                trajY = self.shiftedY + i * 1/60 * impulseY + 0.5 * (i * i + i) * gravY * 1/60 * 1/60

                -- render every fifth calculation as a circle
                if i % 5 == 0 then
                    love.graphics.circle('fill', trajX, trajY, 3)
                end
            end
        end
        
        love.graphics.setColor(1, 1, 1, 1)
    else
        for _, alien in pairs(self.aliens) do
            if not alien.body:isDestroyed() then
                alien:render()
            end
        end
    end
end

function AlienLaunchMarker:spawnAlien(x, y, velocityX, velocityY)
    local alien = Alien(self.world, 'round', x, y, 'Player')
    alien.body:setLinearVelocity(velocityX, velocityY)
    alien.fixture:setRestitution(0.4)
    alien.body:setAngularDamping(1)
    -- mask alien so it does not collide with the other aliens
    alien.fixture:setFilterData(1, 65535, -1)
    return alien
end

function AlienLaunchMarker:splitAlien()
    local x, y = self.alien.body:getPosition()
    local velocityX, velocityY = self.alien.body:getLinearVelocity()

    local splitAngle = math.rad(20)
    local sin, cos = math.sin(splitAngle), math.cos(splitAngle)
    -- Create two new aliens with linar velocity for an angle of 30
    local alienUp = self:spawnAlien(x, y - ALIEN_SIZE,
        velocityX,
        velocityX * sin + velocityY * cos)
    local alienDown = self:spawnAlien(x, y + ALIEN_SIZE,
        velocityX,
        -velocityX * sin + velocityY * cos)
    -- Insert new aliens in table
    table.insert(self.aliens, alienUp)
    table.insert(self.aliens, alienDown)
    self.split = true
end