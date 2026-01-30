local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configurações
local Settings = {
    Aimbot = {
        Enabled = false,
        Mode = "Mouse",
        ShowFOV = false,
        FOVSize = 150,
        TargetPart = "Head",
        Smoothness = 0.14,
        IgnoreTeam = false,
        VisibilityCheck = true
    },
    ESP = {
        Enabled = false,
        TeamCheck = true
    },
    Hitbox = {
        Enabled = false,
        TargetPart = "Head",
        Size = 5,
        Transparency = 0.5,
        IgnoreTeam = false,
        VisibilityCheck = true
    },
    UI = {
        Keybind = Enum.KeyCode.K,
        MenuOpen = true,
        Font = "Gotham"
    }
}

local FOVCircle
local CurrentTarget = nil
local AimbotConnection = nil
local ESPObjects = {}
local HitboxConnections = {}
local OriginalSizes = {}

local EnableESP
local DisableESP
local ToggleAimbot
local ToggleHitbox

-- Cores do tema militar/tático
local Colors = {
    Background = Color3.fromRGB(20, 25, 30),
    Secondary = Color3.fromRGB(30, 35, 40),
    Accent = Color3.fromRGB(76, 175, 80), -- Verde militar
    AccentDark = Color3.fromRGB(56, 142, 60),
    Text = Color3.fromRGB(230, 230, 230),
    TextDim = Color3.fromRGB(160, 160, 160),
    Border = Color3.fromRGB(45, 50, 55),
    Success = Color3.fromRGB(76, 175, 80),
    Warning = Color3.fromRGB(255, 152, 0),
    Danger = Color3.fromRGB(244, 67, 54)
}

