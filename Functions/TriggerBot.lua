local TriggerBot = {}

TriggerBot.Settings = {
    Delay = 0,
    Keybind = nil
}

TriggerBot.Enabled = false
TriggerBot.Connection = nil
TriggerBot.LastAttack = 0
TriggerBot.Status = nil

local AIM_RADIUS = 150

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

function TriggerBot.IsPartVisible(target, camera, part, ignore)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = ignore
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local origin = camera.CFrame.Position
    local result = workspace:Raycast(origin, part.Position - origin, raycastParams)

    if not result or not result.Instance then
        return true
    end

    return result.Instance == part or result.Instance:IsDescendantOf(target.Character)
end

function TriggerBot.FindTargetPart(player, target, camera, center)
    local character = target.Character
    if not character then return nil end

    local bestPart = nil
    local bestDistance = math.huge
    local ignore = TriggerBot.BuildIgnoreList(player)

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and not part:FindFirstAncestorWhichIsA("Accessory") and not part:FindFirstAncestorWhichIsA("Accoutrement") then
            local screenPos, onScreen = camera:WorldToScreenPoint(part.Position)

            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

                if distance <= AIM_RADIUS and distance < bestDistance then
                    if TriggerBot.IsPartVisible(target, camera, part, ignore) then
                        bestPart = part
                        bestDistance = distance
                    end
                end
            end
        end
    end

    return bestPart
end

function TriggerBot.Start(player)
    local RunService = game:GetService("RunService")

    TriggerBot.Enabled = true
    TriggerBot.LastAttack = 0

    if TriggerBot.Status and TriggerBot.Status.Parent then
        TriggerBot.Status.Text = "Status: waiting"
        TriggerBot.Status.TextColor3 = Color3.fromRGB(160, 160, 160)
    end

    local function setStatus(text, color)
        if TriggerBot.Status and TriggerBot.Status.Parent then
            TriggerBot.Status.Text = text
            TriggerBot.Status.TextColor3 = color or Color3.fromRGB(160, 160, 160)
        end
    end

    local function clickMouse()
        pcall(function()
            mouse1press()
            task.wait(0.01)
            mouse1release()
        end)
    end

    TriggerBot.Connection = RunService.RenderStepped:Connect(function()
        if not TriggerBot.Enabled then return end
        if os.clock() - TriggerBot.LastAttack < TriggerBot.Settings.Delay / 1000 then return end

        local cam = workspace.CurrentCamera
        if not cam then return end

        local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        local checked = 0

        for _, target in pairs(game.Players:GetPlayers()) do
            if target ~= player and target.Character then
                local humanoid = target.Character:FindFirstChild("Humanoid")

                if humanoid and humanoid.Health > 0 then
                    checked = checked + 1
                    local part = TriggerBot.FindTargetPart(player, target, cam, center)

                    if part then
                        clickMouse()
                        TriggerBot.LastAttack = os.clock()
                        setStatus("Firing at " .. part.Name, Color3.fromRGB(60, 255, 120))
                        break
                    end
                end
            end
        end

        if os.clock() - TriggerBot.LastAttack > 0.2 then
            if checked == 0 then
                setStatus("Status: no players to target", Color3.fromRGB(255, 160, 60))
            else
                setStatus("Status: no visible body part near the crosshair", Color3.fromRGB(255, 160, 60))
            end
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

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 55)
    info.BackgroundTransparency = 1
    info.Text = "Shoots automatically at any visible body part near the crosshair. Wall check, aim radius and left click are always on"
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
