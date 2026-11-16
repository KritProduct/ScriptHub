local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local BUILD_VERSION = "1.4"
local BASE_URL = "https://raw.githubusercontent.com/KritProduct/ScriptHub/main/"
local CACHE_BUST = tostring(math.floor(os.time()))

local PlayerGui = player:WaitForChild("PlayerGui")

for _, child in ipairs(PlayerGui:GetChildren()) do
    if child.Name == "ScriptHub" or child.Name == "ScriptHubConfigs" then
        child:Destroy()
    end
end

for _, child in ipairs(workspace:GetChildren()) do
    if child.Name == "ScriptHubWalkOnWater" or child.Name == "ScriptHubAirWalk" then
        child:Destroy()
    end
end

local function loadModule(path, optional)
    local url = BASE_URL .. path .. "?v=" .. CACHE_BUST
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if not ok then
        if optional then
            warn("[ScriptHub] failed to load " .. path .. ": " .. tostring(result))
            return nil
        end

        error("ScriptHub failed to load " .. path .. ": " .. tostring(result))
    end

    return result
end

local Window = loadModule("UI/Window.lua")
local Tabs = loadModule("UI/Tabs.lua")
local ModuleButton = loadModule("UI/ModuleButton.lua")
local Fly = loadModule("Functions/Fly.lua", true)
local Noclip = loadModule("Functions/Noclip.lua", true)
local Speed = loadModule("Functions/Speed.lua", true)
local PlayerESP = loadModule("Functions/PlayerESP.lua", true)
local SkeletonESP = loadModule("Functions/SkeletonESP.lua", true)
local Aimbot = loadModule("Functions/Aimbot.lua", true)
local TriggerBot = loadModule("Functions/TriggerBot.lua", true)
local InfinityJump = loadModule("Functions/InfinityJump.lua", true)
local BunnyHop = loadModule("Functions/BunnyHop.lua", true)
local Teleport = loadModule("Functions/Teleport.lua", true)
local Gravity = loadModule("Functions/Gravity.lua", true)
local NoFog = loadModule("Functions/NoFog.lua", true)
local Fullbright = loadModule("Functions/Fullbright.lua", true)
local AntiAFK = loadModule("Functions/AntiAFK.lua", true)
local AutoClicker = loadModule("Functions/AutoClicker.lua", true)
local Rejoin = loadModule("Functions/Rejoin.lua", true)
local TimeChanger = loadModule("Functions/TimeChanger.lua", true)
local ChatSpammer = loadModule("Functions/ChatSpammer.lua", true)
local BlockSpawn = loadModule("Functions/BlockSpawn.lua", true)
local CameraFOV = loadModule("Functions/CameraFOV.lua", true)
local FreeCamera = loadModule("Functions/FreeCamera.lua", true)
local Trail = loadModule("Functions/Trail.lua", true)
local Watermark = loadModule("Functions/Watermark.lua", true)
local AntiAim = loadModule("Functions/AntiAim.lua", true)
local HitboxExpander = loadModule("Functions/HitboxExpander.lua", true)
local Spinbot = loadModule("Functions/Spinbot.lua", true)
local WalkOnWater = loadModule("Functions/WalkOnWater.lua", true)
local AirWalk = loadModule("Functions/AirWalk.lua", true)
local TeleportCoords = loadModule("Functions/TeleportCoords.lua", true)
local AtmosphereEditor = loadModule("Functions/AtmosphereEditor.lua", true)
local LightingEditor = loadModule("Functions/LightingEditor.lua", true)
local Config = loadModule("Core/Config.lua")

local window = Window.Create(player)
window.Title.Text = "SCRIPT HUB " .. BUILD_VERSION

local tabs = Tabs.Create(window.LeftPanel)

tabs.CreateTab("Movement", 10)
tabs.CreateTab("Visuals", 60)
tabs.CreateTab("Combat", 110)
tabs.CreateTab("Misc", 160)

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 8)
searchBox.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
searchBox.BorderSizePixel = 0
searchBox.PlaceholderText = "Search modules..."
searchBox.Text = ""
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
searchBox.Font = Enum.Font.GothamBold
searchBox.TextSize = 12
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = window.RightPanel

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = searchBox

local moduleContainer = Instance.new("ScrollingFrame")
moduleContainer.Size = UDim2.new(1, -20, 1, -60)
moduleContainer.Position = UDim2.new(0, 10, 0, 48)
moduleContainer.BackgroundTransparency = 1
moduleContainer.BorderSizePixel = 0
moduleContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
moduleContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
moduleContainer.ScrollBarThickness = 3
moduleContainer.Parent = window.RightPanel

local moduleList = Instance.new("UIListLayout")
moduleList.Padding = UDim.new(0, 8)
moduleList.Parent = moduleContainer

