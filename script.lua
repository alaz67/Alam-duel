     
-- CONTENT AREA
local contentArea = Instance.new("Frame", main)
contentArea.Size = UDim2.new(1, -16, 1, -88)
contentArea.Position = UDim2.new(0, 8, 0, 84)
contentArea.BackgroundTransparency = 1
contentArea.ZIndex = 11

local function mkScroll()
    local p = Instance.new("ScrollingFrame", contentArea)
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = BLUE
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.ZIndex = 12
    p.Visible = false
    local layout = Instance.new("UIListLayout", p)
    layout.Padding = UDim.new(0, 3)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", p).PaddingBottom = UDim.new(0, 10)
    return p
end

local featPanel = mkScroll(); featPanel.Visible = true
local kbPanel   = mkScroll()
local setPanel  = mkScroll()

local panels = {FEATURES = featPanel, KEYBINDS = kbPanel, SETTINGS = setPanel}

local function switchTab(name)
    for n, p in pairs(panels) do p.Visible = (n == name) end
    for n, b in pairs(tabBtns) do b.TextColor3 = (n == name) and WHT or GRY end
    local idx = 0
    for i, t in ipairs(TABS) do if t == name then idx = i - 1; break end end
    tw(tabInd, {Position = UDim2.new(0, 2 + idx * 118, 0, 2)})
end

for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

-- FEATURE ROW FACTORY
local featOrder = 0

local function mkRow(label, tKey, onFn, offFn)
    featOrder = featOrder + 1
    local row = Instance.new("Frame", featPanel)
    row.Size = UDim2.new(1, 0, 0, 42)
    row.BackgroundColor3 = CARD
    row.BackgroundTransparency = 0.25
    row.BorderSizePixel = 0
    row.ZIndex = 13
    row.LayoutOrder = featOrder
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -58, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = WHT
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 14

    local tb = Instance.new("Frame", row)
    tb.Size = UDim2.new(0, 44, 0, 22)
    tb.Position = UDim2.new(1, -52, 0.5, -11)
    tb.BackgroundColor3 = Color3.fromRGB(35, 45, 70)
    tb.BorderSizePixel = 0
    tb.ZIndex = 13
    Instance.new("UICorner", tb).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", tb)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = WHT
    knob.BorderSizePixel = 0
    knob.ZIndex = 14
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local clk = Instance.new("TextButton", row)
    clk.Size = UDim2.new(1, 0, 1, 0)
    clk.BackgroundTransparency = 1
    clk.Text = ""
    clk.ZIndex = 15

    local isOn = false
    local function sv(state)
        isOn = state
        Toggles[tKey] = isOn
        tw(tb, {BackgroundColor3 = isOn and BLUE or Color3.fromRGB(35, 45, 70)})
        tw(knob, {Position = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)})
        if isOn and onFn  then onFn()  end
        if not isOn and offFn then offFn() end
    end
    clk.MouseButton1Click:Connect(function() sv(not isOn) end)
end

local function mkBtn(label, cb)
    featOrder = featOrder + 1
    local btn = Instance.new("TextButton", featPanel)
    btn.Size = UDim2.new(1, 0, 0, 46)
    btn.BackgroundColor3 = BLUE
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(5, 10, 20)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    btn.ZIndex = 13
    btn.LayoutOrder = featOrder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(cb)
end

local function mkSep()
    featOrder = featOrder + 1
    local s = Instance.new("Frame", featPanel)
    s.Size = UDim2.new(1, 0, 0, 1)
    s.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    s.BorderSizePixel = 0
    s.ZIndex = 13
    s.LayoutOrder = featOrder
end

-- POPULATE FEATURES
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
    if hum then hum:UnequipTools() end
end)

-- KEYBINDS TAB
local kbOrder = 0
local activeRebind = nil
local kbDisplays = {}

