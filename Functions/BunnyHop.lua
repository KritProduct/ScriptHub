local BunnyHop = {}

BunnyHop.Settings = {
    Mode = "Normal",
    Speed = 50,
    Keybind = nil
}

BunnyHop.Enabled = false
BunnyHop.Connection = nil

function BunnyHop.Start(player)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    BunnyHop.Enabled = true
    
    BunnyHop.Connection = RunService.Heartbeat:Connect(function()
        if not BunnyHop.Enabled then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end
        
        local moving = false
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moving = true end
        
        if moving and humanoid:GetState() == Enum.HumanoidStateType.Landed then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            
            if BunnyHop.Settings.Mode == "Speed" then
                local cam = workspace.CurrentCamera
                local dir = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                dir = Vector3.new(dir.X, 0, dir.Z)
                
                if dir.Magnitude > 0 then
                    root.Velocity = Vector3.new(dir.Unit.X * BunnyHop.Settings.Speed, root.Velocity.Y, dir.Unit.Z * BunnyHop.Settings.Speed)
                end
            end
        end
    end)
end

function BunnyHop.Stop()
    BunnyHop.Enabled = false
    if BunnyHop.Connection then
        BunnyHop.Connection:Disconnect()
        BunnyHop.Connection = nil
    end
end

function BunnyHop.BuildSettings(content)
    local modeContainer = Instance.new("Frame")
    modeContainer.Size = UDim2.new(1, 0, 0, 30)
    modeContainer.BackgroundTransparency = 1
    modeContainer.Parent = content
    
    local normalBtn = Instance.new("TextButton")
    normalBtn.Size = UDim2.new(0.45, 0, 0, 30)
    normalBtn.Text = "Normal"
    normalBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    normalBtn.BorderSizePixel = 0
    normalBtn.TextColor3 = Color3.new(1, 1, 1)
    normalBtn.Font = Enum.Font.GothamBlack
    normalBtn.TextSize = 11
    normalBtn.AutoButtonColor = false
    normalBtn.Parent = modeContainer
    
    local normalCorner = Instance.new("UICorner")
    normalCorner.CornerRadius = UDim.new(0, 6)
    normalCorner.Parent = normalBtn
    
    local speedBtn = Instance.new("TextButton")
    speedBtn.Size = UDim2.new(0.45, 0, 0, 30)
    speedBtn.Position = UDim2.new(0.5, 0, 0, 0)
    speedBtn.Text = "Speed"
    speedBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    speedBtn.BorderSizePixel = 0
    speedBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
    speedBtn.Font = Enum.Font.GothamBlack
    speedBtn.TextSize = 11
    speedBtn.AutoButtonColor = false
    speedBtn.Parent = modeContainer
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 6)
    speedCorner.Parent = speedBtn
    
    local speedSliderContainer = Instance.new("Frame")
    speedSliderContainer.Size = UDim2.new(1, 0, 0, 35)
    speedSliderContainer.Position = UDim2.new(0, 0, 0, 35)
    speedSliderContainer.BackgroundTransparency = 1
    speedSliderContainer.Visible = false
    speedSliderContainer.Parent = content
    
    local function updateMode()
        if BunnyHop.Settings.Mode == "Normal" then
            normalBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            normalBtn.TextColor3 = Color3.new(1, 1, 1)
            speedBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            speedBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
            speedSliderContainer.Visible = false
        else
            speedBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            speedBtn.TextColor3 = Color3.new(1, 1, 1)
            normalBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            normalBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
            speedSliderContainer.Visible = true
        end
    end
    
    normalBtn.MouseButton1Click:Connect(function()
        BunnyHop.Settings.Mode = "Normal"
        updateMode()
    end)
    
    speedBtn.MouseButton1Click:Connect(function()
        BunnyHop.Settings.Mode = "Speed"
        updateMode()
    end)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 50, 0, 20)
    label.Position = UDim2.new(1, -50, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(BunnyHop.Settings.Speed)
    label.TextColor3 = Color3.fromRGB(80, 140, 255)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 11
    label.Parent = speedSliderContainer
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -60, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 20)
    track.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    track.BorderSizePixel = 0
    track.Parent = speedSliderContainer
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 0, 6)
    fill.Position = UDim2.new(0, 0, 0, 20)
    fill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    fill.BorderSizePixel = 0
    fill.Parent = speedSliderContainer
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    local function updateVisual(value)
        local percent = (value - 20) / (200 - 20)
        fill.Size = UDim2.new(0, percent * track.AbsoluteSize.X, 0, 6)
        label.Text = tostring(math.floor(value))
    end
    
    updateVisual(BunnyHop.Settings.Speed)
    
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
                local value = 20 + percent * (200 - 20)
                BunnyHop.Settings.Speed = value
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
    
    updateMode()
end

return BunnyHop
