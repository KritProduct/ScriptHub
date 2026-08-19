local InfinityJump = {}

InfinityJump.Settings = {
    JumpPower = 100,
    AutoJump = false,
    Keybind = nil
}

InfinityJump.Enabled = false
InfinityJump.Connection = nil

function InfinityJump.Start(player)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    InfinityJump.Enabled = true
    
    InfinityJump.Connection = RunService.Heartbeat:Connect(function()
        if not InfinityJump.Enabled then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        humanoid.JumpPower = InfinityJump.Settings.JumpPower
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        
        if InfinityJump.Settings.AutoJump then
            if humanoid:GetState() == Enum.HumanoidStateType.Landed then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

function InfinityJump.Stop(player)
    InfinityJump.Enabled = false
    
    if InfinityJump.Connection then
        InfinityJump.Connection:Disconnect()
        InfinityJump.Connection = nil
    end
    
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then humanoid.JumpPower = 50 end
    end
end

return InfinityJump
