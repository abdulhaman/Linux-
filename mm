local Library = {}

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local GuiParent = CoreGui
if syn and syn.protect_gui then
    -- will protect below
elseif gethui then
    GuiParent = gethui()
end

local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
if viewportSize.X < 800 then
    isMobile = true
end

local defaultSize = isMobile and UDim2.new(0, 580, 0, 360) or UDim2.new(0, 780, 0, 560)
local minSize = UDim2.new(0, 450, 0, 300)
local maxSize = UDim2.new(0, 1000, 0, 800)

local Themes = {
    ["macOS Dark"] = {
        MainBg = Color3.fromRGB(24, 24, 24),
        SidebarBg = Color3.fromRGB(20, 20, 20),
        TopBar = Color3.fromRGB(20, 20, 20),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(150, 150, 150),
        Accent = Color3.fromRGB(255, 255, 255),
        SectionBg = Color3.fromRGB(30, 30, 30),
        ElementBg = Color3.fromRGB(35, 35, 35),
        HoverBg = Color3.fromRGB(45, 45, 45),
        Border = Color3.fromRGB(40, 40, 40),
        ToggleOn = Color3.fromRGB(255, 255, 255),
        ToggleOff = Color3.fromRGB(60, 60, 60),
    },
    ["macOS Light"] = {
        MainBg = Color3.fromRGB(245, 245, 245),
        SidebarBg = Color3.fromRGB(235, 235, 235),
        TopBar = Color3.fromRGB(235, 235, 235),
        Text = Color3.fromRGB(20, 20, 20),
        SubText = Color3.fromRGB(100, 100, 100),
        Accent = Color3.fromRGB(0, 0, 0),
        SectionBg = Color3.fromRGB(255, 255, 255),
        ElementBg = Color3.fromRGB(225, 225, 225),
        HoverBg = Color3.fromRGB(210, 210, 210),
        Border = Color3.fromRGB(200, 200, 200),
        ToggleOn = Color3.fromRGB(0, 0, 0),
        ToggleOff = Color3.fromRGB(180, 180, 180),
    },
    ["Carbon"] = {
        MainBg = Color3.fromRGB(15, 15, 15),
        SidebarBg = Color3.fromRGB(10, 10, 10),
        TopBar = Color3.fromRGB(10, 10, 10),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(120, 120, 120),
        Accent = Color3.fromRGB(255, 60, 60),
        SectionBg = Color3.fromRGB(20, 20, 20),
        ElementBg = Color3.fromRGB(25, 25, 25),
        HoverBg = Color3.fromRGB(35, 35, 35),
        Border = Color3.fromRGB(30, 30, 30),
        ToggleOn = Color3.fromRGB(255, 60, 60),
        ToggleOff = Color3.fromRGB(40, 40, 40),
    }
}

local function Create(class, properties)
    local inst = Instance.new(class)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
end

