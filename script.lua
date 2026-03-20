-- ALAM HUB | discord.gg/U4XXCxKUm
local ok, err = pcall(function()
repeat task.wait() until game:IsLoaded()
task.wait(1)

local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TweenService")
local HTTP    = game:GetService("HttpService")
local Player  = Players.LocalPlayer
if not Player.Character then Player.CharacterAdded:Wait() end
task.wait(0.5)

-- ── CONFIG ──
local Cfg = {
    ReturnToBaseSpeed  = 29,
    GotoEnemySpeed     = 58.5,
    AutoLRSpeed        = 60,
    RunSpeedBoost      = 60,
    SpeedWhileStealing = 29,
    Gravity            = 70,
    HopPower           = 50,
    AimbotRadius       = 100,
    AimbotSpeed        = 55,
    MedusaRadius       = 10,
    SpinbotSpeed       = 50,
    FloatSpamCPS       = 6.9,
    FloatHeight        = 0,
    GUIScale           = 100,
}

-- ── TOGGLES ──
local T = {
    AutoPlay         = false,
    AutoStart        = false,
    AutoLeft         = false,
    AutoRight        = false,
    Float            = false,
    Ungrab           = false,
    AntiCollision    = false,
    SpeedBoost       = false,
    SpeedSteal       = false,
    InstantGrab      = false,
    OtherPlayersESP  = false,
    BatAimbot        = false,
    AutoMedusa       = false,
    JumpPower        = false,
    Performance      = false,
    AntiRagdoll      = false,
    NoAnimations     = false,
    Spinbot          = false,
    FloatSpammer     = false,
    MobileButtons    = false,
}

-- ── KEYBINDS ──
local KB = {
    AutoLeft      = Enum.KeyCode.Q,
    AutoRight     = Enum.KeyCode.E,
    SpeedSteal    = Enum.KeyCode.R,
    InstantGrab   = Enum.KeyCode.V,
    BatAimbot     = Enum.KeyCode.Z,
    Float         = Enum.KeyCode.F,
    SpeedBoost    = Enum.KeyCode.B,
    AntiRagdoll   = Enum.KeyCode.X,
    NoAnimations  = Enum.KeyCode.N,
    Spinbot       = Enum.KeyCode.T,
    FloatSpammer  = Enum.KeyCode.G,
    Ungrab        = Enum.KeyCode.C,
    Taunt         = Enum.KeyCode.Unknown,
    ToggleUI      = Enum.KeyCode.U,
}

local Conns = {}
local guiVisible = true
local lastGrab = 0
local floatConn = nil
local floatY = nil
local spinBAV = nil
local savedAnim = nil
local floatSpamConn = nil
local autoLRConn = nil
local leftPhase = 1
local rightPhase = 1

-- ── HELPERS ──
local function getHRP()
    local c = Player.Character; return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = Player.Character; return c and c:FindFirstChildOfClass("Humanoid")
end
local function getMD()
    local h = getHum(); return h and h.MoveDirection or Vector3.zero
end
local function isMyPlot(name)
    local plots = workspace:FindFirstChild("Plots"); if not plots then return false end
    local plot = plots:FindFirstChild(name); if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then local yb = sign:FindFirstChild("YourBase"); if yb and yb:IsA("BillboardGui") then return yb.Enabled end end
    return false
end

-- ── SPEED LOOP ──
RS.Heartbeat:Connect(function()
    local hrp = getHRP(); local hum = getHum()
    if not hrp or not hum then return end
    local md = getMD()
    if md.Magnitude < 0.1 then return end
    if hum.FloorMaterial == Enum.Material.Air then return end
    local stealing = Player:GetAttribute("Stealing")
    local spd
    if stealing and T.SpeedSteal then
        spd = Cfg.SpeedWhileStealing
    elseif T.SpeedBoost then
        spd = Cfg.RunSpeedBoost
    else return end
    hrp.AssemblyLinearVelocity = Vector3.new(md.X*spd, hrp.AssemblyLinearVelocity.Y, md.Z*spd)
end)

-- ── FLOAT ──
local function startFloat()
    local hrp = getHRP(); if not hrp then return end
    floatY = hrp.Position.Y + Cfg.FloatHeight
    if floatConn then floatConn:Disconnect() end
    floatConn = RS.Heartbeat:Connect(function()
        if not T.Float then return end
        local h = getHRP(); if not h then return end
        h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, 0, h.AssemblyLinearVelocity.Z)
        if floatY and math.abs(h.Position.Y - floatY) > 0.5 then
            h.CFrame = CFrame.new(h.Position.X, floatY, h.Position.Z)
        end
    end)
end
local function stopFloat()
    if floatConn then floatConn:Disconnect(); floatConn = nil end
end

-- ── FLOAT SPAMMER ──
local function startFloatSpammer()
    if floatSpamConn then return end
    floatSpamConn = RS.Heartbeat:Connect(function()
        if not T.FloatSpammer then return end
        local hrp = getHRP(); if not hrp then return end
        local interval = 1 / math.max(Cfg.FloatSpamCPS, 0.1)
        T.Float = not T.Float
        if T.Float then startFloat() else stopFloat() end
        task.wait(interval)
    end)
end
local function stopFloatSpammer()
    if floatSpamConn then floatSpamConn:Disconnect(); floatSpamConn = nil end
end

-- ── UNGRAB ──
local function doUngrab()
    local hum = getHum(); if hum then hum:UnequipTools() end
end

-- ── ANTI COLLISION ──
local function enableAntiCollision()
    local char = Player.Character; if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end
    end
end
local function disableAntiCollision()
    local char = Player.Character; if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then pcall(function() p.CanCollide = true end) end
    end
end

-- ── ANTI RAGDOLL ──
local function startAntiRagdoll()
    if Conns.ar then return end
    Conns.ar = RS.Heartbeat:Connect(function()
        if not T.AntiRagdoll then return end
        local c = Player.Character; if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hum then
            local s = hum:GetState()
            if s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                workspace.CurrentCamera.CameraSubject = hum
                if hrp then hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end
            end
        end
        for _, o in ipairs(c:GetDescendants()) do
            if o:IsA("Motor6D") and not o.Enabled then o.Enabled = true end
        end
    end)
end
local function stopAntiRagdoll()
    if Conns.ar then Conns.ar:Disconnect(); Conns.ar = nil end
