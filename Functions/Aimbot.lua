local Aimbot = {}

Aimbot.Settings = {
    FOV = 150,
    Speed = 10,
    WallCheck = false,
    FriendCheck = false,
    Keybind = nil
}

Aimbot.Enabled = false
Aimbot.Connection = nil

function Aimbot.Start(player)
    local RunService = game:GetService("RunService")
    
    Aimbot.Enabled = true
    
    Aimbot.Connection = RunService.RenderStepped:Connect(function()
        if not Aimbot.Enabled then return end
        
        local cam = workspace.CurrentCamera
        local closest = nil
        local closestDist = Aimbot.Settings.FOV
        
        for _, target in pairs(game.Players:GetPlayers()) do
            if target ~= player and target.Character then
                local head = target.Character:FindFirstChild("Head")
                local humanoid = target.Character:FindFirstChild("Humanoid")
                
                if head and humanoid and humanoid.Health > 0 then
                    local sp, onScreen = cam:WorldToScreenPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(sp.X, sp.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                        if dist < closestDist then
                            closest = head
                            closestDist = dist
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
end

function Aimbot.Stop()
    Aimbot.Enabled = false
    
    if Aimbot.Connection then
        Aimbot.Connection:Disconnect()
        Aimbot.Connection = nil
    end
end

return Aimbot
