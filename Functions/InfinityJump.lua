local InfinityJump = {}

InfinityJump.Settings = {
    JumpPower = 100,
    AutoJump = false,
    Keybind = nil
}

InfinityJump.Enabled = false
InfinityJump.Connection = nil

function InfinityJump.Start(player)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    InfinityJump.Enabled = true

    InfinityJump.Connection = RunService.Heartbeat:Connect(function()
        if not InfinityJump.Enabled then return end

        local character = player.Character
        if not character then return end

        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end

        humanoid.JumpPower = InfinityJump.Settings.JumpPower

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end

        if InfinityJump.Settings.AutoJump then
            if humanoid:GetState() == Enum.HumanoidStateType.Landed then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

function InfinityJump.Stop(player)
    InfinityJump.Enabled = false

    if InfinityJump.Connection then
        InfinityJump.Connection:Disconnect()
        InfinityJump.Connection = nil
    end

    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
        end
    end
end

function InfinityJump.BuildSettings(content)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 35)
    slider.BackgroundTransparency = 1
    slider.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 50, 0, 20)
    label.Position = UDim2.new(1, -50, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(InfinityJump.Settings.JumpPower)
    label.TextColor3 = Color3.fromRGB(80, 140, 255)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 11
    label.Parent = slider

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -60, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 20)
    track.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    track.BorderSizePixel = 0
    track.Parent = slider

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 0, 6)
    fill.Position = UDim2.new(0, 0, 0, 20)
    fill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill

    local function updateVisual(value)
        local percent = (value - 50) / (500 - 50)
        fill.Size = UDim2.new(0, percent * track.AbsoluteSize.X, 0, 6)
        label.Text = tostring(math.floor(value))
    end

    updateVisual(InfinityJump.Settings.JumpPower)

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
                local value = 50 + percent * (500 - 50)
                InfinityJump.Settings.JumpPower = value
                updateVisual(value)
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

    local function createToggle(text, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 30)
        container.BackgroundTransparency = 1
        container.Parent = content

        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Size = UDim2.new(1, -50, 1, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = text
        toggleLabel.TextColor3 = Color3.new(1, 1, 1)
        toggleLabel.Font = Enum.Font.GothamBold
        toggleLabel.TextSize = 12
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = container

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 40, 0, 22)
        toggle.Position = UDim2.new(1, -40, 0.5, -11)
        toggle.Text = ""
        toggle.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        toggle.BorderSizePixel = 0
        toggle.AutoButtonColor = false
        toggle.Parent = container

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

        local enabled = default

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
            callback(enabled)
        end)
    end

    createToggle("Auto Jump", InfinityJump.Settings.AutoJump, function(v) InfinityJump.Settings.AutoJump = v end)
end

return InfinityJump
