local ColorPicker = {}

function ColorPicker.Create(parent, callback, defaultColor)
    local selectedColor = defaultColor or Color3.fromRGB(255, 0, 0)
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 100, 0),
        Color3.fromRGB(255, 200, 0),
        Color3.fromRGB(100, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 255, 200),
        Color3.fromRGB(0, 100, 255),
        Color3.fromRGB(100, 0, 255),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(255, 0, 100),
        Color3.new(1, 1, 1),
        Color3.new(0, 0, 0)
    }
    
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 30, 0, 30)
    preview.Position = UDim2.new(1, -30, 0, 0)
    preview.BackgroundColor3 = selectedColor
    preview.BorderSizePixel = 0
    preview.Parent = container
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 6)
    previewCorner.Parent = preview
    
    for i, color in ipairs(colors) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 25, 0, 25)
        btn.Position = UDim2.new(0, (i - 1) * 28, 0, 0)
        btn.Text = ""
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = container
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            selectedColor = color
            preview.BackgroundColor3 = color
            if callback then callback(color) end
        end)
    end
    
    return {
        Container = container,
        GetColor = function() return selectedColor end,
        SetColor = function(color) selectedColor = color preview.BackgroundColor3 = color end
    }
end

return ColorPicker
