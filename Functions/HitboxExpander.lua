local HitboxExpander = {}

HitboxExpander.Settings = {
    Scale = 2,
    Keybind = nil
}

HitboxExpander.Enabled = false
HitboxExpander.Player = nil
HitboxExpander.Saved = {}
HitboxExpander.LoopConnection = nil

local RunService = game:GetService("RunService")

local function applyScale()
    if not HitboxExpander.Enabled then return end

    local player = HitboxExpander.Player
    local character = player and player.Character

    if not character then return end

    local scale = HitboxExpander.Settings.Scale

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            local original = HitboxExpander.Saved[part]

            if not original then
                original = part.Size
                HitboxExpander.Saved[part] = original
            end

            local target = original * scale

            if part.Size ~= target then
                part.Size = target
            end
        end
    end
end

function HitboxExpander.Start(player)
    if HitboxExpander.Enabled then return end

    HitboxExpander.Player = player
    HitboxExpander.Saved = {}
    HitboxExpander.Enabled = true

    applyScale()

    HitboxExpander.LoopConnection = RunService.Heartbeat:Connect(applyScale)
end

function HitboxExpander.Stop()
    if not HitboxExpander.Enabled then return end

    HitboxExpander.Enabled = false

    if HitboxExpander.LoopConnection then
        HitboxExpander.LoopConnection:Disconnect()
        HitboxExpander.LoopConnection = nil
    end

    for part, original in pairs(HitboxExpander.Saved) do
        if part and part.Parent then
            pcall(function()
                part.Size = original
            end)
        end
    end

    HitboxExpander.Saved = {}
    HitboxExpander.Player = nil
end

local function createSlider(content, title, minimum, maximum, value, onChanged)
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

    local function updateVisual(number)
        valueLabel.Text = string.format("%.1fx", number)
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

function HitboxExpander.BuildSettings(content)
    createSlider(content, "Scale", 1, 5, HitboxExpander.Settings.Scale, function(value)
        HitboxExpander.Settings.Scale = value
    end)

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 70)
    info.BackgroundTransparency = 1
    info.Text = "Scales your own character parts locally. The server sees the real size, so damage only counts in games that use client-side hit detection. Hitbox parts are restored when disabled"
    info.TextColor3 = Color3.fromRGB(160, 160, 160)
    info.Font = Enum.Font.GothamBold
    info.TextSize = 11
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = content
end

return HitboxExpander
