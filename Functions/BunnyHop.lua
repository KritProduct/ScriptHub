local BunnyHop = {}

BunnyHop.Settings = {
    Speed = 50,
    Keybind = nil
}

BunnyHop.Enabled = false
BunnyHop.Connection = nil

function BunnyHop.Start(player)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    BunnyHop.Enabled = true
    
    BunnyHop.Connection = RunService.Heartbeat:Connect(function()
        if not BunnyHop.Enabled then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end
        
        local moving = false
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moving = true end
        
        if moving and humanoid:GetState() == Enum.HumanoidStateType.Landed then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            root.Velocity = Vector3.new(root.Velocity.X, BunnyHop.Settings.Speed * 0.5, root.Velocity.Z)
        end
    end)
end

function BunnyHop.Stop()
    BunnyHop.Enabled = false
    if BunnyHop.Connection then
        BunnyHop.Connection:Disconnect()
        BunnyHop.Connection = nil
    end
end

function BunnyHop.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Auto jumps while moving"
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
end

return BunnyHop
