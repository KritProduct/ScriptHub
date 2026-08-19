local Rejoin = {}

Rejoin.Enabled = false

function Rejoin.Start(player)
    Rejoin.Enabled = true
    
    local TeleportService = game:GetService("TeleportService")
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end

function Rejoin.Stop()
    Rejoin.Enabled = false
end

return Rejoin
