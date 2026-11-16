local Trail = {}

Trail.Settings = {
    Color = Color3.fromRGB(80, 140, 255),
    Lifetime = 0.4,
    Keybind = nil
}

Trail.Enabled = false
Trail.Instance = nil
Trail.CharacterConnection = nil

local function removeTrail()
    if Trail.Instance then
        Trail.Instance.Trail:Destroy()
        Trail.Instance.Attachment0:Destroy()
        Trail.Instance.Attachment1:Destroy()
        Trail.Instance = nil
    end
end

local function createTrail(player)
    removeTrail()

    local character = player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local attachment0 = Instance.new("Attachment")
    attachment0.Name = "ScriptHubTrailAttachment0"
    attachment0.Position = Vector3.new(0, 1.6, 0)
    attachment0.Parent = root

    local attachment1 = Instance.new("Attachment")
    attachment1.Name = "ScriptHubTrailAttachment1"
    attachment1.Position = Vector3.new(0, -1.6, 0)
    attachment1.Parent = root

    local trail = Instance.new("Trail")
    trail.Name = "ScriptHubTrail"
    trail.Attachment0 = attachment0
    trail.Attachment1 = attachment1
    trail.Lifetime = Trail.Settings.Lifetime
    trail.MinLength = 0.1
    trail.WidthScale = NumberSequence.new(1)
    trail.Color = ColorSequence.new(Trail.Settings.Color)
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.LightEmission = 1
    trail.FaceCamera = true
    trail.Parent = root

    Trail.Instance = {
        Trail = trail,
        Attachment0 = attachment0,
        Attachment1 = attachment1
    }
end

function Trail.Start(player)
    if Trail.Enabled then return end
    Trail.Enabled = true

    createTrail(player)

    Trail.CharacterConnection = player.CharacterAdded:Connect(function()
        if not Trail.Enabled then return end
        task.wait(0.5)
        createTrail(player)
    end)
end

function Trail.Stop()
    Trail.Enabled = false

    if Trail.CharacterConnection then
        Trail.CharacterConnection:Disconnect()
        Trail.CharacterConnection = nil
    end

    removeTrail()
end

function Trail.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Trail color"
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content

    local colors = {
        { Name = "Blue", Color = Color3.fromRGB(80, 140, 255) },
        { Name = "Red", Color = Color3.fromRGB(255, 60, 60) },
        { Name = "Green", Color = Color3.fromRGB(60, 255, 120) },
        { Name = "Purple", Color = Color3.fromRGB(180, 80, 255) },
        { Name = "Yellow", Color = Color3.fromRGB(255, 220, 60) },
        { Name = "White", Color = Color3.fromRGB(255, 255, 255) }
    }

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = content

    local buttons = {}

    local function updateButtons()
        for _, data in ipairs(buttons) do
            if Trail.Settings.Color == data.Color then
                data.Button.BackgroundColor3 = data.Color
                data.Button.TextColor3 = Color3.new(0, 0, 0)
            else
                data.Button.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                data.Button.TextColor3 = data.Color
            end
        end
    end

    for index, data in ipairs(colors) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 20, 0, 20)
        button.Position = UDim2.new(0, (index - 1) * 25, 0, 5)
        button.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        button.BorderSizePixel = 0
        button.Text = ""
        button.AutoButtonColor = false
        button.Parent = container

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = button

        local stroke = Instance.new("UIStroke")
        stroke.Color = data.Color
        stroke.Thickness = 1.5
        stroke.Parent = button

        button.MouseButton1Click:Connect(function()
            Trail.Settings.Color = data.Color
            updateButtons()
            if Trail.Instance then
                Trail.Instance.Trail.Color = ColorSequence.new(data.Color)
            end
        end)

        table.insert(buttons, { Button = button, Color = data.Color })
    end

    updateButtons()

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, 0, 0, 20)
    hint.BackgroundTransparency = 1
    hint.Text = "Uses a plain Trail, no particles"
    hint.TextColor3 = Color3.fromRGB(120, 120, 120)
    hint.Font = Enum.Font.GothamMedium
    hint.TextSize = 10
    hint.TextXAlignment = Enum.TextXAlignment.Left
    hint.Parent = content
end

return Trail
