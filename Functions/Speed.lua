local Speed = {}

Speed.Settings = {
    Speed = 16,
    Mode = "Humanoid",
    Keybind = nil
}

Speed.Enabled = false
Speed.OriginalWalkSpeed = nil
Speed.CharacterConnection = nil
Speed.LoopConnection = nil
Speed.Player = nil

local RunService = game:GetService("RunService")

local function getHumanoid(player)
    local character = player.Character
    if not character then return nil end
    return character:FindFirstChildOfClass("Humanoid")
end

local function applyHumanoid(player)
    local humanoid = getHumanoid(player)
    if humanoid and humanoid.WalkSpeed ~= Speed.Settings.Speed then
        humanoid.WalkSpeed = Speed.Settings.Speed
    end
end

local function applyCFrame(player, deltaTime)
    local humanoid = getHumanoid(player)
    if not humanoid then return end

    local root = humanoid.RootPart
    if not root then return end

    local baseSpeed = Speed.OriginalWalkSpeed

    if not baseSpeed or baseSpeed < 8 then
        baseSpeed = 16
    end

    if humanoid.WalkSpeed ~= baseSpeed then
        humanoid.WalkSpeed = baseSpeed
    end

    local extra = Speed.Settings.Speed - baseSpeed
    if extra <= 0 then return end

    local direction = humanoid.MoveDirection
    if direction.Magnitude < 0.01 then return end

    local flat = Vector3.new(direction.X, 0, direction.Z)
    if flat.Magnitude < 0.01 then return end

    root.CFrame = root.CFrame + flat.Unit * extra * deltaTime
end

function Speed.Start(player)
    local currentHumanoid = getHumanoid(player)
    if not currentHumanoid then return end

    if Speed.Enabled then return end

    Speed.Enabled = true
    Speed.Player = player
    Speed.OriginalWalkSpeed = currentHumanoid.WalkSpeed

    if Speed.Settings.Mode == "Humanoid" then
        applyHumanoid(player)
    else
        applyCFrame(player, 0)
    end

    Speed.CharacterConnection = player.CharacterAdded:Connect(function()
        if not Speed.Enabled then return end
        task.wait(0.2)
        if Speed.Settings.Mode == "Humanoid" then
            applyHumanoid(player)
        else
            applyCFrame(player, 0)
        end
    end)

    Speed.LoopConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not Speed.Enabled then return end

        local target = Speed.Player or game:GetService("Players").LocalPlayer or player
        if Speed.Settings.Mode == "Humanoid" then
            applyHumanoid(target)
        else
            applyCFrame(target, deltaTime)
        end
    end)
end

function Speed.Stop(player)
    Speed.Enabled = false

    if Speed.CharacterConnection then
        Speed.CharacterConnection:Disconnect()
        Speed.CharacterConnection = nil
    end

    if Speed.LoopConnection then
        Speed.LoopConnection:Disconnect()
        Speed.LoopConnection = nil
    end

    local humanoid = getHumanoid(player)
    if humanoid and Speed.OriginalWalkSpeed ~= nil then
        humanoid.WalkSpeed = Speed.OriginalWalkSpeed
    end

    Speed.OriginalWalkSpeed = nil
    Speed.Player = nil
end

function Speed.BuildSettings(content, player)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Mode"
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content

    local modeRow = Instance.new("Frame")
    modeRow.Size = UDim2.new(1, 0, 0, 30)
    modeRow.BackgroundTransparency = 1
    modeRow.Parent = content

    local modeButtons = {}

    local function refreshModes()
        for mode, button in pairs(modeButtons) do
            if Speed.Settings.Mode == mode then
                button.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
                button.TextColor3 = Color3.new(1, 1, 1)
            else
                button.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
    end

    local function createModeButton(mode, x)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.48, 0, 1, 0)
        button.Position = UDim2.new(x, 0, 0, 0)
        button.Text = mode
        button.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        button.BorderSizePixel = 0
        button.TextColor3 = Color3.fromRGB(200, 200, 200)
        button.Font = Enum.Font.GothamBlack
        button.TextSize = 12
        button.AutoButtonColor = false
        button.Parent = modeRow

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = button

        button.MouseButton1Click:Connect(function()
            Speed.Settings.Mode = mode
            refreshModes()
        end)

        modeButtons[mode] = button
    end

    createModeButton("Humanoid", 0)
    createModeButton("CFrame", 0.52)
    refreshModes()

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, 0, 0, 20)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed"
    speedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextSize = 11
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = content

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 30)
    input.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    input.BorderSizePixel = 0
    input.Text = tostring(Speed.Settings.Speed)
    input.PlaceholderText = "1 - 500"
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 12
    input.ClearTextOnFocus = false
    input.Parent = content

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, 0, 0, 30)
    hint.BackgroundTransparency = 1
    hint.Text = "Humanoid sets WalkSpeed. CFrame moves the character directly and ignores game speed checks."
    hint.TextColor3 = Color3.fromRGB(120, 120, 120)
    hint.Font = Enum.Font.GothamMedium
    hint.TextSize = 10
    hint.TextXAlignment = Enum.TextXAlignment.Left
    hint.TextWrapped = true
    hint.Parent = content

    input.FocusLost:Connect(function()
        local value = tonumber(input.Text)
        if value then
            Speed.Settings.Speed = math.clamp(value, 1, 500)
        end
        input.Text = tostring(Speed.Settings.Speed)

        if Speed.Enabled then
            local target = player or game.Players.LocalPlayer
            if Speed.Settings.Mode == "Humanoid" then
                applyHumanoid(target)
            else
                applyCFrame(target, 0)
            end
        end
    end)
end

return Speed
