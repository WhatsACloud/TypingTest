local guiEr = {}

local plr = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local plrGui = plr:WaitForChild("PlayerGui")
local sharedVariables = require(RS.Common.SharedVariables)
local TS = game:GetService("TweenService")
local reqLetterRemoteFunc = RS.RE.RequestLetters
local lettersPerRowVar

local function getDictLength(dict)
    local amt = 0
    for i,v in pairs(dict) do
        amt = amt + 1
    end
    return amt
end

local soundS = require(script.Parent.SoundS)
function guiEr.PlayHoverSound()
    soundS.playSound(3314301151, {Name = "Hover"})
end

local function getHighestElement(frame)
    local highestValue = 0
    for i,v in pairs(frame:GetChildren()) do
        if tonumber(v.Name) > highestValue then
            highestValue = tonumber(v.Name)
        end
    end
    return highestValue
end

local function getLowestElement(frame)
    local lowestValue = 1000000000
    for i,v in pairs(frame:GetChildren()) do
        if tonumber(v.Name) < lowestValue then
            lowestValue = tonumber(v.Name)
        end
    end
    return lowestValue
end

function guiEr.MakeRootFrame(parent, rootPosition)
    local rootFrame = Instance.new("Frame", parent)
    rootFrame.Position = rootPosition
    rootFrame.Size = UDim2.new(0.6,0,0.4)
    rootFrame.BackgroundTransparency = 1
    rootFrame.BackgroundColor3 = Color3.fromRGB(128,128,128)
    return rootFrame
end

function guiEr.MakeFrameForLetters(currentRow, rootFrame, oldRow, specificRow)
    local newFrame = Instance.new("Frame",rootFrame)
    if specificRow == nil then
        newFrame.Name = tostring(currentRow)
    else
        newFrame.Name = tostring(specificRow+1)
    end
    if oldRow == nil then
    if currentRow > 1 or specificRow ~= nil then
            print(currentRow, "specific row", specificRow)
            if specificRow == nil then
                newFrame.Position = rootFrame[tostring(currentRow-1)].Position + UDim2.new(0,0,0.15,0)
            else
                newFrame.Position = rootFrame[tostring(specificRow)].Position + UDim2.new(0,0,0.15,0)
            end
        else
            newFrame.Position = UDim2.new(0,0,0,0)
        end
    else
        newFrame.Position = rootFrame[tostring(getLowestElement(rootFrame))].Position + UDim2.new(0,0,-0.15,0)
    end
    newFrame.Size = UDim2.new(1,0,0.3,0)
    newFrame.BackgroundTransparency = 1
    --newFrame.BackgroundColor3 = Color3.fromRGB(math.random(1,255),math.random(1,255),math.random(1,255))
    return newFrame
end

function guiEr.MakeLetter(frame, letter, letterIndex, toNameLetter)
    local newLetter = Instance.new("TextLabel", frame)
    newLetter.Text = letter
    newLetter.BackgroundTransparency = 1
    newLetter.TextScaled = true
    newLetter.TextColor3 = Color3.fromRGB(128,128,128)
    -- newLetter.Size = UDim2.new(0,200,0,50)
    newLetter.Size = UDim2.new(0.2,0,1,0)
    newLetter.Position = UDim2.new(0.045*letterIndex,0,0,0)
    newLetter.Name = tostring(toNameLetter)
    newLetter.Font = Enum.Font.Code
    return newLetter
end

