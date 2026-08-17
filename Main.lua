local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local Window = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/UI/Window.lua"))()
local Tabs = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/UI/Tabs.lua"))()
local ModuleButton = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/UI/ModuleButton.lua"))()
local Fly = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/Functions/Fly.lua"))()
local Noclip = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/Functions/Noclip.lua"))()
local Speed = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/Functions/Speed.lua"))()
local ESP = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/Functions/ESP.lua"))()
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/KritProduct/ScriptHub/main/Functions/Aimbot.lua"))()
local TriggerBot = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/Functions/TriggerBot.lua"))()
local InfinityJump = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/Functions/InfinityJump.lua"))()
local BunnyHop = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/Functions/BunnyHop.lua"))()
local Teleport = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/Functions/Teleport.lua"))()

local Tracers = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/Functions/Tracers.lua"))()

local NoFog = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/Functions/NoFog.lua"))()
local Fullbright = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/KritProduct/ScriptHub@main/Functions/Fullbright.lua"))()

local window = Window.Create(player)
local tabs = Tabs.Create(window.LeftPanel)

tabs.CreateTab("Movement", 10)
tabs.CreateTab("Visuals", 60)
tabs.CreateTab("Combat", 110)

local moduleContainer = Instance.new("ScrollingFrame")
moduleContainer.Size = UDim2.new(1, -20, 1, -20)
moduleContainer.Position = UDim2.new(0, 10, 0, 10)
moduleContainer.BackgroundTransparency = 1
moduleContainer.BorderSizePixel = 0
moduleContainer.CanvasSize = UDim2.new(0, 0, 0, 900)
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
            moduleTable.BuildSettings(content)
        end
    end)

    table.insert(allModules, moduleData)
    return moduleData
end

createModule("FLY", "Movement", Fly)
createModule("NOCLIP", "Movement", Noclip)
createModule("SPEED", "Movement", Speed)
createModule("BUNNY HOP", "Movement", BunnyHop)
createModule("TELEPORT", "Movement", Teleport)

createModule("INFINITY JUMP", "Movement", InfinityJump)
createModule("ESP", "Visuals", ESP)
createModule("TRACERS", "Visuals", Tracers)

createModule("NO FOG", "Visuals", NoFog)
createModule("FULLBRIGHT", "Visuals", Fullbright)
createModule("AIMBOT", "Combat", Aimbot)
createModule("TRIGGER BOT", "Combat", TriggerBot)

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

print("Script Hub loaded!")
print("K - toggle menu")