-- Função para criar a interface
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NatalHubV2"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Container Principal
    local MainContainer = Instance.new("Frame")
    MainContainer.Name = "MainContainer"
    MainContainer.Parent = ScreenGui
    MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    MainContainer.BackgroundColor3 = Colors.Background
    MainContainer.BorderSizePixel = 0
    MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainContainer.Size = UDim2.new(0, 700, 0, 500)
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 4)
    MainCorner.Parent = MainContainer
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Colors.Border
    MainStroke.Thickness = 1
    MainStroke.Parent = MainContainer
    
    -- Barra superior (Header)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = MainContainer
    Header.BackgroundColor3 = Colors.Secondary
    Header.BorderSizePixel = 0
    Header.Size = UDim2.new(1, 0, 0, 45)
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 4)
    HeaderCorner.Parent = Header
    
    -- Fix para arredondar apenas o topo
    local HeaderFix = Instance.new("Frame")
    HeaderFix.Parent = Header
    HeaderFix.BackgroundColor3 = Colors.Secondary
    HeaderFix.BorderSizePixel = 0
    HeaderFix.Position = UDim2.new(0, 0, 1, -4)
    HeaderFix.Size = UDim2.new(1, 0, 0, 4)
    
    -- Sistema de Drag
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        MainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainContainer.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    -- Título
    local Title = Instance.new("TextLabel")
    Title.Parent = Header
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "NATAL HUB"
    Title.TextColor3 = Colors.Accent
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Subtítulo
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Parent = Header
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0, 125, 0, 0)
    Subtitle.Size = UDim2.new(0.3, 0, 1, 0)
    Title.Font = Enum.Font.Gotham
    Subtitle.Text = "EXÉRCITO BRASILEIRO"
    Subtitle.TextColor3 = Colors.TextDim
    Subtitle.TextSize = 11
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Status indicator
    local StatusDot = Instance.new("Frame")
    StatusDot.Parent = Header
    StatusDot.BackgroundColor3 = Colors.Success
    StatusDot.BorderSizePixel = 0
    StatusDot.Position = UDim2.new(1, -100, 0.5, -4)
    StatusDot.Size = UDim2.new(0, 8, 0, 8)
    
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = StatusDot
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = Header
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(1, -85, 0, 0)
    StatusLabel.Size = UDim2.new(0, 50, 1, 0)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "ATIVO"
    StatusLabel.TextColor3 = Colors.Success
    StatusLabel.TextSize = 11
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Botão fechar
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Header
    CloseBtn.BackgroundColor3 = Colors.Danger
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(1, -30, 0.5, -10)
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 16
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 3)
    CloseCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        MainContainer.Visible = false
        Settings.UI.MenuOpen = false
    end)
    
    -- Navbar lateral
    local Navbar = Instance.new("Frame")
    Navbar.Parent = MainContainer
    Navbar.BackgroundColor3 = Colors.Secondary
    Navbar.BorderSizePixel = 0
    Navbar.Position = UDim2.new(0, 0, 0, 45)
    Navbar.Size = UDim2.new(0, 140, 1, -45)
    
    local NavStroke = Instance.new("UIStroke")
    NavStroke.Color = Colors.Border
    NavStroke.Thickness = 1
    NavStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    NavStroke.Parent = Navbar
    
    -- Container de conteúdo
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Parent = MainContainer
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 140, 0, 45)
    ContentFrame.Size = UDim2.new(1, -140, 1, -45)
    
    local currentPage = nil
    local pages = {}
    
    -- Função para criar botão de navegação
    local function CreateNavButton(name, icon, order)
        local NavBtn = Instance.new("TextButton")
        NavBtn.Parent = Navbar
        NavBtn.BackgroundColor3 = Colors.Background
        NavBtn.BorderSizePixel = 0
        NavBtn.Position = UDim2.new(0, 8, 0, 10 + (order * 48))
        NavBtn.Size = UDim2.new(1, -16, 0, 40)
        NavBtn.Font = Enum.Font.GothamBold
        NavBtn.Text = ""
        NavBtn.AutoButtonColor = false
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 3)
        BtnCorner.Parent = NavBtn
        
        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = Colors.Border
        BtnStroke.Thickness = 1
        BtnStroke.Transparency = 0.5
        BtnStroke.Parent = NavBtn
        
        local IconLabel = Instance.new("TextLabel")
        IconLabel.Parent = NavBtn
        IconLabel.BackgroundTransparency = 1
        IconLabel.Position = UDim2.new(0, 10, 0, 0)
        IconLabel.Size = UDim2.new(0, 20, 1, 0)
        IconLabel.Font = Enum.Font.GothamBold
        IconLabel.Text = icon
        IconLabel.TextColor3 = Colors.TextDim
        IconLabel.TextSize = 14
        
        local TextLabel = Instance.new("TextLabel")
        TextLabel.Parent = NavBtn
        TextLabel.BackgroundTransparency = 1
        TextLabel.Position = UDim2.new(0, 35, 0, 0)
        TextLabel.Size = UDim2.new(1, -40, 1, 0)
        TextLabel.Font = Enum.Font.Gotham
        TextLabel.Text = name
        TextLabel.TextColor3 = Colors.TextDim
        TextLabel.TextSize = 12
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Criar página
        local Page = Instance.new("ScrollingFrame")
        Page.Parent = ContentFrame
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Colors.Accent
        Page.Visible = false
        
        pages[name] = Page
        
        local function ActivatePage()
            for _, btn in ipairs(Navbar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Colors.Background
                    local stroke = btn:FindFirstChild("UIStroke")
                    if stroke then stroke.Transparency = 0.5 end
                    local icon = btn:FindFirstChildWhichIsA("TextLabel")
                    if icon then icon.TextColor3 = Colors.TextDim end
                    local text = btn:FindFirstChild("TextLabel", true)
                    if text and text ~= icon then text.TextColor3 = Colors.TextDim end
                end
            end
            
            for _, page in pairs(pages) do
                page.Visible = false
            end
            
            NavBtn.BackgroundColor3 = Colors.Accent
            BtnStroke.Transparency = 0
            BtnStroke.Color = Colors.Accent
            IconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            Page.Visible = true
            currentPage = name
        end
        
        NavBtn.MouseButton1Click:Connect(ActivatePage)
        
        return Page, ActivatePage
    end
    
    -- Criar páginas
    local HomePage, ActivateHome = CreateNavButton("HOME", "■", 0)
    local AimbotPage = CreateNavButton("AIMBOT", "◆", 1)
    local HitboxPage = CreateNavButton("HITBOX", "▲", 2)
    local ESPPage = CreateNavButton("VISUAL", "◇", 3)
    local ConfigPage = CreateNavButton("CONFIG", "▣", 4)
    
    ActivateHome()
    
    -- Funções auxiliares para criar elementos
    local function CreateCard(parent, yPos, height)
        local Card = Instance.new("Frame")
        Card.Parent = parent
        Card.BackgroundColor3 = Colors.Secondary
        Card.BorderSizePixel = 0
        Card.Position = UDim2.new(0, 15, 0, yPos)
        Card.Size = UDim2.new(1, -30, 0, height)
        
        local CardCorner = Instance.new("UICorner")
        CardCorner.CornerRadius = UDim.new(0, 4)
        CardCorner.Parent = Card
        
        local CardStroke = Instance.new("UIStroke")
        CardStroke.Color = Colors.Border
        CardStroke.Thickness = 1
        CardStroke.Parent = Card
        
        return Card
    end
    
    local function CreateSectionHeader(parent, title, yPos)
        local Header = Instance.new("Frame")
        Header.Parent = parent
        Header.BackgroundTransparency = 1
        Header.Position = UDim2.new(0, 12, 0, yPos)
        Header.Size = UDim2.new(1, -24, 0, 30)
        
        local Line = Instance.new("Frame")
        Line.Parent = Header
        Line.BackgroundColor3 = Colors.Accent
        Line.BorderSizePixel = 0
        Line.Position = UDim2.new(0, 0, 0, 0)
        Line.Size = UDim2.new(0, 3, 1, 0)
        
        local Title = Instance.new("TextLabel")
        Title.Parent = Header
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 12, 0, 0)
        Title.Size = UDim2.new(1, -12, 1, 0)
        Title.Font = Enum.Font.GothamBold
        Title.Text = title
        Title.TextColor3 = Colors.Text
        Title.TextSize = 13
        Title.TextXAlignment = Enum.TextXAlignment.Left
        
        return Header
    end
    
    local function CreateToggle(parent, name, description, default, yPos, callback)
        local Toggle = Instance.new("Frame")
        Toggle.Parent = parent
        Toggle.BackgroundTransparency = 1
        Toggle.Position = UDim2.new(0, 12, 0, yPos)
        Toggle.Size = UDim2.new(1, -24, 0, 50)
        
        local Label = Instance.new("TextLabel")
        Label.Parent = Toggle
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.7, 0, 0, 20)
        Label.Font = Enum.Font.GothamBold
        Label.Text = name
        Label.TextColor3 = Colors.Text
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local Desc = Instance.new("TextLabel")
        Desc.Parent = Toggle
        Desc.BackgroundTransparency = 1
        Desc.Position = UDim2.new(0, 0, 0, 20)
        Desc.Size = UDim2.new(0.7, 0, 0, 15)
        Desc.Font = Enum.Font.Gotham
        Desc.Text = description
        Desc.TextColor3 = Colors.TextDim
        Desc.TextSize = 10
        Desc.TextXAlignment = Enum.TextXAlignment.Left
        
        local Switch = Instance.new("Frame")
        Switch.Parent = Toggle
        Switch.BackgroundColor3 = default and Colors.Accent or Colors.Border
        Switch.BorderSizePixel = 0
        Switch.Position = UDim2.new(1, -50, 0, 5)
        Switch.Size = UDim2.new(0, 45, 0, 22)
        
        local SwitchCorner = Instance.new("UICorner")
        SwitchCorner.CornerRadius = UDim.new(1, 0)
        SwitchCorner.Parent = Switch
        
        local Knob = Instance.new("Frame")
        Knob.Parent = Switch
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.BorderSizePixel = 0
        Knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        Knob.Size = UDim2.new(0, 18, 0, 18)
        
        local KnobCorner = Instance.new("UICorner")
        KnobCorner.CornerRadius = UDim.new(1, 0)
        KnobCorner.Parent = Knob
        
        local enabled = default
        
        local ClickArea = Instance.new("TextButton")
        ClickArea.Parent = Switch
        ClickArea.BackgroundTransparency = 1
        ClickArea.Size = UDim2.new(1, 0, 1, 0)
        ClickArea.Text = ""
        
        ClickArea.MouseButton1Click:Connect(function()
            enabled = not enabled
            
            Switch.BackgroundColor3 = enabled and Colors.Accent or Colors.Border
            Knob:TweenPosition(
                enabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.2,
                true
            )
            
            if callback then callback(enabled) end
        end)
        
        return Toggle
    end
    
    local function CreateSlider(parent, name, min, max, default, yPos, callback)
        local Slider = Instance.new("Frame")
        Slider.Parent = parent
        Slider.BackgroundTransparency = 1
        Slider.Position = UDim2.new(0, 12, 0, yPos)
        Slider.Size = UDim2.new(1, -24, 0, 50)
        
        local Label = Instance.new("TextLabel")
        Label.Parent = Slider
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.5, 0, 0, 20)
        Label.Font = Enum.Font.GothamBold
        Label.Text = name
        Label.TextColor3 = Colors.Text
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local Value = Instance.new("TextLabel")
        Value.Parent = Slider
        Value.BackgroundTransparency = 1
        Value.Position = UDim2.new(0.5, 0, 0, 0)
        Value.Size = UDim2.new(0.5, 0, 0, 20)
        Value.Font = Enum.Font.GothamBold
        Value.Text = tostring(default)
        Value.TextColor3 = Colors.Accent
        Value.TextSize = 12
        Value.TextXAlignment = Enum.TextXAlignment.Right
        
        local Track = Instance.new("Frame")
        Track.Parent = Slider
        Track.BackgroundColor3 = Colors.Border
        Track.BorderSizePixel = 0
        Track.Position = UDim2.new(0, 0, 0, 28)
        Track.Size = UDim2.new(1, 0, 0, 4)
        
        local TrackCorner = Instance.new("UICorner")
        TrackCorner.CornerRadius = UDim.new(1, 0)
        TrackCorner.Parent = Track
        
        local Fill = Instance.new("Frame")
        Fill.Parent = Track
        Fill.BackgroundColor3 = Colors.Accent
        Fill.BorderSizePixel = 0
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = Fill
        
        local dragging = false
        local currentValue = default
        
        local function updateSlider(input)
            local mousePos = input.Position.X
            local trackPos = Track.AbsolutePosition.X
            local trackSize = Track.AbsoluteSize.X
            local percentage = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
            
            currentValue = math.floor(min + (max - min) * percentage)
            Fill.Size = UDim2.new(percentage, 0, 1, 0)
            Value.Text = tostring(currentValue)
            
            if callback then callback(currentValue) end
        end
        
        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        return Slider
    end
    
    local function CreateDropdown(parent, name, options, default, yPos, callback)
        local Dropdown = Instance.new("Frame")
        Dropdown.Parent = parent
        Dropdown.BackgroundTransparency = 1
        Dropdown.Position = UDim2.new(0, 12, 0, yPos)
        Dropdown.Size = UDim2.new(1, -24, 0, 35)
        Dropdown.ZIndex = 10
        
        local Label = Instance.new("TextLabel")
        Label.Parent = Dropdown
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(0.35, 0, 1, 0)
        Label.Font = Enum.Font.GothamBold
        Label.Text = name
        Label.TextColor3 = Colors.Text
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.ZIndex = 10
        
        local Button = Instance.new("TextButton")
        Button.Parent = Dropdown
        Button.BackgroundColor3 = Colors.Background
        Button.BorderSizePixel = 0
        Button.Position = UDim2.new(0.4, 0, 0, 2)
        Button.Size = UDim2.new(0.6, 0, 0, 30)
        Button.Font = Enum.Font.Gotham
        Button.Text = "  " .. default .. "  ▼"
        Button.TextColor3 = Colors.Text
        Button.TextSize = 11
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.ZIndex = 10
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 3)
        BtnCorner.Parent = Button
        
        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = Colors.Border
        BtnStroke.Thickness = 1
        BtnStroke.Parent = Button
        
        local ListContainer = Instance.new("Frame")
        ListContainer.Parent = Dropdown
        ListContainer.BackgroundTransparency = 1
        ListContainer.Position = UDim2.new(0.4, 0, 1, 2)
        ListContainer.Size = UDim2.new(0.6, 0, 0, 0)
        ListContainer.ZIndex = 100
        
        local List = Instance.new("ScrollingFrame")
        List.Parent = ListContainer
        List.BackgroundColor3 = Colors.Background
        List.BorderSizePixel = 0
        List.Size = UDim2.new(1, 0, 1, 0)
        List.Visible = false
        List.ZIndex = 100
        List.ScrollBarThickness = 2
        List.ScrollBarImageColor3 = Colors.Accent
        List.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
        
        local ListCorner = Instance.new("UICorner")
        ListCorner.CornerRadius = UDim.new(0, 3)
        ListCorner.Parent = List
        
        local ListStroke = Instance.new("UIStroke")
        ListStroke.Color = Colors.Border
        ListStroke.Thickness = 1
        ListStroke.Parent = List
        
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.Parent = List
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 2)
        
        for i, option in ipairs(options) do
            local Option = Instance.new("TextButton")
            Option.Parent = List
            Option.BackgroundColor3 = Colors.Background
            Option.BorderSizePixel = 0
            Option.Size = UDim2.new(1, -4, 0, 28)
            Option.Font = Enum.Font.Gotham
            Option.Text = option
            Option.TextColor3 = Colors.Text
            Option.TextSize = 11
            Option.ZIndex = 101
            
            local OptCorner = Instance.new("UICorner")
            OptCorner.CornerRadius = UDim.new(0, 2)
            OptCorner.Parent = Option
            
            Option.MouseButton1Click:Connect(function()
                Button.Text = "  " .. option .. "  ▼"
                List.Visible = false
                ListContainer.Size = UDim2.new(0.6, 0, 0, 0)
                if callback then callback(option) end
            end)
            
            Option.MouseEnter:Connect(function()
                Option.BackgroundColor3 = Colors.Accent
            end)
            
            Option.MouseLeave:Connect(function()
                Option.BackgroundColor3 = Colors.Background
            end)
        end
        
        Button.MouseButton1Click:Connect(function()
            List.Visible = not List.Visible
            local maxHeight = math.min(#options * 30, 120)
            if List.Visible then
                ListContainer:TweenSize(
                    UDim2.new(0.6, 0, 0, maxHeight),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2,
                    true
                )
            else
                ListContainer:TweenSize(
                    UDim2.new(0.6, 0, 0, 0),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2,
                    true
                )
            end
        end)
        
        return Dropdown
    end
    
    -- ========== HOME PAGE ==========
    local WelcomeCard = CreateCard(HomePage, 15, 120)
    
    local WelcomeTitle = Instance.new("TextLabel")
    WelcomeTitle.Parent = WelcomeCard
    WelcomeTitle.BackgroundTransparency = 1
    WelcomeTitle.Position = UDim2.new(0, 15, 0, 15)
    WelcomeTitle.Size = UDim2.new(1, -30, 0, 25)
    WelcomeTitle.Font = Enum.Font.GothamBold
    WelcomeTitle.Text = "BEM-VINDO AO NATAL HUB"
    WelcomeTitle.TextColor3 = Colors.Accent
    WelcomeTitle.TextSize = 14
    WelcomeTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local WelcomeText = Instance.new("TextLabel")
    WelcomeText.Parent = WelcomeCard
    WelcomeText.BackgroundTransparency = 1
    WelcomeText.Position = UDim2.new(0, 15, 0, 45)
    WelcomeText.Size = UDim2.new(1, -30, 1, -60)
    WelcomeText.Font = Enum.Font.Gotham
    WelcomeText.Text = "Sistema tático para Exército Brasileiro"
    WelcomeText.TextColor3 = Colors.TextDim
    WelcomeText.TextSize = 11
    WelcomeText.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeText.TextYAlignment = Enum.TextYAlignment.Top
    WelcomeText.TextWrapped = true
    
    local InfoCard = CreateCard(HomePage, 145, 100)
    
    CreateSectionHeader(InfoCard, "INFORMAÇÕES DO SISTEMA", 0)
    
    local InfoText = Instance.new("TextLabel")
    InfoText.Parent = InfoCard
    InfoText.BackgroundTransparency = 1
    InfoText.Position = UDim2.new(0, 15, 0, 35)
    InfoText.Size = UDim2.new(1, -30, 1, -40)
    InfoText.Font = Enum.Font.Gotham
    InfoText.Text = "Versão: 2.0\nStatus: Operacional"
    InfoText.TextColor3 = Colors.TextDim
    InfoText.TextSize = 11
    InfoText.TextXAlignment = Enum.TextXAlignment.Left
    InfoText.TextYAlignment = Enum.TextYAlignment.Top
    
    HomePage.CanvasSize = UDim2.new(0, 0, 0, 260)
    
    -- ========== AIMBOT PAGE ==========
    local AimbotCard1 = CreateCard(AimbotPage, 15, 280)
    
    CreateSectionHeader(AimbotCard1, "SILENT AIM", 0)
    
    CreateToggle(AimbotCard1, "Aimbot Ativado", "Ativa/desativa o sistema de mira", Settings.Aimbot.Enabled, 35, function(value)
        Settings.Aimbot.Enabled = value
        ToggleAimbot(value)
    end)
    
    CreateToggle(AimbotCard1, "Mostrar FOV", "Exibe círculo de alcance", Settings.Aimbot.ShowFOV, 90, function(value)
        Settings.Aimbot.ShowFOV = value
        if FOVCircle then FOVCircle.Visible = value end
    end)
    
    CreateToggle(AimbotCard1, "Ignorar Time", "Não mira em aliados", Settings.Aimbot.IgnoreTeam, 145, function(value)
        Settings.Aimbot.IgnoreTeam = value
    end)
    
    CreateToggle(AimbotCard1, "Check Visibilidade", "Mira apenas em alvos visíveis", Settings.Aimbot.VisibilityCheck, 200, function(value)
        Settings.Aimbot.VisibilityCheck = value
    end)
    
    local AimbotCard2 = CreateCard(AimbotPage, 305, 250)
    
    CreateSectionHeader(AimbotCard2, "CONFIGURAÇÕES", 0)
    
    CreateDropdown(AimbotCard2, "Modo", {"Mouse", "Camera"}, Settings.Aimbot.Mode, 35, function(value)
        Settings.Aimbot.Mode = value
    end)
    
    CreateDropdown(AimbotCard2, "Parte Alvo", {"Head", "Torso", "HumanoidRootPart"}, Settings.Aimbot.TargetPart, 80, function(value)
        Settings.Aimbot.TargetPart = value
    end)
    
    CreateSlider(AimbotCard2, "Suavidade", 1, 100, math.floor(Settings.Aimbot.Smoothness * 100), 125, function(value)
        Settings.Aimbot.Smoothness = value / 100
    end)
    
    CreateSlider(AimbotCard2, "Tamanho FOV", 50, 500, Settings.Aimbot.FOVSize, 185, function(value)
        Settings.Aimbot.FOVSize = value
        if FOVCircle then FOVCircle.Radius = value end
    end)
    
    AimbotPage.CanvasSize = UDim2.new(0, 0, 0, 570)
    
    -- ========== HITBOX PAGE ==========
    local HitboxCard1 = CreateCard(HitboxPage, 15, 220)
    
    CreateSectionHeader(HitboxCard1, "EXPANSOR DE HITBOX", 0)
    
    CreateToggle(HitboxCard1, "Hitbox Ativado", "Ativa/desativa expansão de hitbox", Settings.Hitbox.Enabled, 35, function(value)
        Settings.Hitbox.Enabled = value
        ToggleHitbox(value)
    end)
    
    CreateToggle(HitboxCard1, "Ignorar Time", "Não expande hitbox de aliados", Settings.Hitbox.IgnoreTeam, 90, function(value)
        Settings.Hitbox.IgnoreTeam = value
        -- Atualizar hitboxes se estiver ativado
        if Settings.Hitbox.Enabled then
            -- Restaurar todos e re-expandir com nova configuração
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    pcall(function()
                        RestoreHitbox(player)
                        wait(0.05)
                        ExpandHitbox(player)
                    end)
                end
            end
        end
    end)
    
    CreateToggle(HitboxCard1, "Check Visibilidade", "Expande apenas alvos visíveis", Settings.Hitbox.VisibilityCheck, 145, function(value)
        Settings.Hitbox.VisibilityCheck = value
    end)
    
    local HitboxCard2 = CreateCard(HitboxPage, 245, 210)
    
    CreateSectionHeader(HitboxCard2, "CONFIGURAÇÕES", 0)
    
    CreateDropdown(HitboxCard2, "Parte Alvo", {"Head", "HumanoidRootPart"}, Settings.Hitbox.TargetPart, 35, function(value)
        Settings.Hitbox.TargetPart = value
        -- Se hitbox estiver ativo, restaurar tudo e re-expandir com nova parte
        if Settings.Hitbox.Enabled then
            RestoreAllHitboxes()
            wait(0.1)
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    pcall(function()
                        ExpandHitbox(player)
                    end)
                end
            end
        end
    end)
    
    CreateSlider(HitboxCard2, "Tamanho", 1, 20, Settings.Hitbox.Size, 80, function(value)
        Settings.Hitbox.Size = value
    end)
    
    CreateSlider(HitboxCard2, "Transparência", 0, 100, math.floor(Settings.Hitbox.Transparency * 100), 140, function(value)
        Settings.Hitbox.Transparency = value / 100
    end)
    
    HitboxPage.CanvasSize = UDim2.new(0, 0, 0, 470)
    
    -- ========== ESP PAGE ==========
    local ESPCard = CreateCard(ESPPage, 15, 160)
    
    CreateSectionHeader(ESPCard, "SISTEMA VISUAL", 0)
    
    CreateToggle(ESPCard, "ESP Ativado", "Ativa/desativa ESP", Settings.ESP.Enabled, 35, function(value)
        Settings.ESP.Enabled = value
        if value then EnableESP() else DisableESP() end
    end)
    
    CreateToggle(ESPCard, "Check de Time", "Não exibe ESP em aliados", Settings.ESP.TeamCheck, 90, function(value)
        Settings.ESP.TeamCheck = value
        -- Recriar ESP para aplicar mudanças
        if Settings.ESP.Enabled then
            DisableESP()
            wait(0.1)
            EnableESP()
        end
    end)
    
    ESPPage.CanvasSize = UDim2.new(0, 0, 0, 190)
    
    -- ========== CONFIG PAGE ==========
    local ConfigCard = CreateCard(ConfigPage, 15, 100)
    
    CreateSectionHeader(ConfigCard, "MENU", 0)
    
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Parent = ConfigCard
    KeybindFrame.BackgroundTransparency = 1
    KeybindFrame.Position = UDim2.new(0, 12, 0, 35)
    KeybindFrame.Size = UDim2.new(1, -24, 0, 35)
    
    local KeyLabel = Instance.new("TextLabel")
    KeyLabel.Parent = KeybindFrame
    KeyLabel.BackgroundTransparency = 1
    KeyLabel.Size = UDim2.new(0.4, 0, 1, 0)
    KeyLabel.Font = Enum.Font.GothamBold
    KeyLabel.Text = "Tecla do Menu"
    KeyLabel.TextColor3 = Colors.Text
    KeyLabel.TextSize = 12
    KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local KeyButton = Instance.new("TextButton")
    KeyButton.Parent = KeybindFrame
    KeyButton.BackgroundColor3 = Colors.Background
    KeyButton.BorderSizePixel = 0
    KeyButton.Position = UDim2.new(0.45, 0, 0, 0)
    KeyButton.Size = UDim2.new(0.55, 0, 1, 0)
    KeyButton.Font = Enum.Font.GothamBold
    KeyButton.Text = Settings.UI.Keybind.Name
    KeyButton.TextColor3 = Colors.Text
    KeyButton.TextSize = 11
    
    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 3)
    KeyCorner.Parent = KeyButton
    
    local KeyStroke = Instance.new("UIStroke")
    KeyStroke.Color = Colors.Border
    KeyStroke.Thickness = 1
    KeyStroke.Parent = KeyButton
    
    local waitingForKey = false
    KeyButton.MouseButton1Click:Connect(function()
        if waitingForKey then return end
        waitingForKey = true
        KeyButton.Text = "..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Settings.UI.Keybind = input.KeyCode
                KeyButton.Text = input.KeyCode.Name
                waitingForKey = false
                connection:Disconnect()
            end
        end)
    end)
    
    ConfigPage.CanvasSize = UDim2.new(0, 0, 0, 130)
    
    local FontCard = CreateCard(ConfigPage, 125, 100)
    
    CreateSectionHeader(FontCard, "APARÊNCIA", 0)
    
    CreateDropdown(FontCard, "Fonte do Menu", {
        "Gotham",
        "GothamBold",
        "Code",
        "Roboto",
        "RobotoMono",
        "SourceSans",
        "Arial",
        "ArialBold"
    }, Settings.UI.Font, 35, function(value)
        Settings.UI.Font = value
        local newFont = Enum.Font[value]
        
        -- Atualizar todas as fontes no ScreenGui
        for _, obj in pairs(ScreenGui:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                pcall(function()
                    -- Manter negrito onde era negrito
                    local wasBold = string.find(tostring(obj.Font), "Bold")
                    if wasBold and not string.find(value, "Bold") then
                        -- Se era bold e nova fonte não é bold, tentar versão bold
                        local boldVersion = value .. "Bold"
                        if pcall(function() return Enum.Font[boldVersion] end) then
                            obj.Font = Enum.Font[boldVersion]
                        else
                            obj.Font = newFont
                        end
                    else
                        obj.Font = newFont
                    end
                end)
            end
        end
    end)
    
    ConfigPage.CanvasSize = UDim2.new(0, 0, 0, 240)
    
    ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Keybind toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Settings.UI.Keybind then
            Settings.UI.MenuOpen = not Settings.UI.MenuOpen
            MainContainer.Visible = Settings.UI.MenuOpen
        end
    end)
    
    return ScreenGui
