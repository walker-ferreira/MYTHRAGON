-- Latunia public travel guide: UI only, no client-side teleport.
-- Uses GLM-R012's six destination labels and visual direction.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local touch = UserInputService.TouchEnabled
local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("LatuniaTravelRemote", 25)
if not remote or not remote:IsA("RemoteEvent") then return end
local playerGui = player:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("LatuniaTravelUi") then return end

local destinations = {
    { "Hub · Aetheria", "hub" }, { "Vila Central", "vila" },
    { "Ilha do Gelo", "gelo" }, { "Ilha do Deserto", "deserto" },
    { "Ilha da Selva", "selva" }, { "Ilha Vulcânica", "vulcanica" },
}
local gui = Instance.new("ScreenGui")
gui.Name = "LatuniaTravelUi"
gui.ResetOnSpawn = false
gui.DisplayOrder = 24
gui.Parent = playerGui

local function round(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end
local function label(parent, name, text, y, height)
    local value = Instance.new("TextLabel")
    value.Name, value.Text = name, text
    value.Position = UDim2.fromOffset(10, y)
    value.Size = UDim2.new(1, -20, 0, height)
    value.BackgroundTransparency = 1
    value.Font = Enum.Font.Gotham
    value.TextColor3 = Color3.fromRGB(239, 223, 188)
    value.TextWrapped = true
    value.TextSize = 12
    value.TextXAlignment = Enum.TextXAlignment.Left
    value.Parent = parent
    return value
end

-- Leave room for the owner's bottom-right Commands panel and mobile joystick.
local open = Instance.new("TextButton")
open.Name = "OpenTravel"
open.AnchorPoint = Vector2.new(1, 1)
open.Position = UDim2.new(1, -140, 1, -14)
open.Size = UDim2.fromOffset(102, 42)
if touch then
    open.AnchorPoint = Vector2.new(0.5, 0)
    open.Position = UDim2.new(0.5, -14, 0, 24)
    open.Size = UDim2.fromOffset(76, 34)
end
open.Font = Enum.Font.GothamBold
open.TextSize = 14
open.Text = "VIAGEM"
open.BackgroundColor3 = Color3.fromRGB(65, 47, 96)
open.TextColor3 = Color3.fromRGB(255, 229, 179)
open.Parent = gui
round(open, 8)

local menu = Instance.new("ScrollingFrame")
menu.Name = "TravelMenu"
menu.AnchorPoint = Vector2.new(1, 1)
menu.Position = UDim2.new(1, -114, 1, -62)
menu.Size = UDim2.new(1, -126, 1, -74)
if touch then
    menu.AnchorPoint = Vector2.new(0.5, 0)
    menu.Position = UDim2.new(0.5, 0, 0, 64)
    menu.Size = UDim2.new(1, -24, 1, -132)
end
menu.CanvasSize = UDim2.new(1, 0, 0, 310)
menu.ScrollingDirection = Enum.ScrollingDirection.Y
menu.ScrollBarThickness = 5
local menuSize = Instance.new("UISizeConstraint")
menuSize.MaxSize = Vector2.new(190, 310)
menuSize.Parent = menu
menu.BackgroundColor3 = Color3.fromRGB(28, 25, 42)
menu.BorderSizePixel = 0
menu.Visible = false
menu.Parent = gui
round(menu, 10)
label(menu, "Title", "TERMINAL DE VIAGEM", 8, 26).Font = Enum.Font.GothamBold
label(menu, "Hint", "Vá até o portal ou cais de embarque para viajar.", 36, 30)
for i, entry in ipairs(destinations) do
    local button = Instance.new("TextButton")
    button.Name = "Go" .. entry[2]
    button.Position = UDim2.fromOffset(10, 67 + (i - 1) * 38)
    button.Size = UDim2.new(1, -20, 0, 34)
    button.BackgroundColor3 = Color3.fromRGB(139, 101, 64)
    button.TextColor3 = Color3.fromRGB(255, 245, 220)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 13
    button.Text = entry[1]
    button.Parent = menu
    round(button, 6)
    local id = entry[2]
    button.Activated:Connect(function()
        menu.Visible = false
        open.Text = "VIAGEM"
        remote:FireServer(id)
    end)
end
open.Activated:Connect(function()
    menu.Visible = not menu.Visible
    if menu.Visible then menu.CanvasPosition = Vector2.zero end
    open.Text = menu.Visible and "FECHAR" or "VIAGEM"
end)

local lastNotice
remote.OnClientEvent:Connect(function(kind, message)
    if kind ~= "notice" or type(message) ~= "string" then return end
    local notice = playerGui:FindFirstChild("LatuniaTravelNotice")
    if not notice then
        notice = Instance.new("ScreenGui")
        notice.Name = "LatuniaTravelNotice"
        notice.ResetOnSpawn = false
        notice.DisplayOrder = 60
        notice.Parent = playerGui
    end
    local text = notice:FindFirstChild("Status")
    if not text then
        text = Instance.new("TextLabel")
        text.Name = "Status"
        text.AnchorPoint = Vector2.new(0.5, 0)
        text.Position = UDim2.fromScale(0.5, 0.10)
        text.Size = UDim2.new(0.8, 0, 0, 48)
        text.BackgroundColor3 = Color3.fromRGB(31, 25, 42)
        text.TextColor3 = Color3.fromRGB(255, 231, 178)
        text.TextWrapped = true
        text.TextSize = 14
        text.Font = Enum.Font.GothamMedium
        text.Parent = notice
        round(text, 8)
    end
    text.Text = message
    local ticket = {}
    lastNotice = ticket
    task.delay(4, function()
        if lastNotice == ticket and notice.Parent then notice:Destroy() end
    end)
end)
