-- ╔══════════════════════════════════════════════════════════════╗
-- ║                    ALAM HUB                                  ║
-- ║              Steal a Brainrot Duels                          ║
-- ║              discord.gg/U4XXCxKUm                            ║
-- ╚══════════════════════════════════════════════════════════════╝
repeat task.wait() until game:IsLoaded()
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Player           = Players.LocalPlayer
local Config = {
    Speed        = 60,
    StealSpeed   = 29,
    AimbotSpeed  = 55,
    SpinSpeed    = 50,
    StealRadius  = 25,
}
local Toggles = {
    AutoLeft    = false,
    AutoRight   = false,
    Float       = false,
    BatAimbot   = false,
    Spinbot     = false,
    InstantGrab = false,
    SpeedBoost  = false,
    SpeedSteal  = false,
    AntiRagdoll = false,
    NoAnim      = false,
}
local KB = {
    AutoLeft    = Enum.KeyCode.Q,
    AutoRight   = Enum.KeyCode.E,
    InstantGrab = Enum.KeyCode.V,
    BatAimbot   = Enum.KeyCode.Z,
    Float       = Enum.KeyCode.F,
    SpeedBoost  = Enum.KeyCode.B,
    AntiRagdoll = Enum.KeyCode.X,
    NoAnim      = Enum.KeyCode.N,
    Spinbot     = Enum.KeyCode.T,
    Ungrab      = Enum.KeyCode.C,
    ToggleUI    = Enum.KeyCode.U,
}
local Connections = {}
local floatY      = nil
local floatConn   = nil
local spinBAV     = nil
local savedAnim   = nil
local lastGrab    = 0
local leftPhase   = 1
local rightPhase  = 1
local guiVisible  = true
local function getHRP()
    local c = Player.Character
    return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()
    local c = Player.Character
    return c and c:FindFirstChildOfClass("Humanoid") end
local function getMoveDir()
    local h = getHum()
    return h and h.MoveDirection or Vector3.zero end
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
    return false end
RunService.Heartbeat:Connect(function()
    local hrp = getHRP()
    local hum = getHum()
    if not hrp or not hum then return end
    local md = getMoveDir()
    if md.Magnitude < 0.1 then return end
    if hum.FloorMaterial == Enum.Material.Air then return end
    local stealing = Player:GetAttribute("Stealing")
    local spd = nil
    if stealing and Toggles.SpeedSteal then
        spd = Config.StealSpeed
    elseif Toggles.SpeedBoost then
        spd = Config.Speed
    end
    if spd then
        hrp.AssemblyLinearVelocity = Vector3.new(md.X * spd, hrp.AssemblyLinearVelocity.Y, md.Z * spd)
    end end)
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
        if floatY and math.abs(h.Position.Y - floatY) > 0.5 then
            h.CFrame = CFrame.new(h.Position.X, floatY, h.Position.Z)
        end
    end) end
local function stopFloat()
    if floatConn then floatConn:Disconnect(); floatConn = nil end end
local function startAimbot()
    if Connections.aim then return end
    Connections.aim = RunService.Heartbeat:Connect(function()
        if not Toggles.BatAimbot then return end
        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum then return end
        local best, bd = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local eh = p.Character:FindFirstChild("HumanoidRootPart")
                local h2 = p.Character:FindFirstChildOfClass("Humanoid")
                if eh and h2 and h2.Health > 0 then
                    local d = (eh.Position - hrp.Position).Magnitude
                    if d < bd then bd = d; best = eh end
                end
            end
        end
        if not best then return end
        local flat = Vector3.new(best.Position.X - hrp.Position.X, 0, best.Position.Z - hrp.Position.Z)
        if flat.Magnitude > 1 then
            local md = flat.Unit
            hrp.AssemblyLinearVelocity = Vector3.new(md.X * Config.AimbotSpeed, hrp.AssemblyLinearVelocity.Y, md.Z * Config.AimbotSpeed)
        end
    end) end
local function stopAimbot()
    if Connections.aim then Connections.aim:Disconnect(); Connections.aim = nil end end
local function startSpinbot()
    local hrp = getHRP()
    if not hrp then return end
    if spinBAV then spinBAV:Destroy() end
    spinBAV=Instance.new("BodyAngularVelocity")
    spinBAV.MaxTorque = Vector3.new(0, math.huge, 0)
    spinBAV.AngularVelocity = Vector3.new(0, Config.SpinSpeed, 0)
    spinBAV.Parent = hrp end
