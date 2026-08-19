local Noclip = {}

Noclip.Settings = {
    Keybind = nil
}

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

function Noclip.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "No settings"
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
end

return Noclip
