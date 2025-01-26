local p1
local foodList
local enemyList
local gameState = true

function love.load()
    Object = require "classic"
    local Player = require "player"
    local Prop = require "props"
    p1 = Player(400, 300, 30, 30)
    foodList = {}
    enemyList = {}
    for i=1, 10 do
        table.insert(
            foodList,
            Prop(math.random(15, 800), math.random(15, 600), 15, "food")            
        )
    end
    for i=1, 10 do
        table.insert(
            enemyList,
            Prop(math.random(15, 800), math.random(15, 600), 15, "enemy")            
        )
    end
end

function love.update(dt)
    if gameState then
        p1:update(dt)
        for i,v in ipairs(foodList) do
            if checkCollision(p1, v) then
                table.remove(foodList, i)
            end
        end
        for i,v in ipairs(enemyList) do
            if checkCollision(p1, v) then
                p1:LoseLife()
                gameState = false
            end
        end
    end
end

function love.draw()
    p1:draw()
    for i,v in ipairs(foodList) do
        v:draw()
    end
    for i,v in ipairs(enemyList) do
        v:draw()
    end
end

function checkCollision(object, colObject) 
    local distance = math.sqrt((object.x - colObject.x)^2 + (object.y - colObject.y)^2)
    return distance < object.radius + colObject.radius
end