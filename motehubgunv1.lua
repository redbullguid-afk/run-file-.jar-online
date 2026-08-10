-- =============================================================
-- Anti-AFK + Bullet NoClip + Aimbot FOV (Draggable GUI Menu)
-- Tối ưu hóa hoàn toàn cho Delta Executor (Mobile & PC)
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
    Aimbot = { Enabled = false, Aiming = false, TargetPart = "Head", AimFOV = 150 },
    FOV_Circle = { Visible = false, Color = Color3.fromRGB(255, 0, 0), Thickness = 2, Transparency = 0.7, NumSides = 64 },
    NoClipBullets = false,
    AntiAFK = true
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
-- 1. TẠO GIAO DIỆN GUI (NÚT TRÒN & MENU)
-- =============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaModMenu"
-- Đặt vào CoreGui nếu có thể để không bị reset khi nhân vật chết
ScreenGui.Parent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- A. Nút tròn mở Menu (Main Circle Button)
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
UICornerBtn.CornerRadius = UDim.new(1, 0) -- Làm cho nút hoàn toàn tròn
UICornerBtn.Parent = CircleBtn

local UIStrokeBtn = Instance.new("UIStroke")
UIStrokeBtn.Color = Color3.fromRGB(0, 170, 255)
UIStrokeBtn.Thickness = 2
UIStrokeBtn.Parent = CircleBtn

-- B. Bảng Menu điều khiển (Main Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Position = UDim2.new(0.05, 65, 0.2, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 210)
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

-- C. Hàm tạo nút Toggle đơn giản
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

-- Tạo các nút chức năng
CreateToggleButton("Anti-AFK", 1, function(state) Config.AntiAFK = state end)
CreateToggleButton("Aimbot & FOV", 2, function(state) 
    Config.Aimbot.Enabled = state 
    Config.FOV_Circle.Visible = state
end)
CreateToggleButton("Đạn NoClip", 3, function(state) Config.NoClipBullets = state end)

-- =============================================================
-- 2. XỬ LÝ DI CHUYỂN NÚT TRÒN (DRAGGABLE SYSTEM)
-- =============================================================

local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    CircleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    -- Giữ bảng Menu luôn đi theo nút tròn
    MainFrame.Position = UDim2.new(CircleBtn.Position.X.Scale, CircleBtn.Position.X.Offset + 65, CircleBtn.Position.Y.Scale, CircleBtn.Position.Y.Offset)
end

CircleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = CircleBtn.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
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
        update(input)
    end
end)

-- Nhấn vào nút tròn để Đóng/Mở Menu
local isMoved = false
CircleBtn.MouseButton1Down:Connect(function() isMoved = false end)
CircleBtn.TouchLongPress:Connect(function() isMoved = true end)
CircleBtn.MouseButton1Click:Connect(function()
    if not isMoved then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- =============================================================
-- 3. LOGIC CÁC TÍNH NĂNG GAME
-- =============================================================

-- A. Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

-- B. Đạn NoClip
local bulletNames = {"Bullet", "Ammo", "Projectile", "Ray", "Part", "Pellet"}
local function makeBulletNoClip(child)
    if not Config.NoClipBullets then return end
    for _, name in ipairs(bulletNames) do
        if string.find(string.lower(child.Name), string.lower(name)) then
            if child:IsA("BasePart") then child.CanCollide = false end
            for _, subPart in pairs(child:GetDescendants()) do
                if subPart:IsA("BasePart") then subPart.CanCollide = false end
            end
        end
    end
end
Workspace.ChildAdded:Connect(makeBulletNoClip)
if Camera then Camera.ChildAdded:Connect(makeBulletNoClip) end

-- C. Aimbot Logic
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

-- D. Render Loop
RunService.RenderStepped:Connect(function()
    -- Cập nhật FOV Circle
    fov_circle.Visible = Config.FOV_Circle.Visible
    if Config.FOV_Circle.Visible then
        fov_circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fov_circle.Radius = Config.Aimbot.AimFOV
    end

    -- Khóa Aimbot
    if Config.Aimbot.Enabled and Config.Aimbot.Aiming then
        local Target = GetClosestPlayerInFOV()
        if Target and Target.Character and Target.Character:FindFirstChild(Config.Aimbot.TargetPart) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Character[Config.Aimbot.TargetPart].Position)
        end
    end
end)

-- Thông báo
StarterGui:SetCore("SendNotification", {
    Title = "Delta GUI Loaded",
    Text = "Nhấn hoặc kéo nút tròn MENU để điều khiển!",
    Duration = 5
})
