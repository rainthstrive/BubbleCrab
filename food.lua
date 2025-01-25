local Shape = require "shape"
local Food = Shape:extend()

function Food:new(x, y, radius)
    Food.super.new(self, x, y)
    self.radius = radius 
end

function Food:draw()
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

-- And then return it.
return Food