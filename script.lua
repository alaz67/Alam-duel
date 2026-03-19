-- ╔══════════════════════════════════════════════════════════════╗
-- ║              ⚔  ALAZ DUEL  ⚔                                ║
-- ║              Steal a Brainrot Edition                        ║
-- ║              discord.gg/U4XXCxKUm                            ║
-- ╚══════════════════════════════════════════════════════════════╝

repeat task.wait() until game:IsLoaded()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local HttpService      = game:GetService("HttpService")
local Player           = Players.LocalPlayer

-- ──────────────────────────────────────────────────────────────
-- CONFIG
-- ──────────────────────────────────────────────────────────────
local Config = {
    SpeedBoost    = 60.0,
    CarrySpeed    = 29.5,
    HopPower      = 50.0,
    Gravity       = 70.0,
    SpinSpeed     = 19.0,
    FOV           = 70.0,
    StealRadius   = 25,
}

local Toggles = {
    AutoTP        = false,
    AutoSteal     = false,
    StealSpeed    = false,
    Unwalk        = false,
    Aimbot        = false,
    AutoLeft      = false,
    AutoRight     = false,
    Float         = false,
    AntiRagdoll   = false,
}

-- Keybinds
local KEYS = {
    Menu      = Enum.KeyCode.U,
    Aimbot    = Enum.KeyCode.X,
    AutoLeft  = Enum.KeyCode.Z,
    AutoRight = Enum.KeyCode.C,
    Float     = Enum.KeyCode.T,
}

local guiVisible   = true
local settingsPanel = nil
local isStealing   = false
local lastSteal    = 0
local Connections  = {}
local spinBAV      = nil
local floatPlat    = nil
local floatConn    = nil
local floatAnchorY = nil
local savedAnims   = {}
local defaultGrav  = workspace.Gravity
local galaxyVF, galaxyAtt = nil, nil

-- ──────────────────────────────────────────────────────────────
-- HELPERS
-- ──────────────────────────────────────────────────────────────
local function getHRP()
    local c = Player.Character; return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = Player.Character; return c and c:FindFirstChildOfClass("Humanoid")
end
local function getMoveDir()
    local h = getHum(); return h and h.MoveDirection or Vector3.zero
end
local function isMyPlot(name)
    local plots = workspace:FindFirstChild("Plots"); if not plots then return false end
    local plot = plots:FindFirstChild(name); if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then local yb=sign:FindFirstChild("YourBase"); if yb and yb:IsA("BillboardGui") then return yb.Enabled end end
    return false
end

-- ──────────────────────────────────────────────────────────────
-- SPEED
-- ──────────────────────────────────────────────────────────────
RunService.Heartbeat:Connect(function()
    local hrp = getHRP(); if not hrp then return end
    local hum = getHum(); if not hum then return end
    local md = getMoveDir()
    if md.Magnitude > 0.1 and hum.FloorMaterial ~= Enum.Material.Air then
        local stealing = Player:GetAttribute("Stealing")
        local spd = (stealing and Toggles.StealSpeed) and Config.CarrySpeed or Config.SpeedBoost
        hrp.AssemblyLinearVelocity = Vector3.new(md.X*spd, hrp.AssemblyLinearVelocity.Y, md.Z*spd)
    end
end)

-- ──────────────────────────────────────────────────────────────
-- ANTI RAGDOLL
-- ──────────────────────────────────────────────────────────────
local function startAntiRagdoll()
    if Connections.antiRag then return end
    Connections.antiRag = RunService.Heartbeat:Connect(function()
        if not Toggles.AntiRagdoll then return end
        local char = Player.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum then
            local s = hum:GetState()
            if s==Enum.HumanoidStateType.Physics or s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                workspace.CurrentCamera.CameraSubject = hum
                if root then root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero end
            end
        end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled = true end
        end
    end)
end
local function stopAntiRagdoll()
    if Connections.antiRag then Connections.antiRag:Disconnect(); Connections.antiRag = nil end
end

-- ──────────────────────────────────────────────────────────────
-- GRAVITY
-- ──────────────────────────────────────────────────────────────
local function setupGravity()
    local hrp = getHRP(); if not hrp then return end
    if galaxyVF then galaxyVF:Destroy() end
    if galaxyAtt then galaxyAtt:Destroy() end
    galaxyAtt = Instance.new("Attachment"); galaxyAtt.Parent = hrp
    galaxyVF  = Instance.new("VectorForce"); galaxyVF.Attachment0 = galaxyAtt
    galaxyVF.ApplyAtCenterOfMass = true
    galaxyVF.RelativeTo = Enum.ActuatorRelativeTo.World
    galaxyVF.Force = Vector3.zero; galaxyVF.Parent = hrp
