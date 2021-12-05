local playerStatsMod = {}

local dsh = require(script.DatastoreHelper)

local playerStatsList = {}

function playerStatsMod:Set(player, values)
    local wpm = values.WPM
    local lpm = values.LPM
    if wpm == nil or lpm == nil then warn("Please provide valid values!"); return end
    playerStatsList[player.UserId] = {WPM = wpm, LPM = lpm}
end

function playerStatsMod:Update(player, values)
    if playerStatsList[player.UserId] == nil then warn("warning! Player", player.Name, "does not exist within the list!"); return end
    local wpm = values.WPM
    local lpm = values.LPM
    if wpm == nil or lpm == nil then warn("Please provide valid values!"); return end
    playerStatsList[player.UserId] = {WPM = wpm, LPM = lpm}
end

function playerStatsMod:Remove(player)
    playerStatsList[player.UserId] = nil
end

function playerStatsMod:Get(player)
    return playerStatsList[player.UserId]
end

return playerStatsMod