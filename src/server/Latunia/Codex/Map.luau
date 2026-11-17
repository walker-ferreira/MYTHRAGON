local Players = game:GetService("Players")
local B = require(script.Parent.Build)
local Layout = require(script.Parent.Layout)
local Islands = require(script.Parent.Islands)
local TravelState = require(script.Parent.TravelState)
local Map = {}
local Controller = {}
Controller.__index = Controller
local mounted = setmetatable({}, { __mode = "k" })

local function pos(p)
    return Vector3.new(p[1], p[2], p[3])
end

function Controller:notify(player, message)
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    if self.notices[player] then self.notices[player]:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "LatuniaNotice", false, 25
    gui.Parent = playerGui
    self.notices[player] = gui
    local text = Instance.new("TextLabel")
    text.AnchorPoint, text.Position = Vector2.new(0.5, 1), UDim2.fromScale(0.5, 0.84)
    text.Size = UDim2.new(0.85, 0, 0, 72)
    text.BackgroundColor3, text.TextColor3 = B.colors.iron, Color3.fromRGB(250, 227, 179)
    text.TextScaled, text.TextWrapped, text.Font = true, true, Enum.Font.Garamond
    text.Text = message
    text.Parent = gui
    local limit = Instance.new("UITextSizeConstraint")
    limit.MinTextSize, limit.MaxTextSize, limit.Parent = 12, 22, text
    task.delay(6, function()
        if self.notices[player] == gui then
            self.notices[player] = nil
            gui:Destroy()
        end
    end)
end

function Controller:forget(player)
    self.current[player] = nil
    self.travel:remove(player)
    if self.playerConns[player] then self.playerConns[player]:Disconnect() end
    self.playerConns[player] = nil
    if self.notices[player] then self.notices[player]:Destroy() end
    self.notices[player] = nil
end

function Controller:arrival(id)
    local p = self.origins[id]+pos(Layout.arrivals[id])
    local center = self.origins[id]
    return CFrame.lookAt(p, Vector3.new(center.X, p.Y, center.Z))
end

function Controller:teleportToIsland(character, root, to)
    local ok, err = pcall(function()
        local arrival = self:arrival(to)
        root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
        character:PivotTo(arrival)
    end)
    if not ok then
        warn("[Latunia] falha ao teleportar para " .. to .. ": " .. tostring(err))
    end
    return ok
end

function Controller:trackArrival(player, to)
    if not self.playerConns[player] then
        self.playerConns[player] = player.CharacterRemoving:Connect(function()
            self:forget(player)
        end)
    end
    self.current[player] = to
end

function Controller:request(player, point, from, to)
    if self.destroyed or player.Parent ~= Players or not point:IsDescendantOf(workspace) then return end
    if from == "Hub" then
        if self.current[player] or to ~= "Central" then return end
    elseif self.current[player] ~= from then
        return
    elseif to ~= "Hub" and not Layout.canTravel(from, to) then
        return
    elseif to == "Hub" and from ~= "Central" then
        return
    end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid or humanoid.Health <= 0 then return end
    local ticket = self.travel:begin(player, os.clock(), (root.Position-point.Position).Magnitude, true)
    if not ticket then return end
    self:notify(player, "LATÚNIA · preparando travessia rápida de teste…")
    task.delay(1.2, function()
        if self.destroyed then return end
        local valid = player.Parent == Players and player.Character == character
            and character.Parent and humanoid.Health > 0 and root.Parent == character
            and point:IsDescendantOf(workspace) and (root.Position-point.Position).Magnitude <= 14
        if not self.travel:finish(player, ticket) or not valid then return end
        if to == "Hub" then
            -- Keep the controller's travel state if returning to Aetheria fails.
            -- The player can then activate the return prompt again.
            local ok, err = pcall(self.onReturn, player)
            if not ok then
                warn("[Latunia] retorno a Aetheria falhou: " .. tostring(err))
                self:notify(player, "Não foi possível voltar a Aetheria. Tente novamente no portal.")
                return
            end
            self:forget(player)
            return
        end
        if not self:teleportToIsland(character, root, to) then
            self:notify(player, "A travessia falhou. Tente novamente neste portal.")
            return
        end
        self:trackArrival(player, to)
        -- This callback is only reached after the server validates the
        -- travel ticket, character, portal position and successful arrival.
        if self.onArrival then
            local completed, err = pcall(self.onArrival, player, to)
            if not completed then
                warn("[Latunia] arrival objective callback failed: " .. tostring(err))
            end
        end
        local slot = self.slots[to]
        local provisional = slot and slot.Content:FindFirstChild("ReservedLanding") ~= nil
        local extra = provisional
            and "\nÁrea de desembarque provisória · cenário ainda não construído."
            or "\nMapa explorável em desenvolvimento · sem missão/recompensa nova."
        self:notify(player, Layout.islands[to].name..extra)
    end)
    return true
