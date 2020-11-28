local start_x = arg[1]
local start_y = arg[2]
local start_z = arg[3]

if (start_x == nil or start_y == nil or start_z == nil) then
    print("XYZ coords needed")
    return
end

local coords = {x = start_x, y = start_y, z = start_z} -- not sure if needed right now. can't distinguish NSEW yet.
local numStepsTaken = 0

local hasExtraFuel = false
local fuelThreshold = 200

local torchEvery = 5

local stairWidth = 2

local Headings = {
    FORWARDS = 0,
    RIGHT = 1,
    BACK = 2,
    LEFT = 3,
}

local currentHeading = Headings.FORWARDS

function getFuelSlot()
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and (item.name == "minecraft:coal" or item.name == "minecraft:coal_block") then
            hasExtraFuel = true
            return i
        end
    end
    hasExtraFuel = false
    print("No more extra fuel.")
    return nil
end

function getTorchSlot()
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and item.name == "minecraft:torch" then
            return i
        end
    end
    return nil
end

function getStairSlot()
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and item.name == "minecraft:stone_stairs" then
            return i
        end
    end
    return nil
end

local fuelSlot = getFuelSlot()
local torchSlot = getTorchSlot()
local stairSlot = getStairSlot()

function checkFuel()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel < fuelThreshold then
        if hasExtraFuel then
            turtle.refuel(fuelSlot)
            local item = turtle.getItemDetail(fuelSlot)
            if item and (item.name == "minecraft:coal" or item.name == "minecraft:coal_block") then
                hasExtraFuel = true
            else
                hasExtraFuel = false
            end
            return true
        end
    end
    return false
end


function turnRight()
    turtle.turnRight()
    currentHeading = (currentHeading + 1) % 4
end


function turnLeft()
    turtle.turnLeft()
    currentHeading = (currentHeading - 1) % 4
end

function turnForwards()
    if currentHeading == Headings.FORWARDS then
        return
    elseif currentHeading == Headings.RIGHT then
        turnLeft()
    elseif currentHeading == Headings.LEFT then
        turnRight()
    else
        turnRight()
        turnRight()
    end
end

function turnBackwards()
    if currentHeading == Headings.BACK then
        return
    elseif currentHeading == Headings.RIGHT then
        turnRight()
    else if currentHeading == Headings.LEFT then
        turnLeft()
    else
        turnRight()
        turnRight()
    end
end

function goDown()
    turtle.down()
    coords.y = coords.y - 1
end


function goUp()
    turtle.up()
    coords.y = coords.y + 1
end

function returnHome()
    turnBackwards()
    while coords.y ~= start_y do
        goUp()
        turtle.forward()
    end
    turnForwards()
end

function placeStairs()
    turtle.select(stairSlot)
    turtle.placeDown()
end

function placeTorch()
    turtle.select(torchSlot)
    turtle.place()
end

function dig()
    while turtle.detectDown() do -- in case of gravel
        turtle.digDown()
        turtle.digUp()
    end
end

function digForwards()
    while turtle.detect() do -- in case of gravel
        turtle.dig()
    end
    if numStepsTaken % torchEvery == 0 then
        placeTorch()
    end
    turtle.forward()
    if currentHeading == Headings.FORWARDS then
        numStepsTaken = numStepsTaken + 1
    end
end

function digStairs()
    while coords.y > 4 do
        if not checkFuel() then
            break
        end
        if stairWidth > 1 then -- if the width is more than 1, we need to weave
            -- 1. look forwards
            -- 2. dig, then place stairs
            -- 3. turn
            -- 4. repeat 1-3 if necessary
            -- 5. turn forwards again
            for i = 1, stairWidth do
                turnForwards()
                dig()
                placeStairs()
                if coords.y % 2 == 1 then -- odd numbered coords dig turn right
                    turnRight()
                else
                    turnLeft()
                end
                digForwards()
            end
            turnForwards()
        else
            dig()
            placeStairs()
        end
        digForwards()
        dig()
        goDown()
    end
    returnHome()
end

digStairs()
print("Done making stairs.")

end