local AutoClicker = {}

AutoClicker.Settings = {
    Button = "Left",
    Delay = 1,
    Keybind = nil
}

AutoClicker.Enabled = false
AutoClicker.Connection = nil
AutoClicker.LastClick = 0

function AutoClicker.Start(player)
    local RunService = game:GetService("RunService")
    
    AutoClicker.Enabled = true
    
    AutoClicker.Connection = RunService.Heartbeat:Connect(function()
        if not AutoClicker.Enabled then return end
        
        if os.clock() - AutoClicker.LastClick >= AutoClicker.Settings.Delay then
            AutoClicker.LastClick = os.clock()
            
            pcall(function()
                if AutoClicker.Settings.Button == "Left" then
                    mouse1press()
                    task.wait(0.01)
                    mouse1release()
                else
                    mouse2press()
                    task.wait(0.01)
                    mouse2release()
                end
            end)
        end
    end)
end

function AutoClicker.Stop()
    AutoClicker.Enabled = false
    
    if AutoClicker.Connection then
        AutoClicker.Connection:Disconnect()
        AutoClicker.Connection = nil
    end
end

function AutoClicker.BuildSettings(content)
    local delaySlider = Instance.new("Frame")
    delaySlider.Size = UDim2.new(1, 0, 0, 35)
    delaySlider.BackgroundTransparency = 1
    delaySlider.Parent = content
    
    local delayLabel = Instance.new("TextLabel")
    delayLabel.Size = UDim2.new(0, 50, 0, 20)
    delayLabel.Position = UDim2.new(1, -50, 0, 0)
    delayLabel.BackgroundTransparency = 1
    delayLabel.Text = tostring(AutoClicker.Settings.Delay) .. "s"
    delayLabel.TextColor3 = Color3.fromRGB(80, 140, 255)
    delayLabel.Font = Enum.Font.GothamBlack
    delayLabel.TextSize = 11
    delayLabel.Parent = delaySlider
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -60, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 20)
    track.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    track.BorderSizePixel = 0
    track.Parent = delaySlider
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 0, 6)
    fill.Position = UDim2.new(0, 0, 0, 20)
    fill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    fill.BorderSizePixel = 0
    fill.Parent = delaySlider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    local function updateVisual(value)
        local percent = (value - 0.1) / (10 - 0.1)
        fill.Size = UDim2.new(0, percent * track.AbsoluteSize.X, 0, 6)
        delayLabel.Text = string.format("%.1f", value) .. "s"
    end
    
    updateVisual(AutoClicker.Settings.Delay)
    
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
                local value = 0.1 + percent * (10 - 0.1)
                AutoClicker.Settings.Delay = value
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
    
    local buttonLabel = Instance.new("TextLabel")
    buttonLabel.Size = UDim2.new(1, 0, 0, 20)
    buttonLabel.BackgroundTransparency = 1
    buttonLabel.Text = "Button: " .. AutoClicker.Settings.Button
    buttonLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    buttonLabel.Font = Enum.Font.GothamBold
    buttonLabel.TextSize = 11
    buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
    buttonLabel.Parent = content
    
    local leftBtn = Instance.new("TextButton")
    leftBtn.Size = UDim2.new(0, 130, 0, 30)
    leftBtn.Position = UDim2.new(0, 0, 0, 0)
    leftBtn.Text = "Left"
    leftBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    leftBtn.BorderSizePixel = 0
    leftBtn.TextColor3 = Color3.new(1, 1, 1)
    leftBtn.Font = Enum.Font.GothamBlack
    leftBtn.TextSize = 11
    leftBtn.AutoButtonColor = false
    leftBtn.Parent = content
    
    local leftCorner = Instance.new("UICorner")
    leftCorner.CornerRadius = UDim.new(0, 6)
    leftCorner.Parent = leftBtn
    
    local rightBtn = Instance.new("TextButton")
    rightBtn.Size = UDim2.new(0, 130, 0, 30)
    rightBtn.Position = UDim2.new(0, 140, 0, 0)
    rightBtn.Text = "Right"
    rightBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    rightBtn.BorderSizePixel = 0
    rightBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
    rightBtn.Font = Enum.Font.GothamBlack
    rightBtn.TextSize = 11
    rightBtn.AutoButtonColor = false
    rightBtn.Parent = content
    
    local rightCorner = Instance.new("UICorner")
    rightCorner.CornerRadius = UDim.new(0, 6)
    rightCorner.Parent = rightBtn
    
    local function updateButtons()
        if AutoClicker.Settings.Button == "Left" then
            leftBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            leftBtn.TextColor3 = Color3.new(1, 1, 1)
            rightBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            rightBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
        else
            rightBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            rightBtn.TextColor3 = Color3.new(1, 1, 1)
            leftBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            leftBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
        end
        buttonLabel.Text = "Button: " .. AutoClicker.Settings.Button
    end
    
    leftBtn.MouseButton1Click:Connect(function()
        AutoClicker.Settings.Button = "Left"
        updateButtons()
    end)
    
    rightBtn.MouseButton1Click:Connect(function()
        AutoClicker.Settings.Button = "Right"
        updateButtons()
    end)
    
    updateButtons()
end

return AutoClicker
