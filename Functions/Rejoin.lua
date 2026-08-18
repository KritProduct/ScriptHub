local Rejoin = {}

Rejoin.Settings = {
    Keybind = nil
}

Rejoin.Enabled = false

function Rejoin.Start(player)
    Rejoin.Enabled = true
    
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end

function Rejoin.Stop()
    Rejoin.Enabled = false
end

function Rejoin.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Rejoins the same server"
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.Text = "Rejoin"
    btn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        local TeleportService = game:GetService("TeleportService")
        local player = game.Players.LocalPlayer
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end)
end

return Rejoin
