local version = 1.0

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Onyx Hub | Boom Hood | Mobile",
    SubTitle = "t.me/onyxhub",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 350),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})


local Tabs = {
    Main = Window:AddTab({Title = "Menu", Icon = "home"}),
    Visual = Window:AddTab({Title = "Visual", Icon = "eye"}),
    Player = Window:AddTab({Title = "Player", Icon = "user"}),
    Teleport = Window:AddTab({Title = "Teleport", Icon = "map-pin"}),
    Anim = Window:AddTab({Title = "Animations", Icon = "film"}),
    Target = Window:AddTab({Title = "Target", Icon = "crosshair"}),
    Config = Window:AddTab({Title = "Settings", Icon = "settings"})
}
local RageAimGroup = Tabs.Main:AddSection("Silent Aim", {
    Title = "",
    Icon = "target"
})
local ESP_SETTINGS = {
    Enabled = false,
    Box_Color = Color3.fromRGB(255, 0, 0),
    Box_Thickness = 2,
    Team_Check = false,
    Team_Color = false,
    Autothickness = true,
    Rainbow = false
}

local player = {
    noclipActive = false,
    noclipConnection = nil,
    defaultCollisions = {},
    humanoid = nil,
    defaultWalkspeed = 16,
    strafe = {
        strafeEnabled = false,
        strafePower = 50,
        airControlFactor = 0.8,
        strafeConnection = nil,
        spinning = false,
        spinSpeed = 50,
        spinConnection = nil
    },
    fly = {
        FLYING = false,
        QEfly = false,
        flyspeed = 3,
        flyKeyDown = nil,
        flyKeyUp = nil,
        Flybind = "X"
    },
    unlockJumpEnabled = false,
    infJumpEnabled = false,
    infJumpDebounce = false,
    infJumpConnection = nil
}

local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
local Player = game:GetService("Players").LocalPlayer
local character = Player.Character
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera
local mouse = Player:GetMouse()

do
    local PlayerSection = Tabs.Player:AddSection("Player", {
        Title = "",
        Icon = "activity"
    })

    repeat task.wait() until game.Players.LocalPlayer.Character
    game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        humanoid = char:WaitForChild("Humanoid")
    end)

    PlayerSection:AddSlider("WalkSpeed", {
        Title = "Speed",
        Default = player.defaultWalkspeed,
        Min = 16,
        Max = 100,
        Rounding = 0,
        Callback = function(value)
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    })

    local function SaveCollisions(char)
        player.defaultCollisions = {}
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                player.defaultCollisions[part] = part.CanCollide
            end
        end
    end

    PlayerSection:AddButton({
        Title = "Anti FLing",
        Description = "",
        Callback = function()
            player.noclipActive = not player.noclipActive
            local character = game.Players.LocalPlayer.Character
            
            if player.noclipActive then
                if character then
                    SaveCollisions(character)
                    
                end
            else
                if player.noclipConnection then
                    player.noclipConnection:Disconnect()
                    for part, canCollide in pairs(player.defaultCollisions) do
                        if part and part.Parent then
                            part.CanCollide = canCollide
                        end
                    end
                end
            end
            game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
                if player.noclipActive then
                    SaveCollisions(newChar)
                end
            end)
        end
    })
end
local TouchGui = Instance.new("ScreenGui")
TouchGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local function createButton(name, position, size)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, size.X, 0, size.Y)
    button.Position = UDim2.new(0, position.X, 0, position.Y)
    button.BackgroundTransparency = 0.5
    button.Text = name
    button.Parent = TouchGui
    button.Visible = false
    return button
end

local buttons = {
    Forward = createButton("W", Vector2.new(100, 300), Vector2.new(50, 50)),
    Backward = createButton("S", Vector2.new(100, 350), Vector2.new(50, 50)),
    Left = createButton("A", Vector2.new(50, 350), Vector2.new(50, 50)),
    Right = createButton("D", Vector2.new(150, 350), Vector2.new(50, 50)),
    Up = createButton("E", Vector2.new(200, 300), Vector2.new(50, 50)),
    Down = createButton("Q", Vector2.new(200, 350), Vector2.new(50, 50))
}
local FLYING = false
local QEfly = false
local iyflyspeed = 50
local flyKeyDown, flyKeyUp
local Flybind = "X"
local UserInputService = game:GetService("UserInputService")
local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

local function sFLY()
    repeat task.wait() until Player.Character and getRoot(Player.Character) and 
        Player.Character:FindFirstChildOfClass("Humanoid")
    
    if flyKeyDown or flyKeyUp then 
        flyKeyDown:Disconnect() 
        flyKeyUp:Disconnect() 
    end

    local T = getRoot(Player.Character)
    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0

    local function FLY()
        FLYING = true
        local BG = Instance.new('BodyGyro')
        local BV = Instance.new('BodyVelocity')
        BG.P = 9e4
        BG.Parent = T
        BV.Parent = T
        BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.cframe = T.CFrame
        BV.velocity = Vector3.new(0, 0, 0)
        BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
        spawn(function()
            repeat wait()
                if Player.Character:FindFirstChildOfClass('Humanoid') then
                    Player.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
                end
                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    SPEED = iyflyspeed
                elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
                    SPEED = 0
                end
                if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                    BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + 
                        ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, 
                        (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                    lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                    BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + 
                        ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, 
                        (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                else
                    BV.velocity = Vector3.new(0, 0, 0)
                end
            until not FLYING
        
            CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            SPEED = 0
        
            BG:Destroy()
            BV:Destroy()
            if Player.Character:FindFirstChildOfClass('Humanoid') then
                Player.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
            end
        end)
    end

    

    for name, button in pairs(buttons) do
        button.MouseButton1Down:Connect(function()
            if name == "Forward" then CONTROL.F = 1
            elseif name == "Backward" then CONTROL.B = -1
            elseif name == "Left" then CONTROL.L = -1
            elseif name == "Right" then CONTROL.R = 1
            elseif name == "Up" then CONTROL.Q = 1
            elseif name == "Down" then CONTROL.E = -1
            end
        end)

        button.MouseButton1Up:Connect(function()
            if name == "Forward" then CONTROL.F = 0
            elseif name == "Backward" then CONTROL.B = 0
            elseif name == "Left" then CONTROL.L = 0
            elseif name == "Right" then CONTROL.R = 0
            elseif name == "Up" then CONTROL.Q = 0
            elseif name == "Down" then CONTROL.E = 0
            end
        end)
    end

    FLY()
end

local function NOFLY()
    FLYING = false
    if flyKeyDown or flyKeyUp then 
        flyKeyDown:Disconnect() 
        flyKeyUp:Disconnect() 
    end
    if Player.Character and Player.Character:FindFirstChildOfClass('Humanoid') then
        Player.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
    end
end
local function setFlyButtonsVisible(visible)
    for _, button in pairs(buttons) do
        button.Visible = visible
    end
end
local function ToggleFly()
    FLYING = not FLYING
    setFlyButtonsVisible(FLYING)
    if FLYING then
        sFLY()
      
    else
        NOFLY()
       
    end
end

local function ApplyAirControl()
    if not player.strafe.strafeEnabled or not Player.Character then return end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    local rootPart = Player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    if humanoid:GetState() == Enum.HumanoidStateType.Jumping or 
       humanoid:GetState() == Enum.HumanoidStateType.FallingDown or
       humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        
        local camera = workspace.CurrentCamera
        local moveDir = humanoid.MoveDirection
        
        local desiredVelocity = Vector3.new(
            moveDir.X * player.strafe.strafePower,
            0,  
            moveDir.Z * player.strafe.strafePower
        )
        
        local currentHorizontalVelocity = Vector3.new(rootPart.Velocity.X, 0, rootPart.Velocity.Z)
        local blendedVelocity = currentHorizontalVelocity:Lerp(desiredVelocity, player.strafe.airControlFactor)
        
        rootPart.Velocity = Vector3.new(
            blendedVelocity.X,
            rootPart.Velocity.Y, 
            blendedVelocity.Z
        )
    end
end

local function UpdateSpinBot()
    if player.strafe.spinning and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(player.strafe.spinSpeed), 0)
    end
end

local function setJumpPowerState(enabled)
    if not Player.Character then return end
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    humanoid.UseJumpPower = not enabled
end


do
    local FlySection = Tabs.Player:AddSection("Fly", {
        Title = "",
        Icon = "feather"
    })

    FlySection:AddToggle('EnableFly', {
        Title = 'Enable Fly',
        Default = false,
        Callback = function(Value)
            if Value then
                ToggleFly()
            end
            
        end
    })

    FlySection:AddSlider('FlySpeed', {
        Title = 'Fly Speed',
        Default = 3,
        Min = 3,
        Max = 500,
        Rounding = 0,
        Callback = function(value)
            iyflyspeed = value
        end
    })

end


do
    local StrafeSection = Tabs.Player:AddSection("Strafe", {
        Title = "",
        Icon = "wind"
    })

    StrafeSection:AddToggle('EnableAirControl', {
        Title = 'Strafe',
        Default = false,
        Callback = function(state)
            player.strafe.strafeEnabled = state
            if state then
                
            else
                if player.strafe.strafeConnection then
                    player.strafe.strafeConnection:Disconnect()
                    player.strafe.strafeConnection = nil
                end
            end
        end
    })

    StrafeSection:AddSlider('AirPower', {
        Title = 'Power',
        Default = 50,
        Min = 50,
        Max = 300,
        Rounding = 0,
        Callback = function(value)
            player.strafe.strafePower = value
        end
    })

    StrafeSection:AddToggle('SpinBot', {
        Title = 'Spin bot',
        Default = false,
        Callback = function(state)
            player.strafe.spinning = state
            if state then
                
            else
                if player.strafe.spinConnection then 
                    player.strafe.spinConnection:Disconnect() 
                end
            end
        end
    })

    StrafeSection:AddSlider('SpinSpeed', {
        Title = 'Speed',
        Default = 50,
        Min = 50,
        Max = 300,
        Rounding = 0,
        Callback = function(value)
            player.strafe.spinSpeed = value
        end
    })
end


do
    local JumpSection = Tabs.Player:AddSection("Jump", {
        Title = "",
        Icon = "arrow-up"
    })

    JumpSection:AddToggle('EnableInfJump', {
        Title = 'Jump Boost',
        Default = false,
        Callback = function(Value)
            player.infJumpEnabled = Value
            if Value then
                player.infJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                    if not player.infJumpEnabled or player.infJumpDebounce or not Player.Character then return end
                    
                    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
                    if not humanoid then return end
                    
                    player.infJumpDebounce = true
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    task.wait(0.1)
                    player.infJumpDebounce = false
                end)
            else
                if player.infJumpConnection then
                    player.infJumpConnection:Disconnect()
                    player.infJumpConnection = nil
                end
            end
        end
    })

    JumpSection:AddToggle('UnlockJump', {
        Title = 'Unlock Jump',
        Default = false,
        Callback = function(Value)
            player.unlockJumpEnabled = Value
            setJumpPowerState(Value)
        end
    })