local allModules = {}
local applyOrder = nil
local refreshView = nil

local function createModule(name, tab, moduleTable)
    if not moduleTable then return nil end

    local moduleData = ModuleButton.Create(moduleContainer, name, tab, function(enabled)
        if enabled then
            moduleTable.Start(player)
        else
            moduleTable.Stop(player)
        end
    end, function(content)
        if moduleTable.BuildSettings then
            moduleTable.BuildSettings(content, player)
        end
    end, function()
        if refreshView then
            refreshView()
        end
    end)

    table.insert(allModules, moduleData)
    moduleData.Module = moduleTable
    return moduleData
end

createModule("FLY", "Movement", Fly)
createModule("NOCLIP", "Movement", Noclip)
createModule("SPEED", "Movement", Speed)
createModule("BUNNY HOP", "Movement", BunnyHop)
createModule("TELEPORT", "Movement", Teleport)
createModule("INFINITY JUMP", "Movement", InfinityJump)
createModule("GRAVITY", "Movement", Gravity)
createModule("BLOCK SPAWN", "Movement", BlockSpawn)
createModule("FREECAMERA", "Movement", FreeCamera)
createModule("WALK ON WATER", "Movement", WalkOnWater)
createModule("AIR WALK", "Movement", AirWalk)
createModule("TELEPORT COORDS", "Movement", TeleportCoords)
createModule("PLAYER ESP", "Visuals", PlayerESP)
createModule("SKELETON ESP", "Visuals", SkeletonESP)
createModule("NO FOG", "Visuals", NoFog)
createModule("FULLBRIGHT", "Visuals", Fullbright)
createModule("CAMERA FOV", "Visuals", CameraFOV)
createModule("ATMOSPHERE EDITOR", "Visuals", AtmosphereEditor)
createModule("LIGHTING EDITOR", "Visuals", LightingEditor)
createModule("TRAIL", "Visuals", Trail)
createModule("WATERMARK", "Visuals", Watermark)
createModule("AIMBOT", "Combat", Aimbot)
createModule("TRIGGER BOT", "Combat", TriggerBot)
createModule("ANTI AIM", "Combat", AntiAim)
createModule("HITBOX EXPANDER", "Combat", HitboxExpander)
createModule("SPINBOT", "Combat", Spinbot)
createModule("ANTI AFK", "Misc", AntiAFK)
createModule("AUTO CLICKER", "Misc", AutoClicker)
createModule("REJOIN", "Misc", Rejoin)
createModule("TIME CHANGER", "Misc", TimeChanger)
createModule("CHAT SPAMMER", "Misc", ChatSpammer)

local configModule = ModuleButton.Create(moduleContainer, "CONFIG", "Misc", function() end, function(content)
    Config.BuildSettings(content, allModules)
end, function()
    if refreshView then
        refreshView()
    end
end)

table.insert(allModules, configModule)

local okPanel, panelError = pcall(function()
    Config.CreatePanel(player, allModules)
end)

if not okPanel then
    warn("[ScriptHub] config panel error: " .. tostring(panelError))
end

applyOrder = function()
    local favorites = {}
    local normal = {}

    for _, moduleData in ipairs(allModules) do
        local isFavorite = moduleData.GetFavorite and moduleData.GetFavorite()
        if isFavorite then
            table.insert(favorites, moduleData)
        else
            table.insert(normal, moduleData)
        end
    end

    for index, moduleData in ipairs(favorites) do
        moduleData.SetLayoutOrder(index)
    end

    for index, moduleData in ipairs(normal) do
        moduleData.SetLayoutOrder(1000 + index)
    end
end

applyOrder()

local currentTab = "Movement"
local searchQuery = ""

local function applyFilter()
    for _, moduleData in pairs(allModules) do
        local visible
        local isFavorite = moduleData.GetFavorite and moduleData.GetFavorite()

        if searchQuery ~= "" then
            visible = string.find(string.lower(moduleData.Name), searchQuery, 1, true) ~= nil
        else
            visible = moduleData.Tab == currentTab or isFavorite == true
        end

        moduleData.SetVisible(visible)
    end

    if applyOrder then
        applyOrder()
    end
end

refreshView = applyFilter

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    searchQuery = string.lower(searchBox.Text)
    applyFilter()
end)

tabs.SetOnChanged(function(tabName)
    currentTab = tabName
    applyFilter()
end)

tabs.SetActiveTab("Movement")

window.CloseBtn.MouseButton1Click:Connect(function()
    window.Toggle()
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.K then
        if UserInputService:GetFocusedTextBox() then return end
        window.Toggle()
    end
end)

local function makeDraggable(frame, handle)
    local dragging = false
    local startPos = nil
    local frameStart = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = input.Position
            frameStart = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - startPos
            frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(window.Main, window.TitleBar)
