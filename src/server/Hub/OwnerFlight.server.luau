-- Owner-only flight sandbox for Studio and the experimental staging place.
-- Movement authorization and velocity are enforced on the server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Access = require(script.Parent.CommandAccess)
local TravelPolicy = require(script.Parent.FlightTravelPolicy)

local remote = Instance.new("RemoteEvent")
remote.Name = "MythragonOwnerFlight"
remote.Parent = ReplicatedStorage

local active = {}
local lastToggle = {}
local MAX_SPEED = 100
local MIN_SPEED = 20
local MAX_ALTITUDE = 950
local MIN_ALTITUDE = -55
local INPUT_TIMEOUT = 0.5

local function stop(player)
    local flight = active[player]
    if not flight then return end
    active[player] = nil
    if flight.character.Parent and flight.humanoid.Parent == flight.character then
        flight.humanoid.PlatformStand = false
    end
    if flight.velocity then flight.velocity:Destroy() end
    if flight.attachment then flight.attachment:Destroy() end
    if player.Parent == Players then remote:FireClient(player, "status", false) end
end

local function start(player)
    if not Access.canUse(player) or player.Parent ~= Players then return end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then return end
    if humanoid.Sit or root.Anchored then return end
    local attachment = Instance.new("Attachment")
    attachment.Name = "MythragonFlightAttachment"
    attachment.Parent = root
    local velocity = Instance.new("LinearVelocity")
    velocity.Name = "MythragonFlightVelocity"
    velocity.Attachment0 = attachment
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.MaxForce = 100000
    velocity.VectorVelocity = Vector3.zero
    velocity.Parent = root
    humanoid.PlatformStand = true
    active[player] = {
        character = character, humanoid = humanoid, root = root,
        attachment = attachment, velocity = velocity, direction = Vector3.zero,
        speed = 45, lastInput = os.clock(),
        lastPosition = root.Position,
    }
    remote:FireClient(player, "status", true)
end

remote.OnServerEvent:Connect(function(player, action, direction, speed)
    if player.Parent ~= Players or not Access.canUse(player) or type(action) ~= "string" then return end
    if action == "toggle" then
        local now = os.clock()
        if now - (lastToggle[player] or -math.huge) < 0.5 then return end
        lastToggle[player] = now
        if active[player] then stop(player) else start(player) end
        return
    end
    if action ~= "move" then return end
    local flight = active[player]
    if not flight or flight.character ~= player.Character then return end
    if typeof(direction) ~= "Vector3" or type(speed) ~= "number" then return end
    if direction.X ~= direction.X or direction.Y ~= direction.Y or direction.Z ~= direction.Z
        or speed ~= speed or speed == math.huge or speed == -math.huge then return end
    if math.abs(direction.X) > 1 or math.abs(direction.Y) > 1 or math.abs(direction.Z) > 1 then return end
    if speed < MIN_SPEED or speed > MAX_SPEED then return end
    flight.direction = direction.Magnitude > 1 and direction.Unit or direction
    flight.speed = speed
    flight.lastInput = os.clock()
end)

RunService.Heartbeat:Connect(function(dt)
    for player, flight in pairs(active) do
        if player.Parent ~= Players or player.Character ~= flight.character
            or flight.root.Parent ~= flight.character or flight.humanoid.Health <= 0 then
            stop(player)
        else
            -- A portal/debug travel is a server-driven teleport. End flight
            -- immediately so PlatformStand/LinearVelocity cannot strand the
            -- character at the next island or interfere with combat.
            local moved = (flight.root.Position - flight.lastPosition).Magnitude
            flight.lastPosition = flight.root.Position
            if TravelPolicy.isTeleport(moved, dt, flight.speed) then
                stop(player)
                continue
            end
            local dir = flight.direction
            if os.clock() - flight.lastInput > INPUT_TIMEOUT then dir = Vector3.zero end
            local y = flight.root.Position.Y
            if (y >= MAX_ALTITUDE and dir.Y > 0) or (y <= MIN_ALTITUDE and dir.Y < 0) then
                dir = Vector3.new(dir.X, 0, dir.Z)
            end
            flight.velocity.VectorVelocity = dir * flight.speed
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    stop(player)
    lastToggle[player] = nil
end)
