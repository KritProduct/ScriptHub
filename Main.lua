local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Window = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/UI/Window.lua"))()
local Tabs = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/UI/Tabs.lua"))()
local ModuleButton = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/UI/ModuleButton.lua"))()
local Fly = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Fly.lua"))()
local Noclip = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Noclip.lua"))()
local Speed = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Speed.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/ESP.lua"))()
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

local window = Window.Create(player)
local tabs = Tabs.Create(window.LeftPanel)

tabs.CreateTab("Movement", 10)
tabs.CreateTab("Visuals", 60)
tabs.CreateTab("Combat", 110)
tabs.CreateTab("Misc", 160)

local moduleContainer = Instance.new("ScrollingFrame")
moduleContainer.Size = UDim2.new(1, -20, 1, -20)
moduleContainer.Position = UDim2.new(0, 10, 0, 10)
moduleContainer.BackgroundTransparency = 1
moduleContainer.BorderSizePixel = 0
moduleContainer.CanvasSize = UDim2.new(0, 0, 0, 1000)
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
    end)

    table.insert(allModules, moduleData)
    return moduleData
end

createModule("Fly", "Movement", Fly)
createModule("Noclip", "Movement", Noclip)
createModule("Speed", "Movement", Speed)
createModule("Bunny Hop", "Movement", BunnyHop)
createModule("Teleport", "Movement", Teleport)
createModule("Infinity Jump", "Movement", InfinityJump)
createModule("Gravity", "Movement", Gravity)
createModule("ESP", "Visuals", ESP)
createModule("No Fog", "Visuals", NoFog)
createModule("Fullbright", "Visuals", Fullbright)
createModule("Aimbot", "Combat", Aimbot)
createModule("TriggerBot", "Combat", TriggerBot)
createModule("Anti AFK", "Misc", AntiAFK)
createModule("Auto Clicker", "Misc", AutoClicker)
createModule("Rejoin", "Misc", Rejoin)
createModule("Time Changer", "Misc", TimeChanger)
createModule("Chat Spammer", "Misc", ChatSpammer)

tabs.SetOnChanged(function(tabName)
    for _, moduleData in pairs(allModules) do
        moduleData.SetVisible(moduleData.Tab == tabName)
    end
end)

tabs.SetActiveTab("Movement")

window.CloseBtn.MouseButton1Click:Connect(function()
    window.Toggle()
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
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
