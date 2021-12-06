local playerStatsMod = {}

local dsh = require(script.Parent.DatastoreHelper)

local playerStatsList = {}

function playerStatsMod:Set(player, values)
    local wpm = values.WPM
    local lpm = values.LPM
    if wpm == nil or lpm == nil then warn("Please provide valid values!"); return end
    playerStatsList[player.UserId] = {WPM = wpm, LPM = lpm}
    print("set", playerStatsList[player.UserId])
end

function playerStatsMod:Update(player, values)
    if playerStatsList[player.UserId] == nil then warn("warning! Player", player.Name, "does not exist within the list!"); return end
    local wpm = values.WPM
    local lpm = values.LPM
    if wpm == nil or lpm == nil then warn("Please provide valid values!"); return end
    playerStatsList[player.UserId] = {WPM = wpm, LPM = lpm}
    print("update", playerStatsList[player.UserId])
end

function playerStatsMod:Remove(player)
    playerStatsList[player.UserId] = nil
    print("remove", playerStatsList[player.UserId])
end

function playerStatsMod:Get(player)
    print("get", playerStatsList[player.UserId])
    return playerStatsList[player.UserId]
end

return playerStatsMod