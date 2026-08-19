local TriggerBot = {}

TriggerBot.Settings = {
    FriendCheck = false,
    WallCheck = false,
    Keybind = nil
}

TriggerBot.Enabled = false
TriggerBot.Connection = nil

function TriggerBot.Start(player)
    local RunService = game:GetService("RunService")
    
    TriggerBot.Enabled = true
    
    TriggerBot.Connection = RunService.RenderStepped:Connect(function()
        if not TriggerBot.Enabled then return end
        
        local cam = workspace.CurrentCamera
        
        for _, target in pairs(game.Players:GetPlayers()) do
            if target ~= player and target.Character then
                local humanoid = target.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local screenPos, onScreen = cam:WorldToScreenPoint(targetRoot.Position)
                        if onScreen then
                            local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            
                            if dist < 80 then
                                pcall(function()
                                    local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                                    if tool then tool:Activate() end
                                end)
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

return TriggerBot
