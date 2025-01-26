local anim8 = require "libs/anim8" -- Import Anim8
local Shape = require "shape"
local Food = Shape:extend()

function Food:new(x, y, radius, tag, spritesheet)
    Food.super.new(self, x, y)
    self.radius = radius 
    self.tag = tag

    -- Load spritesheet and animation
    self.spritesheet = spritesheet
    local grid = anim8.newGrid(64, 64, spritesheet:getWidth(), spritesheet:getHeight())
    
    -- Create animation (example: using 4 columns and 2 rows)
    self.animation = anim8.newAnimation(grid('1-1',1), 0.08)
end

function Food:update(dt)
    -- Update the animation
    self.animation:update(dt)
end

function Food:draw()
    -- Draw the circle at the correct position
    love.graphics.circle("line", self.x, self.y, self.radius)
    
    -- Draw the sprite animation at the correct position, adjust center and scale
    self.animation:draw(self.spritesheet, self.x -32, self.y -32, 0, 1, 1, 1, 1)  -- Positioning sprite at (self.x, self.y)
end


-- And then return it.
return Food