end

-- ── NO ANIMATIONS ──
local function startNoAnim()
    local c = Player.Character; if not c then return end
    local hum = getHum()
    if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end end
    local anim = c:FindFirstChild("Animate")
    if anim then savedAnim = anim:Clone(); anim:Destroy() end
end
local function stopNoAnim()
    local c = Player.Character
    if c and savedAnim then savedAnim:Clone().Parent = c; savedAnim = nil end
end

-- ── SPINBOT ──
local function startSpinbot()
    local hrp = getHRP(); if not hrp then return end
    if spinBAV then spinBAV:Destroy() end
    spinBAV = Instance.new("BodyAngularVelocity")
    spinBAV.MaxTorque = Vector3.new(0, math.huge, 0)
    spinBAV.AngularVelocity = Vector3.new(0, Cfg.SpinbotSpeed, 0)
    spinBAV.Parent = hrp
end
local function stopSpinbot()
    if spinBAV then spinBAV:Destroy(); spinBAV = nil end
end

-- ── BAT AIMBOT ──
local function findEnemy()
    local hrp = getHRP(); if not hrp then return nil end
    local best, bd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local eh = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if eh and hum and hum.Health > 0 then
                local d = (eh.Position - hrp.Position).Magnitude
                if d < bd and d <= Cfg.AimbotRadius then bd = d; best = eh end
            end
        end
    end
    return best
