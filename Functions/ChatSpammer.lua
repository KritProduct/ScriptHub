local ChatSpammer = {}

ChatSpammer.Settings = {
    Message = "Hello!",
    Delay = 5,
    Keybind = nil
}

ChatSpammer.Enabled = false
ChatSpammer.Connection = nil
ChatSpammer.LastSend = 0

function ChatSpammer.Start(player)
    local RunService = game:GetService("RunService")
    
    ChatSpammer.Enabled = true
    
    ChatSpammer.Connection = RunService.Heartbeat:Connect(function()
        if not ChatSpammer.Enabled then return end
        
        if os.clock() - ChatSpammer.LastSend >= ChatSpammer.Settings.Delay then
            ChatSpammer.LastSend = os.clock()
            
            pcall(function()
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(ChatSpammer.Settings.Message, "All")
            end)
        end
    end)
end

function ChatSpammer.Stop()
    ChatSpammer.Enabled = false
    
    if ChatSpammer.Connection then
        ChatSpammer.Connection:Disconnect()
        ChatSpammer.Connection = nil
    end
end

function ChatSpammer.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Message:"
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 30)
    input.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    input.BorderSizePixel = 0
    input.Text = ChatSpammer.Settings.Message
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 12
    input.Parent = content
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input
    
    input.FocusLost:Connect(function()
        ChatSpammer.Settings.Message = input.Text
    end)
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 35)
    slider.BackgroundTransparency = 1
    slider.Parent = content
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0, 50, 0, 20)
    sliderLabel.Position = UDim2.new(1, -50, 0, 0)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = tostring(ChatSpammer.Settings.Delay) .. "s"
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
        local percent = (value - 1) / (300 - 1)
        fill.Size = UDim2.new(0, percent * track.AbsoluteSize.X, 0, 6)
        sliderLabel.Text = tostring(math.floor(value)) .. "s"
    end
    
    updateVisual(ChatSpammer.Settings.Delay)
    
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
                local value = 1 + percent * (300 - 1)
                ChatSpammer.Settings.Delay = value
                updateVisual(value)
            end)
            local endConnection
            endConnection = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                    endConnection:Disconnect()
                end
            end)
        end
    end)
end

return ChatSpammer
