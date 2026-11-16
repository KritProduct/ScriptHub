local PlayerESP = {}

PlayerESP.Settings = {
    Box = true,
    Name = true,
    Distance = true,
    Health = true,
    Tracer = true,
    Highlight = false,
    TeamCheck = false,
    MaxDistance = 1000,
    Color = Color3.fromRGB(80, 140, 255),
    Keybind = nil
}

PlayerESP.Enabled = false
PlayerESP.Connection = nil
PlayerESP.States = {}
PlayerESP.PlayerRemovedConnection = nil

local Players = game:GetService("Players")

local function destroyDrawing(object)
    if not object then return end
    pcall(function() object:Remove() end)
    pcall(function() object:Destroy() end)
end

local function hasDrawing()
    return Drawing ~= nil
end

local function createState()
    local state = {}

    state.Box = Drawing.new("Square")
    state.Box.Filled = false
    state.Box.Thickness = 1
    state.Box.Transparency = 1

    state.NameText = Drawing.new("Text")
    state.NameText.Center = true
    state.NameText.Outline = true
    state.NameText.Size = 13
    state.NameText.Transparency = 1

    state.DistanceText = Drawing.new("Text")
    state.DistanceText.Center = true
    state.DistanceText.Outline = true
    state.DistanceText.Size = 12
    state.DistanceText.Transparency = 1

    state.HealthBack = Drawing.new("Square")
    state.HealthBack.Filled = true
    state.HealthBack.Thickness = 1
    state.HealthBack.Color = Color3.fromRGB(20, 20, 20)
    state.HealthBack.Transparency = 1

    state.HealthFill = Drawing.new("Square")
    state.HealthFill.Filled = true
    state.HealthFill.Thickness = 1
    state.HealthFill.Transparency = 1

    state.Tracer = Drawing.new("Line")
    state.Tracer.Thickness = 1
    state.Tracer.Transparency = 1

    state.Character = nil
    state.Highlight = nil

    return state
end

local function hideState(state)
    state.Box.Visible = false
    state.NameText.Visible = false
    state.DistanceText.Visible = false
    state.HealthBack.Visible = false
    state.HealthFill.Visible = false
    state.Tracer.Visible = false

    if state.Highlight then
        state.Highlight.Enabled = false
    end
end

local function removeState(target)
    local state = PlayerESP.States[target]
    if not state then return end

    destroyDrawing(state.Box)
    destroyDrawing(state.NameText)
    destroyDrawing(state.DistanceText)
    destroyDrawing(state.HealthBack)
    destroyDrawing(state.HealthFill)
    destroyDrawing(state.Tracer)

    if state.Highlight then
        state.Highlight:Destroy()
    end

    PlayerESP.States[target] = nil
end

local function getHealthColor(healthPercent)
    local red = math.floor(255 * (1 - healthPercent))
    local green = math.floor(255 * healthPercent)
    return Color3.fromRGB(red, green, 40)
end

