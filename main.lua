local p1_obj
local foodList_tbl
local enemyList_tbl
local gameState_bool = true
local score_int = 0
local shakeDuration_int = 0
local shakeWait_int = 0
local shakeOffset_int = {x = 0, y = 0}
local spawnX, spawnY
local waypoints = {}
local waypointList = {}
local crabSpritesheet = love.graphics.newImage("assets/spritesheets/GRID_crabanim.png")

function love.load()
    -- Get Requirements
    local Sti = require "libs/sti"
    local Camera = require "libs/camera"
    love.graphics.setDefaultFilter("nearest","nearest")
    gameMap = Sti('assets/weird_sea.lua')
    camera = Camera()
    Object = require "classic"
    local AutoCamera = require "autocamera"
    local Player = require "player"
    local Wave = require "wave"
    local Prop = require "props"
    -- Initialize Objects
    -- Get Spawn Point from Tiled Map
    getSpawnPoints(gameMap)
    p1_obj = Player(spawnX, spawnY, 30, crabSpritesheet)
    -- Set AutoCamera
    autocam = AutoCamera(p1_obj.x, p1_obj.y, waypointList, 50)
    wave_obj = Wave(300, 200, 50, 50, "right", 50)
    foodList_tbl = {}
    enemyList_tbl = {}
    for i=1, 3 do
        table.insert(
            foodList_tbl,
            Prop(math.random(15, 800), math.random(15, 600), 15, "food")            
        )
    end
    for i=1, 3 do
        table.insert(
            enemyList_tbl,
            Prop(math.random(15, 800), math.random(15, 600), 30, "enemy")            
        )
    end
end

function love.update(dt)
    if gameState_bool then
        -- Get the camera's position and boundaries
        local cameraX, cameraY = autocam.x - love.graphics.getWidth() / 2, autocam.y - love.graphics.getHeight() / 2
        local cameraWidth, cameraHeight = love.graphics.getWidth(), love.graphics.getHeight()
        -- Update player, passing camera boundaries
        p1_obj:update(dt, cameraX+26, cameraY+26, cameraWidth, cameraHeight)
        -- Check if the player enters the wave zone
        if wave_obj:checkCollision(p1_obj) then
            p1_obj:applyWaveForce(wave_obj.direction, wave_obj.force)
        end
        for i,v in ipairs(foodList_tbl) do
            if checkCollision(p1_obj, v) then
                table.remove(foodList_tbl, i)
                score_int = score_int + 1
            end
        end
        for i,v in ipairs(enemyList_tbl) do
            if checkCollision(p1_obj, v) then
                --shakeDuration_int = 0.3
                --p1_obj:LoseLife()
                --gameState_bool = false
            end
        end
        -- Update Camera
        autocam:update(dt)
        autocam:apply(camera)
        limitCircleInsideCamera(p1_obj, camera, gameMap)

    end
    if shakeDuration_int > 0 then
        shakeDuration_int = shakeDuration_int - dt
        if shakeWait_int > 0 then
            shakeWait_int = shakeWait_int - dt
        else
            shakeOffset_int.x = love.math.random(-5,5)
            shakeOffset_int.y = love.math.random(-5,5)
            shakeWait_int = 0.05
        end
    end
end

function love.draw()
    love.graphics.push()
    -- camera position
    camera:attach()
    -- shake camera
    if shakeDuration_int > 0 then
        love.graphics.translate(shakeOffset_int.x, shakeOffset_int.y)
    end
    -- draw background
    gameMap:drawLayer(gameMap.layers["Sea"])
    gameMap:drawLayer(gameMap.layers["Currents"])
    gameMap:drawLayer(gameMap.layers["Beach"])
    gameMap:drawLayer(gameMap.layers["Decor"])
    gameMap:drawLayer(gameMap.layers["Character"])
    gameMap:drawLayer(gameMap.layers["Camera"])
    -- draw player
    p1_obj:draw()
    -- draw food
    for i,v in ipairs(foodList_tbl) do
        --v:draw()
    end
    -- draw enemies
    for i,v in ipairs(enemyList_tbl) do
        --v:draw()
    end
    -- draw waves
    --wave_obj:draw()
    camera:detach()
    love.graphics.pop()
    -- print UI
    --love.graphics.print(score_int, 10, 10)
end

function checkCollision(object, colObject) 
    local distance = math.sqrt((object.x - colObject.x)^2 + (object.y - colObject.y)^2)
    return distance < object.radius + colObject.radius
end

function getSpawnPoints(gameMap_in)
    local spawnPoint = gameMap_in.layers["CharacterSpawn"]
    if spawnPoint and spawnPoint.objects then
        for _, object in ipairs(spawnPoint.objects) do
            if object.name == "SpawnPoint" then
                -- Set the spawn coordinates
                spawnX = tonumber(object.x)
                spawnY = tonumber(object.y)
                break
            end
        end
    end
    --print("Spawn Point:", spawnX, spawnY)
    
    local waypoints = {}
    -- Find the "WayPoints" layer
    local waypointLayer = gameMap_in.layers["MapWaypoints"]
    if waypointLayer and waypointLayer.objects then
        for _, object in ipairs(waypointLayer.objects) do
            -- Match "WP<number>", including WP0
            local wpNumber = tonumber(object.name:match("^WP(%d+)$"))
            if wpNumber then
                -- Add the object and its number to the list
                table.insert(waypoints, {number = wpNumber, object = object})
            end
        end
    end
    -- Sort waypoints by their number
    table.sort(waypoints, function(a, b)
        return a.number < b.number
    end)
    -- Extract just the sorted objects into a list
    local sortedWaypoints = {}
    for _, wp in ipairs(waypoints) do
        table.insert(sortedWaypoints, wp.object)
    end
    for i, wp in ipairs(sortedWaypoints) do
        --print(string.format("Waypoint %d: x=%d, y=%d", i, wp.x, wp.y))
        table.insert(waypointList, {x = tonumber(wp.x), y = tonumber(wp.y)})
    end
end

function limitCircleInsideCamera(circle, camera, gameMap)
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()  -- screen width and height
    local mapW = gameMap.width * gameMap.tilewidth  -- map width
    local mapH = gameMap.height * gameMap.tileheight  -- map height
    
    -- Calculate the camera's visible area
    local camX, camY = camera.x - w / 2, camera.y - h / 2
    local camRight, camBottom = camX + w, camY + h
    
    -- Circle boundaries
    local circleLeft = circle.x - circle.radius
    local circleRight = circle.x + circle.radius
    local circleTop = circle.y - circle.radius
    local circleBottom = circle.y + circle.radius
    
    -- Clamp the circle's position inside the camera's visible area
    if circleLeft < camX then
        circle.x = camX + circle.radius  -- prevent left side overflow
    elseif circleRight > camRight then
        circle.x = camRight - circle.radius  -- prevent right side overflow
    end
    
    if circleTop < camY then
        circle.y = camY + circle.radius  -- prevent top side overflow
    elseif circleBottom > camBottom then
        circle.y = camBottom - circle.radius  -- prevent bottom side overflow
    end
end