local function mkKbRow(label, kbKey)
    kbOrder = kbOrder + 1
    local row = Instance.new("Frame", kbPanel)
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = CARD
    row.BackgroundTransparency = 0.25
    row.BorderSizePixel = 0
    row.ZIndex = 13
    row.LayoutOrder = kbOrder
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local kv = KB[kbKey]
    local badge = Instance.new("TextButton", row)
    badge.Size = UDim2.new(0, 42, 0, 42)
    badge.Position = UDim2.new(0, 3, 0.5, -21)
    badge.BackgroundColor3 = BLUE
    badge.BorderSizePixel = 0
    badge.Text = kv and (kv == Enum.KeyCode.Unknown and "NONE" or kv.Name) or "?"
    badge.TextColor3 = Color3.fromRGB(5, 10, 20)
    badge.Font = Enum.Font.GothamBlack
    badge.TextSize = 11
    badge.ZIndex = 14
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 7)
    kbDisplays[kbKey] = badge

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -56, 1, 0)
    lbl.Position = UDim2.new(0, 54, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = WHT
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 14

    badge.MouseButton1Click:Connect(function()
        activeRebind = kbKey
        badge.Text = "..."
        badge.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    end)

    kbOrder = kbOrder + 1
    local sep = Instance.new("Frame", kbPanel)
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    sep.BorderSizePixel = 0
    sep.ZIndex = 13
    sep.LayoutOrder = kbOrder
end

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

-- SETTINGS TAB
local setOrder = 0

local function mkSetRow(label, cfgKey, min, max)
    setOrder = setOrder + 1
    local row = Instance.new("Frame", setPanel)
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundColor3 = CARD
    row.BackgroundTransparency = 0.25
    row.BorderSizePixel = 0
    row.ZIndex = 13
    row.LayoutOrder = setOrder
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.58, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = WHT
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 14

    local vBox = Instance.new("TextButton", row)
    vBox.Size = UDim2.new(0, 78, 0, 32)
    vBox.Position = UDim2.new(1, -86, 0.5, -16)
    vBox.BackgroundColor3 = BLUE
    vBox.BorderSizePixel = 0
    vBox.Text = tostring(Config[cfgKey])
    vBox.TextColor3 = Color3.fromRGB(5, 10, 20)
    vBox.Font = Enum.Font.GothamBlack
    vBox.TextSize = 14
    vBox.ZIndex = 14
    Instance.new("UICorner", vBox).CornerRadius = UDim.new(0, 8)

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
    local sep = Instance.new("Frame", setPanel)
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    sep.BorderSizePixel = 0
    sep.ZIndex = 13
    sep.LayoutOrder = setOrder
end

mkSetRow("Speed Boost",       "Speed",       0,  150)
mkSetRow("Speed While Steal", "StealSpeed",  0,  100)
mkSetRow("Aimbot Speed",      "AimbotSpeed", 10, 200)
mkSetRow("Spinbot Speed",     "SpinSpeed",   1,  200)
mkSetRow("Steal Radius",      "StealRadius", 5,  80)

setOrder = setOrder + 1
local resetBtn = Instance.new("TextButton", setPanel)
resetBtn.Size = UDim2.new(1, 0, 0, 44)
resetBtn.BackgroundColor3 = BLUE
resetBtn.BorderSizePixel = 0
resetBtn.Text = "RESET DEFAULTS"
resetBtn.TextColor3 = Color3.fromRGB(5, 10, 20)
resetBtn.Font = Enum.Font.GothamBlack
resetBtn.TextSize = 14
resetBtn.ZIndex = 13
resetBtn.LayoutOrder = setOrder
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 10)
resetBtn.MouseButton1Click:Connect(function()
    Config.Speed       = 60
    Config.StealSpeed  = 29
    Config.AimbotSpeed = 55
    Config.SpinSpeed   = 50
    Config.StealRadius = 25
end)

-- RIGHT MINI PANEL
local rp = Instance.new("Frame", sg)
rp.Size = UDim2.new(0, 150, 0, 172)
rp.Position = UDim2.new(1, -160, 0.5, -86)
rp.BackgroundColor3 = Color3.fromRGB(8, 12, 20)
rp.BorderSizePixel = 0
rp.ZIndex = 10
Instance.new("UICorner", rp).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", rp).Color = BLUE

local rpTitle = Instance.new("TextLabel", rp)
rpTitle.Size = UDim2.new(1, 0, 0, 30)
rpTitle.BackgroundTransparency = 1
rpTitle.Text = "ALAM HUB"
rpTitle.TextColor3 = BLUE
rpTitle.Font = Enum.Font.GothamBlack
rpTitle.TextSize = 13
rpTitle.TextXAlignment = Enum.TextXAlignment.Center
rpTitle.ZIndex = 11

local rpSub = Instance.new("TextLabel", rp)
rpSub.Size = UDim2.new(1, 0, 0, 14)
rpSub.Position = UDim2.new(0, 0, 0, 28)
rpSub.BackgroundTransparency = 1
rpSub.Text = "TP to Brainrot"
rpSub.TextColor3 = GRY
rpSub.Font = Enum.Font.Gotham
rpSub.TextSize = 10
rpSub.TextXAlignment = Enum.TextXAlignment.Center
rpSub.ZIndex = 11

