local Gravity = {}

Gravity.Settings = {
    Value = 196.2,
    Keybind = nil
}

Gravity.Enabled = false

function Gravity.Start(player)
    local Workspace = game:GetService("Workspace")
    
    Gravity.Enabled = true
    Workspace.Gravity = Gravity.Settings.Value
end

function Gravity.Stop()
    local Workspace = game:GetService("Workspace")
    
    Gravity.Enabled = false
    Workspace.Gravity = 196.2
end

return Gravity