end
local function updateGravity()
    if not galaxyVF then return end
    local char = Player.Character; if not char then return end
    local mass = 0
    for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then mass += p:GetMass() end end
    local tg = defaultGrav * (Config.Gravity/100)
    galaxyVF.Force = Vector3.new(0, mass*(defaultGrav-tg)*0.95, 0)
end
RunService.Heartbeat:Connect(updateGravity)

-- ──────────────────────────────────────────────────────────────
-- UNWALK
-- ──────────────────────────────────────────────────────────────
local function startUnwalk()
    local char = Player.Character; if not char then return end
    local hum = getHum(); if hum then for _,t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    local anim = char:FindFirstChild("Animate")
    if anim then savedAnims.Animate = anim:Clone(); anim:Destroy() end
end
local function stopUnwalk()
    local char = Player.Character
    if char and savedAnims.Animate then savedAnims.Animate:Clone().Parent = char; savedAnims.Animate = nil end
end

-- ──────────────────────────────────────────────────────────────
-- FLOAT
-- ──────────────────────────────────────────────────────────────
local function startFloat()
    local hrp = getHRP(); if not hrp then return end
    floatAnchorY = hrp.Position.Y
    if floatConn then floatConn:Disconnect() end
    floatConn = RunService.Heartbeat:Connect(function()
        if not Toggles.Float then return end
        local h = getHRP(); if not h then return end
        h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, 0, h.AssemblyLinearVelocity.Z)
        if floatAnchorY and math.abs(h.Position.Y - floatAnchorY) > 1 then
            h.CFrame = CFrame.new(h.Position.X, floatAnchorY, h.Position.Z)
        end
    end)
end
local function stopFloat()
    if floatConn then floatConn:Disconnect(); floatConn = nil end
end

-- ──────────────────────────────────────────────────────────────
-- DROP ANIMAL
-- ──────────────────────────────────────────────────────────────
local function dropAnimal()
    local hum = getHum(); if hum then hum:UnequipTools() end
end

