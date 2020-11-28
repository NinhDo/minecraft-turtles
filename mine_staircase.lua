local curr_y = tonumber(arg[1])
local home_y = tonumber(arg[2])
local lowest_y = tonumber(arg[3])

if (curr_y == nil or home_y == nil or lowest_y == nil) then
    print("Need current Y, home Y, and lowest Y")
    return
end

local coords = { -- not sure if needed right now. can't distinguish NSEW yet.
    y = curr_y,
    home = home_y
}

local hasExtraFuel = false
local fuelThreshold = 200

local torchEvery = 5

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
            print("Current fuel slot:", i)
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
            print("Current torch slot:", i)
            return i
        end
    end
    return nil
end

function getStairSlot()
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and item.name == "minecraft:stone_stairs" then
            print("Current stair slot:", i)
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
            turtle.select(fuelSlot)
            turtle.refuel(1)
            local item = turtle.getItemDetail(fuelSlot)
            if item and (item.name == "minecraft:coal" or item.name == "minecraft:coal_block") then
                hasExtraFuel = true
            else
                print("No more extra fuel")
                hasExtraFuel = false
            end
            return true
        end
    else
        return true -- we have enough fuel
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

function faceForwards()
    if currentHeading == Headings.FORWARDS then
        return nil
    elseif currentHeading == Headings.RIGHT then
        turnLeft()
    elseif currentHeading == Headings.LEFT then
        turnRight()
    else
        turnRight()
        turnRight()
    end
end

function faceRight()
    if currentHeading == Headings.RIGHT then
        return nil
    elseif currentHeading == Headings.BACK then
        turnLeft()
    elseif currentHeading == Headings.FORWARDS then
        turnRight()
    else
        turnRight()
        turnRight()
    end
end

function faceBackwards()
    if currentHeading == Headings.BACK then
        return nil
    elseif currentHeading == Headings.RIGHT then
        turnRight()
    elseif currentHeading == Headings.LEFT then
        turnLeft()
    else
        turnRight()
        turnRight()
    end
end

function faceLeft()
    if currentHeading == Headings.LEFT then
        return nil
    elseif currentHeading == Headings.FORWARDS then
        turnLeft()
    elseif currentHeading == Headings.BACK then
        turnRight()
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

function placeStairs()
    turtle.select(stairSlot)
    turtle.place()
end

function placeTorch()
    turtle.select(torchSlot)
    turnRight()
    turnRight()
    turtle.place()
    turnLeft()
    turnLeft()
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
    turtle.forward()
end


function returnHome()
    print("Returning home...")
    digForwards()
    turtle.digUp()
    faceBackwards()
    turtle.forward()
    while coords.y < coords.home do
        placeStairs()
        goUp()
        turtle.forward()
        if coords.y % torchEvery == 0 then
            placeTorch()
        end
    end
    faceForwards()
end

function digStairs()
    print("Starting to dig stairs...")
    while coords.y > lowest_y do
        if not checkFuel() then
            break
        end
        turtle.digDown()
        digForwards()
        dig()
        goDown()
    end
    returnHome()
end

digStairs()
print("Done making stairs.")