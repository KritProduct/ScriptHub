local ModuleButton = {}
local TweenService = game:GetService("TweenService")

function ModuleButton.Create(parent, name, tab, toggleCallback, settingsBuilder)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 50)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 50)
    button.Text = name .. ": OFF"
    button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBlack
    button.TextSize = 14
    button.AutoButtonColor = false
    button.Parent = wrapper
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = UDim2.new(0, 15, 0.5, -6)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 45, 45)
    indicator.BorderSizePixel = 0
    indicator.Parent = button
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 6)
    indicatorCorner.Parent = indicator
    
    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Size = UDim2.new(0, 35, 0, 35)
    settingsBtn.Position = UDim2.new(1, -42, 0.5, -17)
    settingsBtn.Text = "?"
    settingsBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    settingsBtn.BorderSizePixel = 0
    settingsBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
    settingsBtn.Font = Enum.Font.GothamBlack
    settingsBtn.TextSize = 14
    settingsBtn.AutoButtonColor = false
    settingsBtn.Parent = button
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 8)
    settingsCorner.Parent = settingsBtn
    
    local enabled = false
    
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            indicator.BackgroundColor3 = Color3.fromRGB(45, 255, 110)
            button.Text = name .. ": ON"
            button.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
        else
            indicator.BackgroundColor3 = Color3.fromRGB(255, 45, 45)
            button.Text = name .. ": OFF"
            button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        end
        if toggleCallback then toggleCallback(enabled) end
    end)
    
    settingsBtn.MouseButton1Click:Connect(function()
        if settingsBuilder then
            local settingsWindow = Instance.new("Frame")
            settingsWindow.Size = UDim2.new(0, 300, 0, 200)
            settingsWindow.Position = UDim2.new(0.6, -150, 0.5, -100)
            settingsWindow.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
            settingsWindow.BorderSizePixel = 0
            settingsWindow.ZIndex = 1000
            settingsWindow.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            
            local windowCorner = Instance.new("UICorner")
            windowCorner.CornerRadius = UDim.new(0, 12)
            windowCorner.Parent = settingsWindow
            
            local windowStroke = Instance.new("UIStroke")
            windowStroke.Color = Color3.fromRGB(80, 140, 255)
            windowStroke.Thickness = 2
            windowStroke.Parent = settingsWindow
            
            local titleBar = Instance.new("Frame")
            titleBar.Size = UDim2.new(1, 0, 0, 35)
            titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            titleBar.BorderSizePixel = 0
            titleBar.Parent = settingsWindow
            
            local titleCorner = Instance.new("UICorner")
            titleCorner.CornerRadius = UDim.new(0, 12)
            titleCorner.Parent = titleBar
            
            local titleText = Instance.new("TextLabel")
            titleText.Size = UDim2.new(1, -40, 1, 0)
            titleText.Position = UDim2.new(0, 10, 0, 0)
            titleText.BackgroundTransparency = 1
            titleText.Text = name .. " Settings"
            titleText.TextColor3 = Color3.fromRGB(80, 140, 255)
            titleText.Font = Enum.Font.GothamBlack
            titleText.TextSize = 13
            titleText.TextXAlignment = Enum.TextXAlignment.Left
            titleText.Parent = titleBar
            
            local closeBtn = Instance.new("TextButton")
            closeBtn.Size = UDim2.new(0, 25, 0, 25)
            closeBtn.Position = UDim2.new(1, -30, 0, 5)
            closeBtn.Text = "X"
            closeBtn.BackgroundColor3 = Color3.fromRGB(255, 45, 45)
            closeBtn.TextColor3 = Color3.new(1, 1, 1)
            closeBtn.Font = Enum.Font.GothamBlack
            closeBtn.TextSize = 12
            closeBtn.AutoButtonColor = false
            closeBtn.Parent = titleBar
            
            local closeCorner = Instance.new("UICorner")
            closeCorner.CornerRadius = UDim.new(0, 12)
            closeCorner.Parent = closeBtn
            
            closeBtn.MouseButton1Click:Connect(function()
                settingsWindow:Destroy()
            end)
            
            local content = Instance.new("Frame")
            content.Size = UDim2.new(1, -20, 1, -45)
            content.Position = UDim2.new(0, 10, 0, 40)
            content.BackgroundTransparency = 1
            content.Parent = settingsWindow
            
            local listLayout = Instance.new("UIListLayout")
            listLayout.Padding = UDim.new(0, 5)
            listLayout.Parent = content
            
            settingsBuilder(content)
        end
    end)
    
    return {
        Wrapper = wrapper,
        Button = button,
        Tab = tab,
        SetVisible = function(visible) wrapper.Visible = visible end
    }
end

return ModuleButton
