local ColorPicker = {}

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local HUE_STOPS = {
    { 0, Color3.fromRGB(255, 0, 0) },
    { 0.1667, Color3.fromRGB(255, 255, 0) },
    { 0.3333, Color3.fromRGB(0, 255, 0) },
    { 0.5, Color3.fromRGB(0, 255, 255) },
    { 0.6667, Color3.fromRGB(0, 0, 255) },
    { 0.8333, Color3.fromRGB(255, 0, 255) },
    { 1, Color3.fromRGB(255, 0, 0) }
}

local function getMousePosition()
    local location = UserInputService:GetMouseLocation()
    local inset = GuiService:GetGuiInset()
    return Vector2.new(location.X - inset.X, location.Y - inset.Y)
end

local function toHex(color)
    return string.format(
        "#%02X%02X%02X",
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5)
    )
end

function ColorPicker.Create(parent, initialColor, callback)
    local hue, saturation, value = initialColor:ToHSV()

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 176)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local area = Instance.new("Frame")
    area.Size = UDim2.new(1, 0, 0, 110)
    area.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
    area.BorderSizePixel = 0
    area.ClipsDescendants = true
    area.Active = true
    area.Parent = container

    local areaCorner = Instance.new("UICorner")
    areaCorner.CornerRadius = UDim.new(0, 6)
    areaCorner.Parent = area

    local whiteOverlay = Instance.new("Frame")
    whiteOverlay.Size = UDim2.new(1, 0, 1, 0)
    whiteOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
    whiteOverlay.BorderSizePixel = 0
    whiteOverlay.Active = true
    whiteOverlay.Parent = area

    local whiteGradient = Instance.new("UIGradient")
    whiteGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    whiteGradient.Parent = whiteOverlay

    local valueSteps = 24
    for index = 0, valueSteps - 1 do
        local strip = Instance.new("Frame")
        strip.Size = UDim2.new(1, 0, 1 / valueSteps, 1)
        strip.Position = UDim2.new(0, 0, index / valueSteps, 0)
        strip.BackgroundColor3 = Color3.new(0, 0, 0)
        strip.BorderSizePixel = 0
        strip.BackgroundTransparency = 1 - (index / (valueSteps - 1))
        strip.Parent = area
    end

    local cursor = Instance.new("Frame")
    cursor.Size = UDim2.new(0, 12, 0, 12)
    cursor.AnchorPoint = Vector2.new(0.5, 0.5)
    cursor.BackgroundTransparency = 1
    cursor.Parent = area

    local cursorStroke = Instance.new("UIStroke")
    cursorStroke.Color = Color3.new(1, 1, 1)
    cursorStroke.Thickness = 2
    cursorStroke.Parent = cursor

    local areaCatcher = Instance.new("Frame")
    areaCatcher.Size = UDim2.new(1, 0, 1, 0)
    areaCatcher.BackgroundTransparency = 1
    areaCatcher.BorderSizePixel = 0
    areaCatcher.Active = true
    areaCatcher.Parent = area

    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(1, 0, 0, 14)
    hueBar.Position = UDim2.new(0, 0, 0, 118)
    hueBar.BorderSizePixel = 0
    hueBar.Active = true
    hueBar.Parent = container

    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 4)
    hueCorner.Parent = hueBar

    local hueGradient = Instance.new("UIGradient")
    local hueKeypoints = {}
    for _, stop in ipairs(HUE_STOPS) do
        table.insert(hueKeypoints, ColorSequenceKeypoint.new(stop[1], stop[2]))
    end
    hueGradient.Color = ColorSequence.new(hueKeypoints)
    hueGradient.Parent = hueBar

    local hueMarker = Instance.new("Frame")
    hueMarker.Size = UDim2.new(0, 4, 1, 4)
    hueMarker.AnchorPoint = Vector2.new(0.5, 0.5)
    hueMarker.Position = UDim2.new(hue, 0, 0.5, 0)
    hueMarker.BackgroundColor3 = Color3.new(1, 1, 1)
    hueMarker.BorderSizePixel = 0
    hueMarker.Active = true
    hueMarker.Parent = hueBar

    local hueMarkerCorner = Instance.new("UICorner")
    hueMarkerCorner.CornerRadius = UDim.new(0, 2)
    hueMarkerCorner.Parent = hueMarker

    local hueCatcher = Instance.new("Frame")
    hueCatcher.Size = UDim2.new(1, 0, 1, 0)
    hueCatcher.BackgroundTransparency = 1
    hueCatcher.BorderSizePixel = 0
    hueCatcher.Active = true
    hueCatcher.Parent = hueBar

    local bottomRow = Instance.new("Frame")
    bottomRow.Size = UDim2.new(1, 0, 0, 32)
    bottomRow.Position = UDim2.new(0, 0, 0, 140)
    bottomRow.BackgroundTransparency = 1
    bottomRow.Parent = container

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 32, 0, 32)
    preview.BackgroundColor3 = initialColor
    preview.BorderSizePixel = 0
    preview.Parent = bottomRow

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 6)
    previewCorner.Parent = preview

    local hexInput = Instance.new("TextBox")
    hexInput.Size = UDim2.new(1, -40, 1, 0)
    hexInput.Position = UDim2.new(0, 40, 0, 0)
    hexInput.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    hexInput.BorderSizePixel = 0
    hexInput.Text = toHex(initialColor)
    hexInput.PlaceholderText = "#RRGGBB"
    hexInput.TextColor3 = Color3.new(1, 1, 1)
    hexInput.Font = Enum.Font.GothamBold
    hexInput.TextSize = 12
    hexInput.ClearTextOnFocus = false
    hexInput.Parent = bottomRow

    local hexCorner = Instance.new("UICorner")
    hexCorner.CornerRadius = UDim.new(0, 6)
    hexCorner.Parent = hexInput

    local dragging = nil
    local dragConnection = nil

    local function updateColor(notify)
        local color = Color3.fromHSV(hue, saturation, value)

        area.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        cursor.Position = UDim2.new(saturation, 0, 1 - value, 0)
        hueMarker.Position = UDim2.new(hue, 0, 0.5, 0)
        preview.BackgroundColor3 = color
        hexInput.Text = toHex(color)

        if notify and callback then
            callback(color)
        end
    end

    local function updateFromMouse()
        local mouse = getMousePosition()

        if dragging == "area" then
            local scaleX = (mouse.X - area.AbsolutePosition.X) / area.AbsoluteSize.X
            local scaleY = (mouse.Y - area.AbsolutePosition.Y) / area.AbsoluteSize.Y
            saturation = math.clamp(scaleX, 0, 1)
            value = 1 - math.clamp(scaleY, 0, 1)
        elseif dragging == "hue" then
            local scaleX = (mouse.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X
            hue = math.clamp(scaleX, 0, 1)
        end

        updateColor(true)
    end

    local function stopDrag()
        dragging = nil
        if dragConnection then
            dragConnection:Disconnect()
            dragConnection = nil
        end
    end

    local function startDrag(kind)
        dragging = kind
        updateFromMouse()

        if dragConnection then return end
        dragConnection = RunService.RenderStepped:Connect(function()
            if not dragging then return end
            if not area.Parent then
                stopDrag()
                return
            end
            updateFromMouse()
        end)
    end

    local function bindAreaInput(object)
        object.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                startDrag("area")
            end
        end)
    end

    local function bindHueInput(object)
        object.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                startDrag("hue")
            end
        end)
    end

    bindAreaInput(areaCatcher)
    bindHueInput(hueCatcher)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            stopDrag()
        end
    end)

    hexInput.FocusLost:Connect(function()
        local text = string.gsub(hexInput.Text, "#", "")
        if string.len(text) == 6 then
            local red = tonumber(string.sub(text, 1, 2), 16)
            local green = tonumber(string.sub(text, 3, 4), 16)
            local blue = tonumber(string.sub(text, 5, 6), 16)

            if red and green and blue then
                hue, saturation, value = Color3.fromRGB(red, green, blue):ToHSV()
            end
        end

        updateColor(true)
    end)

    updateColor(false)

    return container
end

return ColorPicker
