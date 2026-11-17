local Players = game:GetService("Players")
local State = require(script.Parent.InteractionState)
local Model = require(script.Parent.VarkhionModel)
local Guidance = require(script.Parent.VarkhionGuidance)

local Varkhion = {}
local mounted = setmetatable({}, { __mode = "k" })
local Controller = {}
Controller.__index = Controller

-- The progression owner provides a read-only, server-validated seal check.

function Controller:show(player, message)
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    local previous = self.dialogues[player]
    if previous then previous:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "VarkhionDialogue"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 20
    gui.Parent = playerGui
    self.dialogues[player] = gui
    local text = Instance.new("TextLabel")
    text.Name = "Response"
    text.AnchorPoint = Vector2.new(0.5, 1)
    text.Position = UDim2.fromScale(0.5, 0.78)
    text.Size = UDim2.new(0.86, 0, 0, 132)
    text.BackgroundColor3 = Color3.fromRGB(20, 13, 33)
    text.BackgroundTransparency = 0.1
    text.TextColor3 = Color3.fromRGB(239, 227, 255)
    text.Font = Enum.Font.GothamMedium
    text.TextWrapped = true
    text.TextScaled = true
    text.Text = "VARKHION · Éter e Trevas\n" .. message
    text.Parent = gui
    local size = Instance.new("UITextSizeConstraint")
    size.MinTextSize = 12
    size.MaxTextSize = 22
    size.Parent = text
    local bounds = Instance.new("UISizeConstraint")
    bounds.MaxSize = Vector2.new(640, 132)
    bounds.Parent = text
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = text
    task.delay(10, function()
        if self.dialogues[player] == gui then
            self.dialogues[player] = nil
            gui:Destroy()
        end
    end)
end

function Controller:interact(player)
    if self.destroyed or not self.model:IsDescendantOf(workspace)
        or not self.anchor:IsDescendantOf(workspace) or player.Parent ~= Players then
        return false
    end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid or humanoid.Health <= 0 then return false end
    local ticket, first = self.state:begin(player, os.clock(),
        (root.Position - self.point.Position).Magnitude, true)
    if not ticket then return false end
    local ok, err = true, nil
    if first then
        ok, err = pcall(self.onInteracted, player, "Varkhion")
    end
    local current = self.state:finish(player, ticket, ok)
    if not current or self.destroyed or player.Parent ~= Players then return false end
    if not ok then
        warn("Varkhion: interaction callback failed: " .. tostring(err))
        self:show(player, "Não consegui confirmar seu objetivo. Aproxime-se e tente ouvir novamente.")
        return false
    end
    local hasEmber = false
    if self.hasEmberSeal then
        local success, result = pcall(self.hasEmberSeal, player)
        if success then
            hasEmber = result == true
        else
            warn("Varkhion: progress lookup failed: " .. tostring(result))
        end
    end
    self:show(player, Guidance.forSeal(hasEmber))
    return true
end

function Controller:destroy()
    if self.destroyed then return end
    self.destroyed = true
    if mounted[self.parent] == self then mounted[self.parent] = nil end
    for _, connection in ipairs(self.connections) do connection:Disconnect() end
    self.state:clear()
    for player, gui in pairs(self.dialogues) do
        gui:Destroy()
        self.dialogues[player] = nil
    end
    self.model:Destroy()
end

function Varkhion.mount(parent, anchor, onInteracted, hasEmberSeal)
    assert(typeof(parent) == "Instance" and parent:IsDescendantOf(workspace),
        "Varkhion parent must be inside Workspace")
    assert(typeof(anchor) == "Instance" and anchor:IsA("BasePart")
        and anchor.Anchored and anchor:IsDescendantOf(parent),
        "Provide an anchored VarkhionAnchor inside parent, at floor level")
    assert(type(onInteracted) == "function", "Provide the GLM objective callback")
    assert(hasEmberSeal == nil or type(hasEmberSeal) == "function",
        "Optional seal check must be a server callback")
    local existing = mounted[parent]
    if existing then
        assert(existing.anchor == anchor, "Varkhion already mounted at a different anchor")
        return existing
    end
    local model, point = Model.build(parent, anchor.CFrame)
    local self = setmetatable({
        parent = parent, anchor = anchor, model = model, point = point,
        onInteracted = onInteracted, hasEmberSeal = hasEmberSeal,
        state = State.new(),
        connections = {}, dialogues = {}, destroyed = false,
    }, Controller)
    mounted[parent] = self
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "HearVarkhion"
    prompt.ActionText = "Ouvir Varkhion"
    prompt.ObjectText = "Lendário · Éter e Trevas"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
    prompt.ClickablePrompt = true
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = State.MAX_DISTANCE
    prompt.RequiresLineOfSight = false
    prompt.Parent = point
    table.insert(self.connections, prompt.Triggered:Connect(function(player)
        self:interact(player)
    end))
    table.insert(self.connections, Players.PlayerRemoving:Connect(function(player)
        self.state:remove(player)
        local gui = self.dialogues[player]
        if gui then gui:Destroy() end
        self.dialogues[player] = nil
    end))
    for _, target in ipairs({ parent, anchor, model }) do
        table.insert(self.connections, target.Destroying:Connect(function() self:destroy() end))
    end
    return self
end

return Varkhion
