-- Comandos de teleporte de teste (Latúnia <-> Aetheria), pedidos pelo dono
-- ("tem algum comando de teleporte") e autorizados nesta sessão.
-- GLM 5.3 · registros GLM-R008 (chat /ir) e GLM-R011 (terminais físicos).
--
-- Duas formas de viajar, todas validadas no servidor:
--
-- 1) Chat (apenas Studio, como combinado na revisão do Codex):
--   /ir hub · vila · deserto · vulcanica · gelo · selva   ("!ir" também funciona)
--
-- 2) Terminais de Viagem físicos (funcionam no jogo publicado também):
--   Pads de latão com ClickDetector: clique (PC) ou toque (mobile) no pad
--   do destino. Cada terminal oferece só as rotas permitidas pelo
--   Layout.canTravel do Codex (tudo passa pela Vila Central):
--     · Hub (Aetheria): um pad "Vila Central"
--     · Vila Central (praça): pads Hub, Gelo, Selva, Deserto, Vulcânica
--     · Gelo/Selva/Deserto/Vulcânica: pad de volta à Vila Central
--
-- Nota de integração (GLM-R011): enquanto o Codex não expõe o controller
-- oficial (pedido de `Map.controller(parent)` em docs/agents/GLM.md), os
-- pads fazem a travessia direta pelo mesmo Layout do Codex (origem +
-- arrivals + mesma orientação da chegada), sem estados/recompensas.
-- Depois do accessor, os pads passam pelo `Controller:request` oficial
-- (tickets do TravelState) sem mudar a interface.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Codex = script.Parent.Parent.Latunia.Codex
local Map = require(Codex.Map)
local Layout = require(Codex.Layout)
local B = require(Codex.Build)

local STUDIO = RunService:IsStudio()

local DESTINOS = {
	hub = "Hub", vila = "Central", central = "Central",
	gelo = "Gelo", selva = "Selva", deserto = "Deserto",
	vulcanica = "Vulcanica",
}

-- RemoteEvent do botão de tela (GLM-R012): o cliente só envia o nome do
-- destino; validação, cooldown e teleporte são sempre do lado do servidor.
local remotoViagem = ReplicatedStorage:FindFirstChild("LatuniaTravelRemote")
if not remotoViagem then
	remotoViagem = Instance.new("RemoteEvent")
	remotoViagem.Name = "LatuniaTravelRemote"
	remotoViagem.Parent = ReplicatedStorage
end

local function notify(player, message)
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then
		return
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "LatuniaCommandNotice"
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

local function pos(t)
	return Vector3.new(t[1], t[2], t[3])
end

local ultimoUso = {}
local COOLDOWN = 1.5