local function stopSpinbot()
    if spinBAV then spinBAV:Destroy(); spinBAV = nil end end
local function startAntiRagdoll()
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
    end) end
local function stopAntiRagdoll()
    if Connections.ar then Connections.ar:Disconnect(); Connections.ar = nil end end
local function startNoAnim()
    local c = Player.Character
    if not c then return end
    local hum = getHum()
    if hum then
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end
    end
    local anim = c:FindFirstChild("Animate")
    if anim then savedAnim = anim:Clone(); anim:Destroy() end end
local function stopNoAnim()
    local c = Player.Character
    if c and savedAnim then savedAnim:Clone().Parent = c; savedAnim = nil end end
local PL1 = Vector3.new(-476.48, -6.28, 92.73)
local PL2 = Vector3.new(-483.12, -4.95, 94.80)
local PR1 = Vector3.new(-476.16, -6.52, 25.62)
local PR2 = Vector3.new(-483.04, -5.09, 23.14)
local function startAutoLeft()
    if Connections.aL then Connections.aL:Disconnect() end
    leftPhase = 1
    Connections.aL = RunService.Heartbeat:Connect(function()
        if not Toggles.AutoLeft then return end
        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum then return end
        local tgt = leftPhase == 1 and PL1 or PL2
        local dist = (Vector3.new(tgt.X, hrp.Position.Y, tgt.Z) - hrp.Position).Magnitude
        if dist < 1.5 then
            if leftPhase == 1 then leftPhase = 2
            else
                hum:Move(Vector3.zero, false)
                hrp.AssemblyLinearVelocity = Vector3.zero
                Toggles.AutoLeft = false
                Connections.aL:Disconnect(); Connections.aL = nil
                return
            end
        end
        local d = (tgt - hrp.Position)
        local md = Vector3.new(d.X, 0, d.Z).Unit
        hum:Move(md, false)
        hrp.AssemblyLinearVelocity = Vector3.new(md.X * Config.Speed, hrp.AssemblyLinearVelocity.Y, md.Z * Config.Speed)
    end) end
local function stopAutoLeft()
    if Connections.aL then Connections.aL:Disconnect(); Connections.aL = nil end
    local h = getHum()
    if h then h:Move(Vector3.zero, false) end
    Toggles.AutoLeft = false end
local function startAutoRight()
    if Connections.aR then Connections.aR:Disconnect() end
    rightPhase = 1
    Connections.aR = RunService.Heartbeat:Connect(function()
        if not Toggles.AutoRight then return end
        local hrp = getHRP()
        local hum = getHum()
        if not hrp or not hum then return end
        local tgt = rightPhase == 1 and PR1 or PR2
        local dist = (Vector3.new(tgt.X, hrp.Position.Y, tgt.Z) - hrp.Position).Magnitude
        if dist < 1.5 then
            if rightPhase == 1 then rightPhase = 2
            else
                hum:Move(Vector3.zero, false)
                hrp.AssemblyLinearVelocity = Vector3.zero
                Toggles.AutoRight = false
                Connections.aR:Disconnect(); Connections.aR = nil
                return
            end
        end
        local d = (tgt - hrp.Position)
        local md = Vector3.new(d.X, 0, d.Z).Unit
        hum:Move(md, false)
        hrp.AssemblyLinearVelocity = Vector3.new(md.X * Config.Speed, hrp.AssemblyLinearVelocity.Y, md.Z * Config.Speed)
    end) end
local function stopAutoRight()
    if Connections.aR then Connections.aR:Disconnect(); Connections.aR = nil end
    local h = getHum()
    if h then h:Move(Vector3.zero, false) end
    Toggles.AutoRight = false end
