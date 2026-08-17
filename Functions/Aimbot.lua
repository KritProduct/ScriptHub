local Aimbot = {}

Aimbot.Settings = {
    FOV = 300,
    Speed = 10,
    WallCheck = false,
    FriendCheck = false,
    DrawFOV = false,
    FOVColor = Color3.fromRGB(255, 255, 255),
    TargetPart = "Head",
    Keybind = nil
}

Aimbot.Enabled = false
Aimbot.Connection = nil
Aimbot.FOVGui = nil

function Aimbot.IsVisible(player, target)
    if not Aimbot.Settings.WallCheck then return true end
    
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local targetChar = target.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local ray = workspace:Raycast(root.Position, (targetRoot.Position - root.Position).Unit * 1000, raycastParams)
    if ray and ray.Instance then
        return ray.Instance:IsDescendantOf(targetChar)
    end
    return true
end

function Aimbot.IsFriend(player, target)
    if not Aimbot.Settings.FriendCheck then return false end
    
    if player.Team and target.Team then
        if player.Team == target.Team then
            return true
        end
    end
    
    if target:IsFriendsWith(player.UserId) then
        return true
    end
    
    return false
end

function Aimbot.GetTargetPart(character)
    local partName = Aimbot.Settings.TargetPart
    
    if partName == "Head" then
        return character:FindFirstChild("Head")
    elseif partName == "Torso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
    elseif partName == "Legs" then
        return character:FindFirstChild("LeftLeg") or character:FindFirstChild("RightLeg") or character:FindFirstChild("LowerTorso")
    end
    
    return character:FindFirstChild("Head")
end

function Aimbot.UpdateFOVCircle()
    if Aimbot.FOVGui then
        Aimbot.FOVGui:Destroy()
        Aimbot.FOVGui = nil
    end
    
    if not Aimbot.Settings.DrawFOV then return end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "FOVCircle"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = game.CoreGui
    
    local screenSize = workspace.CurrentCamera.ViewportSize
    local fovRadius = Aimbot.Settings.FOV
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    circle.Position = UDim2.new(0.5, -fovRadius, 0.5, -fovRadius)
    circle.BackgroundTransparency = 1
    circle.ZIndex = 9999
    circle.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = circle
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Aimbot.Settings.FOVColor
    stroke.Thickness = 2
    stroke.Transparency = 0
    stroke.Parent = circle
    
    Aimbot.FOVGui = gui
end

function Aimbot.Start(player)
    local RunService = game:GetService("RunService")
    
    Aimbot.Enabled = true
    
    Aimbot.Connection = RunService.RenderStepped:Connect(function()
        if not Aimbot.Enabled then return end
        
        local cam = workspace.CurrentCamera
        if not cam then return end
        
        local closest = nil
        local closestDist = Aimbot.Settings.FOV
        
        for _, target in pairs(game.Players:GetPlayers()) do
            if target ~= player and target.Character then
                if not Aimbot.IsFriend(player, target) then
                    local targetPart = Aimbot.GetTargetPart(target.Character)
                    local humanoid = target.Character:FindFirstChild("Humanoid")
                    
                    if targetPart and humanoid and humanoid.Health > 0 then
                        local sp, onScreen = cam:WorldToScreenPoint(targetPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(sp.X, sp.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                            if dist < closestDist then
                                if Aimbot.IsVisible(player, target) then
                                    closest = targetPart
                                    closestDist = dist
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if closest then
            local lookAt = CFrame.lookAt(cam.CFrame.Position, closest.Position)
            cam.CFrame = cam.CFrame:Lerp(lookAt, math.clamp(Aimbot.Settings.Speed / 20, 0.05, 1))
        end
    end)
    
    Aimbot.UpdateFOVCircle()
end

function Aimbot.Stop()
    Aimbot.Enabled = false
    
    if Aimbot.Connection then
        Aimbot.Connection:Disconnect()
        Aimbot.Connection = nil
    end
    
    if Aimbot.FOVGui then
        Aimbot.FOVGui:Destroy()
        Aimbot.FOVGui = nil
    end
end

function Aimbot.RefreshFOV()
    Aimbot.UpdateFOVCircle()
end

function Aimbot.BuildSettings(content)
    local function createSlider(min, max, current, callback, name)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 50)
        container.BackgroundTransparency = 1
        container.Parent = content
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name .. ": " .. math.floor(current)
        nameLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
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
            nameLabel.Text = name .. ": " .. math.floor(value)
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
    
    createSlider(50, 500, Aimbot.Settings.FOV, function(v)
        Aimbot.Settings.FOV = v
        Aimbot.RefreshFOV()
    end, "FOV Radius")
    
    createSlider(1, 20, Aimbot.Settings.Speed, function(v)
        Aimbot.Settings.Speed = v
    end, "Speed")
    
    createToggle("Wall Check", Aimbot.Settings.WallCheck, function(v)
        Aimbot.Settings.WallCheck = v
    end)
    
    createToggle("Friend Check", Aimbot.Settings.FriendCheck, function(v)
        Aimbot.Settings.FriendCheck = v
    end)
    
    createToggle("Draw FOV Circle", Aimbot.Settings.DrawFOV, function(v)
        Aimbot.Settings.DrawFOV = v
        Aimbot.RefreshFOV()
    end)
    
    local partLabel = Instance.new("TextLabel")
    partLabel.Size = UDim2.new(1, 0, 0, 20)
    partLabel.BackgroundTransparency = 1
    partLabel.Text = "Target Part: " .. Aimbot.Settings.TargetPart
    partLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    partLabel.Font = Enum.Font.GothamBold
    partLabel.TextSize = 11
    partLabel.TextXAlignment = Enum.TextXAlignment.Left
    partLabel.Parent = content
    
    local parts = {"Head", "Torso", "Legs"}
    
    for i, part in ipairs(parts) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 90, 0, 30)
        btn.Position = UDim2.new(0, (i - 1) * 95, 0, 0)
        btn.Text = part
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        btn.BorderSizePixel = 0
        btn.TextColor3 = Color3.fromRGB(160, 160, 160)
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 11
        btn.AutoButtonColor = false
        btn.Parent = content
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            Aimbot.Settings.TargetPart = part
            partLabel.Text = "Target Part: " .. part
        end)
    end
end

return Aimbot
