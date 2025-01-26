local p1_obj
local foodList_tbl
local enemyList_tbl
local gameState_bool = true
local score_int = 0
local shakeDuration_int = 0
local shakeWait_int = 0
local shakeOffset_int = {x = 0, y = 0}

function love.load()
    -- Get Requirements
    Object = require "classic"
    local AutoCamera = require "autocamera"
    local Background = require "background"
    local Player = require "player"
    local Wave = require "wave"
    local Prop = require "props"
    -- Initialize Objects
    autocam = AutoCamera(400, 300, 20)
    background = Background(nil, nil)
    p1_obj = Player(400, 300, 15)
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
        --autocam:update(dt)
        p1_obj:update(dt)
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
                shakeDuration_int = 0.3
                p1_obj:LoseLife()
                gameState_bool = false
            end
        end
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
    --autocam:apply()
    -- shake camera
    if shakeDuration_int > 0 then
        love.graphics.translate(shakeOffset_int.x, shakeOffset_int.y)
    end
    -- draw background
    background:draw()
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
    wave_obj:draw()
    -- print UI
    love.graphics.pop()
    love.graphics.print(score_int, 10, 10)
end

function checkCollision(object, colObject) 
    local distance = math.sqrt((object.x - colObject.x)^2 + (object.y - colObject.y)^2)
    return distance < object.radius + colObject.radius
end