end

-- Test commands in Studio or staging. Keep the character and travel state
-- together without awarding discoveries.
function Controller:debugWarp(player, to)
    if self.destroyed or player.Parent ~= Players then return false end
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid or humanoid.Health <= 0 then return false end
    if to == "Hub" then
        local ok, err = pcall(self.onReturn, player)
        if not ok then
            warn("[Latunia] retorno debug falhou: " .. tostring(err))
            return false
        end
        self:forget(player)
        return true
    end
    if not self.origins[to] or not self:teleportToIsland(character, root, to) then
        return false
    end
    self.travel:remove(player)
    self:trackArrival(player, to)
    return true
end

function Controller:prompt(point, from, to, action)
    -- Register only real world portals. A menu can request an existing
    -- portal interaction, but cannot invent remote routes or bypass proximity.
    self.portalPoints[from] = self.portalPoints[from] or {}
    self.portalPoints[from][to] = point
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "LatuniaTravel"
    prompt.ActionText = action
    prompt.ObjectText = to == "Hub" and "Aetheria / MYTHRAGON" or "Latúnia · protótipo 3D"
    prompt.MaxActivationDistance, prompt.RequiresLineOfSight = 12, false
    prompt.KeyboardKeyCode, prompt.GamepadKeyCode = Enum.KeyCode.E, Enum.KeyCode.ButtonX
    prompt.ClickablePrompt, prompt.HoldDuration = true, 0
    prompt.Parent = point
    table.insert(self.connections, prompt.Triggered:Connect(function(player)
        self:request(player, point, from, to)
    end))
end

