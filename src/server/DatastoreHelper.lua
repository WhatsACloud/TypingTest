local datastoreMod = {}

local dss = game:GetService("DataStoreService")

--[[
stuff needed to store:
player's stats
leaderboard
player settings
]]--
local playerStatsDS = dss:GetDataStore("Statistics")
local leaderboardDS = dss:GetDataStore("Leaderboard")
local playerSettingsDS = dss:GetDataStore("Settings")

local datastoreList = {
    Statistics = playerStatsDS,
    Leaderboard = leaderboardDS,
    Settings = playerSettingsDS
}

datastoreMod.DefaultValues = {
    Statistics = {
        WPM = 0,
        LPM = 0
    },
    Leaderboard = {
        WPM = 0,
        LPM = 0,
        PlayerId = 0
    },
    Settings = {
        Time = 30
    }
}

local RETRIES = 3

function datastoreMod.ValidateDatastore(datastoreName)
    if datastoreList[datastoreName] == nil then
        warn("Please provide a valid datastore name!")
        return false
    end
    return true
end

function datastoreMod.RequestDatastore(datastoreName, key)
    if not datastoreMod.ValidateDatastore(datastoreName) then return end
    local ds = datastoreList[datastoreName]
    for i = 1, RETRIES do
        local success, value = pcall(function()
            return ds:GetAsync(key)
        end)
        if success then
            return value
        elseif success == nil and value == nil then
            warn("value does not exist")
            return false
        else
            warn("unable to get value, retrying...", value)
        end
    end
end

function datastoreMod.CreateDatastoreEntry(datastoreName, key, entry)
    if not datastoreMod.ValidateDatastore(datastoreName) then return end
    local ds = datastoreList[datastoreName]
    for i = 1, RETRIES do
        local success, err = pcall(function()
            return ds:SetAsync(key, entry)
        end)
        if success then
            return true
        else
            warn("unable to get value, retrying...", value)
        end
        return false
    end
end

function datastoreMod.RemoveDatastoreEntry(datastoreName, key)
    if not datastoreMod.ValidateDatastore(datastoreName) then return end
    local ds = datastoreList[datastoreName]
    for i = 1, RETRIES do
        local success, err = pcall(function()
            ds:RemoveAsync(key)
        end)
        if success then
            return true
        else
            warn("unable to get value, retrying...", value)
        end
        return false
    end
end

function datastoreMod.SafeDatastoreRequest(datastoreName, key)
    if not datastoreMod.ValidateDatastore(datastoreName) then return end
    local val = datastoreMod.RequestDatastore(datastoreName, key)
    if val == false then
        warn("key does not exist, creating new entry...")
        datastoreMod.CreateDatastoreEntry(datastoreName, key, DefaultValues[datastoreName])
        return DefaultValues[datastoreName]
    end
    return val
end

function datastoreMod.UpdateDatastoreEntry(datastoreName, key, entry)
    if not datastoreMod.ValidateDatastore(datastoreName) then return end
    local ds = datastoreList[datastoreName]
    for i = 1, RETRIES do
        local success, err = pcall(function()
            return ds:UpdateAsync(key, function()
                return entry
            end)
        end)
        if success then
            return true
        else
            warn("unable to get value, retrying...", value)
        end
        return false
    end
end

return datastoreMod