end


game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(10)
    if player.strafe.strafeEnabled then
        
        if player.strafe.strafeConnection then
            player.strafe.strafeConnection:Disconnect()
        end
       
    end
    
    if player.unlockJumpEnabled then
        setJumpPowerState(true)
    end
end)

do
    local TpTool = Tabs.Teleport:AddSection("Tp Tool", {
        Title = "",
        Icon = "anchor"
    })
    
    TpTool:AddButton({
        Title = "Tp tool",
        Description = "",
        Callback = function()
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            
            local TeleportTool = Instance.new("Tool")
            TeleportTool.Name = "⚡ Teleporter"
            TeleportTool.RequiresHandle = false
            TeleportTool.CanBeDropped = false 
            TeleportTool.Parent = player.Backpack
            
            TeleportTool.Equipped:Connect(function()
                humanoid:SetStateEnabled(Enum.HumanoidStateType.UsingTool, false)
            end)
            
            TeleportTool.Activated:Connect(function()
                if not character then return end
                
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if not humanoidRootPart then return end
                
                local targetCFrame = CFrame.new(
                    mouse.Hit.X, 
                    mouse.Hit.Y + 3,  
                    mouse.Hit.Z
                )
                
                humanoidRootPart.CFrame = targetCFrame
            end)
        end
    })
end
local lockAim = {
    enabled = false,
    keybind = "Q",
    targetPart = "Head",
    fov = 100,
    smoothing = 0.1,
    lockConnection = nil,
    lockedPlayer = nil,
    isLocked = false,
    showFOV = true,
    fovColor = Color3.new(0, 1, 0),
    lockButton = nil
}

local lockFOVCircle = Drawing.new("Circle")
lockFOVCircle.Visible = false
lockFOVCircle.Color = lockAim.fovColor
lockFOVCircle.Transparency = 0.7
lockFOVCircle.Thickness = 1
lockFOVCircle.Filled = false
lockFOVCircle.Position = Camera.ViewportSize / 2
lockFOVCircle.Radius = lockAim.fov

local function createLockButton()
    local lockButton = Instance.new("TextButton")
    lockButton.Size = UDim2.new(0, 60, 0, 60)
    lockButton.Position = UDim2.new(0.8, 0, 0.7, 0)
    lockButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    lockButton.BackgroundTransparency = 0.5
    lockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    lockButton.Text = "LOCK"
    lockButton.TextSize = 14
    lockButton.Visible = false
    lockButton.Active = true
    lockButton.Draggable = true
    

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.3, 0)
    corner.Parent = lockButton
    
    lockButton.Parent = TouchGui
    return lockButton
end


lockAim.lockButton = createLockButton()


local function findClosestPlayerInFOV()
    local closestPlayer = nil
    local closestDistance = lockAim.fov
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local targetPart = player.Character:FindFirstChild(lockAim.targetPart)
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local center = Camera.ViewportSize / 2
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

                    if distance <= lockAim.fov and distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end


local function smoothLookAt(targetPosition)
    local currentCF = Camera.CFrame
    local targetCF = CFrame.lookAt(Camera.CFrame.Position, targetPosition)
    Camera.CFrame = currentCF:Lerp(targetCF, lockAim.smoothing)
end


local function updateLockAim()
    if not lockAim.enabled or not lockAim.isLocked then return end
    
    if lockAim.lockedPlayer and lockAim.lockedPlayer.Character then
        local targetPart = lockAim.lockedPlayer.Character:FindFirstChild(lockAim.targetPart)
        if targetPart then
            smoothLookAt(targetPart.Position)
        else
            lockAim.isLocked = false
            if lockAim.lockConnection then
                lockAim.lockConnection:Disconnect()
                lockAim.lockConnection = nil
            end
        end
    else
        lockAim.isLocked = false
        if lockAim.lockConnection then
            lockAim.lockConnection:Disconnect()
            lockAim.lockConnection = nil
        end
    end
end


local function toggleLockAim()
    if not lockAim.enabled then return end
    
    if lockAim.isLocked then

        lockAim.isLocked = false
        if lockAim.lockConnection then
            lockAim.lockConnection:Disconnect()
            lockAim.lockConnection = nil
        end
        lockAim.lockButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

    else

        lockAim.lockedPlayer = findClosestPlayerInFOV()
        if lockAim.lockedPlayer then
            lockAim.isLocked = true
            lockAim.lockConnection = RunService.RenderStepped:Connect(updateLockAim)
            lockAim.lockButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            Fluent:Notify({
                Title = "Lock Aim",
                Content = string.format("Locked on: %s (%s)", lockAim.lockedPlayer.Name, lockAim.targetPart),
                Duration = 2
            })
        else
        end
    end
end


lockAim.lockButton.MouseButton1Click:Connect(toggleLockAim)


UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not lockAim.enabled then return end
    
    if input.KeyCode == Enum.KeyCode[lockAim.keybind] then
        toggleLockAim()
    end
end)


