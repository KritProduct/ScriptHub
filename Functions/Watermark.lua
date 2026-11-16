local Watermark = {}

Watermark.Settings = {
    Keybind = nil
}

Watermark.Enabled = false
Watermark.Gui = nil
Watermark.FrameConnection = nil
Watermark.Session = nil

function Watermark.Start(player)
    local RunService = game:GetService("RunService")
    local Stats = game:GetService("Stats")

    if Watermark.Enabled then return end
    Watermark.Enabled = true
    
    local session = {}
    Watermark.Session = session

    local gui = Instance.new("ScreenGui")
    gui.Name = "ScriptHubWatermark"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999

    local ok, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)

    if ok and coreGui then
        gui.Parent = coreGui
    else
        gui.Parent = player:WaitForChild("PlayerGui")
    end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 0, 0, 26)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    label.BackgroundTransparency = 0.25
    label.BorderSizePixel = 0
    label.Text = "  SCRIPT HUB  "
    label.TextColor3 = Color3.fromRGB(80, 140, 255)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = label

    Watermark.Gui = gui

    local frames = 0
    Watermark.FrameConnection = RunService.RenderStepped:Connect(function()
        frames += 1
    end)

    task.spawn(function()
        while Watermark.Enabled and Watermark.Session == session do
            local fps = math.floor(frames * 2 + 0.5)
            frames = 0

            local pingText = "N/A"
            pcall(function()
                local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                if ping and ping > 0 then
                    pingText = tostring(math.floor(ping + 0.5)) .. "ms"
                else
                    local networkPing = player:GetNetworkPing() * 1000
                    if networkPing and networkPing > 0 then
                        pingText = tostring(math.floor(networkPing + 0.5)) .. "ms"
                    end
                end
            end)

            label.Text = string.format("  SCRIPT HUB  |  FPS: %d  |  PING: %s  |  %s  ", fps, pingText, player.Name)

            task.wait(0.5)
        end
    end)
end

function Watermark.Stop()
    Watermark.Enabled = false
    Watermark.Session = nil

    if Watermark.FrameConnection then
        Watermark.FrameConnection:Disconnect()
        Watermark.FrameConnection = nil
    end

    if Watermark.Gui then
        Watermark.Gui:Destroy()
        Watermark.Gui = nil
    end
end

function Watermark.BuildSettings(content)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "Shows FPS, ping and nickname"
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = content
end

return Watermark