-- ──────────────────────────────────────────────────────────────
-- BAT AIMBOT
-- ──────────────────────────────────────────────────────────────
local function findEnemy()
    local hrp = getHRP(); if not hrp then return nil end
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
local function findBat()
    local char = Player.Character; if not char then return nil end
    local bp = Player:FindFirstChildOfClass("Backpack")
    for _, ch in ipairs(char:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end
    if bp then for _, ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
end
local function startAimbot()
    if Connections.aim then return end
    Connections.aim = RunService.Heartbeat:Connect(function()
        if not Toggles.Aimbot then return end
        local hrp = getHRP(); local hum = getHum(); if not hrp or not hum then return end
        local bat = findBat(); if bat and bat.Parent ~= Player.Character then hum:EquipTool(bat) end
        local t = findEnemy(); if not t then return end
        local flat = Vector3.new(t.Position.X-hrp.Position.X, 0, t.Position.Z-hrp.Position.Z)
        if flat.Magnitude > 1.5 then
            local md = flat.Unit
            hrp.AssemblyLinearVelocity = Vector3.new(md.X*55, hrp.AssemblyLinearVelocity.Y, md.Z*55)
        end
    end)
end
local function stopAimbot()
    if Connections.aim then Connections.aim:Disconnect(); Connections.aim = nil end
end

-- ──────────────────────────────────────────────────────────────
-- AUTO LEFT / RIGHT
-- ──────────────────────────────────────────────────────────────
local PL1=Vector3.new(-476.48,-6.28,92.73); local PL2=Vector3.new(-483.12,-4.95,94.80)
local PR1=Vector3.new(-476.16,-6.52,25.62); local PR2=Vector3.new(-483.04,-5.09,23.14)
local leftPhase=1; local rightPhase=1

local function startAutoLeft()
    if Connections.autoL then Connections.autoL:Disconnect() end; leftPhase=1
    Connections.autoL = RunService.Heartbeat:Connect(function()
        if not Toggles.AutoLeft then return end
        local hrp=getHRP(); local hum=getHum(); if not hrp or not hum then return end
        local tgt = leftPhase==1 and PL1 or PL2
        local dist = (Vector3.new(tgt.X,hrp.Position.Y,tgt.Z)-hrp.Position).Magnitude
        if dist < 1.5 then
            if leftPhase==1 then leftPhase=2
            else hum:Move(Vector3.zero,false); hrp.AssemblyLinearVelocity=Vector3.zero; Toggles.AutoLeft=false; Connections.autoL:Disconnect(); Connections.autoL=nil; return end
        end
        local d=(tgt-hrp.Position); local md=Vector3.new(d.X,0,d.Z).Unit
        hum:Move(md,false); hrp.AssemblyLinearVelocity=Vector3.new(md.X*Config.SpeedBoost,hrp.AssemblyLinearVelocity.Y,md.Z*Config.SpeedBoost)
    end)
end
local function stopAutoLeft()
    if Connections.autoL then Connections.autoL:Disconnect(); Connections.autoL=nil end
    local hum=getHum(); if hum then hum:Move(Vector3.zero,false) end
end

local function startAutoRight()
    if Connections.autoR then Connections.autoR:Disconnect() end; rightPhase=1
    Connections.autoR = RunService.Heartbeat:Connect(function()
        if not Toggles.AutoRight then return end
        local hrp=getHRP(); local hum=getHum(); if not hrp or not hum then return end
        local tgt = rightPhase==1 and PR1 or PR2
        local dist = (Vector3.new(tgt.X,hrp.Position.Y,tgt.Z)-hrp.Position).Magnitude
        if dist < 1.5 then
            if rightPhase==1 then rightPhase=2
            else hum:Move(Vector3.zero,false); hrp.AssemblyLinearVelocity=Vector3.zero; Toggles.AutoRight=false; Connections.autoR:Disconnect(); Connections.autoR=nil; return end
        end
        local d=(tgt-hrp.Position); local md=Vector3.new(d.X,0,d.Z).Unit
        hum:Move(md,false); hrp.AssemblyLinearVelocity=Vector3.new(md.X*Config.SpeedBoost,hrp.AssemblyLinearVelocity.Y,md.Z*Config.SpeedBoost)
    end)
end
local function stopAutoRight()
    if Connections.autoR then Connections.autoR:Disconnect(); Connections.autoR=nil end
    local hum=getHum(); if hum then hum:Move(Vector3.zero,false) end
end

-- ──────────────────────────────────────────────────────────────
-- AUTO STEAL
-- ──────────────────────────────────────────────────────────────
local function findNearestPrompt()
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
                                if ch:IsA("ProximityPrompt") then np=ch; nd=dist; break end
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
        local prompt = findNearestPrompt()
        if prompt and prompt.Parent then
            lastSteal = tick()
            pcall(function() fireproximityprompt(prompt) end)
        end
    end)
end
local function stopAutoSteal()
    if Connections.steal then Connections.steal:Disconnect(); Connections.steal = nil end
end

-- ──────────────────────────────────────────────────────────────
-- AUTO TP
-- ──────────────────────────────────────────────────────────────
local function tpToHighest()
    local plots = workspace:FindFirstChild("Plots"); if not plots then return end
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
            local ch = S.Sync:Get(plot.Name); if not ch then return end
            local list = ch:Get("AnimalList"); if not list then return end
            local pods = plot:FindFirstChild("AnimalPodiums"); if not pods then return end
            for slot, data in pairs(list) do
                if type(data)~="table" then continue end
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
        local hrp = getHRP(); if not hrp then return end
        hrp.CFrame = CFrame.new(best:GetPivot().Position + Vector3.new(0,5,0))
    end
end

-- ──────────────────────────────────────────────────────────────
-- SAVE / LOAD CONFIG
-- ──────────────────────────────────────────────────────────────
local function saveConfig()
    pcall(function()
        local data = {}
        for k,v in pairs(Config) do data[k]=v end
        for k,v in pairs(Toggles) do data["toggle_"..k]=v end
        data["key_Aimbot"]    = KEYS.Aimbot.Name
        data["key_AutoLeft"]  = KEYS.AutoLeft.Name
        data["key_AutoRight"] = KEYS.AutoRight.Name
        data["key_Float"]     = KEYS.Float.Name
        if writefile then writefile("AlazDuel_Config.json", HttpService:JSONEncode(data)) end
    end)
end

