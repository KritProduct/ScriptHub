local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Window = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/UI/Window.lua"))()
local Tabs = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/UI/Tabs.lua"))()
local ModuleButton = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/UI/ModuleButton.lua"))()
local Fly = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Fly.lua"))()
local Noclip = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Noclip.lua"))()
local Speed = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Speed.lua"))()
local PlayerESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/PlayerESP.lua"))()
local SkeletonESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/SkeletonESP.lua"))()
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Aimbot.lua"))()
local TriggerBot = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/TriggerBot.lua"))()
local InfinityJump = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/InfinityJump.lua"))()
local BunnyHop = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/BunnyHop.lua"))()
local Teleport = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Teleport.lua"))()
local Gravity = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Gravity.lua"))()
local NoFog = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/NoFog.lua"))()
local Fullbright = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Fullbright.lua"))()
local AntiAFK = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/AntiAFK.lua"))()
local AutoClicker = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/AutoClicker.lua"))()
local Rejoin = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Rejoin.lua"))()
local TimeChanger = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/TimeChanger.lua"))()
local ChatSpammer = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/ChatSpammer.lua"))()
local BlockSpawn = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/BlockSpawn.lua"))()
local CameraFOV = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/CameraFOV.lua"))()
local FreeCamera = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/FreeCamera.lua"))()
local Trail = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Trail.lua"))()
local Watermark = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Watermark.lua"))()
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Core/Config.lua"))()

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
    if input.KeyCode == Enum.KeyCode.K then
        if input.gameProcessedEvent then return end
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
