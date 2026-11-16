local Spinbot = {}

Spinbot.Settings = {
    Speed = 720,
    Keybind = nil
}

Spinbot.Enabled = false
Spinbot.Player = nil
Spinbot.Root = nil
Spinbot.Humanoid = nil
Spinbot.OriginalAutoRotate = nil
Spinbot.LoopConnection = nil

local RunService = game:GetService("RunService")

local function refreshCharacter()
    local player = Spinbot.Player
    local character = player and player.Character

    if not character then return false end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then return false end

    Spinbot.Root = root

    if Spinbot.Humanoid ~= humanoid then
        Spinbot.Humanoid = humanoid
        Spinbot.OriginalAutoRotate = humanoid.AutoRotate
        humanoid.AutoRotate = false
    end

    return true
end

function Spinbot.Start(player)
    if Spinbot.Enabled then return end

    Spinbot.Player = player
    Spinbot.Enabled = true

    refreshCharacter()

    Spinbot.LoopConnection = RunService.RenderStepped:Connect(function(deltaTime)
        if not Spinbot.Enabled then return end

        if not Spinbot.Root or not Spinbot.Root.Parent then
            if not refreshCharacter() then return end
        end

        local speed = Spinbot.Settings.Speed

        if speed ~= 0 then
            local step = math.rad(speed) * deltaTime
            Spinbot.Root.CFrame = Spinbot.Root.CFrame * CFrame.Angles(0, step, 0)
        end
    end)
end

function Spinbot.Stop()
    if not Spinbot.Enabled then return end

    Spinbot.Enabled = false

    if Spinbot.LoopConnection then
        Spinbot.LoopConnection:Disconnect()
        Spinbot.LoopConnection = nil
    end

    if Spinbot.Humanoid and Spinbot.Humanoid.Parent then
        Spinbot.Humanoid.AutoRotate = Spinbot.OriginalAutoRotate
    end

    Spinbot.Player = nil
    Spinbot.Root = nil
    Spinbot.Humanoid = nil
    Spinbot.OriginalAutoRotate = nil
end

function Spinbot.BuildSettings(content)
    local RunService = game:GetService("RunService")

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 40)
    slider.BackgroundTransparency = 1
    slider.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = "Speed"
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
        valueLabel.Text = tostring(math.floor(number + 0.5)) .. " deg/s"
        local percent = math.clamp((number - 60) / (1800 - 60), 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0)
    end

    updateVisual(Spinbot.Settings.Speed)

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
            local number = 60 + percent * (1800 - 60)
            Spinbot.Settings.Speed = number
            updateVisual(number)
        end)

        endedConnection = game:GetService("UserInputService").InputEnded:Connect(function(release)
            if release.UserInputType == Enum.UserInputType.MouseButton1 or release.UserInputType == Enum.UserInputType.Touch then
                connection:Disconnect()
                endedConnection:Disconnect()
            end
        end)
    end)

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 40)
    info.BackgroundTransparency = 1
    info.Text = "Spins your character around its own axis. Speed is degrees per second"
    info.TextColor3 = Color3.fromRGB(160, 160, 160)
    info.Font = Enum.Font.GothamBold
    info.TextSize = 11
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = content
end

return Spinbot
