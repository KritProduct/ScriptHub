local Spider = {}

Spider.Settings = {
    Keybind = nil
}

Spider.Enabled = false
Spider.Connection = nil

function Spider.Start(player)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    Spider.Enabled = true
    
    Spider.Connection = RunService.Heartbeat:Connect(function()
        if not Spider.Enabled then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end
        
        humanoid.AutoRotate = false
        humanoid.PlatformStand = true
        
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new()
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
        moveDir = Vector3.new(moveDir.X, 0, moveDir.Z)
        
        if moveDir.Magnitude > 0 then
            root.Velocity = Vector3.new(moveDir.Unit.X * 50, -30, moveDir.Unit.Z * 50)
        else
            root.Velocity = Vector3.new(0, -30, 0)
        end
    end)
end

function Spider.Stop(player)
    Spider.Enabled = false
    
    if Spider.Connection then
        Spider.Connection:Disconnect()
        Spider.Connection = nil
    end
    
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.AutoRotate = true
            humanoid.PlatformStand = false
        end
    end
end

function Spider.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Walk on walls!"
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
end

return Spider
