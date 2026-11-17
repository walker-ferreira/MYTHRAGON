-- Fail-closed authorization for developer travel tools.
-- Studio playtests are allowed. Live commands are restricted to the
-- individual creator of the exact MYTHRAGON staging place.
local Access = {}
Access.STAGING_PLACE = 135004978091658

function Access.allowed(isStudio, placeId, creatorType, creatorId, userId)
    if isStudio == true then return true end
    return placeId == Access.STAGING_PLACE
        and creatorType == "User"
        and type(userId) == "number" and userId > 0
        and type(creatorId) == "number" and creatorId > 0
        and creatorId == userId
end

function Access.canUse(player)
    local RunService = game:GetService("RunService")
    return RunService:IsServer() and Access.allowed(
        RunService:IsStudio(),
        game.PlaceId,
        game.CreatorType.Name,
        game.CreatorId,
        player.UserId
    )
end

return Access