end

-- ESP Functions
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local espObjects = {}
    
    local function updateESP()
        if not Settings.ESP.Enabled then return end
        if not player.Character then return end
        
        local head = player.Character:FindFirstChild("Head")
        if not head then return end
        
        -- Verificar se deve mostrar ESP baseado no time
        local shouldShow = true
        if Settings.ESP.TeamCheck and player.Team and LocalPlayer.Team then
            if player.Team == LocalPlayer.Team then
                shouldShow = false
            end
        end
        
        if not shouldShow then
            -- Esconder ESP se não deve mostrar
            if espObjects.Highlight then espObjects.Highlight.Enabled = false end
            if espObjects.BillboardGui then espObjects.BillboardGui.Enabled = false end
            return
        end
        
        if not espObjects.Highlight then
            local highlight = Instance.new("Highlight")
            highlight.Parent = player.Character
            highlight.FillColor = Colors.Danger
            highlight.OutlineColor = Colors.Accent
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            espObjects.Highlight = highlight
        end
        
        if not espObjects.BillboardGui then
            local billboard = Instance.new("BillboardGui")
            billboard.Parent = head
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = billboard
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = Colors.Danger
            nameLabel.TextStrokeTransparency = 0.5
            nameLabel.TextSize = 14
            nameLabel.Font = Enum.Font.GothamBold
            
            espObjects.BillboardGui = billboard
        end
        
        if espObjects.Highlight then espObjects.Highlight.Enabled = true end
        if espObjects.BillboardGui then espObjects.BillboardGui.Enabled = true end
    end
    
    local connection = RunService.RenderStepped:Connect(updateESP)
    espObjects.Connection = connection
    
    player.CharacterRemoving:Connect(function()
        for _, obj in pairs(espObjects) do
            if typeof(obj) == "Instance" then
                obj:Destroy()
            elseif typeof(obj) == "RBXScriptConnection" then
                obj:Disconnect()
            end
        end
    end)
    
    ESPObjects[player] = espObjects
    updateESP()