local function updateLockFOVCircle()
    lockFOVCircle.Visible = lockAim.showFOV and lockAim.enabled
    lockFOVCircle.Color = lockAim.fovColor
    lockFOVCircle.Radius = lockAim.fov
    
    if lockAim.showFOV then
        lockFOVCircle.Position = Camera.ViewportSize / 2
    end
end


RageAimGroup:AddToggle('LockAimEnabled', {
    Title = 'Lock Aim',
    Default = false,
    Callback = function(state)
        lockAim.enabled = state
        lockAim.lockButton.Visible = state
        
        if not state and lockAim.isLocked then
            lockAim.isLocked = false
            if lockAim.lockConnection then
                lockAim.lockConnection:Disconnect()
                lockAim.lockConnection = nil
            end
            lockAim.lockButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
        
        updateLockFOVCircle()
    end
})

RageAimGroup:AddDropdown('LockAimPart', {
    Title = 'Lock Bone',
    Values = {"Head", "HumanoidRootPart", "UpperTorso"},
    Default = 1,
    Callback = function(value)
        lockAim.targetPart = value
    end
})

RageAimGroup:AddSlider('LockAimFOV', {
    Title = 'Lock FOV',
    Default = 100,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(value)
        lockAim.fov = value
        updateLockFOVCircle()
    end
})

RageAimGroup:AddSlider('LockAimSmoothing', {
    Title = 'Smoothing',
    Default = 10,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        lockAim.smoothing = value / 100
    end
})

RageAimGroup:AddToggle('ShowLockFOV', {
    Title = 'Show FOV Circle',
    Default = true,
    Callback = function(state)
        lockAim.showFOV = state
        updateLockFOVCircle()
    end
})



local Colorpicker = RageAimGroup:AddColorpicker("LockFOVColor", {
    Title = "FOV Color",
    Default = lockAim.fovColor
})

Colorpicker:OnChanged(function()
    lockAim.fovColor = Colorpicker.Value
    updateLockFOVCircle()
end)
do
    local MoreSection = Tabs.Main:AddSection("Func", {
        Title = "",
        Icon = "tool"
    })

    MoreSection:AddButton({
        Title = "Rejoin Server",
        Description = "",
        Callback = function()
            local TeleportService = game:GetService("TeleportService")
            local placeId = game.PlaceId
            local serverId = game.JobId
            
            TeleportService:TeleportToPlaceInstance(placeId, serverId)
        end
    })

    MoreSection:AddButton({
        Title = "Inject Infinite Yield",
        Description = "",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end
    })
end

do
    local AnimSection = Tabs.Anim:AddSection("Emotes", {
        Title = "",
        Icon = "sliders"
    })
    AnimSection:AddButton({
        Title = "Mobile Emotes",
        Description = "",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/AllEmotes"))()
        end
    })
