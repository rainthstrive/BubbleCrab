local AutoCamera = Object:extend()
local drawable_img = love.graphics.newImage("assets/example_map.jpg")

function AutoCamera:new(x, y, speed)
    self.x = x or 0 -- Initial camera X position
    self.y = y or 0 -- Initial camera Y position
    self.speed = speed or 50 -- Default speed
    self.waypoints = { -- Waypoints for the camera to follow
        {x = 398, y = 2335},
        {x = 503, y = 2136},
        {x = 533, y = 1966},
        {x = 427, y = 1689},
        {x = 251, y = 1428},
        {x = 336, y = 1124},
        {x = 457, y = 867},
        {x = 479, y = 717},
        {x = 362, y = 522},
        {x = 280, y = 374},
        -- Add more points if needed
    }
    self.currentWaypoint = 1 -- Start at the first waypoint
end

function AutoCamera:update(dt)
    if self.currentWaypoint <= #self.waypoints then
        -- Get the current target waypoint
        local target = self.waypoints[self.currentWaypoint]

        -- Calculate the direction to the waypoint
        local dx = target.x * -1 - self.x
        local dy = target.y * -1 - self.y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance > 1 then
            -- Move the camera towards the waypoint
            self.x = self.x + (dx / distance) * self.speed * dt
            self.y = self.y + (dy / distance) * self.speed * dt
        else
            -- Reached the waypoint, move to the next one
            self.currentWaypoint = self.currentWaypoint + 1
        end
    end
end

function AutoCamera:apply()
    -- Center the camera's view around its current position
    love.graphics.translate(-self.x + love.graphics.getWidth() / 2, -self.y + love.graphics.getHeight() / 2)
end


return AutoCamera
