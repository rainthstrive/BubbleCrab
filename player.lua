local Shape = require "shape"
local Player = Shape:extend()

function Player:Rotate(direction_txt, dt)
    local rotationSpeed_float = math.rad(180)
    if direction_txt=="right" then
        self.rotationAngle_float = self.rotationAngle_float + rotationSpeed_float * dt
    elseif direction_txt=="left" then
        self.rotationAngle_float = self.rotationAngle_float - rotationSpeed_float * dt
    end
    self.rotationAngle_float = self.rotationAngle_float % (2 * math.pi)
    --print(self.rotationAngle_float)
end

function Player:Move(dt)
    -- Calculate direction based on angle
    local dx = math.cos(self.rotationAngle_float)
    local dy = math.sin(self.rotationAngle_float)
    -- Update position based on direction and speed
    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt
end

function Player:new(x, y, radius)
    Player.super.new(self, x, y)
    self.radius = radius
    self.rotationAngle_float = 0
    self.alive = true
    self.bubble = true
end

function Player:update(dt)
    if self.alive then
        if love.keyboard.isDown("left") and love.keyboard.isDown("right")  then
            self:Move(dt)
        elseif love.keyboard.isDown("right") then
            self:Rotate("right", dt)
        elseif love.keyboard.isDown("left") then
            self:Rotate("left", dt)
        end
    end
end

function Player:draw()
    if self.alive then
        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.rotate(self.rotationAngle_float)
        love.graphics.circle("line", 0, 0, self.radius)
        love.graphics.pop()
    end
end

function Player:LoseLife()
    if self.bubble then self.bubble=false end
    if self.bubble==false and self.alive then self.alive=false end
    if self.alive==false then print("Game Over") end
end

-- And then return it.
return Player