end
do
    local AnimSection = Tabs.Anim:AddSection("Custom Animations", {
        Title = "",
        Icon = ""

    })


    local animationPresets = {
        Vampire = {
            idle1 = "1083445855",
            idle2 = "1083450166",
            walk = "1083473930",
            run = "1083462077",
            jump = "1083455352",
            climb = "1083439238",
            fall = "1083443587"
        },
        Catwalk = {
            idle1 = "94970088341563",
            idle2 = "133806214992291",
            walk = "109168724482748",
            run = "81024476153754",
            jump = "116936326516985",
            climb = "119377220967554",
            fall = "92294537340807"
        },
        Zombie = {
            idle1 = "616158929",
            idle2 = "616160636",
            walk = "616168032",
            run = "616163682",
            jump = "616161997",
            climb = "616156119",
            fall = "616157476"
        },
        Mage = {
            idle1 = "707742142",
            idle2 = "707855907",
            walk = "707897309",
            run = "707861613",
            jump = "707853694",
            climb = "707826056",
            fall = "707829716"
        },
        Elder = {
            idle1 = "845397899",
            idle2 = "845400520",
            walk = "845403856",
            run = "845386501",
            jump = "845398858",
            climb = "845392038",
            fall = "845396048"
        },
        MrToilet = {
            idle1 = "4417977954",
            idle2 = "4417978624",
            walk = "10921269718",
            run = "4417979645",
            jump = "10921263860",
            climb = "10921257536",
            fall = "10921262864"
        },
        Udzal = {
            idle1 = "3303162274",
            idle2 = "3303162549",
            walk = "3303162967",
            run = "3236836670",
            jump = "119846112151352",
            climb = "10921257536",
            fall = "10921262864"
        },
        Wicked = {
            idle1 = "118832222982049",
            idle2 = "76049494037641",
            walk = "92072849924640",
            run = "72301599441680",
            jump = "104325245285198",
            climb = "131326830509784",
            fall = "121152442762481"
        },
        NoBoundaries = {
            idle1 = "18747067405",
            idle2 = "18747063918",
            walk = "18747074203",
            run = "18747070484",
            jump = "18747069148",
            climb = "18747060903",
            fall = "18747062535"
        },
        Bold = {
            idle1 = "16738333868",
            idle2 = "16738334710",
            walk = "16738340646",
            run = "16738337225",
            jump = "16738336650",
            climb = "167383321693",
            fall = "16738333171"
        },
        Hero = {
            idle1 = "616111295",
            idle2 = "616113536",
            walk = "616122287",
            run = "616117076",
            jump = "616115533",
            climb = "616104706",
            fall = "616108001"
        },
        ZombieClassic = {
            idle1 = "616158929",
            idle2 = "616160636",
            walk = "616168032",
            run = "616163682",
            jump = "616161997",
            climb = "616156119",
            fall = "616157476"
        },
        Try = {
            idle1 = "616158929",
            idle2 = "616160636",
            walk = "616168032",
            run = "616163682",
            jump = "845398858",
            climb = "616156119",
            fall = "845396048"
        },
        Ghost = {
            idle1 = "616006778",
            idle2 = "616008087",
            walk = "616010382",
            run = "616013216",
            jump = "616008936",
            climb = "616003713",
            fall = "616005863"
        },
        Levitation = {
            idle1 = "616006778",
            idle2 = "616008087",
            walk = "616013216",
            run = "616010382",
            jump = "616008936",
            climb = "616003713",
            fall = "616005863"
        },
        Astronaut = {
            idle1 = "891621366",
            idle2 = "891633237",
            walk = "891667138",
            run = "891636393",
            jump = "891627522",
            climb = "891609353",
            fall = "891617961"
        },
        Ninja = {
            idle1 = "656117400",
            idle2 = "656118341",
            walk = "656121766",
            run = "656118852",
            jump = "656117878",
            climb = "656114359",
            fall = "656115606"
        },
        Werewolf = {
            idle1 = "18537376492",
            idle2 = "18537371272",
            walk = "18537392113",
            run = "18537384940",
            jump = "18537380791",
            climb = "18537363391",
            fall = "18537367238"
        },
        Cartoon = {
            idle1 = "742637544",
            idle2 = "742638445",
            walk = "742640026",
            run = "742638842",
            jump = "742637942",
            climb = "742636889",
            fall = "742637151"
        },
        Pirate = {
            idle1 = "92080889861410",
            idle2 = "74451233229259",
            walk = "110358958299415",
            run = "117333533048078",
            jump = "119846112151352",
            climb = "134630013742019",
            fall = "750780242"
        },
        Sneaky = {
            idle1 = "1132473842",
            idle2 = "1132477671",
            walk = "1132510133",
            run = "1132494274",
            jump = "1132489853",
            climb = "1132461372",
            fall = "1132469004"
        },
        Toy = {
            idle1 = "782841498",
            idle2 = "782845736",
            walk = "782843345",
            run = "782842708",
            jump = "782847020",
            climb = "782843869",
            fall = "782846423"
        },
        Knight = {
            idle1 = "657595757",
            idle2 = "657568135",
            walk = "657552124",
            run = "657564596",
            jump = "658409194",
            climb = "658360781",
            fall = "657600338"
        },
        Confident = {
            idle1 = "1069977950",
            idle2 = "1069987858",
            walk = "1070017263",
            run = "1070001516",
            jump = "1069984524",
            climb = "1069946257",
            fall = "1069973677"
        },
        Popstar = {
            idle1 = "1212900985",
            idle2 = "1212900985",
            walk = "1212980338",
            run = "1212980348",
            jump = "1212954642",
            climb = "1213044953",
            fall = "1212900995"
        },
        Princess = {
            idle1 = "941003647",
            idle2 = "941013098",
            walk = "941028902",
            run = "941015281",
            jump = "941008832",
            climb = "940996062",
            fall = "941000007"
        },
        Cowboy = {
            idle1 = "1014390418",
            idle2 = "1014398616",
            walk = "1014421541",
            run = "1014401683",
            jump = "1014394726",
            climb = "1014380606",
            fall = "1014384571"
        },
        Patrol = {
            idle1 = "1149612882",
            idle2 = "1150842221",
            walk = "1151231493",
            run = "1150967949",
            jump = "1150944216",
            climb = "1148811837",
            fall = "1148863382"
        },
        ZombieFE = {
            idle1 = "3489171152",
            idle2 = "3489171152",
            walk = "3489174223",
            run = "3489173414",
            jump = "616161997",
            climb = "616156119",
            fall = "616157476"
        },
        AdidasNew = {
            idle1 = "122257458498464",
            idle2 = "102357151005774",
            walk = "122150855457006",
            run = "82598234841035",
            jump = "75290611992385",
            climb = "88763136693023",
            fall = "98600215928904"
        }
    }

    local currentPreset = "Default"

    local function ApplyAnimation(preset)
        currentPreset = preset
        local plr = game:GetService("Players").LocalPlayer
        if not plr.Character then return end
        
        local animate = plr.Character:FindFirstChild("Animate")
        if not animate then return end

        animate.Disabled = true
        
        for _, track in pairs(plr.Character.Humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
        
        if preset == "Default" then
            animate.Disabled = false
            return
        end

        local animations = animationPresets[preset]
        animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id="..animations.idle1
        animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id="..animations.idle2
        animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id="..animations.walk
        animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id="..animations.run
        animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id="..animations.jump
        animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id="..animations.climb
        animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id="..animations.fall

        plr.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        task.wait(0.1)
        animate.Disabled = false
    end

    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
        humanoid = char:WaitForChild("Humanoid")
        task.wait(0.3)
        ApplyAnimation(currentPreset)
        if currentPreset ~= "Default" then
            local animate = char:WaitForChild("Animate")
            animate.Disabled = true
            task.wait(0.1)
            animate.Disabled = false
        end
    end)


    local animationButtons = {
        {Name = "Vampire", Desc = "Apply vampire movement style", Icon = "moon"},
        {Name = "Elder", Desc = "Apply elder movement style", Icon = "moon"},
        {Name = "Mage", Desc = "Apply mage movement style", Icon = "moon"},
        {Name = "Catwalk", Desc = "Apply model walk style", Icon = "trending-up"},
        {Name = "Zombie", Desc = "Apply zombie movement style", Icon = "biohazard"},
        {Name = "MrToilet", Desc = "Apply MrToilet movement style", Icon = "biohazard"},
        {Name = "Udzal", Desc = "Apply Udzal movement style", Icon = "user"},
        {Name = "Wicked", Desc = "Apply Wicked movement style", Icon = "user"},
        {Name = "NoBoundaries", Desc = "Apply NoBoundaries movement style", Icon = "user"},
        {Name = "Bold", Desc = "Apply Bold movement style", Icon = "user"},
        {Name = "Hero", Desc = "Apply Hero movement style", Icon = "shield"},
        {Name = "ZombieClassic", Desc = "Apply ZombieClassic movement style", Icon = "biohazard"},
        {Name = "Try", Desc = "Apply Try movement style", Icon = "user"},
        {Name = "Ghost", Desc = "Apply Ghost movement style", Icon = "user"},
        {Name = "Levitation", Desc = "Apply Levitation movement style", Icon = "user"},
        {Name = "Astronaut", Desc = "Apply Astronaut movement style", Icon = "user"},
        {Name = "Ninja", Desc = "Apply Ninja movement style", Icon = "user"},
        {Name = "Werewolf", Desc = "Apply Werewolf movement style", Icon = "user"},
        {Name = "Cartoon", Desc = "Apply Cartoon movement style", Icon = "user"},
        {Name = "Pirate", Desc = "Apply Pirate movement style", Icon = "user"},
        {Name = "Sneaky", Desc = "Apply Sneaky movement style", Icon = "user"},
        {Name = "Toy", Desc = "Apply Toy movement style", Icon = "user"},
        {Name = "Knight", Desc = "Apply Knight movement style", Icon = "shield"},
        {Name = "Confident", Desc = "Apply Confident movement style", Icon = "user"},
        {Name = "Popstar", Desc = "Apply Popstar movement style", Icon = "user"},
        {Name = "Princess", Desc = "Apply Princess movement style", Icon = "user"},
        {Name = "Cowboy", Desc = "Apply Cowboy movement style", Icon = "user"},
        {Name = "Patrol", Desc = "Apply Patrol movement style", Icon = "user"},
        {Name = "ZombieFE", Desc = "Apply ZombieFE movement style", Icon = "biohazard"},
        {Name = "AdidasNew", Desc = "Apply Adidasnew movement style", Icon = "biohazard"}
    }


    for _, btn in ipairs(animationButtons) do
        AnimSection:AddButton({
            Title = btn.Name,
            Callback = function()
                ApplyAnimation(btn.Name)
            end
        })
    end

    AnimSection:AddButton({
        Title = "Reset Animations",
        Callback = function()
            ApplyAnimation("Default")
        end
    })


    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        ApplyAnimation(currentPreset)
    end)

end


local tg ={
    targetNameInput = "",
    viewing = nil,
    viewDied = nil,
    viewChanged = nil,
    bangState = {Active = false, Connection = nil, Track = nil},
    headsitState = {Active = false, Connection = nil, VelocityObject = nil},
    standState = {Active = false, Connection = nil, Velocity = nil, Track = nil},
    clickTargetTool = nil
}

local TargetLeftGroup = Tabs.Target:AddSection("Player trgt", {
    Title = "",
    Icon = ""
})
local TargetRightGroup = Tabs.Target:AddSection("Spectate",{
    Title = "",
    Icon =""
})


local function findTargetPlayer()
    if not tg.targetNameInput or tg.targetNameInput == "" then return nil end
    local inputLower = string.lower(tg.targetNameInput)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            if string.find(string.lower(player.Name), inputLower, 1, true) then
                return player
            end
        end
    end
    return nil
end



TargetLeftGroup:AddInput("Input", {
    Title = "Player Name",
    Default = "",
    Placeholder = "Text",
    Numeric = false, 
    Finished = false,
    Callback = function(Value)
        tg.targetNameInput = Value
    end
})