local function loadConfig()
    pcall(function()
        if not readfile or not isfile or not isfile("AlazDuel_Config.json") then return end
        local data = HttpService:JSONDecode(readfile("AlazDuel_Config.json"))
        for k,v in pairs(data) do
            if Config[k] ~= nil then Config[k] = v end
            local tk = k:match("^toggle_(.+)$")
            if tk and Toggles[tk] ~= nil then Toggles[tk] = v end
            if k == "key_Aimbot"    and Enum.KeyCode[v] then KEYS.Aimbot    = Enum.KeyCode[v] end
            if k == "key_AutoLeft"  and Enum.KeyCode[v] then KEYS.AutoLeft  = Enum.KeyCode[v] end
            if k == "key_AutoRight" and Enum.KeyCode[v] then KEYS.AutoRight = Enum.KeyCode[v] end
            if k == "key_Float"     and Enum.KeyCode[v] then KEYS.Float     = Enum.KeyCode[v] end
        end
    end)
end

pcall(loadConfig)

-- ──────────────────────────────────────────────────────────────
-- GUI
-- ──────────────────────────────────────────────────────────────
local sg = Instance.new("ScreenGui")
sg.Name="AlazDuel"; sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
sg.Parent=Player:FindFirstChildOfClass("PlayerGui") or Player.PlayerGui

local C = {
    bg      = Color3.fromRGB(30,30,30),
    card    = Color3.fromRGB(40,40,40),
    border  = Color3.fromRGB(200,120,50),
    text    = Color3.fromRGB(255,255,255),
    textDim = Color3.fromRGB(180,180,180),
    orange  = Color3.fromRGB(220,130,50),
    green   = Color3.fromRGB(80,200,100),
    red     = Color3.fromRGB(200,60,60),
    dark    = Color3.fromRGB(20,20,20),
    toggle  = Color3.fromRGB(220,130,50),
    toggleOff = Color3.fromRGB(80,80,80),
}

-- ══════════════════════════════════════════════════════════════
-- LEFT PANEL (Mini buttons like Nine Hub)
-- ══════════════════════════════════════════════════════════════
local leftPanel = Instance.new("Frame", sg)
leftPanel.Size = UDim2.new(0,140,0,220)
leftPanel.Position = UDim2.new(0,5,0.4,-110)
leftPanel.BackgroundTransparency = 1
leftPanel.ZIndex = 10

local leftList = Instance.new("UIListLayout", leftPanel)
leftList.Padding = UDim.new(0,5)
leftList.SortOrder = Enum.SortOrder.LayoutOrder

local lOrder = 0
local function nextLO() lOrder=lOrder+1; return lOrder end

local waitingKey = nil
local keyBtns = {}

local function mkLeftBtn(label, keybindKey, toggleKey, onCb, offCb)
    local row = Instance.new("Frame", leftPanel)
    row.Size = UDim2.new(1,0,0,38)
    row.BackgroundColor3 = C.card
    row.BackgroundTransparency = 0.2
    row.BorderSizePixel = 0
    row.ZIndex = 11
    row.LayoutOrder = nextLO()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    -- Label
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-55,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 12

    -- Keybind button
    local kbtn = Instance.new("TextButton", row)
    kbtn.Size = UDim2.new(0,30,0,22)
    kbtn.Position = UDim2.new(1,-50,0.5,-11)
    kbtn.BackgroundColor3 = C.dark
    kbtn.Text = KEYS[keybindKey] and "["..KEYS[keybindKey].Name.."]" or ""
    kbtn.TextColor3 = C.orange
    kbtn.Font = Enum.Font.GothamBold
    kbtn.TextSize = 9
    kbtn.BorderSizePixel = 0
    kbtn.ZIndex = 13
    Instance.new("UICorner", kbtn).CornerRadius = UDim.new(0,4)

    -- Toggle dot
    local dot = Instance.new("Frame", row)
    dot.Size = UDim2.new(0,10,0,10)
    dot.Position = UDim2.new(1,-14,0.5,-5)
    dot.BackgroundColor3 = C.toggleOff
    dot.BorderSizePixel = 0
    dot.ZIndex = 12
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    -- Settings icon
    local settings = Instance.new("TextButton", row)
    settings.Size = UDim2.new(0,16,0,16)
    settings.Position = UDim2.new(1,-33,0.5,-8)
    settings.BackgroundTransparency = 1
    settings.Text = "⚙"
    settings.TextColor3 = C.textDim
    settings.Font = Enum.Font.GothamBold
    settings.TextSize = 12
    settings.ZIndex = 13

    -- Click to toggle
    local clk = Instance.new("TextButton", row)
    clk.Size = UDim2.new(0.7,0,1,0)
    clk.BackgroundTransparency = 1
    clk.Text = ""; clk.ZIndex = 14

    local isOn = Toggles[toggleKey] or false
    if isOn then dot.BackgroundColor3 = C.toggle end

    local function update(state)
        isOn = state; Toggles[toggleKey] = isOn
        TweenService:Create(dot,TweenInfo.new(0.2),{BackgroundColor3=isOn and C.toggle or C.toggleOff}):Play()
        if isOn and onCb  then onCb()  end
        if not isOn and offCb then offCb() end
    end

    clk.MouseButton1Click:Connect(function() update(not isOn) end)

    -- Keybind click
    kbtn.MouseButton1Click:Connect(function()
        waitingKey = keybindKey
        kbtn.Text = "..."
        kbtn.TextColor3 = Color3.fromRGB(255,255,100)
    end)

    keyBtns[keybindKey] = kbtn
    return row
