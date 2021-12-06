local RS = game:GetService("ReplicatedStorage")
local variables = require(RS.Common.SharedVariables)
local session = require(script.SessionClass)
local multiSession = require(script.MultiSessionClass)
local psh = require(script.PlayerStatsHelper)
local dsh = require(script.DatastoreHelper)
local lbh = require(script.LeaderboardHelper)
local keyMap = variables.KeyMap
local RE = game:GetService("ReplicatedStorage").RE
local players = game:GetService("Players")
local inputRF = RE.Input

local keyMapKeys = variables.keyMapKeys

local function randLetter()
    local selectedKey = keyMapKeys[math.random(1,#keyMapKeys)]
    return sharedVariables.KeyMap[selectedKey]
end

local function startSession(plr, totalTime, lettersPerRow)
    --session:PrintAttributesMain()
    local newSession = session:New(nil,plr, totalTime, lettersPerRow)
    --session:PrintAttributesMain()
    RE.Timer:FireClient(plr,totalTime)
    return newSession
end

local function typeLetter(player,letter)
    local textLetter = keyMap[letter]
    if not textLetter then
        return nil
    end
    
    local playerSession = session:FindSessionByPlayer(player)
    local actualLetter = playerSession.letterIndexArr[playerSession.currentLetterIndex]
    if not playerSession.Started then
        playerSession.Started = true
        playerSession:StartTimer(playerSession.TotalTime)
    end
    playerSession.currentLetterIndex = playerSession.currentLetterIndex + 1
    
    -- print(actualLetter,type(actualLetter),textLetter,type(textLetter),playerSession.currentLetterIndex-1)
    if actualLetter == textLetter then
        table.insert(playerSession.lettersTyped, #playerSession.lettersTyped+1, {value = 1, letter = actualLetter})
        return true,playerSession.currentLetterIndex-1
    end
    table.insert(playerSession.lettersTyped, #playerSession.lettersTyped+1, {value = 0, letter = actualLetter})
    return false,playerSession.currentLetterIndex-1
end

local function deleteLetter(player)
    local playerSession = session:FindSessionByPlayer(player)
    if (playerSession.currentLetterIndex - 1) > 0 then
        playerSession.currentLetterIndex = playerSession.currentLetterIndex - 1
        table.remove(playerSession.lettersTyped, #playerSession.lettersTyped)
        if actualLetter == " " then
            table.remove(playerSession.lettersTyped, #playerSession.wordsTyped)
        end
        return playerSession.currentLetterIndex
    end
    return false
end
inputRF.OnServerInvoke = typeLetter
RE.DeleteLetter.OnServerInvoke = deleteLetter
RE.RequestLetters.OnServerInvoke = function(plr, rowAmt, totalTime, lettersPerRow, isNew, requestingRow)
    local plrSession
    if isNew then
        if session:FindSessionByPlayer(plr) then
            session:FindSessionByPlayer(plr):Remove()
        end
        plrSession = startSession(plr, totalTime, lettersPerRow)
    else
        plrSession = session:FindSessionByPlayer(plr)
    end
    local letterArray,pastLength, rowArray = plrSession:LoadTyping(rowAmt, requestingRow)
    return letterArray,pastLength,plrSession.LettersPerRow, rowArray
end

RE.EndSession.OnServerEvent:Connect(function(plr)
    local playerSession = session:FindSessionByPlayer(plr)
    playerSession:Remove()
end)

RE.StopTimer.OnServerInvoke = function(plr)
    local playerSession = session:FindSessionByPlayer(plr)
    playerSession.Started = false
    if playerSession.Timer > 0 then
        repeat wait() until playerSession.Started == true
    end
    return
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DATASTORES

local reqLeaderboardRF = RE.RequestLeaderboard
local reqFriendsLeaderboardRF = RE.RequestFriendsLeaderboard
local STATS = "Statistics"

local function returnLeaderboard(player)
    return lbh.GetLeaderboard()
end

local function returnFriendsLeaderboard(player)
    return lbh.GetFriends(player)
end

reqLeaderboardRF.OnServerInvoke = returnLeaderboard
reqFriendsLeaderboardRF.OnServerInvoke = returnFriendsLeaderboard

players.PlayerAdded:Connect(function(player)
    repeat wait() until player.Character ~= nil
    local char = player.Character
    char.Humanoid.WalkSpeed = 0
    char.Humanoid.JumpHeight = 0
    local playerData = dsh.RequestDatastore(STATS, player.UserId)
    if playerData then
        psh:Set(player, playerData)
        -- insert triggering some remote event or smth
    else
        dsh.CreateDatastoreEntry(STATS, player.UserId, dsh.DefaultValues[STATS])
        psh:Set(player, dsh.DefaultValues[STATS])
    end
    if playerData then
        lbh.CacheAndUpdateFriends(player, playerData)
    else
        lbh.CacheAndUpdateFriends(player, dsh.DefaultValues[STATS])
    end
end)

players.PlayerRemoving:Connect(function(player)
    local playerData = psh:Get(player)
    dsh.CreateDatastoreEntry(STATS, player.UserId, playerData)
    psh:Remove(player)
    lbh.RemoveFriends(player)
end)

local function compareAndUpdateLeaderboards()
    for _,player in pairs(game.Players:GetPlayers()) do
        print(player)
        local tab = psh:Get(player)
        tab.PlayerId = player.UserId
        lbh.AttemptAdd(player, tab)
    end
    print("asfhefifhfdisf")
    lbh.updateLeaderboardFromCache()
    for _,player in pairs(game.Players:GetPlayers()) do
        lbh.CacheAndUpdateFriends(player, psh:Get(player))
    end
end

lbh.CacheLeaderboard()

coroutine.wrap(function()
    while true do
        compareAndUpdateLeaderboards()
        wait(180) -- waits 3 minutes before updating
    end
end)()

