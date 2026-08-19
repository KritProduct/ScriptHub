local Tabs = {}

function Tabs.Create(parent)
    local tabButtons = {}
    local activeTab = nil
    local onChanged = nil
    
    local function CreateTab(name, y)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -20, 0, 40)
        tabBtn.Position = UDim2.new(0, 10, 0, y)
        tabBtn.Text = name
        tabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        tabBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 13
        tabBtn.AutoButtonColor = false
        tabBtn.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = tabBtn
        
        tabButtons[name] = tabBtn
        
        tabBtn.MouseButton1Click:Connect(function()
            activeTab = name
            for tabName, btn in pairs(tabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                btn.TextColor3 = Color3.fromRGB(160, 160, 160)
            end
            tabBtn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            tabBtn.TextColor3 = Color3.new(1, 1, 1)
            
            if onChanged then onChanged(name) end
        end)
        
        return tabBtn
    end
    
    local system = {
        TabButtons = tabButtons,
        CreateTab = CreateTab,
        GetActiveTab = function() return activeTab end,
        SetActiveTab = function(name)
            activeTab = name
            for tabName, btn in pairs(tabButtons) do
                if tabName == name then
                    btn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
                    btn.TextColor3 = Color3.new(1, 1, 1)
                else
                    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    btn.TextColor3 = Color3.fromRGB(160, 160, 160)
                end
            end
            if onChanged then onChanged(name) end
        end,
        SetOnChanged = function(callback) onChanged = callback end
    }
    
    return system
end

return Tabs