local function personagemPronto(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not humanoid or humanoid.Health <= 0 then
		return nil
	end
	return character, root
end

local function origem(slotId)
	local def = Layout.islands[slotId]
	return pos(Layout.origin) + Vector3.new(def.x, 0, def.z)
end

local function chegada(slotId)
	local at = origem(slotId)
	local p = at + pos(Layout.arrivals[slotId])
	return CFrame.lookAt(p, Vector3.new(at.X, p.Y, at.Z))
end

local function viajar(player, slotId)
	local agora = os.clock()
	if ultimoUso[player] and agora - ultimoUso[player] < COOLDOWN then
		return
	end
	local character, root = personagemPronto(player)
	if not character then
		return
	end
	ultimoUso[player] = os.clock()
	if slotId == "Hub" then
		root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
		character:PivotTo(CFrame.new(0, 4, 14))
		notify(player, "Aetheria · hub de MYTHRAGON. O portal de Latúnia fica ao lado.")
		return
	end
	if not workspace:FindFirstChild("LatuniaCodex") then
		notify(player, "Latúnia ainda não terminou de montar neste servidor. Tente em instantes.")
		ultimoUso[player] = nil
		return
	end
	root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
	character:PivotTo(chegada(slotId))
	notify(player, Layout.islands[slotId].name .. " · desembarque no atracadouro da ilha.")
end

remotoViagem.OnServerEvent:Connect(function(player, key)
	if typeof(key) ~= "string" then
		return
	end
	local slotId = DESTINOS[key]
	if not slotId then
		notify(player, "Destino desconhecido.")
		return
	end
	viajar(player, slotId)
end)

local function onChatted(player, message)
	local key = message:match("^/ir%s+([%a]+)") or message:match("^!ir%s+([%a]+)")
	if key then
		local slotId = DESTINOS[key:lower()]
		if not slotId then
			notify(player, "Destino desconhecido. Use: /ir hub · vila · deserto · vulcanica · gelo · selva")
			return
		end
		viajar(player, slotId)
	end
end

-- Chat /ir segue restrito ao Studio (revisão do Codex, GLM-R008); os
-- terminais físicos funcionam em qualquer servidor porque só oferecem
-- rotas já cobertas pelos pontos oficiais do Layout.
if STUDIO then
	Players.PlayerAdded:Connect(function(player)
		player.Chatted:Connect(function(message)
			onChatted(player, message)
		end)
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		player.Chatted:Connect(function(message)
			onChatted(player, message)
		end)
	end
end

Players.PlayerRemoving:Connect(function(player)
	ultimoUso[player] = nil
end)

-- ===========================================================================
-- Terminais de Viagem (interface física dos comandos, GLM-R011)
-- ===========================================================================

local COR_PADRAO = Color3.fromRGB(246, 225, 176)
local CORES = {
	Hub = COR_PADRAO,
	Central = Color3.fromRGB(214, 158, 94),
	Gelo = Color3.fromRGB(181, 210, 207),
	Selva = Color3.fromRGB(126, 173, 120),
	Deserto = Color3.fromRGB(221, 187, 133),
	Vulcanica = Color3.fromRGB(196, 104, 64),
}

local NOMES = {
	Hub = "Hub · Aetheria",
	Central = "Vila Central",
	Gelo = "Ilha do Gelo",
	Selva = "Ilha da Selva",
	Deserto = "Ilha do Deserto",
	Vulcanica = "Ilha Vulcânica",
}

-- Pad individual: latão com topo de vidro âmbar, rótulo flutuante e
-- ClickDetector (clique no PC, toque no mobile). Sem client scripts.
local function pad(model, baseCFrame, offset, slotId)
	local padPart = B.part(model, "Destino" .. slotId, Vector3.new(1.7, 0.5, 1.5),
		baseCFrame * CFrame.new(offset), CORES[slotId] or COR_PADRAO, Enum.Material.Neon, true)
	local click = Instance.new("ClickDetector")
	click.Name = "Viajar" .. slotId
	click.MaxActivationDistance = 16
	click.Parent = padPart
	B.label(padPart, NOMES[slotId] or slotId, Vector3.new(0, 2.2, 0), 55)
	click.MouseClick:Connect(function(player)
		if (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) ~= nil
			and (player.Character.HumanoidRootPart.Position - padPart.Position).Magnitude <= 18 then
			viajar(player, slotId)
		end
	end)
	return padPart
end

-- terminal(parent, baseCFrame, titulo, rotas): base de bronze, painel de
-- ardósia com o título, pads em grade (até 3 por fila) no topo.
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

-- Posição padrão para terminal de ilha: chegada oficial do Layout,
-- deslocada 5 studs em direção ao centro da ilha, pousada no piso.
local function terminalNaChegada(slotId, pisoLocalY, ladoX, ladoZ)
	local at = origem(slotId)
	local pontoChegada = at + pos(Layout.arrivals[slotId])
	local centro = Vector3.new(at.X - pontoChegada.X, 0, at.Z - pontoChegada.Z)
	if centro.Magnitude > 0.01 then
		centro = centro.Unit
	else
		centro = Vector3.new(0, 0, -1)
	end
	local base = pontoChegada + centro * 5
		+ Vector3.new(0, at.Y + (pisoLocalY or 0) + 0.5 - pontoChegada.Y, 0)
		+ Vector3.new(ladoX or 0, 0, ladoZ or 0)
	return CFrame.new(base)
end

task.spawn(function()
	-- Terminal do hub: deck de Aetheria, a leste do spawn.
	local map = workspace:WaitForChild("MythragonMap", 120)
	if not map then
		warn("[Latunia] Terminal do hub não instalado: MythragonMap ausente")
		return
	end
	if not map:FindFirstChild("Hub") then
		map:WaitForChild("Hub", 60)
	end
	if not map:FindFirstChild("Hub") then
		warn("[Latunia] Terminal do hub não instalado: Hub ausente")
		return
	end
	terminal(map, CFrame.new(16, 0.5, 16), "TERMINAL DE VIAGEM\nLatúnia", { "Central" })

	-- Terminais das ilhas: um por slot montado, sempre junto à chegada.
	local codex = map:WaitForChild("LatuniaCodex", 120)
	if not codex then
		warn("[Latunia] Terminais das ilhas não instalados: LatuniaCodex ausente")
		return
	end
	local ilhas = codex:WaitForChild("Islands", 60)
	if not ilhas then
		warn("[Latunia] Terminais das ilhas não instalados: Islands ausente")
		return
	end
	local fila = { "Central", "Gelo", "Selva", "Deserto", "Vulcanica" }
	for _, slotId in ipairs(fila) do
		local slot = ilhas:WaitForChild(slotId, 120)
		if slot then
			task.wait(1)
			if slotId == "Central" then
				-- Praça da Vila Central (nível alto, longe da rosa-dos-ventos).
				terminal(slot, CFrame.new(2414, 32.5, -18),
					"TERMINAL DE VIAGEM\nLatúnia", { "Hub", "Gelo", "Selva", "Deserto", "Vulcanica" })
			else
				local pisoY = 0.2
				local ladoX, ladoZ = 0, 0
				if slotId == "Gelo" then
					ladoX = 4
				elseif slotId == "Selva" then
					ladoZ = 4
				elseif slotId == "Vulcanica" then
					pisoY = 8.2
				end
				terminal(slot, terminalNaChegada(slotId, pisoY, ladoX, ladoZ),
					"TERMINAL DE VIAGEM\nLatúnia", { "Central" })
			end
		else
			warn("[Latunia] Terminal não instalado: slot " .. slotId .. " ausente")
		end
	end
end)
