-- =============================================================
-- Delta Mod Menu Full (5 In 1): 
-- Anti-AFK | NoClip Bullets | Smooth Aimbot | ESP Glow | Invisible Shield
-- Tối ưu hoàn toàn cho Delta Executor (Mobile & PC)
-- =============================================================

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // CẤU HÌNH TÍNH NĂNG
local Config = {
    Aimbot = { 
        Enabled = false, 
        Aiming = false, 
        TargetPart = "Head", 
        AimFOV = 150,
        Smoothness = 0.25
    },
    FOV_Circle = { Visible = false, Color = Color3.fromRGB(255, 0, 0), Thickness = 2, Transparency = 0.7, NumSides = 64 },
    NoClipBullets = false,
    AntiAFK = true,
    ESP = false,
    Shield = false -- Chức năng Khiên Bất Tử / Tường vô hình
}

-- // CÔNG CỤ VẼ FOV CIRCLE
local fov_circle = Drawing.new("Circle")
fov_circle.Visible = false
fov_circle.Color = Config.FOV_Circle.Color
fov_circle.Thickness = Config.FOV_Circle.Thickness
fov_circle.Transparency = Config.FOV_Circle.Transparency
fov_circle.NumSides = Config.FOV_Circle.NumSides
fov_circle.Radius = Config.Aimbot.AimFOV
fov_circle.Filled = false

-- =============================================================
-- 1. GIAO DIỆN GUI (NÚT TRÒN & MENU)
-- =============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaModMenu"
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local CircleBtn = Instance.new("TextButton")
CircleBtn.Name = "CircleToggle"
CircleBtn.Parent = ScreenGui
CircleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
CircleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
CircleBtn.Size = UDim2.new(0, 55, 0, 55)
CircleBtn.Text = "MENU"
CircleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleBtn.TextSize = 12
CircleBtn.Font = Enum.Font.SourceSansBold
CircleBtn.Active = true

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(1, 0)
UICornerBtn.Parent = CircleBtn

local UIStrokeBtn = Instance.new("UIStroke")
UIStrokeBtn.Color = Color3.fromRGB(0, 170, 255)
UIStrokeBtn.Thickness = 2
UIStrokeBtn.Parent = CircleBtn

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Position = UDim2.new(0.05, 65, 0.2, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 290) -- Mở rộng menu để đủ chứa 5 nút
MainFrame.Visible = false

local UICornerFrame = Instance.new("UICorner")
UICornerFrame.CornerRadius = UDim.new(0, 10)
UICornerFrame.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "DELTA MOD MENU"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

local function CreateToggleButton(text, layoutOrder, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = MainFrame
    Btn.Size = UDim2.new(0.85, 0, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Btn.Text = text .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    Btn.Font = Enum.Font.SourceSansSemibold
    Btn.TextSize = 14
    Btn.LayoutOrder = layoutOrder

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Btn.Text = text .. ": ON"
            Btn.TextColor3 = Color3.fromRGB(100, 255, 100)
            Btn.BackgroundColor3 = Color3.fromRGB(50, 60, 50)
        else
            Btn.Text = text .. ": OFF"
            Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
            Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        end
        callback(state)
    end)
    return Btn
end

-- MÃ NGUỒN XỬ LÝ KHIÊN BẤT TỬ
local function ToggleShield(state)
    Config.Shield = state
    local char = LocalPlayer.Character
    if not char then return end

    if state then
        if char:FindFirstChild("InvisibleShield") then char.InvisibleShield:Destroy() end

        local root = char:WaitForChild("HumanoidRootPart", 3)
        if not root then return end

        -- Tạo quả cầu khiên vô hình bao quanh nhân vật
        local Shield = Instance.new("Part")
        Shield.Name = "InvisibleShield"
        Shield.Shape = Enum.PartType.Ball
        Shield.Size = Vector3.new(12, 12, 12) -- Kích thước khiên bao quanh
        Shield.Transparency = 1 -- Vô hình
        Shield.CanCollide = true
        Shield.Massless = true
        Shield.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        Shield.Parent = char

        local Weld = Instance.new("WeldConstraint")
        Weld.Part0 = root
        Weld.Part1 = Shield
        Weld.Parent = Shield

        -- Bỏ va chạm CHỈ VỚI BẢN THÂN NHÂN VẬT (chống đơ/bay khi di chuyển)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part ~= Shield then
                local ncc = Instance.new("NoCollisionConstraint")
                ncc.Part0 = Shield
                ncc.Part1 = part
                ncc.Parent = Shield
            end
        end
    else
        if char:FindFirstChild("InvisibleShield") then
            char.InvisibleShield:Destroy()
        end
    end
end

-- Tự động bật lại khiên khi hồi sinh nhân vật
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if Config.Shield then ToggleShield(true) end
end)

