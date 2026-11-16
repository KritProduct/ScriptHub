local TriggerBot = {}

TriggerBot.Settings = {
    Delay = 0,
    AimPart = "Torso",
    Keybind = nil
}

TriggerBot.Enabled = false
TriggerBot.Connection = nil
TriggerBot.LastAttack = 0
TriggerBot.Status = nil

local PART_GROUPS = {
    Head = {
        ["Head"] = true
    },
    Torso = {
        ["Torso"] = true,
        ["UpperTorso"] = true,
        ["LowerTorso"] = true,
        ["Left Arm"] = true,
        ["Right Arm"] = true,
        ["LeftUpperArm"] = true,
        ["RightUpperArm"] = true,
        ["LeftLowerArm"] = true,
        ["RightLowerArm"] = true,
        ["LeftHand"] = true,
        ["RightHand"] = true
    },
    Legs = {
        ["Left Leg"] = true,
        ["Right Leg"] = true,
        ["LeftUpperLeg"] = true,
        ["RightUpperLeg"] = true,
        ["LeftLowerLeg"] = true,
        ["RightLowerLeg"] = true,
        ["LeftFoot"] = true,
        ["RightFoot"] = true
    }
}

local RAY_LENGTH = 2000

function TriggerBot.BuildIgnoreList(player)
    local ignore = {}
    local char = player.Character

    if char then
        table.insert(ignore, char)
    end

    for _, other in ipairs(game.Players:GetPlayers()) do
        if other ~= player and other.Character then
            for _, descendant in ipairs(other.Character:GetDescendants()) do
                if descendant:IsA("Accessory") or descendant:IsA("Accoutrement") then
                    table.insert(ignore, descendant)
                end
            end
        end
    end

    return ignore
end

function TriggerBot.FindTarget(player, camera, ignore)
    local group = PART_GROUPS[TriggerBot.Settings.AimPart] or PART_GROUPS.Torso
    local origin = camera.CFrame.Position
    local direction = camera.CFrame.LookVector * RAY_LENGTH
    local unit = direction.Unit
    local skipped = {}

    for _ = 1, 12 do
        local filter = {}

        for _, item in ipairs(ignore) do
            table.insert(filter, item)
        end

        for _, item in ipairs(skipped) do
            table.insert(filter, item)
        end

        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = filter
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.IgnoreWater = true
        raycastParams.RespectCanCollide = false

        local result = workspace:Raycast(origin, direction, raycastParams)

        if not result or not result.Instance then
            return nil
        end

        local instance = result.Instance
        local owner = nil

        for _, other in ipairs(game.Players:GetPlayers()) do
            if other ~= player and other.Character and instance:IsDescendantOf(other.Character) then
                owner = other
                break
            end
        end

        if not owner then
            return nil
        end

        if group[instance.Name] and instance:IsA("BasePart") then
            return instance, owner
        end

        if #skipped >= 11 then
            return nil
        end

        table.insert(skipped, instance)
        origin = result.Position + unit * 0.05
    end

    return nil
end

function TriggerBot.Start(player)
    if TriggerBot.Enabled then return end

    TriggerBot.Enabled = true
    TriggerBot.LastAttack = 0

    local lastStatus = nil
    local ignoreList = nil
    local ignoreTime = 0

    local function setStatus(text, color)
        if lastStatus == text then return end
        lastStatus = text

        if TriggerBot.Status and TriggerBot.Status.Parent then
            TriggerBot.Status.Text = text
            TriggerBot.Status.TextColor3 = color or Color3.fromRGB(160, 160, 160)
        end
    end

    local function getIgnoreList()
        local now = os.clock()

        if not ignoreList or now - ignoreTime > 0.5 then
            ignoreList = TriggerBot.BuildIgnoreList(player)
            ignoreTime = now
        end

        return ignoreList
    end

    local function clickMouse()
        pcall(function()
            mouse1press()
            task.wait(0.005)
            mouse1release()
        end)
    end

    local function scan()
        local cam = workspace.CurrentCamera
        if not cam then return end

        local ignore = getIgnoreList()
        local part, owner = TriggerBot.FindTarget(player, cam, ignore)

        if part and owner then
            local humanoid = owner.Character and owner.Character:FindFirstChild("Humanoid")

            if humanoid and humanoid.Health > 0 then
                local isFriend = false

                if TriggerBot.Settings.FriendCheck then
                    if player.Team and owner.Team and player.Team == owner.Team then
                        isFriend = true
                    end

                    if owner:IsFriendsWith(player.UserId) then
                        isFriend = true
                    end
                end

                if not isFriend then
                    clickMouse()
                    TriggerBot.LastAttack = os.clock()
                    setStatus("Firing at " .. part.Name, Color3.fromRGB(60, 255, 120))
                    return
                end
            end
        end

        if os.clock() - TriggerBot.LastAttack > 0.2 then
            setStatus("Status: crosshair not on " .. string.lower(TriggerBot.Settings.AimPart), Color3.fromRGB(255, 160, 60))
        end
    end

    setStatus("Status: waiting", Color3.fromRGB(160, 160, 160))

    task.spawn(function()
        while TriggerBot.Enabled do
            pcall(scan)
            task.wait(math.max(TriggerBot.Settings.Delay, 30) / 1000)
        end
    end)
