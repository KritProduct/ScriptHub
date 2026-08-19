local Tabs = {}

function Tabs.Create(parent)
    local tabButtons = {}
    local activeTab = nil
    local onChanged = nil
    
    local function CreateTab(name, y)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 35)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.AutoButtonColor = false
        btn.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        tabButtons[name] = btn
        
        btn.MouseButton1Click:Connect(function()
            activeTab = name
            for tabName, tabBtn in pairs(tabButtons) do
                tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
            btn.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
            btn.TextColor3 = Color3.new(1, 1, 1)
            
            if onChanged then onChanged(name) end
        end)
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
                    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
                end
            end
            if onChanged then onChanged(name) end
        end,
        SetOnChanged = function(callback) onChanged = callback end
    }
    
    return system
end

return Tabs