end
local function startBatAimbot()
    if Conns.aim then return end
    Conns.aim = RS.Heartbeat:Connect(function()
        if not T.BatAimbot then return end
        local hrp = getHRP(); local hum = getHum(); if not hrp or not hum then return end
        local bp = Player:FindFirstChildOfClass("Backpack")
        local char = Player.Character
        local bat = nil
        if char then for _, ch in ipairs(char:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then bat = ch; break end end end
        if not bat and bp then for _, ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then bat = ch; break end end end
        if bat and bat.Parent ~= char then hum:EquipTool(bat) end
        local t = findEnemy(); if not t then return end
        local flat = Vector3.new(t.Position.X - hrp.Position.X, 0, t.Position.Z - hrp.Position.Z)
        if flat.Magnitude > 1 then
            local md = flat.Unit
            hrp.AssemblyLinearVelocity = Vector3.new(md.X*Cfg.AimbotSpeed, hrp.AssemblyLinearVelocity.Y, md.Z*Cfg.AimbotSpeed)
        end
    end)
end
local function stopBatAimbot()
    if Conns.aim then Conns.aim:Disconnect(); Conns.aim = nil end
end

-- ── OTHER PLAYERS SPEED ESP ──
local espLabels = {}
local function startESP()
    if Conns.esp then return end
    Conns.esp = RS.Heartbeat:Connect(function()
        if not T.OtherPlayersESP then
            for p, bb in pairs(espLabels) do pcall(function() bb:Destroy() end); espLabels[p] = nil end
            return
        end
        local hrp = getHRP()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local eh = p.Character:FindFirstChild("HumanoidRootPart")
                if eh then
                    if not espLabels[p] or not espLabels[p].Parent then
                        local bb = Instance.new("BillboardGui")
                        bb.Size = UDim2.new(0,120,0,30); bb.StudsOffset = Vector3.new(0,3,0)
                        bb.AlwaysOnTop = true; bb.Adornee = eh; bb.Parent = Player.PlayerGui
                        local lbl = Instance.new("TextLabel", bb)
                        lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(0,200,255); lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 12; lbl.Name = "SpeedLbl"
                        espLabels[p] = bb
                    end
                    local vel = eh.AssemblyLinearVelocity
                    local spd = math.floor(Vector3.new(vel.X,0,vel.Z).Magnitude)
                    local lbl = espLabels[p]:FindFirstChild("SpeedLbl")
                    if lbl then lbl.Text = p.Name.." | "..spd.." st/s" end
                end
            end
        end
    end)
end

-- ── AUTO MEDUSA ──
local function startAutoMedusa()
    if Conns.medusa then return end
    Conns.medusa = RS.Heartbeat:Connect(function()
        if not T.AutoMedusa then return end
        local hrp = getHRP(); if not hrp then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local eh = p.Character:FindFirstChild("HumanoidRootPart")
                if eh and (eh.Position - hrp.Position).Magnitude <= Cfg.MedusaRadius then
                    local bp = Player:FindFirstChildOfClass("Backpack")
                    local char = Player.Character
                    local medusa = nil
                    if char then for _, ch in ipairs(char:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("medusa") then medusa = ch; break end end end
                    if not medusa and bp then for _, ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("medusa") then medusa = ch; break end end end
                    if medusa then
                        local hum = getHum(); if hum then hum:EquipTool(medusa) end
                        pcall(function()
                            local remote = medusa:FindFirstChildOfClass("RemoteEvent") or medusa:FindFirstChildOfClass("RemoteFunction")
                            if remote then remote:FireServer() end
                        end)
                    end
                end
            end
        end
    end)
end
local function stopAutoMedusa()
    if Conns.medusa then Conns.medusa:Disconnect(); Conns.medusa = nil end
end

-- ── JUMP POWER ──
local function startJumpPower()
    if Conns.jump then return end
    Conns.jump = RS.Heartbeat:Connect(function()
        if not T.JumpPower then return end
        local hum = getHum(); if hum then hum.JumpHeight = Cfg.HopPower end
    end)
end
local function stopJumpPower()
    if Conns.jump then Conns.jump:Disconnect(); Conns.jump = nil end
    local hum = getHum(); if hum then hum.JumpHeight = 7.2 end
end

-- ── PERFORMANCE ──
local function enablePerformance()
    local Lighting = game:GetService("Lighting")
    Lighting.GlobalShadows = false
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            for _, obj in ipairs(p.Character:GetDescendants()) do
                pcall(function()
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj.Enabled = false end
                    if obj:IsA("BasePart") then obj.CastShadow = false end
                end)
            end
        end
    end
end
local function disablePerformance()
    game:GetService("Lighting").GlobalShadows = true
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
end

-- ── INSTANT GRAB ──
local function findPrompt()
    local hrp = getHRP(); if not hrp then return nil end
    local plots = workspace:FindFirstChild("Plots"); if not plots then return nil end
    local np, nd = nil, math.huge
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlot(plot.Name) then continue end
        local pods = plot:FindFirstChild("AnimalPodiums"); if not pods then continue end
        for _, pod in ipairs(pods:GetChildren()) do
            pcall(function()
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - hrp.Position).Magnitude
                    if dist < nd and dist <= 25 then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, ch in ipairs(att:GetChildren()) do
                                if ch:IsA("ProximityPrompt") then np = ch; nd = dist; break end
                            end
                        end
                    end
                end
            end)
        end
    end
    return np
end

local function doInstantGrab()
    if tick() - lastGrab < 0.3 then return end
    local p = findPrompt()
    if p and p.Parent then
        lastGrab = tick()
        pcall(function() fireproximityprompt(p) end)
    end
end

local function startInstantGrabLoop()
    if Conns.grab then return end
    Conns.grab = RS.Heartbeat:Connect(function()
        if not T.InstantGrab then return end
        local hum = getHum()
        if hum and hum.FloorMaterial == Enum.Material.Air then return end
        doInstantGrab()
    end)
end
local function stopInstantGrabLoop()
    if Conns.grab then Conns.grab:Disconnect(); Conns.grab = nil end
end

-- ── AUTO LEFT / RIGHT ──
local PL1 = Vector3.new(-476.48,-6.28,92.73)
local PL2 = Vector3.new(-483.12,-4.95,94.80)
local PR1 = Vector3.new(-476.16,-6.52,25.62)
local PR2 = Vector3.new(-483.04,-5.09,23.14)

local function startAutoLeft()
    if Conns.aL then Conns.aL:Disconnect() end; leftPhase = 1
    Conns.aL = RS.Heartbeat:Connect(function()
        if not T.AutoLeft then return end
        local hrp = getHRP(); local hum = getHum(); if not hrp or not hum then return end
        local tgt = leftPhase == 1 and PL1 or PL2
        local dist = (Vector3.new(tgt.X, hrp.Position.Y, tgt.Z) - hrp.Position).Magnitude
        if dist < 1.5 then
            if leftPhase == 1 then leftPhase = 2
            else hum:Move(Vector3.zero,false); hrp.AssemblyLinearVelocity=Vector3.zero; T.AutoLeft=false; Conns.aL:Disconnect(); Conns.aL=nil; return end
        end
        local d = (tgt - hrp.Position); local md = Vector3.new(d.X,0,d.Z).Unit
        hum:Move(md,false); hrp.AssemblyLinearVelocity = Vector3.new(md.X*Cfg.AutoLRSpeed, hrp.AssemblyLinearVelocity.Y, md.Z*Cfg.AutoLRSpeed)
    end)
end
local function stopAutoLeft()
    if Conns.aL then Conns.aL:Disconnect(); Conns.aL = nil end
    local h = getHum(); if h then h:Move(Vector3.zero,false) end
    T.AutoLeft = false
end

local function startAutoRight()
    if Conns.aR then Conns.aR:Disconnect() end; rightPhase = 1
    Conns.aR = RS.Heartbeat:Connect(function()
        if not T.AutoRight then return end
        local hrp = getHRP(); local hum = getHum(); if not hrp or not hum then return end
        local tgt = rightPhase == 1 and PR1 or PR2
        local dist = (Vector3.new(tgt.X, hrp.Position.Y, tgt.Z) - hrp.Position).Magnitude
        if dist < 1.5 then
            if rightPhase == 1 then rightPhase = 2
            else hum:Move(Vector3.zero,false); hrp.AssemblyLinearVelocity=Vector3.zero; T.AutoRight=false; Conns.aR:Disconnect(); Conns.aR=nil; return end
        end
        local d = (tgt - hrp.Position); local md = Vector3.new(d.X,0,d.Z).Unit
        hum:Move(md,false); hrp.AssemblyLinearVelocity = Vector3.new(md.X*Cfg.AutoLRSpeed, hrp.AssemblyLinearVelocity.Y, md.Z*Cfg.AutoLRSpeed)
    end)
end
local function stopAutoRight()
    if Conns.aR then Conns.aR:Disconnect(); Conns.aR = nil end
    local h = getHum(); if h then h:Move(Vector3.zero,false) end
    T.AutoRight = false
end

-- ── TP TO BRAINROT ──
local function tpToBrainrot(side)
    local hrp = getHRP(); if not hrp then return end
    if side == "left" then
        hrp.CFrame = CFrame.new(PL1)
    elseif side == "right" then
        hrp.CFrame = CFrame.new(PR1)
    else
        -- TP to highest gen
        local plots = workspace:FindFirstChild("Plots"); if not plots then return end
        local ok2, S = pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            return {
                Sync   = require(rs:WaitForChild("Packages"):WaitForChild("Synchronizer")),
                Shared = require(rs:WaitForChild("Shared"):WaitForChild("Animals")),
            }
        end)
        if not ok2 then return end
        local best, bestVal = nil, -1
        for _, plot in ipairs(plots:GetChildren()) do
            if isMyPlot(plot.Name) then continue end
            pcall(function()
                local ch = S.Sync:Get(plot.Name); if not ch then return end
                local list = ch:Get("AnimalList"); if not list then return end
                local pods = plot:FindFirstChild("AnimalPodiums"); if not pods then return end
                for slot, data in pairs(list) do
                    if type(data) ~= "table" then continue end
                    local val = S.Shared:GetGeneration(data.Index, data.Mutation, data.Traits, nil) or 0
                    if val > bestVal then
                        bestVal = val
                        local pod = pods:FindFirstChild(tostring(slot))
                        if pod then best = pod end
                    end
                end
            end)
        end
        if best then hrp.CFrame = CFrame.new(best:GetPivot().Position + Vector3.new(0,5,0)) end
    end
end

-- ── TAUNT ──
local function doTaunt()
    local char = Player.Character; if not char then return end
    local hum = getHum(); if not hum then return end
    local emote = game:GetService("ReplicatedStorage"):FindFirstChild("Emote", true)
    if emote then pcall(function() emote:FireServer("wave") end) end
end

-- ────────────────────────────────────────────────────────────
-- GUI
-- ────────────────────────────────────────────────────────────
local sg = Instance.new("ScreenGui")
sg.Name = "AlamHub"; sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = Player:FindFirstChildOfClass("PlayerGui") or Player.PlayerGui