end

local function mkLeftAction(label, cb)
    local btn = Instance.new("TextButton", leftPanel)
    btn.Size = UDim2.new(1,0,0,32)
    btn.BackgroundColor3 = C.card
    btn.BackgroundTransparency = 0.2
    btn.Text = label
    btn.TextColor3 = C.orange
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.ZIndex = 11
    btn.LayoutOrder = nextLO()
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    btn.MouseButton1Click:Connect(cb)
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundTransparency=0}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundTransparency=0.2}):Play() end)
    return btn
end

-- MENU button
local menuBtn = Instance.new("TextButton", sg)
menuBtn.Size = UDim2.new(0,70,0,28)
menuBtn.Position = UDim2.new(0,5,0.4,-124)
menuBtn.BackgroundColor3 = C.card
menuBtn.BackgroundTransparency = 0.1
menuBtn.Text = "MENU [U]"
menuBtn.TextColor3 = C.orange
menuBtn.Font = Enum.Font.GothamBold
menuBtn.TextSize = 11
menuBtn.BorderSizePixel = 0
menuBtn.ZIndex = 12
Instance.new("UICorner", menuBtn).CornerRadius = UDim.new(0,6)
local mS = Instance.new("UIStroke", menuBtn); mS.Color = C.border; mS.Thickness = 1.5

menuBtn.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    leftPanel.Visible = guiVisible
    if settingsPanel then settingsPanel.Visible = false end
end)

-- Left panel buttons
mkLeftBtn("Aimbot",       "Aimbot",    "Aimbot",    startAimbot,    stopAimbot)
mkLeftBtn("Auto Left",    "AutoLeft",  "AutoLeft",  startAutoLeft,  stopAutoLeft)
mkLeftBtn("Auto Right",   "AutoRight", "AutoRight", startAutoRight, stopAutoRight)
mkLeftBtn("Float",        "Float",     "Float",     startFloat,     stopFloat)
mkLeftAction("TAUNT", function() end)
mkLeftAction("DROP", dropAnimal)

-- ══════════════════════════════════════════════════════════════
-- SETTINGS PANEL (Center panel like Nine Hub)
-- ══════════════════════════════════════════════════════════════
settingsPanel = Instance.new("Frame", sg)
settingsPanel.Name = "SettingsPanel"
settingsPanel.Size = UDim2.new(0,220,0,380)
settingsPanel.Position = UDim2.new(0.5,-110,0.5,-190)
settingsPanel.BackgroundColor3 = C.bg
settingsPanel.BackgroundTransparency = 0.05
settingsPanel.BorderSizePixel = 0
settingsPanel.Active = true
settingsPanel.Draggable = true
settingsPanel.ClipsDescendants = true
settingsPanel.ZIndex = 20
settingsPanel.Visible = false
Instance.new("UICorner", settingsPanel).CornerRadius = UDim.new(0,12)
local spS = Instance.new("UIStroke", settingsPanel); spS.Color = C.border; spS.Thickness = 2

-- Title
local spTitle = Instance.new("TextLabel", settingsPanel)
spTitle.Size = UDim2.new(1,0,0,40)
spTitle.BackgroundTransparency = 1
spTitle.Text = "Alaz Duel"
spTitle.TextColor3 = C.orange
spTitle.Font = Enum.Font.GothamBlack
spTitle.TextSize = 18
spTitle.TextXAlignment = Enum.TextXAlignment.Center
spTitle.ZIndex = 21

