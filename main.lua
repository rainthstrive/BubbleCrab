local p1_obj
--local foodList_tbl
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
local enemySpritesheet = love.graphics.newImage("assets/spritesheets/GRID_4X4_128.png")
local foodSpritesheet = love.graphics.newImage("assets/spritesheets/basura.png")
local enemySpawnPoints = {}
local foodSpawnPoints = {}
local leftWaveSpawnPoints = {}
local rightWaveSpawnPoints = {}
local upWaveSpawnPoints = {}
local downWaveSpawnPoints = {}
local foodSpawnPoints = {}
local waveForce = 5

function love.load()
    -- Get Requirements
    -- Get Sounds
    sounds = {}
    sounds.blip = love.audio.newSource("assets/vga/BUBBLE.ogg", "static")
    sounds.music = love.audio.newSource("assets/vga/survivor_sea.mp3", "stream")
    sounds.music:play()
    -- Get Libs
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
    local Food = require "food"
    font = love.graphics.newFont(48)
    -- Initialize Objects
    -- Get Spawn Point from Tiled Map
    getCharacterSpawn(gameMap)
    p1_obj = Player(spawnX, spawnY, 30, crabSpritesheet)
    -- Set AutoCamera
    autocam = AutoCamera(p1_obj.x, p1_obj.y, waypointList, 200)
    -- Left Waves
    leftWaveSpawnPoints = getSpawnList(gameMap, "Leftwavespawns")
    leftWaveList_tbl = {}
    for i, v in ipairs(leftWaveSpawnPoints) do
        table.insert(
            leftWaveList_tbl,
            Wave(v.x, v.y, 60, 60, "left", waveForce)            
        )
    end
    -- Right Waves
    rightWaveSpawnPoints = getSpawnList(gameMap, "RightWaveSpawns")
    rightWaveList_tbl = {}
    for i, v in ipairs(rightWaveSpawnPoints) do
        table.insert(
            rightWaveList_tbl,
            Wave(v.x, v.y, 60, 60, "right", waveForce)            
        )
    end
    -- Up Waves
    upWaveSpawnPoints = getSpawnList(gameMap, "upwavespawn")
    upWaveList_tbl = {}
    for i, v in ipairs(upWaveSpawnPoints) do
        table.insert(
            upWaveList_tbl,
            Wave(v.x, v.y, 60, 60, "up", waveForce)            
        )
    end
    -- Down Waves
    downWaveSpawnPoints = getSpawnList(gameMap, "downwavespawn")
    downWaveList_tbl = {}
    for i, v in ipairs(downWaveSpawnPoints) do
        table.insert(
            upWaveList_tbl,
            Wave(v.x, v.y, 60, 60, "down", waveForce)            
        )
    end
    -- Food List
    foodSpwanPoints = getSpawnList(gameMap, "FoodSpawn")
    foodList_tbl = {}
    for i, v in ipairs(foodSpwanPoints) do
        table.insert(
            foodList_tbl,
            Food(v.x+32, v.y+32, 30, "food", foodSpritesheet)            
        )
    end
    -- Enemy List
    enemySpawnPoints = getSpawnList(gameMap, "EnemySpawns")
    enemyList_tbl = {}
    for i, v in ipairs(enemySpawnPoints) do
        table.insert(
            enemyList_tbl,
            Prop(v.x+64, v.y+64, 60, "enemy", enemySpritesheet)            
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
        for i,v in ipairs(leftWaveList_tbl) do
            if v:checkCollision(p1_obj) then
                p1_obj:applyWaveForce(v.direction, v.force)
            end
        end
        for i,v in ipairs(rightWaveList_tbl) do
            if v:checkCollision(p1_obj) then
                p1_obj:applyWaveForce(v.direction, v.force)
            end
        end
        for i,v in ipairs(upWaveList_tbl) do
            if v:checkCollision(p1_obj) then
                p1_obj:applyWaveForce(v.direction, v.force)
            end
        end
        for i,v in ipairs(downWaveList_tbl) do
            if v:checkCollision(p1_obj) then
                p1_obj:applyWaveForce(v.direction, v.force)
            end
        end
        for i,v in ipairs(foodList_tbl) do
            if checkCollision(p1_obj, v) then
                sounds.blip:play()
                table.remove(foodList_tbl, i)
                score_int = score_int + 1
            end
        end
        for i,v in ipairs(enemyList_tbl) do
            v:update(dt)
            if checkCollision(p1_obj, v) then
                sounds.blip:play()
                shakeDuration_int = 0.3
                p1_obj:LoseLife()
                gameState_bool = false
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
    gameMap:drawLayer(gameMap.layers["Beach"])
    --gameMap:drawLayer(gameMap.layers["Decor"])
    gameMap:drawLayer(gameMap.layers["Currents"])
    --gameMap:drawLayer(gameMap.layers["Character"])
    gameMap:drawLayer(gameMap.layers["Camera"])
    -- draw player
    p1_obj:draw()
    -- draw food
    for i,v in ipairs(foodList_tbl) do
        v:draw()
    end
    -- draw enemies
    for i,v in ipairs(enemyList_tbl) do
        v:draw()
    end
    -- draw waves
    for i,v in ipairs(leftWaveList_tbl) do
        v:draw()
    end
    for i,v in ipairs(rightWaveList_tbl) do
        v:draw()
    end
    for i,v in ipairs(upWaveList_tbl) do
        v:draw()
    end
    for i,v in ipairs(downWaveList_tbl) do
        v:draw()
    end
    camera:detach()
    love.graphics.pop()
    -- print UI
    love.graphics.setFont(font)
    love.graphics.print(score_int, 20, 20)
end

function checkCollision(object, colObject) 
    local distance = math.sqrt((object.x - colObject.x)^2 + (object.y - colObject.y)^2)
    return distance < object.radius + colObject.radius
end

function getSpawnList(gameMap_in, layerName)
    local enemySpawns = {}
    local spawnLayer = gameMap_in.layers[layerName]
    
    if spawnLayer and spawnLayer.objects then
        for _, object in ipairs(spawnLayer.objects) do
            local spawnX = tonumber(object.x)
            local spawnY = tonumber(object.y)
            table.insert(enemySpawns, {x = spawnX, y = spawnY})
        end
    end
    return enemySpawns
end

function getCharacterSpawn(gameMap_in)
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
