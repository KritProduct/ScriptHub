local AntiAim = {}

AntiAim.Settings = {
    Offset = 180,
    Jitter = true,
    Keybind = nil
}

AntiAim.Enabled = false
AntiAim.Player = nil
AntiAim.Root = nil
AntiAim.Humanoid = nil
AntiAim.OriginalAutoRotate = nil
AntiAim.JitterSign = 1
AntiAim.NextJitter = 0
AntiAim.LoopConnection = nil

local RunService = game:GetService("RunService")

local function refreshCharacter()
    local player = AntiAim.Player
    local character = player and player.Character

    if not character then return false end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then return false end

    AntiAim.Root = root

    if AntiAim.Humanoid ~= humanoid then
        AntiAim.Humanoid = humanoid
        AntiAim.OriginalAutoRotate = humanoid.AutoRotate
        humanoid.AutoRotate = false
    end

    return true
end

function AntiAim.Start(player)
    if AntiAim.Enabled then return end

    AntiAim.Player = player
    AntiAim.Enabled = true
    AntiAim.NextJitter = 0
    AntiAim.JitterSign = 1

    refreshCharacter()

    AntiAim.LoopConnection = RunService.RenderStepped:Connect(function()
        if not AntiAim.Enabled then return end

        if not AntiAim.Root or not AntiAim.Root.Parent then
            if not refreshCharacter() then return end
        end

        local camera = workspace.CurrentCamera
        if not camera then return end

        local look = camera.CFrame.LookVector
        local baseYaw

        if math.abs(look.X) < 0.0001 and math.abs(look.Z) < 0.0001 then
            baseYaw = 0
        else
            baseYaw = math.atan2(-look.X, -look.Z)
        end

        local angle = AntiAim.Settings.Offset

        if AntiAim.Settings.Jitter then
            local now = os.clock()

            if now >= AntiAim.NextJitter then
                AntiAim.JitterSign = -AntiAim.JitterSign
                AntiAim.NextJitter = now + 0.12
            end

            angle = angle + 25 * AntiAim.JitterSign
        end

        local yaw = baseYaw + math.rad(angle)

        AntiAim.Root.CFrame = CFrame.new(AntiAim.Root.Position) * CFrame.Angles(0, yaw, 0)
    end)
end

function AntiAim.Stop()
    if not AntiAim.Enabled then return end

    AntiAim.Enabled = false

    if AntiAim.LoopConnection then
        AntiAim.LoopConnection:Disconnect()
        AntiAim.LoopConnection = nil
    end

    if AntiAim.Humanoid and AntiAim.Humanoid.Parent then
        AntiAim.Humanoid.AutoRotate = AntiAim.OriginalAutoRotate
    end

    AntiAim.Player = nil
    AntiAim.Root = nil
    AntiAim.Humanoid = nil
    AntiAim.OriginalAutoRotate = nil
end

function AntiAim.BuildSettings(content)
    local RunService = game:GetService("RunService")

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 40)
    slider.BackgroundTransparency = 1
    slider.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = "Angle"
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
        valueLabel.Text = tostring(math.floor(number + 0.5)) .. " deg"
        local percent = math.clamp((number + 180) / 360, 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0)
    end

    updateVisual(AntiAim.Settings.Offset)

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
            local number = -180 + percent * 360
            AntiAim.Settings.Offset = number
            updateVisual(number)
        end)

        endedConnection = game:GetService("UserInputService").InputEnded:Connect(function(release)
            if release.UserInputType == Enum.UserInputType.MouseButton1 or release.UserInputType == Enum.UserInputType.Touch then
                connection:Disconnect()
                endedConnection:Disconnect()
            end
        end)
    end)

    local jitterButton = Instance.new("TextButton")
    jitterButton.Size = UDim2.new(1, 0, 0, 28)
    jitterButton.Text = "Jitter: " .. (AntiAim.Settings.Jitter and "ON" or "OFF")
    jitterButton.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    jitterButton.BorderSizePixel = 0
    jitterButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    jitterButton.Font = Enum.Font.GothamBlack
    jitterButton.TextSize = 11
    jitterButton.AutoButtonColor = false
    jitterButton.Parent = content

    local jitterCorner = Instance.new("UICorner")
    jitterCorner.CornerRadius = UDim.new(0, 6)
    jitterCorner.Parent = jitterButton

    jitterButton.MouseButton1Click:Connect(function()
        AntiAim.Settings.Jitter = not AntiAim.Settings.Jitter
        jitterButton.Text = "Jitter: " .. (AntiAim.Settings.Jitter and "ON" or "OFF")
    end)

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 55)
    info.BackgroundTransparency = 1
    info.Text = "Turns your character away from the camera direction by the chosen angle and adds random jitter, so your real facing is hard to read"
    info.TextColor3 = Color3.fromRGB(160, 160, 160)
    info.Font = Enum.Font.GothamBold
    info.TextSize = 11
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = content
end

return AntiAim
