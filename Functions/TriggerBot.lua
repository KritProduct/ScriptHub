local TriggerBot = {}

TriggerBot.Enabled = false
TriggerBot.Connection = nil

function TriggerBot.Start(player)
    local RunService = game:GetService("RunService")
    
    TriggerBot.Enabled = true
    
    TriggerBot.Connection = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        
        for _, target in pairs(game.Players:GetPlayers()) do
            if target ~= player and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head then
                    local sp, onScreen = cam:WorldToScreenPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if dist < 50 then
                            pcall(function()
                                local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
                                if tool then tool:Activate() end
                            end)
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

function TriggerBot.Toggle(player)
    if TriggerBot.Enabled then
        TriggerBot.Stop()
    else
        TriggerBot.Start(player)
    end
end

return TriggerBot