end

function EnableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
end

function DisableESP()
    for _, espObjects in pairs(ESPObjects) do
        for _, obj in pairs(espObjects) do
            if typeof(obj) == "Instance" then
                obj:Destroy()
            elseif typeof(obj) == "RBXScriptConnection" then
                obj:Disconnect()
            end
        end
    end
    ESPObjects = {}
end

-- FOV Circle
local function CreateFOVCircle()
    if not Drawing then return nil end
    
    local success, circle = pcall(function()
        local c = Drawing.new("Circle")
        c.Thickness = 2
        c.NumSides = 64
        c.Radius = Settings.Aimbot.FOVSize
        c.Filled = false
        c.Transparency = 1
        c.Color = Color3.new(76/255, 175/255, 80/255)
        c.Visible = Settings.Aimbot.ShowFOV
        return c
    end)
    
    return success and circle or nil
end

local function UpdateFOVCircle()
    if FOVCircle then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = mousePos
        FOVCircle.Radius = Settings.Aimbot.FOVSize
        FOVCircle.Visible = Settings.Aimbot.ShowFOV
    end
end

-- Aimbot Functions
local function IsVisible(targetPart)
    if not Settings.Aimbot.VisibilityCheck then return true end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local head = character:FindFirstChild("Head")
    if not head then return false end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.IgnoreWater = true
    
    local rayResult = workspace:Raycast(head.Position, (targetPart.Position - head.Position), rayParams)
    
    if rayResult then
        return rayResult.Instance:IsDescendantOf(targetPart.Parent)
    end
    
    return true
