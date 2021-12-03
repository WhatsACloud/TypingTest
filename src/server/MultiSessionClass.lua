local multiSession = {}
local multiSessionList = {}

local session = require(script.Parent.SessionClass)
multiSession = setmetatable({}, session)

function multiSession:New(preTable,players)
    preTable = preTable or {Players = players}
    preTable.ID = #multiSessionList+1
    multiSessionList[#multiSessionList+1] = setmetatable(preTable,{__index = self})
    multiSessionList[#multiSessionList+1].IsMulti = true
    return multiSessionList[#multiSessionList]
end

function multiSession:Remove()
    multiSessionList[self.ID] = nil
end

function multiSession:addPlayer(plr)
    self.Players[plr] = session:New(nil, plr, 30, 50)
end

function multiSession:FindMultiSessionByPlayer(plr)
    for _,v in ipairs(multiSessionList) do
        for _,player in ipairs(v) do
            if player == plr then
                return v
            end
        end
    end
    return nil
end

return multiSession