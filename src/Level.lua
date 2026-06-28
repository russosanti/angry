--[[
    CS50 2D
    Angry Birds

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Level = Class{}

function Level:init()
    
    -- create a new "world" (where physics take place), with no x gravity
    -- and 300 units of Y gravity (for downward force)
    self.world = love.physics.newWorld(0, 300)

    -- bodies we will destroy after the world update cycle; destroying these in the
    -- actual collision callbacks can cause stack overflow and other errors
    self.destroyedBodies = {}

    -- define collision callbacks for our world; the World object expects four,
    -- one for different stages of any given collision
    function beginContact(a, b, coll)
        local aType = type(a:getUserData()) == 'table' and a:getUserData().type or a:getUserData()
        local bType = type(b:getUserData()) == 'table' and b:getUserData().type or b:getUserData()

        local types = {
            [aType] = true,
            [bType] = true
        }

        if types['Player'] and not (aType == 'Player' and bType == 'Player') then
            self.launchMarker.collided = true
        end

        -- if we collided between both the player and an obstacle...
        if types['Obstacle'] and types['Player'] then

            -- grab the body that belongs to the player
            local playerFixture = aType == 'Player' and a or b
            local obstacleFixture = aType == 'Obstacle' and a or b
            
            -- destroy the obstacle if player's combined X/Y velocity is high enough
            local velX, velY = playerFixture:getBody():getLinearVelocity()
            local sumVel = math.abs(velX) + math.abs(velY)

            local obstacle = obstacleFixture:getUserData().entity
            if sumVel > (MATERIAL_DAMAGE_VELOCITY[obstacle.material] or 20) and obstacle:takeDamage(1) then
                table.insert(self.destroyedBodies, obstacle.body)
            end
        end

        -- if we collided between an obstacle and an alien, as by debris falling...
        if types['Obstacle'] and types['Alien'] then

            -- grab the body that belongs to the player
            local obstacleFixture = aType == 'Obstacle' and a or b
            local alienFixture = aType == 'Alien' and a or b

            -- destroy the alien if falling debris is falling fast enough
            local velX, velY = obstacleFixture:getBody():getLinearVelocity()
            local sumVel = math.abs(velX) + math.abs(velY)

            if sumVel > 20 then
                table.insert(self.destroyedBodies, alienFixture:getBody())
            end
        end

        -- if we collided between the player and the alien...
        if types['Player'] and types['Alien'] then

            -- grab the bodies that belong to the player and alien
            local playerFixture = aType == 'Player' and a or b
            local alienFixture = aType == 'Alien' and a or b

            -- destroy the alien if player is traveling fast enough
            local velX, velY = playerFixture:getBody():getLinearVelocity()
            local sumVel = math.abs(velX) + math.abs(velY)

            if sumVel > 20 then
                table.insert(self.destroyedBodies, alienFixture:getBody())
            end
        end

        -- glass hits ground
        if types['Obstacle'] and types['Ground'] then
            local obstacleFixture = aType == 'Obstacle' and a or b
            local obstacle = obstacleFixture:getUserData().entity
            local _, vel = obstacle.body:getLinearVelocity()

            if obstacle.material == 'glass' and  vel > 0 and obstacle:takeDamage(1) then
                table.insert(self.destroyedBodies, obstacle.body)
            end
        end

        -- if we hit the ground, play a bounce sound
        if types['Player'] and types['Ground'] then
            gSounds['bounce']:stop()
            gSounds['bounce']:play()
        end
    end

    -- the remaining three functions here are sample definitions, but we are not
    -- implementing any functionality with them in this demo; use-case specific
    -- http://www.iforce2d.net/b2dtut/collision-anatomy
    function endContact(a, b, coll)
        
    end

    function preSolve(a, b, coll)

    end

    function postSolve(a, b, coll, normalImpulse, tangentImpulse)

    end

    -- register just-defined functions as collision callbacks for world
    self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    -- shows alien before being launched and its trajectory arrow
    self.launchMarker = AlienLaunchMarker(self.world)

    -- aliens in our scene
    self.aliens = {}

    -- obstacles guarding aliens that we can destroy
    self.obstacles = {}

    -- simple edge shape to represent collision for ground
    self.edgeShape = love.physics.newEdgeShape(0, 0, VIRTUAL_WIDTH * 3, 0)

    -- spawn an alien to try and destroy
    table.insert(self.aliens, Alien(self.world, 'square', VIRTUAL_WIDTH - 80, VIRTUAL_HEIGHT - TILE_SIZE - ALIEN_SIZE / 2, 'Alien'))

    -- spawn a few obstacles
    table.insert(self.obstacles, Obstacle(self.world, 'vertical',
        VIRTUAL_WIDTH - 120, VIRTUAL_HEIGHT - 35 - 110 / 2, 'glass'))
    table.insert(self.obstacles, Obstacle(self.world, 'vertical',
        VIRTUAL_WIDTH - 35, VIRTUAL_HEIGHT - 35 - 110 / 2, 'metal'))
    table.insert(self.obstacles, Obstacle(self.world, 'horizontal',
        VIRTUAL_WIDTH - 80, VIRTUAL_HEIGHT - 35 - 110 - 35 / 2, 'wood'))
    local obstacle2 = Obstacle(self.world, 'vertical', VIRTUAL_WIDTH - 170, VIRTUAL_HEIGHT - 35 - 110 / 2, 'stone')
    local obstacle1 = Obstacle(self.world, 'vertical', VIRTUAL_WIDTH - 210, VIRTUAL_HEIGHT - 35 - 110 / 2, 'metal')
    table.insert(self.obstacles, obstacle1)
    table.insert(self.obstacles, obstacle2)

    -- ground data
    self.groundBody = love.physics.newBody(self.world, -VIRTUAL_WIDTH, VIRTUAL_HEIGHT - 35, 'static')
    self.groundFixture = love.physics.newFixture(self.groundBody, self.edgeShape)
    self.groundFixture:setFriction(0.5)
    self.groundFixture:setUserData('Ground')



    -- Pendulum initialize
    local anchorX = VIRTUAL_WIDTH / 2
    local anchorY = 100
    local pendulumRod = Obstacle(self.world, 'vertical', anchorX, anchorY + 110 / 2, 'metal')
    local pendulumWeight = Obstacle(self.world, 'horizontal', anchorX, anchorY + 110 + 35 / 2, 'stone')
    table.insert(self.obstacles, pendulumRod)
    table.insert(self.obstacles, pendulumWeight)
    
    -- Joints
    self.pendulumPivot = love.physics.newRevoluteJoint(self.groundBody, pendulumRod.body, anchorX, anchorY, false)
    self.pendulumWeld = love.physics.newWeldJoint(pendulumRod.body, pendulumWeight.body, anchorX, anchorY + 110, false)

    self.pendulumWeld = love.physics.newWeldJoint(self.groundBody, obstacle1.body, obstacle1.body:getX() + 35 / 2, obstacle1.body:getY() + 110, false)
    self.pendulumWeld = love.physics.newWeldJoint(self.groundBody, obstacle2.body, obstacle2.body:getX() + 35 / 2, obstacle2.body:getY() + 110, false)

    -- background graphics
    self.background = Background()
end

local FIXED_DT = 1 / 60
local accumulator = 0

function Level:update(dt)
    accumulator = accumulator + dt

    -- update launch marker, which shows trajectory
    self.launchMarker:update(dt)

    -- Box2D world update code; resolves collisions and processes callbacks
    -- ensure a fixed timestep of 1/60th of a second
    while accumulator >= FIXED_DT do
        self.world:update(FIXED_DT)
        accumulator = accumulator - FIXED_DT
    end

    -- destroy launched player aliens that leave the playable world
    if self.launchMarker.launched then
        for _, alien in pairs(self.launchMarker.aliens) do
            if not alien.body:isDestroyed() then
                local x, y = alien.body:getPosition()

                if x < -VIRTUAL_WIDTH or x > VIRTUAL_WIDTH * 3 or y > VIRTUAL_HEIGHT * 2 then
                    table.insert(self.destroyedBodies, alien.body)
                end
            end
        end
    end

    -- destroy all bodies we calculated to destroy during the update call
    for k, body in pairs(self.destroyedBodies) do
        if not body:isDestroyed() then 
            body:destroy()
        end
    end

    -- reset destroyed bodies to empty table for next update phase
    self.destroyedBodies = {}

    -- remove all destroyed obstacles from level
    for i = #self.obstacles, 1, -1 do
        if self.obstacles[i].body:isDestroyed() then
            table.remove(self.obstacles, i)

            -- play random wood sound effect
            local soundNum = math.random(5)
            gSounds['break' .. tostring(soundNum)]:stop()
            gSounds['break' .. tostring(soundNum)]:play()
        end
    end

    -- remove all destroyed aliens from level
    for i = #self.aliens, 1, -1 do
        if self.aliens[i].body:isDestroyed() then
            table.remove(self.aliens, i)
            gSounds['kill']:stop()
            gSounds['kill']:play()
        end
    end

    -- replace launch marker if original alien stopped moving
    if self.launchMarker.launched then
        -- check if all aliens have stopped before restart
        local allStopped = true
        for _, alien in pairs(self.launchMarker.aliens) do
            if not alien.body:isDestroyed() then
                local xVel, yVel = alien.body:getLinearVelocity()

                if math.abs(xVel) + math.abs(yVel) >= 1.5 then
                    allStopped = false
                    break
                end
            end
        end

        if allStopped then
            for k, alien in pairs(self.launchMarker.aliens) do
                if not alien.body:isDestroyed() then
                    alien.body:destroy()
                end
            end
            self.launchMarker = AlienLaunchMarker(self.world)
            -- re-initialize level if we have no more aliens
            if #self.aliens == 0 then
                gStateMachine:change('start')
            end
        end
    end
end

function Level:render()
    
    -- render ground tiles across full scrollable width of the screen
    for x = -VIRTUAL_WIDTH, VIRTUAL_WIDTH * 2, 35 do
        love.graphics.draw(gTextures['tiles'], gFrames['tiles'][12], x, VIRTUAL_HEIGHT - 35)
    end

    self.launchMarker:render()

    for k, alien in pairs(self.aliens) do
        alien:render()
    end

    for k, obstacle in pairs(self.obstacles) do
        obstacle:render()
    end

    -- render instruction text if we haven't launched bird
    if not self.launchMarker.launched then
        love.graphics.setFont(gFonts['medium'])
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf('Click and drag circular alien to shoot!',
            0, 64, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- render victory text if all aliens are dead
    if #self.aliens == 0 then
        love.graphics.setFont(gFonts['huge'])
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf('VICTORY', 0, VIRTUAL_HEIGHT / 2 - 32, VIRTUAL_WIDTH, 'center')
        love.graphics.setColor(1, 1, 1, 1)
    end
end