local function atlas(parent, origin)
    local m = B.model(parent, "Atlas3D")
    B.part(m, "SeaTable", Vector3.new(76, 2, 58), CFrame.new(origin+Vector3.new(0, 3, 0)),
        Color3.fromRGB(49, 89, 92), Enum.Material.Glass)
    for i, id in ipairs(Layout.order) do
        local def = Layout.islands[id]
        local p = origin+Vector3.new(def.x/650*23, 5, def.z/650*17)
        local color = id == "Deserto" and B.colors.sand or id == "Vulcanica"
            and B.colors.basalt or id == "Gelo" and Color3.fromRGB(181, 210, 207)
            or id == "Selva" and Color3.fromRGB(72, 105, 73) or B.colors.copper
        B.part(m, id.."Miniature", Vector3.new(12, 2, 10), CFrame.new(p), color,
            Enum.Material.Slate, false)
        if id == "Central" then
            B.part(m, "ClockTowerMiniature", Vector3.new(2.8, 9, 2.8),
                CFrame.new(p+Vector3.new(0, 5, 0)), B.colors.brass, nil, false)
            local clock = B.part(m, "ClockFace", Vector3.new(2.5, 2.5, 0.2),
                CFrame.new(p+Vector3.new(0, 7, 1.5)), B.colors.amber, nil, false)
            B.label(clock, "Torre-Relógio", Vector3.new(0, 5, 0), 38)
        elseif id == "Vulcanica" then
            B.part(m, "CraterMiniature", Vector3.new(7, 5, 7),
                CFrame.new(p+Vector3.new(0, 3, 0)), B.colors.basalt, Enum.Material.Basalt, false, "Wedge")
            B.part(m, "LavaMiniature", Vector3.new(3, 0.4, 3),
                CFrame.new(p+Vector3.new(0, 5.6, 0)), Color3.fromRGB(255, 130, 41), Enum.Material.Neon, false)
        else
            B.part(m, "IslandLandmark", Vector3.new(3, id == "Gelo" and 7 or 4, 4),
                CFrame.new(p+Vector3.new(0, 3, 0)), color, Enum.Material.Slate, false,
                id == "Gelo" and "Wedge" or nil)
        end
        local number = B.part(m, "MapNumber", Vector3.new(2, 0.2, 2),
            CFrame.new(p+Vector3.new(4, 1.3, 3)), B.colors.brass, nil, false)
        local gui = Instance.new("SurfaceGui")
        gui.Face, gui.CanvasSize, gui.Parent = Enum.NormalId.Top, Vector2.new(64, 64), number
        local text = Instance.new("TextLabel")
        text.Size, text.BackgroundTransparency = UDim2.fromScale(1, 1), 1
        text.Text, text.TextScaled, text.TextColor3 = tostring(i), true, B.colors.iron
        text.Parent = gui
    end
    for _, route in ipairs(Layout.docks) do
        local def = Layout.islands[route.id]
        local a = origin+Vector3.new(route.central[3]/650*23, 4.3, route.central[4]/650*17)
        local b = origin+Vector3.new((def.x+route.island[3])/650*23, 4.3,
            (def.z+route.island[4])/650*17)
        for i = 0, 5 do
            B.beam(m, "AtlasDashedRoute", a:Lerp(b, i/6), a:Lerp(b, (i+0.5)/6),
                0.2, 0.15, B.colors.brass, false)
        end
    end
    local legend = B.part(m, "AtlasLegend", Vector3.new(3, 9, 2),
        CFrame.new(origin+Vector3.new(-47, 4.5, 0)), B.colors.brass)
    B.label(legend, "ARQUIPÉLAGO DE LATÚNIA · N ↑ (-Z)\n1 Vila Central · 2 Gelo · 3 Deserto\n4 Selva · 5 Vulcânica", Vector3.new(0, 10, 0), 90)
end

local function airship(parent, a, b)
    local cf = CFrame.lookAt(a:Lerp(b, 0.5)+Vector3.new(0, 48, 0),
        b+Vector3.new(0, 48, 0))
    B.part(parent, "EmptyAirshipEnvelope", Vector3.new(20, 17, 54), cf,
        B.colors.copper, Enum.Material.Metal, false, "Ball")
    B.part(parent, "ClosedGondola", Vector3.new(10, 6, 21), cf*CFrame.new(0, -14, 3),
        B.colors.iron, Enum.Material.Metal, false)
    local glass = B.part(parent, "AmberAirshipWindows", Vector3.new(10.2, 2.5, 15),
        cf*CFrame.new(0, -13, 3), B.colors.amber, Enum.Material.Glass, false)
    glass.Transparency = 0.3
    for _, side in ipairs({ -1, 1 }) do
        B.beam(parent, "GondolaSupport", (cf*CFrame.new(side*4, -11, 0)).Position,
            (cf*CFrame.new(side*7, -4, 0)).Position, 0.5, 0.5, B.colors.iron, false)
    end
end

function Controller:destroy()
    if self.destroyed then return end
    self.destroyed = true
    mounted[self.parent] = nil
    for _, conn in ipairs(self.connections) do conn:Disconnect() end
    for player in pairs(self.playerConns) do self:forget(player) end
    for player, gui in pairs(self.notices) do
        gui:Destroy()
        self.notices[player] = nil
    end
    self.travel:clear()
    self.root:Destroy()
end

