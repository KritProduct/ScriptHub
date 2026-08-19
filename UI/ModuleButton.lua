local ModuleButton = {}

function ModuleButton.Create(parent, name, tab, toggleCallback)
    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, 0, 0, 50)
    wrapper.BackgroundTransparency = 1
    wrapper.Parent = parent
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 45)
    button.Text = name .. ": OFF"
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.AutoButtonColor = false
    button.Parent = wrapper
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local enabled = false
    
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            button.Text = name .. ": ON"
            button.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        else
            button.Text = name .. ": OFF"
            button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end
        if toggleCallback then toggleCallback(enabled) end
    end)
    
    return {
        Wrapper = wrapper,
        Button = button,
        Tab = tab,
        SetVisible = function(visible) wrapper.Visible = visible end
    }
end

return ModuleButton
