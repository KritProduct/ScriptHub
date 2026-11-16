local LightingEditor = {}

LightingEditor.Settings = {
    Brightness = 2,
    ClockTime = 14,
    Ambient = Color3.fromRGB(70, 70, 70),
    OutdoorAmbient = Color3.fromRGB(128, 128, 128),
    Keybind = nil
}

LightingEditor.Enabled = false
LightingEditor.Original = nil
LightingEditor.LoopConnection = nil

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

local function applyLighting()
    if not LightingEditor.Enabled then return end

    local Lighting = game:GetService("Lighting")
    local settings = LightingEditor.Settings

    if Lighting.Brightness ~= settings.Brightness then
        Lighting.Brightness = settings.Brightness
    end

    if Lighting.ClockTime ~= settings.ClockTime then
        Lighting.ClockTime = settings.ClockTime
    end

    if Lighting.Ambient ~= settings.Ambient then
        Lighting.Ambient = settings.Ambient
    end

    if Lighting.OutdoorAmbient ~= settings.OutdoorAmbient then
        Lighting.OutdoorAmbient = settings.OutdoorAmbient
    end
end

function LightingEditor.Start(player)
    if LightingEditor.Enabled then return end

    local Lighting = game:GetService("Lighting")

    LightingEditor.Enabled = true
    LightingEditor.Original = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient
    }

    applyLighting()

    LightingEditor.LoopConnection = RunService.Heartbeat:Connect(applyLighting)
end

function LightingEditor.Stop()
    if not LightingEditor.Enabled then return end

    LightingEditor.Enabled = false

    if LightingEditor.LoopConnection then
        LightingEditor.LoopConnection:Disconnect()
        LightingEditor.LoopConnection = nil
    end

    local Lighting = game:GetService("Lighting")

    if LightingEditor.Original then
        Lighting.Brightness = LightingEditor.Original.Brightness
        Lighting.ClockTime = LightingEditor.Original.ClockTime
        Lighting.Ambient = LightingEditor.Original.Ambient
        Lighting.OutdoorAmbient = LightingEditor.Original.OutdoorAmbient
        LightingEditor.Original = nil
    end
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

function LightingEditor.BuildSettings(content)
    createSlider(content, "Brightness", 0, 5, LightingEditor.Settings.Brightness, 2, function(value)
        LightingEditor.Settings.Brightness = value
    end)

    createSlider(content, "Clock Time", 0, 24, LightingEditor.Settings.ClockTime, 2, function(value)
        LightingEditor.Settings.ClockTime = value
    end)

    local ambientLabel = Instance.new("TextLabel")
    ambientLabel.Size = UDim2.new(1, 0, 0, 20)
    ambientLabel.BackgroundTransparency = 1
    ambientLabel.Text = "Ambient"
    ambientLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ambientLabel.Font = Enum.Font.GothamBold
    ambientLabel.TextSize = 11
    ambientLabel.TextXAlignment = Enum.TextXAlignment.Left
    ambientLabel.Parent = content

    getColorPicker().Create(content, LightingEditor.Settings.Ambient, function(color)
        LightingEditor.Settings.Ambient = color
    end)

    local outdoorLabel = Instance.new("TextLabel")
    outdoorLabel.Size = UDim2.new(1, 0, 0, 20)
    outdoorLabel.BackgroundTransparency = 1
    outdoorLabel.Text = "Outdoor Ambient"
    outdoorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    outdoorLabel.Font = Enum.Font.GothamBold
    outdoorLabel.TextSize = 11
    outdoorLabel.TextXAlignment = Enum.TextXAlignment.Left
    outdoorLabel.Parent = content

    getColorPicker().Create(content, LightingEditor.Settings.OutdoorAmbient, function(color)
        LightingEditor.Settings.OutdoorAmbient = color
    end)
end

return LightingEditor
