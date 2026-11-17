-- Stores only the three existing server-authoritative Hub objectives.
-- Shares the Ember record and uses UpdateAsync union, never SetAsync.
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Data = require(script.Parent.ObjectivesData)
local ObjectivesStore = {}
local storage
local pending = {}
local working = {}

local function store()
    if not storage then storage = DataStoreService:GetDataStore("Mythragon_Progress_v1") end
    return storage
end

local function userKey(id)
    return "player_" .. tostring(id)
end

local function save(id, objectiveId)
    local ok, err = pcall(function()
        store():UpdateAsync(userKey(id), function(previous)
            return Data.merge(previous, objectiveId)
        end)
    end)
    if not ok then warn("[ObjectivesStore] save failed for " .. tostring(id) .. ": " .. tostring(err)) end
    return ok
end

local function schedule(id, objectiveId)
    local entries = pending[id]
    if not entries then
        entries = {}
        pending[id] = entries
    end
    entries[objectiveId] = true
    if working[id] then return end
    working[id] = true
    task.spawn(function()
        for attempt = 1, 6 do
            local current = pending[id]
            if not current or next(current) == nil then break end
            for objective in pairs(current) do
                if save(id, objective) then current[objective] = nil end
            end
            if next(current) == nil then
                pending[id] = nil
                break
            end
            if attempt < 6 then task.wait(math.min(attempt * 2, 10)) end
        end
        working[id] = nil
        if pending[id] then warn("[ObjectivesStore] unsaved objectives for " .. tostring(id)) end
    end)
end

function ObjectivesStore.start(Hub)
    local active = true
    local connections = {}
    local arrivalRecorded = {}

    local function load(player)
        task.spawn(function()
            local raw
            local loaded = false
            for attempt = 1, 3 do
                local ok, value = pcall(function()
                    return store():GetAsync(userKey(player.UserId))
                end)
                if ok then
                    raw, loaded = value, true
                    break
                end
                warn("[ObjectivesStore] load failed for " .. tostring(player.UserId) .. ": " .. tostring(value))
                if attempt < 3 then task.wait(attempt * 2) end
            end
            if not loaded or not active or player.Parent ~= Players then return end
            local ok, done = pcall(Data.read, raw)
            if not ok then
                warn("[ObjectivesStore] invalid objectives for " .. tostring(player.UserId) .. ": " .. tostring(done))
                return
            end
            for objective, completed in pairs(done) do
                if completed then
                    if objective == "latunia" then
                        arrivalRecorded[player] = true
                    else
                        Hub.restoreObjective(player, objective)
                    end
                end
            end
        end)
    end

    Hub.setObjectiveCompletionHandler(function(player, objectiveId)
        if not active or not Data.allowed(objectiveId) then return end
        if type(player.UserId) == "number" and player.UserId > 0 then
            schedule(player.UserId, objectiveId)
        end
    end)

    table.insert(connections, Players.PlayerRemoving:Connect(function(player)
        arrivalRecorded[player] = nil
    end))
    table.insert(connections, Players.PlayerAdded:Connect(load))
    for _, player in ipairs(Players:GetPlayers()) do load(player) end
    if RunService:IsRunning() then
        game:BindToClose(function()
            for id, entries in pairs(pending) do
                for objective in pairs(entries) do
                    if save(id, objective) then entries[objective] = nil end
                end
            end
        end)
    end

    return {
        recordArrival = function(_, player, islandId)
            if not active or islandId ~= "Central" or player.Parent ~= Players
                or type(player.UserId) ~= "number" or player.UserId <= 0 then
                return false
            end
            if arrivalRecorded[player] then return false end
            arrivalRecorded[player] = true
            schedule(player.UserId, "latunia")
            return true
        end,
        stop = function()
            active = false
            Hub.setObjectiveCompletionHandler(nil)
            for _, connection in ipairs(connections) do connection:Disconnect() end
        end,
    }
end

return ObjectivesStore
