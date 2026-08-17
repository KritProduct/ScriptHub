local Noclip = {}

Noclip.Enabled = false
Noclip.Connection = nil

function Noclip.Start(player)
    local RunService = game:GetService("RunService")
    
    Noclip.Enabled = true
    
    Noclip.Connection = RunService.Stepped:Connect(function()
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)
end

function Noclip.Stop(player)
    Noclip.Enabled = false
    
    if Noclip.Connection then
        Noclip.Connection:Disconnect()
        Noclip.Connection = nil
    end
    
    if player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = true
            end
        end
    end
end

function Noclip.Toggle(player)
    if Noclip.Enabled then
        Noclip.Stop(player)
    else
        Noclip.Start(player)
    end
end

return Noclip