-- COLORS
local BG    = Color3.fromRGB(12,15,22)
local CARD  = Color3.fromRGB(18,22,32)
local BLUE  = Color3.fromRGB(0,180,255)
local WHT   = Color3.fromRGB(255,255,255)
local GRY   = Color3.fromRGB(60,70,90)
local DGRY  = Color3.fromRGB(30,35,50)
local TBLUEON  = Color3.fromRGB(0,180,255)
local TBLUEOFF = Color3.fromRGB(40,50,70)

local function tw(obj, props, t)
    TS:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad), props):Play()
end

-- MINI ICON (top left - draggable)
local iconFrame = Instance.new("Frame", sg)
iconFrame.Size = UDim2.new(0,55,0,55)
iconFrame.Position = UDim2.new(0,10,0.35,0)
iconFrame.BackgroundColor3 = Color3.fromRGB(8,12,20)
iconFrame.BorderSizePixel = 0
iconFrame.Active = true; iconFrame.ZIndex = 100
Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0,12)
local iStroke = Instance.new("UIStroke", iconFrame); iStroke.Color = BLUE; iStroke.Thickness = 2

local iconLbl = Instance.new("TextLabel", iconFrame)
iconLbl.Size = UDim2.new(1,0,1,0); iconLbl.BackgroundTransparency = 1
iconLbl.Text = "A"; iconLbl.TextColor3 = BLUE
iconLbl.Font = Enum.Font.GothamBlack; iconLbl.TextSize = 26; iconLbl.ZIndex = 101

-- Drag icon
do
    local dragging, ds, dp = false, nil, nil
    iconFrame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; ds = i.Position; dp = iconFrame.Position
        end
    end)
    iconFrame.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - ds
            iconFrame.Position = UDim2.new(dp.X.Scale, dp.X.Offset+delta.X, dp.Y.Scale, dp.Y.Offset+delta.Y)
        end
    end)
end

-- MAIN PANEL
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0,380,0,580)
main.Position = UDim2.new(0.5,-190,0.5,-290)
main.BackgroundColor3 = BG
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.Active = true; main.Draggable = true; main.ClipsDescendants = true
main.ZIndex = 10
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)
local mStroke = Instance.new("UIStroke", main); mStroke.Color = BLUE; mStroke.Thickness = 2

-- TITLE
local titleLbl = Instance.new("TextLabel", main)
titleLbl.Size = UDim2.new(1,0,0,40); titleLbl.BackgroundTransparency = 1
titleLbl.Text = "ALAM HUB"; titleLbl.TextColor3 = BLUE
titleLbl.Font = Enum.Font.GothamBlack; titleLbl.TextSize = 20
titleLbl.TextXAlignment = Enum.TextXAlignment.Center; titleLbl.ZIndex = 11

local divLine = Instance.new("Frame", main)
divLine.Size = UDim2.new(1,-20,0,1); divLine.Position = UDim2.new(0,10,0,40)
divLine.BackgroundColor3 = BLUE; divLine.BorderSizePixel = 0; divLine.ZIndex = 11

-- TAB BAR
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1,-20,0,36); tabBar.Position = UDim2.new(0,10,0,46)
tabBar.BackgroundColor3 = DGRY; tabBar.BorderSizePixel = 0; tabBar.ZIndex = 11
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0,10)

local TABS = {"FEATURES","KEYBINDS","SETTINGS","MOBILE"}
local tabBtns = {}
local currentTab = "FEATURES"

local function mkTabBtn(name, xOff)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0,88,1,0); btn.Position = UDim2.new(0,xOff,0,0)
    btn.BackgroundTransparency = 1; btn.Text = name
    btn.TextColor3 = name == currentTab and WHT or GRY
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.ZIndex = 12
    tabBtns[name] = btn
    return btn
end

for i, name in ipairs(TABS) do mkTabBtn(name, (i-1)*92) end

-- Active tab indicator
local tabIndicator = Instance.new("Frame", tabBar)
tabIndicator.Size = UDim2.new(0,88,1,-4); tabIndicator.Position = UDim2.new(0,2,0,2)
tabIndicator.BackgroundColor3 = BLUE; tabIndicator.BorderSizePixel = 0; tabIndicator.ZIndex = 11
Instance.new("UICorner", tabIndicator).CornerRadius = UDim.new(0,8)

-- CONTENT AREA
local contentArea = Instance.new("Frame", main)
contentArea.Size = UDim2.new(1,-20,1,-92); contentArea.Position = UDim2.new(0,10,0,88)
contentArea.BackgroundTransparency = 1; contentArea.ZIndex = 11

local function mkPanel()
    local p = Instance.new("ScrollingFrame", contentArea)
    p.Size = UDim2.new(1,0,1,0)
    p.BackgroundTransparency = 1; p.BorderSizePixel = 0
    p.ScrollBarThickness = 3; p.ScrollBarImageColor3 = BLUE
    p.CanvasSize = UDim2.new(0,0,0,0); p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.ZIndex = 12; p.Visible = false
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0,2); layout.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", p)
    pad.PaddingBottom = UDim.new(0,10)
    return p
end

local featPanel = mkPanel(); featPanel.Visible = true
local kbPanel   = mkPanel()
local setPanel  = mkPanel()
local mobPanel  = mkPanel()

local panels = {FEATURES=featPanel, KEYBINDS=kbPanel, SETTINGS=setPanel, MOBILE=mobPanel}

local function switchTab(name)
    currentTab = name
    for n, p in pairs(panels) do p.Visible = (n == name) end
    for n, b in pairs(tabBtns) do b.TextColor3 = (n == name) and WHT or GRY end
    local idx = 0
    for i, t in ipairs(TABS) do if t == name then idx = i-1; break end end
    tw(tabIndicator, {Position = UDim2.new(0, 2+idx*92, 0, 2)})
end

for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

