local player = game.Players.LocalPlayer
local guiEr = require(script.guiEr)
local typingFunc = require(script.TypingFunctions)
local hbs = require(script.HoverButtonS)

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

hbs.hoverAllTextButtons()

local function startAndLoadLetters(settings)
    if settings == nil then warn("please provide settings dict!"); return end
    local timeAmt = settings.Time
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
            if inputState == Enum.UserInputState.Begin then
                typingFunc.detectedKeyInput(inputObject,false)
            end
        end,
        false,
        Enum.KeyCode.I
    )
    cas:BindAction(
        "pressO",
        function(actionName,inputState,inputObject)
            if inputState == Enum.UserInputState.Begin then
                typingFunc.detectedKeyInput(inputObject,false)
            end
        end,
        false,
        Enum.KeyCode.O
    )
    startScreen.Parent.TypingGui.Enabled = true
    guiEr.LoadTyping(4, timeAmt, 30)
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

local function loadLeaderboardGui()
    guiEr.DisableUI({startScreen.Parent.LeaderboardGui})
end

local cache = {}
function getUsernameFromUserId(userId) -- copied from roblox docs lol
	-- First, check if the cache contains the name
	if cache[userId] then return cache[userId] end
	-- Second, check if the user is already connected to the server
    local Players = game:GetService("Players")
	local player = Players:GetPlayerByUserId(userId)
	if player then
		cache[userId] = player.Name
		return player.Name
	end 
	-- If all else fails, send a request
	local name
	pcall(function()
		name = Players:GetNameFromUserIdAsync(userId)
	end)
	cache[userId] = name
	return name
end

