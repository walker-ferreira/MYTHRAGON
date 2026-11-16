-- Single composition root, explicitly callable in isolated engine tests.
-- No live hot-rebuild: idempotent per server; failures remain visible until a new server.
local Bootstrap = {}
local current

function Bootstrap.run()
	if current then return current end
	local Health = require(script.Parent.Health)
	local health = Health.new()
	current = { health = health }
	local parent = script.Parent.Parent
	local Players = game:GetService("Players")
	local Hub, Profile, map, returnToHub
	local coreOk = health:stage("Core", function()
		assert(not workspace:FindFirstChild("MythragonMap"), "Unowned existing map")
		Hub = require(parent.Hub.Map)
		local Ember = require(parent.Ember.Map)
		Profile = require(parent.Profile.Profile)
		map = Instance.new("Folder")
		map.Name = "MythragonMap"
		map.Parent = workspace
		local function onVictory(player, encounterId)
			local status, seal = Profile.recordVictory(player, "Ember", encounterId)
			if status == "granted" and seal then
				Hub.setSealEarned(player, seal.index)
				Hub.notify(player, seal.title .. " conquistado!")
			elseif status == "duplicate" and seal and Profile.hasSeal(player, seal.id) then
				Hub.setSealEarned(player, seal.index)
			end
		end
		local enterEmber = Ember.build(map, onVictory)
		returnToHub = Hub.build(map, enterEmber)
		assert(type(returnToHub) == "function", "Hub return contract")
		Ember.connectReturn(map, returnToHub)
		Players.PlayerRemoving:Connect(function(player) Profile.clearSession(player) end)
		assert(map:FindFirstChild("Hub"), "Hub did not mount")
	end, function()
		if map then map:Destroy() end
	end)
	if coreOk then
		health:stage("Varkhion", function()
			local anchor = assert(map.Hub:FindFirstChild("VarkhionAnchor"), "Varkhion anchor missing")
			local Varkhion = require(parent.Dragons.Varkhion)
			current.varkhion = Varkhion.mount(map, anchor, function(player, speciesId)
				assert(speciesId == "Varkhion", "Unexpected sanctuary species")
				Hub.completeObjective(player, "santuario")
			end)
		end, function()
			if current.varkhion then current.varkhion:destroy() end
			local partial = map:FindFirstChild("Varkhion")
			if partial then partial:Destroy() end
		end)
		health:stage("Latunia", function()
			local Latunia = require(parent.Latunia.Codex.Map)
			local Vila = require(parent.Hub.Latunia)
			current.latunia = Latunia.build(workspace, returnToHub, { Central = Vila.build })
			assert(current.latunia.root.Parent == workspace, "Latunia did not mount")
		end, function()
			-- Map.build already owns rollback/connections; do not destroy an unowned scene.
			if current.latunia then current.latunia:destroy() end
		end)
	else
		health:block("Varkhion", "Core failed")
		health:block("Latunia", "Core failed")
	end
	current.healthy = health:finish()
	return current
end

return Bootstrap
