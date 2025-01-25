local p1

function love.load()
    Object = require "classic"
    local Player = require "player"
    local Food = require "food"
    p1 = Player(400, 300, 30, 30)
    foodList = {}
    for i=1, 5 do
        table.insert(
            foodList,
            Food(math.random(50, 650), math.random(50, 450), 25)            
        )
    end
end

function love.update(dt)
    p1:update(dt)
    for i,v in ipairs(foodList) do
        if checkCollision(p1, v) then
            table.remove(foodList, i)
        end
    end
end

function love.draw()
    p1:draw()
    for i,v in ipairs(foodList) do
        v:draw()
    end
end

function checkCollision(object, colObject) 
    local distance = math.sqrt((object.x - colObject.x)^2 + (object.y - colObject.y)^2)
    return distance < object.radius + colObject.radius
end