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
    -- Add directional movement to velocity
    self.vx = self.vx + dx * self.speed * dt
    self.vy = self.vy + dy * self.speed * dt
end

function Player:new(x, y, radius)
    Player.super.new(self, x, y)
    self.radius = radius
    self.rotationAngle_float = 0
    self.alive = true
    self.bubble = true
    self.vx = 0 -- Horizontal velocity
    self.vy = 0 -- Vertical velocity
    self.friction = 0.94 -- Friction
    self.minVelocity = 10
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
        -- Apply velocity to position
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        -- Apply friction to gradually slow down
        self.vx = self.vx * self.friction
        self.vy = self.vy * self.friction
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

-- Function to apply a wave-like push
function Player:applyWaveForce(direction, force)
    if direction == "up" then
        self.vy = self.vy - force
    elseif direction == "down" then
        self.vy = self.vy + force
    elseif direction == "left" then
        self.vx = self.vx - force
    elseif direction == "right" then
        self.vx = self.vx + force
    end
end

-- And then return it.
return Player