local Shape = require "shape"
local Prop = Shape:extend()

function Prop:new(x, y, radius, tag)
    Prop.super.new(self, x, y)
    self.radius = radius 
    self.tag = tag
end

function Prop:draw()
    local type_txt
    if self.tag=="enemy" then type_txt="line" else type_txt="fill" end
    love.graphics.circle(type_txt, self.x, self.y, self.radius)
end

-- And then return it.
return Prop