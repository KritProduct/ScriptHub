local ESP = {}

ESP.Settings = {
    Color = Color3.fromRGB(255, 45, 45),
    Keybind = nil
}

ESP.Enabled = false
ESP.Connection = nil

function ESP.Start(player)
    local RunService = game:GetService("RunService")
    
    ESP.Enabled = true
    
    ESP.Connection = RunService.RenderStepped:Connect(function()
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                pcall(function()
                    local h = Instance.new("Highlight")
                    h.Parent = p.Character
                    h.FillColor = ESP.Settings.Color
                    h.FillTransparency = 0.5
                    h.OutlineColor = ESP.Settings.Color
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    task.delay(0.05, function() h:Destroy() end)
                end)
            end
        end
    end)
end

function ESP.Stop()
    ESP.Enabled = false
    
    if ESP.Connection then
        ESP.Connection:Disconnect()
        ESP.Connection = nil
    end
end

return ESP