end

function TriggerBot.Stop()
    TriggerBot.Enabled = false

    if TriggerBot.Connection then
        TriggerBot.Connection:Disconnect()
        TriggerBot.Connection = nil
    end

    if TriggerBot.Status and TriggerBot.Status.Parent then
        TriggerBot.Status.Text = "Status: off"
        TriggerBot.Status.TextColor3 = Color3.fromRGB(160, 160, 160)
    end
end

function TriggerBot.BuildSettings(content)
    local delayLabel = Instance.new("TextLabel")
    delayLabel.Size = UDim2.new(1, 0, 0, 20)
    delayLabel.BackgroundTransparency = 1
    delayLabel.Text = "Delay before each shot (ms)"
    delayLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    delayLabel.Font = Enum.Font.GothamBold
    delayLabel.TextSize = 11
    delayLabel.TextXAlignment = Enum.TextXAlignment.Left
    delayLabel.Parent = content

    local delayInput = Instance.new("TextBox")
    delayInput.Size = UDim2.new(1, 0, 0, 30)
    delayInput.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    delayInput.BorderSizePixel = 0
    delayInput.Text = tostring(TriggerBot.Settings.Delay)
    delayInput.PlaceholderText = "0 - 500"
    delayInput.TextColor3 = Color3.new(1, 1, 1)
    delayInput.Font = Enum.Font.GothamBold
    delayInput.TextSize = 12
    delayInput.ClearTextOnFocus = false
    delayInput.Parent = content

    local delayCorner = Instance.new("UICorner")
    delayCorner.CornerRadius = UDim.new(0, 6)
    delayCorner.Parent = delayInput

    delayInput.FocusLost:Connect(function()
        local value = tonumber(delayInput.Text)

        if value then
            TriggerBot.Settings.Delay = math.clamp(value, 0, 500)
        end

        delayInput.Text = tostring(TriggerBot.Settings.Delay)
    end)

    local partLabel = Instance.new("TextLabel")
    partLabel.Size = UDim2.new(1, 0, 0, 20)
    partLabel.BackgroundTransparency = 1
    partLabel.Text = "Shoot only when the crosshair is on this part"
    partLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    partLabel.Font = Enum.Font.GothamBold
    partLabel.TextSize = 11
    partLabel.TextXAlignment = Enum.TextXAlignment.Left
    partLabel.Parent = content

    local partRow = Instance.new("Frame")
    partRow.Size = UDim2.new(1, 0, 0, 30)
    partRow.BackgroundTransparency = 1
    partRow.Parent = content

    local partButtons = {}

    local function refreshParts()
        for mode, button in pairs(partButtons) do
            if TriggerBot.Settings.AimPart == mode then
                button.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
                button.TextColor3 = Color3.new(1, 1, 1)
            else
                button.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
    end

    local function createPartButton(mode, x, width)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(width, -4, 1, 0)
        button.Position = UDim2.new(x, 0, 0, 0)
        button.Text = mode
        button.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        button.BorderSizePixel = 0
        button.TextColor3 = Color3.fromRGB(200, 200, 200)
        button.Font = Enum.Font.GothamBlack
        button.TextSize = 11
        button.AutoButtonColor = false
        button.Parent = partRow

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = button

        button.MouseButton1Click:Connect(function()
            TriggerBot.Settings.AimPart = mode
            refreshParts()
        end)

        partButtons[mode] = button
    end

    createPartButton("Head", 0, 0.34)
    createPartButton("Torso", 0.34, 0.34)
    createPartButton("Legs", 0.68, 0.34)
    refreshParts()

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 55)
    info.BackgroundTransparency = 1
    info.Text = "Casts a ray from the camera through the crosshair. Shoots only when that ray reaches the selected part of a player and is not blocked by walls or other objects. Minimum interval is 30 ms to keep FPS stable"
    info.TextColor3 = Color3.fromRGB(120, 120, 120)
    info.Font = Enum.Font.GothamMedium
    info.TextSize = 10
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = content

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = TriggerBot.Enabled and "Status: waiting" or "Status: off"
    statusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 11
    statusLabel.TextWrapped = true
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = content

    TriggerBot.Status = statusLabel
end

return TriggerBot
