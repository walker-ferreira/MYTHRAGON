local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local State = require(script.Parent.EncounterState)

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
    board.Size = UDim2.fromOffset(370, 100)
    board.StudsOffset = Vector3.new(0, 7, 0)
    board.AlwaysOnTop = true
    board.Parent = self.body
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 0.25
    text.BackgroundColor3 = Color3.fromRGB(30, 18, 22)
    text.TextColor3 = Color3.fromRGB(255, 224, 178)
    text.TextScaled = true
    text.TextWrapped = true
    text.Parent = board
    self.text = text
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
        rules = State.new(), id = HttpService:GenerateGUID(false),
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
    self:message("Guardião 100/100 · aproxime-se e ataque [E / toque]\nAfaste-se da área laranja!")
    task.spawn(function()
        while self.session == s and s.rules.result == "active" do
            task.wait(2)
            if self.session ~= s then break end
            if not self:valid(player) then
                self:close("abandoned")
                break
            end
            local position = root.Position
            if position.Y < self.center.Y - 10
                or (position - self.center).Magnitude > 65 then
                self:returnPlayer(player)
                break
            end
            self.warning.Transparency = 0.35
            self:message("SOPRO! Saia da área laranja · Guardião " .. s.rules.health .. "/100")
            task.wait(1.2)
            if self.session ~= s or s.rules.result ~= "active" then break end
            self.warning.Transparency = 1
            local valid = self:valid(player)
            -- Keep the entire damage radius inside the 22-stud warning square.
            if valid and (root.Position - self.body.Position).Magnitude <= 11 then
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

function Combat:attack(player)
    local s = self:valid(player)
    local root = s and s.character:FindFirstChild("HumanoidRootPart")
    if not root or not s.rules:attack(os.clock(), (root.Position - self.body.Position).Magnitude) then
        return
    end
    self:message("-20 · Guardião " .. s.rules.health .. "/100 · Você " .. math.ceil(s.humanoid.Health))
    if s.rules.result == "victory" then
        self.warning.Transparency = 1
        self:message("VITÓRIA! · Use o portal roxo para voltar ao hub")
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
    if not self:valid(player) then return end
    self:close("abandoned")
    if self.onReturn then self.onReturn(player) end
end

return Combat
