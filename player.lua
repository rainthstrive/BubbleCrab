local Shape = require "shape"
local Player = Shape:extend()

function Player:Rotate(direction_txt, dt)
    local rotationSpeed_float = math.rad(90)
    if direction_txt=="right" then
        self.rotationAngle_float = self.rotationAngle_float + rotationSpeed_float * dt
    elseif direction_txt=="left" then
        self.rotationAngle_float = self.rotationAngle_float - rotationSpeed_float * dt
    end
    self.rotationAngle_float = self.rotationAngle_float % (2 * math.pi)
    print(self.rotationAngle_float)
end

function Player:Move(dt)
    -- Calculate direction based on angle
    local dx = math.cos(self.rotationAngle_float)
    local dy = math.sin(self.rotationAngle_float)
    -- Update position based on direction and speed
    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt
end

function Player:new(x, y, width, height)
    Player.super.new(self, x, y)
    self.width = width
    self.height = height
    self.rotationAngle_float = 0
end

function Player:update(dt)
    if love.keyboard.isDown("left") and love.keyboard.isDown("right")  then
        self:Move(dt)
    elseif love.keyboard.isDown("right") then
        self:Rotate("right", dt)
    elseif love.keyboard.isDown("left") then
        self:Rotate("left", dt)
    end
end

function Player:draw()
    love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.rotate(self.rotationAngle_float)
        love.graphics.rectangle("line", -self.width/2, -self.height/2, self.width, self.height)
    love.graphics.pop()
end

-- And then return it.
return Player