local function Tween(inst, time, props)
    local t = TweenService:Create(inst, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function MakeDraggable(topbar, window)
    local dragging, dragInput, dragStart, startPos
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Library:MakeWindow(config)
    local TitleText = config.Title or "Window"
    local SubTitleText = config.SubTitle or ""
    local CurrentTheme = Themes["macOS Dark"]

    local ScreenGui = Create("ScreenGui", {
        Name = "redzlib_macos",
        Parent = GuiParent,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    end

    local Main = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CurrentTheme.MainBg,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = defaultSize,
        ClipsDescendants = false
    })

    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Main })
    
    local DropShadow = Create("ImageLabel", {
        Name = "DropShadow",
        Parent = Main,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 10, 1, 10),
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        ZIndex = -1
    })

    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = Main,
        BackgroundColor3 = CurrentTheme.TopBar,
        Size = UDim2.new(1, 0, 0, 40),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = TopBar })
    Create("Frame", {
        Parent = TopBar,
        BackgroundColor3 = CurrentTheme.TopBar,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10),
        BorderSizePixel = 0
    })

    MakeDraggable(TopBar, Main)

    local Controls = Create("Frame", {
        Name = "Controls",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0.5, -6),
        Size = UDim2.new(0, 52, 0, 12)
    })
    local UIListLayout = Create("UIListLayout", {
        Parent = Controls,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })

    local CloseBtn = Create("TextButton", {
        Name = "Close",
        Parent = Controls,
        BackgroundColor3 = Color3.fromRGB(255, 95, 86),
        Size = UDim2.new(0, 12, 0, 12),
        Text = "",
        AutoButtonColor = false
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = CloseBtn })

    local MinimizeBtn = Create("TextButton", {
        Name = "Minimize",
        Parent = Controls,
        BackgroundColor3 = Color3.fromRGB(255, 189, 46),
        Size = UDim2.new(0, 12, 0, 12),
        Text = "",
        AutoButtonColor = false
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = MinimizeBtn })

    local MaximizeBtn = Create("TextButton", {
        Name = "Maximize",
        Parent = Controls,
        BackgroundColor3 = Color3.fromRGB(39, 201, 63),
        Size = UDim2.new(0, 12, 0, 12),
        Text = "",
        AutoButtonColor = false
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = MaximizeBtn })

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = Main,
        BackgroundColor3 = CurrentTheme.SidebarBg,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 200, 1, -40),
        BorderSizePixel = 0
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = Sidebar })
    Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = CurrentTheme.SidebarBg,
        Position = UDim2.new(1, -10, 0, 0),
        Size = UDim2.new(0, 10, 1, 0),
        BorderSizePixel = 0
    })
    Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = CurrentTheme.SidebarBg,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 10),
        BorderSizePixel = 0
    })

    local Title = Create("TextLabel", {
        Name = "Title",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(1, -30, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = TitleText,
        TextColor3 = CurrentTheme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local SubTitle = Create("TextLabel", {
        Name = "SubTitle",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 35),
        Size = UDim2.new(1, -30, 0, 14),
        Font = Enum.Font.Gotham,
        Text = SubTitleText,
        TextColor3 = CurrentTheme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local SidebarDivider = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = CurrentTheme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 15, 0, 65),
        Size = UDim2.new(1, -30, 0, 1)
    })

    local TabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 75),
        Size = UDim2.new(1, -20, 1, -145),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CurrentTheme.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    local TabListLayout = Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })
    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
    end)

    local ProfileCard = Create("Frame", {
        Name = "ProfileCard",
        Parent = Sidebar,
        BackgroundColor3 = CurrentTheme.MainBg,
        Position = UDim2.new(0, 10, 1, -60),
        Size = UDim2.new(1, -20, 0, 50)
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = ProfileCard })
    
    local Avatar = Create("ImageLabel", {
        Parent = ProfileCard,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0.5, -17),
        Size = UDim2.new(0, 34, 0, 34),
        Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Avatar })
    
    task.spawn(function()
        pcall(function()
            if LocalPlayer then
                Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            end
        end)
    end)

    local DisplayName = Create("TextLabel", {
        Parent = ProfileCard,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 10),
        Size = UDim2.new(1, -60, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = LocalPlayer and LocalPlayer.DisplayName or "User",
        TextColor3 = CurrentTheme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local Username = Create("TextLabel", {
        Parent = ProfileCard,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 26),
        Size = UDim2.new(1, -60, 0, 14),
        Font = Enum.Font.Gotham,
        Text = LocalPlayer and ("@" .. LocalPlayer.Name) or "@user",
        TextColor3 = CurrentTheme.SubText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local Workarea = Create("Frame", {
        Name = "Workarea",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 200, 0, 40),
        Size = UDim2.new(1, -200, 1, -40),
        ClipsDescendants = true
    })
    
    local ResizeGrip = Create("TextButton", {
        Name = "ResizeGrip",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -15, 1, -15),
        Size = UDim2.new(0, 15, 0, 15),
        Text = "",
        ZIndex = 100
    })
    Create("Frame", { Parent = ResizeGrip, BackgroundColor3 = CurrentTheme.Border, Position = UDim2.new(0.6, 0, 0.6, 0), Size = UDim2.new(0, 2, 0, 2), BorderSizePixel = 0})
    Create("Frame", { Parent = ResizeGrip, BackgroundColor3 = CurrentTheme.Border, Position = UDim2.new(0.3, 0, 0.6, 0), Size = UDim2.new(0, 2, 0, 2), BorderSizePixel = 0})
    Create("Frame", { Parent = ResizeGrip, BackgroundColor3 = CurrentTheme.Border, Position = UDim2.new(0.6, 0, 0.3, 0), Size = UDim2.new(0, 2, 0, 2), BorderSizePixel = 0})
    
    local resizing = false
    local rsStart, rsStartSize
    ResizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            rsStart = input.Position
            rsStartSize = Main.Size
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if resizing then
                local delta = input.Position - rsStart
                local newX = math.clamp(rsStartSize.X.Offset + delta.X, minSize.X.Offset, maxSize.X.Offset)
                local newY = math.clamp(rsStartSize.Y.Offset + delta.Y, minSize.Y.Offset, maxSize.Y.Offset)
                Main.Size = UDim2.new(0, newX, 0, newY)
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end)

    local Window = {}
    local Tabs = {}
    local ActiveTab = nil

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    local windowVisible = true
    function Window:ToggleVisible()
        windowVisible = not windowVisible
        if windowVisible then
            Main.Visible = true
            Tween(Main, 0.3, {Size = defaultSize})
        else
            Tween(Main, 0.3, {Size = UDim2.new(0, 0, 0, 0)})
            task.wait(0.3)
            Main.Visible = false
        end
    end
    MinimizeBtn.MouseButton1Click:Connect(function() Window:ToggleVisible() end)
    
    function Window:GreenButton(cb)
        MaximizeBtn.MouseButton1Click:Connect(cb)
    end
    
    function Window:AddMinimizeButton(config)
        config = config or {}
        local btnConfig = config.Button or {}
        local cornConfig = config.Corner or {}
        
        local minBtn = Create("ImageButton", {
            Parent = ScreenGui,
            Position = UDim2.new(0.5, -25, 0, 20),
            Size = UDim2.new(0, 50, 0, 50),
            Image = btnConfig.Image or "rbxassetid://12621719043",
            BackgroundTransparency = btnConfig.BackgroundTransparency or 0,
            BackgroundColor3 = CurrentTheme.SectionBg,
            ZIndex = 100
        })
        if cornConfig.CornerRadius then
            Create("UICorner", {
                Parent = minBtn,
                CornerRadius = cornConfig.CornerRadius
            })
        else
            Create("UICorner", {
                Parent = minBtn,
                CornerRadius = UDim.new(0.5, 0)
            })
        end
        
        local dragging, dragStart, startPos
        minBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = minBtn.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    local delta = input.Position - dragStart
                    minBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        minBtn.MouseButton1Click:Connect(function()
            Window:ToggleVisible()
        end)
    end

    function Window:SetTheme(themeName)
        if Themes[themeName] then
            CurrentTheme = Themes[themeName]
            -- Basic live update for backgrounds (Main, Sidebar, TopBar)
            Tween(Main, 0.3, {BackgroundColor3 = CurrentTheme.MainBg})
            Tween(Sidebar, 0.3, {BackgroundColor3 = CurrentTheme.SidebarBg})
            Tween(TopBar, 0.3, {BackgroundColor3 = CurrentTheme.TopBar})
            for _, child in ipairs(Sidebar:GetChildren()) do
                if child.BackgroundColor3 == Themes["macOS Dark"].SidebarBg then
                    Tween(child, 0.3, {BackgroundColor3 = CurrentTheme.SidebarBg})
                end
            end
        end
    end
    
    function Window:MakeSettingsTab()
        local settingsTab = self:MakeTab({"Settings", "rbxassetid://12030232490"})
        local sec = settingsTab:AddSection({"Theme Settings"})
        local themeOptions = {}
        for k, _ in pairs(Themes) do
            table.insert(themeOptions, k)
        end
        sec:AddDropdown({
            Name = "Select Theme",
            Options = themeOptions,
            Default = "macOS Dark",
            Callback = function(val)
                self:SetTheme(val)
            end
        })
        return settingsTab
    end

    function Window:MakeTab(tabConfig)
        local tabName = ""
        local tabIcon = ""
        if type(tabConfig) == "table" then
            tabName = tabConfig.Name or tabConfig[1] or "Tab"
            tabIcon = tabConfig.Icon or tabConfig[2] or ""
        else
            tabName = tostring(tabConfig)
        end
        
        local TabBtn = Create("TextButton", {
            Name = tabName,
            Parent = TabContainer,
            BackgroundColor3 = CurrentTheme.HoverBg,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Text = "",
            AutoButtonColor = false
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TabBtn })
        
        local TabText = Create("TextLabel", {
            Parent = TabBtn,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -24, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextColor3 = CurrentTheme.SubText,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local Page = Create("ScrollingFrame", {
            Name = tabName.."_Page",
            Parent = Workarea,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 15),
            Size = UDim2.new(1, -30, 1, -30),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = CurrentTheme.Border,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BorderSizePixel = 0,
            Visible = false
        })
        local PageLayout = Create("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        local TabObj = {}
        
        TabBtn.MouseButton1Click:Connect(function()
            Window:SelectTab(TabObj)
        end)
        
        TabObj.Button = TabBtn
        TabObj.Text = TabText
        TabObj.Page = Page
        TabObj.Name = tabName
        
        table.insert(Tabs, TabObj)
        if #Tabs == 1 then
            Window:SelectTab(TabObj)
        end
        
        function TabObj:AddSection(secConfig)
            local secName = ""
            if type(secConfig) == "table" then
                secName = secConfig.Name or secConfig[1] or "Section"
            else
                secName = tostring(secConfig)
            end
            
            local SectionContainer = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = CurrentTheme.SectionBg,
                Size = UDim2.new(1, -5, 0, 40)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = SectionContainer })
            
            local SecTitle = Create("TextLabel", {
                Parent = SectionContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 10),
                Size = UDim2.new(1, -30, 0, 20),
                Font = Enum.Font.GothamMedium,
                Text = secName,
                TextColor3 = CurrentTheme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local SecContent = Create("Frame", {
                Parent = SectionContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 35),
                Size = UDim2.new(1, -20, 1, -45)
            })
            local SecLayout = Create("UIListLayout", {
                Parent = SecContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6)
            })
            SecLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionContainer.Size = UDim2.new(1, -5, 0, SecLayout.AbsoluteContentSize.Y + 45)
            end)
            
            local SectionObj = {}
            SectionObj.Container = SecContent
            
            function SectionObj:AddButton(cfg, cbArg)
                local name = type(cfg) == "table" and (cfg.Name or cfg[1]) or tostring(cfg)
                local cb = type(cfg) == "table" and cfg.Callback or cbArg or function() end
                if type(cfg) == "table" and type(cfg[2]) == "function" then cb = cfg[2] end
                
                local btn = Create("TextButton", {
                    Parent = SecContent,
                    BackgroundColor3 = CurrentTheme.ElementBg,
                    Size = UDim2.new(1, 0, 0, 36),
                    Text = "",
                    AutoButtonColor = false
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
                
                Create("TextLabel", {
                    Parent = btn,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(1, -30, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Center
                })
                
                btn.MouseButton1Click:Connect(function()
                    Tween(btn, 0.1, {BackgroundColor3 = CurrentTheme.HoverBg})
                    task.wait(0.1)
                    Tween(btn, 0.1, {BackgroundColor3 = CurrentTheme.ElementBg})
                    cb()
                end)
                return btn
            end
            
            function SectionObj:AddToggle(cfg, defArg, cbArg)
                local name = type(cfg) == "table" and (cfg.Name or cfg[1]) or tostring(cfg)
                local def = type(cfg) == "table" and cfg.Default or type(defArg)=="boolean" and defArg or false
                if type(cfg) == "table" and type(cfg[2]) == "boolean" then def = cfg[2] end
                local cb = type(cfg) == "table" and cfg.Callback or cbArg or function() end
                if type(cfg) == "table" and type(cfg[3]) == "function" then cb = cfg[3] end
                if type(cfg) == "table" and type(cfg[2]) == "function" then cb = cfg[2] end
                
                local toggleState = def
                
                local toggleFrame = Create("TextButton", {
                    Parent = SecContent,
                    BackgroundColor3 = CurrentTheme.ElementBg,
                    Size = UDim2.new(1, 0, 0, 36),
                    Text = "",
                    AutoButtonColor = false
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = toggleFrame })
                
                Create("TextLabel", {
                    Parent = toggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(1, -80, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Track = Create("Frame", {
                    Parent = toggleFrame,
                    BackgroundColor3 = toggleState and CurrentTheme.ToggleOn or CurrentTheme.ToggleOff,
                    Position = UDim2.new(1, -45, 0.5, -10),
                    Size = UDim2.new(0, 34, 0, 20)
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })
                
                local Knob = Create("Frame", {
                    Parent = Track,
                    BackgroundColor3 = toggleState and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(255, 255, 255),
                    Position = toggleState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })
                
                local function fire()
                    toggleState = not toggleState
                    if toggleState then
                        Tween(Track, 0.2, {BackgroundColor3 = CurrentTheme.ToggleOn})
                        Tween(Knob, 0.2, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.fromRGB(30,30,30)})
                    else
                        Tween(Track, 0.2, {BackgroundColor3 = CurrentTheme.ToggleOff})
                        Tween(Knob, 0.2, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255,255,255)})
                    end
                    cb(toggleState)
                end
                toggleFrame.MouseButton1Click:Connect(fire)
                
                local toggObj = {}
                function toggObj:Callback(newCb)
                    cb = newCb
                end
                return toggObj
            end
            
            function SectionObj:AddSlider(cfg)
                local name = type(cfg) == "table" and cfg.Name or "Slider"
                local min = type(cfg) == "table" and cfg.Min or 0
                local max = type(cfg) == "table" and cfg.Max or 100
                local inc = type(cfg) == "table" and cfg.Increase or 1
                local def = type(cfg) == "table" and cfg.Default or min
                local cb = type(cfg) == "table" and cfg.Callback or function() end
                
                local sliderFrame = Create("Frame", {
                    Parent = SecContent,
                    BackgroundColor3 = CurrentTheme.ElementBg,
                    Size = UDim2.new(1, 0, 0, 50)
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = sliderFrame })
                
                Create("TextLabel", {
                    Parent = sliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 5),
                    Size = UDim2.new(1, -80, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueBox = Create("TextBox", {
                    Parent = sliderFrame,
                    BackgroundColor3 = CurrentTheme.HoverBg,
                    Position = UDim2.new(1, -55, 0, 5),
                    Size = UDim2.new(0, 40, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = tostring(def),
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 12
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = ValueBox })
                
                local Track = Create("TextButton", {
                    Parent = sliderFrame,
                    BackgroundColor3 = CurrentTheme.ToggleOff,
                    Position = UDim2.new(0, 15, 0, 35),
                    Size = UDim2.new(1, -30, 0, 4),
                    Text = "",
                    AutoButtonColor = false
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })
                
                local Fill = Create("Frame", {
                    Parent = Track,
                    BackgroundColor3 = CurrentTheme.Accent,
                    Size = UDim2.new(math.clamp((def - min) / (max - min), 0, 1), 0, 1, 0)
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })
                
                local Knob = Create("Frame", {
                    Parent = Fill,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(1, -6, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12)
                })
                Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })
                
                local sliding = false
                local function updateSlider(input)
                    local relative = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local val = min + (relative * (max - min))
                    val = math.floor(val / inc + 0.5) * inc
                    relative = (val - min) / (max - min)
                    
                    Tween(Fill, 0.1, {Size = UDim2.new(relative, 0, 1, 0)})
                    ValueBox.Text = tostring(val)
                    cb(val)
                end
                
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        updateSlider(input)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and sliding then
                        updateSlider(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)
                
                ValueBox.FocusLost:Connect(function()
                    local n = tonumber(ValueBox.Text)
                    if n then
                        n = math.clamp(math.floor(n / inc + 0.5) * inc, min, max)
                        ValueBox.Text = tostring(n)
                        Tween(Fill, 0.1, {Size = UDim2.new((n - min) / (max - min), 0, 1, 0)})
                        cb(n)
                    else
                        ValueBox.Text = tostring(min)
                    end
                end)
            end
            
            function SectionObj:AddDropdown(cfg)
                local name = cfg.Name or "Dropdown"
                local options = cfg.Options or {}
                local def = cfg.Default or ""
                local cb = cfg.Callback or function() end
                
                local dropFrame = Create("Frame", {
                    Parent = SecContent,
                    BackgroundColor3 = CurrentTheme.ElementBg,
                    Size = UDim2.new(1, 0, 0, 36),
                    ClipsDescendants = true
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = dropFrame })
                
                local dropBtn = Create("TextButton", {
                    Parent = dropFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36),
                    Text = "",
                    AutoButtonColor = false
                })
                
                Create("TextLabel", {
                    Parent = dropBtn,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local SelectedText = Create("TextLabel", {
                    Parent = dropBtn,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, -30, 0, 0),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = def,
                    TextColor3 = CurrentTheme.SubText,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local Icon = Create("ImageLabel", {
                    Parent = dropBtn,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    Image = "rbxassetid://6031090990",
                    ImageColor3 = CurrentTheme.SubText
                })
                
                local DropContainer = Create("Frame", {
                    Parent = dropFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 40),
                    Size = UDim2.new(1, -20, 0, 0)
                })
                local DropLayout = Create("UIListLayout", {
                    Parent = DropContainer,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4)
                })
                
                local open = false
                local function refreshSize()
                    if open then
                        Tween(dropFrame, 0.2, {Size = UDim2.new(1, 0, 0, 45 + DropLayout.AbsoluteContentSize.Y)})
                        Tween(Icon, 0.2, {Rotation = 180})
                    else
                        Tween(dropFrame, 0.2, {Size = UDim2.new(1, 0, 0, 36)})
                        Tween(Icon, 0.2, {Rotation = 0})
                    end
                end
                
                dropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    refreshSize()
                end)
                
                for _, opt in ipairs(options) do
                    local optBtn = Create("TextButton", {
                        Parent = DropContainer,
                        BackgroundColor3 = CurrentTheme.HoverBg,
                        Size = UDim2.new(1, 0, 0, 28),
                        Font = Enum.Font.Gotham,
                        Text = opt,
                        TextColor3 = CurrentTheme.Text,
                        TextSize = 12,
                        AutoButtonColor = false
                    })
                    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = optBtn })
                    optBtn.MouseButton1Click:Connect(function()
                        SelectedText.Text = opt
                        open = false
                        refreshSize()
                        cb(opt)
                    end)
                end
                DropLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if open then refreshSize() end
                end)
            end
            
            function SectionObj:AddTextBox(cfg, phArg, cbArg)
                local name = type(cfg) == "table" and (cfg.Name or cfg[1]) or tostring(cfg)
                local ph = type(cfg) == "table" and (cfg.PlaceholderText or cfg[2]) or type(phArg)=="string" and phArg or "Type..."
                local cb = type(cfg) == "table" and cfg.Callback or cbArg or function() end
                if type(cfg) == "table" and type(cfg[3]) == "function" then cb = cfg[3] end
                if type(cfg) == "table" and type(cfg[2]) == "function" then cb = cfg[2] end
                
                local tbFrame = Create("Frame", {
                    Parent = SecContent,
                    BackgroundColor3 = CurrentTheme.ElementBg,
                    Size = UDim2.new(1, 0, 0, 36)
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = tbFrame })
                
                Create("TextLabel", {
                    Parent = tbFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Box = Create("TextBox", {
                    Parent = tbFrame,
                    BackgroundColor3 = CurrentTheme.HoverBg,
                    Position = UDim2.new(0.5, 0, 0.5, -12),
                    Size = UDim2.new(0.5, -15, 0, 24),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = ph,
                    Text = "",
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 12,
                    PlaceholderColor3 = CurrentTheme.SubText
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Box })
                
                Box.FocusLost:Connect(function()
                    cb(Box.Text)
                end)
            end
            
            function SectionObj:AddParagraph(cfg, textArg)
                local name = type(cfg) == "table" and (cfg.Name or cfg[1]) or tostring(cfg)
                local text = type(cfg) == "table" and (cfg.Text or cfg[2]) or type(textArg)=="string" and textArg or ""
                
                local paraFrame = Create("Frame", {
                    Parent = SecContent,
                    BackgroundColor3 = CurrentTheme.ElementBg,
                    Size = UDim2.new(1, 0, 0, 0)
                })
                Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = paraFrame })
                
                local tLabel = Create("TextLabel", {
                    Parent = paraFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 10),
                    Size = UDim2.new(1, -30, 0, 0),
                    Font = Enum.Font.Gotham,
                    Text = name .. (text ~= "" and ("\n" .. text) or ""),
                    TextColor3 = CurrentTheme.SubText,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    AutomaticSize = Enum.AutomaticSize.Y
                })
                tLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    paraFrame.Size = UDim2.new(1, 0, 0, tLabel.AbsoluteSize.Y + 20)
                end)
            end
            
            return SectionObj
        end
        
        function TabObj:AddButton(...) local s = self.DefaultSection or self:AddSection("Elements") self.DefaultSection = s return s:AddButton(...) end
        function TabObj:AddToggle(...) local s = self.DefaultSection or self:AddSection("Elements") self.DefaultSection = s return s:AddToggle(...) end
        function TabObj:AddSlider(...) local s = self.DefaultSection or self:AddSection("Elements") self.DefaultSection = s return s:AddSlider(...) end
        function TabObj:AddDropdown(...) local s = self.DefaultSection or self:AddSection("Elements") self.DefaultSection = s return s:AddDropdown(...) end
        function TabObj:AddTextBox(...) local s = self.DefaultSection or self:AddSection("Elements") self.DefaultSection = s return s:AddTextBox(...) end
        function TabObj:AddParagraph(...) local s = self.DefaultSection or self:AddSection("Elements") self.DefaultSection = s return s:AddParagraph(...) end
        
        function TabObj:AddDiscordInvite(cfg)
            local s = self.DefaultSection or self:AddSection("Discord")
            self.DefaultSection = s
            local name = cfg.Name or "Join Discord"
            local desc = cfg.Description or "Join our community"
            local logo = cfg.Logo or "rbxassetid://18751483361"
            local link = cfg.Invite or ""
            
            local dFrame = Create("Frame", {
                Parent = s.Container,
                BackgroundColor3 = Color3.fromRGB(88, 101, 242),
                Size = UDim2.new(1, 0, 0, 70)
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = dFrame })
            
            Create("ImageLabel", {
                Parent = dFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0.5, -20),
                Size = UDim2.new(0, 40, 0, 40),
                Image = logo
            })
            
            Create("TextLabel", {
                Parent = dFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 65, 0, 15),
                Size = UDim2.new(1, -140, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            Create("TextLabel", {
                Parent = dFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 65, 0, 35),
                Size = UDim2.new(1, -140, 0, 15),
                Font = Enum.Font.Gotham,
                Text = desc,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local joinBtn = Create("TextButton", {
                Parent = dFrame,
                BackgroundColor3 = Color3.fromRGB(59, 165, 93),
                Position = UDim2.new(1, -75, 0.5, -15),
                Size = UDim2.new(0, 60, 0, 30),
                Font = Enum.Font.GothamBold,
                Text = "Join",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 13,
                AutoButtonColor = false
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = joinBtn })
            joinBtn.MouseButton1Click:Connect(function()
                if setclipboard then setclipboard(link) end
            end)
        end
        
        return TabObj
    end
    
    function Window:SelectTab(tabObj)
        if ActiveTab then
            Tween(ActiveTab.Button, 0.2, {BackgroundTransparency = 1})
            Tween(ActiveTab.Text, 0.2, {TextColor3 = CurrentTheme.SubText})
            ActiveTab.Page.Visible = false
        end
        ActiveTab = tabObj
        Tween(ActiveTab.Button, 0.2, {BackgroundTransparency = 0.8})
        Tween(ActiveTab.Text, 0.2, {TextColor3 = CurrentTheme.Text})
        ActiveTab.Page.Visible = true
    end
    
    function Window:Notify(txt1, txt2, b1, icon, cb)
        local notif = Create("Frame", {
            Parent = ScreenGui,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 300, 0, 200),
            BackgroundColor3 = CurrentTheme.SectionBg,
            ZIndex = 50
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = notif })
        
        Create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 20),
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamBold,
            Text = txt1,
            TextColor3 = CurrentTheme.Text,
            TextSize = 18
        })
        Create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 60),
            Size = UDim2.new(1, -40, 0, 60),
            Font = Enum.Font.Gotham,
            Text = txt2,
            TextColor3 = CurrentTheme.SubText,
            TextSize = 13,
            TextWrapped = true
        })
        
        local btn = Create("TextButton", {
            Parent = notif,
            BackgroundColor3 = CurrentTheme.Accent,
            Position = UDim2.new(0, 40, 1, -50),
            Size = UDim2.new(1, -80, 0, 35),
            Font = Enum.Font.GothamMedium,
            Text = b1 or "OK",
            TextColor3 = Color3.fromRGB(0,0,0),
            TextSize = 14
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
        
        btn.MouseButton1Click:Connect(function()
            notif:Destroy()
            if cb then cb() end
        end)
    end
    
    function Window:Notify2(txt1, txt2, b1, b2, icon, cb1, cb2)
        local notif = Create("Frame", {
            Parent = ScreenGui,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 300, 0, 200),
            BackgroundColor3 = CurrentTheme.SectionBg,
            ZIndex = 50
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = notif })
        
        Create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 20),
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamBold,
            Text = txt1,
            TextColor3 = CurrentTheme.Text,
            TextSize = 18
        })
        Create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 60),
            Size = UDim2.new(1, -40, 0, 60),
            Font = Enum.Font.Gotham,
            Text = txt2,
            TextColor3 = CurrentTheme.SubText,
            TextSize = 13,
            TextWrapped = true
        })
        
        local btn1 = Create("TextButton", {
            Parent = notif,
            BackgroundColor3 = CurrentTheme.Accent,
            Position = UDim2.new(0, 20, 1, -50),
            Size = UDim2.new(0.5, -25, 0, 35),
            Font = Enum.Font.GothamMedium,
            Text = b1 or "Yes",
            TextColor3 = Color3.fromRGB(0,0,0),
            TextSize = 14
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn1 })
        
        local btn2 = Create("TextButton", {
            Parent = notif,
            BackgroundColor3 = CurrentTheme.ElementBg,
            Position = UDim2.new(0.5, 5, 1, -50),
            Size = UDim2.new(0.5, -25, 0, 35),
            Font = Enum.Font.GothamMedium,
            Text = b2 or "No",
            TextColor3 = CurrentTheme.Text,
            TextSize = 14
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn2 })
        
        btn1.MouseButton1Click:Connect(function() notif:Destroy() if cb1 then cb1() end end)
        btn2.MouseButton1Click:Connect(function() notif:Destroy() if cb2 then cb2() end end)
    end
    
    function Window:TempNotify(txt1, txt2, icon)
        local tnotif = Create("Frame", {
            Parent = ScreenGui,
            BackgroundColor3 = CurrentTheme.SectionBg,
            Position = UDim2.new(1, 20, 1, -100),
            Size = UDim2.new(0, 250, 0, 80),
            ZIndex = 50
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = tnotif })
        
        Create("TextLabel", {
            Parent = tnotif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 10),
            Size = UDim2.new(1, -30, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = txt1,
            TextColor3 = CurrentTheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        Create("TextLabel", {
            Parent = tnotif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 35),
            Size = UDim2.new(1, -30, 0, 30),
            Font = Enum.Font.Gotham,
            Text = txt2,
            TextColor3 = CurrentTheme.SubText,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })
        
        Tween(tnotif, 0.4, {Position = UDim2.new(1, -270, 1, -100)})
        task.delay(4, function()
            Tween(tnotif, 0.4, {Position = UDim2.new(1, 20, 1, -100)})
            task.wait(0.4)
            tnotif:Destroy()
        end)
    end
    
    function Window:Dialog(cfg)
        local notif = Create("Frame", {
            Parent = ScreenGui,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 300, 0, 130 + (#cfg.Options * 45)),
            BackgroundColor3 = CurrentTheme.SectionBg,
            ZIndex = 50
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = notif })
        
        Create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 20),
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.GothamBold,
            Text = cfg.Title or "Dialog",
            TextColor3 = CurrentTheme.Text,
            TextSize = 18
        })
        Create("TextLabel", {
            Parent = notif,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 20, 0, 60),
            Size = UDim2.new(1, -40, 0, 60),
            Font = Enum.Font.Gotham,
            Text = cfg.Text or "",
            TextColor3 = CurrentTheme.SubText,
            TextSize = 13,
            TextWrapped = true
        })
        
        local yOffset = 130
        for i, opt in ipairs(cfg.Options) do
            local btn = Create("TextButton", {
                Parent = notif,
                BackgroundColor3 = i == 1 and CurrentTheme.Accent or CurrentTheme.ElementBg,
                Position = UDim2.new(0, 20, 0, yOffset),
                Size = UDim2.new(1, -40, 0, 35),
                Font = Enum.Font.GothamMedium,
                Text = opt[1],
                TextColor3 = i == 1 and Color3.fromRGB(0,0,0) or CurrentTheme.Text,
                TextSize = 14
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
            btn.MouseButton1Click:Connect(function()
                notif:Destroy()
                if opt[2] then opt[2]() end
            end)
            yOffset = yOffset + 45
        end
    end

    return Window
end



return Library
