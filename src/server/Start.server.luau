local Hub = require(script.Parent.Hub.Map)
local Ember = require(script.Parent.Ember.Map)

local map = Instance.new("Folder")
map.Name = "MythragonMap"
map.Parent = workspace

local enterEmber = Ember.build(map)
local returnToHub = Hub.build(map, enterEmber)
Ember.connectReturn(map, returnToHub)
