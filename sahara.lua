--// DEVELOPER MODE: KERNEL V70 (MERHAMETSIZ GV)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

--// REFERANS GÜNCELLEME (ÖLÜNCE KAPANMAMA)
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Root = newChar:WaitForChild("HumanoidRootPart")
end)

--// AYARLAR
local CONFIG = {
    DepoPos = Vector3.new(1305.77, -77.86, -9967.73),
    WaitTime = 0.8,
    SafeHeight = 4,
    Key = "merhametsiz"
}

--// [V70 SİSTEMLERİ - KORUNDU]
local function GetSafePoint(pos)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {Character}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local ray = Workspace:Raycast(pos + Vector3.new(0, 100, 0), Vector3.new(0, -200, 0), rayParams)
    if ray and ray.Instance then
        if not ray.Instance.Name:lower():find("leaf") and not ray.Instance.Name:lower():find("tree") then
            return ray.Position + Vector3.new(0, CONFIG.SafeHeight, 0)
        end
    end
    return pos + Vector3.new(0, 10, 0)
end

local function HardTP(targetPos)
    if not Root then return end
    Root.Anchored = true
    LocalPlayer:RequestStreamAroundAsync(targetPos)
    task.wait(0.5)
    local finalPos = GetSafePoint(targetPos)
    Root.CFrame = CFrame.new(finalPos)
    task.wait(CONFIG.WaitTime)
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

--// [GUI TASARIM - GRAFFITI STYLE]
if game.CoreGui:FindFirstChild("SaharaSkate") then game.CoreGui.SaharaSkate:Destroy() end
local SG = Instance.new("ScreenGui", game.CoreGui); SG.Name = "SaharaSkate"; SG.ResetOnSpawn = false

-- Ana Panel
local MainFrame = Instance.new("Frame", SG)
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true

--// [SÜRÜKLEME SİSTEMİ]
local dragToggle, dragStart, startPos
local function updateInput(input)
    local delta = input.Position - dragStart
    local targetPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(MainFrame, TweenInfo.new(0.15), {Position = targetPosition}):Play()
end

MainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateInput(input)
    end
end)

-- Graffiti Süsü
local Line = Instance.new("Frame", MainFrame)
Line.Size = UDim2.new(1, 0, 0, 3); Line.BackgroundColor3 = Color3.fromRGB(150, 255, 0); Line.BorderSizePixel = 0

-- Başlık (Merhametsiz GV)
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40); Title.BackgroundTransparency = 1
Title.Text = "Merhametsiz GV"; Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.PermanentMarker; Title.TextSize = 22

-- Key Ekranı
local KeyFrame = Instance.new("Frame", MainFrame)
KeyFrame.Size = UDim2.new(1, 0, 1, -40); KeyFrame.Position = UDim2.new(0, 0, 0, 40)
KeyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); KeyFrame.BorderSizePixel = 0

local KeyInput = Instance.new("TextBox", KeyFrame)
KeyInput.Size = UDim2.new(0.8, 0, 0, 35); KeyInput.Position = UDim2.new(0.1, 0, 0.2, 0)
KeyInput.PlaceholderText = "KEY GİR..."; KeyInput.Text = ""
KeyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45); KeyInput.TextColor3 = Color3.new(1,1,1)
KeyInput.Font = Enum.Font.SourceSansBold

-- İçerik Paneli
local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, 0, 1, -40); Content.Position = UDim2.new(1, 0, 0, 40)
Content.BackgroundTransparency = 1

local function CreateSkateBtn(name, pos, func)
    local b = Instance.new("TextButton", Content)
    b.Size = UDim2.new(0.9, 0, 0, 40); b.Position = UDim2.new(0.05, 0, 0, pos)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.Text = name
    b.TextColor3 = Color3.fromRGB(150, 255, 0); b.Font = Enum.Font.PermanentMarker; b.TextSize = 16
    b.BorderSizePixel = 0
    b.MouseButton1Click:Connect(func)
end

CreateSkateBtn("LOCATE CARGO", 10, function()
    local t = GetCurrentMission()
    if t then HardTP(t.Position) end
end)

CreateSkateBtn("GO DEPOT", 60, function()
    HardTP(CONFIG.DepoPos)
end)

-- Key Mantığı
KeyInput.FocusLost:Connect(function()
    if KeyInput.Text == CONFIG.Key then
        TweenService:Create(KeyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(-1, 0, 0, 40)}):Play()
        TweenService:Create(Content, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 0, 0, 40)}):Play()
        task.wait(0.6)
        KeyFrame:Destroy()
    else
        KeyInput.Text = ""; KeyInput.PlaceholderText = "YANLIŞ KEY!"
    end
end)

-- AltGr Toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightAlt then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