end

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Settings.Aimbot.FOVSize
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local targetPart = character:FindFirstChild(Settings.Aimbot.TargetPart)
            
            if targetPart and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                if Settings.Aimbot.IgnoreTeam and player.Team == LocalPlayer.Team then
                    continue
                end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if distance < shortestDistance and IsVisible(targetPart) then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function AimbotLoop()
    if not Settings.Aimbot.Enabled then return end
    
    local target = GetClosestPlayer()
    
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild(Settings.Aimbot.TargetPart)
        
        if targetPart then
            if Settings.Aimbot.Mode == "Mouse" then
                local targetPos = Camera:WorldToViewportPoint(targetPart.Position)
                local mousePos = UserInputService:GetMouseLocation()
                
                local delta = Vector2.new(targetPos.X - mousePos.X, targetPos.Y - mousePos.Y)
                local smoothness = Settings.Aimbot.Smoothness
                
                mousemoverel(delta.X * smoothness, delta.Y * smoothness)
                
            elseif Settings.Aimbot.Mode == "Camera" then
                local targetPosition = targetPart.Position
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)
                
                local smoothness = Settings.Aimbot.Smoothness
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothness)
            end
        end
    end
end

function ToggleAimbot(enabled)
    if enabled then
        if not AimbotConnection then
            AimbotConnection = RunService.RenderStepped:Connect(AimbotLoop)
        end
    else
        if AimbotConnection then
            AimbotConnection:Disconnect()
            AimbotConnection = nil
        end
    end
