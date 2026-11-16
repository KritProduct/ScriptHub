local NoFog = {}

NoFog.Settings = {
    Keybind = nil
}

NoFog.Enabled = false
NoFog.Original = nil
NoFog.LoopConnection = nil

local RunService = game:GetService("RunService")

local function applyFog()
    local Lighting = game:GetService("Lighting")

    if Lighting.FogStart ~= 100000 then
        Lighting.FogStart = 100000
    end

    if Lighting.FogEnd ~= 100000 then
        Lighting.FogEnd = 100000
    end
end

function NoFog.Start(player)
    if NoFog.Enabled then return end

    local Lighting = game:GetService("Lighting")

    NoFog.Enabled = true
    NoFog.Original = {
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        FogColor = Lighting.FogColor
    }

    applyFog()

    NoFog.LoopConnection = RunService.Heartbeat:Connect(function()
        if NoFog.Enabled then applyFog() end
    end)
end

function NoFog.Stop()
    if not NoFog.Enabled then return end

    NoFog.Enabled = false

    if NoFog.LoopConnection then
        NoFog.LoopConnection:Disconnect()
        NoFog.LoopConnection = nil
    end

    local Lighting = game:GetService("Lighting")

    if NoFog.Original then
        Lighting.FogStart = NoFog.Original.FogStart
        Lighting.FogEnd = NoFog.Original.FogEnd
        Lighting.FogColor = NoFog.Original.FogColor
        NoFog.Original = nil
    end
end

function NoFog.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 40)
    label.BackgroundTransparency = 1
    label.Text = "Removes fog and keeps it removed. Original fog values are restored when disabled"
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
end

return NoFog
