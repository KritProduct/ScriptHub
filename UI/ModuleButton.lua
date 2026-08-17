local ModuleButton = {}
local TweenService = game:GetService("TweenService")

function ModuleButton.Create(parent, name, tab, toggleCallback, settingsBuilder)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 55)
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
    button.ZIndex = 10
    button.Parent = wrapper
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = UDim2.new(0, 15, 0.5, -6)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 45, 45)
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 11
    indicator.Parent = button
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 6)
    indicatorCorner.Parent = indicator
    
    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Size = UDim2.new(0, 35, 0, 35)
    settingsBtn.Position = UDim2.new(1, -42, 0.5, -17)
    settingsBtn.Text = "+"
    settingsBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    settingsBtn.BorderSizePixel = 0
    settingsBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
    settingsBtn.Font = Enum.Font.GothamBlack
    settingsBtn.TextSize = 18
    settingsBtn.AutoButtonColor = false
    settingsBtn.ZIndex = 12
    settingsBtn.Parent = button
    
    local settingsCorner = Instance.new("UICorner")
    settingsCorner.CornerRadius = UDim.new(0, 8)
    settingsCorner.Parent = settingsBtn
    
    local settingsPanel = Instance.new("Frame")
    settingsPanel.Size = UDim2.new(1, 0, 0, 0)
    settingsPanel.Position = UDim2.new(0, 0, 0, 52)
    settingsPanel.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    settingsPanel.BorderSizePixel = 0
    settingsPanel.ClipsDescendants = true
    settingsPanel.ZIndex = 9
    settingsPanel.Parent = wrapper
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 10)
    panelCorner.Parent = settingsPanel
    
    local settingsContent = Instance.new("Frame")
    settingsContent.Size = UDim2.new(1, -20, 1, -20)
    settingsContent.Position = UDim2.new(0, 10, 0, 10)
    settingsContent.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    settingsContent.BorderSizePixel = 0
    settingsContent.ZIndex = 9
    settingsContent.Parent = settingsPanel
    
    local settingsList = Instance.new("UIListLayout")
    settingsList.Padding = UDim.new(0, 5)
    settingsList.Parent = settingsContent
    
    local enabled = false
    local settingsOpen = false
    local animating = false
    
    local function setZIndexRecursive(instance, z)
        instance.ZIndex = z
        for _, child in pairs(instance:GetChildren()) do
            if child:IsA("GuiObject") then
                setZIndexRecursive(child, z)
            end
        end
    end
    
    local function animateOpen(targetHeight)
        animating = true
        local wrapperTween = TweenService:Create(wrapper, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 55 + targetHeight)})
        local panelTween = TweenService:Create(settingsPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)})
        wrapperTween:Play()
        panelTween:Play()
        wrapperTween.Completed:Connect(function() animating = false end)
    end
    
    local function animateClose()
        animating = true
        local wrapperTween = TweenService:Create(wrapper, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 55)})
        local panelTween = TweenService:Create(settingsPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
        wrapperTween:Play()
        panelTween:Play()
        wrapperTween.Completed:Connect(function()
            animating = false
            for _, child in pairs(settingsContent:GetChildren()) do
                if child ~= settingsList then child:Destroy() end
            end
        end)
    end
    
    button.MouseButton1Click:Connect(function()
        if animating then return end
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
        if animating then return end
        settingsOpen = not settingsOpen
        
        if settingsOpen then
            settingsBtn.Text = "-"
            for _, child in pairs(settingsContent:GetChildren()) do
                if child ~= settingsList then child:Destroy() end
            end
            
            if settingsBuilder then
                settingsBuilder(settingsContent)
            end
            
            for _, child in pairs(settingsContent:GetChildren()) do
                if child ~= settingsList then
                    setZIndexRecursive(child, 9)
                end
            end
            
            local itemCount = 0
            for _, child in pairs(settingsContent:GetChildren()) do
                if child ~= settingsList then itemCount += 1 end
            end
            
            local targetHeight = math.max(itemCount * 40 + 20, 80)
            animateOpen(targetHeight)
        else
            settingsBtn.Text = "+"
            animateClose()
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
