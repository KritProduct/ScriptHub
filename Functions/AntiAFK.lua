local AntiAFK = {}

AntiAFK.Settings = {
    Interval = 5,
    Action = "Jump",
    Keybind = nil
}

AntiAFK.Enabled = false
AntiAFK.Connection = nil
AntiAFK.LastAction = 0

function AntiAFK.Start(player)
    local RunService = game:GetService("RunService")
    
    AntiAFK.Enabled = true
    
    AntiAFK.Connection = RunService.Heartbeat:Connect(function()
        if not AntiAFK.Enabled then return end
        
        if os.clock() - AntiAFK.LastAction >= AntiAFK.Settings.Interval then
            AntiAFK.LastAction = os.clock()
            
            pcall(function()
                local character = player.Character
                if not character then return end
                
                local humanoid = character:FindFirstChild("Humanoid")
                local cam = workspace.CurrentCamera
                
                if AntiAFK.Settings.Action == "Jump" then
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                elseif AntiAFK.Settings.Action == "Turn Camera" then
                    if cam then
                        cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(45), 0)
                    end
                elseif AntiAFK.Settings.Action == "Click" then
                    pcall(function()
                        mouse1press()
                        task.wait(0.01)
                        mouse1release()
                    end)
                end
            end)
        end
    end)
end

function AntiAFK.Stop()
    AntiAFK.Enabled = false
    
    if AntiAFK.Connection then
        AntiAFK.Connection:Disconnect()
        AntiAFK.Connection = nil
    end
end

return AntiAFK
