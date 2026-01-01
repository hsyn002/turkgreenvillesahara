--// DEVELOPER MODE: KERNEL V70 (ULTRA SOFT + NO HINT KEY SYSTEM)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// AYARLAR
local CONFIG = {
    DepoPos = Vector3.new(1305.77, -77.86, -9967.73),
    Key = "merhametsiz",
    SpeedPower = 0,
    BrakePower = 0
}

--// [V70 ÇEKİRDEK YAPI - KORUNDU]
local function GetSafePoint(pos)
    local Character = LocalPlayer.Character
    if not Character then return pos end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {Character}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local ray = Workspace:Raycast(pos + Vector3.new(0, 100, 0), Vector3.new(0, -200, 0), rayParams)
    if ray and ray.Instance and not ray.Instance.Name:lower():find("leaf") then
        return ray.Position + Vector3.new(0, 4, 0)
    end
    return pos + Vector3.new(0, 10, 0)
end

local function HardTP(targetPos)
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end
    Root.Anchored = true
    LocalPlayer:RequestStreamAroundAsync(targetPos)
    task.wait(0.5)
    Root.CFrame = CFrame.new(GetSafePoint(targetPos))
    task.wait(0.8)
    Root.Anchored = false
end

local function GetCurrentMission()
    for _, item in pairs(Workspace:GetDescendants()) do
        if item:IsA("BasePart") and item.Transparency < 1 then
            if (item.Color.B > 0.8 and item.Color.R < 0.4) or item.Name == "Destination" then
                if item:FindFirstChildWhichIsA("ProximityPrompt") or item.Parent:FindFirstChildWhichIsA("ProximityPrompt") then
                    return item
                end
            end
        end
    end
    return nil
end

--// [ARAÇ MOTORU]
RunService.Heartbeat:Connect(function()
    local Character = LocalPlayer.Character
    local vehicle = Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.SeatPart
    if vehicle and vehicle:IsA("VehicleSeat") then
        if vehicle.Throttle > 0 and CONFIG.SpeedPower > 0 then
            vehicle.AssemblyLinearVelocity = vehicle.AssemblyLinearVelocity + (vehicle.CFrame.LookVector * (CONFIG.SpeedPower * 0.35))
        elseif vehicle.Throttle < 0 and CONFIG.BrakePower > 0 then
            vehicle.AssemblyLinearVelocity = vehicle.AssemblyLinearVelocity * (1 - (CONFIG.BrakePower * 0.04))
        end
    end
end)

--// [GUI TASARIM - SOFT & NO HINT]
if game.CoreGui:FindFirstChild("MerhametsizGV") then game.CoreGui.MerhametsizGV:Destroy() end
local SG = Instance.new("ScreenGui", game.CoreGui); SG.Name = "MerhametsizGV"; SG.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", SG)
MainFrame.Size = UDim2.new(0, 420, 0, 260)
MainFrame.Position = UDim2.new(0.5, -210, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Key Ekranı (İpucu Kaldırıldı)
local KeyScreen = Instance.new("Frame", MainFrame)
KeyScreen.Size = UDim2.new(1, 0, 1, 0); KeyScreen.BackgroundColor3 = Color3.fromRGB(20, 20, 20); KeyScreen.ZIndex = 100

local KeyBox = Instance.new("TextBox", KeyScreen)
KeyBox.Size = UDim2.new(0.6, 0, 0, 40); KeyBox.Position = UDim2.new(0.2, 0, 0.4, 0)
KeyBox.PlaceholderText = ""; KeyBox.Text = "" -- İpucu tamamen silindi
KeyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30); KeyBox.TextColor3 = Color3.new(1,1,1)
KeyBox.Font = Enum.Font.GothamMedium; KeyBox.TextSize = 16; KeyBox.ZIndex = 101
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)

