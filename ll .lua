local Library = {}

local onyxVersion = "v1.1A."

local TweenService = game:GetService("TweenService")
local input = game:GetService("UserInputService")

local themouse = game.Players.LocalPlayer:GetMouse()

local function Notify(tt, tx)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = tt,
        Text = tx,
        Duration = 5
    })
end

local function Dragify(frame, parent)
    parent = parent or frame

    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    input.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position  = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

local function round(num, bracket)
    bracket = bracket or 1
    local a = math.floor(num/bracket + (math.sign(num) * 0.5)) * bracket
    if a < 0 then
        a = a + bracket
    end
    return a
end

local function buttoneffect(options)
    pcall(function()
        options.entered.MouseEnter:Connect(function()
            if options.frame.TextColor3 ~= Color3.fromRGB(234, 239, 246) then
                TweenService:Create(options.frame, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    TextColor3 = Color3.fromRGB(234, 239, 245)
                }):Play()
            end
        end)
        options.entered.MouseLeave:Connect(function()
            if options.frame.TextColor3 ~= Color3.fromRGB(157, 171, 182) and options.frame.TextColor3 ~= Color3.fromRGB(234, 239, 246) then
                TweenService:Create(options.frame, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    TextColor3 = Color3.fromRGB(157, 171, 182)
                }):Play()
            end
        end)
    end)
end

