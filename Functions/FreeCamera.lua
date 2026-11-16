local FreeCamera = {}

FreeCamera.Settings = {
    Speed = 50,
    Sensitivity = 0.3,
    Keybind = nil
}

FreeCamera.Enabled = false
FreeCamera.Connection = nil
FreeCamera.OriginalCameraType = nil
FreeCamera.OriginalSubject = nil
FreeCamera.Yaw = 0
FreeCamera.Pitch = 0
FreeCamera.Locked = false

function FreeCamera.Start()
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    local camera = workspace.CurrentCamera
    if not camera then return end

    if FreeCamera.Enabled then return end
    FreeCamera.Enabled = true

    FreeCamera.OriginalCameraType = camera.CameraType
    FreeCamera.OriginalSubject = camera.CameraSubject

    local pitch, yaw = camera.CFrame:ToOrientation()
    FreeCamera.Pitch = pitch
    FreeCamera.Yaw = yaw

    camera.CameraType = Enum.CameraType.Scriptable

    FreeCamera.Connection = RunService.RenderStepped:Connect(function(deltaTime)
        if not FreeCamera.Enabled then return end

        local cam = workspace.CurrentCamera
        if not cam then return end

        local looking = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

        if looking and not FreeCamera.Locked then
            FreeCamera.Locked = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        elseif not looking and FreeCamera.Locked then
            FreeCamera.Locked = false
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end

        if looking then
            local delta = UserInputService:GetMouseDelta()
            FreeCamera.Yaw -= delta.X * FreeCamera.Settings.Sensitivity * 0.01
            FreeCamera.Pitch = math.clamp(FreeCamera.Pitch - delta.Y * FreeCamera.Settings.Sensitivity * 0.01, math.rad(-89), math.rad(89))
        end

        local rotation = CFrame.fromOrientation(FreeCamera.Pitch, FreeCamera.Yaw, 0)
        local position = cam.CFrame.Position
        local look = rotation.LookVector
        local right = rotation.RightVector
        local up = Vector3.new(0, 1, 0)

        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += look end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= look end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += right end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += up end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= up end

        if move.Magnitude > 0 then
            position += move.Unit * FreeCamera.Settings.Speed * deltaTime
        end

        cam.CFrame = CFrame.new(position) * rotation
    end)
end

function FreeCamera.Stop()
    local UserInputService = game:GetService("UserInputService")

    FreeCamera.Enabled = false

    if FreeCamera.Connection then
        FreeCamera.Connection:Disconnect()
        FreeCamera.Connection = nil
    end

    local camera = workspace.CurrentCamera
    if camera then
        camera.CameraType = FreeCamera.OriginalCameraType or Enum.CameraType.Custom
        camera.CameraSubject = FreeCamera.OriginalSubject
    end

    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    FreeCamera.Locked = false
    FreeCamera.OriginalCameraType = nil
    FreeCamera.OriginalSubject = nil
end

function FreeCamera.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Fly speed"
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 30)
    input.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    input.BorderSizePixel = 0
    input.Text = tostring(FreeCamera.Settings.Speed)
    input.PlaceholderText = "1 - 1000"
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 12
    input.ClearTextOnFocus = false
    input.Parent = content

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, 0, 0, 34)
    hint.BackgroundTransparency = 1
    hint.Text = "WASD to move, Space/Shift up and down, hold right mouse to look around"
    hint.TextColor3 = Color3.fromRGB(120, 120, 120)
    hint.Font = Enum.Font.GothamMedium
    hint.TextSize = 10
    hint.TextXAlignment = Enum.TextXAlignment.Left
    hint.TextWrapped = true
    hint.Parent = content

    input.FocusLost:Connect(function()
        local value = tonumber(input.Text)
        if value then
            FreeCamera.Settings.Speed = math.clamp(value, 1, 1000)
        end
        input.Text = tostring(FreeCamera.Settings.Speed)
    end)
end

return FreeCamera
