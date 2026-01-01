--// DEVELOPER MODE: KERNEL V70 (MANUAL BASE - NO LOGS)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- Karakter değiştiğinde (ölünce) Root referansını güncelle
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Root = newChar:WaitForChild("HumanoidRootPart")
end)

--// AYARLAR
local CONFIG = {
    DepoPos = Vector3.new(1305.77, -77.86, -9967.73),
    WaitTime = 0.8,
    SafeHeight = 4 
}

--// [V70 SİSTEM 1] LAZERLE ZEMİN KONTROLÜ
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

--// [V70 SİSTEM 2] HARD TELEPORT
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

--// [V70 SİSTEM 3] GÖREV BULUCU
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

--// [GUI PANEL]
if game.CoreGui:FindFirstChild("SaharaControl") then game.CoreGui.SaharaControl:Destroy() end
local SG = Instance.new("ScreenGui", game.CoreGui)
SG.Name = "SaharaControl"
SG.ResetOnSpawn = false -- ÖLÜNCE KAPANMAMASI İÇİN

local Frame = Instance.new("Frame", SG)
Frame.Size = UDim2.new(0, 220, 0, 105)
Frame.Position = UDim2.new(0.8, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Active = true
Frame.Draggable = true
Frame.Visible = true -- Başlangıçta açık

local function CreateBtn(name, pos, color, func)
    local b = Instance.new("TextButton", Frame)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Position = UDim2.new(0.05, 0, 0, pos)
    b.Text = name
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = "SourceSansBold"
    b.TextSize = 13
    b.MouseButton1Click:Connect(func)
    return b
end

-- 1. KARGOYA IŞINLAN
CreateBtn("KARGOYA IŞINLAN", 10, Color3.fromRGB(130, 0, 200), function()
    local target = GetCurrentMission()
    if target then HardTP(target.Position) end
end)

-- 2. DEPOYA IŞINLAN
CreateBtn("DEPOYA IŞINLAN", 55, Color3.fromRGB(200, 150, 0), function()
    HardTP(CONFIG.DepoPos)
end)

--// [SİSTEM 5] ALTGR (RIGHTALT) TUŞ ATAMASI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.RightAlt then
            Frame.Visible = not Frame.Visible
        end
    end
end)
