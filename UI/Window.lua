local Window = {}
local TweenService = game:GetService("TweenService")

function Window.Create(player)
    local gui = Instance.new("ScreenGui")
    gui.Name = "UI"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 0, 0, 0)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = main
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "UI"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0, 6)
    closeBtn.Text = "X"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 14)
    closeCorner.Parent = closeBtn
    
    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 120, 1, -40)
    leftPanel.Position = UDim2.new(0, 0, 0, 40)
    leftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = main
    
    local rightPanel = Instance.new("Frame")
    rightPanel.Size = UDim2.new(1, -120, 1, -40)
    rightPanel.Position = UDim2.new(0, 120, 0, 40)
    rightPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = main
    
    local window = {
        Gui = gui,
        Main = main,
        TitleBar = titleBar,
        LeftPanel = leftPanel,
        RightPanel = rightPanel,
        CloseBtn = closeBtn,
        Visible = true
    }
    
    function window.AnimateOpen()
        TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 500)}):Play()
    end
    
    function window.AnimateClose()
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
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
