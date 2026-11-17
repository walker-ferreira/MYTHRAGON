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
	local profileConnection
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
				require(parent.Profile.ExplorationPanel).markEmber(player)
				if current.progress then current.progress:recordSeal(player, seal.id) end
				Hub.setSealEarned(player, seal.index)
				Hub.notify(player, seal.title .. " conquistado!")
			elseif status == "duplicate" and seal and Profile.hasSeal(player, seal.id) then
				Hub.setSealEarned(player, seal.index)
			end
		end
		local enterEmber = Ember.build(map, onVictory)
		returnToHub = Hub.build(map, enterEmber)
		assert(type(returnToHub) == "function", "Hub return contract")
		local ProgressStore = require(parent.Profile.ProgressStore)
		current.progress = ProgressStore.start(Profile, Hub)
		local ObjectivesStore = require(parent.Profile.ObjectivesStore)
		current.objectives = ObjectivesStore.start(Hub)
		Ember.connectReturn(map, returnToHub)
		assert(map:FindFirstChild("Hub"), "Hub did not mount")
		profileConnection = Players.PlayerRemoving:Connect(function(player) Profile.clearSession(player) end)
	end, function()
		if current.objectives then current.objectives.stop() end
		if current.progress then current.progress.stop() end
		if profileConnection then profileConnection:Disconnect() end
		if map then map:Destroy() end
	end)
	if coreOk then
		health:stage("Varkhion", function()
			local anchor = assert(map.Hub:FindFirstChild("VarkhionAnchor"), "Varkhion anchor missing")
			local Varkhion = require(parent.Dragons.Varkhion)
			current.varkhion = Varkhion.mount(map, anchor, function(player, speciesId)
				assert(speciesId == "Varkhion", "Unexpected sanctuary species")
				Hub.completeObjective(player, "santuario")
			end, function(player)
				return Profile.hasSeal(player, "Ember")
			end)
		end, function()
			if current.varkhion then current.varkhion:destroy() end
			local partial = map:FindFirstChild("Varkhion")
			if partial then partial:Destroy() end
		end)
		health:stage("Latunia", function()
			local Latunia = require(parent.Latunia.Codex.Map)
			local Vila = require(parent.Hub.Latunia)
			-- GLM builders layer new scenery over the existing Codex island base.
			-- All five island travel contracts and the arrival objective remain intact.
			assert(type(Vila.partnerBuilders) == "table", "Latunia GLM builders missing")
			current.latunia = Latunia.build(workspace, returnToHub,
				Vila.partnerBuilders, function(player, islandId)
				if current.objectives then
					local first = current.objectives:recordArrival(player, islandId)
					if first then
						local names = {
							Central = "Vila Central", Gelo = "Ilha do Gelo",
							Deserto = "Ilha do Deserto", Selva = "Ilha da Selva",
							Vulcanica = "Ilha Vulcânica",
						}
						Hub.notify(player, "Exploração: " .. (names[islandId] or "Latúnia") .. " descoberta!")
					end
				end
			end)
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