local function findPrompt()
    local hrp = getHRP()
    if not hrp then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local np, nd = nil, math.huge
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlot(plot.Name) then continue end
        local pods = plot:FindFirstChild("AnimalPodiums")
        if not pods then continue end
        for _, pod in ipairs(pods:GetChildren()) do
            pcall(function()
                local base  = pod:FindFirstChild("Base")
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
    return np end
local function startInstantGrab()
    if Connections.grab then return end
    Connections.grab = RunService.Heartbeat:Connect(function()
        if not Toggles.InstantGrab then return end
        if tick() - lastGrab < 0.3 then return end
        local hum = getHum()
        if hum and hum.FloorMaterial == Enum.Material.Air then return end
        local p = findPrompt()
        if p and p.Parent then
            lastGrab = tick()
            pcall(function() fireproximityprompt(p) end)
        end
    end) end
local function stopInstantGrab()
    if Connections.grab then Connections.grab:Disconnect(); Connections.grab = nil end end
local function tpToBrainrot()
    local hrp = getHRP()
    if not hrp then return end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end
    local ok, S = pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        return {
            Sync   = require(rs:WaitForChild("Packages"):WaitForChild("Synchronizer")),
            Shared = require(rs:WaitForChild("Shared"):WaitForChild("Animals")),
        }
    end)
    if not ok then return end
    local best, bestVal = nil, -1
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlot(plot.Name) then continue end
        pcall(function()
            local ch   = S.Sync:Get(plot.Name); if not ch then return end
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
    if best then
        hrp.CFrame = CFrame.new(best:GetPivot().Position + Vector3.new(0, 5, 0))
    end end
local sg=Instance.new("ScreenGui")
sg.Name = "AlamHub"
sg.ResetOnSpawn=false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = Player:FindFirstChildOfClass("PlayerGui") or Player.PlayerGui
local BG   = Color3.fromRGB(10, 13, 20)
local CARD = Color3.fromRGB(18, 22, 32)
local BLUE = Color3.fromRGB(0, 180, 255)
local WHT  = Color3.fromRGB(255, 255, 255)
local GRY  = Color3.fromRGB(50, 65, 90)
local DGRY = Color3.fromRGB(22, 28, 42)
local function tw(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15), props):Play() end
local iconBtn=Instance.new("TextButton", sg)
iconBtn.Size=UDim2.new(0, 52, 0, 52)
iconBtn.Position=UDim2.new(0, 8, 0.38, 0)
iconBtn.BackgroundColor3=Color3.fromRGB(8, 12, 20)
iconBtn.Text="A"
iconBtn.TextColor3=BLUE
iconBtn.Font=Enum.Font.GothamBlack
iconBtn.TextSize=26
iconBtn.BorderSizePixel=0
iconBtn.ZIndex=100
Instance.new("UICorner", iconBtn).CornerRadius=UDim.new(0, 12)
Instance.new("UIStroke", iconBtn).Color = BLUE
local main=Instance.new("Frame", sg)
main.Size=UDim2.new(0, 360, 0, 560)
main.Position=UDim2.new(0.5, -180, 0.5, -280)
main.BackgroundColor3 = BG
main.BackgroundTransparency=0.05
main.BorderSizePixel=0
main.Active=true
main.Draggable=true
main.ClipsDescendants=true
main.ZIndex=10
Instance.new("UICorner", main).CornerRadius=UDim.new(0, 16)
Instance.new("UIStroke", main).Color = BLUE
local titleLbl=Instance.new("TextLabel", main)
titleLbl.Size=UDim2.new(1, 0, 0, 38)
titleLbl.BackgroundTransparency=1
titleLbl.Text="ALAM HUB"
titleLbl.TextColor3=BLUE
titleLbl.Font=Enum.Font.GothamBlack
titleLbl.TextSize=20
titleLbl.ZIndex=11
local divLine=Instance.new("Frame", main)
divLine.Size=UDim2.new(1, -20, 0, 1)
divLine.Position=UDim2.new(0, 10, 0, 38)
divLine.BackgroundColor3 = BLUE
divLine.BorderSizePixel=0
divLine.ZIndex=11
local tabBar=Instance.new("Frame", main)
tabBar.Size=UDim2.new(1, -16, 0, 34)
tabBar.Position=UDim2.new(0, 8, 0, 44)
tabBar.BackgroundColor3 = DGRY
tabBar.BorderSizePixel=0
tabBar.ZIndex=11
Instance.new("UICorner", tabBar).CornerRadius=UDim.new(0, 8)
local TABS = {"FEATURES", "KEYBINDS", "SETTINGS"}
local tabBtns = {}
local tabInd=Instance.new("Frame", tabBar)
tabInd.Size=UDim2.new(0, 116, 1, -4)
tabInd.Position=UDim2.new(0, 2, 0, 2)
tabInd.BackgroundColor3 = BLUE
tabInd.BorderSizePixel=0
tabInd.ZIndex=11
Instance.new("UICorner", tabInd).CornerRadius=UDim.new(0, 6)
for i, name in ipairs(TABS) do
    local btn=Instance.new("TextButton", tabBar)
    btn.Size=UDim2.new(0, 116, 1, 0)
    btn.Position=UDim2.new(0, (i - 1) * 118, 0, 0)
    btn.BackgroundTransparency=1
    btn.Text = name
    btn.TextColor3 = (name == "FEATURES") and WHT or GRY
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=10
    btn.ZIndex=12
    tabBtns[name] = btn end
