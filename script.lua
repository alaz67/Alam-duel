-- ALAZ DUEL | discord.gg/U4XXCxKUm
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer

print("[Alaz Duel] Loading...")

local Config = {
    SpeedBoost  = 60,
    CarrySpeed  = 29.5,
    Gravity     = 70,
    SpinSpeed   = 19,
    StealRadius = 25,
}

local Toggles = {
    AutoSteal   = false,
    StealSpeed  = false,
    Aimbot      = false,
    AutoLeft    = false,
    AutoRight   = false,
    Float       = false,
    Unwalk      = false,
    AntiRagdoll = false,
}

local Connections = {}
local lastSteal   = 0
local guiVisible  = true
local floatConn   = nil
local floatY      = nil
local spinBAV     = nil

local function getHRP()
    local c = Player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = Player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getMD()
    local h = getHum()
    return h and h.MoveDirection or Vector3.zero
end
local function isMyPlot(name)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(name)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then return yb.Enabled end
    end
    return false
end

-- Speed
RunService.Heartbeat:Connect(function()
    local hrp = getHRP()
    local hum = getHum()
    if not hrp or not hum then return end
    local md = getMD()
    if md.Magnitude < 0.1 then return end
    if hum.FloorMaterial == Enum.Material.Air then return end
    local stealing = Player:GetAttribute("Stealing")
    local spd = (stealing and Toggles.StealSpeed) and Config.CarrySpeed or Config.SpeedBoost
    hrp.AssemblyLinearVelocity = Vector3.new(md.X*spd, hrp.AssemblyLinearVelocity.Y, md.Z*spd)
end)

-- Anti Ragdoll
local function startAntiRag()
    if Connections.ar then return end
    Connections.ar = RunService.Heartbeat:Connect(function()
        if not Toggles.AntiRagdoll then return end
        local c = Player.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hum then
            local s = hum:GetState()
            if s == Enum.HumanoidStateType.Physics or s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
            end
        end
    end)
end
local function stopAntiRag()
    if Connections.ar then Connections.ar:Disconnect(); Connections.ar = nil end
end

-- Unwalk
local savedAnim = nil
local function startUnwalk()
    local c = Player.Character
    if not c then return end
    local hum = getHum()
    if hum then for _,t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    local anim = c:FindFirstChild("Animate")
    if anim then savedAnim = anim:Clone(); anim:Destroy() end
end
local function stopUnwalk()
    local c = Player.Character
    if c and savedAnim then savedAnim:Clone().Parent = c; savedAnim = nil end
end

-- Float
local function startFloat()
    local hrp = getHRP()
    if not hrp then return end
    floatY = hrp.Position.Y
    if floatConn then floatConn:Disconnect() end
    floatConn = RunService.Heartbeat:Connect(function()
        if not Toggles.Float then return end
        local h = getHRP()
        if not h then return end
        h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, 0, h.AssemblyLinearVelocity.Z)
        if floatY and math.abs(h.Position.Y - floatY) > 1 then
            h.CFrame = CFrame.new(h.Position.X, floatY, h.Position.Z)
        end
    end)
end
local function stopFloat()
    if floatConn then floatConn:Disconnect(); floatConn = nil end
end

-- Drop
local function dropAnimal()
    local hum = getHum()
    if hum then hum:UnequipTools() end
end

-- Aimbot
local function findEnemy()
    local hrp = getHRP()
    if not hrp then return nil end
    local best, bestD = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local eh = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if eh and hum and hum.Health > 0 then
                local d = (eh.Position - hrp.Position).Magnitude
                if d < bestD then bestD = d; best = eh end
            end
        end
    end
    return best
end
local function startAimbot()
    if Connections.aim then return end
    Connections.aim = RunService.Heartbeat:Connect(function()
        if not Toggles.Aimbot then return end
        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum then return end
        local t = findEnemy()
        if not t then return end
        local flat = Vector3.new(t.Position.X - hrp.Position.X, 0, t.Position.Z - hrp.Position.Z)
        if flat.Magnitude > 1.5 then
            local md = flat.Unit
            hrp.AssemblyLinearVelocity = Vector3.new(md.X*55, hrp.AssemblyLinearVelocity.Y, md.Z*55)
        end
    end)
end
local function stopAimbot()
    if Connections.aim then Connections.aim:Disconnect(); Connections.aim = nil end
end