end

-- Hitbox Expander Functions
local function ExpandHitbox(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    
    local character = player.Character
    local targetPart = character:FindFirstChild(Settings.Hitbox.TargetPart)
    
    if not targetPart then return end
    
    -- Verificar se deve expandir baseado no time
    if Settings.Hitbox.IgnoreTeam and player.Team and LocalPlayer.Team then
        if player.Team == LocalPlayer.Team then
            -- Restaurar se for do mesmo time
            if OriginalSizes[targetPart] then
                local original = OriginalSizes[targetPart]
                targetPart.Size = original.Size
                targetPart.Transparency = original.Transparency
                targetPart.Massless = original.Massless
                targetPart.CanCollide = original.CanCollide
            end
            return
        end
    end
    
    -- Verificar visibilidade se necessário
    if Settings.Hitbox.VisibilityCheck and not IsVisible(targetPart) then
        return
    end
    
    -- Salvar propriedades originais se ainda não foi salvo
    if not OriginalSizes[targetPart] then
        OriginalSizes[targetPart] = {
            Size = targetPart.Size,
            Transparency = targetPart.Transparency,
            Massless = targetPart.Massless,
            CanCollide = targetPart.CanCollide
        }
    end
    
    -- Expandir hitbox sem afetar física
    targetPart.Size = Vector3.new(Settings.Hitbox.Size, Settings.Hitbox.Size, Settings.Hitbox.Size)
    targetPart.Transparency = Settings.Hitbox.Transparency
    targetPart.Massless = true
    targetPart.CanCollide = false
end

local function RestoreHitbox(player)
    if not player.Character then return end
    
    local character = player.Character
    
    -- Tentar restaurar tanto Head quanto HumanoidRootPart
    for _, partName in ipairs({"Head", "HumanoidRootPart"}) do
        local targetPart = character:FindFirstChild(partName)
        
        if targetPart and OriginalSizes[targetPart] then
            local original = OriginalSizes[targetPart]
            targetPart.Size = original.Size
            targetPart.Transparency = original.Transparency
            targetPart.Massless = original.Massless
            targetPart.CanCollide = original.CanCollide
            OriginalSizes[targetPart] = nil
        end
    end
end

local function RestoreAllHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        pcall(function()
            RestoreHitbox(player)
        end)
    end
end

local function HitboxLoop()
    if not Settings.Hitbox.Enabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            pcall(function()
                ExpandHitbox(player)
            end)
        end
    end
end

function ToggleHitbox(enabled)
    if enabled then
        -- Criar conexão para loop de hitbox
        if not HitboxConnections.Loop then
            HitboxConnections.Loop = RunService.Heartbeat:Connect(HitboxLoop)
        end
        
        -- Expandir hitboxes imediatamente
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                pcall(function()
                    ExpandHitbox(player)
                end)
            end
        end
    else
        -- Desconectar loop
        if HitboxConnections.Loop then
            HitboxConnections.Loop:Disconnect()
            HitboxConnections.Loop = nil
        end
        
        -- Restaurar todos os hitboxes
        RestoreAllHitboxes()
    end
end

-- Initialize
local function Initialize()
    local oldGui = game:GetService("CoreGui"):FindFirstChild("NatalHubV2")
    if oldGui then
        oldGui:Destroy()
        wait(0.1)
    end
    
    pcall(function()
        FOVCircle = CreateFOVCircle()
    end)
    
    RunService.RenderStepped:Connect(function()
        pcall(UpdateFOVCircle)
    end)
    
    local success = pcall(CreateUI)
    if not success then
        warn("Erro ao criar UI!")
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function()
                wait(0.5)
                if Settings.ESP.Enabled then
                    pcall(function() CreateESP(player) end)
                end
            end)
            
            player.CharacterRemoving:Connect(function()
                pcall(function() RestoreHitbox(player) end)
            end)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            wait(0.5)
            if Settings.ESP.Enabled then
                pcall(function() CreateESP(player) end)
            end
        end)
        
        player.CharacterRemoving:Connect(function()
            pcall(function() RestoreHitbox(player) end)
        end)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        pcall(function() RestoreHitbox(player) end)
    end)
end

pcall(Initialize)
