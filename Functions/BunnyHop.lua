local BunnyHop = {}

BunnyHop.Settings = {
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
        if not humanoid then return end
        
        local moving = false
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moving = true end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moving = true end
        
        if moving and humanoid:GetState() == Enum.HumanoidStateType.Landed then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
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

return BunnyHop