TargetLeftGroup:AddButton({
    Title = "Teleport to Target",
    Description = "",
    Callback = function()
        local targetPlayer = findTargetPlayer()
        
        if targetPlayer and targetPlayer.Character then
            Player.Character:MoveTo(targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
        else
            Fluent:Notify({
                Title = "Teleport Btn",
                Content = "Player not found",
                Duration = 5 
            })
        end
    end
})
TargetLeftGroup:AddButton({
    Title = "Bang Target",
    Description = "",
    Callback = function()
        local targetPlayer = findTargetPlayer()
        
        tg.bangState.Active = not tg.bangState.Active

        local function PlayAnim(assetID)
            if tg.bangState.Track then
                tg.bangState.Track:Stop()
                tg.bangState.Track:Destroy()
                tg.bangState.Track = nil
            end
            if tg.bangState.Active then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://"..assetID
                tg.bangState.Track = Player.Character.Humanoid:LoadAnimation(anim)
                tg.bangState.Track:Play()
                tg.bangState.Track.Looped = true
            end
        end

        if tg.bangState.Active then
            if targetPlayer and targetPlayer.Character then
                PlayAnim(5918726674)
            

                
            end
        else
            if tg.bangState.Connection then
                tg.bangState.Connection:Disconnect()
                tg.bangState.Connection = nil
            end
            if tg.bangState.Track then 
                tg.bangState.Track:Stop() 
                tg.bangState.Track:Destroy() 
                tg.bangState.Track = nil 
            end
            
            if Player.Character then
                for _, part in ipairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Massless = false
                    end
                end
                
                local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
            
        
        end
    end
})


TargetLeftGroup:AddButton({
    Title = "Headsit Target",
    Description = "",
    Callback = function()
        local targetPlayer = findTargetPlayer()
        
        tg.headsitState.Active = not tg.headsitState.Active

        if tg.headsitState.Active then
            if targetPlayer and targetPlayer.Character then
                local humanoid = Player.Character:FindFirstChild("Humanoid")
                local rootPart = Player.Character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and rootPart then
                    humanoid.Sit = true
                    tg.headsitState.VelocityObject = Instance.new("BodyVelocity")
                    tg.headsitState.VelocityObject.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    tg.headsitState.VelocityObject.Velocity = Vector3.new(0,0,0)
                    tg.headsitState.VelocityObject.P = 10000
                    tg.headsitState.VelocityObject.Parent = rootPart
                    
                

                    
                end
            end
        else
            if tg.headsitState.Connection then
                tg.headsitState.Connection:Disconnect()
                tg.headsitState.Connection = nil
            end
            if tg.headsitState.VelocityObject then
                tg.headsitState.VelocityObject:Destroy()
                tg.headsitState.VelocityObject = nil
            end
            if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                Player.Character.Humanoid.Sit = false
            end
            
        
        end
    end
})


TargetLeftGroup:AddButton({
    Title = "Stand",
    Description = "",
    Callback = function()
        local targetPlayer = findTargetPlayer()
        
        tg.standState.Active = not tg.standState.Active

        if tg.standState.Active then
            if targetPlayer and targetPlayer.Character then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://13823324057"
                tg.standState.Track = Player.Character.Humanoid:LoadAnimation(anim)
                tg.standState.Track:Play()
                
                tg.standState.Velocity = Instance.new("BodyVelocity")
                tg.standState.Velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                tg.standState.Velocity.Velocity = Vector3.new(0,0,0)
                tg.standState.Velocity.P = 10000
                tg.standState.Velocity.Parent = Player.Character.HumanoidRootPart

            

                
            end
        else
            if tg.standState.Connection then
                tg.standState.Connection:Disconnect()
                tg.standState.Connection = nil
            end
            if tg.standState.Velocity then
                tg.standState.Velocity:Destroy()
                tg.standState.Velocity = nil
            end
            if tg.standState.Track then
                tg.standState.Track:Stop()
                tg.standState.Track:Destroy()
                tg.standState.Track = nil
            end
            
        
        end
    end
})


local function StopSpectate()
    if tg.viewing then
   
    end
    tg.viewing = nil
    if tg.viewDied then
        tg.viewDied:Disconnect()
        tg.viewDied = nil
    end
    if tg.viewChanged then
        tg.viewChanged:Disconnect()
        tg.viewChanged = nil
    end
    if Player.Character then
        Camera.CameraSubject = Player.Character:FindFirstChild("Humanoid")
    end
end

TargetRightGroup:AddButton({
    Title = "Spectate",
    Description = "",
    Callback = function()
        local targetPlayer = findTargetPlayer()
        if not targetPlayer then return end
        
        StopSpectate()
        
        tg.viewing = targetPlayer
        Camera.CameraSubject = tg.viewing.Character
        
        tg.viewDied = tg.viewing.CharacterAdded:Connect(function(newChar)
            repeat task.wait() until newChar:FindFirstChild("HumanoidRootPart")
            Camera.CameraSubject = newChar:FindFirstChild("Humanoid")
        end)
        
        tg.viewChanged = Camera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
            if tg.viewing and tg.viewing.Character and 
               Camera.CameraSubject ~= tg.viewing.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = tg.viewing.Character:FindFirstChild("Humanoid")
            end
        end)
    end
})

TargetRightGroup:AddButton({
    Title = "Stop Spectate",
    Description = "",
    Callback = StopSpectate
})
local aim = {
    rageAimEnabled = false,
    rageAimKey = "Q",
    targetPart = "Head",
    prediction = 0.12,
    fovEnabled = true,
    fovRadius = 100,
    fovColor = Color3.new(1, 0, 0),
    fovTransparency = 0.7,
    fovThickness = 1,
    fovFilled = false,
    fovCircle = nil,
    rageAimBindMode = "Mouse",
    aimMode = "Center",
    whitelistPlayers = {},
    whitelistDropdown = nil,
    wallCheckEnabled = false,
    autoShootEnabled = false,
    autoShootEnabledAim = false,
    shootInterval = 0.01,
    lastShotTime = 0,
    autoreload = false,
    fovType = "Center",
    rageAimTarget = nil
}

local weapon = {
    weaponHooks = {},
    infinityAmmoEnabled = false,
    noReloadDelayEnabled = false,
    rapidFireEnabled = false,
    range = false,
    orig = {},
    noStopInReloadEnabled = false,
    reloadValue = nil,
    reloadConnection = nil,
    originalCooldowns = {},
    ammoConnections = {}
}

local health = false
local minh = 11

local Player = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShootEvent = ReplicatedStorage:WaitForChild("ShootEvent")
local RunService = game:GetService("RunService")
local function createFOVCircle()
    if aim.fovCircle then aim.fovCircle:Remove() end
    
    aim.fovCircle = Drawing.new("Circle")
    aim.fovCircle.Visible = aim.fovEnabled and aim.rageAimEnabled
    aim.fovCircle.Radius = aim.fovRadius
    aim.fovCircle.Color = aim.fovColor
    aim.fovCircle.Transparency = aim.fovTransparency
    aim.fovCircle.Thickness = aim.fovThickness
    aim.fovCircle.Filled = aim.fovFilled
    aim.fovCircle.Position = Camera.ViewportSize / 2
end

local function updateFOVCircle()
    if not aim.fovCircle then createFOVCircle() end
    
    aim.fovCircle.Visible = aim.fovEnabled and aim.rageAimEnabled

    if aim.fovType == "Center" then
        aim.fovCircle.Position = Camera.ViewportSize / 2
    else
        aim.fovCircle.Position = UserInputService:GetMouseLocation()
    end
    
    aim.fovCircle.Radius = aim.fovRadius
    aim.fovCircle.Color = aim.fovColor
    aim.fovCircle.Transparency = aim.fovTransparency
    aim.fovCircle.Thickness = aim.fovThickness
    aim.fovCircle.Filled = aim.fovFilled
end

local function isInFOV(targetScreenPos)
    if not aim.fovEnabled then return true end
    
    local centerPoint
    if aim.fovType == "Center" then
        centerPoint = Camera.ViewportSize / 2
    else
        centerPoint = UserInputService:GetMouseLocation()
    end
    
    local distance = (Vector2.new(targetScreenPos.X, targetScreenPos.Y) - centerPoint).Magnitude
    return distance <= aim.fovRadius
end

