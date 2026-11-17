local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local State = require(script.Parent.EncounterState)
local DodgeState = require(script.Parent.DodgeState)

local Combat = {}
Combat.__index = Combat

local function part(parent, name, size, position, color, material)
    local value = Instance.new("Part")
    value.Name = name
    value.Size = size
    value.Position = position
    value.Anchored = true
    value.Material = material or Enum.Material.Basalt
    value.Color = color
    value.Parent = parent
    return value
end

function Combat.new(model, center, onVictory)
    local self = setmetatable({ center = center, onVictory = onVictory }, Combat)
    local enemy = Instance.new("Model")
    enemy.Name = "BasaltWyrm"
    enemy.Parent = model
    self.enemy = enemy
    self.body = part(enemy, "ObsidianBody", Vector3.new(6, 5, 8),
        center + Vector3.new(0, 3.5, -4), Color3.fromRGB(51, 43, 49))
    part(enemy, "Head", Vector3.new(4, 3, 4), center + Vector3.new(0, 5, 1),
        Color3.fromRGB(78, 49, 43))
    for _, side in ipairs({ -1, 1 }) do
        local wing = part(enemy, "BasaltWing", Vector3.new(7, 0.8, 5),
            center + Vector3.new(side * 5, 5, -5), Color3.fromRGB(95, 51, 42))
        wing.CFrame *= CFrame.Angles(0, 0, math.rad(side * 24))
        part(enemy, "EmberEye", Vector3.new(0.5, 0.5, 0.5),
            center + Vector3.new(side * 1.4, 5.4, 3.1),
            Color3.fromRGB(255, 141, 30), Enum.Material.Neon)
        local horn = part(enemy, "Horn", Vector3.new(0.7, 3, 0.7),
            center + Vector3.new(side * 1.5, 7, 0), Color3.fromRGB(173, 149, 115))
        horn.CFrame *= CFrame.Angles(math.rad(-25), 0, math.rad(side * -15))
    end
    self.warning = part(model, "BreathTelegraph", Vector3.new(22, 0.12, 22),
        center + Vector3.new(0, 0.15, -4), Color3.fromRGB(255, 69, 20), Enum.Material.Neon)
    self.warning.CanCollide = false
    self.warning.CanTouch = false
    self.warning.Transparency = 1

    local board = Instance.new("BillboardGui")
    board.Size = UDim2.fromOffset(270, 92)
    board.StudsOffset = Vector3.new(0, 7, 0)
    board.MaxDistance = 55
    board.AlwaysOnTop = false
    board.Parent = self.body
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 0.73, 0)
    text.BackgroundTransparency = 0.25
    text.BackgroundColor3 = Color3.fromRGB(30, 18, 22)
    text.TextColor3 = Color3.fromRGB(255, 224, 178)
    text.TextScaled = true
    text.TextWrapped = true
    text.Parent = board
    self.text = text
    local textLimit = Instance.new("UITextSizeConstraint")
    textLimit.MaxTextSize = 18
    textLimit.MinTextSize = 12
    textLimit.Parent = text
    local healthBackground = Instance.new("Frame")
    healthBackground.Name = "BossHealthBackground"
    healthBackground.Size = UDim2.new(0.9, 0, 0.14, 0)
    healthBackground.Position = UDim2.new(0.05, 0, 0.8, 0)
    healthBackground.BackgroundColor3 = Color3.fromRGB(26, 18, 22)
    healthBackground.BorderSizePixel = 0
    healthBackground.Parent = board
    local healthFill = Instance.new("Frame")
    healthFill.Name = "BossHealthFill"
    healthFill.Size = UDim2.fromScale(1, 1)
    healthFill.BackgroundColor3 = Color3.fromRGB(227, 97, 46)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBackground
    self.healthFill = healthFill
    self:message("Guardião de Ember\nEntre pelo portal do hub")

    local attack = Instance.new("ProximityPrompt")
    attack.Name = "Attack"
    attack.ActionText = "Atacar · 20 dano"
    attack.ObjectText = "Guardião de Ember"
    attack.MaxActivationDistance = 13
    attack.RequiresLineOfSight = false
    attack.KeyboardKeyCode = Enum.KeyCode.E
    attack.HoldDuration = 0
    attack.Parent = self.body
    attack.Triggered:Connect(function(player)
        self:attack(player)
    end)
    local dodgePrompt = Instance.new("ProximityPrompt")
    dodgePrompt.Name = "Dodge"
    dodgePrompt.ActionText = "Esquivar · 3 s"
    dodgePrompt.ObjectText = "Desviar do sopro"
    dodgePrompt.KeyboardKeyCode = Enum.KeyCode.Q
    dodgePrompt.GamepadKeyCode = Enum.KeyCode.ButtonB
    dodgePrompt.ClickablePrompt = true
    dodgePrompt.MaxActivationDistance = 13
    dodgePrompt.RequiresLineOfSight = false
    dodgePrompt.HoldDuration = 0
    dodgePrompt.Parent = self.body
    dodgePrompt.Triggered:Connect(function(player)
        self:dodge(player)
    end)
    self.removing = Players.PlayerRemoving:Connect(function(player)
        if self.session and self.session.player == player then
            self:close("abandoned")
        end
    end)
    model.Destroying:Connect(function()
        self:close("abandoned")
        self.removing:Disconnect()
    end)
    return self
end