-- ── FEATURE ROW ──
local featOrder = 0
local function mkFeatRow(label, tKey, onFn, offFn)
    featOrder += 1
    local row = Instance.new("Frame", featPanel)
    row.Size = UDim2.new(1,0,0,44); row.BackgroundColor3 = CARD
    row.BackgroundTransparency = 0.2; row.BorderSizePixel = 0
    row.ZIndex = 13; row.LayoutOrder = featOrder
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-60,1,0); lbl.Position = UDim2.new(0,16,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = WHT; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 14

    local defOn = T[tKey] or false
    local tb = Instance.new("Frame", row)
    tb.Size = UDim2.new(0,46,0,24); tb.Position = UDim2.new(1,-56,0.5,-12)
    tb.BackgroundColor3 = defOn and TBLUEON or TBLUEOFF; tb.BorderSizePixel = 0; tb.ZIndex = 13
    Instance.new("UICorner", tb).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", tb)
    knob.Size = UDim2.new(0,18,0,18)
    knob.Position = defOn and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
    knob.BackgroundColor3 = WHT; knob.BorderSizePixel = 0; knob.ZIndex = 14
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local clk = Instance.new("TextButton", row)
    clk.Size = UDim2.new(1,0,1,0); clk.BackgroundTransparency = 1; clk.Text = ""; clk.ZIndex = 15

    local isOn = defOn
    local function sv(state)
        isOn = state; T[tKey] = isOn
        tw(tb, {BackgroundColor3 = isOn and TBLUEON or TBLUEOFF})
        tw(knob, {Position = isOn and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)})
        if isOn and onFn then onFn() end
        if not isOn and offFn then offFn() end
    end
    clk.MouseButton1Click:Connect(function() sv(not isOn) end)
    return row, sv
end

local function mkFeatBtn(label, color, cb)
    featOrder += 1
    local btn = Instance.new("TextButton", featPanel)
    btn.Size = UDim2.new(1,0,0,48); btn.BackgroundColor3 = color or BLUE
    btn.BorderSizePixel = 0; btn.Text = label
    btn.TextColor3 = Color3.fromRGB(5,10,20); btn.Font = Enum.Font.GothamBlack; btn.TextSize = 15
    btn.ZIndex = 13; btn.LayoutOrder = featOrder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    btn.MouseButton1Click:Connect(cb)
    btn.MouseEnter:Connect(function() tw(btn, {BackgroundTransparency=0.2}) end)
    btn.MouseLeave:Connect(function() tw(btn, {BackgroundTransparency=0}) end)
end

local function mkSeparator(parent, order)
    local sep = Instance.new("Frame", parent)
    sep.Size = UDim2.new(1,0,0,1); sep.BackgroundColor3 = Color3.fromRGB(30,40,60)
    sep.BorderSizePixel = 0; sep.ZIndex = 13; sep.LayoutOrder = order or 0
end

-- FEATURES TAB
mkFeatRow("Auto Play",        "AutoPlay",        function() end, function() end)
mkSeparator(featPanel, featOrder)
mkFeatRow("Auto Start",       "AutoStart",       function() end, function() end)
mkSeparator(featPanel, featOrder)
mkFeatRow("Auto Left",        "AutoLeft",        startAutoLeft,  stopAutoLeft)
mkSeparator(featPanel, featOrder)
mkFeatRow("Auto Right",       "AutoRight",       startAutoRight, stopAutoRight)
mkSeparator(featPanel, featOrder)
mkFeatBtn("TP to Brainrot", BLUE, function() tpToBrainrot("highest") end)
mkSeparator(featPanel, featOrder)
mkFeatRow("Float",            "Float",           startFloat,     stopFloat)
mkSeparator(featPanel, featOrder)
mkFeatRow("Ungrab",           "Ungrab",          function()
    if Conns.ungrab then return end
    Conns.ungrab = RS.Heartbeat:Connect(function()
        if not T.Ungrab then return end
        doUngrab()
    end)
end, function()
    if Conns.ungrab then Conns.ungrab:Disconnect(); Conns.ungrab = nil end
end)
mkSeparator(featPanel, featOrder)
mkFeatRow("Anti Collision",   "AntiCollision",   enableAntiCollision, disableAntiCollision)
mkSeparator(featPanel, featOrder)
mkFeatRow("Speed Boost",      "SpeedBoost",      function() end, function() end)
mkSeparator(featPanel, featOrder)
mkFeatRow("Speed Steal",      "SpeedSteal",      function() end, function() end)
mkSeparator(featPanel, featOrder)
mkFeatRow("Instant Grab",     "InstantGrab",     startInstantGrabLoop, stopInstantGrabLoop)
mkSeparator(featPanel, featOrder)
mkFeatRow("Other Players ESP","OtherPlayersESP", startESP, function()
    T.OtherPlayersESP = false
    for p, bb in pairs(espLabels) do pcall(function() bb:Destroy() end); espLabels[p] = nil end
    if Conns.esp then Conns.esp:Disconnect(); Conns.esp = nil end
end)
mkSeparator(featPanel, featOrder)
mkFeatRow("Bat Aimbot",       "BatAimbot",       startBatAimbot, stopBatAimbot)
mkSeparator(featPanel, featOrder)
mkFeatRow("Auto Medusa",      "AutoMedusa",      startAutoMedusa, stopAutoMedusa)
mkSeparator(featPanel, featOrder)
mkFeatRow("Jump Power",       "JumpPower",       startJumpPower,  stopJumpPower)
mkSeparator(featPanel, featOrder)
mkFeatRow("Performance",      "Performance",     enablePerformance, disablePerformance)
mkSeparator(featPanel, featOrder)
mkFeatRow("Anti Ragdoll",     "AntiRagdoll",     startAntiRagdoll, stopAntiRagdoll)
mkSeparator(featPanel, featOrder)
mkFeatRow("No Animations",    "NoAnimations",    startNoAnim, stopNoAnim)
mkSeparator(featPanel, featOrder)
mkFeatRow("Spinbot",          "Spinbot",         startSpinbot, stopSpinbot)
mkSeparator(featPanel, featOrder)
mkFeatRow("Float Spammer",    "FloatSpammer",    startFloatSpammer, stopFloatSpammer)
mkSeparator(featPanel, featOrder)
mkFeatBtn("TAUNT", BLUE, doTaunt)

-- ── KEYBIND ROW ──
local kbOrder = 0
local activeRebind = nil
local kbDisplays = {}