local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local baseFrame = RS.GuiObjs.Leaderboard.PlayerFrame
local function loadGlobalLeaderboardGui()
    for i,v in pairs(startScreen.Parent.GlobalGui.ScrollingFrame:GetChildren()) do
        if not v:IsA("UIListLayout") then
            v:Destroy()
        end
    end
    local plsClear = RS.GuiObjs.Leaderboard.PlsClear:Clone()
    plsClear.Parent = startScreen.Parent.GlobalGui.ScrollingFrame
    guiEr.DisableUI({startScreen.Parent.GlobalGui})
    local globalLeaderboard = RE.RequestLeaderboard:InvokeServer()
    plsClear:Destroy()
    for i,v in ipairs(globalLeaderboard) do
        local newFrame = baseFrame:Clone()
        newFrame.Name = tostring(i)
        newFrame.WPM.Text = round(v.WPM, 2)
        newFrame.LPM.Text = round(v.LPM, 2)
        newFrame.WPM.TextSize = 100/(#newFrame.WPM.Text)
        newFrame.LPM.TextSize = 100/(#newFrame.LPM.Text)
        newFrame.Pos.Text = newFrame.Name
        newFrame.PlayerName.Text = getUsernameFromUserId(v.PlayerId)
        if newFrame.PlayerName.Text == game.Players.LocalPlayer.Name then
            newFrame.PlayerName.Text = "you"
            newFrame.BackgroundColor3 = Color3.fromRGB(134,134,134)
        end
        newFrame.Parent = startScreen.Parent.GlobalGui.ScrollingFrame
        newFrame.LayoutOrder = i
    end
end

local function loadFriendsLeaderboardGui()
    for i,v in pairs(startScreen.Parent.FriendsGui.ScrollingFrame:GetChildren()) do
        print(i,v)
        if not (v:IsA("UIListLayout")) then
            if not (v.Name == "FriendsInvite") then
                print(v)
                v:Destroy()
            else
                print(v.Name, v.Name == "FriendsInvite")
            end
        end
    end
    startScreen.Parent.FriendsGui.ScrollingFrame.FriendsInvite.LayoutOrder = 2
    startScreen.Parent.FriendsGui.ScrollingFrame.FriendsInvite.BackgroundTransparency = 1
    startScreen.Parent.FriendsGui.ScrollingFrame.FriendsInvite.TextButton.BackgroundTransparency = 1
    startScreen.Parent.FriendsGui.ScrollingFrame.FriendsInvite.TextButton.TextTransparency = 1
    startScreen.Parent.FriendsGui.ScrollingFrame.FriendsInvite.TextButton.Active = false
    local plsClear = RS.GuiObjs.Leaderboard.PlsClear:Clone()
    plsClear.Parent = startScreen.Parent.FriendsGui.ScrollingFrame
    guiEr.DisableUI({startScreen.Parent.FriendsGui})
    local friendsLeaderboard = RE.RequestFriendsLeaderboard:InvokeServer()
    plsClear:Destroy()
    print("friends", friendsLeaderboard)
    for i,v in ipairs(friendsLeaderboard) do
        local newFrame = baseFrame:Clone()
        newFrame.Name = tostring(i)
        newFrame.WPM.Text = round(v.WPM, 2)
        newFrame.LPM.Text = round(v.LPM, 2)
        newFrame.WPM.TextSize = 100/(#newFrame.WPM.Text)
        newFrame.LPM.TextSize = 100/(#newFrame.LPM.Text)
        newFrame.Pos.Text = newFrame.Name
        newFrame.PlayerName.Text = getUsernameFromUserId(v.PlayerId)
        if newFrame.PlayerName.Text == game.Players.LocalPlayer.Name then
            newFrame.PlayerName.Text = "you"
            newFrame.BackgroundColor3 = Color3.fromRGB(134,134,134)
        end
        newFrame.Parent = startScreen.Parent.FriendsGui.ScrollingFrame
        newFrame.LayoutOrder = i
    end
    startScreen.Parent.FriendsGui.ScrollingFrame.FriendsInvite.LayoutOrder = #friendsLeaderboard+1
    startScreen.Parent.FriendsGui.ScrollingFrame.FriendsInvite.BackgroundTransparency = 0
    startScreen.Parent.FriendsGui.ScrollingFrame.FriendsInvite.TextButton.BackgroundTransparency = 0
    startScreen.Parent.FriendsGui.ScrollingFrame.FriendsInvite.TextButton.TextTransparency = 0
    startScreen.Parent.FriendsGui.ScrollingFrame.FriendsInvite.TextButton.Active = true
end

local function invokeInviteFriends()
    print('invoked invite friends')
    local targetPlayer = game.Players.LocalPlayer
    local SS = game:GetService("SocialService")
    local res, canSend = pcall(function()
        return SS:CanSendGameInviteAsync(targetPlayer)
    end)
    print(res, canSend)
    if canSend then
        local res, canInvite = pcall(function()
            SS:PromptGameInvite(targetPlayer)
        end)
        print(res, canInvite)
    else
        warn("cannot prompt player to send invite!")
    end
end
startScreen.Parent.FriendsGui.ScrollingFrame.FriendsInvite.TextButton.MouseButton1Click:Connect(invokeInviteFriends)

startScreen.StartButton.MouseButton1Click:Connect(function()
    guiEr.DisableUI({startScreen.Parent.SettingGui})
end)

-- startScreen.MultiplayerButton.MouseButton1Click:Connect(loadMultiplayerGui)
startScreen.LeaderboardButton.MouseButton1Click:Connect(loadLeaderboardGui)
startScreen.Parent.LeaderboardGui.BackButton.MouseButton1Click:Connect(function()
    guiEr.DisableUI({startScreen})
end)
startScreen.Parent.FriendsGui.BackButton.MouseButton1Click:Connect(loadLeaderboardGui)
startScreen.Parent.GlobalGui.BackButton.MouseButton1Click:Connect(loadLeaderboardGui)
startScreen.Parent.LeaderboardGui.GlobalButton.MouseButton1Click:Connect(loadGlobalLeaderboardGui)
startScreen.Parent.LeaderboardGui.FriendsButton.MouseButton1Click:Connect(loadFriendsLeaderboardGui)
-- startScreen.Parent.LeaderboardGui.FriendsButton.MouseButton1Click:Connect()

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

local dataLookupTable = {
    WPM = {"Words Per Minute: ", ""},
    LPM = {"Letters Per Minute: ", ""},
    Accuracy = {"Accuracy: ", "%"}
}

RE.EndSession.OnClientEvent:Connect(function(data)
    if typingConnection ~= nil then
        typingConnection:Disconnect()
        typingConnection = nil
    end
    local statsGui = startScreen.Parent.StatsGui
    for i,v in pairs(data) do
        print(i,v)
        statsGui[i].Text = dataLookupTable[i][1]..v..dataLookupTable[i][2]
    end
    statsGui.Enabled = true
    guiEr.DisableUI({statsGui,startScreen.Parent.TypingGui})
    guiEr.TweenProperty(startScreen.Parent.TypingGui.TimeText,TweenInfo.new(0.5),{TextTransparency = 1})
end)

RE.Timer.OnClientEvent:Connect(function(timeLeft)
    local timeText = startScreen.Parent.TypingGui.TimeText
    startScreen.Parent.TypingGui.TimeText.Text = tostring(timeLeft)
end)

local settingGui = player.PlayerGui.TypingScreen.SettingGui
local function getSettings()
    local settings = {}
    for i,v in pairs(settingGui.SettingsSetters:GetChildren()) do
        if v:FindFirstChild("TextBox") ~= nil then
            if v.TextBox.Text == "" then
                settings[v.Name] = v.TextBox.PlaceholderText
            else
                settings[v.Name] = v.TextBox.Text
                v.TextBox.PlaceholderText = v.TextBox.Text
                v.TextBox.Text = ""
            end
        end
    end
    return settings
end

local restartButtonDeb = true
startScreen.Parent.TypingGui.RestartButton.MouseButton1Click:Connect(function()
    if not restartButtonDeb then return end
    guiEr.TweenProperty(startScreen.Parent.TypingGui.TimeText,TweenInfo.new(0.5),{TextTransparency = 0})
    RE.StopTimer:InvokeServer()
    guiEr.EndSession()
    startAndLoadLetters(getSettings())
    -- guiEr.DisableUI({startScreen.Parent.TypingGui,startScreen.Parent.LetterGui})
    guiEr.TweenScreenProperty(startScreen.Parent.StatsGui,TweenInfo.new(0.5),{TextTransparency = 1})
    restartButtonDeb = false
    wait(1)
    restartButtonDeb = true
end)

settingGui.StartButton.MouseButton1Click:Connect(function()
    guiEr.DisableUI({startScreen.Parent.TypingGui, startScreen.Parent.LetterGui})
    startAndLoadLetters(getSettings())
end)
settingGui.BackButton.MouseButton1Click:Connect(function()
    guiEr.DisableUI({startScreen})
end)