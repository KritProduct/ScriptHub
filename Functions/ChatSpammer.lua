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

return ChatSpammer
