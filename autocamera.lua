local AutoCamera = Object:extend()

function AutoCamera:new(x, y, wayPoints, speed)
    self.x = x or 0 -- Initial camera X position
    self.y = y or 0 -- Initial camera Y position
    self.speed = speed or 50 -- Default speed
    self.waypointList = wayPoints
    self.currentWaypoint = 1 -- Start at the first waypoint
    self.pauseDuration = 2
    self.paused = false
    self.pauseTimer = 0
end

function AutoCamera:update(dt)
    -- If the camera is paused, increment the pause timer
    if self.paused then
        self.pauseTimer = self.pauseTimer + dt
        if self.pauseTimer >= self.pauseDuration then
            self.paused = false -- Resume moving
            self.pauseTimer = 0 -- Reset pause timer
            self.currentWaypoint = self.currentWaypoint + 1 -- Move to the next waypoint
        end
        return -- Skip the rest of the update logic while paused
    end

    -- Move towards the next waypoint if there are any left
    if self.currentWaypoint <= #self.waypointList then
        local targetWaypoint = self.waypointList[self.currentWaypoint]
        local directionX = targetWaypoint.x - self.x
        local directionY = targetWaypoint.y - self.y

        -- Compute the distance to the target waypoint
        local distance = math.sqrt(directionX^2 + directionY^2)

        if distance > 1 then
            -- Normalize direction and apply speed
            local normX = directionX / distance
            local normY = directionY / distance
            self.x = self.x + normX * self.speed * dt
            self.y = self.y + normY * self.speed * dt
        else
            -- Reached the waypoint, start pausing
            self.paused = true
        end
    end
end

function AutoCamera:apply(camera)
    -- Center the camera's view around its current position
    camera:lookAt((self.x+26), self.y+26)
end

return AutoCamera
