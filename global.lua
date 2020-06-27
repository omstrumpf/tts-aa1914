-- Axis & Allies 1914 Scripting
--
-- Battle Board: counts hits automatically based on dice zones
-- Spawning: units, chits, etc. bound to numpad keys. color/power aware.
-- Income: tracks total income for each team, and adds buttons to collect income for a turn.

------ BAG GUIDS
trashBag = "2d7e33"

chitBagAllies = "f5fe52"
chitBagCP = "1a0ff7"

diceBagAllies = "f1f43e"
diceBagCP = "604fca"

controlMarkerBags = {
    AH = "870337",
    Russia = "5b2812",
    Germany = "c60dfa",
    France = "115b5b",
    UK = "2bfbad",
    Ottoman = "518d50",
    Italy = "a2f3b7",
    America = "c9f82c"
}

infantryBags = {
    AH = "7345fe",
    Russia = "5ac851",
    Germany = "b02801",
    France = "e84f8b",
    UK = "3d7b92",
    Ottoman = "a28e5e",
    Italy = "862066",
    America = "c3385b"
}

artilleryBags = {
    AH = "c3fb3f",
    Russia = "c73a2f",
    Germany = "8a4e7c",
    France = "b9a2f4",
    UK = "723bca",
    Ottoman = "e9b62c",
    Italy = "f2521b",
    America = "8a6930"
}

fighterBags = {
    AH = "8311fd",
    Russia = "1c15e1",
    Germany = "ff9df1",
    France = "ba274e",
    UK = "3de88b",
    Ottoman = "447711",
    Italy = "1d3775",
    America = "bef166"
}

tankBags = {
    AH = "cc79ce",
    Russia = "6141a2",
    Germany = "7a3027",
    France = "61929f",
    UK = "98323e",
    Ottoman = "2e4b2f",
    Italy = "bb4bb2",
    America = "7489d0"
}

------ INCOME TRACKING GUIDS
incomeCounters = {
    AH = "1e8e3f",
    Russia = "ec4c71",
    Germany = "6bbe86",
    France = "aefeac",
    UK = "1cb674",
    Ottoman = "bbc11b",
    Italy = "47ca8f",
    America = "261ee3"
}

ipcCounters = {
    AH = "2337a8",
    Russia = "53f7f5",
    Germany = "36208a",
    France = "e354a7",
    UK = "49057b",
    Ottoman = "3943e1",
    Italy = "a89fda",
    America = "201fd0"
}

collectIncomeButtons = {
    AH = "802c51",
    Russia = "fcbe97",
    Germany = "b4bc82",
    France = "24aadd",
    UK = "356095",
    Ottoman = "b32b30",
    Italy = "8fe290",
    America = "83b1b4"
}

------ BATTLE GUIDS
battleZones = {
    {"9680a3", {4, 4}},
    {"55c57c", {3, 4}},
    {"e7e104", {1, 2}},
    {"aec3e7", {3, 3}},
    {"634bcf", {2, 0}},
    {"9ca48a", {2, 2}},
    {"e75d82", {3, 3}},
    {"ba4a49", {4, 4}},
    {"928c97", {3, 4}},
    {"255777", {4, 4}}
}

battleBoardLand = "12c5ea"
battleBoardNaval = "a00b55"

hitCounterAllies = "585420"
hitCounterCP = "388fe9"

totalIncomeAllies = "844524"
totalIncomeCP = "79c854"

------ POWERS
powers = {
    "Germany",
    "AH",
    "Ottoman",
    "France",
    "America",
    "UK",
    "Russia",
    "Italy"
}

colorToPower = {
    Red = "Germany",
    Green = "AH",
    Teal = "Ottoman",
    Blue = "France",
    White = "America",
    Yellow = "UK",
    Brown = "Russia",
    Orange = "Italy"
}

colorToTeam = {
    Red = "CP",
    Green = "CP",
    Teal = "CP",
    Blue = "Allies",
    White = "Allies",
    Yellow = "Allies",
    Brown = "Allies",
    Orange = "Allies"
}

powerToTeam = {
    Germany = "CP",
    AH = "CP",
    Ottoman = "CP",
    France = "Allies",
    America = "Allies",
    UK = "Allies",
    Russia = "Allies",
    Italy = "Allies"
}

powerToString = {
    Germany = "Germany",
    AH = "Austria-Hungary",
    Ottoman = "Ottoman Empire",
    France = "France",
    America = "America",
    UK = "United Kingdom",
    Russia = "Russia",
    Italy = "Italy"
}

------ OBJECT SPAWNING
local function placeMiniatureFromBag(bag, position, rotation)
    local rotation1 = rotation or {0, 0, 0}
    
    local raisedPosition = {position[1], position[2] + 2, position[3]}

    getObjectFromGUID(bag).takeObject({
            position = raisedPosition,
            smooth = false,
            rotation = rotation1
    })
end