local function mkKbRow(label, kbKey)
    kbOrder += 1
    local row = Instance.new("Frame", kbPanel)
    row.Size = UDim2.new(1,0,0,52); row.BackgroundColor3 = CARD
    row.BackgroundTransparency = 0.2; row.BorderSizePixel = 0
    row.ZIndex = 13; row.LayoutOrder = kbOrder
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    -- Key badge
    local badge = Instance.new("TextButton", row)
    badge.Size = UDim2.new(0,44,0,44); badge.Position = UDim2.new(0,4,0.5,-22)
    badge.BackgroundColor3 = BLUE; badge.BorderSizePixel = 0
    local kbVal = KB[kbKey]
    badge.Text = kbVal and (kbVal == Enum.KeyCode.Unknown and "NONE" or kbVal.Name) or "?"
    badge.TextColor3 = Color3.fromRGB(5,10,20); badge.Font = Enum.Font.GothamBlack; badge.TextSize = 13
    badge.ZIndex = 14
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0,8)
    kbDisplays[kbKey] = badge

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-60,1,0); lbl.Position = UDim2.new(0,58,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = WHT; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 14

    badge.MouseButton1Click:Connect(function()
        activeRebind = kbKey
        badge.Text = "..."
        badge.BackgroundColor3 = Color3.fromRGB(255,200,0)
    end)

    mkSeparator(kbPanel, kbOrder)
end

mkKbRow("Auto Left Keybind",    "AutoLeft")
mkKbRow("Auto Right Keybind",   "AutoRight")
mkKbRow("Speed Steal Keybind",  "SpeedSteal")
mkKbRow("Instant Grab Keybind", "InstantGrab")
mkKbRow("Bat Aimbot Keybind",   "BatAimbot")
mkKbRow("Float Keybind",        "Float")
mkKbRow("Speed Boost Keybind",  "SpeedBoost")
mkKbRow("Anti Ragdoll Keybind", "AntiRagdoll")
mkKbRow("No Anim Keybind",      "NoAnimations")
mkKbRow("Spinbot Keybind",      "Spinbot")
mkKbRow("Float Spam Keybind",   "FloatSpammer")
mkKbRow("Ungrab Keybind",       "Ungrab")
mkKbRow("Taunt Keybind",        "Taunt")
mkKbRow("Toggle UI Keybind",    "ToggleUI")

-- ── SETTINGS ROW ──
local setOrder = 0
local function mkSetRow(label, cfgKey, min, max)
    setOrder += 1
    local row = Instance.new("Frame", setPanel)
    row.Size = UDim2.new(1,0,0,52); row.BackgroundColor3 = CARD
    row.BackgroundTransparency = 0.2; row.BorderSizePixel = 0
    row.ZIndex = 13; row.LayoutOrder = setOrder
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6,0,1,0); lbl.Position = UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = WHT; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 14

    local valBox = Instance.new("TextButton", row)
    valBox.Size = UDim2.new(0,80,0,34); valBox.Position = UDim2.new(1,-90,0.5,-17)
    valBox.BackgroundColor3 = BLUE; valBox.BorderSizePixel = 0
    valBox.Text = tostring(Cfg[cfgKey])
    valBox.TextColor3 = Color3.fromRGB(5,10,20); valBox.Font = Enum.Font.GothamBlack; valBox.TextSize = 14
    valBox.ZIndex = 14
    Instance.new("UICorner", valBox).CornerRadius = UDim.new(0,8)

    -- Click to edit value
    valBox.MouseButton1Click:Connect(function()
        -- Cycle through preset values
        local presets = {}
        local step = (max - min) / 10
        for i = min, max, step do table.insert(presets, math.floor(i*10)/10) end
        local cur = Cfg[cfgKey]
        local idx = 1
        for i, v in ipairs(presets) do if v == cur then idx = i; break end end
        idx = (idx % #presets) + 1
        Cfg[cfgKey] = presets[idx]
        valBox.Text = tostring(presets[idx])
        if cfgKey == "SpinbotSpeed" and spinBAV then spinBAV.AngularVelocity = Vector3.new(0, Cfg.SpinbotSpeed, 0) end
    end)

    mkSeparator(setPanel, setOrder)
end

mkSetRow("GUI Scale %",           "GUIScale",           50,  200)
mkSetRow("Return To Base Speed",  "ReturnToBaseSpeed",  0,   100)
mkSetRow("Goto Enemy Base Speed", "GotoEnemySpeed",     0,   150)
mkSetRow("Simple Auto L/R Speed", "AutoLRSpeed",        0,   150)
mkSetRow("Run Speed Boost",       "RunSpeedBoost",      0,   150)
mkSetRow("Speed While Stealing",  "SpeedWhileStealing", 0,   100)
mkSetRow("Gravity",               "Gravity",            10,  200)
mkSetRow("Hop Power",             "HopPower",           0,   200)
mkSetRow("Aimbot Radius",         "AimbotRadius",       10,  500)
mkSetRow("Aimbot Speed",          "AimbotSpeed",        10,  200)
mkSetRow("Medusa Radius",         "MedusaRadius",       1,   50)
mkSetRow("Spinbot Speed",         "SpinbotSpeed",       1,   200)
mkSetRow("Float Spam CPS",        "FloatSpamCPS",       0.5, 30)
mkSetRow("Float Height",          "FloatHeight",        -20, 50)

setOrder += 1
local resetBtn = Instance.new("TextButton", setPanel)
resetBtn.Size = UDim2.new(1,0,0,48); resetBtn.BackgroundColor3 = BLUE
resetBtn.BorderSizePixel = 0; resetBtn.Text = "RESET DEFAULTS"
resetBtn.TextColor3 = Color3.fromRGB(5,10,20); resetBtn.Font = Enum.Font.GothamBlack; resetBtn.TextSize = 15
resetBtn.ZIndex = 13; resetBtn.LayoutOrder = setOrder
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,10)
resetBtn.MouseButton1Click:Connect(function()
    Cfg.ReturnToBaseSpeed  = 29
    Cfg.GotoEnemySpeed     = 58.5
    Cfg.AutoLRSpeed        = 60
    Cfg.RunSpeedBoost      = 60
    Cfg.SpeedWhileStealing = 29
    Cfg.Gravity            = 70
    Cfg.HopPower           = 50
    Cfg.AimbotRadius       = 100
    Cfg.AimbotSpeed        = 55
    Cfg.MedusaRadius       = 10
    Cfg.SpinbotSpeed       = 50
    Cfg.FloatSpamCPS       = 6.9
    Cfg.FloatHeight        = 0
    Cfg.GUIScale           = 100
end)