local function findCurrentWeapon()
    if not Player.Character then return nil, nil end
    
    for _, tool in ipairs(Player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local ammo = tool:FindFirstChild("Ammo")
            if ammo and (ammo:IsA("IntValue") or ammo:IsA("NumberValue")) then
                return tool, ammo
            end
        end
    end
    
    return nil, nil
end

local function autoReload()
    if not aim.autoreload then return end
    
    local weapon, ammoObj = findCurrentWeapon()
    
    if weapon and ammoObj then
        if ammoObj.Value == 0 then
            game:GetService("ReplicatedStorage").MainEvent:FireServer("Reload")
        end
    end
end

local function setupNoStopInReload()
    if weapon.reloadConnection then
        weapon.reloadConnection:Disconnect()
        weapon.reloadConnection = nil
    end
    if Player.Character then
        local bodyEffects = Player.Character:FindFirstChild("BodyEffects")
        if bodyEffects then
            weapon.reloadValue = bodyEffects:FindFirstChild("Reload")
            if weapon.reloadValue then
                weapon.reloadConnection = weapon.reloadValue:GetPropertyChangedSignal("Value"):Connect(function()
                    if weapon.noStopInReloadEnabled and weapon.reloadValue.Value == true then
                        weapon.reloadValue.Value = false
                    end
                end)
            end
        end
    end
end

local function applyWeaponMods(tool)
    if not tool:IsA("Tool") then return end
    

    
    local cooldown = tool:FindFirstChild("ShootingCooldown")
    if cooldown then
        if weapon.noReloadDelayEnabled or weapon.rapidFireEnabled then
            if not weapon.originalCooldowns[tool] then
                weapon.originalCooldowns[tool] = cooldown.Value
            end
            cooldown.Value = 0
        elseif weapon.originalCooldowns[tool] then
            cooldown.Value = weapon.originalCooldowns[tool]
            weapon.originalCooldowns[tool] = nil
        end
    end
    
    local rg = tool:FindFirstChild("Range")
    if rg then
        if weapon.range then
            if not weapon.orig[tool] then
                weapon.orig[tool] = rg.value
            end
            rg.Value = 99999999
        elseif weapon.orig[tool] then
            rg.Value = weapon.orig[tool]
            weapon.orig[tool] = nil
        end
    end
end

local function processNewTool(tool)
    applyWeaponMods(tool)
end

local function restoreOriginalCooldowns()
    for tool, value in pairs(weapon.originalCooldowns) do
        if tool and tool.Parent and tool:FindFirstChild("ShootingCooldown") then
            tool.ShootingCooldown.Value = value
        end
    end
    weapon.originalCooldowns = {}
end

local function shouldSkipTarget(targetCharacter)
    if not health then return false end
    
    local hitbox = targetCharacter:FindFirstChild("Hitbox")
    if hitbox and not hitbox.CanQuery then
        return true
    end
    return false
end

local function InstantShoot()
    if not aim.rageAimEnabled then return false end
    
    local camera = workspace.CurrentCamera
    local localPlayer = Player
    local localCharacter = localPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("Head") then return false end
    
    local closestPlayer = nil
    local closestDistance = math.huge
    local closestScreenPos = nil
    local centerPoint = Camera.ViewportSize / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if table.find(aim.whitelistPlayers, player.Name) then
            continue
        end
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild(aim.targetPart) then
            local bodyPart = player.Character:FindFirstChild(aim.targetPart)
            local screenPos, onScreen = camera:WorldToViewportPoint(bodyPart.Position)
            
            if onScreen then
                local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - centerPoint).Magnitude
               
                local targetScreenPos = Vector2.new(screenPos.X, screenPos.Y)
                if isInFOV(targetScreenPos) then
                    local distance
                    if aim.aimMode == "Closest" then
                        distance = (bodyPart.Position - localCharacter.Head.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                            closestScreenPos = screenPos
                        end
                    elseif aim.aimMode == "Center" then
                        distance = distanceToCenter
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                            closestScreenPos = screenPos
                        end
                    end
                end
            end
        end
    end

    if closestPlayer then
        aim.rageAimTarget = closestPlayer 
    else
        aim.rageAimTarget = nil
    end
    
    local function fireWithRemoteEvent(targetPart, predictedPosition)
        local character = Player.Character
        if not character then return false end
    
        local weaponTool = character:FindFirstChildOfClass("Tool")
        if not weaponTool then return false end
    
        local handle = weaponTool:FindFirstChild("Handle")
        if not handle then return false end
        local rgValue = nil
        local cooldownValue = nil
        for _, tool in ipairs(Player.Backpack:GetChildren()) do
            local rg = tool:FindFirstChild("Range")
            local cooldown = tool:FindFirstChild("ShootingCooldown")
            
            if rg and rg:IsA("NumberValue") then
                rgValue = rg.Value
            end
            if cooldown and cooldown:IsA("NumberValue") then
                cooldownValue = cooldown.Value
            end
        end
        if not handle or not targetPart or not predictedPosition then
            return false
        end
        local params = {
            WeaponHandle = handle,
            OriginPosition = handle.Position,
            TargetPosition = predictedPosition,
            TargetPart = targetPart,
            DirectionVector = Vector3.new(0, 1, 0), 
            AdditionalData1 = {}, 
            AdditionalData2 = {}, 
            FireTime = tick(),
            Range = rgValue,
            PredictedPositions = {predictedPosition},
            BulletCount = 1,
            CooldownTime = cooldownValue,
            FinalTargetPosition = predictedPosition
        }
    
        ShootEvent:FireServer(
            "ShootGun",
            params.WeaponHandle,
            params.OriginPosition,
            params.PredictedPositions,
            {targetPart},
            {params.DirectionVector},
            params.AdditionalData1,
            params.FireTime,
            params.Range,
            params.PredictedPositions,
            params.BulletCount,
            params.CooldownTime,
            params.FinalTargetPosition
        )
    
        return true
    end
    
    if closestPlayer and closestPlayer.Character and closestScreenPos then
        local bodyPart = closestPlayer.Character:FindFirstChild(aim.targetPart)
        if bodyPart then
            if shouldSkipTarget(closestPlayer.Character) then
                return false
            end
            if aim.wallCheckEnabled then
                local origin = Camera.CFrame.Position
                local targetPos = bodyPart.Position
                local direction = (targetPos - origin).Unit
                local distance = (targetPos - origin).Magnitude
                
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                raycastParams.FilterDescendantsInstances = {Player.Character}
                raycastParams.IgnoreWater = true
                
                local raycastResult = workspace:Raycast(origin, direction * distance, raycastParams)
                if raycastResult then
                    local hitPart = raycastResult.Instance
                    local hitCharacter = hitPart:FindFirstAncestorOfClass("Model")
                    if hitCharacter ~= closestPlayer.Character then
                        return nil 
                    end
                end
            end
            local velocity = bodyPart.Velocity
            local predictedPosition = bodyPart.Position + (velocity * aim.prediction)

            return fireWithRemoteEvent(bodyPart, predictedPosition)
        end
    end
    return false
end

local function AutoShootThread()
    while aim.autoShootEnabledAim and aim.rageAimEnabled do
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            local success, shotFired = pcall(InstantShoot)
            if success and shotFired then
                aim.lastShotTime = tick()
            end
        end
        task.wait(aim.shootInterval)
    end
end

local function updatePlayerList()
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

local function refreshWhitelistPlayerList()
    aim.whitelistDropdown:SetValues(updatePlayerList())
end


do
    

    RageAimGroup:AddToggle("EnableGhost", {
        Title = 'Enable Aim',
        Default = false,
        Callback = function(state)
            aim.rageAimEnabled = state
            updateFOVCircle()
        end
    })
    RageAimGroup:AddDropdown("AimPartSelect", {
        Title = 'Target Bone',
        Values = {"Head", "HumanoidRootPart", "UpperTorso"},
        Default = 1,
        Callback = function(value)
            aim.targetPart = value
        end
    })

    RageAimGroup:AddDropdown("AimMode", {
        Title = 'Aim Mode',
        Values = {"Closest", "Center"},
        Default = 2,
        Callback = function(value)
            aim.aimMode = value
        end
    })



    
    RageAimGroup:AddToggle('WallCheck', {
        Title = 'Wall Check',
        Default = false,
        Callback = function(Value)
            aim.wallCheckEnabled = Value
        end
    })

    RageAimGroup:AddToggle('HealthCheck', {
        Title = 'Health Check',
        Default = false,
        Callback = function(Value)
            health = Value
        end
    })

    RageAimGroup:AddToggle('AutoShootAim', {
        Title = 'Auto Shoot',
        Default = false,
        Callback = function(Value)
            aim.autoShootEnabledAim = Value
            if Value then
                task.spawn(AutoShootThread) 
            end
        end
    })

    RageAimGroup:AddToggle('AutoReload', {
        Title = 'Auto Reload',
        Default = false,
        Callback = function(Value)
            aim.autoreload = Value
        end
    })

    RageAimGroup:AddToggle('RapidFire', {
        Title = 'Rapid Fire',
        Default = false,
        Callback = function(state)
            weapon.rapidFireEnabled = state
            for _, tool in ipairs(Player.Backpack:GetChildren()) do
                applyWeaponMods(tool)
            end
            if Player.Character then
                for _, tool in ipairs(Player.Character:GetChildren()) do
                    applyWeaponMods(tool)
                end
            end
        end
    })

    RageAimGroup:AddToggle('Range', {
        Title = 'Unlock Range',
        Default = false,
        Callback = function(Value)
            weapon.range = Value
            for _, tool in ipairs(Player.Backpack:GetChildren()) do
                applyWeaponMods(tool)
            end
            if Player.Character then
                for _, tool in ipairs(Player.Character:GetChildren()) do
                    applyWeaponMods(tool)
                end
            end
        end
    })

    RageAimGroup:AddToggle('NoStopInReload', {
        Title = 'No stop in reload',
        Default = false,
        Callback = function(Value)
            weapon.noStopInReloadEnabled = Value
            if Value then
                setupNoStopInReload()
            else
                if weapon.reloadConnection then
                    weapon.reloadConnection:Disconnect()
                    weapon.reloadConnection = nil
                end
                if Player.Character then
                    local bodyEffects = Player.Character:FindFirstChild("BodyEffects")
                    if bodyEffects then
                        local reloadValue = bodyEffects:FindFirstChild("Reload")
                        if reloadValue then
                            reloadValue.Value = false
                        end
                    end
                end
            end
        end
    })


    
    local FOVSettings = Tabs.Main:AddSection("FOV Settings", {
        Title = "",
        Icon = "circle"
    })
    --[[FOVSettings:AddDropdown("FOVType", {
        Title = 'FOV Type',
        Values = {"Center", "Mouse"},
        Default = 1,
        Callback = function(value)
            aim.fovType = value
            updateFOVCircle()
        end
    })]]--
    

    FOVSettings:AddToggle("EnableFOV", {
        Title = 'Show FOV Circle',
        Default = true,
        Callback = function(state)
            aim.fovEnabled = state
            updateFOVCircle()
        end
    })

    FOVSettings:AddSlider("FOVRadius", {
        Title = 'FOV Radius',
        Default = 100,
        Min = 50,
        Max = 300,
        Rounding = 0,
        Callback = function(value)
            aim.fovRadius = value
            updateFOVCircle()
        end
    })

    local Colorpicker = FOVSettings:AddColorpicker("FovClr", {
        Title = "Color",
        Default = Color3.fromRGB(96, 205, 255)
    })

    Colorpicker:OnChanged(function()
        aim.fovColor = Colorpicker.Value
        updateFOVCircle()
    end)
    

    FOVSettings:AddSlider("FOVTransparency", {
        Title = 'Transparency',
        Default = 0.7,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(value)
            aim.fovTransparency = value
            updateFOVCircle()
        end
    })

    FOVSettings:AddSlider("FOVThickness", {
        Title = 'Thickness',
        Default = 1,
        Min = 1,
        Max = 5,
        Rounding = 0,
        Callback = function(value)
            aim.fovThickness = value
            updateFOVCircle()
        end
    })

    FOVSettings:AddToggle("FOVFilled", {
        Title = 'Filled Circle',
        Default = false,
        Callback = function(state)
            aim.fovFilled = state
            updateFOVCircle()
        end
    })


    
    local WhitelistGroup = Tabs.Main:AddSection("Whitelist", {
        Title = "",
        Icon = "shield"
    })

    Players.PlayerAdded:Connect(refreshWhitelistPlayerList)
    Players.PlayerRemoving:Connect(refreshWhitelistPlayerList)
    
    aim.whitelistDropdown = WhitelistGroup:AddDropdown('WhitelistPlayerSelect', {
        Title = 'Whitelist',
        Values = updatePlayerList(),
        Default = 1,
    })

    WhitelistGroup:AddButton({
        Title = 'Add to Whitelist',
        Callback = function()
            local selected = aim.whitelistDropdown.Value
            if selected and not table.find(aim.whitelistPlayers, selected) then
                table.insert(aim.whitelistPlayers, selected)
                Fluent:Notify({
                    Title = "Whitelist",
                    Content = selected .. " added to whitelist",
                    Duration = 3
                })
            end
        end
    })

    WhitelistGroup:AddButton({
        Title = 'Remove from Whitelist',
        Callback = function()
            local selected = aim.whitelistDropdown.Value
            if selected and table.find(aim.whitelistPlayers, selected) then
                table.remove(aim.whitelistPlayers, table.find(aim.whitelistPlayers, selected))
                Fluent:Notify({
                    Title = "Whitelist",
                    Content = selected .. " removed from whitelist",
                    Duration = 3
                })
            end
        end
    })

    createFOVCircle()
end


Player.CharacterAdded:Connect(function(character)
    task.wait(10)
    if weapon.noStopInReloadEnabled then
        setupNoStopInReload()
    end
    if weapon.rapidFireEnabled then 
        for _, tool in ipairs(Player.Backpack:GetChildren()) do
            applyWeaponMods(tool)
        end
        if Player.Character then
            for _, tool in ipairs(Player.Character:GetChildren()) do
                applyWeaponMods(tool)
            end
        end
    end
    if weapon.range then 
        for _, tool in ipairs(Player.Backpack:GetChildren()) do
            applyWeaponMods(tool)
        end
        if Player.Character then
            for _, tool in ipairs(Player.Character:GetChildren()) do
                applyWeaponMods(tool)
            end
        end
    end
end)
--[[
local visualUpdateConnection = RunService.RenderStepped:Connect(function()

    if aim.autoreload then
        pcall(autoReload)
    end

end)
]]--


do
    local KillAuraSection = Tabs.Main:AddSection("Kill Aura", {
        Title = "",
        Icon = "target"
    })

    local aura = {
        teleportTarget = nil,
        teleportEnabled = false,
        teleportConnection = nil,
        autoShootEnabled = true,
        autoReloadEnabled = false,
        shootInterval = 0.1,
        lastShotTime = 0,
        lastReloadTime = 0
    }

    local function updatePlayerList()
        local playerList = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Player then
                table.insert(playerList, player.Name)
            end
        end
        return playerList
    end

    local function shootAtTarget()
        if not aura.teleportEnabled or not aura.teleportTarget then return end
        
        local targetChar = aura.teleportTarget.Character
        if not targetChar then return end
        
        local targetPart = targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")
        if not targetPart then return end
        
        local velocity = targetPart.Velocity
        local predictedPosition = targetPart.Position + (velocity * 0.15) 
        
        if aura.autoReloadEnabled and tick() - aura.lastReloadTime >= 1 then
            vim:SendKeyEvent(true, Enum.KeyCode.R, false, game)
            vim:SendKeyEvent(false, Enum.KeyCode.R, false, game)
            aura.lastReloadTime = tick()
        end
        
        if aura.autoShootEnabled and tick() - aura.lastShotTime >= aura.shootInterval then
            local weaponTool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
            local handle = weaponTool and weaponTool:FindFirstChild("Handle")
            
            if weaponTool and handle then
                ShootEvent:FireServer(
                    "ShootGun",
                    handle,
                    handle.Position,
                    {predictedPosition},
                    {targetPart},
                    {Vector3.new()},
                    {},
                    tick(),
                    9999,
                    {predictedPosition},
                    1,
                    0,
                    predictedPosition
                )
                aura.lastShotTime = tick()
            end
        end
    end

    local playerDropdown = KillAuraSection:AddDropdown('PlayerSelector', {
        Title = 'Select Player',
        Values = updatePlayerList(),
        Default = 1,
        Callback = function(Value)
            aura.teleportTarget = Players:FindFirstChild(Value)
        end
    })

    KillAuraSection:AddToggle('KillAuraToggle', {
        Title = 'Kill Aura',
        Default = false,
        Callback = function(Value)
            aura.teleportEnabled = Value
            if Value then
                if aura.teleportConnection then
                    aura.teleportConnection:Disconnect()
                end
                
          
                if aura.teleportTarget then
                    Fluent:Notify({
                        Title = "Kill Aura",
                        Content = "Enabled for "..aura.teleportTarget.Name,
                        Duration = 3
                    })
                else
                    Fluent:Notify({
                        Title = "Kill Aura",
                        Content = "No player selected",
                        Duration = 3
                    })
                end
            else
                if aura.teleportConnection then
                    aura.teleportConnection:Disconnect()
                    aura.teleportConnection = nil
                end
            end
        end
    })



    local function refreshPlayerList()
        local players = updatePlayerList()
        playerDropdown:SetValues(players)
        
        if aura.teleportTarget and table.find(players, aura.teleportTarget.Name) then
            playerDropdown:SetValue(aura.teleportTarget.Name)
        elseif #players > 0 then
            playerDropdown:SetValue(players[1])
            aura.teleportTarget = Players:FindFirstChild(players[1])
        else
            aura.teleportTarget = nil
        end
    end

    local function onCharacterAdded(player, character)
        if player == aura.teleportTarget and aura.teleportEnabled then
            character:WaitForChild("HumanoidRootPart")
            task.wait(0.5)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            player.CharacterAdded:Connect(function(character)
                onCharacterAdded(player, character)
            end)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            onCharacterAdded(player, character)
        end)
        refreshPlayerList()
    end)

    Players.PlayerRemoving:Connect(function(player)
        refreshPlayerList()
        
        if player == aura.teleportTarget then
            aura.teleportEnabled = false
            if aura.teleportConnection then
                aura.teleportConnection:Disconnect()
                aura.teleportConnection = nil
            end
            KillAuraSection:SetToggle('KillAuraToggle', false)
        end
    end)

    refreshPlayerList()