function Combat:message(message)
    self.text.Text = message
    if self.healthFill then
        local health = self.session and self.session.rules.health or 100
        self.healthFill.Size = UDim2.fromScale(math.clamp(health / 100, 0, 1), 1)
    end
end

function Combat:valid(player)
    local s = self.session
    if not s or s.player ~= player or player.Character ~= s.character
        or s.humanoid.Health <= 0 or not s.character.Parent then
        return nil
    end
    return s
end

function Combat:close(result)
    local s = self.session
    if not s then
        return
    end
    s.rules:finish(result)
    self.session = nil
    s.death:Disconnect()
    s.characterRemoving:Disconnect()
    self.warning.Transparency = 1
    if s.rules.result == "defeat" then
        self:message("DERROTA · renasça no hub e tente novamente")
    elseif s.rules.result ~= "victory" then
        self:message("Tentativa encerrada · volte pelo hub para tentar novamente")
    end
end

function Combat:enter(player)
    -- One exclusive encounter: other players cannot steal damage, rewards or arena slots.
    if self.session then
        return false
    end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root then
        return false
    end
    local s = {
        player = player, character = character, humanoid = humanoid,
        rules = State.new(), dodge = DodgeState.new(),
        id = HttpService:GenerateGUID(false),
    }
    self.session = s
    s.death = humanoid.Died:Connect(function()
        self:close("defeat")
    end)
    s.characterRemoving = player.CharacterRemoving:Connect(function(removed)
        if removed == character and self.session == s then
            self:close("abandoned")
        end
    end)
    character:PivotTo(CFrame.new(self.center + Vector3.new(0, 4, 12)))
    self:message("Guardião 100/100 · E atacar / Q esquivar\nControle B · toque nos comandos")
    task.spawn(function()
        while self.session == s do
            task.wait(2)
            if self.session ~= s then break end
            if not self:valid(player) then
                self:close("abandoned")
                break
            end
            local position = root.Position
            local outsideArena = position.Y < self.center.Y - 10
                or (position - self.center).Magnitude > 65
            local won = s.rules.result == "victory"
            if outsideArena or (won and os.clock() - s.wonAt >= 30) then
                if self:returnPlayer(player) then break end
                continue
            end
            if won then
                continue
            end
            self.warning.Transparency = 0.35
            self:message("SOPRO! Saia da área laranja · Guardião " .. s.rules.health .. "/100")
            task.wait(1.2)
            if self.session ~= s then break end
            self.warning.Transparency = 1
            if s.rules.result ~= "active" then continue end
            local valid = self:valid(player)
            -- The actual hitbox matches the orange 22×22 telegraph, not a sphere.
            local delta = root.Position - self.warning.Position
            local inWarning = math.abs(delta.X) <= 11 and math.abs(delta.Z) <= 11
                and math.abs(delta.Y) <= 8
            if valid and inWarning then
                humanoid:TakeDamage(25)
                if self.session == s then
                    self:message("-25 PV · Você " .. math.ceil(humanoid.Health)
                        .. " · Guardião " .. s.rules.health .. "/100")
                end
            elseif valid then
                self:message("Esquivou! · Guardião " .. s.rules.health .. "/100")
            end
        end
    end)
    return true
end

function Combat:dodge(player)
    local s = self:valid(player)
    if not s or s.rules.result ~= "active" then return false end
    local root = s.character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local relative = root.Position - self.body.Position
    local horizontal = Vector3.new(relative.X, 0, relative.Z)
    if horizontal.Magnitude > 13 or math.abs(relative.Y) > 10 then return false end
    local direction = horizontal.Magnitude > 0.1 and horizontal.Unit or Vector3.new(0, 0, 1)
    local shift = direction * 11
    local target = root.Position + shift
    if (target - self.center).Magnitude > 48 then return false end
    if not s.dodge:use(os.clock()) then return false end
    root.AssemblyLinearVelocity = Vector3.zero
    s.character:PivotTo(s.character:GetPivot() + shift)
    self:message("ESQUIVA! · Guardião " .. s.rules.health .. "/100")
    return true
end

function Combat:attack(player)
    local s = self:valid(player)
    local root = s and s.character:FindFirstChild("HumanoidRootPart")
    if not root or not s.rules:attack(os.clock(), (root.Position - self.body.Position).Magnitude) then
        return
    end
    self:message("-20 · Guardião " .. s.rules.health .. "/100 · Você " .. math.ceil(s.humanoid.Health))
    if s.rules.result == "victory" then
        s.wonAt = os.clock()
        self.warning.Transparency = 1
        self:message("VITÓRIA! · Portal roxo para o hub\nRetorno automático em 30 s")
        -- Set terminal state BEFORE calling the reward owner. Never accept a client victory.
        if self.onVictory then
            local ok, err = pcall(self.onVictory, player, s.id)
            if not ok then
                warn("Ember: falha ao registrar vitória: " .. tostring(err))
                self:message("Vitória validada; falha ao registrar selo. Volte e tente novamente.")
            end
        end
    end
end

function Combat:returnPlayer(player)
    local s = self:valid(player)
    if not s or s.returning or not self.onReturn then return false end

    s.returning = true
    local ok, err = pcall(self.onReturn, player)
    s.returning = false
    if not ok then
        warn("Ember: falha ao retornar ao hub: " .. tostring(err))
        if self.session == s then
            self:message("Falha ao voltar ao hub · tente o portal roxo novamente")
        end
        return false
    end

    if self.session == s then
        self:close("abandoned")
    end
    return true
end

return Combat
