local NoFog = {}

NoFog.Settings = {
    Keybind = nil
}

NoFog.Enabled = false

function NoFog.Start(player)
    local Lighting = game:GetService("Lighting")
    
    NoFog.Enabled = true
    Lighting.FogEnd = 100000
    Lighting.FogStart = 100000
end

function NoFog.Stop()
    local Lighting = game:GetService("Lighting")
    
    NoFog.Enabled = false
    Lighting.FogEnd = 100000
    Lighting.FogStart = 100000
end

function NoFog.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Removes fog"
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
end

return NoFog
