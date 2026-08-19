local Fly = {}

Fly.Settings = {
    Speed = 50,
    Keybind = nil
}

Fly.Enabled = false
Fly.Instance = nil

function Fly.Start(player)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    local character = player.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    Fly.Enabled = true
    hum.PlatformStand = true
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9000
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    bodyGyro.Parent = root
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Parent = root
    
    local connection = RunService.Heartbeat:Connect(function()
        if not Fly.Enabled then return end
        
        bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        
        local dir = Vector3.new()
        local cam = workspace.CurrentCamera
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
        
        if dir.Magnitude > 0 then
            bodyVelocity.Velocity = dir.Unit * Fly.Settings.Speed
        else
            bodyVelocity.Velocity = Vector3.new()
        end
    end)
    
    Fly.Instance = {
        Connection = connection,
        BodyGyro = bodyGyro,
        BodyVelocity = bodyVelocity,
        Humanoid = hum
    }
end

function Fly.Stop()
    Fly.Enabled = false
    
    if Fly.Instance then
        Fly.Instance.Connection:Disconnect()
        Fly.Instance.BodyGyro:Destroy()
        Fly.Instance.BodyVelocity:Destroy()
        Fly.Instance.Humanoid.PlatformStand = false
        Fly.Instance = nil
    end
end

return Fly
