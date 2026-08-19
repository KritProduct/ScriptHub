local TimeChanger = {}

TimeChanger.Settings = {
    Time = 14,
    Keybind = nil
}

TimeChanger.Enabled = false

function TimeChanger.Start(player)
    local Lighting = game:GetService("Lighting")
    
    TimeChanger.Enabled = true
    Lighting.ClockTime = TimeChanger.Settings.Time
end

function TimeChanger.Stop()
    TimeChanger.Enabled = false
end

return TimeChanger
