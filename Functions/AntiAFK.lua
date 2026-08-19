local AntiAFK = {}

AntiAFK.Settings = {
    Interval = 5,
    Action = "Jump",
    Keybind = nil
}

AntiAFK.Enabled = false
AntiAFK.Connection = nil
AntiAFK.LastAction = 0

function AntiAFK.Start(player)
    local RunService = game:GetService("RunService")
    
    AntiAFK.Enabled = true
    
    AntiAFK.Connection = RunService.Heartbeat:Connect(function()
        if not AntiAFK.Enabled then return end
        
        if os.clock() - AntiAFK.LastAction >= AntiAFK.Settings.Interval then
            AntiAFK.LastAction = os.clock()
            
            pcall(function()
                local character = player.Character
                if not character then return end
                
                local humanoid = character:FindFirstChild("Humanoid")
                local cam = workspace.CurrentCamera
                
                if AntiAFK.Settings.Action == "Jump" then
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                elseif AntiAFK.Settings.Action == "Turn Camera" then
                    if cam then
                        cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(45), 0)
                    end
                elseif AntiAFK.Settings.Action == "Click" then
                    pcall(function()
                        mouse1press()
                        task.wait(0.01)
                        mouse1release()
                    end)
                end
            end)
        end
    end)
end

function AntiAFK.Stop()
    AntiAFK.Enabled = false
    
    if AntiAFK.Connection then
        AntiAFK.Connection:Disconnect()
        AntiAFK.Connection = nil
    end
end

function AntiAFK.BuildSettings(content)
    local intervalSlider = Instance.new("Frame")
    intervalSlider.Size = UDim2.new(1, 0, 0, 35)
    intervalSlider.BackgroundTransparency = 1
    intervalSlider.Parent = content
    
    local intervalLabel = Instance.new("TextLabel")
    intervalLabel.Size = UDim2.new(0, 50, 0, 20)
    intervalLabel.Position = UDim2.new(1, -50, 0, 0)
    intervalLabel.BackgroundTransparency = 1
    intervalLabel.Text = tostring(AntiAFK.Settings.Interval) .. "s"
    intervalLabel.TextColor3 = Color3.fromRGB(80, 140, 255)
    intervalLabel.Font = Enum.Font.GothamBlack
    intervalLabel.TextSize = 11
    intervalLabel.Parent = intervalSlider
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -60, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 20)
    track.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    track.BorderSizePixel = 0
    track.Parent = intervalSlider
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 0, 6)
    fill.Position = UDim2.new(0, 0, 0, 20)
    fill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    fill.BorderSizePixel = 0
    fill.Parent = intervalSlider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    local function updateVisual(value)
        local percent = (value - 1) / (15 - 1)
        fill.Size = UDim2.new(0, percent * track.AbsoluteSize.X, 0, 6)
        intervalLabel.Text = tostring(math.floor(value)) .. "s"
    end
    
    updateVisual(AntiAFK.Settings.Interval)
    
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
                local value = 1 + percent * (15 - 1)
                AntiAFK.Settings.Interval = value
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
    
    local actions = {"Jump", "Turn Camera", "Click"}
    for i, action in ipairs(actions) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 0, 30)
        btn.Position = UDim2.new(0, (i - 1) * 105, 0, 0)
        btn.Text = action
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        btn.BorderSizePixel = 0
        btn.TextColor3 = Color3.fromRGB(160, 160, 160)
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 10
        btn.AutoButtonColor = false
        btn.Parent = content
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            AntiAFK.Settings.Action = action
            for _, child in pairs(content:GetChildren()) do
                if child:IsA("TextButton") and child.Text ~= "" then
                    child.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                    child.TextColor3 = Color3.fromRGB(160, 160, 160)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            btn.TextColor3 = Color3.new(1, 1, 1)
        end)
    end
end

return AntiAFK
