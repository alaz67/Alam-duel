-- BANANA HUB - THE RETURN OF THE BANANA (UI UPDATE)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Toggles = {Aimbot = false, ESP = false, Hitbox = false, AutoShoot = false, Jump = false}

-- UI Root
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "BananaHubFinalV2"
ScreenGui.DisplayOrder = 999

-- --- DE BANANENKNOP (LINKSBOVEN) ---
local MenuBtn = Instance.new("TextButton", ScreenGui)
MenuBtn.Size = UDim2.new(0, 60, 0, 60)
MenuBtn.Position = UDim2.new(0, 10, 0, 10) -- Nu linksboven
MenuBtn.Text = "ðŸŒ"
MenuBtn.TextSize = 40
MenuBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 0)
MenuBtn.BorderSizePixel = 0
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", MenuBtn)
Stroke.Thickness = 2
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- --- DE APARTE TP KNOP (ONDER DE BANAAN) ---
local TPBtn = Instance.new("TextButton", ScreenGui)
TPBtn.Size = UDim2.new(0, 60, 0, 60)
TPBtn.Position = UDim2.new(0, 10, 0, 80) -- Direct onder de banaan
TPBtn.Text = "TP"
TPBtn.Font = Enum.Font.GothamBold
TPBtn.TextColor3 = Color3.new(1, 1, 1)
TPBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 200)
Instance.new("UICorner", TPBtn).CornerRadius = UDim.new(0, 10)

-- --- HET MENU ---
local Menu = Instance.new("Frame", ScreenGui)
Menu.Size = UDim2.new(0, 200, 0, 260)
Menu.Position = UDim2.new(0, 80, 0, 10) -- Menu opent nu naast de knoppen
Menu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Menu.Visible = false
Menu.Active = true
Menu.Draggable = true
Instance.new("UICorner", Menu)

local function AddToggle(text, key, y)
local btn = Instance.new("TextButton", Menu)
btn.Size = UDim2.new(0.9, 0, 0, 40)
btn.Position = UDim2.new(0.05, 0, 0, y)
btn.Text = text
btn.Font = Enum.Font.GothamBold
btn.TextColor3 = Color3.new(1, 1, 1)
btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Instance.new("UICorner", btn)

btn.MouseButton1Click:Connect(function()
Toggles[key] = not Toggles[key]
btn.BackgroundColor3 = Toggles[key] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(45, 45, 45)
end)
end

AddToggle("AIMBOT (HEAD)", "Aimbot", 20)
AddToggle("AUTO-SHOOT", "AutoShoot", 70)
AddToggle("PLAYER ESP", "ESP", 120)
AddToggle("HUGE HITBOX", "Hitbox", 170)
AddToggle("INF JUMP", "Jump", 220)

-- --- LOGICA ---
MenuBtn.MouseButton1Click:Connect(function()
Menu.Visible = not Menu.Visible
end)

local function GetClosest()
local target, dist = nil, math.huge
for _, p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
local root = p.Character:FindFirstChild("HumanoidRootPart")
if root then
local d = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
if d < dist then dist = d; target = p.Character end
end
end
end
return target
end

TPBtn.MouseButton1Click:Connect(function()
local t = GetClosest()
if t and t:FindFirstChild("HumanoidRootPart") then
LocalPlayer.Character.HumanoidRootPart.CFrame = t.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
end
end)

-- De Hoofdloop
RunService:BindToRenderStep("BananaEngine", Enum.RenderPriority.Camera.Value + 1, function()
local enemy = GetClosest()

-- Aimbot & AutoShoot
if Toggles.Aimbot and enemy and enemy:FindFirstChild("Head") then
Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, enemy.Head.Position)
if Toggles.AutoShoot then
local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
if tool then tool:Activate() end
end
end

-- ESP & Hitbox Loop
for _, p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer and p.Character then
local hrp = p.Character:FindFirstChild("HumanoidRootPart")
if hrp then
hrp.Size = Toggles.Hitbox and Vector3.new(15, 15, 15) or Vector3.new(2, 2, 1)
hrp.Transparency = Toggles.Hitbox and 0.7 or 0
hrp.CanCollide = false
end
if Toggles.ESP then
if not p.Character:FindFirstChild("Highlight") then
local h = Instance.new("Highlight", p.Character)
h.FillColor = Color3.new(1, 0, 0)
end
elseif p.Character:FindFirstChild("Highlight") then
p.Character.Highlight:Destroy()
end
end
end
end)

UserInputService.JumpRequest:Connect(function()
if Toggles.Jump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
LocalPlayer.Character.Humanoid:ChangeState(3)
end
end)
