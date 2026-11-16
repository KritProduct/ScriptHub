local AirWalk = {}

AirWalk.Settings = {
    Keybind = nil
}

AirWalk.Enabled = false
AirWalk.Player = nil
AirWalk.Platform = nil
AirWalk.LoopConnection = nil

local RunService = game:GetService("RunService")

local function createPlatform()
    local part = Instance.new("Part")
    part.Name = "ScriptHubAirWalk"
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
    if not AirWalk.Enabled then return end

    local player = AirWalk.Player
    local character = player and player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then return end

    if not AirWalk.Platform or not AirWalk.Platform.Parent then
        AirWalk.Platform = createPlatform()
    end

    AirWalk.Platform.CFrame = CFrame.new(
        root.Position.X,
        root.Position.Y - humanoid.HipHeight - 0.5,
        root.Position.Z
    )
end

function AirWalk.Start(player)
    if AirWalk.Enabled then return end

    AirWalk.Player = player
    AirWalk.Platform = createPlatform()
    AirWalk.Enabled = true

    updatePlatform()

    AirWalk.LoopConnection = RunService.RenderStepped:Connect(updatePlatform)
end

function AirWalk.Stop()
    if not AirWalk.Enabled then return end

    AirWalk.Enabled = false

    if AirWalk.LoopConnection then
        AirWalk.LoopConnection:Disconnect()
        AirWalk.LoopConnection = nil
    end

    if AirWalk.Platform and AirWalk.Platform.Parent then
        AirWalk.Platform:Destroy()
    end

    AirWalk.Platform = nil
    AirWalk.Player = nil
end

function AirWalk.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 60)
    label.BackgroundTransparency = 1
    label.Text = "Keeps an invisible platform under your feet, so you can walk in the air and will not fall. Jump to go higher"
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
end

return AirWalk