local contentArea=Instance.new("Frame", main)
contentArea.Size=UDim2.new(1, -16, 1, -88)
contentArea.Position=UDim2.new(0, 8, 0, 84)
contentArea.BackgroundTransparency=1
contentArea.ZIndex=11
local function mkScroll()
    local p=Instance.new("ScrollingFrame", contentArea)
    p.Size=UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency=1
    p.BorderSizePixel=0
    p.ScrollBarThickness=3
    p.ScrollBarImageColor3 = BLUE
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.AutomaticCanvasSize=Enum.AutomaticSize.Y
    p.ZIndex=12
    p.Visible=false
    local layout=Instance.new("UIListLayout", p)
    layout.Padding=UDim.new(0, 3)
    layout.SortOrder=Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", p).PaddingBottom = UDim.new(0, 10)
    return p end
local featPanel = mkScroll(); featPanel.Visible=true
local kbPanel   = mkScroll()
local setPanel  = mkScroll()
local panels = {FEATURES = featPanel, KEYBINDS = kbPanel, SETTINGS = setPanel}
local function switchTab(name)
    for n, p in pairs(panels) do p.Visible = (n == name) end
    for n, b in pairs(tabBtns) do b.TextColor3 = (n == name) and WHT or GRY end
    local idx = 0
    for i, t in ipairs(TABS) do if t == name then idx = i - 1; break end end
    tw(tabInd, {Position = UDim2.new(0, 2 + idx * 118, 0, 2)}) end
for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end) end
local featOrder = 0
local function mkRow(label, tKey, onFn, offFn)
    featOrder = featOrder + 1
    local row=Instance.new("Frame", featPanel)
    row.Size=UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = CARD
    row.BackgroundTransparency=0.25
    row.BorderSizePixel=0
    row.ZIndex=13
    row.LayoutOrder = featOrder
    Instance.new("UICorner", row).CornerRadius=UDim.new(0, 8)
    local lbl=Instance.new("TextLabel", row)
    lbl.Size=UDim2.new(1, -58, 1, 0)
    lbl.Position=UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency=1
    lbl.Text = label
    lbl.TextColor3=WHT
    lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=13
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.ZIndex=14
    local tb=Instance.new("Frame", row)
    tb.Size=UDim2.new(0, 44, 0, 22)
    tb.Position=UDim2.new(1, -52, 0.5, -11)
    tb.BackgroundColor3=Color3.fromRGB(35, 45, 70)
    tb.BorderSizePixel=0
    tb.ZIndex=13
    Instance.new("UICorner", tb).CornerRadius=UDim.new(1, 0)
    local knob=Instance.new("Frame", tb)
    knob.Size=UDim2.new(0, 18, 0, 18)
    knob.Position=UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = WHT
    knob.BorderSizePixel=0
    knob.ZIndex=14
    Instance.new("UICorner", knob).CornerRadius=UDim.new(1, 0)
    local clk=Instance.new("TextButton", row)
    clk.Size=UDim2.new(1, 0, 1, 0)
    clk.BackgroundTransparency=1
    clk.Text=""
    clk.ZIndex=15
    local isOn = false
    local function sv(state)
        isOn = state
        Toggles[tKey] = isOn
        tw(tb, {BackgroundColor3 = isOn and BLUE or Color3.fromRGB(35, 45, 70)})
        tw(knob, {Position = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)})
        if isOn and onFn  then onFn()  end
        if not isOn and offFn then offFn() end
    end
    clk.MouseButton1Click:Connect(function() sv(not isOn) end) end
local function mkBtn(label, cb)
    featOrder = featOrder + 1
    local btn=Instance.new("TextButton", featPanel)
    btn.Size=UDim2.new(1, 0, 0, 46)
    btn.BackgroundColor3 = BLUE
    btn.BorderSizePixel=0
    btn.Text = label
    btn.TextColor3=Color3.fromRGB(5, 10, 20)
    btn.Font=Enum.Font.GothamBlack
    btn.TextSize=14
    btn.ZIndex=13
    btn.LayoutOrder = featOrder
    Instance.new("UICorner", btn).CornerRadius=UDim.new(0, 10)
    btn.MouseButton1Click:Connect(cb) end
