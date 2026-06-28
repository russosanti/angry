--[[
    CS50 2D
    Angry Birds

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    An Obstacle is any physics-based construction that forms the current level,
    usually shielding the aliens the player is trying to kill; they can form houses,
    boxes, anything the developer wishes. Depending on what kind they are, they are
    typically rectangular or polygonal.
]]

local DAMAGE_FRAMES = {
    glass = {
        horizontal = {2, 1, 1},
        vertical = {4, 3, 3}
    },
    wood = {
        horizontal = {2, 1, 1},
        vertical = {4, 3, 3}
    },
    stone = {
        horizontal = {2, 5, 1},
        vertical = {4, 6, 3}
    },
    metal = {
        horizontal = {2, 5, 1},
        vertical = {4, 6, 3}
    }
}

Obstacle = Class{}

function Obstacle:init(world, shape, x, y, material)
    self.orientation = shape or 'horizontal'
    self.material = material or 'wood'
    self.hits = 0
    self.maxHits = MATERIAL_HITS[self.material]

    self.frame = DAMAGE_FRAMES[self.material][self.orientation][1]

    self.startX = x
    self.startY = y

    self.pendingDestroy = false

    self.world = world

    self.body = love.physics.newBody(self.world, 
        self.startX or math.random(VIRTUAL_WIDTH), self.startY or math.random(VIRTUAL_HEIGHT - 35), 'dynamic')

    -- assign width and height based on shape to create physics shape
    if self.orientation == 'horizontal' then
        self.width = 110
        self.height = 35
    elseif self.orientation == 'vertical' then
        self.width = 35
        self.height = 110
    end

    self.shape = love.physics.newRectangleShape(self.width, self.height)

    self.fixture = love.physics.newFixture(self.body, self.shape)

    self.fixture:setUserData({
        type = 'Obstacle',
        entity = self
    })
    self.body:setUserData(self)
end

function Obstacle:update(dt)

end

function Obstacle:render()
    love.graphics.draw(gTextures[self.material], gFrames[self.material][self.frame],
        self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1,
        self.width / 2, self.height / 2)
end

-- Obstacle takes damage, checks destory and switch frame if neccesary
function Obstacle:takeDamage(amount)
    if self.pendingDestroy then
        return false
    end

    self.hits = self.hits + (amount or 1)

    if self.hits >= self.maxHits then
        self.pendingDestroy = true
        return true
    end

    self.frame = DAMAGE_FRAMES[self.material][self.orientation][math.min(self.hits + 1, 3)]
    return false
end