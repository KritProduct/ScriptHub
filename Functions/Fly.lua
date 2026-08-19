
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
    
<<<<<<< HEAD
    function window.FreeMouse()
        pcall(function()
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end)
=======
    if Fly.Instance then
        Fly.Instance.Connection:Disconnect()
        Fly.Instance.BodyGyro:Destroy()
        Fly.Instance.BodyVelocity:Destroy()
        Fly.Instance.Humanoid.PlatformStand = false
        Fly.Instance = nil
    end
end

function Fly.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Speed: " .. math.floor(Fly.Settings.Speed)
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 30)
    input.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    input.BorderSizePixel = 0
    input.Text = tostring(math.floor(Fly.Settings.Speed))
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 12
    input.Parent = content
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input
    
    input.FocusLost:Connect(function()
        local value = tonumber(input.Text)
        if value then
            Fly.Settings.Speed = math.clamp(value, 10, 1000)
            input.Text = tostring(math.floor(Fly.Settings.Speed))
            label.Text = "Speed: " .. math.floor(Fly.Settings.Speed)
        end
    end)
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 35)
    slider.BackgroundTransparency = 1
    slider.Parent = content
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0, 50, 0, 20)
    sliderLabel.Position = UDim2.new(1, -50, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = tostring(math.floor(Fly.Settings.Speed))
    sliderLabel.TextColor3 = Color3.fromRGB(80, 140, 255)
    sliderLabel.Font = Enum.Font.GothamBlack
    sliderLabel.TextSize = 11
    sliderLabel.Parent = slider
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -60, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 20)
    track.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    track.BorderSizePixel = 0
    track.Parent = slider
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 0, 6)
    fill.Position = UDim2.new(0, 0, 0, 20)
    fill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fill
    
    local function updateVisual(value)
        local percent = (value - 10) / (1000 - 10)
        fill.Size = UDim2.new(0, percent * track.AbsoluteSize.X, 0, 6)
        sliderLabel.Text = tostring(math.floor(value))
>>>>>>> 4b4983b9d4ecdb1d9da3ae4ec3d8e01da1b2fb7f
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
    
<<<<<<< HEAD
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
=======
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local RunService = game:GetService("RunService")
            local UserInputService = game:GetService("UserInputService")
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local mouseX = UserInputService:GetMouseLocation().X
                local startX = track.AbsolutePosition.X
                local endX = track.AbsolutePosition.X + track.AbsoluteSize.X
                local percent = math.clamp((mouseX - startX) / (endX - startX), 0, 1)
                local value = 10 + percent * (1000 - 10)
                Fly.Settings.Speed = value
                label.Text = "Speed: " .. math.floor(value)
                input.Text = tostring(math.floor(value))
                updateVisual(value)
            end)
            local endConnection
            endConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                    endConnection:Disconnect()
                end
            end)
>>>>>>> 4b4983b9d4ecdb1d9da3ae4ec3d8e01da1b2fb7f
        end
    end
    
    window.AnimateOpen()
    
    return window
end

return Window