function Map.build(parent, onReturn, partnerBuilders, onArrival, onDebugArrival, onQuestBoard)
    assert(parent == workspace or parent:IsDescendantOf(workspace))
    assert(type(onReturn) == "function")
    assert(onArrival == nil or type(onArrival) == "function")
    assert(onDebugArrival == nil or type(onDebugArrival) == "function")
    assert(onQuestBoard == nil or type(onQuestBoard) == "function")
    if mounted[parent] then return mounted[parent] end
    assert(not parent:FindFirstChild("LatuniaCodex"), "Existing Latunia scene is not owned by this controller")
    local root = B.model(parent, "LatuniaCodex")
    root:SetAttribute("Prototype", true)
    root:SetAttribute("TravelMode", "ServerTeleportPrototype")
    local self = setmetatable({
        root = root, parent = parent, onReturn = onReturn, onArrival = onArrival,
        onDebugArrival = onDebugArrival, onQuestBoard = onQuestBoard,
        travel = TravelState.new(),
        current = {}, origins = {}, slots = {}, notices = {}, connections = {}, playerConns = {},
        portalPoints = {},
    }, Controller)
    mounted[parent] = self
    local ok, err = xpcall(function()
    local origin = pos(Layout.origin)
    local sea = B.part(root, "LatuniaSea", Vector3.new(1800, 2, 1800),
        CFrame.new(origin-Vector3.new(0, 15, 0)), Color3.fromRGB(44, 82, 89), Enum.Material.Glass, false)
    sea.Transparency = 0.18
    local islands = B.model(root, "Islands")
    for _, id in ipairs(Layout.order) do
        local def = Layout.islands[id]
        local at = origin+Vector3.new(def.x, 0, def.z)
        self.origins[id] = at
        local slot = B.model(islands, id)
        self.slots[id] = slot
        local anchor = B.part(slot, "BuildAnchor", Vector3.one, CFrame.new(at), B.colors.iron, nil, false)
        anchor.Transparency = 1
        local content = B.model(slot, "Content")
        local function reservedLanding()
            -- Temporary landing only, explicitly NOT the partner's finished island.
            local base = B.part(content, "ReservedLanding", Vector3.new(220, 20, 220),
                CFrame.new(at-Vector3.new(0, 10, 0)), B.colors.basalt, Enum.Material.Slate)
            B.label(base, def.name.."\nDesembarque provisório · mapa 3D do GLM pendente",
                Vector3.new(0, 25, 0), 220)
        end
        -- Endurecimento GLM-R008 (autorização do dono): uma ilha que falha em
        -- runtime não pode derrubar o arquipélago inteiro nem o portão do hub.
        local okIsland, errIsland = true, nil
        if id == "Deserto" then
            okIsland, errIsland = pcall(Islands.desert, content, at)
        elseif id == "Vulcanica" then
            okIsland, errIsland = pcall(Islands.volcanic, content, at)
        elseif partnerBuilders and partnerBuilders[id] then
            okIsland, errIsland = pcall(partnerBuilders[id], content, anchor.CFrame)
        else
            okIsland = false -- sem construtor: landing provisório
        end
        if not okIsland then
            if errIsland then
                warn("[Latunia] ilha " .. id .. " falhou; landing provisório: " .. tostring(errIsland))
            end
            if not content:FindFirstChild("ReservedLanding") then
                reservedLanding()
            end
        end
    end
    atlas(root, self.origins.Central)
    -- Reuse the GLM village mural; never create or activate the NPC library.
    -- The noticeboard reads the player's next real objective but grants none.
    local mural = self.slots.Central.Content:FindFirstChild("MuralQuadro", true)
    if mural and onQuestBoard then
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "LatuniaQuestBoard"
        prompt.ActionText = "Consultar missão"
        prompt.ObjectText = "Mural de Avisos · Vila Central"
        prompt.MaxActivationDistance = 12
        prompt.RequiresLineOfSight = false
        prompt.ClickablePrompt = true
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
        prompt.HoldDuration = 0
        prompt.Parent = mural
        table.insert(self.connections, prompt.Triggered:Connect(function(player)
            if self.destroyed or self.current[player] ~= "Central" then return end
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if not rootPart or not humanoid or humanoid.Health <= 0
                or (rootPart.Position - mural.Position).Magnitude > 14 then return end
            local ok, err = pcall(onQuestBoard, player)
            if not ok then warn("[Latunia] Mural de Avisos falhou: " .. tostring(err)) end
        end))
    elseif onQuestBoard then
        warn("[Latunia] Mural GLM ausente; orientação continua no painel individual")
    end
    for _, route in ipairs(Layout.docks) do
        local c, p = route.central, route.island
        local from = self.origins.Central
        local target = self.origins[route.id]
        local floor = Layout.islands[route.id].floor
        local ca, cb = from+Vector3.new(c[1], 1, c[2]), from+Vector3.new(c[3], 1, c[4])
        local ia, ib = target+Vector3.new(p[1], floor+1, p[2]), target+Vector3.new(p[3], floor+1, p[4])
        local dockName = route.id == "Deserto" and "1 · Doca do Cânion"
            or route.id == "Vulcanica" and "1 · Doca das Cinzas" or "Doca provisória"
        local centralPoint = B.dock(root, ca, cb, "Embarque · "..Layout.islands[route.id].name)
        local islandPoint = B.dock(root, ia, ib, dockName)
        self:prompt(centralPoint, "Central", route.id, "Viajar · "..Layout.islands[route.id].name)
        self:prompt(islandPoint, route.id, "Central", "Voltar à Vila Central")
        local a, b = cb+Vector3.new(0, 5, 0), ib+Vector3.new(0, 5, 0)
        local count = math.ceil((b-a).Magnitude/20)
        for i = 0, count-1 do
            B.beam(root, "AirRouteDash", a:Lerp(b, i/count), a:Lerp(b, (i+0.45)/count),
                0.8, 0.5, B.colors.brass, false)
        end
        airship(root, a, b)
    end
    local gate = B.part(root, "LatuniaTestGate", Vector3.new(6, 8, 1), CFrame.new(24, 4.5, 8),
        B.colors.amber, Enum.Material.Glass, false)
    gate.Transparency = 0.3
    B.label(gate, "LATÚNIA · acesso de teste\nDeserto / Vulcânica / Atlas 3D", Vector3.new(0, 7, 0), 120)
    self:prompt(gate, "Hub", "Central", "Explorar Latúnia")
    local exit = B.part(root, "ReturnToMythragon", Vector3.new(5, 7, 1),
        CFrame.new(origin+Vector3.new(0, 3.5, 72)), B.colors.amber, Enum.Material.Glass, false)
    B.label(exit, "Voltar a Aetheria", Vector3.new(0, 6, 0))
    self:prompt(exit, "Central", "Hub", "Voltar a Aetheria")
    table.insert(self.connections, Players.PlayerRemoving:Connect(function(player) self:forget(player) end))
    table.insert(self.connections, root.Destroying:Connect(function() self:destroy() end))
    task.spawn(function()
        while not self.destroyed and root.Parent do
            task.wait(0.5)
            if self.destroyed then break end
            for player, id in pairs(self.current) do
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                if humanoid and humanoid.Health > 0 and hrp then
                    local relative = hrp.Position-self.origins[id]
                    local craterFall = id == "Vulcanica" and relative.Y < 45
                        and (Vector2.new(relative.X+25, relative.Z+25)).Magnitude < 36
                    if relative.Y < -20 or craterFall then
                        self.travel:remove(player)
                        if self:teleportToIsland(character, hrp, id) then
                            self:notify(player, "Você foi devolvido ao desembarque seguro.")
                        end
                    end
                end
            end
        end
    end)
    end, debug.traceback)
    if not ok then
        self:destroy()
        error(err, 0)
    end
    return self
end

-- Public server entry point for an on-screen travel menu. This intentionally
-- uses the SAME portal, distance, tickets and route validation as the prompt.
-- It does not teleport a player, grant discoveries or accept client results.
function Map.requestTravel(parent, player, to)
    if not game:GetService("RunService"):IsServer() then return false end
    local controller = mounted[parent]
    if not controller or controller.destroyed or not player or type(to) ~= "string" then
        return false
    end
    local from = controller.current[player] or "Hub"
    local points = controller.portalPoints[from]
    local point = points and points[to]
    if not point then return false end
    return controller:request(player, point, from, to) == true
end

function Map.debugWarp(parent, player, to)
    local Access = require(script.Parent.Parent.Parent.Hub.CommandAccess)
    if not Access.canUse(player) then return false end
    local controller = mounted[parent]
    if not controller or not controller:debugWarp(player, to) then return false end
    -- Release Ember only once the destination is confirmed. Otherwise its
    -- recovery loop can pull the player out of Latúnia and leave stale state.
    if controller.onDebugArrival then controller.onDebugArrival(player) end
    return true
end

return Map