function guiEr.LoadTyping(rowAmt, totalTime, lettersPerRow)
    lettersPerRowVar = lettersPerRow
    local lettersList
    local typingScreen = plrGui:WaitForChild("TypingScreen")
    local rootPosition = UDim2.new(0.1,0,0.2,0)
    local placeHolder
    lettersList,placeHolder, lettersPerRow, rowArray = reqLetterRemoteFunc:InvokeServer(rowAmt, totalTime, lettersPerRow, true)
    local rootFrame
    rootFrame = guiEr.MakeRootFrame(typingScreen.LetterGui, rootPosition)
    local letterCount = #lettersList
    local currentIndex = 0 -- for positioning the letter
    local otherCurrentIndex = 0 -- for naming the letter
    for i,v in ipairs(rowArray) do
        guiEr.MakeFrameForLetters(i, rootFrame)
        for index, val in ipairs(v) do
            currentIndex = currentIndex + 1
            otherCurrentIndex = otherCurrentIndex + 1
            local letter = guiEr.MakeLetter(rootFrame[tostring(i)], val, currentIndex, otherCurrentIndex, lettersPerRow)
            if i >= 4 then
                letter.TextTransparency = 1
            end
        end
        currentIndex = 0
    end
    guiEr.TweenScreenProperty(plrGui.TypingScreen.TypingGui,TweenInfo.new(0.01),{TextTransparency = 1})
    guiEr.TweenScreenProperty(plrGui.TypingScreen.TypingGui,TweenInfo.new(0.5),{TextTransparency = 0})
    plrGui.TypingScreen.TypingGui.Enabled = true
end

function guiEr.DisableUI(exceptions)
    for i,v in pairs(plrGui.TypingScreen:GetChildren()) do
        local transparency = 1
        local enabled = false
        for _,exception in ipairs(exceptions) do
            if v == exception then
                transparency = 0
                enabled = true
                break
            end
        end
        if not (v.Name == "BackgroundGui") then
            v.Enabled = true
            for index,gui in pairs(v:GetDescendants()) do
                success, errData = pcall(function()
                    local plsIgnore = false
                    if gui:FindFirstChild("ignore") then
                        if gui:FindFirstChild("ignore"):IsA("StringValue") then
                            plsIgnore = true
                        end
                    end
                    if gui:IsA("ScrollingFrame") then
                        gui.BackgroundTransparency = 1
                        gui.ScrollBarImageTransparency = 1
                        if not plsIgnore then
                            local tween = TS:Create(gui, TweenInfo.new(0.5), {ScrollBarImageTransparency = transparency})
                            tween:Play()
                        end
                    elseif gui:IsA("Frame") then
                        gui.BackgroundTransparency = 1
                        if not plsIgnore then
                            local tween = TS:Create(gui,TweenInfo.new(0.5),{BackgroundTransparency = transparency})
                            tween:Play()
                        end
                    elseif not gui:IsA("ScreenGui") and not gui:IsA("LocalScript") then
                        gui.BackgroundTransparency = 1
                        gui.TextTransparency = 1
                        local tween = TS:Create(gui,TweenInfo.new(0.5),{TextTransparency = transparency})
                        tween:Play()
                        pcall(function()
                            if gui:IsA("TextButton") and (not plsIgnore) then
                                local tween2 = TS:Create(gui,TweenInfo.new(0.5),{BackgroundTransparency = transparency})
                                tween2:Play()
                            end
                        end)
                    end
                end)
            end
            coroutine.wrap(
                function()
                    wait(0.5)
                    v.Enabled = enabled
                end
            )()
        end
    end
end

function guiEr.TweenProperty(gui,twInfo,properties)
    local tween = TS:Create(gui,twInfo,properties)
    tween:Play()
end

function guiEr.TweenRow(frame,color,addPosition, callbackFunc)
    if callbackFunc then
        print(callbackFunc)
        coroutine.wrap(callbackFunc)()
    end
    if color ~= nil then
        guiEr.TweenScreenProperty(frame,
            TweenInfo.new(0.5),
            {TextColor3 = color}
        )
    end
    guiEr.TweenProperty(frame,TweenInfo.new(0.5),
    {Position = frame.Position + addPosition})
end

local grey = Color3.fromRGB(128,128,128)
local lightGrey = Color3.fromRGB(105,105,105)
local backgroundColor = Color3.fromRGB(43, 43, 43)
local up = UDim2.new(0,0,-0.15,0)
local down = UDim2.new(0,0,0.15,0)

local function checkForOverflow(currentIndex, indexToStop, lettersPerRow)
    local overflowAmt = 0
    while not (currentIndex >= indexToStop) do
        if (currentIndex % lettersPerRow) == 0 or currentIndex == 1 then
            overflowAmt = overflowAmt + 1
        end
        currentIndex = currentIndex + 1
    end
    return overflowAmt
end

