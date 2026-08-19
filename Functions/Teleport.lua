local Teleport = {}

Teleport.Enabled = false

function Teleport.Start(player)
    Teleport.Enabled = true
end

function Teleport.Stop()
    Teleport.Enabled = false
end

return Teleport
