local ESP = {}

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
                    h.FillColor = Color3.fromRGB(255, 45, 45)
                    h.FillTransparency = 0.5
                    h.OutlineColor = Color3.fromRGB(255, 45, 45)
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

function ESP.Toggle(player)
    if ESP.Enabled then
        ESP.Stop()
    else
        ESP.Start(player)
    end
end

return ESP
