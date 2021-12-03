local player = game.Players.LocalPlayer
local guiEr = require(script.guiEr)
local typingFunc = require(script.TypingFunctions)

require(script.DisableResetScript).DisableReset()

local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local sharedVariables = require(RS.Common.SharedVariables)

local RE = RS.RE

local typingConnection

local startScreen = player.PlayerGui:WaitForChild("TypingScreen").StartScreen
startScreen.Enabled = true
local TS = game:GetService("TweenService")
local startButtonDeb = true

local function startAndLoadLetters()
    print(startButtonDeb)
    if not startButtonDeb then return end
    print("pressed start button")
    if typingConnection ~= nil then
        typingConnection:Disconnect()
    end
    typingConnection = UIS.InputBegan:Connect(typingFunc.detectedKeyInput)
    local cas = game:GetService("ContextActionService")
    cas:BindAction(
        "pressI",
        function(actionName,inputState,inputObject)
            typingFunc.detectedKeyInput(inputObject,false)
        end,
        false,
        Enum.KeyCode.I
    )
    cas:BindAction(
        "pressO",
        function(actionName,inputState,inputObject)
            typingFunc.detectedKeyInput(inputObject,false)
        end,
        false,
        Enum.KeyCode.O
    )
    startScreen.Parent.TypingGui.Enabled = true
    guiEr.LoadTyping(4, 1000, 30)
    guiEr.TweenScreenProperty(startScreen,TweenInfo.new(0.5),{TextTransparency = 1})
    guiEr.TweenScreenProperty(startScreen.Parent.TypingGui,TweenInfo.new(0.5),{TextTransparency = 0})
    guiEr.TweenScreenProperty(startScreen.Parent.LetterGui,TweenInfo.new(0.5),{TextTransparency = 0})
    wait(0.5)
    startScreen.Enabled = false
    startScreen.Parent.TypingGui.Enabled = true
    startScreen.Parent.LetterGui.Enabled = true
    coroutine.wrap(function()
    startButtonDeb = false
    wait(1)
    startButtonDeb = true
    end)()
end

local function loadMultiplayerGui()
    guiEr.DisableUI({startScreen.Parent.MultiplayerGui})
end

startScreen.StartButton.MouseButton1Click:Connect(startAndLoadLetters)

startScreen.MultiplayerButton.MouseButton1Click:Connect(loadMultiplayerGui)
local multiplayerGui = startScreen.Parent.MultiplayerGui.Background

local function loadLobbyGui()
    guiEr.DisableUI({startScreen.Parent.LobbyGui})
end

multiplayerGui.BackButton.MouseButton1Click:Connect(function()
    guiEr.DisableUI({startScreen})
end)
multiplayerGui.CreateButton.MouseButton1Click:Connect(loadLobbyGui)

startScreen.Parent.TypingGui.BackButton.MouseButton1Click:Connect(function()
    if typingConnection ~= nil then
        typingConnection:Disconnect()
        typingConnection = nil
    end
    coroutine.wrap(guiEr.EndSession)()
    coroutine.wrap(guiEr.DisableUI)({startScreen})
end)

local restartButtonDeb = true
startScreen.Parent.TypingGui.RestartButton.MouseButton1Click:Connect(function()
    if not restartButtonDeb then return end
    guiEr.TweenProperty(startScreen.Parent.TypingGui.TimeText,TweenInfo.new(0.5),{TextTransparency = 0})
    RE.StopTimer:InvokeServer()
    guiEr.EndSession()
    startAndLoadLetters()
    -- guiEr.DisableUI({startScreen.Parent.TypingGui,startScreen.Parent.LetterGui})
    guiEr.TweenScreenProperty(startScreen.Parent.StatsGui,TweenInfo.new(0.5),{TextTransparency = 1})
    restartButtonDeb = false
    wait(1)
    restartButtonDeb = true
end)

local dataLookupTable = {
    WPM = "Words Per Minute: "
}

RE.EndSession.OnClientEvent:Connect(function(data)
    if typingConnection ~= nil then
        typingConnection:Disconnect()
        typingConnection = nil
    end
    local statsGui = startScreen.Parent.StatsGui
    for i,v in pairs(data) do
        print(i,v)
        statsGui[i].Text = dataLookupTable[i]..v
    end
    statsGui.Enabled = true
    guiEr.DisableUI({statsGui,startScreen.Parent.TypingGui})
    guiEr.TweenProperty(startScreen.Parent.TypingGui.TimeText,TweenInfo.new(0.5),{TextTransparency = 1})
end)

RE.Timer.OnClientEvent:Connect(function(timeLeft)
    local timeText = startScreen.Parent.TypingGui.TimeText
    startScreen.Parent.TypingGui.TimeText.Text = tostring(timeLeft)
end)