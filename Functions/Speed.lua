local Speed = {}

Speed.Settings = {
    Strength = 50,
    Keybind = nil
}

Speed.Enabled = false
Speed.Instance = nil

function Speed.Start(player)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    local character = player.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    Speed.Enabled = true
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(40000, 0, 40000)
    bodyVelocity.Parent = root
    
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
            bodyVelocity.Velocity = dir.Unit * Speed.Settings.Strength
        else
            bodyVelocity.Velocity = Vector3.new()
        end
    end)
    
    Speed.Instance = {
        Connection = connection,
        BodyVelocity = bodyVelocity
    }
end

function Speed.Stop()
    Speed.Enabled = false
    
    if Speed.Instance then
        Speed.Instance.Connection:Disconnect()
        Speed.Instance.BodyVelocity:Destroy()
        Speed.Instance = nil
    end
end

function Speed.BuildSettings(content)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 35)
    slider.BackgroundTransparency = 1
    slider.Parent = content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 50, 0, 20)
    label.Position = UDim2.new(1, -50, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(Speed.Settings.Strength)
    label.TextColor3 = Color3.fromRGB(80, 140, 255)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 11
    label.Parent = slider
    
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
        local percent = (value - 5) / (500 - 5)
        fill.Size = UDim2.new(0, percent * track.AbsoluteSize.X, 0, 6)
        label.Text = tostring(math.floor(value))
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
                local value = 5 + percent * (500 - 5)
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
end

return Speed
