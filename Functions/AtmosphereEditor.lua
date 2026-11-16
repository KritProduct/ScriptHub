local AtmosphereEditor = {}

AtmosphereEditor.Settings = {
    Density = 0.3,
    Offset = 0,
    Haze = 0,
    Glare = 0,
    Color = Color3.fromRGB(199, 199, 199),
    Keybind = nil
}

AtmosphereEditor.Enabled = false
AtmosphereEditor.Instance = nil
AtmosphereEditor.Original = nil
AtmosphereEditor.Created = false
AtmosphereEditor.LoopConnection = nil

local RunService = game:GetService("RunService")
local ColorPicker = nil

local function getColorPicker()
    if not ColorPicker then
        ColorPicker = _G.ScriptHubColorPicker
        if not ColorPicker then
            ColorPicker = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/UI/ColorPicker.lua?v=" .. tostring(math.floor(os.time()))))()
            _G.ScriptHubColorPicker = ColorPicker
        end
    end
    return ColorPicker
end

local function ensureAtmosphere()
    local Lighting = game:GetService("Lighting")
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Parent = Lighting
        AtmosphereEditor.Created = true
    end

    AtmosphereEditor.Instance = atmosphere
    return atmosphere
end

local function applyAtmosphere()
    if not AtmosphereEditor.Enabled then return end

    local atmosphere = AtmosphereEditor.Instance
    if not atmosphere or not atmosphere.Parent then
        atmosphere = ensureAtmosphere()
    end

    local settings = AtmosphereEditor.Settings

    if atmosphere.Density ~= settings.Density then
        atmosphere.Density = settings.Density
    end

    if atmosphere.Offset ~= settings.Offset then
        atmosphere.Offset = settings.Offset
    end

    if atmosphere.Haze ~= settings.Haze then
        atmosphere.Haze = settings.Haze
    end

    if atmosphere.Glare ~= settings.Glare then
        atmosphere.Glare = settings.Glare
    end

    if atmosphere.Color ~= settings.Color then
        atmosphere.Color = settings.Color
    end
end

function AtmosphereEditor.Start(player)
    if AtmosphereEditor.Enabled then return end

    AtmosphereEditor.Enabled = true
    AtmosphereEditor.Created = false
    AtmosphereEditor.Original = nil

    local atmosphere = ensureAtmosphere()

    if not AtmosphereEditor.Created then
        AtmosphereEditor.Original = {
            Density = atmosphere.Density,
            Offset = atmosphere.Offset,
            Haze = atmosphere.Haze,
            Glare = atmosphere.Glare,
            Color = atmosphere.Color
        }
    end

    applyAtmosphere()

    AtmosphereEditor.LoopConnection = RunService.Heartbeat:Connect(applyAtmosphere)
end

function AtmosphereEditor.Stop()
    if not AtmosphereEditor.Enabled then return end

    AtmosphereEditor.Enabled = false

    if AtmosphereEditor.LoopConnection then
        AtmosphereEditor.LoopConnection:Disconnect()
        AtmosphereEditor.LoopConnection = nil
    end

    local atmosphere = AtmosphereEditor.Instance

    if AtmosphereEditor.Created then
        if atmosphere and atmosphere.Parent then
            atmosphere:Destroy()
        end
    elseif atmosphere and atmosphere.Parent and AtmosphereEditor.Original then
        atmosphere.Density = AtmosphereEditor.Original.Density
        atmosphere.Offset = AtmosphereEditor.Original.Offset
        atmosphere.Haze = AtmosphereEditor.Original.Haze
        atmosphere.Glare = AtmosphereEditor.Original.Glare
        atmosphere.Color = AtmosphereEditor.Original.Color
    end

    AtmosphereEditor.Instance = nil
    AtmosphereEditor.Original = nil
    AtmosphereEditor.Created = false
end

local function createSlider(content, title, minimum, maximum, value, decimals, onChanged)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 40)
    slider.BackgroundTransparency = 1
    slider.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.4, 0, 0, 18)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(80, 140, 255)
    valueLabel.Font = Enum.Font.GothamBlack
    valueLabel.TextSize = 11
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = slider

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 24)
    track.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    track.BorderSizePixel = 0
    track.Active = true
    track.Parent = slider

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 0, 6)
    fill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill

    local function formatValue(number)
        if decimals and decimals > 0 then
            return string.format("%." .. tostring(decimals) .. "f", number)
        end
        return tostring(math.floor(number + 0.5))
    end

    local function updateVisual(number)
        valueLabel.Text = formatValue(number)
        local percent = math.clamp((number - minimum) / (maximum - minimum), 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0)
    end

    updateVisual(value)

    track.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local connection
        local endedConnection

        connection = RunService.RenderStepped:Connect(function()
            local mouseX = game:GetService("UserInputService"):GetMouseLocation().X
            local startX = track.AbsolutePosition.X
            local width = track.AbsoluteSize.X

            if width <= 0 then return end

            local percent = math.clamp((mouseX - startX) / width, 0, 1)
            local number = minimum + percent * (maximum - minimum)
            onChanged(number)
            updateVisual(number)
        end)

        endedConnection = game:GetService("UserInputService").InputEnded:Connect(function(release)
            if release.UserInputType == Enum.UserInputType.MouseButton1 or release.UserInputType == Enum.UserInputType.Touch then
                connection:Disconnect()
                endedConnection:Disconnect()
            end
        end)
    end)
end

function AtmosphereEditor.BuildSettings(content)
    createSlider(content, "Density", 0, 1, AtmosphereEditor.Settings.Density, 2, function(value)
        AtmosphereEditor.Settings.Density = value
    end)

    createSlider(content, "Offset", -1, 1, AtmosphereEditor.Settings.Offset, 2, function(value)
        AtmosphereEditor.Settings.Offset = value
    end)

    createSlider(content, "Haze", 0, 10, AtmosphereEditor.Settings.Haze, 2, function(value)
        AtmosphereEditor.Settings.Haze = value
    end)

    createSlider(content, "Glare", 0, 10, AtmosphereEditor.Settings.Glare, 2, function(value)
        AtmosphereEditor.Settings.Glare = value
    end)

    local colorLabel = Instance.new("TextLabel")
    colorLabel.Size = UDim2.new(1, 0, 0, 20)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Text = "Color"
    colorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    colorLabel.Font = Enum.Font.GothamBold
    colorLabel.TextSize = 11
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.Parent = content

    getColorPicker().Create(content, AtmosphereEditor.Settings.Color, function(color)
        AtmosphereEditor.Settings.Color = color
    end)
end

return AtmosphereEditor
