local anim8 = require "libs/anim8" -- Import Anim8
local Shape = require "shape"
local Player = Shape:extend()

function Player:new(x, y, radius, spritesheet)
    Player.super.new(self, x, y)
    self.radius = radius
    self.rotationAngle_float = 0
    self.alive = true
    self.bubble = true
    self.vx = 0 -- Horizontal velocity
    self.vy = 0 -- Vertical velocity
    self.friction = 0.94 -- Friction
    self.minVelocity = 10

    -- Load spritesheet and animation
    self.spritesheet = spritesheet
    local grid = anim8.newGrid(256, 256, spritesheet:getWidth(), spritesheet:getHeight())
    
    -- Create animation (example: using 4 columns and 2 rows)
    self.animation = anim8.newAnimation(grid('1-4', 1, '1-4', 2), 0.1)

end

function Player:update(dt)
    if self.alive then
        -- Handle movement logic
        if love.keyboard.isDown("left") and love.keyboard.isDown("right") then
            self:Move(dt)
        elseif love.keyboard.isDown("right") then
            self:Rotate("right", dt)
        elseif love.keyboard.isDown("left") then
            self:Rotate("left", dt)
        elseif love.keyboard.isDown("q") then
            love.load()
        end

        -- Apply velocity to position
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt

        -- Apply friction
        self.vx = self.vx * self.friction
        self.vy = self.vy * self.friction

        -- Update the animation
        self.animation:update(dt)
    end
end

function Player:draw()
    if self.alive then
        -- Draw the circle for collision detection
        love.graphics.push()
        love.graphics.translate(self.x, self.y)
        love.graphics.rotate(self.rotationAngle_float)
        love.graphics.circle("line", 0, 0, self.radius)  -- Circle for collision
        love.graphics.pop()

        -- Draw the sprite animation (use the same translation)
        love.graphics.push()
        love.graphics.translate(self.x, self.y)  -- Ensure the sprite is drawn at the same position
        love.graphics.rotate(self.rotationAngle_float)  -- Ensure sprite rotates the same way
        self.animation:draw(self.spritesheet, 0, 0, 0, 0.25, 0.25, 128, 128)  -- Adjust for sprite's center point
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
    local dx = math.sin(self.rotationAngle_float)
    local dy = -math.cos(self.rotationAngle_float)
    -- Update position based on direction and speed
    -- Add directional movement to velocity
    self.vx = self.vx + dx * self.speed * dt
    self.vy = self.vy + dy * self.speed * dt
end

return Player