end


local ESP_SETTINGS = {
    Enabled = false,
    Box_Color = Color3.fromRGB(255, 0, 0),
    Box_Thickness = 2,
    Team_Check = false,
    Team_Color = false,
    Autothickness = true,
    Rainbow = false,
    HighlightEnabled = false,
    HighlightColor = Color3.fromRGB(255, 0, 0), 
    HighlightTransparency = 0.7, 
    HighlightFillTransparency = 0.8 
}

local highlights = {} 

local function createHighlight(character)
    if not character or not character.Parent then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if highlights[character] then 
        if highlights[character].Parent then
            return
        else
            highlights[character] = nil
        end
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "high"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = ESP_SETTINGS.HighlightColor
    highlight.OutlineColor = ESP_SETTINGS.HighlightColor
    highlight.OutlineTransparency = ESP_SETTINGS.HighlightTransparency
    highlight.FillTransparency = ESP_SETTINGS.HighlightFillTransparency
    highlight.Parent = character
    
    highlights[character] = highlight
end

local function removeHighlight(character)
    if highlights[character] then
        highlights[character]:Destroy()
        highlights[character] = nil
    end
end

local function updateHighlights()
    for character, highlight in pairs(highlights) do
        if highlight and highlight.Parent then
            if highlight.FillColor ~= ESP_SETTINGS.HighlightColor then
                highlight.FillColor = ESP_SETTINGS.HighlightColor
                highlight.OutlineColor = ESP_SETTINGS.HighlightColor
            end
            highlight.OutlineTransparency = ESP_SETTINGS.HighlightTransparency
            highlight.FillTransparency = ESP_SETTINGS.HighlightFillTransparency
        end
    end
