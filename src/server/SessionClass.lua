local session = {}

local sessionList = {}

local variables = require(game:GetService("ReplicatedStorage").Common.SharedVariables)
local wordsList = require(script.Parent.wordsList).Words
local psh = require(script.Parent.playerStatsMod)
local keyMap = variables.KeyMap

function session:SetAttributes(dict)
    for i,v in dict do
        if self[i] ~= nil then
            self[i] = v
        end
    end
end

function session:PrintAttributesMain()
    for i,v in pairs(session) do
        print(i,v)
    end
end

function session:New(preTable,player, totalTime, lettersPerRow)
    preTable = preTable or {Player = player}
    local playerName = preTable.Player.Name
    preTable.TotalTime = totalTime
    preTable.LettersPerRow = lettersPerRow
    preTable.currentLetterIndex = 1
    preTable.letterIndexArr = {}
    preTable.lettersArrByRow = {}
    preTable.Timer = 0
    preTable.TimerStopped = game:GetService("ReplicatedStorage").RE.EndSession
    preTable.Data = {
        WPM = 0
    }
    preTable.lettersTyped = {}
    preTable.RowsTyped = {}
    preTable.Started = false
    preTable.IsMulti = false
    setmetatable(preTable,{__index = session})
    sessionList[playerName] = preTable
    return sessionList[playerName]
end

function session:Remove()
    player = self.Player
    if sessionList[player.Name] ~= nil then
        sessionList[player.Name] = nil
    end
end

function session:LoadTyping(rowAmt, rowRequested)
    local pastLetterNum = #self.letterIndexArr
    warn(rowAmt, rowReqested)
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
    timeLength = tonumber(timeLength)
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
        psh:Update(self.Player, {WPM = self.Data.WPM, LPM = self.Data.LPM})
        self.TimerStopped:FireClient(self.Player,self.Data)
    end)
    timer()
end

local function CalculateAveraged(arr,totalTime, Type)
    local totalNum = 0
    local increment = 1
    for _,v in ipairs(arr) do
        if Type == "word" then
            if v.letter == " " then
                totalNum = totalNum + increment
            end
            if v.value == 0 then 
                increment = 0
            end
        elseif Type == "letter" or Type == "accuracy" then
            totalNum = totalNum + v.value
        end
    end
    if Type == "accuracy" then
        totalNum = ((totalNum / #arr)*100) / (60/totalTime) -- last part to make value the same
    end
    return totalNum * (60/totalTime)
end

function session:CalculateWPM()
    local wordsAv = CalculateAveraged(self.lettersTyped, self.TotalTime, "word")
    local lettersAv = CalculateAveraged(self.lettersTyped, self.TotalTime, "letter")
    local accuracy = CalculateAveraged(self.lettersTyped, self.TotalTime, "accuracy")
    self.Data.WPM = wordsAv
    self.Data.LPM = lettersAv
    self.Data.Accuracy = accuracy
    return wordsAv
end

function session:FindSessionByPlayer(plr)
    return sessionList[plr.Name]
end

return session