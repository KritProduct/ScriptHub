local CameraFOV = {}

CameraFOV.Settings = {
    FOV = 70,
    Keybind = nil
}

CameraFOV.Enabled = false
CameraFOV.OriginalFOV = nil

local function applyFOV()
    local camera = workspace.CurrentCamera
    if camera then
        camera.FieldOfView = CameraFOV.Settings.FOV
    end
end

function CameraFOV.Start()
    local camera = workspace.CurrentCamera
    if not camera then return end

    if not CameraFOV.Enabled then
        CameraFOV.OriginalFOV = camera.FieldOfView
    end

    CameraFOV.Enabled = true
    applyFOV()
end

function CameraFOV.Stop()
    CameraFOV.Enabled = false

    local camera = workspace.CurrentCamera
    if camera then
        camera.FieldOfView = CameraFOV.OriginalFOV or 70
    end

    CameraFOV.OriginalFOV = nil
end

function CameraFOV.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Field of View (30 - 120)"
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 30)
    input.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    input.BorderSizePixel = 0
    input.Text = tostring(CameraFOV.Settings.FOV)
    input.PlaceholderText = "30 - 120"
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 12
    input.ClearTextOnFocus = false
    input.Parent = content

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input

    input.FocusLost:Connect(function()
        local value = tonumber(input.Text)
        if value then
            CameraFOV.Settings.FOV = math.clamp(value, 30, 120)
        end
        input.Text = tostring(CameraFOV.Settings.FOV)
        if CameraFOV.Enabled then
            applyFOV()
        end
    end)
end

return CameraFOV