end

local function toggleHighlights(state)
    if state then

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Player and player.Character then
                createHighlight(player.Character)
            end
        end

        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                if ESP_SETTINGS.HighlightEnabled then
                    createHighlight(character)
                end
            end)
        end)

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Player then
                player.CharacterAdded:Connect(function(character)
                    if ESP_SETTINGS.HighlightEnabled then
                        createHighlight(character)
                    end
                end)
            end
        end
    else

        for character, _ in pairs(highlights) do
            removeHighlight(character)
        end
        highlights = {}
    end
end


do
    local HighlightSection = Tabs.Visual:AddSection("Highlights", {
        Title = "",
        Icon = "eye"
    })

    HighlightSection:AddToggle("EnableHighlights", {
        Title = "Highlights",
        Default = ESP_SETTINGS.HighlightEnabled,
        Callback = function(state)
            ESP_SETTINGS.HighlightEnabled = state
            toggleHighlights(state)
        end
    })

    local Colorpicker = HighlightSection:AddColorpicker("HighlightColor", {
        Title = "Color",
        Default = ESP_SETTINGS.HighlightColor
    })

    Colorpicker:OnChanged(function()
        ESP_SETTINGS.HighlightColor = Colorpicker.Value
        updateHighlights()
    end)

    HighlightSection:AddSlider("HighlightTransparency", {
        Title = "Outline",
        Default = ESP_SETTINGS.HighlightTransparency,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(value)
            ESP_SETTINGS.HighlightTransparency = value
            updateHighlights()
        end
    })

    HighlightSection:AddSlider("HighlightFillTransparency", {
        Title = "Fill",
        Default = ESP_SETTINGS.HighlightFillTransparency,
        Min = 0,
        Max = 1,
        Rounding = 2,
        Callback = function(value)
            ESP_SETTINGS.HighlightFillTransparency = value
            updateHighlights()
        end
    })
end
local heartbeatConnections = {}
local mainHeartbeatConnection = nil
local function update()
    if player.noclipActive and Player.Character then
        for _, part in ipairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if player.strafe.strafeEnabled and Player.Character then
        ApplyAirControl()
    end
    

    if player.strafe.spinning and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(player.strafe.spinSpeed) * deltaTime * 60, 0)
    end

    if tg.bangState.Active and tg.bangState.Connection then
        if not tg.bangState.Active then return end
        
        local targetPlayer = findTargetPlayer()
        if targetPlayer and targetPlayer.Character then
            local targetHead = targetPlayer.Character:FindFirstChild("Head")
            local localRoot = Player.Character:FindFirstChild("HumanoidRootPart")
            
            if targetHead and localRoot then
                local desiredCFrame = targetHead.CFrame * CFrame.new(0, 0, 1.2)
                
                localRoot.CFrame = desiredCFrame
                localRoot.Velocity = Vector3.new(0,0,0)
                
                for _, part in ipairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Massless = true
                    end
                end
            end
        end
    end
    
    if tg.headsitState.Active and tg.headsitState.Connection then
        if not tg.headsitState.Active then return end
        
        local targetPlayer = findTargetPlayer()
        if targetPlayer and targetPlayer.Character then
            local targetHead = targetPlayer.Character:FindFirstChild("Head")
            local localRoot = Player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = Player.Character:FindFirstChild("Humanoid")
            
            if targetHead and localRoot and humanoid then
                local newCFrame = targetHead.CFrame * CFrame.new(0, 2, 0)
                localRoot.CFrame = newCFrame
                localRoot.Velocity = Vector3.new(0,0,0)
                humanoid.Sit = true
            end
        end
    end
    

    if tg.standState.Active and tg.standState.Connection then
        if not tg.standState.Active then return end
        
        local targetPlayer = findTargetPlayer()
        if targetPlayer and targetPlayer.Character then
            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local localRoot = Player.Character:FindFirstChild("HumanoidRootPart")
            
            if targetRoot and localRoot then
                local offsetCFrame = CFrame.new(-3, 1, 0)
                local desiredPosition = targetRoot.CFrame * offsetCFrame
                
                localRoot.CFrame = desiredPosition
                localRoot.Velocity = Vector3.new(0,0,0)
                localRoot.CFrame = CFrame.new(localRoot.Position, targetRoot.Position)
            end
        end
    end
    

    if aim.autoreload then
        autoReload()
    end

end
mainHeartbeatConnection = RunService.Heartbeat:Connect(update)
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player.Character and highlights[player.Character] then
        removeHighlight(player.Character)
    end
end)

do
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("WAPremiumUI")
    SaveManager:SetFolder("WAPremiumUI/configs")
    
    InterfaceManager:BuildInterfaceSection(Tabs.Config)
    SaveManager:BuildConfigSection(Tabs.Config)
end

Window:SelectTab(1)
Fluent:Notify({
    Title = "Onyx HUB",
    Content = "Succesfully loaded menu!",
    SubContent = "Press Left Ctrl to show menu",
    Duration = 6
})