-- Auto Left / Right
local PL1 = Vector3.new(-476.48,-6.28,92.73)
local PL2 = Vector3.new(-483.12,-4.95,94.80)
local PR1 = Vector3.new(-476.16,-6.52,25.62)
local PR2 = Vector3.new(-483.04,-5.09,23.14)
local leftPhase = 1
local rightPhase = 1

local function startAutoLeft()
    if Connections.autoL then Connections.autoL:Disconnect() end
    leftPhase = 1
    Connections.autoL = RunService.Heartbeat:Connect(function()
        if not Toggles.AutoLeft then return end
        local hrp = getHRP(); local hum = getHum()
        if not hrp or not hum then return end
        local tgt = leftPhase == 1 and PL1 or PL2
        local dist = (Vector3.new(tgt.X, hrp.Position.Y, tgt.Z) - hrp.Position).Magnitude
        if dist < 1.5 then
            if leftPhase == 1 then leftPhase = 2
            else
                hum:Move(Vector3.zero, false)
                hrp.AssemblyLinearVelocity = Vector3.zero
                Toggles.AutoLeft = false
                Connections.autoL:Disconnect(); Connections.autoL = nil
                return
            end
        end
        local d = (tgt - hrp.Position)
        local md = Vector3.new(d.X, 0, d.Z).Unit
        hum:Move(md, false)
        hrp.AssemblyLinearVelocity = Vector3.new(md.X*Config.SpeedBoost, hrp.AssemblyLinearVelocity.Y, md.Z*Config.SpeedBoost)
    end)
end
local function stopAutoLeft()
    if Connections.autoL then Connections.autoL:Disconnect(); Connections.autoL = nil end
    local hum = getHum(); if hum then hum:Move(Vector3.zero, false) end
end

local function startAutoRight()
    if Connections.autoR then Connections.autoR:Disconnect() end
    rightPhase = 1
    Connections.autoR = RunService.Heartbeat:Connect(function()
        if not Toggles.AutoRight then return end
        local hrp = getHRP(); local hum = getHum()
        if not hrp or not hum then return end
        local tgt = rightPhase == 1 and PR1 or PR2
        local dist = (Vector3.new(tgt.X, hrp.Position.Y, tgt.Z) - hrp.Position).Magnitude
        if dist < 1.5 then
            if rightPhase == 1 then rightPhase = 2
            else
                hum:Move(Vector3.zero, false)
                hrp.AssemblyLinearVelocity = Vector3.zero
                Toggles.AutoRight = false
                Connections.autoR:Disconnect(); Connections.autoR = nil
                return
            end
        end
        local d = (tgt - hrp.Position)
        local md = Vector3.new(d.X, 0, d.Z).Unit
        hum:Move(md, false)
        hrp.AssemblyLinearVelocity = Vector3.new(md.X*Config.SpeedBoost, hrp.AssemblyLinearVelocity.Y, md.Z*Config.SpeedBoost)
    end)
end
local function stopAutoRight()
    if Connections.autoR then Connections.autoR:Disconnect(); Connections.autoR = nil end
    local hum = getHum(); if hum then hum:Move(Vector3.zero, false) end
end

-- Auto Steal
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
                    if dist < nd and dist <= Config.StealRadius then
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

local function startAutoSteal()
    if Connections.steal then return end
    Connections.steal = RunService.Heartbeat:Connect(function()
        if not Toggles.AutoSteal then return end
        if tick() - lastSteal < 0.3 then return end
        local hum = getHum()
        if hum and hum.FloorMaterial == Enum.Material.Air then return end
        local p = findPrompt()
        if p and p.Parent then
            lastSteal = tick()
            pcall(function() fireproximityprompt(p) end)
        end
    end)
end
local function stopAutoSteal()
    if Connections.steal then Connections.steal:Disconnect(); Connections.steal = nil end
end

-- GUI
local sg = Instance.new("ScreenGui")
sg.Name = "AlazDuel"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = Player:FindFirstChildOfClass("PlayerGui") or Player.PlayerGui

local BG   = Color3.fromRGB(28,28,28)
local CARD = Color3.fromRGB(38,38,38)
local ORG  = Color3.fromRGB(220,130,50)
local WHT  = Color3.fromRGB(255,255,255)
local GRY  = Color3.fromRGB(80,80,80)
local DRK  = Color3.fromRGB(15,15,15)

