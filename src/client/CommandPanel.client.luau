-- Developer command palette. In published staging only the individual
-- place creator sees this UI; the server independently enforces access.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local touch = UserInputService.TouchEnabled
local player = Players.LocalPlayer
local authorizedPreview = RunService:IsStudio() or (
    game.PlaceId == 135004978091658
    and game.CreatorType == Enum.CreatorType.User
    and player.UserId == game.CreatorId
)
if not authorizedPreview then return end
local playerGui = player:WaitForChild("PlayerGui")
local remote = ReplicatedStorage:WaitForChild("MythragonStudioCommand", 20)
if not remote or not remote:IsA("RemoteEvent") then
    warn("[Mythragon Commands] Server command channel unavailable")
    return
end
if playerGui:FindFirstChild("MythragonStudioCommands") then return end

local gui = Instance.new("ScreenGui")
gui.Name = "MythragonStudioCommands"
gui.ResetOnSpawn = false
gui.DisplayOrder = 40
gui.Parent = playerGui

local open = Instance.new("TextButton")
open.Name = "OpenCommands"
open.AnchorPoint = Vector2.new(1, 1)
open.Position = UDim2.new(1, -12, 1, -14)
open.Size = UDim2.fromOffset(116, 42)
if touch then
    open.AnchorPoint = Vector2.new(0.5, 0)
    open.Position = UDim2.new(0.5, 75, 0, 24)
    open.Size = UDim2.fromOffset(94, 34)
end
open.BackgroundColor3 = Color3.fromRGB(75, 53, 133)
open.TextColor3 = Color3.fromRGB(255, 240, 192)
open.Text = "⚙ Comandos"
open.TextSize = touch and 13 or 15
open.Font = Enum.Font.GothamBold
open.Parent = gui
local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 10)
openCorner.Parent = open

local panel = Instance.new("ScrollingFrame")
panel.Name = "CommandPanel"
panel.AnchorPoint = Vector2.new(1, 1)
panel.Position = UDim2.new(1, -12, 1, -62)
panel.Size = UDim2.fromOffset(240, 308)
panel.CanvasSize = UDim2.new(1, 0, 0, 308)
panel.ScrollingDirection = Enum.ScrollingDirection.Y
panel.ScrollBarThickness = 5
if touch then
    panel.AnchorPoint = Vector2.new(0.5, 0)
    panel.Position = UDim2.new(0.5, 0, 0, 64)
    panel.Size = UDim2.new(1, -24, 1, -132)
end
panel.BackgroundColor3 = Color3.fromRGB(25, 22, 43)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
local bound = Instance.new("UISizeConstraint")
bound.MinSize = Vector2.new(0, 0)
bound.MaxSize = Vector2.new(240, 308)
bound.Parent = panel
local round = Instance.new("UICorner")
round.CornerRadius = UDim.new(0, 10)
round.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(10, 7)
title.Size = UDim2.new(1, -50, 0, 24)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.fromRGB(255, 220, 141)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "COMANDOS DE TESTE"
title.Parent = panel

local close = Instance.new("TextButton")
close.Name = "CloseCommands"
close.Position = UDim2.new(1, -34, 0, 6)
close.Size = UDim2.fromOffset(27, 26)
close.BackgroundColor3 = Color3.fromRGB(68, 52, 80)
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextSize = 17
close.Text = "×"
close.Parent = panel
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = close

local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.Position = UDim2.fromOffset(10, 34)
hint.Size = UDim2.new(1, -20, 0, 29)
hint.Font = Enum.Font.Gotham
hint.TextSize = 11
hint.TextColor3 = Color3.fromRGB(194, 191, 217)
hint.TextWrapped = true
hint.Text = "Ferramentas do proprietário · apenas staging"
hint.Parent = panel

local mobileMenuAttribute = "MythragonMobileMenu"
local menuId = "Commands"
local function setOpen(value)
    if touch then
        if value then
            playerGui:SetAttribute(mobileMenuAttribute, menuId)
        elseif playerGui:GetAttribute(mobileMenuAttribute) == menuId then
            playerGui:SetAttribute(mobileMenuAttribute, nil)
        end
    end
    panel.Visible = value
    if value then panel.CanvasPosition = Vector2.zero end
    open.Text = value and "× Fechar" or "⚙ Comandos"
end

if touch then
    playerGui:GetAttributeChangedSignal(mobileMenuAttribute):Connect(function()
        if panel.Visible and playerGui:GetAttribute(mobileMenuAttribute) ~= menuId then
            setOpen(false)
        end
    end)
end

local destinations = {
    { "Aetheria / Hub", "hub" },
    { "Vila Central", "vila" },
    { "Deserto", "deserto" },
    { "Vulcânica", "vulcanica" },
    { "Gelo", "gelo" },
    { "Selva", "selva" },
}
for i, entry in ipairs(destinations) do
    local button = Instance.new("TextButton")
    button.Name = "Go" .. entry[2]
    button.Position = UDim2.fromOffset(10, 65 + (i - 1) * 38)
    button.Size = UDim2.new(1, -20, 0, 33)
    button.BackgroundColor3 = Color3.fromRGB(49, 41, 80)
    button.TextColor3 = Color3.fromRGB(243, 239, 250)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 13
    button.Text = entry[1]
    button.Parent = panel
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    local destination = entry[2]
    button.Activated:Connect(function()
        remote:FireServer(destination)
        setOpen(false)
    end)
end

open.Activated:Connect(function()
    setOpen(not panel.Visible)
end)
close.Activated:Connect(function()
    setOpen(false)
end)
