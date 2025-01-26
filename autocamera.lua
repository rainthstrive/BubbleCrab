local AutoCamera = Object:extend()

function AutoCamera:new(x, y, wayPoints, speed)
    self.x = x or 0 -- Initial camera X position
    self.y = y or 0 -- Initial camera Y position
    self.speed = speed or 75 -- Default speed
    self.waypointList = wayPoints
    self.currentWaypoint = 1 -- Start at the first waypoint
    self.pauseDuration = 0
    self.paused = false
    self.pauseTimer = 0
    self.easingDuration = 3 -- Duration for easing to complete (adjustable)
    self.t = 0 -- Easing progress factor
end

function AutoCamera:update(dt)
    -- If the camera is paused, increment the pause timer
    if self.paused then
        self.pauseTimer = self.pauseTimer + dt
        if self.pauseTimer >= self.pauseDuration then
            self.paused = false -- Resume moving
            self.pauseTimer = 0 -- Reset pause timer
            self.currentWaypoint = self.currentWaypoint + 1 -- Move to the next waypoint
            self.t = 0 -- Reset easing progress
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
            -- Normalize direction and apply speed, but use easing
            local normX = directionX / distance
            local normY = directionY / distance

            -- Easing (ease-in/ease-out effect)
            self.t = self.t + dt / self.easingDuration -- Progress the easing factor
            if self.t > 1 then self.t = 1 end -- Clamp easing progress to 1

            -- Calculate the speed as easing factor
            local easedSpeed = self.speed * self.t

            -- Apply the eased speed to movement
            self.x = self.x + normX * easedSpeed * dt
            self.y = self.y + normY * easedSpeed * dt
        else
            -- Reached the waypoint, start pausing
            self.paused = true
        end
    end
end

function AutoCamera:apply(camera)
    -- Center the camera's view around its current position
    camera:lookAt(self.x+26, self.y+26)
end

return AutoCamera