-- MENU button
local menuBtn = Instance.new("TextButton", sg)
menuBtn.Size = UDim2.new(0,72,0,28)
menuBtn.Position = UDim2.new(0,5,0.38,-14)
menuBtn.BackgroundColor3 = CARD
menuBtn.Text = "MENU [U]"
menuBtn.TextColor3 = ORG
menuBtn.Font = Enum.Font.GothamBold
menuBtn.TextSize = 11
menuBtn.BorderSizePixel = 0
menuBtn.ZIndex = 20
Instance.new("UICorner", menuBtn).CornerRadius = UDim.new(0,6)
Instance.new("UIStroke", menuBtn).Color = ORG

-- LEFT PANEL
local leftPanel = Instance.new("Frame", sg)
leftPanel.Size = UDim2.new(0,145,0,10)
leftPanel.Position = UDim2.new(0,5,0.38,18)
leftPanel.BackgroundTransparency = 1
leftPanel.ZIndex = 20
leftPanel.AutomaticSize = Enum.AutomaticSize.Y

local leftList = Instance.new("UIListLayout", leftPanel)
leftList.Padding = UDim.new(0,4)
leftList.SortOrder = Enum.SortOrder.LayoutOrder

local lOrder = 0
local function nLO() lOrder=lOrder+1; return lOrder end

local activeKeybind = nil
local kbLabels = {}

local function mkRow(label, keybindName, toggleKey, onFn, offFn)
    local row = Instance.new("Frame", leftPanel)
    row.Size = UDim2.new(1,0,0,36)
    row.BackgroundColor3 = CARD
    row.BackgroundTransparency = 0.15
    row.BorderSizePixel = 0
    row.ZIndex = 21
    row.LayoutOrder = nLO()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,7)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-70,1,0)
    lbl.Position = UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = WHT
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 22

    local kbBtn = Instance.new("TextButton", row)
    kbBtn.Size = UDim2.new(0,36,0,22)
    kbBtn.Position = UDim2.new(1,-66,0.5,-11)
    kbBtn.BackgroundColor3 = DRK
    kbBtn.Text = "["..keybindName.."]"
    kbBtn.TextColor3 = ORG
    kbBtn.Font = Enum.Font.GothamBold
    kbBtn.TextSize = 9
    kbBtn.BorderSizePixel = 0
    kbBtn.ZIndex = 22
    Instance.new("UICorner", kbBtn).CornerRadius = UDim.new(0,4)
    kbLabels[toggleKey] = {btn=kbBtn, name=keybindName}

    local dot = Instance.new("Frame", row)
    dot.Size = UDim2.new(0,10,0,10)
    dot.Position = UDim2.new(1,-14,0.5,-5)
    dot.BackgroundColor3 = GRY
    dot.BorderSizePixel = 0
    dot.ZIndex = 22
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    local clk = Instance.new("TextButton", row)
    clk.Size = UDim2.new(0.65,0,1,0)
    clk.BackgroundTransparency = 1
    clk.Text = ""
    clk.ZIndex = 23

    local isOn = false
    local function toggle(state)
        isOn = state; Toggles[toggleKey] = isOn
        TweenService:Create(dot, TweenInfo.new(0.2), {BackgroundColor3 = isOn and ORG or GRY}):Play()
        if isOn and onFn  then onFn()  end
        if not isOn and offFn then offFn() end
    end

    clk.MouseButton1Click:Connect(function() toggle(not isOn) end)

    kbBtn.MouseButton1Click:Connect(function()
        activeKeybind = toggleKey
        kbBtn.Text = "..."
        kbBtn.TextColor3 = Color3.fromRGB(255,255,100)
    end)

    return row, toggle
end

local function mkActionRow(label)
    local btn = Instance.new("TextButton", leftPanel)
    btn.Size = UDim2.new(1,0,0,30)
    btn.BackgroundColor3 = CARD
    btn.BackgroundTransparency = 0.15
    btn.Text = label
    btn.TextColor3 = ORG
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.ZIndex = 21
    btn.LayoutOrder = nLO()
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)
    return btn
end

-- Build left panel rows
mkRow("Aimbot",     "X", "Aimbot",    startAimbot,    stopAimbot)
mkRow("Auto Left",  "Z", "AutoLeft",  startAutoLeft,  stopAutoLeft)
mkRow("Auto Right", "C", "AutoRight", startAutoRight, stopAutoRight)
mkRow("Float",      "T", "Float",     startFloat,     stopFloat)
local tntBtn = mkActionRow("TAUNT")
local dropBtn = mkActionRow("DROP")