-- Divider
local div1 = Instance.new("Frame", settingsPanel)
div1.Size = UDim2.new(1,-20,0,2); div1.Position = UDim2.new(0,10,0,40)
div1.BackgroundColor3 = C.border; div1.BorderSizePixel = 0; div1.ZIndex = 21

-- Section label
local sectionLbl = Instance.new("TextLabel", settingsPanel)
sectionLbl.Size = UDim2.new(1,-20,0,20); sectionLbl.Position = UDim2.new(0,10,0,46)
sectionLbl.BackgroundTransparency = 1; sectionLbl.Text = "SETTINGS"
sectionLbl.TextColor3 = C.orange; sectionLbl.Font = Enum.Font.GothamBold
sectionLbl.TextSize = 11; sectionLbl.TextXAlignment = Enum.TextXAlignment.Center; sectionLbl.ZIndex = 21

-- Scroll
local spScroll = Instance.new("ScrollingFrame", settingsPanel)
spScroll.Size = UDim2.new(1,0,1,-70); spScroll.Position = UDim2.new(0,0,0,68)
spScroll.BackgroundTransparency = 1; spScroll.BorderSizePixel = 0
spScroll.ScrollBarThickness = 3; spScroll.ScrollBarImageColor3 = C.border
spScroll.CanvasSize = UDim2.new(0,0,0,0); spScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
spScroll.ZIndex = 21

local spList = Instance.new("UIListLayout", spScroll)
spList.Padding = UDim.new(0,3); spList.SortOrder = Enum.SortOrder.LayoutOrder
spList.HorizontalAlignment = Enum.HorizontalAlignment.Center
local spPad = Instance.new("UIPadding", spScroll)
spPad.PaddingLeft = UDim.new(0,10); spPad.PaddingRight = UDim.new(0,10)
spPad.PaddingTop = UDim.new(0,5); spPad.PaddingBottom = UDim.new(0,10)

local spOrder = 0
local function nextSO() spOrder=spOrder+1; return spOrder end

-- Toggle row in settings
local settingsToggles = {}
local function mkSettingsToggle(title, toggleKey, onCb, offCb)
    local row = Instance.new("Frame", spScroll)
    row.Size = UDim2.new(1,0,0,40)
    row.BackgroundColor3 = C.card
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0; row.ZIndex = 22; row.LayoutOrder = nextSO()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", row).Color = C.border

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-60,1,0); lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = title
    lbl.TextColor3 = C.text; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 23

    local defOn = Toggles[toggleKey] or false
    local tb = Instance.new("Frame", row)
    tb.Size = UDim2.new(0,44,0,22); tb.Position = UDim2.new(1,-52,0.5,-11)
    tb.BackgroundColor3 = defOn and C.toggle or C.toggleOff; tb.BorderSizePixel = 0; tb.ZIndex = 22
    Instance.new("UICorner", tb).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", tb)
    knob.Size = UDim2.new(0,17,0,17)
    knob.Position = defOn and UDim2.new(1,-20,0.5,-8.5) or UDim2.new(0,3,0.5,-8.5)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255); knob.BorderSizePixel = 0; knob.ZIndex = 23
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local clk = Instance.new("TextButton", row)
    clk.Size = UDim2.new(1,0,1,0); clk.BackgroundTransparency = 1; clk.Text = ""; clk.ZIndex = 24

    local isOn = defOn
    local function sv(state)
        isOn = state; Toggles[toggleKey] = isOn
        TweenService:Create(tb,TweenInfo.new(0.2),{BackgroundColor3=isOn and C.toggle or C.toggleOff}):Play()
        TweenService:Create(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back),{Position=isOn and UDim2.new(1,-20,0.5,-8.5) or UDim2.new(0,3,0.5,-8.5)}):Play()
        if isOn and onCb  then onCb()  end
        if not isOn and offCb then offCb() end
    end
    settingsToggles[toggleKey] = sv
    clk.MouseButton1Click:Connect(function() sv(not isOn) end)
end