local function mkSep()
    featOrder = featOrder + 1
    local s=Instance.new("Frame", featPanel)
    s.Size=UDim2.new(1, 0, 0, 1)
    s.BackgroundColor3=Color3.fromRGB(25, 35, 55)
    s.BorderSizePixel=0
    s.ZIndex=13
    s.LayoutOrder = featOrder end
mkRow("Auto Left",    "AutoLeft",    startAutoLeft,    stopAutoLeft)   mkSep()
mkRow("Auto Right",   "AutoRight",   startAutoRight,   stopAutoRight)  mkSep()
mkBtn("TP to Brainrot", tpToBrainrot)                                  mkSep()
mkRow("Float",        "Float",       startFloat,       stopFloat)      mkSep()
mkRow("Speed Boost",  "SpeedBoost",  nil,              nil)            mkSep()
mkRow("Speed Steal",  "SpeedSteal",  nil,              nil)            mkSep()
mkRow("Instant Grab", "InstantGrab", startInstantGrab, stopInstantGrab) mkSep()
mkRow("Bat Aimbot",   "BatAimbot",   startAimbot,      stopAimbot)    mkSep()
mkRow("Anti Ragdoll", "AntiRagdoll", startAntiRagdoll, stopAntiRagdoll) mkSep()
mkRow("No Animations","NoAnim",      startNoAnim,      stopNoAnim)    mkSep()
mkRow("Spinbot",      "Spinbot",     startSpinbot,     stopSpinbot)   mkSep()
mkBtn("TAUNT", function()
    local hum = getHum()
    if hum then hum:UnequipTools() end end)
local kbOrder = 0
local activeRebind = nil
local kbDisplays = {}
local function mkKbRow(label, kbKey)
    kbOrder = kbOrder + 1
    local row=Instance.new("Frame", kbPanel)
    row.Size=UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = CARD
    row.BackgroundTransparency=0.25
    row.BorderSizePixel=0
    row.ZIndex=13
    row.LayoutOrder = kbOrder
    Instance.new("UICorner", row).CornerRadius=UDim.new(0, 8)
    local kv = KB[kbKey]
    local badge=Instance.new("TextButton", row)
    badge.Size=UDim2.new(0, 42, 0, 42)
    badge.Position=UDim2.new(0, 3, 0.5, -21)
    badge.BackgroundColor3 = BLUE
    badge.BorderSizePixel=0
    badge.Text = kv and (kv == Enum.KeyCode.Unknown and "NONE" or kv.Name) or "?"
    badge.TextColor3=Color3.fromRGB(5, 10, 20)
    badge.Font=Enum.Font.GothamBlack
    badge.TextSize=11
    badge.ZIndex=14
    Instance.new("UICorner", badge).CornerRadius=UDim.new(0, 7)
    kbDisplays[kbKey] = badge
    local lbl=Instance.new("TextLabel", row)
    lbl.Size=UDim2.new(1, -56, 1, 0)
    lbl.Position=UDim2.new(0, 54, 0, 0)
    lbl.BackgroundTransparency=1
    lbl.Text = label
    lbl.TextColor3=WHT
    lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=13
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.ZIndex=14
    badge.MouseButton1Click:Connect(function()
        activeRebind = kbKey
        badge.Text="..."
        badge.BackgroundColor3=Color3.fromRGB(255, 200, 0)
    end)
    kbOrder = kbOrder + 1
    local sep=Instance.new("Frame", kbPanel)
    sep.Size=UDim2.new(1, 0, 0, 1)
    sep.BackgroundColor3=Color3.fromRGB(25, 35, 55)
    sep.BorderSizePixel=0
    sep.ZIndex=13
    sep.LayoutOrder = kbOrder end
