local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local BASE_URL = "https://raw.githubusercontent.com/KritProduct/ScriptHub/main/"
local CACHE_BUST = tostring(math.floor(os.time()))

local function loadModule(path)
    local url = BASE_URL .. path .. "?v=" .. CACHE_BUST
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if not ok then
        error("ScriptHub failed to load " .. path .. ": " .. tostring(result))
    end

    return result
end

local Window = loadModule("UI/Window.lua")
local Tabs = loadModule("UI/Tabs.lua")
local ModuleButton = loadModule("UI/ModuleButton.lua")
local Fly = loadModule("Functions/Fly.lua")
local Noclip = loadModule("Functions/Noclip.lua")
local Speed = loadModule("Functions/Speed.lua")
local PlayerESP = loadModule("Functions/PlayerESP.lua")
local SkeletonESP = loadModule("Functions/SkeletonESP.lua")
local Aimbot = loadModule("Functions/Aimbot.lua")
local TriggerBot = loadModule("Functions/TriggerBot.lua")
local InfinityJump = loadModule("Functions/InfinityJump.lua")
local BunnyHop = loadModule("Functions/BunnyHop.lua")
local Teleport = loadModule("Functions/Teleport.lua")
local Gravity = loadModule("Functions/Gravity.lua")
local NoFog = loadModule("Functions/NoFog.lua")
local Fullbright = loadModule("Functions/Fullbright.lua")
local AntiAFK = loadModule("Functions/AntiAFK.lua")
local AutoClicker = loadModule("Functions/AutoClicker.lua")
local Rejoin = loadModule("Functions/Rejoin.lua")
local TimeChanger = loadModule("Functions/TimeChanger.lua")
local ChatSpammer = loadModule("Functions/ChatSpammer.lua")
local BlockSpawn = loadModule("Functions/BlockSpawn.lua")
local CameraFOV = loadModule("Functions/CameraFOV.lua")
local FreeCamera = loadModule("Functions/FreeCamera.lua")
local Trail = loadModule("Functions/Trail.lua")
local Watermark = loadModule("Functions/Watermark.lua")
local Config = loadModule("Core/Config.lua")

local window = Window.Create(player)
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

local function createModule(name, tab, moduleTable)
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
createModule("PLAYER ESP", "Visuals", PlayerESP)
createModule("SKELETON ESP", "Visuals", SkeletonESP)
createModule("NO FOG", "Visuals", NoFog)
createModule("FULLBRIGHT", "Visuals", Fullbright)
createModule("CAMERA FOV", "Visuals", CameraFOV)
createModule("TRAIL", "Visuals", Trail)
createModule("WATERMARK", "Visuals", Watermark)
createModule("AIMBOT", "Combat", Aimbot)
createModule("TRIGGER BOT", "Combat", TriggerBot)
createModule("ANTI AFK", "Misc", AntiAFK)
createModule("AUTO CLICKER", "Misc", AutoClicker)
createModule("REJOIN", "Misc", Rejoin)
createModule("TIME CHANGER", "Misc", TimeChanger)
createModule("CHAT SPAMMER", "Misc", ChatSpammer)

local configModule = ModuleButton.Create(moduleContainer, "CONFIG", "Misc", function() end, function(content)
    Config.BuildSettings(content, allModules)
end)

table.insert(allModules, configModule)

Config.CreatePanel(player, allModules)

local currentTab = "Movement"
local searchQuery = ""

local function applyFilter()
    for _, moduleData in pairs(allModules) do
        local visible

        if searchQuery ~= "" then
            visible = string.find(string.lower(moduleData.Name), searchQuery, 1, true) ~= nil
        else
            visible = moduleData.Tab == currentTab
        end

        moduleData.SetVisible(visible)
    end
end

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