-- ── MOBILE TAB ──
local mobOrder = 0
local function mkMobRow(label, cb)
    mobOrder += 1
    local row = Instance.new("Frame", mobPanel)
    row.Size = UDim2.new(1,0,0,50); row.BackgroundColor3 = CARD
    row.BackgroundTransparency = 0.2; row.BorderSizePixel = 0
    row.ZIndex = 13; row.LayoutOrder = mobOrder
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.TextColor3 = WHT
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Center; lbl.ZIndex = 14

    local clk = Instance.new("TextButton", row)
    clk.Size = UDim2.new(1,0,1,0); clk.BackgroundTransparency = 1; clk.Text = ""; clk.ZIndex = 15
    if cb then clk.MouseButton1Click:Connect(cb) end
    mkSeparator(mobPanel, mobOrder)
end

local function mkMobLabel(text)
    mobOrder += 1
    local lbl = Instance.new("TextLabel", mobPanel)
    lbl.Size = UDim2.new(1,0,0,28); lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = BLUE
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 13; lbl.LayoutOrder = mobOrder
    local pad = Instance.new("UIPadding", lbl); pad.PaddingLeft = UDim.new(0,10)
end

mkMobLabel("MOBILE BUTTONS")
mkMobRow("Show Mobile Buttons", function() T.MobileButtons = true end)
mkMobRow("Lock Buttons", function() end)

local mobInfo = Instance.new("TextLabel", mobPanel)
mobInfo.Size = UDim2.new(1,-20,0,60); mobInfo.BackgroundTransparency = 1
mobInfo.Text = "6 buttons: 3 on LEFT side, 3 on RIGHT side
LEFT: Auto Play, Left, Right
RIGHT: Float, Bat Aimbot, Spinbot"
mobInfo.TextColor3 = GRY; mobInfo.Font = Enum.Font.Gotham; mobInfo.TextSize = 11
mobInfo.TextWrapped = true; mobInfo.ZIndex = 13; mobInfo.LayoutOrder = mobOrder+1

mobOrder += 2
local resetMobBtn = Instance.new("TextButton", mobPanel)
resetMobBtn.Size = UDim2.new(1,0,0,44); resetMobBtn.BackgroundColor3 = DGRY
resetMobBtn.BorderSizePixel = 0; resetMobBtn.Text = "RESET MOBILE UI"
resetMobBtn.TextColor3 = WHT; resetMobBtn.Font = Enum.Font.GothamBold; resetMobBtn.TextSize = 14
resetMobBtn.ZIndex = 13; resetMobBtn.LayoutOrder = mobOrder
Instance.new("UICorner", resetMobBtn).CornerRadius = UDim.new(0,8)

-- ── RIGHT MINI PANEL (TP shortcuts) ──
local rightPanel = Instance.new("Frame", sg)
rightPanel.Size = UDim2.new(0,160,0,180)
rightPanel.Position = UDim2.new(1,-175,0.5,-90)
rightPanel.BackgroundColor3 = Color3.fromRGB(8,12,20)
rightPanel.BorderSizePixel = 0; rightPanel.ZIndex = 10
Instance.new("UICorner", rightPanel).CornerRadius = UDim.new(0,14)
Instance.new("UIStroke", rightPanel).Color = BLUE

local rpTitle = Instance.new("TextLabel", rightPanel)
rpTitle.Size = UDim2.new(1,0,0,32); rpTitle.BackgroundTransparency = 1
rpTitle.Text = "ALAM HUB"; rpTitle.TextColor3 = BLUE
rpTitle.Font = Enum.Font.GothamBlack; rpTitle.TextSize = 14
rpTitle.TextXAlignment = Enum.TextXAlignment.Center; rpTitle.ZIndex = 11

local rpSub = Instance.new("TextLabel", rightPanel)
rpSub.Size = UDim2.new(1,0,0,16); rpSub.Position = UDim2.new(0,0,0,30)
rpSub.BackgroundTransparency = 1; rpSub.Text = "TP to Brainrot"
rpSub.TextColor3 = GRY; rpSub.Font = Enum.Font.Gotham; rpSub.TextSize = 11
rpSub.TextXAlignment = Enum.TextXAlignment.Center; rpSub.ZIndex = 11

local function mkRPBtn(label, yp, cb)
    local btn = Instance.new("TextButton", rightPanel)
    btn.Size = UDim2.new(1,-16,0,36); btn.Position = UDim2.new(0,8,0,yp)
    btn.BackgroundColor3 = Color3.fromRGB(25,30,45); btn.BorderSizePixel = 0
    btn.Text = label; btn.TextColor3 = GRY
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; btn.ZIndex = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    btn.MouseButton1Click:Connect(function()
        tw(btn, {TextColor3 = WHT})
        task.delay(0.5, function() tw(btn, {TextColor3 = GRY}) end)
        cb()
    end)
end

mkRPBtn("Left Side",    52, function() tpToBrainrot("left") end)
mkRPBtn("Right Side",   96, function() tpToBrainrot("right") end)

local autoLRBtn = Instance.new("TextButton", rightPanel)
autoLRBtn.Size = UDim2.new(1,-16,0,36); autoLRBtn.Position = UDim2.new(0,8,0,140)
autoLRBtn.BackgroundColor3 = Color3.fromRGB(25,30,45); autoLRBtn.BorderSizePixel = 0
autoLRBtn.TextColor3 = GRY; autoLRBtn.Font = Enum.Font.GothamBold; autoLRBtn.TextSize = 13; autoLRBtn.ZIndex = 11
Instance.new("UICorner", autoLRBtn).CornerRadius = UDim.new(0,8)
local autoLRon = false
local function updateAutoLRBtn()
    autoLRBtn.Text = "Auto L/R: " .. (autoLRon and "ON" or "OFF")
    autoLRBtn.TextColor3 = autoLRon and BLUE or GRY
end
updateAutoLRBtn()
autoLRBtn.MouseButton1Click:Connect(function()
    autoLRon = not autoLRon
    if autoLRon then
        T.AutoLeft = true; startAutoLeft()
    else
        stopAutoLeft(); stopAutoRight(); T.AutoLeft=false; T.AutoRight=false
    end
    updateAutoLRBtn()
end)

