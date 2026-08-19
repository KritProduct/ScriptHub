local AutoClicker = {}

AutoClicker.Settings = {
    Button = "Left",
    Delay = 1,
    Keybind = nil
}

AutoClicker.Enabled = false
AutoClicker.Connection = nil
AutoClicker.LastClick = 0

function AutoClicker.Start(player)
    local RunService = game:GetService("RunService")
    
    AutoClicker.Enabled = true
    
    AutoClicker.Connection = RunService.Heartbeat:Connect(function()
        if not AutoClicker.Enabled then return end
        
        if os.clock() - AutoClicker.LastClick >= AutoClicker.Settings.Delay then
            AutoClicker.LastClick = os.clock()
            
            pcall(function()
                if AutoClicker.Settings.Button == "Left" then
                    mouse1press()
                    task.wait(0.01)
                    mouse1release()
                else
                    mouse2press()
                    task.wait(0.01)
                    mouse2release()
                end
            end)
        end
    end)
end

function AutoClicker.Stop()
    AutoClicker.Enabled = false
    
    if AutoClicker.Connection then
        AutoClicker.Connection:Disconnect()
        AutoClicker.Connection = nil
    end
end

return AutoClicker
