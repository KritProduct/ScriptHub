local Aimbot = {}

Aimbot.Settings = {
    FOV = 150,
    Smoothing = 0.25,
    WallCheck = true,
    TargetNPCs = false,
    Prediction = false,
    BulletSpeed = 1500,
    ShowFOV = false,
    Keybind = nil
}

Aimbot.Enabled = false
Aimbot.Connection = nil
Aimbot.FOVCircle = nil
Aimbot.TrackedNPCs = {}
Aimbot.VisibilityCache = {}

local MIN_BULLET_SPEED = 1

function Aimbot.GetVisibility(targetId, character, rayParams)
    local currentTime = tick()

    if Aimbot.VisibilityCache[targetId] and (currentTime - Aimbot.VisibilityCache[targetId].lastUpdate) < 0.1 then
        return Aimbot.VisibilityCache[targetId].isVisible
    end

    local cam = workspace.CurrentCamera
    if not cam then return false end

    local partsToCheck = {
        character:FindFirstChild("Head"),
        character:FindFirstChild("HumanoidRootPart"),
        character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm"),
        character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm"),
        character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg"),
        character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftUpperLeg")
    }

    local origin = cam.CFrame.Position
    local isVisible = false

    for _, part in pairs(partsToCheck) do
        if part and part:IsA("BasePart") then
            local result = workspace:Raycast(origin, part.Position - origin, rayParams)
            if result and result.Instance:IsDescendantOf(character) then
                isVisible = true
                break
            end
        end
    end

    Aimbot.VisibilityCache[targetId] = { isVisible = isVisible, lastUpdate = currentTime }
    return isVisible
end

function Aimbot.GetClosestTarget(player, rayParams)
    if not Aimbot.Enabled then return nil end

    local cam = workspace.CurrentCamera
    if not cam then return nil end

    local target = nil
    local shortestDistance = Aimbot.Settings.FOV
    local mousePos = game:GetService("UserInputService"):GetMouseLocation()

    local function CheckTarget(entityId, character)
        local aimPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
        if not aimPart then return end

        local screenPos, onScreen = cam:WorldToViewportPoint(aimPart.Position)
        if onScreen then
            local distanceToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if distanceToMouse < shortestDistance then
                if Aimbot.Settings.WallCheck then
                    if Aimbot.GetVisibility(entityId, character, rayParams) then
                        target = aimPart
                        shortestDistance = distanceToMouse
                    end
                else
                    target = aimPart
                    shortestDistance = distanceToMouse
                end
            end
        end
    end

    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            if otherPlayer.Team ~= player.Team or otherPlayer.Team == nil then
                CheckTarget(tostring(otherPlayer.UserId), otherPlayer.Character)
            end
        end
    end

    if Aimbot.Settings.TargetNPCs then
        for npc in pairs(Aimbot.TrackedNPCs) do
            if npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart") then
                CheckTarget(npc, npc)
            end
        end
    end

    return target
end

