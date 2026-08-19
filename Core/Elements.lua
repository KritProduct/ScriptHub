local Elements = {}

function Elements.CreateButton(parent, text, size, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(1, 0, 0, 40)
    btn.Position = pos or UDim2.new(0, 0, 0, 0)
    btn.Text = text or "Button"
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

function Elements.CreateLabel(parent, text, size, pos)
    local label = Instance.new("TextLabel")
    label.Size = size or UDim2.new(1, 0, 0, 20)
    label.Position = pos or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = parent
    return label
end

function Elements.CreateFrame(parent, size, pos, color)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(1, 0, 0, 50)
    frame.Position = pos or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = color or Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    return frame
end

return Elements