-- Slider in settings
local function mkSettingsSlider(title, configKey, mn, mx)
    local cont = Instance.new("Frame", spScroll)
    cont.Size = UDim2.new(1,0,0,52)
    cont.BackgroundColor3 = C.card; cont.BackgroundTransparency = 0.3
    cont.BorderSizePixel = 0; cont.ZIndex = 22; cont.LayoutOrder = nextSO()
    Instance.new("UICorner", cont).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", cont).Color = C.border

    local tl = Instance.new("TextLabel", cont)
    tl.Size = UDim2.new(0.65,0,0,20); tl.Position = UDim2.new(0,12,0,4)
    tl.BackgroundTransparency = 1; tl.Text = title
    tl.TextColor3 = C.text; tl.Font = Enum.Font.GothamBold; tl.TextSize = 12
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 23

    local vl = Instance.new("TextLabel", cont)
    vl.Size = UDim2.new(0.3,0,0,20); vl.Position = UDim2.new(0.7,0,0,4)
    vl.BackgroundTransparency = 1; vl.Text = tostring(Config[configKey])
    vl.TextColor3 = C.orange; vl.Font = Enum.Font.GothamBold; vl.TextSize = 12
    vl.TextXAlignment = Enum.TextXAlignment.Right; vl.ZIndex = 23

    local track = Instance.new("Frame", cont)
    track.Size = UDim2.new(1,-20,0,5); track.Position = UDim2.new(0,10,0,34)
    track.BackgroundColor3 = Color3.fromRGB(60,60,60); track.BorderSizePixel = 0; track.ZIndex = 22
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local pct = (Config[configKey]-mn)/(mx-mn)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(pct,0,1,0); fill.BackgroundColor3 = C.orange
    fill.BorderSizePixel = 0; fill.ZIndex = 23
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local thumb = Instance.new("Frame", track)
    thumb.Size = UDim2.new(0,13,0,13); thumb.Position = UDim2.new(pct,-6.5,0.5,-6.5)
    thumb.BackgroundColor3 = Color3.fromRGB(255,255,255); thumb.BorderSizePixel = 0; thumb.ZIndex = 24
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1,0)

    local sBtn = Instance.new("TextButton", track)
    sBtn.Size = UDim2.new(1,0,4,0); sBtn.Position = UDim2.new(0,0,-1.5,0)
    sBtn.BackgroundTransparency = 1; sBtn.Text = ""; sBtn.ZIndex = 25

    local dragging = false
    local function upd(rel)
        rel = math.clamp(rel,0,1)
        fill.Size = UDim2.new(rel,0,1,0); thumb.Position = UDim2.new(rel,-6.5,0.5,-6.5)
        local val = math.floor((mn+(mx-mn)*rel)*10)/10
        vl.Text = tostring(val); Config[configKey] = val
        if configKey == "FOV" then pcall(function() workspace.CurrentCamera.FieldOfView = val end) end
    end
    sBtn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            upd((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X)
        end
    end)
end

local function mkSettingsAction(label, cb)
    local btn = Instance.new("TextButton", spScroll)
    btn.Size = UDim2.new(1,0,0,36)
    btn.BackgroundColor3 = C.card; btn.BackgroundTransparency = 0.2
    btn.Text = label; btn.TextColor3 = C.orange
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 13
    btn.BorderSizePixel = 0; btn.ZIndex = 22; btn.LayoutOrder = nextSO()
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", btn).Color = C.border
    btn.MouseButton1Click:Connect(cb)
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundTransparency=0}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundTransparency=0.2}):Play() end)
end

-- Populate settings panel
mkSettingsToggle("Auto TP",     "AutoTP",     tpToHighest,    function() end)
mkSettingsToggle("Auto Steal",  "AutoSteal",  startAutoSteal, stopAutoSteal)
mkSettingsToggle("Steal Speed", "StealSpeed", function() end, function() end)
mkSettingsSlider("Speed", "CarrySpeed", 0, 60)
mkSettingsToggle("Unwalk",      "Unwalk",     startUnwalk,    stopUnwalk)
mkSettingsToggle("Anti Ragdoll","AntiRagdoll",startAntiRagdoll,stopAntiRagdoll)
mkSettingsSlider("Speed Boost", "SpeedBoost", 0, 120)
mkSettingsSlider("Gravity",     "Gravity",    10, 150)
mkSettingsSlider("FOV",         "FOV",        40, 120)
mkSettingsAction("RESET BUTTONS", function()
    for k,v in pairs(Toggles) do Toggles[k] = false end
    stopAutoSteal(); stopAutoLeft(); stopAutoRight()
    stopAimbot(); stopFloat(); stopAntiRagdoll(); stopUnwalk()
end)
mkSettingsAction("SAVE CONFIG", saveConfig)