local function clickEffect(options)
    options.button.MouseButton1Click:Connect(function()
        local new = options.button.TextSize - tonumber(options.amount)
        local revert = new + tonumber(options.amount)
        TweenService:Create(options.button, TweenInfo.new(0.15, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {TextSize = new}):Play()
        wait(0.1)
        TweenService:Create(options.button, TweenInfo.new(0.1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {TextSize = revert}):Play()
    end)
end

-- Функция для защиты GUI от обнаружения
local function ProtectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    elseif gethui then
        gui.Parent = gethui()
    elseif game.CoreGui:FindFirstChild("RobloxGui") then
        gui.Parent = game.CoreGui:FindFirstChild("RobloxGui")
    else
        gui.Parent = game.CoreGui
    end
    
    -- Скрываем GUI в выходных данных
    if set_hidden_property then
        pcall(function()
            set_hidden_property(gui, "Name", math.random(100000, 999999))
        end)
    end
end

function Library:Toggle(value)
    if not self.Gui or not self.Gui.ScreenGui then return end
    enabled = (type(value) == "boolean" and value) or self.Gui.ScreenGui.Enabled
    self.Gui.ScreenGui.Enabled = not enabled
end

function Library:Window(options)
    options.text = options.text or "onyx"

    local SG = Instance.new("ScreenGui")
    local Body = Instance.new("Frame")
    Dragify(Body, Body)
    local bodyCorner = Instance.new("UICorner")

    local SideBar = Instance.new("Frame")
    local sidebarCorner = Instance.new("UICorner")
    local sbLine = Instance.new("Frame")

    local TopBar = Instance.new("Frame")
    local tbLine = Instance.new("Frame")
    local Title = Instance.new("TextLabel")

    local allPages = Instance.new("Frame")
    local tabContainer = Instance.new("Frame")

    -- Защищаем GUI
    ProtectGui(SG)
    
    SG.Name = "onyx"
    SG.ResetOnSpawn = false

    Body.Name = "Body"
    Body.Parent = SG
    Body.AnchorPoint = Vector2.new(0.5, 0.5)
    Body.BackgroundColor3 = Color3.fromRGB(9, 8, 13)
    Body.BorderSizePixel = 0
    Body.Position = UDim2.new(0.465730786, 0, 0.5, 0)
    Body.Size = UDim2.new(0, 658, 0, 516)

    bodyCorner.CornerRadius = UDim.new(0, 4)
    bodyCorner.Name = "bodyCorner"
    bodyCorner.Parent = Body

    SideBar.Name = "SideBar"
    SideBar.Parent = Body
    SideBar.BackgroundColor3 = Color3.fromRGB(26, 36, 48)
    SideBar.BorderSizePixel = 0
    SideBar.Size = UDim2.new(0, 187, 0, 516)

    sidebarCorner.CornerRadius = UDim.new(0, 4)
    sidebarCorner.Name = "sidebarCorner"
    sidebarCorner.Parent = SideBar

    sbLine.Name = "sbLine"
    sbLine.Parent = SideBar
    sbLine.BackgroundColor3 = Color3.fromRGB(15, 23, 36)
    sbLine.BorderSizePixel = 0
    sbLine.Position = UDim2.new(0.99490571, 0, 0, 0)
    sbLine.Size = UDim2.new(0, 3, 0, 516)

    TopBar.Name = "TopBar"
    TopBar.Parent = Body
    TopBar.BackgroundColor3 = Color3.fromRGB(9, 8, 13)
    TopBar.BackgroundTransparency = 1.000
    TopBar.BorderColor3 = Color3.fromRGB(14, 21, 32)
    TopBar.BorderSizePixel = 0
    TopBar.Position = UDim2.new(0.25166446, 0, 0, 0)
    TopBar.Size = UDim2.new(0, 562, 0, 49)

    tbLine.Name = "tbLine"
    tbLine.Parent = TopBar
    tbLine.BackgroundColor3 = Color3.fromRGB(15, 23, 36)
    tbLine.BorderSizePixel = 0
    tbLine.Position = UDim2.new(0.0400355868, 0, 1, 0)
    tbLine.Size = UDim2.new(0, 469, 0, 3)

    Title.Name = "Title"
    Title.Parent = SideBar
    Title.BackgroundColor3 = Color3.fromRGB(234, 239, 245)
    Title.BackgroundTransparency = 1.000
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0.0614973232, 0, 0.0213178284, 0)
    Title.Size = UDim2.new(0, 162, 0, 26)
    Title.Font = Enum.Font.ArialBold
    Title.Text = options.text
    Title.TextColor3 = Color3.fromRGB(234, 239, 245)
    Title.TextSize = 28.000
    Title.TextWrapped = true

    allPages.Name = "allPages"
    allPages.Parent = Body
    allPages.BackgroundColor3 = Color3.fromRGB(234, 239, 245)
    allPages.BackgroundTransparency = 1.000
    allPages.BorderSizePixel = 0
    allPages.Position = UDim2.new(0.29508087, 0, 0.100775197, 0)
    allPages.Size = UDim2.new(0, 463, 0, 464)

    tabContainer.Name = "tabContainer"
    tabContainer.Parent = SideBar
    tabContainer.BackgroundColor3 = Color3.fromRGB(234, 239, 245)
    tabContainer.BackgroundTransparency = 1.000
    tabContainer.BorderSizePixel = 0
    tabContainer.Position = UDim2.new(0, 0, 0.100775197, 0)
    tabContainer.Size = UDim2.new(0, 187, 0, 464)

    -- Сохраняем все элементы GUI в одной переменной
    self.Gui = {
        ScreenGui = SG,
        Body = Body,
        SideBar = SideBar,
        TopBar = TopBar,
        Title = Title,
        AllPages = allPages,
        TabContainer = tabContainer,
        Tabs = {}
    }

    -- Обработчик переключения GUI
    game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightControl then
            Library:Toggle()
        end
    end)

    local tabsections = {}

    function tabsections:TabSection(options)
        options.text = options.text or "Tab Section"

        local tabLayout = Instance.new("UIListLayout")
        local tabSection = Instance.new("Frame")
        local tabSectionLabel = Instance.new("TextLabel")
        local tabSectionLayout = Instance.new("UIListLayout")

        tabLayout.Name = "tabLayout"
        tabLayout.Parent = tabContainer

        tabSection.Name = "tabSection"
        tabSection.Parent = tabContainer
        tabSection.BackgroundColor3 = Color3.fromRGB(234, 239, 245)
        tabSection.BackgroundTransparency = 1.000
        tabSection.BorderSizePixel = 0
        tabSection.Size = UDim2.new(0, 189, 0, 22)

        local function ResizeTS(num)
            tabSection.Size += UDim2.new(0, 0, 0, num)
        end

        tabSectionLabel.Name = "tabSectionLabel"
        tabSectionLabel.Parent = tabSection
        tabSectionLabel.BackgroundColor3 = Color3.fromRGB(234, 239, 245)
        tabSectionLabel.BackgroundTransparency = 1.000
        tabSectionLabel.BorderSizePixel = 0
        tabSectionLabel.Size = UDim2.new(0, 190, 0, 22)
        tabSectionLabel.Font = Enum.Font.Gotham
        tabSectionLabel.Text = "     ".. options.text
        tabSectionLabel.TextColor3 = Color3.fromRGB(79, 107, 126)
        tabSectionLabel.TextSize = 17.000
        tabSectionLabel.TextXAlignment = Enum.TextXAlignment.Left

        tabSectionLayout.Name = "tabSectionLayout"
        tabSectionLayout.Parent = tabSection
        tabSectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabSectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabSectionLayout.Padding = UDim.new(0, 7)

        local tabs = {}

        function tabs:Tab(options)
            options.text = options.text or "New Tab"
            options.icon = options.icon or "rbxassetid://7999345313"

            local tabButton = Instance.new("TextButton")
            local tabButtonCorner = Instance.new("UICorner")
            local tabIcon = Instance.new("ImageLabel")

            local newPage = Instance.new("ScrollingFrame")
            local pageLayout = Instance.new("UIGridLayout")

            tabButton.Name = "tabButton"
            tabButton.Parent = tabSection
            tabButton.BackgroundColor3 = Color3.fromRGB(13, 57, 84)
            tabButton.BorderSizePixel = 0
            tabButton.Position = UDim2.new(0.0714285746, 0, 0.402777791, 0)
            tabButton.Size = UDim2.new(0, 165, 0, 30)
            tabButton.AutoButtonColor = false
            tabButton.Font = Enum.Font.GothamSemibold
            tabButton.Text = "             " .. options.text
            tabButton.TextColor3 = Color3.fromRGB(234, 239, 245)
            tabButton.TextSize = 14.000
            tabButton.BackgroundTransparency = 1
            tabButton.TextXAlignment = Enum.TextXAlignment.Left
            tabButton.MouseButton1Click:Connect(function()
                for i,v in next, allPages:GetChildren() do
                    v.Visible = false
                end

                newPage.Visible = true

                for i,v in next, SideBar:GetDescendants() do
                    if v:IsA("TextButton") then
                        TweenService:Create(v, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end

                TweenService:Create(tabButton, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    BackgroundTransparency = 0
                }):Play()
            end)

            tabButtonCorner.CornerRadius = UDim.new(0, 4)
            tabButtonCorner.Name = "tabButtonCorner"
            tabButtonCorner.Parent = tabButton

            tabIcon.Name = "tabIcon"
            tabIcon.Parent = tabButton
            tabIcon.BackgroundColor3 = Color3.fromRGB(234, 239, 245)
            tabIcon.BackgroundTransparency = 1.000
            tabIcon.BorderSizePixel = 0
            tabIcon.Position = UDim2.new(0.0408859849, 0, 0.133333355, 0)
            tabIcon.Size = UDim2.new(0, 21, 0, 21)
            tabIcon.Image = options.icon
            tabIcon.ImageColor3 = Color3.fromRGB(43, 154, 198)

            newPage.Name = "newPage"
            newPage.Parent = allPages
            newPage.Visible = false
            newPage.BackgroundColor3 = Color3.fromRGB(234, 239, 245)
            newPage.BackgroundTransparency = 1.000
            newPage.BorderSizePixel = 0
            newPage.ClipsDescendants = false
            newPage.Position = UDim2.new(0.021598272, 0, 0.0237068962, 0)
            newPage.Size = UDim2.new(0, 442, 0, 440)
            newPage.ScrollBarThickness = 4
            newPage.CanvasSize = UDim2.new(0,0,0,0)

            pageLayout.Name = "pageLayout"
            pageLayout.Parent = newPage
            pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
            pageLayout.CellPadding = UDim2.new(0, 12, 0, 12)
            pageLayout.CellSize = UDim2.new(0, 215, 0, -10)
            pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                newPage.CanvasSize = UDim2.new(0,0,0,pageLayout.AbsoluteContentSize.Y) 
            end)

            ResizeTS(50)

            -- Сохраняем вкладку в общую структуру GUI
            table.insert(self.Gui.Tabs, {
                Button = tabButton,
                Page = newPage,
                Name = options.text
            })

            local sections = {}

            function sections:Section(options)
                options.text = options.text or "Section"

                local sectionFrame = Instance.new("Frame")
                local sectionLabel = Instance.new("TextLabel")
                local sectionFrameCorner = Instance.new("UICorner")
                local sectionLayout = Instance.new("UIListLayout")
                local sLine = Instance.new("TextLabel")
                local sectionSizeConstraint = Instance.new("UISizeConstraint")

                sectionFrame.Name = "sectionFrame"
                sectionFrame.Parent = newPage
                sectionFrame.BackgroundColor3 = Color3.fromRGB(0, 15, 30)
                sectionFrame.BorderSizePixel = 0
                sectionFrame.Size = UDim2.new(0, 215, 0, 134)

                sectionLabel.Name = "sectionLabel"
                sectionLabel.Parent = sectionFrame
                sectionLabel.BackgroundColor3 = Color3.fromRGB(234, 239, 245)
                sectionLabel.BackgroundTransparency = 1.000
                sectionLabel.BorderSizePixel = 0
                sectionLabel.Position = UDim2.new(0.0121902823, 0, 0, 0)
                sectionLabel.Size = UDim2.new(0, 213, 0, 25)
                sectionLabel.Font = Enum.Font.GothamSemibold
                sectionLabel.Text = "   " .. options.text
                sectionLabel.TextColor3 = Color3.fromRGB(234, 239, 245)
                sectionLabel.TextSize = 14.000
                sectionLabel.TextXAlignment = Enum.TextXAlignment.Left

                sectionFrameCorner.CornerRadius = UDim.new(0, 4)
                sectionFrameCorner.Name = "sectionFrameCorner"
                sectionFrameCorner.Parent = sectionFrame

                sectionLayout.Name = "sectionLayout"
                sectionLayout.Parent = sectionFrame
                sectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
                sectionLayout.Padding = UDim.new(0, 2)

                sLine.Name = "sLine"
                sLine.Parent = sectionFrame
                sLine.BackgroundColor3 = Color3.fromRGB(13, 28, 44)
                sLine.BorderSizePixel = 0
                sLine.Position = UDim2.new(0.0255813953, 0, 0.41538462, 0)
                sLine.Size = UDim2.new(0, 202, 0, 3)
                sLine.Font = Enum.Font.SourceSans
                sLine.Text = ""
                sLine.TextColor3 = Color3.fromRGB(0, 0, 0)
                sLine.TextSize = 0

                sectionSizeConstraint.Name = "sectionSizeConstraint"
                sectionSizeConstraint.Parent = sectionFrame
                sectionSizeConstraint.MinSize = Vector2.new(215, 35)

                local function Resize(num)
                    sectionSizeConstraint.MinSize += Vector2.new(0, num)
                end

                local elements = {}

                function elements:Button(options)
                    if not options.text or not options.callback then Notify("Button", "Missing arguments!") return end

                    local TextButton = Instance.new("TextButton")

                    TextButton.Parent = sectionFrame
                    TextButton.BackgroundColor3 = Color3.fromRGB(13, 57, 84)
                    TextButton.BorderSizePixel = 0
                    TextButton.Position = UDim2.new(0.0348837227, 0, 0.355555564, 0)
                    TextButton.Size = UDim2.new(0, 200, 0, 22)
                    TextButton.AutoButtonColor = false
                    TextButton.Text = options.text
                    TextButton.Font = Enum.Font.Gotham
                    TextButton.TextColor3 = Color3.fromRGB(157, 171, 182)
                    TextButton.TextSize = 14.000
                    TextButton.BackgroundTransparency = 1
                    buttoneffect({frame = TextButton, entered = TextButton})
                    clickEffect({button = TextButton, amount = 5})
                    TextButton.MouseButton1Click:Connect(function()
                        options.callback()
                    end)

                    Resize(25)
                end

                function elements:Toggle(options)
                    if not options.text or not options.callback then Notify("Toggle", "Missing arguments!") return end

                    local toggleLabel = Instance.new("TextLabel")
                    local toggleFrame = Instance.new("TextButton")
                    local togFrameCorner = Instance.new("UICorner")
                    local toggleButton = Instance.new("TextButton")
                    local togBtnCorner = Instance.new("UICorner")

                    local State = options.state or false

                    if options.state then
                        toggleButton.Position = UDim2.new(0.74, 0, 0.5, 0)
                        toggleLabel.TextColor3 = Color3.fromRGB(234, 239, 246)
                        toggleButton.BackgroundColor3 = Color3.fromRGB(2, 162, 243)
                        toggleFrame.BackgroundColor3 = Color3.fromRGB(2, 23, 49)
                    end

                    toggleLabel.Name = "toggleLabel"
                    toggleLabel.Parent = sectionFrame
                    toggleLabel.BackgroundColor3 = Color3.fromRGB(157, 171, 182)
                    toggleLabel.BackgroundTransparency = 1.000
                    toggleLabel.Position = UDim2.new(0.0348837227, 0, 0.965517223, 0)
                    toggleLabel.Size = UDim2.new(0, 200, 0, 22)
                    toggleLabel.Font = Enum.Font.Gotham
                    toggleLabel.Text = " " .. options.text
                    toggleLabel.TextColor3 = Color3.fromRGB(157, 171, 182)
                    toggleLabel.TextSize = 14.000
                    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                    buttoneffect({frame = toggleLabel, entered = toggleLabel})

                    local function PerformToggle()
                        State = not State
                        options.callback(State)
                        TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
                            Position = State and UDim2.new(0.74, 0, 0.5, 0) or UDim2.new(0.25, 0, 0.5, 0)
                        }):Play()
                        TweenService:Create(toggleLabel, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
                            TextColor3 = State and Color3.fromRGB(234, 239, 246) or Color3.fromRGB(157, 171, 182)
                        }):Play()
                        TweenService:Create(toggleButton, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
                            BackgroundColor3 = State and Color3.fromRGB(2, 162, 243) or Color3.fromRGB(77, 77, 77)
                        }):Play()
                        TweenService:Create(toggleFrame, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
                            BackgroundColor3 = State and Color3.fromRGB(2, 23, 49) or Color3.fromRGB(4, 4, 11)
                        }):Play()
                    end

                    toggleFrame.Name = "toggleFrame"
                    toggleFrame.Parent = toggleLabel
                    toggleFrame.BackgroundColor3 = Color3.fromRGB(4, 4, 11)
                    toggleFrame.BorderSizePixel = 0
                    toggleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                    toggleFrame.Position = UDim2.new(0.9, 0, 0.5, 0)
                    toggleFrame.Size = UDim2.new(0, 38, 0, 18)
                    toggleFrame.AutoButtonColor = false
                    toggleFrame.Font = Enum.Font.SourceSans
                    toggleFrame.Text = ""
                    toggleFrame.TextColor3 = Color3.fromRGB(0, 0, 0)
                    toggleFrame.TextSize = 14.000
                    toggleFrame.MouseButton1Click:Connect(function()
                        PerformToggle()
                    end)

                    togFrameCorner.CornerRadius = UDim.new(0, 50)
                    togFrameCorner.Name = "togFrameCorner"
                    togFrameCorner.Parent = toggleFrame

                    toggleButton.Name = "toggleButton"
                    toggleButton.Parent = toggleFrame
                    toggleButton.BackgroundColor3 = Color3.fromRGB(77, 77, 77)
                    toggleButton.BorderSizePixel = 0
                    toggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
                    toggleButton.Position = UDim2.new(0.25, 0, 0.5, 0)
                    toggleButton.Size = UDim2.new(0, 16, 0, 16)
                    toggleButton.AutoButtonColor = false
                    toggleButton.Font = Enum.Font.SourceSans
                    toggleButton.Text = ""
                    toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
                    toggleButton.TextSize = 14.000
                    toggleButton.MouseButton1Click:Connect(function()
                        PerformToggle()
                    end)

                    togBtnCorner.CornerRadius = UDim.new(0, 50)
                    togBtnCorner.Name = "togFrameCorner"
                    togBtnCorner.Parent = toggleButton

                    Resize(25)
                end

                function elements:Slider(options)
                    if not options.text or not options.min or not options.max or not options.callback then Notify("Slider", "Missing arguments!") return end

                    local Slider = Instance.new("Frame")
                    local sliderLabel = Instance.new("TextLabel")
                    local sliderFrame = Instance.new("TextButton")
                    local sliderBall = Instance.new("TextButton")
                    local sliderBallCorner = Instance.new("UICorner")
                    local sliderTextBox = Instance.new("TextBox")
                    buttoneffect({frame = sliderLabel, entered = Slider})

                    local Value
                    local Held = false

                    local UIS = game:GetService("UserInputService")
                    local RS = game:GetService("RunService")
                    local Mouse = game.Players.LocalPlayer:GetMouse()

                    local percentage = 0
                    local step = 0.01

                    local function snap(number, factor)
                        if factor == 0 then
                            return number
                        else
                            return math.floor(number/factor+0.5)*factor
                        end
                    end

                    UIS.InputEnded:Connect(function(Mouse)
                        Held = false
                    end)

                    Slider.Name = "Slider"
                    Slider.Parent = sectionFrame
                    Slider.BackgroundColor3 = Color3.fromRGB(157, 171, 182)
                    Slider.BackgroundTransparency = 1.000
                    Slider.Position = UDim2.new(0.0395348854, 0, 0.947335422, 0)
                    Slider.Size = UDim2.new(0, 200, 0, 22)

                    sliderLabel.Name = "sliderLabel"
                    sliderLabel.Parent = Slider
                    sliderLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                    sliderLabel.BackgroundColor3 = Color3.fromRGB(157, 171, 182)
                    sliderLabel.BackgroundTransparency = 1.000
                    sliderLabel.Position = UDim2.new(0.2, 0, 0.5, 0)
                    sliderLabel.Size = UDim2.new(0, 77, 0, 22)
                    sliderLabel.Font = Enum.Font.Gotham
                    sliderLabel.Text = " " .. options.text
                    sliderLabel.TextColor3 = Color3.fromRGB(157, 171, 182)
                    sliderLabel.TextSize = 14.000
                    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                    sliderLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
                        if sliderLabel.TextBounds.X > 75 then
                            sliderLabel.TextScaled = true
                        else
                            sliderLabel.TextScaled = false
                        end
                    end)

                    sliderFrame.Name = "sliderFrame"
                    sliderFrame.Parent = sliderLabel
                    sliderFrame.BackgroundColor3 = Color3.fromRGB(29, 87, 118)
                    sliderFrame.BorderSizePixel = 0
                    sliderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                    sliderFrame.Position = UDim2.new(1.6, 0, 0.5, 0)
                    sliderFrame.Size = UDim2.new(0, 72, 0, 2)
                    sliderFrame.Text = ""
                    sliderFrame.AutoButtonColor = false
                    sliderFrame.MouseButton1Down:Connect(function()
                        Held = true
                    end)

                    sliderBall.Name = "sliderBall"
                    sliderBall.Parent = sliderFrame
                    sliderBall.AnchorPoint = Vector2.new(0.5, 0.5)
                    sliderBall.BackgroundColor3 = Color3.fromRGB(67, 136, 231)
                    sliderBall.BorderSizePixel = 0
                    sliderBall.Position = UDim2.new(0, 0, 0.5, 0)
                    sliderBall.Size = UDim2.new(0, 14, 0, 14)
                    sliderBall.AutoButtonColor = false
                    sliderBall.Font = Enum.Font.SourceSans
                    sliderBall.Text = ""
                    sliderBall.TextColor3 = Color3.fromRGB(0, 0, 0)
                    sliderBall.TextSize = 14.000
                    sliderBall.MouseButton1Down:Connect(function()
                        Held = true
                    end)

                    RS.RenderStepped:Connect(function()
                        if Held then
                            local BtnPos = sliderBall.Position
                            local MousePos = UIS:GetMouseLocation().X
                            local FrameSize = sliderFrame.AbsoluteSize.X
                            local FramePos = sliderFrame.AbsolutePosition.X
                            local pos = snap((MousePos-FramePos)/FrameSize,step)
                            percentage = math.clamp(pos,0,0.9)

                            Value = ((((tonumber(options.max) - tonumber(options.min)) / 0.9) * percentage)) + tonumber(options.min)
                            Value = round(Value, options.float)
                            Value = math.clamp(Value, options.min, options.max)
                            sliderTextBox.Text = Value
                            options.callback(Value)
                            sliderBall.Position = UDim2.new(percentage,0,BtnPos.Y.Scale, BtnPos.Y.Offset)
                        end
                    end)

                    sliderBallCorner.CornerRadius = UDim.new(0, 50)
                    sliderBallCorner.Name = "sliderBallCorner"
                    sliderBallCorner.Parent = sliderBall

                    sliderTextBox.Name = "sliderTextBox"
                    sliderTextBox.Parent = sliderLabel
                    sliderTextBox.BackgroundColor3 = Color3.fromRGB(1, 7, 17)
                    sliderTextBox.AnchorPoint = Vector2.new(0.5, 0.5)
                    sliderTextBox.Position = UDim2.new(2.4, 0, 0.5, 0)
                    sliderTextBox.Size = UDim2.new(0, 31, 0, 15)
                    sliderTextBox.Font = Enum.Font.Gotham
                    sliderTextBox.Text = options.min
                    sliderTextBox.TextColor3 = Color3.fromRGB(234, 239, 245)
                    sliderTextBox.TextSize = 11.000
                    sliderTextBox.TextWrapped = true

                    sliderTextBox.Focused:Connect(function()
                        TweenService:Create(sliderLabel, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextColor3 = Color3.fromRGB(234, 239, 246)}):Play()
                    end)

                    sliderTextBox.FocusLost:Connect(function(Enter)
                        TweenService:Create(sliderLabel, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextColor3 = Color3.fromRGB(157, 171, 182)}):Play()
                        if Enter then
                            if sliderTextBox.Text ~= nil and sliderTextBox.Text ~= "" then
                                if tonumber(sliderTextBox.Text) > options.max then
                                    sliderTextBox.Text = tostring(options.max)
                                    options.callback(options.max)
                                elseif tonumber(sliderTextBox.Text) < options.min then
                                    sliderTextBox.Text = tostring(options.min)
                                    options.callback(options.min)
                                elseif not tonumber(sliderTextBox.Text) < options.min and not tonumber(sliderTextBox.Text) > options.max then
                                    options.callback(sliderTextBox.Text)
                                end
                            end
                        end
                    end)

                    Resize(25)
                end

                function elements:Dropdown(options)
                    if not options.text or not options.default or not options.list or not options.callback then Notify("Dropdown", "Missing arguments!") return end

                    local DropYSize = 0
                    local Dropped = false

                    local Dropdown = Instance.new("Frame")
                    local dropdownLabel = Instance.new("TextLabel")
                    local dropdownText = Instance.new("TextLabel")
                    local dropdownArrow = Instance.new("ImageButton")
                    local dropdownList = Instance.new("Frame")

                    local dropListLayout = Instance.new("UIListLayout")
                    buttoneffect({frame = dropdownLabel, entered = Dropdown})

                    Dropdown.Name = "Dropdown"
                    Dropdown.Parent = sectionFrame
                    Dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Dropdown.BackgroundTransparency = 1.000
                    Dropdown.BorderSizePixel = 0
                    Dropdown.Position = UDim2.new(0.0697674453, 0, 0.237037033, 0)
                    Dropdown.Size = UDim2.new(0, 200, 0, 22)
                    Dropdown.ZIndex = 2

                    dropdownLabel.Name = "dropdownLabel"
                    dropdownLabel.Parent = Dropdown
                    dropdownLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    dropdownLabel.BackgroundTransparency = 1.000
                    dropdownLabel.BorderSizePixel = 0
                    dropdownLabel.Size = UDim2.new(0, 105, 0, 22)
                    dropdownLabel.Font = Enum.Font.Gotham
                    dropdownLabel.Text = " " .. options.text
                    dropdownLabel.TextColor3 = Color3.fromRGB(157, 171, 182)
                    dropdownLabel.TextSize = 14.000
                    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                    dropdownLabel.TextWrapped = true

                    dropdownText.Name = "dropdownText"
                    dropdownText.Parent = dropdownLabel
                    dropdownText.BackgroundColor3 = Color3.fromRGB(2, 5, 12)
                    dropdownText.Position = UDim2.new(1.08571434, 0, 0.0909090936, 0)
                    dropdownText.Size = UDim2.new(0, 87, 0, 18)
                    dropdownText.Font = Enum.Font.Gotham
                    dropdownText.Text = " " .. options.default
                    dropdownText.TextColor3 = Color3.fromRGB(234, 239, 245)
                    dropdownText.TextSize = 12.000
                    dropdownText.TextXAlignment = Enum.TextXAlignment.Left
                    dropdownText.TextWrapped = true

                    dropdownArrow.Name = "dropdownArrow"
                    dropdownArrow.Parent = dropdownText
                    dropdownArrow.BackgroundColor3 = Color3.fromRGB(2, 5, 12)
                    dropdownArrow.BorderSizePixel = 0
                    dropdownArrow.Position = UDim2.new(0.87356323, 0, 0.138888866, 0)
                    dropdownArrow.Size = UDim2.new(0, 11, 0, 13)
                    dropdownArrow.AutoButtonColor = false
                    dropdownArrow.Image = "rbxassetid://6031091004"
                    dropdownArrow.ImageColor3 = Color3.fromRGB(234, 239, 245)
                    dropdownArrow.MouseButton1Click:Connect(function()
                        Dropped = not Dropped
                        if Dropped then
                            TweenService:Create(dropdownArrow, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Rotation = 180}):Play()
                            TweenService:Create(dropdownLabel, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextColor3 = Color3.fromRGB(234, 239, 246)}):Play()
                            dropdownList.Visible = true
                            Resize(DropYSize)
                        else
                            TweenService:Create(dropdownArrow, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Rotation = 0}):Play()
                            TweenService:Create(dropdownLabel, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextColor3 = Color3.fromRGB(157, 171, 182)}):Play()
                            dropdownList.Visible = false
                            Resize(-DropYSize)
                        end
                    end)

                    dropdownList.Name = "dropdownList"
                    dropdownList.Parent = dropdownLabel
                    dropdownList.BackgroundColor3 = Color3.fromRGB(2, 5, 12)
                    dropdownList.BorderSizePixel = 0
                    dropdownList.Position = UDim2.new(1.08571434, 0, 1.09090912, 0)
                    dropdownList.Size = UDim2.new(0, 87, 0, 0)
                    dropdownList.Visible = false

                    dropListLayout.Name = "dropListLayout"
                    dropListLayout.Parent = dropdownList
                    dropListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    dropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    dropListLayout.Padding = UDim.new(0, 2)

                    for i,v in next, options.list do
                        local dropOption = Instance.new("TextButton")
                        dropOption.Name = "dropOption"
                        dropOption.Parent = dropdownList
                        dropOption.BackgroundColor3 = Color3.fromRGB(2, 5, 12)
                        dropOption.BorderSizePixel = 0
                        dropOption.Size = UDim2.new(0, 87, 0, 18)
                        dropOption.Font = Enum.Font.Gotham
                        dropOption.Text = " " .. v
                        dropOption.TextColor3 = Color3.fromRGB(234, 239, 245)
                        dropOption.TextSize = 12.000
                        dropOption.TextXAlignment = Enum.TextXAlignment.Left
                        dropOption.AutoButtonColor = false
                        dropOption.MouseButton1Click:Connect(function()
                            dropdownText.Text = " " .. v
                            options.callback(v)
                            Dropped = false
                            TweenService:Create(dropdownArrow, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Rotation = 0}):Play()
                            TweenService:Create(dropdownLabel, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextColor3 = Color3.fromRGB(157, 171, 182)}):Play()
                            dropdownList.Visible = false
                            Resize(-DropYSize)
                        end)
                        DropYSize += 20
                    end

                    Resize(25)
                end

                function elements:Textbox(options)
                    if not options.text or not options.callback then Notify("Textbox", "Missing arguments!") return end

                    local Textbox = Instance.new("Frame")
                    local textboxLabel = Instance.new("TextLabel")
                    local textboxFrame = Instance.new("TextBox")
                    buttoneffect({frame = textboxLabel, entered = Textbox})

                    Textbox.Name = "Textbox"
                    Textbox.Parent = sectionFrame
                    Textbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Textbox.BackgroundTransparency = 1.000
                    Textbox.BorderSizePixel = 0
                    Textbox.Position = UDim2.new(0.0697674453, 0, 0.237037033, 0)
                    Textbox.Size = UDim2.new(0, 200, 0, 22)

                    textboxLabel.Name = "textboxLabel"
                    textboxLabel.Parent = Textbox
                    textboxLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    textboxLabel.BackgroundTransparency = 1.000
                    textboxLabel.BorderSizePixel = 0
                    textboxLabel.Size = UDim2.new(0, 105, 0, 22)
                    textboxLabel.Font = Enum.Font.Gotham
                    textboxLabel.Text = " " .. options.text
                    textboxLabel.TextColor3 = Color3.fromRGB(157, 171, 182)
                    textboxLabel.TextSize = 14.000
                    textboxLabel.TextXAlignment = Enum.TextXAlignment.Left

                    textboxFrame.Name = "textboxFrame"
                    textboxFrame.Parent = textboxLabel
                    textboxFrame.BackgroundColor3 = Color3.fromRGB(2, 5, 12)
                    textboxFrame.Position = UDim2.new(1.08571434, 0, 0.0909090936, 0)
                    textboxFrame.Size = UDim2.new(0, 87, 0, 18)
                    textboxFrame.Font = Enum.Font.Gotham
                    textboxFrame.Text = ""
                    textboxFrame.TextColor3 = Color3.fromRGB(234, 239, 245)
                    textboxFrame.TextSize = 12.000
                    textboxFrame.TextXAlignment = Enum.TextXAlignment.Left

                    textboxFrame.Focused:Connect(function()
                        TweenService:Create(textboxLabel, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextColor3 = Color3.fromRGB(234, 239, 246)}):Play()
                    end)

                    textboxFrame.FocusLost:Connect(function(Enter)
                        TweenService:Create(textboxLabel, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextColor3 = Color3.fromRGB(157, 171, 182)}):Play()
                        if Enter then
                            options.callback(textboxFrame.Text)
                        end
                    end)

                    Resize(25)
                end

                function elements:Keybind(options)
                    if not options.text or not options.default or not options.callback then Notify("Keybind", "Missing arguments!") return end

                    local Keybind = Instance.new("Frame")
                    local keybindLabel = Instance.new("TextLabel")
                    local keybindFrame = Instance.new("TextButton")
                    buttoneffect({frame = keybindLabel, entered = Keybind})

                    local Listening = false
                    local Key = options.default

                    Keybind.Name = "Keybind"
                    Keybind.Parent = sectionFrame
                    Keybind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Keybind.BackgroundTransparency = 1.000
                    Keybind.BorderSizePixel = 0
                    Keybind.Position = UDim2.new(0.0697674453, 0, 0.237037033, 0)
                    Keybind.Size = UDim2.new(0, 200, 0, 22)

                    keybindLabel.Name = "keybindLabel"
                    keybindLabel.Parent = Keybind
                    keybindLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    keybindLabel.BackgroundTransparency = 1.000
                    keybindLabel.BorderSizePixel = 0
                    keybindLabel.Size = UDim2.new(0, 105, 0, 22)
                    keybindLabel.Font = Enum.Font.Gotham
                    keybindLabel.Text = " " .. options.text
                    keybindLabel.TextColor3 = Color3.fromRGB(157, 171, 182)
                    keybindLabel.TextSize = 14.000
                    keybindLabel.TextXAlignment = Enum.TextXAlignment.Left

                    keybindFrame.Name = "keybindFrame"
                    keybindFrame.Parent = keybindLabel
                    keybindFrame.BackgroundColor3 = Color3.fromRGB(2, 5, 12)
                    keybindFrame.Position = UDim2.new(1.08571434, 0, 0.0909090936, 0)
                    keybindFrame.Size = UDim2.new(0, 87, 0, 18)
                    keybindFrame.Font = Enum.Font.Gotham
                    keybindFrame.Text = " " .. Key.Name
                    keybindFrame.TextColor3 = Color3.fromRGB(234, 239, 245)
                    keybindFrame.TextSize = 12.000
                    keybindFrame.TextXAlignment = Enum.TextXAlignment.Left
                    keybindFrame.AutoButtonColor = false
                    keybindFrame.MouseButton1Click:Connect(function()
                        Listening = true
                        keybindFrame.Text = " ..."
                        TweenService:Create(keybindLabel, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextColor3 = Color3.fromRGB(234, 239, 246)}):Play()
                    end)

                    UIS.InputBegan:Connect(function(input, processed)
                        if not processed then
                            if Listening then
                                if input.UserInputType == Enum.UserInputType.Keyboard then
                                    Key = input.KeyCode
                                    keybindFrame.Text = " " .. input.KeyCode.Name
                                    Listening = false
                                    TweenService:Create(keybindLabel, TweenInfo.new(0.06, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextColor3 = Color3.fromRGB(157, 171, 182)}):Play()
                                end
                            else
                                if input.KeyCode == Key then
                                    options.callback()
                                end
                            end
                        end
                    end)

                    Resize(25)
                end

                function elements:Label(options)
                    if not options.text then Notify("Label", "Missing arguments!") return end

                    local Label = Instance.new("TextLabel")
                    Label.Parent = sectionFrame
                    Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Label.BackgroundTransparency = 1.000
                    Label.Position = UDim2.new(0.0697674453, 0, 0.237037033, 0)
                    Label.Size = UDim2.new(0, 200, 0, 22)
                    Label.Font = Enum.Font.Gotham
                    Label.Text = " " .. options.text
                    Label.TextColor3 = Color3.fromRGB(234, 239, 245)
                    Label.TextSize = 14.000
                    Label.TextXAlignment = Enum.TextXAlignment.Left

                    Resize(25)
                end

                return elements
            end

            return sections
        end

        return tabs
    end

    return tabsections
end

return Library
