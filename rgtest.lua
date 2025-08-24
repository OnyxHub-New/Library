local OnyxHub = {}

OnyxHub.Settings = {
    OwnerTag = "OnyxHubLol"
}

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ragdollScript = nil
local originalParent = nil

function OnyxHub:SetOwnerTag(tag)
    self.Settings.OwnerTag = tag
    return true
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

function OnyxHub:InitChatCommands()
    TextChatService.OnIncomingMessage = function(message)
        local text = string.lower(message.Text)
        local sender = Players:FindFirstChild(message.TextSource.Name)
        
        if not sender or string.lower(sender.Name) ~= string.lower(self.Settings.OwnerTag) then return end 
        
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
        end
    end
end

function OnyxHub:Init()
    self:InitChatCommands()
    print("loaded successfully")
    return true
end

return OnyxHub
