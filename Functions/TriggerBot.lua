local TriggerBot = {}

TriggerBot.Settings = {
    FriendCheck = false,
    Keybind = nil
}

TriggerBot.Enabled = false
TriggerBot.Connection = nil

function TriggerBot.Start(player)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    TriggerBot.Enabled = true
    
    TriggerBot.Connection = RunService.RenderStepped:Connect(function()
        if not TriggerBot.Enabled then return end
        
        local cam = workspace.CurrentCamera
        if not cam then return end
        
        local mouse = player:GetMouse()
        
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
                        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot then
                            local screenPos, onScreen = cam:WorldToScreenPoint(targetRoot.Position)
                            
                            if onScreen then
                                local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                
                                if dist < 80 then
                                    pcall(function()
                                        mouse1press()
                                        task.wait(0.001)
                                        mouse1release()
                                    end)
                                end
                            end
                        end
                    end
                end
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
end

function TriggerBot.BuildSettings(content)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Friend Check"
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
    
    local enabled = TriggerBot.Settings.FriendCheck
    
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
        TriggerBot.Settings.FriendCheck = enabled
        updateToggle()
    end)
end

return TriggerBot