-- Settings button on left panel (gear icon)
local gearBtn = Instance.new("TextButton", sg)
gearBtn.Size = UDim2.new(0,28,0,28)
gearBtn.Position = UDim2.new(0,115,0.4,-124)
gearBtn.BackgroundColor3 = C.card; gearBtn.BackgroundTransparency = 0.1
gearBtn.Text = "⚙"; gearBtn.TextColor3 = C.orange
gearBtn.Font = Enum.Font.GothamBold; gearBtn.TextSize = 16
gearBtn.BorderSizePixel = 0; gearBtn.ZIndex = 12
Instance.new("UICorner", gearBtn).CornerRadius = UDim.new(0,6)
Instance.new("UIStroke", gearBtn).Color = C.border
gearBtn.MouseButton1Click:Connect(function()
    settingsPanel.Visible = not settingsPanel.Visible
end)

-- FPS + Ping display
local fpsLabel = Instance.new("TextLabel", sg)
fpsLabel.Size = UDim2.new(0,100,0,40)
fpsLabel.Position = UDim2.new(1,-110,0,10)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(80,255,120)
fpsLabel.Font = Enum.Font.GothamBold; fpsLabel.TextSize = 16
fpsLabel.ZIndex = 5

local frames = 0; local lastT = tick()
RunService.RenderStepped:Connect(function()
    frames += 1
    local now = tick()
    if now - lastT >= 1 then
        local fps = frames; frames = 0; lastT = now
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        fpsLabel.Text = "FPS: "..fps.."
Ping: "..ping
    end
end)

-- Speed indicator
local speedLabel = Instance.new("TextLabel", sg)
speedLabel.Size = UDim2.new(0,120,0,24)
speedLabel.Position = UDim2.new(0.5,-60,0,5)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = PINK or Color3.fromRGB(220,0,120)
speedLabel.Font = Enum.Font.GothamBold; speedLabel.TextSize = 14
speedLabel.ZIndex = 5

RunService.Heartbeat:Connect(function()
    local hrp = getHRP()
    if hrp then
        local vel = hrp.AssemblyLinearVelocity
        local spd = math.floor(Vector3.new(vel.X,0,vel.Z).Magnitude * 10) / 10
        speedLabel.Text = "Speed: "..spd
    end
end)

-- ──────────────────────────────────────────────────────────────
-- INPUT HANDLER
-- ──────────────────────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end

    -- Keybind rebinding
    if waitingKey then
        KEYS[waitingKey] = inp.KeyCode
        if keyBtns[waitingKey] then
            keyBtns[waitingKey].Text = "["..inp.KeyCode.Name.."]"
            keyBtns[waitingKey].TextColor3 = C.orange
        end
        waitingKey = nil; return
    end

    if inp.KeyCode == KEYS.Menu      then guiVisible=not guiVisible; leftPanel.Visible=guiVisible; if not guiVisible then settingsPanel.Visible=false end end
    if inp.KeyCode == KEYS.Aimbot    then Toggles.Aimbot=not Toggles.Aimbot; if Toggles.Aimbot then startAimbot() else stopAimbot() end end
    if inp.KeyCode == KEYS.AutoLeft  then Toggles.AutoLeft=not Toggles.AutoLeft; if Toggles.AutoLeft then startAutoLeft() else stopAutoLeft() end end
    if inp.KeyCode == KEYS.AutoRight then Toggles.AutoRight=not Toggles.AutoRight; if Toggles.AutoRight then startAutoRight() else stopAutoRight() end end
    if inp.KeyCode == KEYS.Float     then Toggles.Float=not Toggles.Float; if Toggles.Float then startFloat() else stopFloat() end end
end)

-- ──────────────────────────────────────────────────────────────
-- RESPAWN
-- ──────────────────────────────────────────────────────────────
task.spawn(function() task.wait(1); setupGravity() end)
Player.CharacterAdded:Connect(function()
    task.wait(1); setupGravity()
    if Toggles.Aimbot    then stopAimbot();    task.wait(0.1); startAimbot()    end
    if Toggles.AutoLeft  then stopAutoLeft();  task.wait(0.1); startAutoLeft()  end
    if Toggles.AutoRight then stopAutoRight(); task.wait(0.1); startAutoRight() end
    if Toggles.Float     then startFloat() end
    if Toggles.AntiRagdoll then startAntiRagdoll() end
    if Toggles.AutoSteal then startAutoSteal() end
end)

print("⚔ ALAZ DUEL Loaded! discord.gg/U4XXCxKUm")
