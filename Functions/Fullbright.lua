local Fullbright = {}

Fullbright.Enabled = false

function Fullbright.Start(player)
    local Lighting = game:GetService("Lighting")
    
    Fullbright.Enabled = true
    Lighting.Brightness = 5
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
end

function Fullbright.Stop()
    local Lighting = game:GetService("Lighting")
    
    Fullbright.Enabled = false
    Lighting.Brightness = 2
    Lighting.GlobalShadows = true
end

return Fullbright
