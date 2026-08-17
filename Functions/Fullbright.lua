local Fullbright = {}

Fullbright.Settings = {
    Keybind = nil
}

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
    Lighting.ClockTime = 14
    Lighting.GlobalShadows = true
end

function Fullbright.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Makes everything bright"
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
end

return Fullbright
