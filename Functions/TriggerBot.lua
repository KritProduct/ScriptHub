local TriggerBot = {}

TriggerBot.Settings = {
    FriendCheck = false,
    WallCheck = false,
    Button = "Left",
    Delay = 0,
    Fov = 150,
    Keybind = nil
}

TriggerBot.Enabled = false
TriggerBot.Connection = nil
TriggerBot.LastAttack = 0
TriggerBot.Status = nil

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
    if not TriggerBot.Settings.WallCheck then return true end

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

    local radius = TriggerBot.Settings.Fov
    local bestPart = nil
    local bestDistance = math.huge
    local ignore = TriggerBot.BuildIgnoreList(player)

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and not part:FindFirstAncestorWhichIsA("Accessory") and not part:FindFirstAncestorWhichIsA("Accoutrement") then
            local screenPos, onScreen = camera:WorldToScreenPoint(part.Position)

            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

                if distance <= radius and distance < bestDistance then
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

    local function clickMouse(button)
        local isLeft = button == "Left"
        local pressed = false

        if isLeft and type(mouse1click) == "function" then
            pressed = pcall(mouse1click)
        elseif not isLeft and type(mouse2click) == "function" then
            pressed = pcall(mouse2click)
        end

        if not pressed then
            local pressFunction = isLeft and mouse1press or mouse2press
            local releaseFunction = isLeft and mouse1release or mouse2release

            if type(pressFunction) == "function" and type(releaseFunction) == "function" then
                pressed = pcall(function()
                    pressFunction()
                    task.wait(0.02)
                    releaseFunction()
                end)
            end
        end

        if pressed then return true end

        local sent = pcall(function()
            local VirtualInputManager = game:GetService("VirtualInputManager")
            local camera = workspace.CurrentCamera
            local position = camera and camera.ViewportSize or Vector2.new(800, 600)
            local x = math.floor(position.X / 2)
            local y = math.floor(position.Y / 2)
            local code = isLeft and 0 or 1

            VirtualInputManager:SendMouseButtonEvent(x, y, code, true, game, 0)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(x, y, code, false, game, 0)
        end)

        return sent
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
                    local isFriend = false
                    
                    if TriggerBot.Settings.FriendCheck then
                        if player.Team and target.Team then
                            if player.Team == target.Team then
                                isFriend = true
                            end
                        end
                        if target:IsFriendsWith(player.UserId) then
                            isFriend = true
                        end
                    end
                    
                    if not isFriend then
                        checked = checked + 1
                        local part = TriggerBot.FindTargetPart(player, target, cam, center)

                        if part then
                            clickMouse(TriggerBot.Settings.Button)
                            TriggerBot.LastAttack = os.clock()
                            setStatus("Firing at " .. part.Name, Color3.fromRGB(60, 255, 120))
                            break
                        end
                    end
                end
            end
        end

        if os.clock() - TriggerBot.LastAttack > 0.2 then
            if checked == 0 then
                setStatus("No players to target", Color3.fromRGB(255, 160, 60))
            else
                setStatus("No visible body part inside " .. tostring(math.floor(TriggerBot.Settings.Fov)) .. " px", Color3.fromRGB(255, 160, 60))
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

    local fovLabel = Instance.new("TextLabel")
    fovLabel.Size = UDim2.new(1, 0, 0, 20)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Text = "Aim radius around the crosshair (pixels)"
    fovLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    fovLabel.Font = Enum.Font.GothamBold
    fovLabel.TextSize = 11
    fovLabel.TextXAlignment = Enum.TextXAlignment.Left
    fovLabel.Parent = content

    local fovInput = Instance.new("TextBox")
    fovInput.Size = UDim2.new(1, 0, 0, 30)
    fovInput.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    fovInput.BorderSizePixel = 0
    fovInput.Text = tostring(TriggerBot.Settings.Fov)
    fovInput.PlaceholderText = "0 - 500"
    fovInput.TextColor3 = Color3.new(1, 1, 1)
    fovInput.Font = Enum.Font.GothamBold
    fovInput.TextSize = 12
    fovInput.ClearTextOnFocus = false
    fovInput.Parent = content

    local fovCorner = Instance.new("UICorner")
    fovCorner.CornerRadius = UDim.new(0, 6)
    fovCorner.Parent = fovInput

    fovInput.FocusLost:Connect(function()
        local value = tonumber(fovInput.Text)
        if value then
            TriggerBot.Settings.Fov = math.clamp(value, 0, 500)
        end
        fovInput.Text = tostring(TriggerBot.Settings.Fov)
    end)
    
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
    
    createToggle("Friend Check", TriggerBot.Settings.FriendCheck, function(v)
        TriggerBot.Settings.FriendCheck = v
    end)
    
    createToggle("Wall Check", TriggerBot.Settings.WallCheck, function(v)
        TriggerBot.Settings.WallCheck = v
    end)
    
    local buttonLabel = Instance.new("TextLabel")
    buttonLabel.Size = UDim2.new(1, 0, 0, 20)
    buttonLabel.BackgroundTransparency = 1
    buttonLabel.Text = "Button: " .. TriggerBot.Settings.Button
    buttonLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    buttonLabel.Font = Enum.Font.GothamBold
    buttonLabel.TextSize = 11
    buttonLabel.TextXAlignment = Enum.TextXAlignment.Left
    buttonLabel.Parent = content
    
    local leftBtn = Instance.new("TextButton")
    leftBtn.Size = UDim2.new(0, 130, 0, 30)
    leftBtn.Position = UDim2.new(0, 0, 0, 0)
    leftBtn.Text = "Left"
    leftBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    leftBtn.BorderSizePixel = 0
    leftBtn.TextColor3 = Color3.new(1, 1, 1)
    leftBtn.Font = Enum.Font.GothamBlack
    leftBtn.TextSize = 11
    leftBtn.AutoButtonColor = false
    leftBtn.Parent = content
    
    local leftCorner = Instance.new("UICorner")
    leftCorner.CornerRadius = UDim.new(0, 6)
    leftCorner.Parent = leftBtn
    
    local rightBtn = Instance.new("TextButton")
    rightBtn.Size = UDim2.new(0, 130, 0, 30)
    rightBtn.Position = UDim2.new(0, 140, 0, 0)
    rightBtn.Text = "Right"
    rightBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    rightBtn.BorderSizePixel = 0
    rightBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
    rightBtn.Font = Enum.Font.GothamBlack
    rightBtn.TextSize = 11
    rightBtn.AutoButtonColor = false
    rightBtn.Parent = content
    
    local rightCorner = Instance.new("UICorner")
    rightCorner.CornerRadius = UDim.new(0, 6)
    rightCorner.Parent = rightBtn
    
    local function updateButtons()
        if TriggerBot.Settings.Button == "Left" then
            leftBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            leftBtn.TextColor3 = Color3.new(1, 1, 1)
            rightBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            rightBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
        else
            rightBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            rightBtn.TextColor3 = Color3.new(1, 1, 1)
            leftBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            leftBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
        end
        buttonLabel.Text = "Button: " .. TriggerBot.Settings.Button
    end
    
    leftBtn.MouseButton1Click:Connect(function()
        TriggerBot.Settings.Button = "Left"
        updateButtons()
    end)
    
    rightBtn.MouseButton1Click:Connect(function()
        TriggerBot.Settings.Button = "Right"
        updateButtons()
    end)
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: idle"
    statusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 11
    statusLabel.TextWrapped = true
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = content

    TriggerBot.Status = statusLabel

    updateButtons()
end

return TriggerBot