dropBtn.MouseButton1Click:Connect(dropAnimal)

-- SETTINGS PANEL
local settingsPanel = Instance.new("Frame", sg)
settingsPanel.Name = "Settings"
settingsPanel.Size = UDim2.new(0,210,0,370)
settingsPanel.Position = UDim2.new(0.5,-105,0.5,-185)
settingsPanel.BackgroundColor3 = BG
settingsPanel.BackgroundTransparency = 0.05
settingsPanel.BorderSizePixel = 0
settingsPanel.Active = true
settingsPanel.Draggable = true
settingsPanel.ClipsDescendants = true
settingsPanel.ZIndex = 30
settingsPanel.Visible = false
Instance.new("UICorner", settingsPanel).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke", settingsPanel).Color = ORG

-- Settings title
local stitle = Instance.new("TextLabel", settingsPanel)
stitle.Size = UDim2.new(1,0,0,38)
stitle.BackgroundTransparency = 1
stitle.Text = "Alaz Duel"
stitle.TextColor3 = ORG
stitle.Font = Enum.Font.GothamBlack
stitle.TextSize = 17
stitle.TextXAlignment = Enum.TextXAlignment.Center
stitle.ZIndex = 31

local sdiv = Instance.new("Frame", settingsPanel)
sdiv.Size = UDim2.new(1,-20,0,1); sdiv.Position = UDim2.new(0,10,0,38)
sdiv.BackgroundColor3 = ORG; sdiv.BorderSizePixel = 0; sdiv.ZIndex = 31

local ssub = Instance.new("TextLabel", settingsPanel)
ssub.Size = UDim2.new(1,0,0,18); ssub.Position = UDim2.new(0,0,0,42)
ssub.BackgroundTransparency = 1; ssub.Text = "SETTINGS"
ssub.TextColor3 = ORG; ssub.Font = Enum.Font.GothamBold
ssub.TextSize = 10; ssub.TextXAlignment = Enum.TextXAlignment.Center; ssub.ZIndex = 31

-- Settings scroll
local sScroll = Instance.new("ScrollingFrame", settingsPanel)
sScroll.Size = UDim2.new(1,0,1,-65); sScroll.Position = UDim2.new(0,0,0,63)
sScroll.BackgroundTransparency = 1; sScroll.BorderSizePixel = 0
sScroll.ScrollBarThickness = 3; sScroll.ScrollBarImageColor3 = ORG
sScroll.CanvasSize = UDim2.new(0,0,0,0); sScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
sScroll.ZIndex = 31

local sList = Instance.new("UIListLayout", sScroll)
sList.Padding = UDim.new(0,4); sList.SortOrder = Enum.SortOrder.LayoutOrder
sList.HorizontalAlignment = Enum.HorizontalAlignment.Center
local sPad = Instance.new("UIPadding", sScroll)
sPad.PaddingLeft = UDim.new(0,8); sPad.PaddingRight = UDim.new(0,8)
sPad.PaddingTop = UDim.new(0,4); sPad.PaddingBottom = UDim.new(0,8)

local sO = 0
local function nSO() sO=sO+1; return sO end

local function mkSToggle(title, toggleKey, onFn, offFn)
    local row = Instance.new("Frame", sScroll)
    row.Size = UDim2.new(1,0,0,38)
    row.BackgroundColor3 = CARD; row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0; row.ZIndex = 32; row.LayoutOrder = nSO()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", row).Color = ORG

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-55,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = title
    lbl.TextColor3 = WHT; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 33

    local tb = Instance.new("Frame", row)
    tb.Size = UDim2.new(0,42,0,20); tb.Position = UDim2.new(1,-50,0.5,-10)
    tb.BackgroundColor3 = GRY; tb.BorderSizePixel = 0; tb.ZIndex = 32
    Instance.new("UICorner", tb).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", tb)
    knob.Size = UDim2.new(0,15,0,15); knob.Position = UDim2.new(0,3,0.5,-7.5)
    knob.BackgroundColor3 = WHT; knob.BorderSizePixel = 0; knob.ZIndex = 33
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local clk = Instance.new("TextButton", row)
    clk.Size = UDim2.new(1,0,1,0); clk.BackgroundTransparency = 1; clk.Text = ""; clk.ZIndex = 34

    local isOn = false
    local function sv(state)
        isOn = state; Toggles[toggleKey] = isOn
        TweenService:Create(tb, TweenInfo.new(0.2), {BackgroundColor3 = isOn and ORG or GRY}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = isOn and UDim2.new(1,-18,0.5,-7.5) or UDim2.new(0,3,0.5,-7.5)}):Play()
        if isOn and onFn  then onFn()  end
        if not isOn and offFn then offFn() end
    end
    clk.MouseButton1Click:Connect(function() sv(not isOn) end)
