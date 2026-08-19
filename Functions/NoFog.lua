local NoFog = {}

NoFog.Enabled = false

function NoFog.Start(player)
    local Lighting = game:GetService("Lighting")
    
    NoFog.Enabled = true
    Lighting.FogEnd = 100000
    Lighting.FogStart = 100000
end

function NoFog.Stop()
    NoFog.Enabled = false
end

return NoFog
