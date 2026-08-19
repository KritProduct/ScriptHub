local Elements = {}

function Elements.CreateLabel(parent, text, size, pos, font, color, textSize)
    local label = Instance.new("TextLabel")
    label.Size = size or UDim2.new(1, 0, 0, 20)
    label.Position = pos or UDim2.new(0, 0, 0, 0)
    label.Text = text or ""
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.Font = font or Enum.Font.GothamBold
    label.TextSize = textSize or 13
    label.Parent = parent
    return label
end

function Elements.CreateButton(parent, text, size, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(1, 0, 0, 40)
    btn.Position = pos or UDim2.new(0, 0, 0, 0)
    btn.Text = text or "Button"
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn
    
    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

function Elements.CreateSlider(parent, min, max, current, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Elements.CreateLabel(container, tostring(math.floor(current)), UDim2.new(0, 50, 0, 20), UDim2.new(1, -50, 0, 0), Enum.Font.GothamBlack, Color3.fromRGB(80, 140, 255), 11)
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -60, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 20)
    track.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    track.BorderSizePixel = 0
    track.Parent = container
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 0, 6)
    fill.Position = UDim2.new(0, 0, 0, 20)
    fill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    fill.BorderSizePixel = 0
    fill.Parent = container
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    local function updateVisual(value)
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(0, percent * track.AbsoluteSize.X, 0, 6)
        label.Text = tostring(math.floor(value))
    end
    
    updateVisual(current)
    
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
                local value = min + percent * (max - min)
                updateVisual(value)
                if callback then callback(value) end
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
    
    return container
end

function Elements.CreateToggle(parent, text, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Elements.CreateLabel(container, text, UDim2.new(1, -50, 1, 0), UDim2.new(0, 0, 0, 0), Enum.Font.GothamBold, Color3.new(1, 1, 1), 12)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Elements.CreateButton(container, "", UDim2.new(0, 40, 0, 22), UDim2.new(1, -40, 0.5, -11))
    toggle.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 11)
    toggleCorner.Parent = toggle
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = UDim2.new(0, 3, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
    dot.BorderSizePixel = 0
    dot.Parent = toggle
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0, 8)
    dotCorner.Parent = dot
    
    local enabled = default or false
    
    local function updateToggle()
        if enabled then
            toggle.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            dot.Position = UDim2.new(1, -19, 0.5, -8)
            dot.BackgroundColor3 = Color3.new(1, 1, 1)
        else
            toggle.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            dot.Position = UDim2.new(0, 3, 0.5, -8)
            dot.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
        end
    end
    
    updateToggle()
    
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateToggle()
        if callback then callback(enabled) end
    end)
    
    return container
end

return Elements
