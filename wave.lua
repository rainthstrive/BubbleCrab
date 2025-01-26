local Shape = require "shape"
local Wave = Shape:extend()

function Wave:new(x, y, width, height, direction, force)
    Wave.super.new(self, x, y)
    self.width = width
    self.height = height
    self.direction = direction
    self.force = force or 300
end

function Wave:update(circle, pushSpeed, dt)
    --self:resolveCircleRectangleCollision(circle, pushSpeed, dt)
end

function Wave:draw()
    love.graphics.setColor(0, 0.5, 1) -- Blue rectangle for wave zone
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1) -- Reset to white
end

-- Check if a circle and a rectangle are colliding
function Wave:checkCollision(circle)
    -- Find the closest point on the rectangle to the circle
    local closestX = math.max(self.x, math.min(circle.x, self.x + self.width))
    local closestY = math.max(self.y, math.min(circle.y, self.y + self.height))

    -- Calculate the distance from the circle to the closest point
    local dx = circle.x - closestX
    local dy = circle.y - closestY
    local distance = math.sqrt(dx * dx + dy * dy)

    -- Return whether they are colliding and the direction of the push
    return math.sqrt(dx * dx + dy * dy) < circle.radius
end

return Wave