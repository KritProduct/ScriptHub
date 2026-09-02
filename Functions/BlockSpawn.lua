local BlockSpawn = {}

BlockSpawn.Settings = {
    Interval = 0.1,
    Keybind = nil
}

BlockSpawn.Enabled = false
BlockSpawn.Connection = nil

function BlockSpawn.Start(player)
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    
    BlockSpawn.Enabled = true
    
    BlockSpawn.Connection = RunService.Heartbeat:Connect(function()
        if not BlockSpawn.Enabled then return end
        
        local character = player.Character
        if not character then return end
        
        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        pcall(function()
            local block = Instance.new("Part")
            block.Name = "SpawnBlock"
            block.Size = Vector3.new(4, 1, 4)
            block.Position = root.Position - Vector3.new(0, 3, 0)
            block.Anchored = true
            block.CanCollide = true
            block.Material = Enum.Material.Grass
            block.Color = Color3.fromRGB(100, 150, 100)
            block.Parent = Workspace
        end)
        
        task.wait(BlockSpawn.Settings.Interval)
    end)
end

function BlockSpawn.Stop()
    BlockSpawn.Enabled = false
    
    if BlockSpawn.Connection then
        BlockSpawn.Connection:Disconnect()
        BlockSpawn.Connection = nil
    end
end

function BlockSpawn.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Spawns blocks under you"
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
end

return BlockSpawn
