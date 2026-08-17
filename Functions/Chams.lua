local Chams = {}

Chams.Settings = {
    Color = Color3.fromRGB(80, 140, 255),
    Keybind = nil
}

Chams.Enabled = false
Chams.Connection = nil
Chams.Highlights = {}

function Chams.Start(player)
    local RunService = game:GetService("RunService")
    
    Chams.Enabled = true
    
    Chams.Connection = RunService.RenderStepped:Connect(function()
        for _, h in pairs(Chams.Highlights) do
            h:Destroy()
        end
        Chams.Highlights = {}
        
        for _, target in pairs(game.Players:GetPlayers()) do
            if target ~= player and target.Character then
                pcall(function()
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = target.Character
                    highlight.FillColor = Chams.Settings.Color
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Chams.Settings.Color
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    table.insert(Chams.Highlights, highlight)
                end)
            end
        end
    end)
end

function Chams.Stop()
    Chams.Enabled = false
    
    if Chams.Connection then
        Chams.Connection:Disconnect()
        Chams.Connection = nil
    end
    
    for _, h in pairs(Chams.Highlights) do
        h:Destroy()
    end
    Chams.Highlights = {}
end

function Chams.BuildSettings(content)
    local ColorPicker = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/Core/ColorPicker.lua"))()
    local picker = ColorPicker.Create(content, function(color)
        Chams.Settings.Color = color
    end, Chams.Settings.Color)
end

return Chams
