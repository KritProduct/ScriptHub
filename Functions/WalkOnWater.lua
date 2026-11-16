local WalkOnWater = {}

WalkOnWater.Settings = {
    Keybind = nil
}

WalkOnWater.Enabled = false
WalkOnWater.Player = nil
WalkOnWater.Platform = nil
WalkOnWater.BaseY = nil
WalkOnWater.LoopConnection = nil

local RunService = game:GetService("RunService")

local function createPlatform()
    local part = Instance.new("Part")
    part.Name = "ScriptHubWalkOnWater"
    part.Anchored = true
    part.CanCollide = true
    part.CanQuery = false
    part.CanTouch = false
    part.Transparency = 1
    part.Size = Vector3.new(18, 1, 18)
    part.Material = Enum.Material.SmoothPlastic
    part.Parent = workspace
    return part
end

local function updatePlatform()
    if not WalkOnWater.Enabled then return end

    local player = WalkOnWater.Player
    local character = player and player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then return end

    if not WalkOnWater.Platform or not WalkOnWater.Platform.Parent then
        WalkOnWater.Platform = createPlatform()
    end

    if WalkOnWater.BaseY == nil then
        WalkOnWater.BaseY = root.Position.Y - humanoid.HipHeight
    end

    WalkOnWater.Platform.CFrame = CFrame.new(
        root.Position.X,
        WalkOnWater.BaseY - 0.5,
        root.Position.Z
    )
end

function WalkOnWater.Start(player)
    if WalkOnWater.Enabled then return end

    WalkOnWater.Player = player
    WalkOnWater.Platform = createPlatform()
    WalkOnWater.Enabled = true

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if root then
        WalkOnWater.BaseY = root.Position.Y - (humanoid and humanoid.HipHeight or 2)
    else
        WalkOnWater.BaseY = nil
    end

    updatePlatform()

    WalkOnWater.LoopConnection = RunService.RenderStepped:Connect(updatePlatform)
end

function WalkOnWater.Stop()
    if not WalkOnWater.Enabled then return end

    WalkOnWater.Enabled = false

    if WalkOnWater.LoopConnection then
        WalkOnWater.LoopConnection:Disconnect()
        WalkOnWater.LoopConnection = nil
    end

    if WalkOnWater.Platform and WalkOnWater.Platform.Parent then
        WalkOnWater.Platform:Destroy()
    end

    WalkOnWater.Platform = nil
    WalkOnWater.Player = nil
    WalkOnWater.BaseY = nil
end

function WalkOnWater.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 60)
    label.BackgroundTransparency = 1
    label.Text = "Creates an invisible platform at the height where you enabled it and moves it with you. Walk over water and gaps. Disable and enable again to pick a new height"
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
end

return WalkOnWater