-- Ana İçerik
local Content = Instance.new("Frame", MainFrame); Content.Size = UDim2.new(1, 0, 1, 0); Content.Visible = false; Content.BackgroundTransparency = 1
local Sidebar = Instance.new("Frame", Content); Sidebar.Size = UDim2.new(0, 120, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Sidebar.BorderSizePixel = 0
local Container = Instance.new("Frame", Content); Container.Position = UDim2.new(0, 130, 0, 10); Container.Size = UDim2.new(1, -140, 1, -20); Container.BackgroundTransparency = 1

local Pages = { Main = Instance.new("ScrollingFrame", Container), Utils = Instance.new("ScrollingFrame", Container) }
for _, p in pairs(Pages) do 
    p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = false; p.ScrollBarThickness = 0
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)
end

-- Buton/Slider Ekleme
local function AddBtn(p, txt, f)
    local b = Instance.new("TextButton", p); b.Size = UDim2.new(0.95, 0, 0, 38); b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamBold; b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(f)
end

local function AddSlider(p, txt, min, max, cb)
    local l = Instance.new("TextLabel", p); l.Size = UDim2.new(0.95, 0, 0, 18); l.Text = txt .. " [0]"; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = Enum.Font.Gotham; l.TextSize = 11
    local sf = Instance.new("Frame", p); sf.Size = UDim2.new(0.95, 0, 0, 22); sf.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 4)
    local fill = Instance.new("Frame", sf); fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(150, 255, 0); fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
    local btn = Instance.new("TextButton", sf); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""
    btn.MouseButton1Down:Connect(function()
        local conn; conn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local relX = math.clamp((input.Position.X - sf.AbsolutePosition.X) / sf.AbsoluteSize.X, 0, 1)
                TweenService:Create(fill, TweenInfo.new(0.2), {Size = UDim2.new(relX, 0, 1, 0)}):Play()
                local val = math.floor(min + (max - min) * relX)
                l.Text = txt .. " [" .. val .. "]"; cb(val)
            end
        end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 and conn then conn:Disconnect() end end)
    end)
end

-- İçerik
AddBtn(Pages.Main, "IŞINLAN: KARGO", function() local t = GetCurrentMission() if t then HardTP(t.Position) end end)
AddBtn(Pages.Main, "IŞINLAN: DEPO", function() HardTP(CONFIG.DepoPos) end)
AddSlider(Pages.Utils, "HIZ DESTEĞİ", 0, 100, function(v) CONFIG.SpeedPower = v end)
AddSlider(Pages.Utils, "FREN GÜCÜ", 0, 100, function(v) CONFIG.BrakePower = v end)

-- Sidebar Tabları
local function AddTab(n, pos, pg)
    local t = Instance.new("TextButton", Sidebar); t.Size = UDim2.new(1, 0, 0, 40); t.Position = UDim2.new(0, 0, 0, pos)
    t.BackgroundTransparency = 1; t.Text = n; t.TextColor3 = Color3.new(0.6, 0.6, 0.6); t.Font = Enum.Font.GothamBold; t.TextSize = 10
    t.MouseButton1Click:Connect(function() 
        for _, p in pairs(Pages) do p.Visible = false end 
        pg.Visible = true 
    end)
end
AddTab("TELEPORTS", 40, Pages.Main); AddTab("VEHICLE", 85, Pages.Utils)
Pages.Main.Visible = true

-- Key Doğrulama (Soft Geçiş)
KeyBox.FocusLost:Connect(function()
    if KeyBox.Text == CONFIG.Key then
        TweenService:Create(KeyScreen, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 0, -1, 0)}):Play()
        Content.Visible = true
        task.wait(0.6); KeyScreen:Destroy()
    else
        KeyBox.Text = ""; KeyBox.PlaceholderText = "WRONG!"; task.wait(1); KeyBox.PlaceholderText = ""
    end
end)

-- Soft Sürükleme
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        TweenService:Create(MainFrame, TweenInfo.new(0.12), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Soft AltGr Açılış
UserInputService.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightAlt then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            MainFrame.GroupTransparency = 1
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {GroupTransparency = 0}):Play()
        end
    end
end)