local function mkRPBtn(label, yp, cb)
    local btn = Instance.new("TextButton", rp)
    btn.Size = UDim2.new(1, -14, 0, 32)
    btn.Position = UDim2.new(0, 7, 0, yp)
    btn.BackgroundColor3 = Color3.fromRGB(22, 28, 45)
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = GRY
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.ZIndex = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(cb)
end

mkRPBtn("Left Side",  46, function()
    local h = getHRP(); if h then h.CFrame = CFrame.new(PL1) end
end)
mkRPBtn("Right Side", 84, function()
    local h = getHRP(); if h then h.CFrame = CFrame.new(PR1) end
end)

local autoLRon = false
local alrBtn = Instance.new("TextButton", rp)
alrBtn.Size = UDim2.new(1, -14, 0, 32)
alrBtn.Position = UDim2.new(0, 7, 0, 122)
alrBtn.BackgroundColor3 = Color3.fromRGB(22, 28, 45)
alrBtn.BorderSizePixel = 0
alrBtn.Font = Enum.Font.GothamBold
alrBtn.TextSize = 12
alrBtn.ZIndex = 11
Instance.new("UICorner", alrBtn).CornerRadius = UDim.new(0, 8)

local function updateALR()
    alrBtn.Text = "Auto L/R: " .. (autoLRon and "ON" or "OFF")
    alrBtn.TextColor3 = autoLRon and BLUE or GRY
end
updateALR()

alrBtn.MouseButton1Click:Connect(function()
    autoLRon = not autoLRon
    if autoLRon then
        Toggles.AutoLeft = true; startAutoLeft()
    else
        stopAutoLeft(); stopAutoRight()
    end
    updateALR()
end)


-- Make all panels draggable
makeDraggable(rp)
makeDraggable(iconBtn)

-- TOGGLE GUI (nur großes Fenster, kleines bleibt!)
iconBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    main.Visible = guiVisible
    -- rp (kleines Fenster rechts) bleibt IMMER sichtbar
end)

-- INPUT HANDLER
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
    if k == KB.ToggleUI    then guiVisible = not guiVisible; main.Visible = guiVisible end
    if k == KB.AutoLeft    then Toggles.AutoLeft = not Toggles.AutoLeft; if Toggles.AutoLeft then startAutoLeft() else stopAutoLeft() end end
    if k == KB.AutoRight   then Toggles.AutoRight = not Toggles.AutoRight; if Toggles.AutoRight then startAutoRight() else stopAutoRight() end end
    if k == KB.InstantGrab then Toggles.InstantGrab = not Toggles.InstantGrab; if Toggles.InstantGrab then startInstantGrab() else stopInstantGrab() end end
    if k == KB.BatAimbot   then Toggles.BatAimbot = not Toggles.BatAimbot; if Toggles.BatAimbot then startAimbot() else stopAimbot() end end
    if k == KB.Float       then Toggles.Float = not Toggles.Float; if Toggles.Float then startFloat() else stopFloat() end end
    if k == KB.SpeedBoost  then Toggles.SpeedBoost = not Toggles.SpeedBoost end
    if k == KB.AntiRagdoll then Toggles.AntiRagdoll = not Toggles.AntiRagdoll; if Toggles.AntiRagdoll then startAntiRagdoll() else stopAntiRagdoll() end end
    if k == KB.NoAnim      then Toggles.NoAnim = not Toggles.NoAnim; if Toggles.NoAnim then startNoAnim() else stopNoAnim() end end
    if k == KB.Spinbot     then Toggles.Spinbot = not Toggles.Spinbot; if Toggles.Spinbot then startSpinbot() else stopSpinbot() end end
    if k == KB.Ungrab      then local hum = getHum(); if hum then hum:UnequipTools() end end
end)

-- RESPAWN
Player.CharacterAdded:Connect(function()
    task.wait(1)
    if Toggles.AntiRagdoll then stopAntiRagdoll(); task.wait(0.1); startAntiRagdoll() end
    if Toggles.BatAimbot   then stopAimbot();      task.wait(0.1); startAimbot()      end
    if Toggles.AutoLeft    then stopAutoLeft();     task.wait(0.1); startAutoLeft()    end
    if Toggles.AutoRight   then stopAutoRight();    task.wait(0.1); startAutoRight()   end
    if Toggles.Float       then startFloat()   end
    if Toggles.Spinbot     then startSpinbot() end
    if Toggles.InstantGrab then startInstantGrab() end
end)

print("[ALAM HUB] Loaded! discord.gg/U4XXCxKUm | U = Toggle")