-- Tạo đủ 5 nút chức năng
CreateToggleButton("Anti-AFK", 1, function(state) Config.AntiAFK = state end)
CreateToggleButton("Aimbot & FOV", 2, function(state) 
    Config.Aimbot.Enabled = state 
    Config.FOV_Circle.Visible = state
end)
CreateToggleButton("Đạn NoClip", 3, function(state) Config.NoClipBullets = state end)
CreateToggleButton("ESP Phát Sáng", 4, function(state) Config.ESP = state end)
CreateToggleButton("Khiên Bất Tử", 5, function(state) ToggleShield(state) end)

-- KÉO NÚT MENU TRÒN
local dragging = false
local dragInput, dragStart, startPos

CircleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = CircleBtn.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

CircleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        CircleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        MainFrame.Position = UDim2.new(CircleBtn.Position.X.Scale, CircleBtn.Position.X.Offset + 65, CircleBtn.Position.Y.Scale, CircleBtn.Position.Y.Offset)
    end
end)

local isMoved = false
CircleBtn.MouseButton1Down:Connect(function() isMoved = false end)
CircleBtn.TouchLongPress:Connect(function() isMoved = true end)
CircleBtn.MouseButton1Click:Connect(function()
    if not isMoved then MainFrame.Visible = not MainFrame.Visible end
end)

-- =============================================================
-- 2. CHỨC NĂNG ESP PHÁT SÁNG
-- =============================================================

local function ApplyESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end

    local highlight = char:FindFirstChild("ESPHighlight")

    if Config.ESP then
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "ESPHighlight"
            highlight.Parent = char
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
        end

        if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
            highlight.FillColor = Color3.fromRGB(0, 255, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        else
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
        end
    else
        if highlight then highlight:Destroy() end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        for _, player in pairs(Players:GetPlayers()) do
            ApplyESP(player)
        end
    end
end)

-- =============================================================
-- 3. CÁC TÍNH NĂNG KHÁC (Anti-AFK, Đạn NoClip, Smooth Aimbot)
-- =============================================================

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

-- Đạn NoClip
local bulletKeywords = {"bullet", "ammo", "projectile", "ray", "pellet", "part", "casing", "shot"}
RunService.Stepped:Connect(function()
    if not Config.NoClipBullets then return end
    for _, item in pairs(Workspace:GetChildren()) do
        local lowerName = string.lower(item.Name)
        for _, key in ipairs(bulletKeywords) do
            if string.find(lowerName, key) then
                if item:IsA("BasePart") then item.CanCollide = false end
                for _, child in pairs(item:GetDescendants()) do
                    if child:IsA("BasePart") then child.CanCollide = false end
                end
            end
        end
    end
end)

-- Aimbot Logic
local function GetClosestPlayerInFOV()
    local ClosestPlayer = nil
    local ShortestDistance = Config.Aimbot.AimFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Config.Aimbot.TargetPart) and player.Character:FindFirstChildOfClass("Humanoid") then
            if player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                if LocalPlayer.Team == nil or player.Team ~= LocalPlayer.Team then
                    local TargetPart = player.Character[Config.Aimbot.TargetPart]
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)

                    if OnScreen then
                        local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - ScreenCenter).Magnitude

                        if Distance < ShortestDistance then
                            ShortestDistance = Distance
                            ClosestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return ClosestPlayer
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Config.Aimbot.Aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Config.Aimbot.Aiming = false
    end
end)

-- Render Loop
RunService.RenderStepped:Connect(function()
    fov_circle.Visible = Config.FOV_Circle.Visible
    if Config.FOV_Circle.Visible then
        fov_circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fov_circle.Radius = Config.Aimbot.AimFOV
    end

    if Config.Aimbot.Enabled and Config.Aimbot.Aiming then
        local Target = GetClosestPlayerInFOV()
        if Target and Target.Character and Target.Character:FindFirstChild(Config.Aimbot.TargetPart) then
            local TargetPos = Target.Character[Config.Aimbot.TargetPart].Position
            local TargetCFrame = CFrame.new(Camera.CFrame.Position, TargetPos)
            Camera.CFrame = Camera.CFrame:Lerp(TargetCFrame, Config.Aimbot.Smoothness)
        end
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "Delta Mod Menu",
    Text = "Đã tích hợp đủ 5 chức năng!",
    Duration = 5
})
