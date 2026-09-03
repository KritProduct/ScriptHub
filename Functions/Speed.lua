local Speed = {}

Speed.Settings = {
    Strength = 50,
    AntiCheatBypass = false,
    Keybind = nil
}

Speed.Enabled = false
Speed.Instance = nil
Speed.OriginalHumanoid = nil
Speed.CameraConnection = nil

function Speed.Start(player)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    local character = player.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not root or not humanoid then return end
    
    Speed.Enabled = true
    
    if Speed.Settings.AntiCheatBypass then
        Speed.OriginalHumanoid = humanoid
        humanoid.Parent = nil
        
        task.spawn(function()
            while Speed.Enabled do
                pcall(function()
                    workspace.CurrentCamera.CameraSubject = root
                    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                end)
                task.wait(0.05)
            end
        end)
    end
    
    local connection = RunService.Heartbeat:Connect(function()
        if not Speed.Enabled then return end
        
        local dir = Vector3.new()
        local cam = workspace.CurrentCamera
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        dir = Vector3.new(dir.X, 0, dir.Z)
        
        if dir.Magnitude > 0 then
            dir = dir.Unit
            local moveDistance = Speed.Settings.Strength * 0.05
            root.CFrame = root.CFrame + (dir * moveDistance)
        end
    end)
    
    Speed.Instance = {
        Connection = connection
    }
end

function Speed.Stop(player)
    Speed.Enabled = false
    
    if Speed.Instance then
        Speed.Instance.Connection:Disconnect()
        Speed.Instance = nil
    end
    
    if Speed.Settings.AntiCheatBypass and Speed.OriginalHumanoid then
        Speed.OriginalHumanoid.Parent = player.Character
        Speed.OriginalHumanoid = nil
        pcall(function()
            workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChild("Humanoid")
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end)
    end
end

function Speed.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Speed: " .. math.floor(Speed.Settings.Strength)
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
    sliderLabel.Text = tostring(math.floor(Speed.Settings.Strength))
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
        local percent = (value - 5) / (1000 - 5)
        fill.Size = UDim2.new(0, percent * track.AbsoluteSize.X, 0, 6)
        sliderLabel.Text = tostring(math.floor(value))
        label.Text = "Speed: " .. math.floor(value)
    end
    
    updateVisual(Speed.Settings.Strength)
    
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
                local value = 5 + percent * (1000 - 5)
                Speed.Settings.Strength = value
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
    
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Size = UDim2.new(1, 0, 0, 30)
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Parent = content
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(1, -50, 1, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = "AntiCheat Bypass"
    toggleLabel.TextColor3 = Color3.new(1, 1, 1)
    toggleLabel.Font = Enum.Font.GothamBold
    toggleLabel.TextSize = 11
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleContainer
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 22)
    toggle.Position = UDim2.new(1, -40, 0.5, -11)
    toggle.Text = ""
    toggle.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Parent = toggleContainer
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 11)
    toggleCorner.Parent = toggle
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = UDim2.new(0, 3, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    dot.BorderSizePixel = 0
    dot.Parent = toggle
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0, 8)
    dotCorner.Parent = dot
    
    local enabled = Speed.Settings.AntiCheatBypass
    
    local function updateToggle()
        if enabled then
            toggle.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            dot.Position = UDim2.new(1, -19, 0.5, -8)
            dot.BackgroundColor3 = Color3.new(1, 1, 1)
        else
            toggle.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            dot.Position = UDim2.new(0, 3, 0.5, -8)
            dot.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
        end
    end
    
    updateToggle()
    
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        Speed.Settings.AntiCheatBypass = enabled
        updateToggle()
    end)
end

return Speed
