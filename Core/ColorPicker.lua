local ColorPicker = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

function ColorPicker.Create(parent, callback, defaultColor)
    local selectedColor = defaultColor or Color3.fromRGB(255, 0, 0)
    local hue = 0
    local saturation = 1
    local brightness = 1
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 100)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local function hslToRgb(h, s, l)
        local r, g, b
        if s == 0 then
            r = l
            g = l
            b = l
        else
            local function hue2rgb(p, q, t)
                if t < 0 then t = t + 1 end
                if t > 1 then t = t - 1 end
                if t < 1/6 then return p + (q - p) * 6 * t end
                if t < 1/2 then return q end
                if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
                return p
            end
            
            local q = l < 0.5 and l * (1 + s) or l + s - l * s
            local p = 2 * l - q
            r = hue2rgb(p, q, h + 1/3)
            g = hue2rgb(p, q, h)
            b = hue2rgb(p, q, h - 1/3)
        end
        return Color3.new(r, g, b)
    end
    
    local function updateColor()
        selectedColor = hslToRgb(hue, saturation, brightness)
        if callback then callback(selectedColor) end
    end
    
    local colorCanvas = Instance.new("Frame")
    colorCanvas.Size = UDim2.new(1, -20, 0, 55)
    colorCanvas.Position = UDim2.new(0, 0, 0, 0)
    colorCanvas.BackgroundColor3 = Color3.new(1, 1, 1)
    colorCanvas.BorderSizePixel = 0
    colorCanvas.Parent = container
    
    local canvasCorner = Instance.new("UICorner")
    canvasCorner.CornerRadius = UDim.new(0, 6)
    canvasCorner.Parent = colorCanvas
    
    local hueColor = hslToRgb(hue, 1, 0.5)
    
    local saturationGradient = Instance.new("UIGradient")
    saturationGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, hueColor)
    })
    saturationGradient.Parent = colorCanvas
    
    local brightnessGradient = Instance.new("UIGradient")
    brightnessGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    brightnessGradient.Rotation = 90
    brightnessGradient.Parent = colorCanvas
    
    local canvasIndicator = Instance.new("Frame")
    canvasIndicator.Size = UDim2.new(0, 10, 0, 10)
    canvasIndicator.Position = UDim2.new(saturation, -5, 1 - brightness, -5)
    canvasIndicator.BackgroundColor3 = Color3.new(1, 1, 1)
    canvasIndicator.BorderSizePixel = 0
    canvasIndicator.ZIndex = 10
    canvasIndicator.Parent = colorCanvas
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 5)
    indicatorCorner.Parent = canvasIndicator
    
    local indicatorStroke = Instance.new("UIStroke")
    indicatorStroke.Color = Color3.new(0, 0, 0)
    indicatorStroke.Thickness = 1.5
    indicatorStroke.Parent = canvasIndicator
    
    local hueSlider = Instance.new("Frame")
    hueSlider.Size = UDim2.new(1, -20, 0, 8)
    hueSlider.Position = UDim2.new(0, 0, 0, 62)
    hueSlider.BorderSizePixel = 0
    hueSlider.Parent = container
    
    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 4)
    hueCorner.Parent = hueSlider
    
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    hueGradient.Parent = hueSlider
    
    local hueIndicator = Instance.new("Frame")
    hueIndicator.Size = UDim2.new(0, 14, 0, 14)
    hueIndicator.Position = UDim2.new(hue, -7, 0.5, -7)
    hueIndicator.BackgroundColor3 = Color3.new(1, 1, 1)
    hueIndicator.BorderSizePixel = 0
    hueIndicator.ZIndex = 10
    hueIndicator.Parent = hueSlider
    
    local hueIndicatorCorner = Instance.new("UICorner")
    hueIndicatorCorner.CornerRadius = UDim.new(0, 7)
    hueIndicatorCorner.Parent = hueIndicator
    
    local hueIndicatorStroke = Instance.new("UIStroke")
    hueIndicatorStroke.Color = Color3.new(0, 0, 0)
    hueIndicatorStroke.Thickness = 1.5
    hueIndicatorStroke.Parent = hueIndicator
    
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 30, 0, 20)
    preview.Position = UDim2.new(1, -30, 0, 75)
    preview.BackgroundColor3 = selectedColor
    preview.BorderSizePixel = 0
    preview.Parent = container
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = preview
    
    local function updateCanvas()
        local hueColor = hslToRgb(hue, 1, 0.5)
        saturationGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, hueColor)
        })
    end
    
    local function updateIndicators()
        canvasIndicator.Position = UDim2.new(saturation, -5, 1 - brightness, -5)
        hueIndicator.Position = UDim2.new(hue, -7, 0.5, -7)
    end
    
    local function updatePreview()
        selectedColor = hslToRgb(hue, saturation, brightness)
        preview.BackgroundColor3 = selectedColor
        if callback then callback(selectedColor) end
    end
    
    colorCanvas.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local mousePos = UserInputService:GetMouseLocation()
                local canvasPos = colorCanvas.AbsolutePosition
                local canvasSize = colorCanvas.AbsoluteSize
                
                saturation = math.clamp((mousePos.X - canvasPos.X) / canvasSize.X, 0, 1)
                brightness = math.clamp(1 - (mousePos.Y - canvasPos.Y) / canvasSize.Y, 0, 1)
                
                updateIndicators()
                updatePreview()
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
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local mousePos = UserInputService:GetMouseLocation()
                local sliderPos = hueSlider.AbsolutePosition
                local sliderSize = hueSlider.AbsoluteSize
                
                hue = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                
                updateCanvas()
                updateIndicators()
                updatePreview()
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
    
    updateCanvas()
    updateIndicators()
    updatePreview()
    
    return {
        Container = container,
        GetColor = function() return selectedColor end,
        SetColor = function(color)
            selectedColor = color
            preview.BackgroundColor3 = color
        end
    }
end

return ColorPicker
