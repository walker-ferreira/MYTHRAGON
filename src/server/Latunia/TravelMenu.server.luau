-- Public Latunia journey menu gateway. No teleport or reward code here.
-- Every trip goes through Map.requestTravel -> Controller:request, the same
-- physical portal distance, route, cooldown and travel-ticket checks.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Map = require(script.Parent.Codex.Map)
local Policy = require(script.Parent.Codex.TravelMenuPolicy)

local remote = ReplicatedStorage:FindFirstChild("LatuniaTravelRemote")
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = "LatuniaTravelRemote"
    remote.Parent = ReplicatedStorage
end

local lastRequest = {}
remote.OnServerEvent:Connect(function(player, key)
    if player.Parent ~= Players then return end
    local to = Policy.destination(key)
    if not to then return end
    local now = os.clock()
    if now - (lastRequest[player] or -math.huge) < 0.75 then return end
    lastRequest[player] = now
    local ok, accepted = pcall(Map.requestTravel, workspace, player, to)
    if not ok then
        warn("[LatuniaMenu] request failed for " .. player.Name .. ": " .. tostring(accepted))
        remote:FireClient(player, "notice", "Viagem indisponível neste servidor.")
    elseif not accepted then
        remote:FireClient(player, "notice",
            "Aproxime-se do portal ou cais da rota desejada para embarcar.")
    end
end)

Players.PlayerRemoving:Connect(function(player)
    lastRequest[player] = nil
end)
