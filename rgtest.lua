local OnyxHub = {}

OnyxHub.Settings = {
    OwnerTags = {"OnyxHubLol"} 
}

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local localPlayer = Players.LocalPlayer
local ragdollScript = nil
local originalParent = nil
local antiflingConnection = nil
local walkflinging = false
local antiAfkEnabled = false
local virtualUserInstance = nil
local antiAfkConnection = nil

function OnyxHub:SetOwnerTag(tag)
    table.insert(self.Settings.OwnerTags, tag)
    return true
end

function OnyxHub:RemoveOwnerTag(tag)
    for i, ownerTag in ipairs(self.Settings.OwnerTags) do
        if ownerTag == tag then
            table.remove(self.Settings.OwnerTags, i)
            return true
        end
    end
    return false
end

function OnyxHub:ClearOwnerTags()
    self.Settings.OwnerTags = {}
    return true
end

local function isOwner(player)
    for _, ownerTag in ipairs(OnyxHub.Settings.OwnerTags) do
        if string.lower(player.Name) == string.lower(ownerTag) then
            return true
        end
    end
    return false
end

local function teleportToPlayer(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        localPlayer.Character:SetPrimaryPartCFrame(player.Character.HumanoidRootPart.CFrame)
        return true
    end
    return false
end

function OnyxHub:TeleportToPlayer(playerName)
    local foundPlayer = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and string.find(string.lower(player.Name), string.lower(playerName), 1, true) then
            foundPlayer = player
            break
        end
    end
    
    if foundPlayer then
        return teleportToPlayer(foundPlayer)
    end
    return false
end

function OnyxHub:AntiRagdoll(enable)
    local playerName = localPlayer.Name
    if enable then
        local folder = workspace:FindFirstChild(playerName)
        if folder then
            ragdollScript = folder:FindFirstChild("Local Ragdoll")
            if ragdollScript then
                originalParent = ragdollScript.Parent 
                ragdollScript.Parent = nil 
            end
        end
    else
        if ragdollScript and originalParent and originalParent.Parent ~= nil then
            ragdollScript.Parent = originalParent
        end
        
        ragdollScript = nil
        originalParent = nil
    end
    return true
end

function OnyxHub:AntiFling(enable)
    if enable then
        if antiflingConnection then
            antiflingConnection:Disconnect()
        end
        
        antiflingConnection = RunService.Stepped:Connect(function()
            local speaker = localPlayer
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= speaker and player.Character then
                    for _, v in ipairs(player.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end
        end)
    else
        if antiflingConnection then
            antiflingConnection:Disconnect()
            antiflingConnection = nil
        end
    end
    return true
end

function OnyxHub:AntiAFK(enable)
    antiAfkEnabled = enable
    
    if enable then
        local GC = getconnections or get_signal_cons
        if GC then
            for i,v in pairs(GC(localPlayer.Idled)) do
                if v["Disable"] then
                    v["Disable"](v)
                elseif v["Disconnect"] then
                    v["Disconnect"](v)
                end
            end
        else
            virtualUserInstance = VirtualUser
            virtualUserInstance:CaptureController()
            virtualUserInstance:ClickButton2(Vector2.new())
            
            antiAfkConnection = localPlayer.Idled:Connect(function()
                virtualUserInstance:CaptureController()
                virtualUserInstance:ClickButton2(Vector2.new())
            end)
        end
        print("Anti AFK enabled")
    else
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
        virtualUserInstance = nil
        print("Anti AFK disabled")
    end
    return true
end

local function findTargetPlayer(playerName)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and string.find(string.lower(player.Name), string.lower(playerName), 1, true) then
            return player
        end
    end
    return nil
end

function OnyxHub:FlingPlayer(playerName)
    if walkflinging then return false end
    
    local targetPlayer = findTargetPlayer(playerName)
    if not targetPlayer or not targetPlayer.Character then
        return false
    end
    
    walkflinging = true
    
    local mapBounds = {
        XMin = -1500, XMax = 1500,
        YMin = -2000, YMax = 2000,
        ZMin = -1000, ZMax = 1000
    }
    
    local function isWithinBounds(position)
        return position.X >= mapBounds.XMin and position.X <= mapBounds.XMax and
               position.Y >= mapBounds.YMin and position.Y <= mapBounds.YMax and
               position.Z >= mapBounds.ZMin and position.Z <= mapBounds.ZMax
    end

    local localHrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if localHrp and not isWithinBounds(localHrp.Position) then
        walkflinging = false
        return false
    end

    local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
    
    if not targetHrp or not localHrp or not humanoid then 
        walkflinging = false
        return false
    end

    local POWER_MULTIPLIER = 0.1
    local DURATION = 2
    local PREDICTION_FACTOR = 0.6
    local JUMP_BOOST = 1.5
    
    local originalPosition = localHrp.CFrame
    local originalCollision = localHrp.CanCollide
    local flingActive = true

    localHrp.CanCollide = false
    for _, part in ipairs(localPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Massless = true
        end
    end

    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(math.huge * 100, math.huge * 100, math.huge * 100)
    bv.P = 1000000000000
    bv.Parent = localHrp

    local av = Instance.new("BodyAngularVelocity")
    av.MaxTorque = Vector3.new(math.huge * 100, math.huge * 100, math.huge * 100)
    av.P = 1000000000000
    av.Parent = localHrp
    
    local startTime = tick()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not pcall(function()
            if not flingActive then return end
            
            if localHrp and not isWithinBounds(localHrp.Position) then
                flingActive = false
                walkflinging = false
                connection:Disconnect()
                bv:Destroy()
                av:Destroy()
                for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Velocity = Vector3.zero
                        part.RotVelocity = Vector3.zero
                        part.CanCollide = originalCollision
                        part.Massless = false
                    end
                end
                
                localHrp.Anchored = true
                local platform = Instance.new("Part")
                platform.Size = Vector3.new(10, 1, 10)
                platform.Position = originalPosition.Position - Vector3.new(0, 3, 0)
                platform.Anchored = true
                platform.Transparency = 0.7
                platform.CanCollide = true
                platform.Color = Color3.fromRGB(0, 255, 0)
                platform.Parent = workspace
                
                localHrp.CFrame = originalPosition
                
                task.wait(0.5)
                platform:Destroy()
                
                local antiStick = Instance.new("BodyVelocity")
                antiStick.Velocity = Vector3.new(0, 100, 0)
                antiStick.MaxForce = Vector3.new(0, 100000, 0)
                antiStick.Parent = localHrp
                
                localHrp.Anchored = false
                
                task.wait(0.2)
                antiStick:Destroy()
                
                for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Velocity = Vector3.zero
                    end
                end
                walkflinging = false
                
                return
            end
            
            local prediction = Vector3.new(0, 0, 0)
            if targetHumanoid then
                if targetHumanoid.MoveDirection.Magnitude > 0 then
                    prediction = targetHumanoid.MoveDirection * (math.max(3, targetHrp.Velocity.Magnitude * PREDICTION_FACTOR)) 
                end
                
                local targetState = targetHumanoid:GetState()
                if targetState == Enum.HumanoidStateType.Jumping or 
                   targetState == Enum.HumanoidStateType.Freefall then
                    prediction = prediction + Vector3.new(0, JUMP_BOOST * targetHrp.Velocity.Y, 0)
                end
            end
            
            if targetHrp and targetHrp.Parent then
                local futurePosition = targetHrp.Position + prediction
                localHrp.CFrame = CFrame.new(futurePosition)
            end
            
            av.AngularVelocity = Vector3.new(
                math.random(-150000, 150000) * POWER_MULTIPLIER,
                math.random(-400000, 400000) * POWER_MULTIPLIER,
                math.random(-150000, 150000) * POWER_MULTIPLIER
            )
            
            bv.Velocity = Vector3.new(
                math.random(-800, 800) * POWER_MULTIPLIER,
                math.random(300, 1200) * POWER_MULTIPLIER,
                math.random(-800, 800) * POWER_MULTIPLIER
            )
            
            if tick() - startTime >= DURATION then
                flingActive = false
                walkflinging = false
                connection:Disconnect()
                bv:Destroy()
                av:Destroy()
                
                for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Velocity = Vector3.zero
                        part.RotVelocity = Vector3.zero
                        part.CanCollide = originalCollision
                        part.Massless = false
                    end
                end
                
                localHrp.Anchored = true
                local platform = Instance.new("Part")
                platform.Size = Vector3.new(10, 1, 10)
                platform.Position = originalPosition.Position - Vector3.new(0, 3, 0)
                platform.Anchored = true
                platform.Transparency = 0.7
                platform.CanCollide = true
                platform.Color = Color3.fromRGB(0, 255, 0)
                platform.Parent = workspace
                
                localHrp.CFrame = originalPosition
                
                task.wait(0.5)
                platform:Destroy()
                
                local antiStick = Instance.new("BodyVelocity")
                antiStick.Velocity = Vector3.new(0, 100, 0)
                antiStick.MaxForce = Vector3.new(0, 100000, 0)
                antiStick.Parent = localHrp
                
                localHrp.Anchored = false
                
                task.wait(0.2)
                antiStick:Destroy()
                
                for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Velocity = Vector3.zero
                    end
                end
                walkflinging = false
            end
        end) then
            flingActive = false
            walkflinging = false
            if connection then connection:Disconnect() end
            if bv then bv:Destroy() end
            if av then av:Destroy() end
            
            if localPlayer.Character then
                for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Velocity = Vector3.zero
                        part.RotVelocity = Vector3.zero
                        part.CanCollide = originalCollision
                        part.Massless = false
                    end
                end
            end
            walkflinging = false
        end
    end)
    
    return true
end

function OnyxHub:RejoinServer()
    local success, result = pcall(function()
        local placeId = game.PlaceId
        local jobId = game.JobId
        
        if jobId and jobId ~= "" then
            TeleportService:TeleportToPlaceInstance(placeId, jobId, localPlayer)
        else
            TeleportService:Teleport(placeId, localPlayer)
        end
    end)
    
    if not success then
        warn("Rejoin failed: " .. tostring(result))
        return false
    end
    return true
end

function OnyxHub:InitChatCommands()
    TextChatService.OnIncomingMessage = function(message)
        local text = string.lower(message.Text)
        local sender = Players:FindFirstChild(message.TextSource.Name)
        
        if not sender or not isOwner(sender) then return end 
        
        if string.sub(text, 1, 4) == "!tp " then
            local targetName = string.sub(text, 5)
            
            if targetName == "me" then
                teleportToPlayer(sender)
            else
                self:TeleportToPlayer(targetName)
            end
            
        elseif text == "!antir" then
            self:AntiRagdoll(true)
            
        elseif text == "!unantir" then
            self:AntiRagdoll(false)
            
        elseif text == "!antifling" then
            self:AntiFling(true)
            
        elseif text == "!unantifling" then
            self:AntiFling(false)
            
        elseif string.sub(text, 1, 7) == "!fling " then
            local targetName = string.sub(text, 8)
            self:FlingPlayer(targetName)
            
        elseif text == "!rejoin" then
            self:RejoinServer()
            
        elseif text == "!antiafk" then
            self:AntiAFK(true)
            print("Anti AFK enabled via chat command")
            
        elseif text == "!unantiafk" then
            self:AntiAFK(false)
            print("Anti AFK disabled via chat command")
        end
    end
end

function OnyxHub:Init()
    self:InitChatCommands()
    print("OnyxHub loaded successfully")
    print("Owners: " .. table.concat(self.Settings.OwnerTags, ", "))
    return true
end

OnyxHub:Init()

return OnyxHub
