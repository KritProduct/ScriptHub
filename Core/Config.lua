local Config = {}

local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "ScriptHub_Config.json"

local function hasFileApi()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

local function encodeValue(value)
    if typeof(value) == "Color3" then
        return { __type = "Color3", R = value.R, G = value.G, B = value.B }
    elseif type(value) == "table" then
        local result = {}
        for key, item in pairs(value) do
            result[key] = encodeValue(item)
        end
        return result
    end

    return value
end

local function decodeValue(value)
    if type(value) == "table" then
        if value.__type == "Color3" then
            return Color3.new(value.R, value.G, value.B)
        end

        local result = {}
        for key, item in pairs(value) do
            result[key] = decodeValue(item)
        end
        return result
    end

    return value
end

local function findModule(modules, name)
    for _, moduleData in pairs(modules) do
        if moduleData.Name == name then
            return moduleData
        end
    end

    return nil
end

function Config.Save(modules)
    local data = {
        Version = 1,
        Modules = {}
    }

    for _, moduleData in pairs(modules) do
        if moduleData.Name and moduleData.Module then
            local keybind = moduleData.GetKeybind and moduleData.GetKeybind()

            data.Modules[moduleData.Name] = {
                Enabled = moduleData.GetEnabled and moduleData.GetEnabled() or false,
                Keybind = keybind and keybind.Name or nil,
                Settings = encodeValue(moduleData.Module.Settings or {})
            }
        end
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)

    if not ok then
        return false, "Failed to encode config"
    end

    if not hasFileApi() then
        return false, "Executor has no file API"
    end

    local saved = pcall(function()
        writefile(CONFIG_FILE, encoded)
    end)

    if not saved then
        return false, "Failed to write config file"
    end

    return true, "Config saved"
end

function Config.Load(modules)
    if not hasFileApi() then
        return false, "Executor has no file API"
    end

    local exists = pcall(function()
        return isfile(CONFIG_FILE)
    end)

    if not exists then
        return false, "Config file not found"
    end

    local ok, raw = pcall(function()
        return readfile(CONFIG_FILE)
    end)

    if not ok or not raw then
        return false, "Failed to read config file"
    end

    local decoded
    ok, decoded = pcall(function()
        return HttpService:JSONDecode(raw)
    end)

    if not ok or type(decoded) ~= "table" then
        return false, "Config file is corrupted"
    end

    for name, entry in pairs(decoded.Modules or {}) do
        local moduleData = findModule(modules, name)

        if moduleData and moduleData.Module then
            if entry.Settings and moduleData.Module.Settings then
                local settings = decodeValue(entry.Settings)
                for key, value in pairs(settings) do
                    moduleData.Module.Settings[key] = value
                end
            end

            if moduleData.SetKeybind then
                local key = nil
                if entry.Keybind then
                    local keyOk, keyValue = pcall(function()
                        return Enum.KeyCode[entry.Keybind]
                    end)
                    if keyOk then
                        key = keyValue
                    end
                end
                moduleData.SetKeybind(key)
            end

            if moduleData.SetEnabled then
                moduleData.SetEnabled(entry.Enabled == true)
            end
        end
    end

    return true, "Config loaded"
end

function Config.BuildSettings(content, allModules)
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Saved to " .. CONFIG_FILE
    statusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 11
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = content

    local buttons = Instance.new("Frame")
    buttons.Size = UDim2.new(1, 0, 0, 30)
    buttons.BackgroundTransparency = 1
    buttons.Parent = content

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.48, 0, 0, 30)
    saveBtn.Text = "Save"
    saveBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    saveBtn.BorderSizePixel = 0
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBtn.Font = Enum.Font.GothamBlack
    saveBtn.TextSize = 12
    saveBtn.AutoButtonColor = false
    saveBtn.Parent = buttons

    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 6)
    saveCorner.Parent = saveBtn

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0.48, 0, 0, 30)
    loadBtn.Position = UDim2.new(0.52, 0, 0, 0)
    loadBtn.Text = "Load"
    loadBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    loadBtn.BorderSizePixel = 0
    loadBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    loadBtn.Font = Enum.Font.GothamBlack
    loadBtn.TextSize = 12
    loadBtn.AutoButtonColor = false
    loadBtn.Parent = buttons

    local loadCorner = Instance.new("UICorner")
    loadCorner.CornerRadius = UDim.new(0, 6)
    loadCorner.Parent = loadBtn

    local feedback = Instance.new("TextLabel")
    feedback.Size = UDim2.new(1, 0, 0, 34)
    feedback.BackgroundTransparency = 1
    feedback.Text = "Saves settings, keybinds and enabled modules"
    feedback.TextColor3 = Color3.fromRGB(120, 120, 120)
    feedback.Font = Enum.Font.GothamMedium
    feedback.TextSize = 10
    feedback.TextXAlignment = Enum.TextXAlignment.Left
    feedback.TextWrapped = true
    feedback.Parent = content

    saveBtn.MouseButton1Click:Connect(function()
        local ok, message = Config.Save(allModules)
        feedback.Text = message
        feedback.TextColor3 = ok and Color3.fromRGB(60, 255, 120) or Color3.fromRGB(255, 80, 80)
    end)

    loadBtn.MouseButton1Click:Connect(function()
        local ok, message = Config.Load(allModules)
        feedback.Text = message .. ", reopen settings to see new values"
        feedback.TextColor3 = ok and Color3.fromRGB(60, 255, 120) or Color3.fromRGB(255, 80, 80)
    end)
end

return Config
