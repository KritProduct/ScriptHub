local Config = {}

local HttpService = game:GetService("HttpService")
local CONFIG_DIR = "ScriptHub_Configs"
local CONFIG_FILE = "ScriptHub_Config.json"
local DEFAULT_NAME = "default"

local function hasFileApi()
    return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

local function hasFolderApi()
    return type(makefolder) == "function"
        and type(isfolder) == "function"
        and type(listfiles) == "function"
        and type(delfile) == "function"
end

local function sanitizeName(name)
    if type(name) ~= "string" then return nil end

    local cleaned = string.gsub(name, "[\\/:*?\"<>|]", "")
    cleaned = string.gsub(cleaned, "^%s+", "")
    cleaned = string.gsub(cleaned, "%s+$", "")
    cleaned = string.gsub(cleaned, "%.+$", "")

    if cleaned == "" then return nil end
    return cleaned
end

local function getPath(name)
    if hasFolderApi() then
        return CONFIG_DIR .. "/" .. name .. ".json"
    end
    return CONFIG_FILE
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

function Config.Save(modules, name)
    name = sanitizeName(name or DEFAULT_NAME) or DEFAULT_NAME

    if not hasFileApi() then
        return false, "Executor has no file API"
    end

    local data = {
        Version = 1,
        Name = name,
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

    local saved = pcall(function()
        if hasFolderApi() and not isfolder(CONFIG_DIR) then
            makefolder(CONFIG_DIR)
        end
        writefile(getPath(name), encoded)
    end)

    if not saved then
        return false, "Failed to write config file"
    end

    return true, "Saved " .. name
end

function Config.Load(modules, name)
    name = sanitizeName(name or DEFAULT_NAME) or DEFAULT_NAME

    if not hasFileApi() then
        return false, "Executor has no file API"
    end

    local path = getPath(name)

    local exists = pcall(function()
        return isfile(path)
    end)

    if not exists and hasFolderApi() then
        local legacyExists = pcall(function()
            return isfile(CONFIG_FILE)
        end)

        if legacyExists then
            path = CONFIG_FILE
            exists = true
        end
    end

    if not exists then
        return false, "Config not found"
    end

    local ok, raw = pcall(function()
        return readfile(path)
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

    for moduleName, entry in pairs(decoded.Modules or {}) do
        local moduleData = findModule(modules, moduleName)

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

    return true, "Loaded " .. name
end

function Config.Delete(name)
    name = sanitizeName(name)
    if not name then
        return false, "Invalid config name"
    end

    if not hasFolderApi() then
        return false, "Executor has no folder API"
    end

    local path = getPath(name)

    local exists = pcall(function()
        return isfile(path)
    end)

    if not exists then
        return false, "Config not found"
    end

    local deleted = pcall(function()
        delfile(path)
    end)

    if not deleted then
        return false, "Failed to delete config"
    end

    return true, "Deleted " .. name
end

function Config.List()
    local names = {}

    if not hasFolderApi() then
        return names
    end

    local ok, folderExists = pcall(function()
        return isfolder(CONFIG_DIR)
    end)

    if not ok or not folderExists then
        return names
    end

    local okFiles, files = pcall(function()
        return listfiles(CONFIG_DIR)
    end)

    if not okFiles or type(files) ~= "table" then
        return names
    end

    for _, path in ipairs(files) do
        local fileName = string.match(path, "([^/\\]+)$") or path
        local name = string.match(fileName, "^(.-)%.json$")
        if name then
            table.insert(names, name)
        end
    end

    table.sort(names, function(a, b)
        return string.lower(a) < string.lower(b)
    end)

    return names
end

function Config.BuildSettings(content, allModules)
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Default config: " .. CONFIG_FILE
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
        local ok, message = Config.Save(allModules, DEFAULT_NAME)
        feedback.Text = message
        feedback.TextColor3 = ok and Color3.fromRGB(60, 255, 120) or Color3.fromRGB(255, 80, 80)
    end)

    loadBtn.MouseButton1Click:Connect(function()
        local ok, message = Config.Load(allModules, DEFAULT_NAME)
        feedback.Text = message .. ", reopen settings to see new values"
        feedback.TextColor3 = ok and Color3.fromRGB(60, 255, 120) or Color3.fromRGB(255, 80, 80)
    end)
end

function Config.CreatePanel(player, allModules)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    local gui = Instance.new("ScreenGui")
    gui.Name = "ScriptHubConfigs"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 998
    gui.Parent = player:WaitForChild("PlayerGui")

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 66, 0, 32)
    toggleButton.Position = UDim2.new(0, 10, 0.5, -16)
    toggleButton.AnchorPoint = Vector2.new(0, 0.5)
    toggleButton.Text = "CONFIG"
    toggleButton.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    toggleButton.BorderSizePixel = 0
    toggleButton.TextColor3 = Color3.fromRGB(80, 140, 255)
    toggleButton.Font = Enum.Font.GothamBlack
    toggleButton.TextSize = 11
    toggleButton.AutoButtonColor = false
    toggleButton.ZIndex = 5
    toggleButton.Parent = gui

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleButton

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(80, 140, 255)
    toggleStroke.Thickness = 1
    toggleStroke.Transparency = 0.4
    toggleStroke.Parent = toggleButton

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 260, 0, 420)
    panel.Position = UDim2.new(0, -280, 0.5, -210)
    panel.AnchorPoint = Vector2.new(0, 0.5)
    panel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    panel.BorderSizePixel = 0
    panel.ZIndex = 10
    panel.Parent = gui

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 12)
    panelCorner.Parent = panel

    local panelStroke = Instance.new("UIStroke")
    panelStroke.Color = Color3.fromRGB(80, 140, 255)
    panelStroke.Thickness = 1.5
    panelStroke.Transparency = 0.3
    panelStroke.Parent = panel

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 0, 30)
    title.Position = UDim2.new(0, 12, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "CONFIGS"
    title.TextColor3 = Color3.fromRGB(80, 140, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 11
    title.Parent = panel

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 26, 0, 26)
    closeButton.Position = UDim2.new(1, -34, 0, 10)
    closeButton.Text = "X"
    closeButton.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    closeButton.BorderSizePixel = 0
    closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeButton.Font = Enum.Font.GothamBlack
    closeButton.TextSize = 12
    closeButton.AutoButtonColor = false
    closeButton.ZIndex = 11
    closeButton.Parent = panel

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton

    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(1, -24, 0, 30)
    nameInput.Position = UDim2.new(0, 12, 0, 44)
    nameInput.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    nameInput.BorderSizePixel = 0
    nameInput.PlaceholderText = "config name"
    nameInput.Text = ""
    nameInput.TextColor3 = Color3.new(1, 1, 1)
    nameInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    nameInput.Font = Enum.Font.GothamBold
    nameInput.TextSize = 12
    nameInput.TextXAlignment = Enum.TextXAlignment.Left
    nameInput.ClearTextOnFocus = false
    nameInput.ZIndex = 11
    nameInput.Parent = panel

    local namePadding = Instance.new("UIPadding")
    namePadding.PaddingLeft = UDim.new(0, 8)
    namePadding.PaddingRight = UDim.new(0, 8)
    namePadding.Parent = nameInput

    local nameCorner = Instance.new("UICorner")
    nameCorner.CornerRadius = UDim.new(0, 6)
    nameCorner.Parent = nameInput

    local createButton = Instance.new("TextButton")
    createButton.Size = UDim2.new(0.5, -18, 0, 30)
    createButton.Position = UDim2.new(0, 12, 0, 80)
    createButton.Text = "Create"
    createButton.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    createButton.BorderSizePixel = 0
    createButton.TextColor3 = Color3.new(1, 1, 1)
    createButton.Font = Enum.Font.GothamBlack
    createButton.TextSize = 12
    createButton.AutoButtonColor = false
    createButton.ZIndex = 11
    createButton.Parent = panel

    local createCorner = Instance.new("UICorner")
    createCorner.CornerRadius = UDim.new(0, 6)
    createCorner.Parent = createButton

    local refreshButton = Instance.new("TextButton")
    refreshButton.Size = UDim2.new(0.5, -18, 0, 30)
    refreshButton.Position = UDim2.new(0.5, 6, 0, 80)
    refreshButton.Text = "Refresh"
    refreshButton.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    refreshButton.BorderSizePixel = 0
    refreshButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    refreshButton.Font = Enum.Font.GothamBlack
    refreshButton.TextSize = 12
    refreshButton.AutoButtonColor = false
    refreshButton.ZIndex = 11
    refreshButton.Parent = panel

    local refreshCorner = Instance.new("UICorner")
    refreshCorner.CornerRadius = UDim.new(0, 6)
    refreshCorner.Parent = refreshButton

    local feedback = Instance.new("TextLabel")
    feedback.Size = UDim2.new(1, -24, 0, 26)
    feedback.Position = UDim2.new(0, 12, 0, 116)
    feedback.BackgroundTransparency = 1
    feedback.Text = ""
    feedback.TextColor3 = Color3.fromRGB(120, 120, 120)
    feedback.Font = Enum.Font.GothamMedium
    feedback.TextSize = 10
    feedback.TextXAlignment = Enum.TextXAlignment.Left
    feedback.TextWrapped = true
    feedback.ZIndex = 11
    feedback.Parent = panel

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -24, 1, -152)
    list.Position = UDim2.new(0, 12, 0, 144)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.ScrollBarThickness = 3
    list.ZIndex = 11
    list.Parent = panel

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = list

    local panelOpen = false

    RunService.RenderStepped:Connect(function()
        if not panelOpen then return end

        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

        if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
            pcall(function()
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end)
        end

        if not UserInputService.MouseIconEnabled then
            pcall(function()
                UserInputService.MouseIconEnabled = true
            end)
        end
    end)

    local function setFeedback(message, success)
        feedback.Text = message
        feedback.TextColor3 = success and Color3.fromRGB(60, 255, 120) or Color3.fromRGB(255, 80, 80)
    end

    local function refreshList()
        for _, child in pairs(list:GetChildren()) do
            if child ~= listLayout then
                child:Destroy()
            end
        end

        if not hasFolderApi() then
            setFeedback("Executor has no folder API, multi-configs unavailable", false)
            return
        end

        local names = Config.List()

        if #names == 0 then
            setFeedback("No configs yet. Type a name and press Create", false)
            return
        end

        for _, configName in ipairs(names) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 32)
            row.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            row.BorderSizePixel = 0
            row.ZIndex = 11
            row.Parent = list

            local rowCorner = Instance.new("UICorner")
            rowCorner.CornerRadius = UDim.new(0, 6)
            rowCorner.Parent = row

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -134, 1, 0)
            label.Position = UDim2.new(0, 8, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = configName
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.ZIndex = 12
            label.Parent = row

            local function createActionButton(text, x, color, callback)
                local button = Instance.new("TextButton")
                button.Size = UDim2.new(0, 38, 0, 24)
                button.Position = UDim2.new(1, x, 0.5, -12)
                button.Text = text
                button.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                button.BorderSizePixel = 0
                button.TextColor3 = color
                button.Font = Enum.Font.GothamBlack
                button.TextSize = 9
                button.AutoButtonColor = false
                button.ZIndex = 12
                button.Parent = row

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 5)
                corner.Parent = button

                button.MouseButton1Click:Connect(function()
                    local ok, message = callback(configName)
                    setFeedback(message, ok)
                end)
            end

            createActionButton("LOAD", -126, Color3.fromRGB(80, 140, 255), function(name)
                local ok, message = Config.Load(allModules, name)
                if ok then
                    message = message .. ", reopen settings to see values"
                end
                return ok, message
            end)

            createActionButton("SAVE", -86, Color3.fromRGB(60, 255, 120), function(name)
                return Config.Save(allModules, name)
            end)

            createActionButton("DEL", -46, Color3.fromRGB(255, 80, 80), function(name)
                local ok, message = Config.Delete(name)
                refreshList()
                return ok, message
            end)
        end
    end

    createButton.MouseButton1Click:Connect(function()
        local name = sanitizeName(nameInput.Text)
        if not name then
            setFeedback("Enter a valid config name", false)
            return
        end

        local ok, message = Config.Save(allModules, name)
        setFeedback(message, ok)

        if ok then
            nameInput.Text = ""
            refreshList()
        end
    end)

    refreshButton.MouseButton1Click:Connect(function()
        refreshList()
    end)

    toggleButton.MouseButton1Click:Connect(function()
        panelOpen = true
        panel:TweenPosition(
            UDim2.new(0, 10, 0.5, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quart,
            0.3,
            true
        )
    end)

    closeButton.MouseButton1Click:Connect(function()
        panelOpen = false
        panel:TweenPosition(
            UDim2.new(0, -280, 0.5, 0),
            Enum.EasingDirection.In,
            Enum.EasingStyle.Quart,
            0.3,
            true
        )
    end)

    refreshList()

    return {
        Gui = gui,
        Panel = panel,
        Refresh = refreshList
    }
end

return Config
