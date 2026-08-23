local TouchFly = {}

TouchFly.Settings = {
    Power = 100,
    Keybind = nil
}

TouchFly.Enabled = false
TouchFly.Connection = nil

function TouchFly.Start(player)
    local RunService = game:GetService("RunService")
    
    TouchFly.Enabled = true
    
    TouchFly.Connection = RunService.Heartbeat:Connect(function()
        if not TouchFly.Enabled then return end
        
        local character = player.Character
        if not character then return end
        
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        for _, target in pairs(game.Players:GetPlayers()) do
            if target ~= player and target.Character then
                local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                local targetHum = target.Character:FindFirstChild("Humanoid")
                
                if targetRoot and targetHum and targetHum.Health > 0 then
                    local distance = (targetRoot.Position - root.Position).Magnitude
                    
                    if distance < 10 then
                        local direction = (targetRoot.Position - root.Position).Unit
                        targetRoot.Velocity = direction * TouchFly.Settings.Power + Vector3.new(0, 50, 0)
                    end
                end
            end
        end
    end)
end

function TouchFly.Stop()
    TouchFly.Enabled = false
    
    if TouchFly.Connection then
        TouchFly.Connection:Disconnect()
        TouchFly.Connection = nil
    end
end

function TouchFly.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Power: " .. math.floor(TouchFly.Settings.Power)
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 35)
    slider.BackgroundTransparency = 1
    slider.Parent = content
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0, 50, 0, 20)
    sliderLabel.Position = UDim2.new(1, -50, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = tostring(math.floor(TouchFly.Settings.Power))
    sliderLabel.TextColor3 = Color3.fromRGB(80, 140, 255)
    sliderLabel.Font = Enum.Font.GothamBlack
    sliderLabel.TextSize = 11
    sliderLabel.Parent = slider
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -60, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 20)
    track.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    track.BorderSizePixel = 0
    track.Parent = slider
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 0, 6)
    fill.Position = UDim2.new(0, 0, 0, 20)
    fill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    local function updateVisual(value)
        local percent = (value - 50) / (500 - 50)
        fill.Size = UDim2.new(0, percent * track.AbsoluteSize.X, 0, 6)
        sliderLabel.Text = tostring(math.floor(value))
        label.Text = "Power: " .. math.floor(value)
    end
    
    updateVisual(TouchFly.Settings.Power)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local RunService = game:GetService("RunService")
            local UserInputService = game:GetService("UserInputService")
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local mouseX = UserInputService:GetMouseLocation().X
                local startX = track.AbsolutePosition.X
                local endX = track.AbsolutePosition.X + track.AbsoluteSize.X
                local percent = math.clamp((mouseX - startX) / (endX - startX), 0, 1)
                local value = 50 + percent * (500 - 50)
                TouchFly.Settings.Power = value
                updateVisual(value)
            end)
            local endConnection
            endConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                    endConnection:Disconnect()
                end
            end)
        end
    end)
end

return TouchFly