------ INCOME TRACKING
local function updateIPCTotals()
    local alliesTotal = 0
    local cpTotal = 0
    
    for power, counterGUID in pairs(incomeCounters) do
        local counter = getObjectFromGUID(counterGUID).Counter
        local value = counter.getValue()
    
        if powerToTeam[power] == "Allies" then
            alliesTotal = alliesTotal + value
        elseif powerToTeam[power] == "CP" then
            cpTotal = cpTotal + value
        end
    end
    
    local alliesCounter = getObjectFromGUID(totalIncomeAllies).Counter
    local cpCounter = getObjectFromGUID(totalIncomeCP).Counter
    
    alliesCounter.setValue(alliesTotal)
    cpCounter.setValue(cpTotal)
end

local function collectIncome(power)
    local incomeCounter = getObjectFromGUID(incomeCounters[power]).Counter
    local ipcCounter = getObjectFromGUID(ipcCounters[power]).Counter

    ipcCounter.setValue(ipcCounter.getValue() + incomeCounter.getValue())

    broadcastToAll(powerToString[power] .. " has collected " .. incomeCounter.getValue() .. " IPCs for the turn.")
end

function collectIncomeBtn(obj, string_player_color, alt_click)
    if alt_click then
        return
    end
        
    for i,power in ipairs(powers) do
        if obj.guid == collectIncomeButtons[power] then
            collectIncome(power)
            return
        end
    end
    
    print("Scripting error: power not found")
end

------ BATTLE STRIP
local function getBattleBoardState()
    -- An object's GUID changes when state changes, so we cannot simply get the stateId of the battle board.
    -- Checking for existence on the naval battle board works.

    if getObjectFromGUID(battleBoardNaval) then
        return 2
    else
        return 1
    end
end

local function updateBattleTotals()
    local alliesTotal = 0
    local cpTotal = 0

    local battleBoardState = getBattleBoardState()
    
    -- Ensure that we only count each die once, in case a die is sitting on the borders of multiple zones
    local countedDice = {}

    for i, zoneData in pairs(battleZones) do
        local zone = getObjectFromGUID(zoneData[1])
        local threshold = zoneData[2][battleBoardState]

        for i, die in ipairs(zone.getObjects()) do
            if countedDice[die.getGUID()] == nil then
                countedDice[die.getGUID()] = true

                if die.getName() == "Allied Power Die" and die.getRotationValue() <= threshold then
                    alliesTotal = alliesTotal + 1
                elseif die.getName() == "Central Power Die" and die.getRotationValue() <= threshold then
                    cpTotal = cpTotal + 1
                end
            end
        end
    end

    getObjectFromGUID(hitCounterAllies).Counter.setValue(alliesTotal)
    getObjectFromGUID(hitCounterCP).Counter.setValue(cpTotal)
end

------ DELETE FUNCTION
local function deleteSelected(player)
    local objs = {}
    
    for _,o in ipairs(player.getSelectedObjects()) do objs[#objs+1] = o end
    for _,o in ipairs(player.getHoldingObjects()) do objs[#objs+1] = o end
    
    if player.getHoverObject() then
        objs[#objs+1] = player.getHoverObject()
    end

    local trashBag = getObjectFromGUID(trashBag)

    for _,o in ipairs(objs) do
        if not o.getLock() then
            trashBag.putObject(o)
        end
    end
end

------ TTS CALLBACKS
function onLoad()
    for power, buttonGUID in pairs(collectIncomeButtons) do
        local buttonObj = getObjectFromGUID(buttonGUID)
        
        buttonObj.createButton({
            click_function = "collectIncomeBtn",
            scale = {15, 15, 15}
        })
    end
end

updateCounter = 0
function onUpdate()
    updateCounter = updateCounter + 1
    
    if updateCounter % 10 == 0 then
        updateIPCTotals()
    end
    
    if updateCounter % 10 == 0 then
        updateBattleTotals()
    end
end

function onScriptingButtonDown(index, playerColor)
    local position = Player[playerColor].getPointerPosition()
    local power = colorToPower[playerColor]
    local team = colorToTeam[playerColor]

    if index == 10 then -- Numpad 0: delete
        deleteSelected(Player[playerColor])
    elseif index == 1 then -- Numpad 1: Dice
        if team == "CP" then
            placeMiniatureFromBag(diceBagCP, position, {0, 0, 180})
        elseif team == "Allies" then
            placeMiniatureFromBag(diceBagAllies, position, {0, 0, 180})
        end
    elseif index == 2 then -- Numpad 2: Control Marker
        placeMiniatureFromBag(controlMarkerBags[power], position)
    elseif index == 3 then -- Numpad 3: Chit
        if team == "CP" then
            placeMiniatureFromBag(chitBagCP, position)
        elseif team == "Allies" then
            placeMiniatureFromBag(chitBagAllies, position)
        end
    elseif index == 4 then -- Numpad 4: Infantry
        placeMiniatureFromBag(infantryBags[power], position)
    elseif index == 5 then -- Numpad 5: Artillery
        placeMiniatureFromBag(artilleryBags[power], position)
    elseif index == 6 then -- Numpad 6: Fighter
        placeMiniatureFromBag(fighterBags[power], position)
    elseif index == 7 then -- Numpad 7: Tank
        placeMiniatureFromBag(tankBags[power], position)
    elseif index == 8 then -- Numpad 8: Unassigned
    elseif index == 9 then -- Numpad 9: Unassigned
    end
end