end

local function mkSSlider(title, configKey, mn, mx)
    local cont = Instance.new("Frame", sScroll)
    cont.Size = UDim2.new(1,0,0,50)
    cont.BackgroundColor3 = CARD; cont.BackgroundTransparency = 0.3
    cont.BorderSizePixel = 0; cont.ZIndex = 32; cont.LayoutOrder = nSO()
    Instance.new("UICorner", cont).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", cont).Color = ORG

    local tl = Instance.new("TextLabel", cont)
    tl.Size = UDim2.new(0.65,0,0,20); tl.Position = UDim2.new(0,10,0,4)
    tl.BackgroundTransparency = 1; tl.Text = title
    tl.TextColor3 = WHT; tl.Font = Enum.Font.GothamBold; tl.TextSize = 12
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 33

    local vl = Instance.new("TextLabel", cont)
    vl.Size = UDim2.new(0.3,0,0,20); vl.Position = UDim2.new(0.7,0,0,4)
    vl.BackgroundTransparency = 1; vl.Text = tostring(Config[configKey])
    vl.TextColor3 = ORG; vl.Font = Enum.Font.GothamBold; vl.TextSize = 12
    vl.TextXAlignment = Enum.TextXAlignment.Right; vl.ZIndex = 33

    local track = Instance.new("Frame", cont)
    track.Size = UDim2.new(1,-16,0,5); track.Position = UDim2.new(0,8,0,32)
    track.BackgroundColor3 = Color3.fromRGB(55,55,55); track.BorderSizePixel = 0; track.ZIndex = 32
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local pct = (Config[configKey]-mn)/(mx-mn)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(pct,0,1,0); fill.BackgroundColor3 = ORG
    fill.BorderSizePixel = 0; fill.ZIndex = 33
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local thumb = Instance.new("Frame", track)
    thumb.Size = UDim2.new(0,12,0,12); thumb.Position = UDim2.new(pct,-6,0.5,-6)
    thumb.BackgroundColor3 = WHT; thumb.BorderSizePixel = 0; thumb.ZIndex = 34
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1,0)

    local sBtn = Instance.new("TextButton", track)
    sBtn.Size = UDim2.new(1,0,4,0); sBtn.Position = UDim2.new(0,0,-1.5,0)
    sBtn.BackgroundTransparency = 1; sBtn.Text = ""; sBtn.ZIndex = 35

    local dragging = false
    local function upd(rel)
        rel = math.clamp(rel,0,1)
        fill.Size = UDim2.new(rel,0,1,0); thumb.Position = UDim2.new(rel,-6,0.5,-6)
        local val = math.floor((mn+(mx-mn)*rel)*10)/10
        vl.Text = tostring(val); Config[configKey] = val
    end
    sBtn.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X)
        end
    end)
end

local function mkSAction(label, cb)
    local btn = Instance.new("TextButton", sScroll)
    btn.Size = UDim2.new(1,0,0,34)
    btn.BackgroundColor3 = CARD; btn.BackgroundTransparency = 0.2
    btn.Text = label; btn.TextColor3 = ORG
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
    btn.BorderSizePixel = 0; btn.ZIndex = 32; btn.LayoutOrder = nSO()
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", btn).Color = ORG
    btn.MouseButton1Click:Connect(cb)
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundTransparency=0}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundTransparency=0.2}):Play() end)
end

