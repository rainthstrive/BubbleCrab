local Background = Object:extend()
local drawable_img = love.graphics.newImage("assets/example_map.jpg")

function Background:new(x, y)
    self.x = x or 398
    self.y = y or 2335
end

function Background:update(dt)
end

function Background:draw()
    love.graphics.draw(drawable_img, -self.x + love.graphics.getWidth() / 2, -self.y + love.graphics.getHeight() / 2)
end

return Background