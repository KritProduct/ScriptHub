local Speed = {}

Speed.Settings = {
    Strength = 50,
    Keybind = nil
}

Speed.Enabled = false
Speed.Instance = nil

function Speed.Start(player)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    local character = player.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    Speed.Enabled = true
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(40000, 0, 40000)
    bodyVelocity.Parent = root
    
    local connection = RunService.Heartbeat:Connect(function()
        if not Speed.Enabled then return end
        
        local dir = Vector3.new()
        local cam = workspace.CurrentCamera
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        dir = Vector3.new(dir.X, 0, dir.Z)
        
        if dir.Magnitude > 0 then
            bodyVelocity.Velocity = dir.Unit * Speed.Settings.Strength
        else
            bodyVelocity.Velocity = Vector3.new()
        end
    end)
    
    Speed.Instance = {
        Connection = connection,
        BodyVelocity = bodyVelocity
    }
end

function Speed.Stop()
    Speed.Enabled = false
    
    if Speed.Instance then
        Speed.Instance.Connection:Disconnect()
        Speed.Instance.BodyVelocity:Destroy()
        Speed.Instance = nil
    end
end

return Speed
