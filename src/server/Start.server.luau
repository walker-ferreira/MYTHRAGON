-- Editor: CODEX/integrador. All mandatory initialization reports health, even on failure.
local Bootstrap = require(script.Parent.Diagnostics.Bootstrap)
Bootstrap.run()

-- Staging-only version label. No credentials, JobId or private diagnostics in the UI.
if game.PlaceId == 135004978091658 then
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local function identify(player)
		task.spawn(function()
			local playerGui = player:WaitForChild("PlayerGui", 30)
			if not playerGui or player.Parent ~= Players then return end
			if playerGui:FindFirstChild("MythragonBuild") then return end
			local health = ReplicatedStorage:FindFirstChild("MythragonHealth")
			local gui = Instance.new("ScreenGui")
			gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "MythragonBuild", false, 1
			local text = Instance.new("TextLabel")
			text.Size, text.Position = UDim2.new(1, 0, 0, 20), UDim2.fromOffset(0, 0)
			text.BackgroundTransparency, text.TextSize = 0.4, 12
			text.TextColor3 = Color3.new(1, 1, 1)
			local sha = health and health:GetAttribute("GitSha") or "unknown"
			local state = health and health:GetAttribute("State") or "FAILED"
			text.Text = "STAGING EXPERIMENTAL · " .. string.sub(sha, 1, 12)
				.. " · v" .. game.PlaceVersion .. " · " .. state
			text.Parent, gui.Parent = gui, playerGui
		end)
	end
	Players.PlayerAdded:Connect(identify)
	for _, player in Players:GetPlayers() do identify(player) end
end