function PlayerESP.Start(player)
    local RunService = game:GetService("RunService")

    if not hasDrawing() then
        PlayerESP.Enabled = true
        return
    end

    if PlayerESP.Enabled then return end
    PlayerESP.Enabled = true

    PlayerESP.PlayerRemovedConnection = Players.PlayerRemoving:Connect(function(leavingPlayer)
        removeState(leavingPlayer)
    end)

    PlayerESP.Connection = RunService.RenderStepped:Connect(function()
        if not PlayerESP.Enabled then return end

        local camera = workspace.CurrentCamera
        if not camera then return end

        local viewport = camera.ViewportSize

        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= player then
                local sameTeam = PlayerESP.Settings.TeamCheck and player.Team ~= nil and target.Team == player.Team
                local character = target.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local root = character and character:FindFirstChild("HumanoidRootPart")
                local head = character and (character:FindFirstChild("Head") or root)

                if not sameTeam and character and humanoid and humanoid.Health > 0 and root and head then
                    local state = PlayerESP.States[target]
                    if not state then
                        state = createState()
                        PlayerESP.States[target] = state
                    end

                    local color = PlayerESP.Settings.Color

                    if state.Character ~= character then
                        if state.Highlight then
                            state.Highlight:Destroy()
                            state.Highlight = nil
                        end
                        state.Character = character
                    end

                    if PlayerESP.Settings.Highlight then
                        if not state.Highlight then
                            local highlight = Instance.new("Highlight")
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            highlight.FillTransparency = 0.5
                            highlight.Parent = character
                            state.Highlight = highlight
                        end

                        state.Highlight.FillColor = color
                        state.Highlight.OutlineColor = color
                        state.Highlight.Enabled = true
                    elseif state.Highlight then
                        state.Highlight.Enabled = false
                    end

                    local distance = (camera.CFrame.Position - root.Position).Magnitude
                    local visible = false
                    local topScreen = Vector2.new()
                    local bottomScreen = Vector2.new()

                    if distance <= PlayerESP.Settings.MaxDistance then
                        local topPosition = head.Position + Vector3.new(0, 0.6, 0)
                        local bottomPosition = root.Position - Vector3.new(0, 3, 0)
                        local topPoint, topOnScreen = camera:WorldToViewportPoint(topPosition)
                        local bottomPoint, bottomOnScreen = camera:WorldToViewportPoint(bottomPosition)

                        if topOnScreen and bottomOnScreen then
                            local height = bottomPoint.Y - topPoint.Y
                            if height > 0 then
                                visible = true
                                topScreen = Vector2.new(topPoint.X, topPoint.Y)
                                bottomScreen = Vector2.new(bottomPoint.X, bottomPoint.Y)
                            end
                        end
                    end

                    if visible then
                        local height = bottomScreen.Y - topScreen.Y
                        local width = math.clamp(height * 0.55, 4, 1000)
                        local centerX = (topScreen.X + bottomScreen.X) / 2
                        local left = centerX - width / 2
                        local top = topScreen.Y

                        state.Box.Visible = PlayerESP.Settings.Box
                        state.Box.Color = color
                        state.Box.Position = Vector2.new(left, top)
                        state.Box.Size = Vector2.new(width, height)

                        state.NameText.Visible = PlayerESP.Settings.Name
                        state.NameText.Text = target.Name
                        state.NameText.Color = color
                        state.NameText.Position = Vector2.new(centerX, top - 18)

                        state.DistanceText.Visible = PlayerESP.Settings.Distance
                        state.DistanceText.Text = tostring(math.floor(distance)) .. "m"
                        state.DistanceText.Color = color
                        state.DistanceText.Position = Vector2.new(centerX, top + height + 2)

                        local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local barHeight = height
                        local barX = left - 5

                        state.HealthBack.Visible = PlayerESP.Settings.Health
                        state.HealthBack.Position = Vector2.new(barX, top)
                        state.HealthBack.Size = Vector2.new(3, barHeight)

                        state.HealthFill.Visible = PlayerESP.Settings.Health
                        state.HealthFill.Color = getHealthColor(healthPercent)
                        state.HealthFill.Position = Vector2.new(barX, top + barHeight * (1 - healthPercent))
                        state.HealthFill.Size = Vector2.new(3, barHeight * healthPercent)

                        state.Tracer.Visible = PlayerESP.Settings.Tracer
                        state.Tracer.Color = color
                        state.Tracer.From = Vector2.new(viewport.X / 2, viewport.Y)
                        state.Tracer.To = Vector2.new(centerX, bottomScreen.Y)
                    else
                        hideState(state)
                    end
                else
                    local state = PlayerESP.States[target]
                    if state then
                        hideState(state)
                    end
                end
            end
        end
    end)
end

function PlayerESP.Stop()
    PlayerESP.Enabled = false

    if PlayerESP.Connection then
        PlayerESP.Connection:Disconnect()
        PlayerESP.Connection = nil
    end

    if PlayerESP.PlayerRemovedConnection then
        PlayerESP.PlayerRemovedConnection:Disconnect()
        PlayerESP.PlayerRemovedConnection = nil
    end

    for target in pairs(PlayerESP.States) do
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

local function createColorPicker(parent, colors, getColor, setColor)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local buttons = {}

    local function updateButtons()
        for _, data in ipairs(buttons) do
            if getColor() == data.Color then
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
            setColor(data.Color)
            updateButtons()
        end)

        table.insert(buttons, { Button = button, Color = data.Color })
    end

    updateButtons()
end

function PlayerESP.BuildSettings(content)
    local colors = {
        { Color = Color3.fromRGB(80, 140, 255) },
        { Color = Color3.fromRGB(255, 60, 60) },
        { Color = Color3.fromRGB(60, 255, 120) },
        { Color = Color3.fromRGB(255, 255, 255) },
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
    colorLabel.Text = "ESP color"
    colorLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    colorLabel.Font = Enum.Font.GothamBold
    colorLabel.TextSize = 11
    colorLabel.TextXAlignment = Enum.TextXAlignment.Left
    colorLabel.Parent = content

    createColorPicker(content, colors, function()
        return PlayerESP.Settings.Color
    end, function(color)
        PlayerESP.Settings.Color = color
    end)

    createToggle(content, "Box", PlayerESP.Settings.Box, function(value)
        PlayerESP.Settings.Box = value
    end)

    createToggle(content, "Health Bar", PlayerESP.Settings.Health, function(value)
        PlayerESP.Settings.Health = value
    end)

    createToggle(content, "Name", PlayerESP.Settings.Name, function(value)
        PlayerESP.Settings.Name = value
    end)

    createToggle(content, "Distance", PlayerESP.Settings.Distance, function(value)
        PlayerESP.Settings.Distance = value
    end)

    createToggle(content, "Tracer", PlayerESP.Settings.Tracer, function(value)
        PlayerESP.Settings.Tracer = value
    end)

    createToggle(content, "Highlight", PlayerESP.Settings.Highlight, function(value)
        PlayerESP.Settings.Highlight = value
    end)

    createToggle(content, "Team Check", PlayerESP.Settings.TeamCheck, function(value)
        PlayerESP.Settings.TeamCheck = value
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
    distanceInput.Text = tostring(PlayerESP.Settings.MaxDistance)
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
            PlayerESP.Settings.MaxDistance = math.clamp(value, 100, 10000)
        end
        distanceInput.Text = tostring(PlayerESP.Settings.MaxDistance)
    end)
end

return PlayerESP
