local SkeletonESP = {}

SkeletonESP.Settings = {
    Color = Color3.fromRGB(255, 255, 255),
    TeamCheck = false,
    MaxDistance = 1000,
    Keybind = nil
}

SkeletonESP.Enabled = false
SkeletonESP.Connection = nil
SkeletonESP.States = {}
SkeletonESP.PlayerRemovedConnection = nil

local Players = game:GetService("Players")

local function destroyDrawing(object)
    if not object then return end
    pcall(function() object:Remove() end)
    pcall(function() object:Destroy() end)
end

local R15_BONES = {
    { "Head", "UpperTorso" },
    { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" },
    { "LeftUpperArm", "LeftLowerArm" },
    { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" },
    { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" },
    { "LeftUpperLeg", "LeftLowerLeg" },
    { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" },
    { "RightLowerLeg", "RightFoot" }
}

local R6_BONES = {
    { "Head", "Torso" },
    { "Torso", "Left Arm" },
    { "Torso", "Right Arm" },
    { "Torso", "Left Leg" },
    { "Torso", "Right Leg" }
}

local function hasDrawing()
    return Drawing ~= nil
end

local function createState(boneCount)
    local state = {
        Lines = {},
        Character = nil
    }

    for index = 1, boneCount do
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Transparency = 1
        line.Visible = false
        state.Lines[index] = line
    end

    return state
end

local function removeState(target)
    local state = SkeletonESP.States[target]
    if not state then return end

    for _, line in ipairs(state.Lines) do
        destroyDrawing(line)
    end

    SkeletonESP.States[target] = nil
end

local function hideState(state)
    for _, line in ipairs(state.Lines) do
        line.Visible = false
    end
end

function SkeletonESP.Start(player)
    local RunService = game:GetService("RunService")

    if not hasDrawing() then
        SkeletonESP.Enabled = true
        return
    end

    if SkeletonESP.Enabled then return end
    SkeletonESP.Enabled = true

    SkeletonESP.PlayerRemovedConnection = Players.PlayerRemoving:Connect(function(leavingPlayer)
        removeState(leavingPlayer)
    end)

    SkeletonESP.Connection = RunService.RenderStepped:Connect(function()
        if not SkeletonESP.Enabled then return end

        local camera = workspace.CurrentCamera
        if not camera then return end

        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= player then
                local sameTeam = SkeletonESP.Settings.TeamCheck and player.Team ~= nil and target.Team == player.Team
                local character = target.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local root = character and character:FindFirstChild("HumanoidRootPart")

                if not sameTeam and character and humanoid and humanoid.Health > 0 and root then
                    local bones
                    if character:FindFirstChild("UpperTorso") then
                        bones = R15_BONES
                    else
                        bones = R6_BONES
                    end

                    local state = SkeletonESP.States[target]
                    if state and #state.Lines ~= #bones then
                        removeState(target)
                        state = nil
                    end
                    if not state then
                        state = createState(#bones)
                        SkeletonESP.States[target] = state
                    end

                    local distance = (camera.CFrame.Position - root.Position).Magnitude
                    local color = SkeletonESP.Settings.Color

                    if distance > SkeletonESP.Settings.MaxDistance then
                        hideState(state)
                    else
                        for index, bone in ipairs(bones) do
                            local line = state.Lines[index]
                            local partA = character:FindFirstChild(bone[1])
                            local partB = character:FindFirstChild(bone[2])

                            if partA and partB then
                                local pointA, onScreenA = camera:WorldToViewportPoint(partA.Position)
                                local pointB, onScreenB = camera:WorldToViewportPoint(partB.Position)

                                if onScreenA and onScreenB then
                                    line.Visible = true
                                    line.Color = color
                                    line.From = Vector2.new(pointA.X, pointA.Y)
                                    line.To = Vector2.new(pointB.X, pointB.Y)
                                else
                                    line.Visible = false
                                end
                            else
                                line.Visible = false
                            end
                        end
                    end
                else
                    local state = SkeletonESP.States[target]
                    if state then
                        hideState(state)
                    end
                end
            end
        end
    end)
end

function SkeletonESP.Stop()
    SkeletonESP.Enabled = false

    if SkeletonESP.Connection then
        SkeletonESP.Connection:Disconnect()
        SkeletonESP.Connection = nil
    end

    if SkeletonESP.PlayerRemovedConnection then
        SkeletonESP.PlayerRemovedConnection:Disconnect()
        SkeletonESP.PlayerRemovedConnection = nil
    end

    for target in pairs(SkeletonESP.States) do
        removeState(target)
    end
end

local function createToggle(parent, text, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

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

function SkeletonESP.BuildSettings(content)
    local colors = {
        { Color = Color3.fromRGB(255, 255, 255) },
        { Color = Color3.fromRGB(80, 140, 255) },
        { Color = Color3.fromRGB(255, 60, 60) },
        { Color = Color3.fromRGB(60, 255, 120) },
        { Color = Color3.fromRGB(180, 80, 255) },
        { Color = Color3.fromRGB(255, 220, 60) }
    }

    if not hasDrawing() then
        local warning = Instance.new("TextLabel")
        warning.Size = UDim2.new(1, 0, 0, 34)
        warning.BackgroundTransparency = 1
        warning.Text = "Drawing API is not supported by this executor"
        warning.TextColor3 = Color3.fromRGB(255, 80, 80)
        warning.Font = Enum.Font.GothamBold
        warning.TextSize = 11
        warning.TextXAlignment = Enum.TextXAlignment.Left
        warning.TextWrapped = true
        warning.Parent = content
        return
    end

    local colorLabel = Instance.new("TextLabel")
    colorLabel.Size = UDim2.new(1, 0, 0, 20)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Text = "Skeleton color"
    colorLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    colorLabel.Font = Enum.Font.GothamBold
    colorLabel.TextSize = 11
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.Parent = content

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = content

    local buttons = {}

    local function updateButtons()
        for _, data in ipairs(buttons) do
            if SkeletonESP.Settings.Color == data.Color then
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
            SkeletonESP.Settings.Color = data.Color
            updateButtons()
        end)

        table.insert(buttons, { Button = button, Color = data.Color })
    end

    updateButtons()

    createToggle(content, "Team Check", SkeletonESP.Settings.TeamCheck, function(value)
        SkeletonESP.Settings.TeamCheck = value
    end)

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0, 20)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "Max distance (studs)"
    distanceLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    distanceLabel.Font = Enum.Font.GothamBold
    distanceLabel.TextSize = 11
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    distanceLabel.Parent = content

    local distanceInput = Instance.new("TextBox")
    distanceInput.Size = UDim2.new(1, 0, 0, 30)
    distanceInput.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    distanceInput.BorderSizePixel = 0
    distanceInput.Text = tostring(SkeletonESP.Settings.MaxDistance)
    distanceInput.PlaceholderText = "100 - 10000"
    distanceInput.TextColor3 = Color3.new(1, 1, 1)
    distanceInput.Font = Enum.Font.GothamBold
    distanceInput.TextSize = 12
    distanceInput.ClearTextOnFocus = false
    distanceInput.Parent = content

    local distanceCorner = Instance.new("UICorner")
    distanceCorner.CornerRadius = UDim.new(0, 6)
    distanceCorner.Parent = distanceInput

    distanceInput.FocusLost:Connect(function()
        local value = tonumber(distanceInput.Text)
        if value then
            SkeletonESP.Settings.MaxDistance = math.clamp(value, 100, 10000)
        end
        distanceInput.Text = tostring(SkeletonESP.Settings.MaxDistance)
    end)
end

return SkeletonESP
