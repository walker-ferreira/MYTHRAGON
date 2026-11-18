-- Terminais físicos de viagem de Latúnia (GLM-R013 · rework seguro do PR #45).
-- Pads de latão com ClickDetector posicionados JUNTO aos pontos de embarque
-- oficiais: portão do hub, docas centrais de embarque da Vila, docas de
-- retorno das ilhas e portal de volta a Aetheria.
--
-- Toda travessia passa por Map.requestTravel -> Controller:request — o mesmo
-- bilhete do TravelState, a mesma proximidade (<= 14 studs) e as mesmas rotas
-- do menu público seguro (PR #58). Aqui não há teleporte direto, não há
-- scripts de cliente e nenhum RemoteEvent é criado (o TravelMenu.server.luau
-- do Codex é o dono do canal remoto; a UI oficial na tela continua valendo).
--
-- PC: clique no pad. Mobile: toque no pad. Cooldown e fila são do controlador.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Codex = script.Parent.Parent.Latunia.Codex
local Map = require(Codex.Map)
local Layout = require(Codex.Layout)
local B = require(Codex.Build)

local function pos(t)
	return Vector3.new(t[1], t[2], t[3])
end

local function notify(player, message)
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then
		return
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "LatuniaTerminalNotice"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 30
	local text = Instance.new("TextLabel")
	text.AnchorPoint = Vector2.new(0.5, 1)
	text.Position = UDim2.fromScale(0.5, 0.9)
	text.Size = UDim2.new(0.7, 0, 0, 34)
	text.BackgroundColor3 = Color3.fromRGB(24, 20, 24)
	text.BackgroundTransparency = 0.15
	text.TextColor3 = Color3.fromRGB(246, 225, 176)
	text.Font = Enum.Font.Garamond
	text.TextScaled = true
	text.TextWrapped = true
	text.Text = message
	text.Parent = gui
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = 20
	limit.Parent = text
	gui.Parent = playerGui
	task.delay(4, function()
		gui:Destroy()
	end)
end

-- Cooldown local de aviso (o bilhete real do TravelState continua no
-- controlador; isto só evita spam de cliques rápidos).
local COOLDOWN = 1.5
local ultimoAviso = {}

Players.PlayerRemoving:Connect(function(player)
	ultimoAviso[player] = nil
end)

local COR_PADRAO = Color3.fromRGB(246, 225, 176)
local CORES = {
	Central = Color3.fromRGB(240, 190, 96),
	Gelo = Color3.fromRGB(140, 200, 255),
	Deserto = Color3.fromRGB(230, 190, 120),
	Selva = Color3.fromRGB(120, 200, 130),
	Vulcanica = Color3.fromRGB(255, 120, 70),
	Hub = Color3.fromRGB(190, 140, 220),
}

local function nomeDe(slotId)
	if slotId == "Hub" then
		return "Aetheria · MYTHRAGON"
	end
	local def = Layout.islands[slotId]
	return def and def.name or slotId
end

-- Pad individual: latão com ClickDetector (clique no PC, toque no mobile).
-- A travessia é sempre pedida ao controlador seguro; o pad nunca teleporta.
local function pad(model, baseCFrame, offset, slotId)
	local padPart = B.part(model, "Destino" .. slotId, Vector3.new(1.7, 0.5, 1.5),
		baseCFrame * CFrame.new(offset), CORES[slotId] or COR_PADRAO, Enum.Material.Neon, true)
	local click = Instance.new("ClickDetector")
	click.Name = "Viajar" .. slotId
	click.MaxActivationDistance = 16
	click.Parent = padPart
	B.label(padPart, nomeDe(slotId), Vector3.new(0, 2.2, 0), 55)
	click.MouseClick:Connect(function(player)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not humanoid or humanoid.Health <= 0 or not root then
			return
		end
		if (root.Position - padPart.Position).Magnitude > 16 then
			return
		end
		local agora = os.clock()
		if ultimoAviso[player] and agora - ultimoAviso[player] < COOLDOWN then
			return
		end
		ultimoAviso[player] = agora
		local ok, accepted = pcall(Map.requestTravel, workspace, player, slotId)
		if not ok then
			warn("[Latunia] terminal: pedido falhou para " .. player.Name .. ": " .. tostring(accepted))
			notify(player, "Viagem indisponível neste servidor. Tente em instantes.")
		elseif accepted then
			notify(player, "Embarque em " .. nomeDe(slotId) .. " · fique no deck até a travessia.")
		else
			notify(player, "Aproxime-se do ponto de embarque desta rota para embarcar.")
		end
	end)
	return padPart
end

-- terminal(parent, baseCFrame, titulo, rotas): base de bronze, painel de
-- ardósia com o título e pads em grade (até 3 por fila) no topo.
local function terminal(parent, baseCFrame, titulo, rotas)
	local model = B.model(parent, "TerminalViagem")
	B.part(model, "Base", Vector3.new(5.6, 1, 3.4), baseCFrame * CFrame.new(0, 0.5, 0),
		Color3.fromRGB(140, 94, 52), Enum.Material.Metal)
	local painel = B.part(model, "Painel", Vector3.new(5.6, 3.2, 0.4),
		baseCFrame * CFrame.new(0, 2.6, -1.5), Color3.fromRGB(38, 34, 36), Enum.Material.Slate)
	B.label(painel, titulo, Vector3.new(0, 0, 0.3), 70)
	local porFila = 3
	for indice, slotId in ipairs(rotas) do
		local fila = math.floor((indice - 1) / porFila)
		local coluna = (indice - 1) % porFila
		local naFila = math.min(#rotas - fila * porFila, porFila)
		local x = (coluna - (naFila - 1) / 2) * 1.9
		local z = fila == 0 and 0.85 or -0.9
		pad(model, baseCFrame, Vector3.new(x, 1.25, z), slotId)
	end
	return model
end

-- O ponto oficial de embarque é B.dock(...): BoardingPoint em b + (0, 3, 0),
-- NÃO no centro da doca. Colocar os pads a 7 studs de b, em direção a a,
-- mantém o clique dentro da distância máxima real (14 studs) do controlador.
local function pertoDoPonto(quad, origem, floor)
	local a = Vector3.new(quad[1], 0, quad[2])
	local b = Vector3.new(quad[3], 0, quad[4])
	local direction = (a - b).Magnitude > 0.01 and (a - b).Unit or Vector3.new(0, 0, -1)
	local localPos = b + direction * 7
	return CFrame.new(origem + localPos + Vector3.new(0, floor + 1.6, 0))
end

local function embarqueCFrame(quad)
	return pertoDoPonto(quad, pos(Layout.origin), 0)
end

local function retornoCFrame(quad, slotId)
	local def = Layout.islands[slotId]
	local origin = pos(Layout.origin) + Vector3.new(def.x, 0, def.z)
	return pertoDoPonto(quad, origin, def.floor)
end

task.spawn(function()
	local map = workspace:WaitForChild("MythragonMap", 120)
	if not map then
		warn("[Latunia] Terminais não instalados: MythragonMap ausente")
		return
	end

	-- Hub: junto ao portão de Latúnia (part "LatuniaTestGate" em (24, 4.5, 8)).
	terminal(map, CFrame.new(20, 0.5, 14), "TERMINAL DE VIAGEM\nLatúnia", { "Central" })

	local codex = map:WaitForChild("LatuniaCodex", 120)
	if not codex then
		warn("[Latunia] Terminais das ilhas não instalados: LatuniaCodex ausente")
		return
	end
	local islands = codex:WaitForChild("Islands", 60)
	if not islands then
		warn("[Latunia] Terminais das ilhas não instalados: Islands ausente")
		return
	end

	for _, route in ipairs(Layout.docks) do
		local slot = islands:WaitForChild(route.id, 120)
		if slot then
			task.wait(0.2)
			-- Embarque na Vila Central: doca central desta rota.
			terminal(slot, embarqueCFrame(route.central),
				"EMBARQUE\n" .. nomeDe(route.id), { route.id })
			-- Retorno: doca de chegada da própria ilha.
			terminal(slot, retornoCFrame(route.island, route.id),
				"RETORNO\nVila Central", { "Central" })
		else
			warn("[Latunia] terminal ausente: slot " .. route.id .. " não montou")
		end
	end

	-- Central -> Aetheria: junto ao portal de saída (origem + (0, 3.5, 72)).
	local central = islands:WaitForChild("Central", 120)
	if central then
		task.wait(0.2)
		local origin = pos(Layout.origin)
		terminal(central, CFrame.new(origin.X, origin.Y + 0.6, origin.Z + 78),
			"RETORNO\nAetheria", { "Hub" })
	end
end)
