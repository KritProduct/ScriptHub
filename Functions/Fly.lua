local Fly = {}

Fly.Settings = {
    Speed = 50,
    Keybind = nil
}

Fly.Enabled = false
Fly.Instance = nil

function Fly.Start(player)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    local character = player.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    Fly.Enabled = true
    hum.PlatformStand = true
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9000
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    bodyGyro.Parent = root
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Parent = root
    
    local connection = RunService.Heartbeat:Connect(function()
        if not Fly.Enabled then return end
        
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        
        local dir = Vector3.new()
        local cam = workspace.CurrentCamera
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
        
        if dir.Magnitude > 0 then
            bodyVelocity.Velocity = dir.Unit * Fly.Settings.Speed
        else
            bodyVelocity.Velocity = Vector3.new()
        end
    end)
    
    Fly.Instance = {
        Connection = connection,
        BodyGyro = bodyGyro,
        BodyVelocity = bodyVelocity,
        Humanoid = hum
    }
end

function Fly.Stop()
    Fly.Enabled = false
    
    if Fly.Instance then
        Fly.Instance.Connection:Disconnect()
        Fly.Instance.BodyGyro:Destroy()
        Fly.Instance.BodyVelocity:Destroy()
        Fly.Instance.Humanoid.PlatformStand = false
        Fly.Instance = nil
    end
end

function Fly.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Speed: " .. math.floor(Fly.Settings.Speed)
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 30)
    input.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    input.BorderSizePixel = 0
    input.Text = tostring(math.floor(Fly.Settings.Speed))
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 12
    input.Parent = content
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input
    
    input.FocusLost:Connect(function()
        local value = tonumber(input.Text)
        if value then
            Fly.Settings.Speed = math.clamp(value, 10, 1000)
            input.Text = tostring(math.floor(Fly.Settings.Speed))
            label.Text = "Speed: " .. math.floor(Fly.Settings.Speed)
        end
    end)
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 35)
    slider.BackgroundTransparency = 1
    slider.Parent = content
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0, 50, 0, 20)
    sliderLabel.Position = UDim2.new(1, -50, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = tostring(math.floor(Fly.Settings.Speed))
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
        local percent = (value - 10) / (1000 - 10)
        fill.Size = UDim2.new(0, percent * track.AbsoluteSize.X, 0, 6)
        sliderLabel.Text = tostring(math.floor(value))
    end
    
    updateVisual(Fly.Settings.Speed)
    
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
                local value = 10 + percent * (1000 - 10)
                Fly.Settings.Speed = value
                label.Text = "Speed: " .. math.floor(value)
                input.Text = tostring(math.floor(value))
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

return Fly
