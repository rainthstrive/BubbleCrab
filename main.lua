local p1_obj
local foodList_tbl
local enemyList_tbl
local gameState_bool = true
local score_int = 0
local shakeDuration_int = 0
local shakeWait_int = 0
local shakeOffset_int = {x = 0, y = 0}

function love.load()
    Object = require "classic"
    local Player = require "player"
    local Prop = require "props"
    p1_obj = Player(400, 300, 30, 30)
    foodList_tbl = {}
    enemyList_tbl = {}
    for i=1, 10 do
        table.insert(
            foodList_tbl,
            Prop(math.random(15, 800), math.random(15, 600), 15, "food")            
        )
    end
    for i=1, 10 do
        table.insert(
            enemyList_tbl,
            Prop(math.random(15, 800), math.random(15, 600), 15, "enemy")            
        )
    end
end

function love.update(dt)
    if gameState_bool then
        p1_obj:update(dt)
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
    love.graphics.translate(-p1_obj.x + 400, -p1_obj.y + 300)
    -- shake camera
    if shakeDuration_int > 0 then
        love.graphics.translate(shakeOffset_int.x, shakeOffset_int.y)
    end
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
    -- print UI
    love.graphics.pop()
    love.graphics.print(score_int, 10, 10)
end

function checkCollision(object, colObject) 
    local distance = math.sqrt((object.x - colObject.x)^2 + (object.y - colObject.y)^2)
    return distance < object.radius + colObject.radius
end