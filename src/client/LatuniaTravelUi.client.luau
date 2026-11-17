-- LocalScript: botão "VIAGEM" na tela + menu de destinos (GLM-R011/R012).
-- Pedido do dono ("cria um botao na tela para abrir a interface de comandos").
-- O clique só envia o destino ao servidor (RemoteEvent); TODA a validação e o
-- teleporte acontecem no servidor (LatuniaCommands.server.luau). Nada de
-- progresso, recompensa ou estado decide no cliente.
-- Botão compatível com clique (PC) e toque (mobile) via Activated.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("LatuniaTravelRemote", 30)
if not remote then
	warn("[Latunia] botão de viagem desativado: LatuniaTravelRemote ausente")
	return
end

local DESTINOS = {
	{ key = "hub", nome = "Hub · Aetheria" },
	{ key = "vila", nome = "Vila Central" },
	{ key = "gelo", nome = "Ilha do Gelo" },
	{ key = "selva", nome = "Ilha da Selva" },
	{ key = "deserto", nome = "Ilha do Deserto" },
	{ key = "vulcanica", nome = "Ilha Vulcânica" },
}

local COR_FUNDO = Color3.fromRGB(38, 34, 36)
local COR_TEXTO = Color3.fromRGB(246, 225, 176)
local COR_PADRAO = Color3.fromRGB(214, 158, 94)

local gui = Instance.new("ScreenGui")
gui.Name = "LatuniaTravelUi"
gui.ResetOnSpawn = false
gui.DisplayOrder = 25

local botao = Instance.new("TextButton")
botao.Name = "AbrirViagem"
botao.AnchorPoint = Vector2.new(1, 1)
botao.Position = UDim2.new(1, -14, 1, -14)
botao.Size = UDim2.new(0, 92, 0, 46)
botao.BackgroundColor3 = COR_FUNDO
botao.BackgroundTransparency = 0.08
botao.BorderSizePixel = 0
botao.AutoButtonColor = true
botao.TextColor3 = COR_TEXTO
botao.Font = Enum.Font.Garamond
botao.TextScaled = true
botao.Text = "VIAGEM"
botao.Parent = gui
local limiteBotao = Instance.new("UITextSizeConstraint")
limiteBotao.MaxTextSize = 22
limiteBotao.Parent = botao
local cantosBotao = Instance.new("UICorner")
cantosBotao.CornerRadius = UDim.new(0, 8)
cantosBotao.Parent = botao

local menu = Instance.new("Frame")
menu.Name = "MenuViagem"
menu.AnchorPoint = Vector2.new(1, 1)
menu.Position = UDim2.new(1, -14, 1, -66)
menu.Size = UDim2.new(0, 236, 0, 316)
menu.BackgroundColor3 = COR_FUNDO
menu.BackgroundTransparency = 0.06
menu.BorderSizePixel = 0
menu.Visible = false
menu.Parent = gui
local cantosMenu = Instance.new("UICorner")
cantosMenu.CornerRadius = UDim.new(0, 10)
cantosMenu.Parent = menu

local titulo = Instance.new("TextLabel")
titulo.Name = "Titulo"
titulo.Position = UDim2.new(0, 12, 0, 8)
titulo.Size = UDim2.new(1, -24, 0, 30)
titulo.BackgroundTransparency = 1
titulo.TextColor3 = COR_TEXTO
titulo.Font = Enum.Font.Garamond
titulo.TextScaled = true
titulo.Text = "TERMINAL DE VIAGEM"
titulo.Parent = menu
local limiteTitulo = Instance.new("UITextSizeConstraint")
limiteTitulo.MaxTextSize = 18
limiteTitulo.Parent = titulo

local fechar = Instance.new("TextButton")
fechar.Name = "Fechar"
fechar.AnchorPoint = Vector2.new(1, 0)
fechar.Position = UDim2.new(1, -8, 0, 8)
fechar.Size = UDim2.new(0, 62, 0, 26)
fechar.BackgroundColor3 = COR_PADRAO
fechar.BorderSizePixel = 0
fechar.TextColor3 = COR_FUNDO
fechar.Font = Enum.Font.Garamond
fechar.TextScaled = true
fechar.Text = "FECHAR"
fechar.Parent = menu
local limiteFechar = Instance.new("UITextSizeConstraint")
limiteFechar.MaxTextSize = 14
limiteFechar.Parent = fechar
local cantosFechar = Instance.new("UICorner")
cantosFechar.CornerRadius = UDim.new(0, 6)
cantosFechar.Parent = fechar

local function destinoButton(dados, indice)
	local item = Instance.new("TextButton")
	item.Name = "Destino" .. dados.key
	item.Position = UDim2.new(0, 12, 0, 44 + (indice - 1) * 40)
	item.Size = UDim2.new(1, -24, 0, 34)
	item.BackgroundColor3 = COR_PADRAO
	item.BackgroundTransparency = 0.15
	item.BorderSizePixel = 0
	item.TextColor3 = COR_FUNDO
	item.Font = Enum.Font.Garamond
	item.TextScaled = true
	item.Text = dados.nome
	item.Parent = menu
	local limite = Instance.new("UITextSizeConstraint")
	limite.MaxTextSize = 17
	limite.Parent = item
	local cantos = Instance.new("UICorner")
	cantos.CornerRadius = UDim.new(0, 6)
	cantos.Parent = item
	item.Activated:Connect(function()
		menu.Visible = false
		remote:FireServer(dados.key)
	end)
	return item
end

for indice, dados in ipairs(DESTINOS) do
	destinoButton(dados, indice)
end

botao.Activated:Connect(function()
	menu.Visible = not menu.Visible
end)
fechar.Activated:Connect(function()
	menu.Visible = false
end)

gui.Parent = player:WaitForChild("PlayerGui")
