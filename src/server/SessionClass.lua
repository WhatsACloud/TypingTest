local session = {}

local sessionList = {}

local variables = require(game:GetService("ReplicatedStorage").Common.SharedVariables)
local wordsList = require(script.Parent.wordsList).Words
local keyMap = variables.KeyMap

session.currentLetterIndex = 1
session.letterIndexArr = {}
session.lettersArrByRow = {}
session.Player = nil
session.Timer = 0
session.TotalTime = 0
session.TimerStopped = game:GetService("ReplicatedStorage").RE.EndSession
session.Data = {
    WPM = 0
}
session.wordsTyped = {}
session.lettersTyped = {}
session.PastLettersInWord = {}
session.LettersPerRow = 0
session.RowsTyped = {}
session.Started = false
session.IsMulti = false

function session:SetAttributes(dict)
    for i,v in dict do
        if session[i] ~= nil then
            session[i] = v
        end
    end
end

function session:New(preTable,player, totalTime, lettersPerRow)
    preTable = preTable or {Player = player}
    local playerName = preTable.Player.Name
    preTable.TotalTime = totalTime
    preTable.LettersPerRow = lettersPerRow
    sessionList[playerName] = setmetatable(preTable,{__index = self})
    return sessionList[playerName]
end

function session:Remove()
    player = self.Player
    if sessionList[player.Name] ~= nil then
        sessionList[player.Name] = nil
    end
end

function session:LoadTyping(rowAmt, rowRequested)
    if new then
        self.letterIndexArr = {}
    end
    local pastLetterNum = #self.letterIndexArr
    if not rowReqested then
        for i = 1,rowAmt do
            local object = {}
            while true do
                local word = wordsList[math.random(1, #wordsList)].." "
                local wordLength = string.len(word)
                if (wordLength + #object) > self.LettersPerRow then
                    break
                end
                for i,v in ipairs(word:split("")) do
                    self.letterIndexArr[#self.letterIndexArr+1] = v
                    object[#object+1] = v
                end
                -- wait(0.1) -- just in case loop is infinite
            end
            self.lettersArrByRow[#self.lettersArrByRow+1] = object
        end
    end
    return self.letterIndexArr, pastLetterNum, self.lettersArrByRow
end

function session:StoreLetterInRow(rowNumber, letter)
    if self.RowsTyped[rowNumber] ~= nil then
        table.insert(self.RowsTyped[rowNumber], #self.RowsTyped[rowNumber]+1, letter)
    else
        self.RowsTyped[rowNumber] = {letter}
    end
end

function session:StartTimer(timeLength)
    self.Timer = timeLength
    local timer = coroutine.wrap(function()
        local timerRE = game:GetService("ReplicatedStorage").RE.Timer
        for i = 1,timeLength do
            for a = 1,10 do
                if sessionList[self.Player.Name] ~= nil then
                    if sessionList[self.Player.Name].Started == false then
                        sessionList[self.Player.Name].Started = true
                        coroutine.yield()
                    end
                else
                    coroutine.yield()
                end
                wait(0.1)
            end
            self.Timer = self.Timer - 1
            timerRE:FireClient(self.Player,self.Timer)
        end
        self:CalculateWPM()
        self.TimerStopped:FireClient(self.Player,self.Data)
    end)
    timer()
end

local function CalculateAveraged(arr,totalTime)
    local totalNum = 0
    for _,v in ipairs(arr) do
        if v then
            totalNum = totalNum + 1
        end
    end
    return totalNum * (60/totalTime)
end

function session:CalculateWPM()
    local wordsAv = CalculateAveraged(self.wordsTyped, self.TotalTime)
    local lettersAv = CalculateAveraged(self.lettersTyped, self.TotalTime)
    self.Data.WPM = wordsAv
    return wordsAv
end

function session:FindSessionByPlayer(plr)
    return sessionList[plr.Name]
end

return session