-- ── MOBILE QUICK BUTTONS ──
local mobBtns = {}
local function createMobileButtons()
    -- Left side: Auto Play, Left, Right
    local leftBtns = {
        {label="Auto
Play",  cb=function() T.AutoPlay=not T.AutoPlay end},
        {label="Left",        cb=function() T.AutoLeft=not T.AutoLeft; if T.AutoLeft then startAutoLeft() else stopAutoLeft() end end},
        {label="Right",       cb=function() T.AutoRight=not T.AutoRight; if T.AutoRight then startAutoRight() else stopAutoRight() end end},
    }
    for i, data in ipairs(leftBtns) do
        local btn = Instance.new("TextButton", sg)
        btn.Size = UDim2.new(0,55,0,55)
        btn.Position = UDim2.new(0,5,0.6+(i-1)*0.1,0)
        btn.BackgroundColor3 = Color3.fromRGB(15,20,35)
        btn.BackgroundTransparency = 0.2
        btn.Text = data.label; btn.TextColor3 = BLUE
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
        btn.BorderSizePixel = 0; btn.ZIndex = 50
        btn.TextWrapped = true
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
        Instance.new("UIStroke", btn).Color = BLUE
        btn.MouseButton1Click:Connect(data.cb)
        table.insert(mobBtns, btn)
    end

    -- Right side: Float, Bat Aimbot, Spinbot
    local rightBtns = {
        {label="Float",    cb=function() T.Float=not T.Float; if T.Float then startFloat() else stopFloat() end end},
        {label="Aimbot",   cb=function() T.BatAimbot=not T.BatAimbot; if T.BatAimbot then startBatAimbot() else stopBatAimbot() end end},
        {label="Spin",     cb=function() T.Spinbot=not T.Spinbot; if T.Spinbot then startSpinbot() else stopSpinbot() end end},
    }
    for i, data in ipairs(rightBtns) do
        local btn = Instance.new("TextButton", sg)
        btn.Size = UDim2.new(0,55,0,55)
        btn.Position = UDim2.new(1,-65,0.6+(i-1)*0.1,0)
        btn.BackgroundColor3 = Color3.fromRGB(15,20,35)
        btn.BackgroundTransparency = 0.2
        btn.Text = data.label; btn.TextColor3 = BLUE
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
        btn.BorderSizePixel = 0; btn.ZIndex = 50
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
        Instance.new("UIStroke", btn).Color = BLUE
        btn.MouseButton1Click:Connect(data.cb)
        table.insert(mobBtns, btn)
    end
end
createMobileButtons()

-- ── ICON TOGGLE ──
iconFrame.InputBegan:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.Touch and i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    -- Only toggle if not dragging
    task.wait(0.15)
    if not (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) then return end
    guiVisible = not guiVisible
    main.Visible = guiVisible
    rightPanel.Visible = guiVisible
end)

-- Simple tap detection
local tapStart = nil
iconFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
        tapStart = tick()
    end
end)
iconFrame.InputEnded:Connect(function(i)
    if (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1) and tapStart then
        if tick() - tapStart < 0.2 then
            guiVisible = not guiVisible
            main.Visible = guiVisible
            rightPanel.Visible = guiVisible
        end
        tapStart = nil
    end
end)

-- ── KEYBIND INPUT ──
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end

    -- Rebinding
    if activeRebind then
        KB[activeRebind] = inp.KeyCode
        if kbDisplays[activeRebind] then
            kbDisplays[activeRebind].Text = inp.KeyCode == Enum.KeyCode.Unknown and "NONE" or inp.KeyCode.Name
            kbDisplays[activeRebind].BackgroundColor3 = BLUE
        end
        activeRebind = nil; return
    end

    local k = inp.KeyCode
    if k == KB.ToggleUI    then guiVisible=not guiVisible; main.Visible=guiVisible; rightPanel.Visible=guiVisible end
    if k == KB.AutoLeft    then T.AutoLeft=not T.AutoLeft; if T.AutoLeft then startAutoLeft() else stopAutoLeft() end end
    if k == KB.AutoRight   then T.AutoRight=not T.AutoRight; if T.AutoRight then startAutoRight() else stopAutoRight() end end
    if k == KB.SpeedSteal  then T.SpeedSteal=not T.SpeedSteal end
    if k == KB.InstantGrab then
        if T.InstantGrab then stopInstantGrabLoop(); T.InstantGrab=false
        else T.InstantGrab=true; startInstantGrabLoop() end
    end
    if k == KB.BatAimbot   then T.BatAimbot=not T.BatAimbot; if T.BatAimbot then startBatAimbot() else stopBatAimbot() end end
    if k == KB.Float       then T.Float=not T.Float; if T.Float then startFloat() else stopFloat() end end
    if k == KB.SpeedBoost  then T.SpeedBoost=not T.SpeedBoost end
    if k == KB.AntiRagdoll then T.AntiRagdoll=not T.AntiRagdoll; if T.AntiRagdoll then startAntiRagdoll() else stopAntiRagdoll() end end
    if k == KB.NoAnimations then T.NoAnimations=not T.NoAnimations; if T.NoAnimations then startNoAnim() else stopNoAnim() end end
    if k == KB.Spinbot     then T.Spinbot=not T.Spinbot; if T.Spinbot then startSpinbot() else stopSpinbot() end end
    if k == KB.FloatSpammer then T.FloatSpammer=not T.FloatSpammer; if T.FloatSpammer then startFloatSpammer() else stopFloatSpammer() end end
    if k == KB.Ungrab      then doUngrab() end
    if k == KB.Taunt       then doTaunt() end
end)

-- ── RESPAWN ──
Player.CharacterAdded:Connect(function()
    task.wait(1)
    if T.AntiRagdoll  then stopAntiRagdoll(); task.wait(0.1); startAntiRagdoll() end
    if T.BatAimbot    then stopBatAimbot();   task.wait(0.1); startBatAimbot()   end
    if T.AutoLeft     then stopAutoLeft();    task.wait(0.1); startAutoLeft()    end
    if T.AutoRight    then stopAutoRight();   task.wait(0.1); startAutoRight()   end
    if T.Float        then startFloat() end
    if T.Spinbot      then startSpinbot() end
    if T.InstantGrab  then startInstantGrabLoop() end
end)

print("[ALAM HUB] Loaded! discord.gg/U4XXCxKUm | U = Toggle")

end)
if not ok then warn("[ALAM HUB] Error: "..tostring(err)) end
