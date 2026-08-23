local ESP = {}

ESP.Settings = {
    Color = Color3.fromRGB(255, 45, 45),
    Mode = "Color",
    TeamColor = Color3.fromRGB(45, 255, 110),
    EnemyColor = Color3.fromRGB(255, 45, 45),
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
                    
                    if ESP.Settings.Mode == "Team" then
                        if player.Team and p.Team then
                            if player.Team == p.Team then
                                h.FillColor = ESP.Settings.TeamColor
                                h.OutlineColor = ESP.Settings.TeamColor
                            else
                                h.FillColor = ESP.Settings.EnemyColor
                                h.OutlineColor = ESP.Settings.EnemyColor
                            end
                        else
                            h.FillColor = ESP.Settings.EnemyColor
                            h.OutlineColor = ESP.Settings.EnemyColor
                        end
                    else
                        h.FillColor = ESP.Settings.Color
                        h.OutlineColor = ESP.Settings.Color
                    end
                    
                    h.FillTransparency = 0.5
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
    local ColorPicker = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/Core/ColorPicker.lua"))()
    
    local modeContainer = Instance.new("Frame")
    modeContainer.Size = UDim2.new(1, 0, 0, 30)
    modeContainer.BackgroundTransparency = 1
    modeContainer.Parent = content
    
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(0.45, 0, 0, 30)
    colorBtn.Position = UDim2.new(0, 0, 0, 0)
    colorBtn.Text = "Color"
    colorBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    colorBtn.BorderSizePixel = 0
    colorBtn.TextColor3 = Color3.new(1, 1, 1)
    colorBtn.Font = Enum.Font.GothamBlack
    colorBtn.TextSize = 12
    colorBtn.AutoButtonColor = false
    colorBtn.Parent = modeContainer
    
    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 6)
    colorCorner.Parent = colorBtn
    
    local teamBtn = Instance.new("TextButton")
    teamBtn.Size = UDim2.new(0.45, 0, 0, 30)
    teamBtn.Position = UDim2.new(0.5, 0, 0, 0)
    teamBtn.Text = "Team"
    teamBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    teamBtn.BorderSizePixel = 0
    teamBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
    teamBtn.Font = Enum.Font.GothamBlack
    teamBtn.TextSize = 12
    teamBtn.AutoButtonColor = false
    teamBtn.Parent = modeContainer
    
    local teamCorner = Instance.new("UICorner")
    teamCorner.CornerRadius = UDim.new(0, 6)
    teamCorner.Parent = teamBtn
    
    local colorPickerContainer = Instance.new("Frame")
    colorPickerContainer.Size = UDim2.new(1, 0, 0, 120)
    colorPickerContainer.Position = UDim2.new(0, 0, 0, 40)
    colorPickerContainer.BackgroundTransparency = 1
    colorPickerContainer.Parent = content
    
    local teamColorsContainer = Instance.new("Frame")
    teamColorsContainer.Size = UDim2.new(1, 0, 0, 120)
    teamColorsContainer.Position = UDim2.new(0, 0, 0, 40)
    teamColorsContainer.BackgroundTransparency = 1
    teamColorsContainer.Visible = false
    teamColorsContainer.Parent = content
    
    local function updateMode()
        if ESP.Settings.Mode == "Color" then
            colorBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            colorBtn.TextColor3 = Color3.new(1, 1, 1)
            teamBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            teamBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
            colorPickerContainer.Visible = true
            teamColorsContainer.Visible = false
        else
            teamBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            teamBtn.TextColor3 = Color3.new(1, 1, 1)
            colorBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            colorBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
            colorPickerContainer.Visible = false
            teamColorsContainer.Visible = true
        end
    end
    
    colorBtn.MouseButton1Click:Connect(function()
        ESP.Settings.Mode = "Color"
        updateMode()
    end)
    
    teamBtn.MouseButton1Click:Connect(function()
        ESP.Settings.Mode = "Team"
        updateMode()
    end)
    
    local picker = ColorPicker.Create(colorPickerContainer, function(color)
        ESP.Settings.Color = color
    end, ESP.Settings.Color)
    
    local teamLabel = Instance.new("TextLabel")
    teamLabel.Size = UDim2.new(1, 0, 0, 20)
    teamLabel.BackgroundTransparency = 1
    teamLabel.Text = "Team Color:"
    teamLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    teamLabel.Font = Enum.Font.GothamBold
    teamLabel.TextSize = 11
    teamLabel.TextXAlignment = Enum.TextXAlignment.Left
    teamLabel.Parent = teamColorsContainer
    
    local teamPicker = ColorPicker.Create(teamColorsContainer, function(color)
        ESP.Settings.TeamColor = color
    end, ESP.Settings.TeamColor)
    teamPicker.Container.Position = UDim2.new(0, 0, 0, 25)
    
    local enemyLabel = Instance.new("TextLabel")
    enemyLabel.Size = UDim2.new(1, 0, 0, 20)
    enemyLabel.Position = UDim2.new(0, 0, 0, 145)
    enemyLabel.BackgroundTransparency = 1
    enemyLabel.Text = "Enemy Color:"
    enemyLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    enemyLabel.Font = Enum.Font.GothamBold
    enemyLabel.TextSize = 11
    enemyLabel.TextXAlignment = Enum.TextXAlignment.Left
    enemyLabel.Parent = teamColorsContainer
    
    local enemyPicker = ColorPicker.Create(teamColorsContainer, function(color)
        ESP.Settings.EnemyColor = color
    end, ESP.Settings.EnemyColor)
    enemyPicker.Container.Position = UDim2.new(0, 0, 0, 170)
    
    updateMode()
end

return ESP
