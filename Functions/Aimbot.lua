local Aimbot = {}

Aimbot.FOV = 150
Aimbot.Speed = 10
Aimbot.WallCheck = false
Aimbot.FriendCheck = false
Aimbot.Enabled = false
Aimbot.Connection = nil

function Aimbot.IsVisible(player, target)
    if not Aimbot.WallCheck then return true end
    
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local targetChar = target.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local ray = workspace:Raycast(root.Position, (targetRoot.Position - root.Position).Unit * 1000, raycastParams)
    if ray and ray.Instance then
        return ray.Instance:IsDescendantOf(targetChar)
    end
    return true
end

function Aimbot.IsFriend(player, target)
    if not Aimbot.FriendCheck then return false end
    if player.Team and target.Team then
        return player.Team == target.Team
    end
    return false
end

function Aimbot.Start(player)
    local RunService = game:GetService("RunService")
    
    Aimbot.Enabled = true
    
    Aimbot.Connection = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        local closest = nil
        local closestDist = Aimbot.FOV
        
        for _, target in pairs(game.Players:GetPlayers()) do
            if target ~= player and target.Character then
                if not Aimbot.IsFriend(player, target) then
                    local head = target.Character:FindFirstChild("Head")
                    if head then
                        local sp, onScreen = cam:WorldToScreenPoint(head.Position)
                        if onScreen then
                            local dist = (Vector2.new(sp.X, sp.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                            if dist < closestDist then
                                if Aimbot.IsVisible(player, target) then
                                    closest = head
                                    closestDist = dist
                                end
                            end
                        end
                    end
                end
            end
        end
        
        if closest then
            local lookAt = CFrame.lookAt(cam.CFrame.Position, closest.Position)
            cam.CFrame = cam.CFrame:Lerp(lookAt, math.clamp(Aimbot.Speed / 20, 0.05, 1))
        end
    end)
end

function Aimbot.Stop()
    Aimbot.Enabled = false
    
    if Aimbot.Connection then
        Aimbot.Connection:Disconnect()
        Aimbot.Connection = nil
    end
end

function Aimbot.Toggle(player)
    if Aimbot.Enabled then
        Aimbot.Stop()
    else
        Aimbot.Start(player)
    end
end

return Aimbot
