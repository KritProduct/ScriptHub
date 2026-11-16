local Speed = {}

Speed.Settings = {
    Speed = 16,
    Keybind = nil
}

Speed.Enabled = false
Speed.OriginalWalkSpeed = nil
Speed.CharacterConnection = nil
Speed.LoopConnection = nil
Speed.Player = nil

local RunService = game:GetService("RunService")

local function getHumanoid(player)
    local character = player.Character
    if not character then return nil end
    return character:FindFirstChildOfClass("Humanoid")
end

local function applySpeed(player, force)
    local humanoid = getHumanoid(player)
    if humanoid then
        if force or humanoid.WalkSpeed ~= Speed.Settings.Speed then
            humanoid.WalkSpeed = Speed.Settings.Speed
        end
    end
end

function Speed.Start(player)
    local currentHumanoid = getHumanoid(player)
    if not currentHumanoid then return end

    if Speed.Enabled then return end

    Speed.Enabled = true
    Speed.Player = player
    Speed.OriginalWalkSpeed = currentHumanoid.WalkSpeed

    applySpeed(player, true)

    Speed.CharacterConnection = player.CharacterAdded:Connect(function()
        if not Speed.Enabled then return end
        task.wait(0.2)
        applySpeed(player, true)
    end)

    Speed.LoopConnection = RunService.Heartbeat:Connect(function()
        if not Speed.Enabled then return end
        applySpeed(Speed.Player or game:GetService("Players").LocalPlayer or player, false)
    end)
end

function Speed.Stop(player)
    Speed.Enabled = false

    if Speed.CharacterConnection then
        Speed.CharacterConnection:Disconnect()
        Speed.CharacterConnection = nil
    end

    if Speed.LoopConnection then
        Speed.LoopConnection:Disconnect()
        Speed.LoopConnection = nil
    end

    local humanoid = getHumanoid(player)
    if humanoid and Speed.OriginalWalkSpeed ~= nil then
        humanoid.WalkSpeed = Speed.OriginalWalkSpeed
    end

    Speed.OriginalWalkSpeed = nil
    Speed.Player = nil
end

function Speed.BuildSettings(content, player)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "WalkSpeed"
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 30)
    input.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    input.BorderSizePixel = 0
    input.Text = tostring(Speed.Settings.Speed)
    input.PlaceholderText = "1 - 500"
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 12
    input.ClearTextOnFocus = false
    input.Parent = content

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, 0, 0, 16)
    hint.BackgroundTransparency = 1
    hint.Text = "16 = standard Roblox speed"
    hint.TextColor3 = Color3.fromRGB(120, 120, 120)
    hint.Font = Enum.Font.GothamMedium
    hint.TextSize = 10
    hint.TextXAlignment = Enum.TextXAlignment.Left
    hint.Parent = content

    input.FocusLost:Connect(function()
        local value = tonumber(input.Text)
        if value then
            Speed.Settings.Speed = math.clamp(value, 1, 500)
        end
        input.Text = tostring(Speed.Settings.Speed)
        if Speed.Enabled then
            applySpeed(player or game.Players.LocalPlayer)
        end
    end)
end

return Speed
