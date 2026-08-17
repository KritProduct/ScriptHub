local Teleport = {}

Teleport.Settings = {
    Keybind = nil
}

Teleport.Enabled = false

function Teleport.Start(player)
    Teleport.Enabled = true
end

function Teleport.Stop()
    Teleport.Enabled = false
end

function Teleport.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = "Player Name:"
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 30)
    input.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    input.BorderSizePixel = 0
    input.PlaceholderText = "Enter player name..."
    input.Text = ""
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 12
    input.Parent = content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = input
    
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(1, 0, 0, 30)
    tpBtn.Text = "Teleport"
    tpBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    tpBtn.BorderSizePixel = 0
    tpBtn.TextColor3 = Color3.new(1, 1, 1)
    tpBtn.Font = Enum.Font.GothamBlack
    tpBtn.TextSize = 12
    tpBtn.AutoButtonColor = false
    tpBtn.Parent = content
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = tpBtn
    
    tpBtn.MouseButton1Click:Connect(function()
        local targetName = input.Text
        local player = game.Players.LocalPlayer
        
        for _, target in pairs(game.Players:GetPlayers()) do
            if target.Name == targetName and target ~= player then
                if target.Character then
                    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                    local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    
                    if targetRoot and playerRoot then
                        playerRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 2, 0)
                    end
                end
                break
            end
        end
    end)
end

return Teleport
