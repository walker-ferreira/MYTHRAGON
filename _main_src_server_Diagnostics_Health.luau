local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuildInfo = require(script.Parent.BuildInfo)
local Health = {}
Health.__index = Health

function Health.new()
	local folder = Instance.new("Folder")
	folder.Name = "MythragonHealth"
	folder:SetAttribute("GitSha", BuildInfo.gitSha)
	folder:SetAttribute("BuildRunId", BuildInfo.buildRunId)
	folder:SetAttribute("PlaceVersion", game.PlaceVersion)
	folder:SetAttribute("Experimental", true)
	folder:SetAttribute("State", "INITIALIZING")
	folder.Parent = ReplicatedStorage
	local self = setmetatable({ folder = folder, failures = {}, components = {} }, Health)
	self:log("bootstrap", "INITIALIZING")
	return self
end

function Health:log(component, state, message)
	local record = {
		project = "MYTHRAGON", gitSha = BuildInfo.gitSha, buildRunId = BuildInfo.buildRunId,
		universeId = game.GameId, placeId = game.PlaceId, placeVersion = game.PlaceVersion,
		jobId = game.JobId, component = component, state = state, message = message,
	}
	local encoded = HttpService:JSONEncode(record)
	if state == "FAILED" or state == "BLOCKED" then warn(encoded) else print(encoded) end
end

function Health:stage(name, callback, cleanup)
	assert(not self.components[name], "Duplicate bootstrap stage: " .. name)
	self.components[name] = "INITIALIZING"
	self.folder:SetAttribute(name, "INITIALIZING")
	local ok, result = xpcall(callback, debug.traceback)
	local state = if ok then "READY" else "FAILED"
	self.components[name] = state
	self.folder:SetAttribute(name, state)
	if not ok then
		self.failures[name] = tostring(result)
		if cleanup then
			local cleanOk, cleanError = pcall(cleanup)
			if not cleanOk then self:log(name .. ".cleanup", "FAILED", tostring(cleanError)) end
		end
	end
	self:log(name, state, if ok then nil else tostring(result))
	return ok, result
end

function Health:block(name, reason)
	self.components[name] = "BLOCKED"
	self.failures[name] = reason
	self.folder:SetAttribute(name, "BLOCKED")
	self:log(name, "BLOCKED", reason)
end

function Health:finish()
	local healthy = next(self.failures) == nil
	self.folder:SetAttribute("State", if healthy then "READY" else "FAILED")
	self:log("bootstrap", if healthy then "READY" else "FAILED")
	return healthy
end

return Health