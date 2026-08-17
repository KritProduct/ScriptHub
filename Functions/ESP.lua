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

function ESP.BuildSettings(content)
    local colors = {
        {name = "Red", color = Color3.fromRGB(255, 45, 45)},
        {name = "Green", color = Color3.fromRGB(45, 255, 110)},
        {name = "Blue", color = Color3.fromRGB(45, 120, 255)},
        {name = "Yellow", color = Color3.fromRGB(255, 255, 45)}
    }
    
    for i, c in ipairs(colors) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 70, 0, 30)
        btn.Position = UDim2.new(0, (i - 1) * 75, 0, 0)
        btn.Text = c.name
        btn.BackgroundColor3 = c.color
        btn.TextColor3 = Color3.new(0, 0, 0)
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 10
        btn.AutoButtonColor = false
        btn.Parent = content
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            ESP.Settings.Color = c.color
        end)
    end
end

return ESP