mkKbRow("Auto Left",    "AutoLeft")
mkKbRow("Auto Right",   "AutoRight")
mkKbRow("Instant Grab", "InstantGrab")
mkKbRow("Bat Aimbot",   "BatAimbot")
mkKbRow("Float",        "Float")
mkKbRow("Speed Boost",  "SpeedBoost")
mkKbRow("Anti Ragdoll", "AntiRagdoll")
mkKbRow("No Anim",      "NoAnim")
mkKbRow("Spinbot",      "Spinbot")
mkKbRow("Ungrab",       "Ungrab")
mkKbRow("Toggle UI",    "ToggleUI")
local setOrder = 0
local function mkSetRow(label, cfgKey, min, max)
    setOrder = setOrder + 1
    local row=Instance.new("Frame", setPanel)
    row.Size=UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = CARD
    row.BackgroundTransparency=0.25
    row.BorderSizePixel=0
    row.ZIndex=13
    row.LayoutOrder = setOrder
    Instance.new("UICorner", row).CornerRadius=UDim.new(0, 8)
    local lbl=Instance.new("TextLabel", row)
    lbl.Size=UDim2.new(0.58, 0, 1, 0)
    lbl.Position=UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency=1
    lbl.Text = label
    lbl.TextColor3=WHT
    lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=13
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.ZIndex=14
    local vBox=Instance.new("TextButton", row)
    vBox.Size=UDim2.new(0, 78, 0, 32)
    vBox.Position=UDim2.new(1, -86, 0.5, -16)
    vBox.BackgroundColor3 = BLUE
    vBox.BorderSizePixel=0
    vBox.Text = tostring(Config[cfgKey])
    vBox.TextColor3=Color3.fromRGB(5, 10, 20)
    vBox.Font=Enum.Font.GothamBlack
    vBox.TextSize=14
    vBox.ZIndex=14
    Instance.new("UICorner", vBox).CornerRadius=UDim.new(0, 8)
    vBox.MouseButton1Click:Connect(function()
        local step = (max - min) / 10
        local cur = Config[cfgKey]
        local presets = {}
        for i = min, max, step do table.insert(presets, math.floor(i * 10) / 10) end
        local idx = 1
        for i, v in ipairs(presets) do if v == cur then idx = i; break end end
        idx = (idx % #presets) + 1
        Config[cfgKey] = presets[idx]
        vBox.Text = tostring(presets[idx])
        if cfgKey == "SpinSpeed" and spinBAV then
            spinBAV.AngularVelocity = Vector3.new(0, Config.SpinSpeed, 0)
        end
    end)
    setOrder = setOrder + 1
    local sep=Instance.new("Frame", setPanel)
    sep.Size=UDim2.new(1, 0, 0, 1)
    sep.BackgroundColor3=Color3.fromRGB(25, 35, 55)
    sep.BorderSizePixel=0
    sep.ZIndex=13
    sep.LayoutOrder = setOrder end
mkSetRow("Speed Boost",       "Speed",       0,  150)
mkSetRow("Speed While Steal", "StealSpeed",  0,  100)
mkSetRow("Aimbot Speed",      "AimbotSpeed", 10, 200)
mkSetRow("Spinbot Speed",     "SpinSpeed",   1,  200)
mkSetRow("Steal Radius",      "StealRadius", 5,  80)
setOrder = setOrder + 1
local resetBtn=Instance.new("TextButton", setPanel)
resetBtn.Size=UDim2.new(1, 0, 0, 44)
resetBtn.BackgroundColor3 = BLUE
resetBtn.BorderSizePixel=0
resetBtn.Text="RESET DEFAULTS"
resetBtn.TextColor3=Color3.fromRGB(5, 10, 20)
resetBtn.Font=Enum.Font.GothamBlack
resetBtn.TextSize=14
resetBtn.ZIndex=13
resetBtn.LayoutOrder = setOrder
Instance.new("UICorner", resetBtn).CornerRadius=UDim.new(0, 10)
resetBtn.MouseButton1Click:Connect(function()
    Config.Speed       = 60
    Config.StealSpeed  = 29
    Config.AimbotSpeed = 55
    Config.SpinSpeed   = 50
    Config.StealRadius = 25 end)
local rp=Instance.new("Frame", sg)
rp.Size=UDim2.new(0, 150, 0, 172)
rp.Position=UDim2.new(1, -160, 0.5, -86)
rp.BackgroundColor3=Color3.fromRGB(8, 12, 20)
rp.BorderSizePixel=0
rp.ZIndex=10
Instance.new("UICorner", rp).CornerRadius=UDim.new(0, 14)
Instance.new("UIStroke", rp).Color = BLUE
local rpTitle=Instance.new("TextLabel", rp)
rpTitle.Size=UDim2.new(1, 0, 0, 30)
rpTitle.BackgroundTransparency=1
rpTitle.Text="ALAM HUB"
rpTitle.TextColor3=BLUE
rpTitle.Font=Enum.Font.GothamBlack
rpTitle.TextSize=13
rpTitle.TextXAlignment=Enum.TextXAlignment.Center
rpTitle.ZIndex=11
local rpSub=Instance.new("TextLabel", rp)
rpSub.Size=UDim2.new(1, 0, 0, 14)
rpSub.Position=UDim2.new(0, 0, 0, 28)
rpSub.BackgroundTransparency=1
rpSub.Text="TP to Brainrot"
rpSub.TextColor3=GRY
rpSub.Font=Enum.Font.Gotham
rpSub.TextSize=10
rpSub.TextXAlignment=Enum.TextXAlignment.Center
rpSub.ZIndex=11
local function mkRPBtn(label, yp, cb)
    local btn=Instance.new("TextButton", rp)
    btn.Size=UDim2.new(1, -14, 0, 32)
    btn.Position=UDim2.new(0, 7, 0, yp)
    btn.BackgroundColor3=Color3.fromRGB(22, 28, 45)
    btn.BorderSizePixel=0
    btn.Text = label
    btn.TextColor3=GRY
    btn.Font=Enum.Font.GothamBold
    btn.TextSize=12
    btn.ZIndex=11
    Instance.new("UICorner", btn).CornerRadius=UDim.new(0, 8)
    btn.MouseButton1Click:Connect(cb) end
mkRPBtn("Left Side",  46, function()
    local h = getHRP(); if h then h.CFrame = CFrame.new(PL1) end end)
mkRPBtn("Right Side", 84, function()
    local h = getHRP(); if h then h.CFrame = CFrame.new(PR1) end end)
local autoLRon = false
local alrBtn=Instance.new("TextButton", rp)
alrBtn.Size=UDim2.new(1, -14, 0, 32)
alrBtn.Position=UDim2.new(0, 7, 0, 122)
alrBtn.BackgroundColor3=Color3.fromRGB(22, 28, 45)
alrBtn.BorderSizePixel=0
alrBtn.Font=Enum.Font.GothamBold
alrBtn.TextSize=12
alrBtn.ZIndex=11
Instance.new("UICorner", alrBtn).CornerRadius=UDim.new(0, 8)
local function updateALR()
    alrBtn.Text="Auto L/R: " .. (autoLRon and "ON" or "OFF")
    alrBtn.TextColor3 = autoLRon and BLUE or GRY end
updateALR()
alrBtn.MouseButton1Click:Connect(function()
    autoLRon = not autoLRon
    if autoLRon then
        Toggles.AutoLeft = true; startAutoLeft()
    else
        stopAutoLeft(); stopAutoRight()
    end
    updateALR() end)
iconBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    main.Visible = guiVisible
    rp.Visible = guiVisible end)
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if activeRebind then
        KB[activeRebind] = inp.KeyCode
        if kbDisplays[activeRebind] then
            kbDisplays[activeRebind].Text = inp.KeyCode == Enum.KeyCode.Unknown and "NONE" or inp.KeyCode.Name
            kbDisplays[activeRebind].BackgroundColor3 = BLUE
        end
        activeRebind = nil
        return
    end
    local k = inp.KeyCode
    if k == KB.ToggleUI    then guiVisible = not guiVisible; main.Visible = guiVisible; rp.Visible = guiVisible end -- mobile buttons stay visible
    if k == KB.AutoLeft    then Toggles.AutoLeft = not Toggles.AutoLeft; if Toggles.AutoLeft then startAutoLeft() else stopAutoLeft() end end
    if k == KB.AutoRight   then Toggles.AutoRight = not Toggles.AutoRight; if Toggles.AutoRight then startAutoRight() else stopAutoRight() end end
    if k == KB.InstantGrab then Toggles.InstantGrab = not Toggles.InstantGrab; if Toggles.InstantGrab then startInstantGrab() else stopInstantGrab() end end
    if k == KB.BatAimbot   then Toggles.BatAimbot = not Toggles.BatAimbot; if Toggles.BatAimbot then startAimbot() else stopAimbot() end end
    if k == KB.Float       then Toggles.Float = not Toggles.Float; if Toggles.Float then startFloat() else stopFloat() end end
    if k == KB.SpeedBoost  then Toggles.SpeedBoost = not Toggles.SpeedBoost end
    if k == KB.AntiRagdoll then Toggles.AntiRagdoll = not Toggles.AntiRagdoll; if Toggles.AntiRagdoll then startAntiRagdoll() else stopAntiRagdoll() end end
    if k == KB.NoAnim      then Toggles.NoAnim = not Toggles.NoAnim; if Toggles.NoAnim then startNoAnim() else stopNoAnim() end end
    if k == KB.Spinbot     then Toggles.Spinbot = not Toggles.Spinbot; if Toggles.Spinbot then startSpinbot() else stopSpinbot() end end
    if k == KB.Ungrab      then local hum = getHum(); if hum then hum:UnequipTools() end end end)