function Aimbot.IsNPC(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    if game.Players:GetPlayerFromCharacter(model) then return false end
    return true
end

function Aimbot.UpdateFOVCircle()
    if Aimbot.FOVCircle then
        Aimbot.FOVCircle:Destroy()
        Aimbot.FOVCircle = nil
    end

    if not Aimbot.Settings.ShowFOV then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FOVCircle"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = game.CoreGui

    local fovRadius = Aimbot.Settings.FOV

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    circle.Position = UDim2.new(0, 0, 0, 0)
    circle.BackgroundTransparency = 1
    circle.ZIndex = 9999
    circle.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = circle

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0
    stroke.Parent = circle

    Aimbot.FOVCircle = gui
end

function Aimbot.Start(player)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    Aimbot.Enabled = true

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local function refreshRayFilter()
        local list = {}
        local char = player.Character
        local cam = workspace.CurrentCamera
        if char then table.insert(list, char) end
        if cam then table.insert(list, cam) end
        rayParams.FilterDescendantsInstances = list
    end

    task.spawn(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                if Aimbot.IsNPC(obj) then
                    Aimbot.TrackedNPCs[obj] = true
                end
            end
            if _ % 500 == 0 then task.wait() end
        end
    end)

    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            task.delay(0.5, function()
                if Aimbot.IsNPC(obj) then
                    Aimbot.TrackedNPCs[obj] = true
                end
            end)
        end
    end)

    workspace.DescendantRemoving:Connect(function(obj)
        if Aimbot.TrackedNPCs[obj] then
            Aimbot.TrackedNPCs[obj] = nil
        end
    end)

    Aimbot.Connection = RunService.RenderStepped:Connect(function()
        if not Aimbot.Enabled then return end
        if not player.Character then return end

        local cam = workspace.CurrentCamera
        if not cam then return end

        refreshRayFilter()

        local mousePos = UserInputService:GetMouseLocation()

        if Aimbot.FOVCircle then
            local circle = Aimbot.FOVCircle:FindFirstChildOfClass("Frame")
            if circle then
                local fovRadius = Aimbot.Settings.FOV
                circle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
                circle.Position = UDim2.new(0, mousePos.X - fovRadius, 0, mousePos.Y - fovRadius)
            end
        end

        if Aimbot.Settings.ShowFOV ~= (Aimbot.FOVCircle ~= nil) then
            Aimbot.UpdateFOVCircle()
        end

        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local aimTarget = Aimbot.GetClosestTarget(player, rayParams)
            if aimTarget and mousemoverel then
                local aimPos = aimTarget.Position

                if Aimbot.Settings.Prediction then
                    local d = (aimPos - cam.CFrame.Position).Magnitude
                    local speed = math.max(Aimbot.Settings.BulletSpeed, MIN_BULLET_SPEED)
                    aimPos = aimPos + (aimTarget.AssemblyLinearVelocity * (d / speed))
                end

                local screenPos, onScreen = cam:WorldToViewportPoint(aimPos)
                if onScreen then
                    local moveX = (screenPos.X - mousePos.X) * Aimbot.Settings.Smoothing
                    local moveY = (screenPos.Y - mousePos.Y) * Aimbot.Settings.Smoothing
                    mousemoverel(moveX, moveY)
                end
            end
        end
    end)
end

function Aimbot.Stop()
    Aimbot.Enabled = false

    if Aimbot.Connection then
        Aimbot.Connection:Disconnect()
        Aimbot.Connection = nil
    end

    if Aimbot.FOVCircle then
        Aimbot.FOVCircle:Destroy()
        Aimbot.FOVCircle = nil
    end
end

function Aimbot.BuildSettings(content)
    local function createSlider(min, max, increment, current, callback, name)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 50)
        container.BackgroundTransparency = 1
        container.Parent = content

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name .. ": " .. current
        nameLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = container

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, 0, 0, 6)
        track.Position = UDim2.new(0, 0, 0, 28)
        track.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        track.BorderSizePixel = 0
        track.Parent = container

        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(0, 3)
        trackCorner.Parent = track

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 0, 6)
        fill.Position = UDim2.new(0, 0, 0, 28)
        fill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
        fill.BorderSizePixel = 0
        fill.Parent = container

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 3)
        fillCorner.Parent = fill

        local function updateVisual(value)
            local percent = (value - min) / (max - min)
            fill.Size = UDim2.new(0, percent * track.AbsoluteSize.X, 0, 6)
            nameLabel.Text = name .. ": " .. value
        end

        updateVisual(current)

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
                    local value = min + percent * (max - min)
                    value = math.floor(value / increment + 0.5) * increment
                    callback(value)
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
    end

    local function createToggle(text, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 30)
        container.BackgroundTransparency = 1
        container.Parent = content

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
        dot.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
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
                dot.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
            end
        end

        updateToggle()

        toggle.MouseButton1Click:Connect(function()
            enabled = not enabled
            updateToggle()
            callback(enabled)
        end)
    end

    createSlider(0.1, 1, 0.05, Aimbot.Settings.Smoothing, function(v)
        Aimbot.Settings.Smoothing = v
    end, "Smoothing")

    createSlider(50, 800, 10, Aimbot.Settings.FOV, function(v)
        Aimbot.Settings.FOV = v
    end, "FOV Radius")

    createToggle("Wall Check", Aimbot.Settings.WallCheck, function(v)
        Aimbot.Settings.WallCheck = v
    end)

    createToggle("Target NPCs", Aimbot.Settings.TargetNPCs, function(v)
        Aimbot.Settings.TargetNPCs = v
    end)

    createToggle("Prediction", Aimbot.Settings.Prediction, function(v)
        Aimbot.Settings.Prediction = v
    end)

    createSlider(100, 5000, 100, Aimbot.Settings.BulletSpeed, function(v)
        Aimbot.Settings.BulletSpeed = v
    end, "Bullet Speed")

    createToggle("Show FOV Circle", Aimbot.Settings.ShowFOV, function(v)
        Aimbot.Settings.ShowFOV = v
        Aimbot.UpdateFOVCircle()
    end)
end

return Aimbot
