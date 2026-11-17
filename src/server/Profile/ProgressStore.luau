-- DataStore integration for already server-validated Ember victories.
-- Writes are monotonic UpdateAsync merges; never overwrite another session's seals.
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local Data = require(script.Parent.ProgressData)
local ProgressStore = {}

local DATASTORE_NAME = "Mythragon_Progress_v1"
local store
local pending = {}
local saving = {}

local function dataStore()
    if not store then
        store = DataStoreService:GetDataStore(DATASTORE_NAME)
    end
    return store
end

local function key(userId)
    return "player_" .. tostring(userId)
end

local function save(userId)
    local ok, err = pcall(function()
        dataStore():UpdateAsync(key(userId), function(previous)
            return Data.merge(previous, "Ember")
        end)
    end)
    if not ok then
        warn("[ProgressStore] failed to persist Ember for " .. tostring(userId) .. ": " .. tostring(err))
    end
    return ok
end

local function scheduleSave(userId)
    pending[userId] = true
    if saving[userId] then return end
    saving[userId] = true
    task.spawn(function()
        for attempt = 1, 6 do
            if not pending[userId] then break end
            if save(userId) then
                pending[userId] = nil
                break
            end
            if attempt < 6 then
                task.wait(math.min(attempt * 2, 10))
            end
        end
        saving[userId] = nil
        if pending[userId] then
            warn("[ProgressStore] persistent save still pending for " .. tostring(userId))
        end
    end)
end

function ProgressStore.start(Profile, Hub)
    local connections = {}
    local closed = false

    local function load(player)
        task.spawn(function()
            -- Retry read outages after the initial three tries. A successful
            -- read is applied additively, never resetting a seal won meanwhile.
            local raw
            local success = false
            while not closed and player.Parent == Players and not success do
                for attempt = 1, 3 do
                    if closed or player.Parent ~= Players then return end
                    local ok, value = pcall(function()
                        return dataStore():GetAsync(key(player.UserId))
                    end)
                    if ok then
                        raw, success = value, true
                        break
                    end
                    warn("[ProgressStore] load failed for " .. tostring(player.UserId)
                        .. ": " .. tostring(value))
                    if attempt < 3 then task.wait(attempt * 2) end
                end
                if not success then
                    warn("[ProgressStore] retrying saved seal load in 60s for "
                        .. tostring(player.UserId))
                    task.wait(60)
                end
            end
            if not success or closed or player.Parent ~= Players then return end
            local ok, snapshot = pcall(Data.read, raw)
            if not ok then
                warn("[ProgressStore] invalid saved record for " .. tostring(player.UserId) .. ": " .. tostring(snapshot))
                return
            end
            if snapshot.seals.Ember then
                local seal = Profile.sealForRealm("Ember")
                if seal then
                    Profile.grantSeal(player, seal)
                    Hub.setSealEarned(player, seal.index)
                end
            end
        end)
    end

    table.insert(connections, Players.PlayerAdded:Connect(load))
    for _, player in ipairs(Players:GetPlayers()) do load(player) end

    -- Transient outages longer than the initial retry window must not leave
    -- earned seals stranded forever in memory while the server is alive.
    if game:GetService("RunService"):IsRunning() then
        task.spawn(function()
            while not closed do
                task.wait(60)
                if closed then break end
                for userId in pairs(pending) do
                    if not saving[userId] then scheduleSave(userId) end
                end
            end
        end)
    end

    -- Open Cloud isolated engine checks are not a running game server.
    if game:GetService("RunService"):IsRunning() then
        game:BindToClose(function()
            -- Pending wins may outlive the Player object; use UserId snapshots.
            local ids = {}
            for id in pairs(pending) do table.insert(ids, id) end
            for _, id in ipairs(ids) do
                if save(id) then pending[id] = nil end
            end
        end)
    end

    return {
        recordSeal = function(_, player, sealId)
            if closed or sealId ~= "Ember" or not player or type(player.UserId) ~= "number"
                or player.UserId <= 0 then return false end
            scheduleSave(player.UserId)
            return true
        end,
        stop = function()
            closed = true
            for _, connection in ipairs(connections) do
                if connection and connection.Disconnect then connection:Disconnect() end
            end
        end,
    }
end

return ProgressStore
