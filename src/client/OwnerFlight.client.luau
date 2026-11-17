-- Owner-only flight controls: click/touch to toggle, wheel changes speed.
-- Server validates access, speed, direction and applies the actual physics.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

if not (RunService:IsStudio() or (
    game.PlaceId == 135004978091658
    and game.CreatorType == Enum.CreatorType.User
    and player.UserId == game.CreatorId
)) then return end

local remote = ReplicatedStorage:WaitForChild("MythragonOwnerFlight", 20)
if not remote or not remote:IsA("RemoteEvent") then return end
local playerGui = player:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("MythragonFlightControls") then return end

local gui = Instance.new("ScreenGui")
gui.Name = "MythragonFlightControls"
gui.ResetOnSpawn = false
gui.DisplayOrder = 45
gui.Parent = playerGui

local function button(name, text, y)
    local item = Instance.new("TextButton")
    item.Name = name
    item.AnchorPoint = Vector2.new(1, 0)
    item.Position = UDim2.new(1, -12, 0, y)
    item.Size = UDim2.fromOffset(116, 40)
    item.BackgroundColor3 = Color3.fromRGB(62, 47, 110)
    item.TextColor3 = Color3.fromRGB(255, 237, 194)
    item.Font = Enum.Font.GothamBold
    item.TextSize = 14
    item.Text = text
    item.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = item
    return item
end

local toggle = button("ToggleFlight", "Voar", 38)
local up = button("FlyUp", "↑ Subir", 85)
local down = button("FlyDown", "↓ Descer", 132)
local speedText = Instance.new("TextLabel")
speedText.Name = "FlightSpeed"
speedText.AnchorPoint = Vector2.new(1, 0)
speedText.Position = UDim2.new(1, -12, 0, 180)
speedText.Size = UDim2.fromOffset(116, 40)
speedText.BackgroundColor3 = Color3.fromRGB(31, 27, 51)
speedText.BackgroundTransparency = 0.15
speedText.TextColor3 = Color3.fromRGB(245, 219, 171)
speedText.Font = Enum.Font.GothamMedium
speedText.TextSize = 12
speedText.TextWrapped = true
speedText.Parent = gui

local flying, upHeld, downHeld = false, false, false
local speed = 45
local stick = Vector2.zero
local function update()
    toggle.Text = flying and "Parar voo" or "Voar"
    up.Visible, down.Visible, speedText.Visible = flying, flying, flying
    speedText.Text = ("Velocidade %d\nScroll +/-"):format(speed)
end
update()

toggle.Activated:Connect(function()
    remote:FireServer("toggle")
end)
for _, item in { {up, true}, {down, false} } do
    local control, ascend = item[1], item[2]
    control.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if ascend then upHeld = true else downHeld = true end
        end
    end)
    control.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if ascend then upHeld = false else downHeld = false end
        end
    end)
end

remote.OnClientEvent:Connect(function(action, value)
    if action ~= "status" then return end
    flying = value == true
    upHeld, downHeld = false, false
    update()
end)

UserInputService.InputChanged:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.MouseWheel and flying and not processed then
        speed = math.clamp(speed + (input.Position.Z > 0 and 5 or -5), 20, 100)
        update()
    elseif input.KeyCode == Enum.KeyCode.Thumbstick1 then
        stick = Vector2.new(input.Position.X, input.Position.Y)
    end
end)

local function key(code)
    return UserInputService:IsKeyDown(code)
end

local function direction()
    local camera = workspace.CurrentCamera
    if not camera then return Vector3.zero end
    local look = camera.CFrame.LookVector
    look = Vector3.new(look.X, 0, look.Z)
    if look.Magnitude < 0.01 then look = Vector3.new(0, 0, -1) end
    look = look.Unit
    local right = Vector3.new(-look.Z, 0, look.X)
    local forward = (key(Enum.KeyCode.W) and 1 or 0) - (key(Enum.KeyCode.S) and 1 or 0)
    local side = (key(Enum.KeyCode.D) and 1 or 0) - (key(Enum.KeyCode.A) and 1 or 0)
    forward += stick.Y
    side += stick.X

    -- Mobile on-screen joystick is represented by Humanoid.MoveDirection.
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local horizontal = right * side + look * forward
    if horizontal.Magnitude < 0.05 and humanoid then
        local move = humanoid.MoveDirection
        horizontal = Vector3.new(move.X, 0, move.Z)
    end
    local rise = (upHeld or key(Enum.KeyCode.Space) or key(Enum.KeyCode.E)
        or key(Enum.KeyCode.ButtonA)) and 1 or 0
    local sink = (downHeld or key(Enum.KeyCode.LeftControl) or key(Enum.KeyCode.Q)
        or key(Enum.KeyCode.ButtonB)) and 1 or 0
    local movement = horizontal + Vector3.new(0, rise - sink, 0)
    return movement.Magnitude > 1 and movement.Unit or movement
end

task.spawn(function()
    while gui.Parent do
        if flying then remote:FireServer("move", direction(), speed) end
        task.wait(0.1)
    end
end)