Player.CharacterAdded:Connect(function()
    task.wait(1)
    if Toggles.AntiRagdoll then stopAntiRagdoll(); task.wait(0.1); startAntiRagdoll() end
    if Toggles.BatAimbot   then stopAimbot();      task.wait(0.1); startAimbot()      end
    if Toggles.AutoLeft    then stopAutoLeft();     task.wait(0.1); startAutoLeft()    end
    if Toggles.AutoRight   then stopAutoRight();    task.wait(0.1); startAutoRight()   end
    if Toggles.Float       then startFloat()   end
    if Toggles.Spinbot     then startSpinbot() end
    if Toggles.InstantGrab then startInstantGrab() end end)
local function mkMobileBtn(parent, label, x, y, cb)
    local btn=Instance.new("TextButton", parent)
    btn.Size=UDim2.new(0, 70, 0, 70)
    btn.Position=UDim2.new(x, 0, y, 0)
    btn.BackgroundColor3=Color3.fromRGB(8, 25, 55)
    btn.BackgroundTransparency=0.1
    btn.Text = label
    btn.TextColor3=BLUE
    btn.Font=Enum.Font.GothamBlack
    btn.TextSize=11
    btn.TextWrapped=true
    btn.BorderSizePixel=0
    btn.ZIndex=200
    Instance.new("UICorner", btn).CornerRadius=UDim.new(1, 0)
    local st=Instance.new("UIStroke", btn); st.Color = BLUE; st.Thickness = 2
    local isOn = false
    btn.MouseButton1Click:Connect(function()
        if cb then cb() end
        isOn = not isOn
        tw(btn, {BackgroundColor3 = isOn and BLUE or Color3.fromRGB(8,25,55)})
        btn.TextColor3 = isOn and Color3.fromRGB(5,10,20) or BLUE
    end)
    return btn end
