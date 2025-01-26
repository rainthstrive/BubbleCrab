local anim8 = require "libs/anim8" -- Import Anim8
local Shape = require "shape"
local Prop = Shape:extend()

function Prop:new(x, y, radius, tag, spritesheet)
    Prop.super.new(self, x, y)
    self.radius = radius 
    self.tag = tag

    -- Load spritesheet and animation
    self.spritesheet = spritesheet
    local grid = anim8.newGrid(128, 128, spritesheet:getWidth(), spritesheet:getHeight())
    
    -- Create animation (example: using 4 columns and 2 rows)
    self.animation = anim8.newAnimation(grid('1-8',1), 0.08)
end

function Prop:update(dt)
    -- Update the animation
    self.animation:update(dt)
end

function Prop:draw()
    -- Determine the type of circle (fill or line)
    local type_txt
    if self.tag == "enemy" then 
        type_txt = "line" 
    else 
        type_txt = "fill" 
    end
    
    -- Draw the circle at the correct position
    love.graphics.circle(type_txt, self.x, self.y, self.radius)
    
    -- Draw the sprite animation at the correct position, adjust center and scale
    self.animation:draw(self.spritesheet, self.x, self.y, 0, 1, 1, 64, 64)  -- Positioning sprite at (self.x, self.y)
end


-- And then return it.
return Prop