local function createNewRow(rootFrame, nextRow)
    local rowAmt = 1
    local lettersList,letter, lettersPerRow, rowArray = reqLetterRemoteFunc:InvokeServer(rowAmt, nil, nil, false, true)
    local letterCount = #lettersList
    -- local makeAmt = checkForOverflow(letter, letterCount, lettersPerRow)
    local currentIndex = 0
    local highestFrame = rootFrame[tostring(getHighestElement(rootFrame))]
    local otherCurrentIndex = getHighestElement(highestFrame)
    local rowToReadFrom = nextRow
    guiEr.MakeFrameForLetters(rowToReadFrom, rootFrame)
    for index, val in ipairs(rowArray[rowToReadFrom]) do
        currentIndex = currentIndex + 1
        otherCurrentIndex = otherCurrentIndex + 1
        local letterObject = guiEr.MakeLetter(rootFrame[tostring(rowToReadFrom)], val, currentIndex, otherCurrentIndex)
        if getDictLength(rootFrame:GetChildren()) >= 5 then
            letterObject.TextTransparency = 1
        end
    end
end

local unloadedRowsAbove = {}
local red = Color3.fromRGB(255,0,0)
local white = Color3.fromRGB(255,255,255)

local prevRow = 1
local function unloadRow(rowToUnload, frame, array)
    local letterGui = plrGui.TypingScreen.LetterGui
    local object = {}
    for i,v in pairs(frame[tostring(rowToUnload)]:GetChildren()) do
        local letterObjectTable = {Letter = v.Text, letterIndex = v.Name, Position = v.Position}
        if v.TextColor3 == red then
            letterObjectTable.Value = false
            object[#object+1] = letterObjectTable
        elseif v.TextColor3 == white then
            letterObjectTable.Value = true
            object[#object+1] = letterObjectTable
        else
            letterObjectTable.Value = nil
            object[#object+1] = letterObjectTable -- only adding this for code readability
        end
    end
    array[#array+1] = object
    letterGui.Frame[tostring(rowToUnload)]:Destroy()
    return array
end

local function reloadRow(ParentFrame, array, isOld, specificRow)
    local letterGui = plrGui.TypingScreen.LetterGui
    local row = array[#array]
    local leastFrameNumber = 100000000000
    for _,v in pairs(ParentFrame:GetChildren()) do
        if tonumber(v.Name) < leastFrameNumber then
            leastFrameNumber = tonumber(v.Name)
        end
    end
    print(#array)
    local frame = guiEr.MakeFrameForLetters(#array, ParentFrame, isOld, specificRow)
    array[#array] = nil
    --[[ local highestFrame = ParentFrame[tostring(getHighestElement(ParentFrame))]
    local currentIndex = getHighestElement(highestFrame) ]]--
    for i,v in ipairs(row) do
        -- currentIndex = currentIndex + 1
        -- warn("letter index", v.letterIndex)
        local letter = guiEr.MakeLetter(frame, v.Letter, v.letterIndex % lettersPerRowVar, v.letterIndex)
        letter.TextTransparency = 1
        if v.Value then
            letter.TextColor3 = white
        else
            letter.TextColor3 = red
        end
    end
    return array
end

local function moveRowsUp(frame,currentActualRow)
    local row = prevRow - 1
    warn(row, "ffeieifeifdfdskfsdkfkf")
    -- for prev prev row
    if getDictLength(frame:GetChildren()) > 5 then
        unloadedRowsAbove = unloadRow(row-1, frame, unloadedRowsAbove)
    end
    -- for prev row
    guiEr.TweenScreenProperty(frame[tostring(row)],TweenInfo.new(0.5),{TextTransparency = 1})
    guiEr.TweenRow(frame[tostring(row)],nil,up)
    -- for current row
    guiEr.TweenRow(frame[tostring(currentActualRow)],grey,up)
    -- second newest row to become visible
    local highestFrameNumber = getHighestElement(frame)
    guiEr.TweenScreenProperty(frame[tostring(highestFrameNumber-1)],TweenInfo.new(0.5),{TextTransparency = 0})
    guiEr.TweenRow(frame[tostring(highestFrameNumber-1)],grey,up)
    -- handles middle row
    guiEr.TweenRow(frame[tostring(getHighestElement(frame)-2)],grey,up)
    --newest row
    guiEr.TweenRow(frame[tostring(highestFrameNumber)],grey,up)
end

local function moveRowsDown(frame,currentActualRow)
    local row = prevRow - 1
    warn(row, "ffeieifeifdfdskfsdkfkf")
    -- for prev prev row
    if #unloadedRowsAbove > 0 then
        unloadedRowsAbove = reloadRow(frame, unloadedRowsAbove, true)
    end
    -- for prev row
    guiEr.TweenScreenProperty(frame[tostring(row)],TweenInfo.new(0.5),{TextTransparency = 0})
    guiEr.TweenRow(frame[tostring(row)],nil,down)
    -- for current row
    guiEr.TweenScreenProperty(frame[tostring(currentActualRow)],TweenInfo.new(0.5),{TextTransparency = 0})
    guiEr.TweenRow(frame[tostring(currentActualRow)],nil,down)
    -- second newest row to become invisible
    local highestFrameNumber = getHighestElement(frame)
    guiEr.TweenScreenProperty(frame[tostring(highestFrameNumber-1)],TweenInfo.new(0.5),{TextTransparency = 1})
    guiEr.TweenRow(frame[tostring(highestFrameNumber-1)],grey,down)
    -- handles middle row
    guiEr.TweenRow(frame[tostring(getHighestElement(frame)-2)],grey,down)
    -- handles last row
    if getHighestElement(frame) >= 5 then
        frame[tostring(getHighestElement(frame))]:Destroy()
    end
end

local checkRowDeb = false
function guiEr.CheckRow(currentActualRow)
    local lettersPerRow = plrGui.TypingScreen.LetterGui.Frame:FindFirstChildOfClass("Frame"):GetChildren()
    local per = 0
    for i,v in pairs(lettersPerRow) do
        per = per + 1
    end
    lettersPerRow = per+1
    local letterGui = plrGui.TypingScreen.LetterGui
    if checkRowDeb then return end
    checkRowDeb = true
    coroutine.wrap(function()
        wait(0.5)
        checkRowDeb = false
    end)()
    if prevRow < currentActualRow then
        warn("prevRow is less than currentActualRow", prevRow, currentActualRow)
        local lastRowNumber = 0
        for _,v in pairs(letterGui.Frame:GetChildren()) do
            if tonumber(v.Name) > lastRowNumber then
                lastRowNumber = tonumber(v.Name)
            end
        end
        prevRow = prevRow + 1
        createNewRow(letterGui.Frame, lastRowNumber+1)
        moveRowsUp(letterGui.Frame,currentActualRow)
    elseif prevRow > currentActualRow then
        warn("prevRow is more than currentActualRow", prevRow, currentActualRow)
        prevRow = prevRow - 1
        moveRowsDown(letterGui.Frame,currentActualRow)
    end
end

function guiEr.EndSession()
    prevRow = 1
    RS.RE.EndSession:FireServer()
    guiEr.TweenScreenProperty(plrGui.TypingScreen.LetterGui,TweenInfo.new(0.5),{TextTransparency = 1})
    wait(0.5)
    plrGui.TypingScreen.LetterGui:ClearAllChildren()
end

function guiEr.TweenTextColor(textObjectName,color)
    textObjectName = tostring(textObjectName)
    local lettersPerRow = plrGui.TypingScreen.LetterGui.Frame:FindFirstChildOfClass("Frame"):GetChildren()
    local per = 0
    for i,v in pairs(lettersPerRow) do
        per = per + 1
    end
    lettersPerRow = per+1
    local currentActualRow
    local textObject
    for i,v in pairs(plrGui.TypingScreen.LetterGui.Frame:GetChildren()) do
        for a,b in pairs(v:GetChildren()) do
            if textObjectName == b.Name then
                currentActualRow = tonumber(v.Name)
                textObject = b
                break
            end
        end
    end
    local tween = TS:Create(textObject,TweenInfo.new(0.01),{TextColor3 = color})
    guiEr.CheckRow(currentActualRow)
    tween:Play()
end

function guiEr.TweenScreenProperty(screenGui,twInfo,properties)
    for i,v in pairs(screenGui:GetChildren()) do
        pcall(function()
            local tween = TS:Create(v,twInfo,properties)
            tween:Play()
        end)
    end
end

return guiEr