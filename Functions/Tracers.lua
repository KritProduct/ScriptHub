local Tracers = {}

Tracers.Settings = {
    Color = Color3.fromRGB(255, 45, 45),
    Keybind = nil
}

Tracers.Enabled = false
Tracers.Connection = nil
Tracers.Lines = {}

function Tracers.Start(player)
    local RunService = game:GetService("RunService")
    
    Tracers.Enabled = true
    
    Tracers.Connection = RunService.RenderStepped:Connect(function()
        for _, line in pairs(Tracers.Lines) do
            line:Destroy()
        end
        Tracers.Lines = {}
        
        for _, target in pairs(game.Players:GetPlayers()) do
            if target ~= player and target.Character then
                local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(targetRoot.Position)
                    
                    if onScreen then
                        local line = Instance.new("Frame")
                        line.Size = UDim2.new(0, 2, 0, screenPos.Y)
                        line.Position = UDim2.new(0, screenPos.X - 1, 0, 0)
                        line.BackgroundColor3 = Tracers.Settings.Color
                        line.BorderSizePixel = 0
                        line.ZIndex = 998
                        line.Parent = player:WaitForChild("PlayerGui")
                        table.insert(Tracers.Lines, line)
                    end
                end
            end
        end
    end)
end

function Tracers.Stop()
    Tracers.Enabled = false
    
    if Tracers.Connection then
        Tracers.Connection:Disconnect()
        Tracers.Connection = nil
    end
    
    for _, line in pairs(Tracers.Lines) do
        line:Destroy()
    end
    Tracers.Lines = {}
end

function Tracers.BuildSettings(content)
    local ColorPicker = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/Core/ColorPicker.lua"))()
    local picker = ColorPicker.Create(content, function(color)
        Tracers.Settings.Color = color
    end, Tracers.Settings.Color)
end

return Tracers