-- Populate settings
mkSToggle("Auto Steal",   "AutoSteal",   startAutoSteal,  stopAutoSteal)
mkSToggle("Steal Speed",  "StealSpeed",  function() end,  function() end)
mkSSlider("Speed",        "CarrySpeed",  0,   60)
mkSToggle("Unwalk",       "Unwalk",      startUnwalk,     stopUnwalk)
mkSToggle("Anti Ragdoll", "AntiRagdoll", startAntiRag,    stopAntiRag)
mkSSlider("Speed Boost",  "SpeedBoost",  0,   120)
mkSSlider("Gravity",      "Gravity",     10,  150)
mkSSlider("Steal Radius", "StealRadius", 5,   80)
mkSAction("RESET", function()
    for k in pairs(Toggles) do Toggles[k] = false end
    stopAutoSteal(); stopAutoLeft(); stopAutoRight()
    stopAimbot(); stopFloat(); stopAntiRag(); stopUnwalk()
end)
mkSAction("SAVE CONFIG", function()
    pcall(function()
        if writefile then
            local d = {}
            for k,v in pairs(Config) do d[k]=v end
            writefile("AlazDuel.json", game:GetService("HttpService"):JSONEncode(d))
        end
    end)
end)

-- Gear button
local gearBtn = Instance.new("TextButton", sg)
gearBtn.Size = UDim2.new(0,26,0,26)
gearBtn.Position = UDim2.new(0,120,0.38,-13)
gearBtn.BackgroundColor3 = CARD
gearBtn.Text = "⚙"
gearBtn.TextColor3 = ORG
gearBtn.Font = Enum.Font.GothamBold
gearBtn.TextSize = 15
gearBtn.BorderSizePixel = 0
gearBtn.ZIndex = 20
Instance.new("UICorner", gearBtn).CornerRadius = UDim.new(0,6)
Instance.new("UIStroke", gearBtn).Color = ORG
gearBtn.MouseButton1Click:Connect(function()
    settingsPanel.Visible = not settingsPanel.Visible
end)

-- FPS / Ping
local fpsLbl = Instance.new("TextLabel", sg)
fpsLbl.Size = UDim2.new(0,90,0,40)
fpsLbl.Position = UDim2.new(1,-100,0,8)
fpsLbl.BackgroundTransparency = 1
fpsLbl.TextColor3 = Color3.fromRGB(80,255,120)
fpsLbl.Font = Enum.Font.GothamBold
fpsLbl.TextSize = 15
fpsLbl.ZIndex = 5

local frames = 0; local lastT = tick()
RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - lastT >= 1 then
        local fps = frames; frames = 0; lastT = tick()
        local ok, ping = pcall(function()
            return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        fpsLbl.Text = "FPS: "..fps.."
Ping: "..(ok and ping or "?")
    end
end)

-- Toggle handlers
menuBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    leftPanel.Visible = guiVisible
    menuBtn.Text = guiVisible and "MENU [U]" or "MENU [U]"
    if not guiVisible then settingsPanel.Visible = false end
end)

-- Keybinds
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end

    if activeKeybind then
        if kbLabels[activeKeybind] then
            kbLabels[activeKeybind].btn.Text = "["..inp.KeyCode.Name.."]"
            kbLabels[activeKeybind].btn.TextColor3 = ORG
        end
        activeKeybind = nil
        return
    end

    if inp.KeyCode == Enum.KeyCode.U then
        guiVisible = not guiVisible
        leftPanel.Visible = guiVisible
        if not guiVisible then settingsPanel.Visible = false end
    end
    if inp.KeyCode == Enum.KeyCode.X then Toggles.Aimbot = not Toggles.Aimbot; if Toggles.Aimbot then startAimbot() else stopAimbot() end end
    if inp.KeyCode == Enum.KeyCode.Z then Toggles.AutoLeft = not Toggles.AutoLeft; if Toggles.AutoLeft then startAutoLeft() else stopAutoLeft() end end
    if inp.KeyCode == Enum.KeyCode.C then Toggles.AutoRight = not Toggles.AutoRight; if Toggles.AutoRight then startAutoRight() else stopAutoRight() end end
    if inp.KeyCode == Enum.KeyCode.T then Toggles.Float = not Toggles.Float; if Toggles.Float then startFloat() else stopFloat() end end
end)

-- Respawn
Player.CharacterAdded:Connect(function()
    task.wait(1)
    if Toggles.Aimbot    then stopAimbot();    task.wait(0.1); startAimbot()    end
    if Toggles.AutoLeft  then stopAutoLeft();  task.wait(0.1); startAutoLeft()  end
    if Toggles.AutoRight then stopAutoRight(); task.wait(0.1); startAutoRight() end
    if Toggles.Float     then startFloat() end
    if Toggles.AntiRagdoll then startAntiRag() end
    if Toggles.AutoSteal then startAutoSteal() end
end)

print("[Alaz Duel] Loaded! discord.gg/U4XXCxKUm")