local mobFrame=Instance.new("Frame", sg)
mobFrame.Size=UDim2.new(1,0,1,0)
mobFrame.BackgroundTransparency=1
mobFrame.ZIndex=199
mkMobileBtn(mobFrame, "AUTO
PLAY", 0.01, 0.22, function() end)
mkMobileBtn(mobFrame, "PLASMA
LEFT",  0.01, 0.34, function()
    Toggles.AutoLeft = not Toggles.AutoLeft
    if Toggles.AutoLeft then startAutoLeft() else stopAutoLeft() end end)
mkMobileBtn(mobFrame, "PLASMA
RIGHT", 0.01, 0.46, function()
    Toggles.AutoRight = not Toggles.AutoRight
    if Toggles.AutoRight then startAutoRight() else stopAutoRight() end end)
mkMobileBtn(mobFrame, "FLOAT",       0.82, 0.18, function()
    Toggles.Float = not Toggles.Float
    if Toggles.Float then startFloat() else stopFloat() end end)
mkMobileBtn(mobFrame, "UNGRAB",      0.72, 0.30, function()
    local hum = getHum(); if hum then hum:UnequipTools() end end)
mkMobileBtn(mobFrame, "BAT
AIMBOT",0.84, 0.30, function()
    Toggles.BatAimbot = not Toggles.BatAimbot
    if Toggles.BatAimbot then startAimbot() else stopAimbot() end end)
mkMobileBtn(mobFrame, "TAUNT",       0.72, 0.42, function()
    local hum = getHum(); if hum then hum:UnequipTools() end end)
mkMobileBtn(mobFrame, "SPINBOT",     0.84, 0.42, function()
    Toggles.Spinbot = not Toggles.Spinbot
    if Toggles.Spinbot then startSpinbot() else stopSpinbot() end end)
print("[ALAM HUB] Loaded! discord.gg/U4XXCxKUm | U = Toggle")
