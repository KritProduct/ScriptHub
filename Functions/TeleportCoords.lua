local TeleportCoords = {}

TeleportCoords.Settings = {
    X = 0,
    Y = 0,
    Z = 0,
    Keybind = nil
}

TeleportCoords.Enabled = false

function TeleportCoords.Start(player)
    TeleportCoords.Enabled = true
end

function TeleportCoords.Stop()
    TeleportCoords.Enabled = false
end

local function createField(content, title, value)
    local field = Instance.new("Frame")
    field.Size = UDim2.new(0.32, -4, 0, 42)
    field.BackgroundTransparency = 1
    field.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = field

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 26)
    input.Position = UDim2.new(0, 0, 0, 16)
    input.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    input.BorderSizePixel = 0
    input.Text = tostring(value)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 11
    input.ClearTextOnFocus = false
    input.Parent = field

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = input

    return input
end

function TeleportCoords.BuildSettings(content)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundTransparency = 1
    row.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 6)
    layout.Parent = row

    local xInput = createField(row, "X", TeleportCoords.Settings.X)
    local yInput = createField(row, "Y", TeleportCoords.Settings.Y)
    local zInput = createField(row, "Z", TeleportCoords.Settings.Z)

    local feedback = Instance.new("TextLabel")
    feedback.Size = UDim2.new(1, 0, 0, 30)
    feedback.BackgroundTransparency = 1
    feedback.Text = ""
    feedback.TextColor3 = Color3.fromRGB(160, 160, 160)
    feedback.Font = Enum.Font.GothamMedium
    feedback.TextSize = 10
    feedback.TextWrapped = true
    feedback.TextXAlignment = Enum.TextXAlignment.Left
    feedback.Parent = content

    local function readPosition()
        local x = tonumber(xInput.Text)
        local y = tonumber(yInput.Text)
        local z = tonumber(zInput.Text)

        if not x or not y or not z then
            feedback.Text = "X, Y and Z must be numbers"
            feedback.TextColor3 = Color3.fromRGB(255, 80, 80)
            return nil
        end

        return Vector3.new(x, y, z)
    end

    local function fillCurrent()
        local player = game.Players.LocalPlayer
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if not root then
            feedback.Text = "Character is not loaded"
            feedback.TextColor3 = Color3.fromRGB(255, 80, 80)
            return
        end

        xInput.Text = string.format("%.1f", root.Position.X)
        yInput.Text = string.format("%.1f", root.Position.Y)
        zInput.Text = string.format("%.1f", root.Position.Z)
        feedback.Text = "Current position filled"
        feedback.TextColor3 = Color3.fromRGB(160, 160, 160)
    end

    local buttonsRow = Instance.new("Frame")
    buttonsRow.Size = UDim2.new(1, 0, 0, 30)
    buttonsRow.BackgroundTransparency = 1
    buttonsRow.Parent = content

    local buttonsLayout = Instance.new("UIListLayout")
    buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonsLayout.Padding = UDim.new(0, 6)
    buttonsLayout.Parent = buttonsRow

    local fillButton = Instance.new("TextButton")
    fillButton.Size = UDim2.new(0.48, -3, 1, 0)
    fillButton.Text = "Use current position"
    fillButton.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    fillButton.BorderSizePixel = 0
    fillButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    fillButton.Font = Enum.Font.GothamBlack
    fillButton.TextSize = 10
    fillButton.AutoButtonColor = false
    fillButton.Parent = buttonsRow

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = fillButton

    local teleportButton = Instance.new("TextButton")
    teleportButton.Size = UDim2.new(0.48, -3, 1, 0)
    teleportButton.Text = "Teleport"
    teleportButton.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    teleportButton.BorderSizePixel = 0
    teleportButton.TextColor3 = Color3.new(1, 1, 1)
    teleportButton.Font = Enum.Font.GothamBlack
    teleportButton.TextSize = 11
    teleportButton.AutoButtonColor = false
    teleportButton.Parent = buttonsRow

    local teleportCorner = Instance.new("UICorner")
    teleportCorner.CornerRadius = UDim.new(0, 6)
    teleportCorner.Parent = teleportButton

    fillButton.MouseButton1Click:Connect(fillCurrent)

    teleportButton.MouseButton1Click:Connect(function()
        local position = readPosition()
        if not position then return end

        local player = game.Players.LocalPlayer
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if not root then
            feedback.Text = "Character is not loaded"
            feedback.TextColor3 = Color3.fromRGB(255, 80, 80)
            return
        end

        TeleportCoords.Settings.X = position.X
        TeleportCoords.Settings.Y = position.Y
        TeleportCoords.Settings.Z = position.Z

        root.CFrame = CFrame.new(position)
        feedback.Text = string.format("Teleported to %.1f, %.1f, %.1f", position.X, position.Y, position.Z)
        feedback.TextColor3 = Color3.fromRGB(60, 255, 120)
    end)
end

return TeleportCoords
