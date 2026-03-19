-- ALAZ DUEL | discord.gg/U4XXCxKUm
local ok, err = pcall(function()

repeat task.wait() until game:IsLoaded()
task.wait(2)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- Wait for character
if not Player.Character then Player.CharacterAdded:Wait() end
task.wait(1)

local function getHRP()
    local c = Player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = Player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local Cfg = { Speed=60, CarrySpeed=30, StealRadius=25 }
local T = { AutoSteal=false, Aimbot=false, AutoLeft=false, AutoRight=false, Float=false, StealSpeed=false, Unwalk=false }
local Conn = {}
local lastSteal = 0
local floatConn = nil
local floatY = nil
local guiVisible = true

-- Speed loop
RunService.Heartbeat:Connect(function()
    local hrp = getHRP(); local hum = getHum()
    if not hrp or not hum then return end
    local md = hum.MoveDirection
    if md.Magnitude < 0.1 then return end
    if hum.FloorMaterial == Enum.Material.Air then return end
    local s = (Player:GetAttribute("Stealing") and T.StealSpeed) and Cfg.CarrySpeed or Cfg.Speed
    hrp.AssemblyLinearVelocity = Vector3.new(md.X*s, hrp.AssemblyLinearVelocity.Y, md.Z*s)
end)

-- Float
local function startFloat()
    local hrp = getHRP(); if not hrp then return end
    floatY = hrp.Position.Y
    if floatConn then floatConn:Disconnect() end
    floatConn = RunService.Heartbeat:Connect(function()
        if not T.Float then return end
        local h = getHRP(); if not h then return end
        h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, 0, h.AssemblyLinearVelocity.Z)
        if floatY and math.abs(h.Position.Y - floatY) > 1 then
            h.CFrame = CFrame.new(h.Position.X, floatY, h.Position.Z)
        end
    end)
end
local function stopFloat()
    if floatConn then floatConn:Disconnect(); floatConn = nil end
end

-- Aimbot
local function startAimbot()
    if Conn.aim then return end
    Conn.aim = RunService.Heartbeat:Connect(function()
        if not T.Aimbot then return end
        local hrp = getHRP(); if not hrp then return end
        local best, bd = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local eh = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if eh and hum and hum.Health > 0 then
                    local d = (eh.Position - hrp.Position).Magnitude
                    if d < bd then bd = d; best = eh end
                end
            end
        end
        if not best then return end
        local flat = Vector3.new(best.Position.X - hrp.Position.X, 0, best.Position.Z - hrp.Position.Z)
        if flat.Magnitude > 1.5 then
            local md = flat.Unit
            hrp.AssemblyLinearVelocity = Vector3.new(md.X*55, hrp.AssemblyLinearVelocity.Y, md.Z*55)
        end
    end)
end
local function stopAimbot()
    if Conn.aim then Conn.aim:Disconnect(); Conn.aim = nil end
end

-- Auto Left/Right
local PL1=Vector3.new(-476.48,-6.28,92.73); local PL2=Vector3.new(-483.12,-4.95,94.80)
local PR1=Vector3.new(-476.16,-6.52,25.62); local PR2=Vector3.new(-483.04,-5.09,23.14)
local lP=1; local rP=1

local function startAutoLeft()
    if Conn.aL then Conn.aL:Disconnect() end; lP=1
    Conn.aL = RunService.Heartbeat:Connect(function()
        if not T.AutoLeft then return end
        local hrp=getHRP(); local hum=getHum(); if not hrp or not hum then return end
        local tgt=lP==1 and PL1 or PL2
        local dist=(Vector3.new(tgt.X,hrp.Position.Y,tgt.Z)-hrp.Position).Magnitude
        if dist<1.5 then
            if lP==1 then lP=2
            else hum:Move(Vector3.zero,false); hrp.AssemblyLinearVelocity=Vector3.zero; T.AutoLeft=false; Conn.aL:Disconnect(); Conn.aL=nil; return end
        end
        local d=(tgt-hrp.Position); local md=Vector3.new(d.X,0,d.Z).Unit
        hum:Move(md,false); hrp.AssemblyLinearVelocity=Vector3.new(md.X*Cfg.Speed,hrp.AssemblyLinearVelocity.Y,md.Z*Cfg.Speed)
    end)
end
local function stopAutoLeft()
    if Conn.aL then Conn.aL:Disconnect(); Conn.aL=nil end
    local h=getHum(); if h then h:Move(Vector3.zero,false) end
end

local function startAutoRight()
    if Conn.aR then Conn.aR:Disconnect() end; rP=1
    Conn.aR = RunService.Heartbeat:Connect(function()
        if not T.AutoRight then return end
        local hrp=getHRP(); local hum=getHum(); if not hrp or not hum then return end
        local tgt=rP==1 and PR1 or PR2
        local dist=(Vector3.new(tgt.X,hrp.Position.Y,tgt.Z)-hrp.Position).Magnitude
        if dist<1.5 then
            if rP==1 then rP=2
            else hum:Move(Vector3.zero,false); hrp.AssemblyLinearVelocity=Vector3.zero; T.AutoRight=false; Conn.aR:Disconnect(); Conn.aR=nil; return end
        end
        local d=(tgt-hrp.Position); local md=Vector3.new(d.X,0,d.Z).Unit
        hum:Move(md,false); hrp.AssemblyLinearVelocity=Vector3.new(md.X*Cfg.Speed,hrp.AssemblyLinearVelocity.Y,md.Z*Cfg.Speed)
    end)
end
local function stopAutoRight()
    if Conn.aR then Conn.aR:Disconnect(); Conn.aR=nil end
    local h=getHum(); if h then h:Move(Vector3.zero,false) end
end

-- Steal
local function isMyPlot(name)
    local plots=workspace:FindFirstChild("Plots"); if not plots then return false end
    local plot=plots:FindFirstChild(name); if not plot then return false end
    local sign=plot:FindFirstChild("PlotSign")
    if sign then local yb=sign:FindFirstChild("YourBase"); if yb and yb:IsA("BillboardGui") then return yb.Enabled end end
    return false
end

local function startAutoSteal()
    if Conn.steal then return end
    Conn.steal = RunService.Heartbeat:Connect(function()
        if not T.AutoSteal then return end
        if tick()-lastSteal < 0.3 then return end
        local hum=getHum()
        if hum and hum.FloorMaterial==Enum.Material.Air then return end
        local hrp=getHRP(); if not hrp then return end
        local plots=workspace:FindFirstChild("Plots"); if not plots then return end
        local np,nd=nil,math.huge
        for _,plot in ipairs(plots:GetChildren()) do
            if isMyPlot(plot.Name) then continue end
            local pods=plot:FindFirstChild("AnimalPodiums"); if not pods then continue end
            for _,pod in ipairs(pods:GetChildren()) do
                pcall(function()
                    local base=pod:FindFirstChild("Base")
                    local spawn=base and base:FindFirstChild("Spawn")
                    if spawn then
                        local dist=(spawn.Position-hrp.Position).Magnitude
                        if dist<nd and dist<=Cfg.StealRadius then
                            local att=spawn:FindFirstChild("PromptAttachment")
                            if att then
                                for _,ch in ipairs(att:GetChildren()) do
                                    if ch:IsA("ProximityPrompt") then np=ch; nd=dist; break end
                                end
                            end
                        end
                    end
                end)
            end
        end
        if np and np.Parent then
            lastSteal=tick()
            pcall(function() fireproximityprompt(np) end)
        end
    end)
end
local function stopAutoSteal()
    if Conn.steal then Conn.steal:Disconnect(); Conn.steal=nil end
end

-- Unwalk
local savedAnim=nil
local function startUnwalk()
    local c=Player.Character; if not c then return end
    local hum=getHum(); if hum then for _,t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    local a=c:FindFirstChild("Animate"); if a then savedAnim=a:Clone(); a:Destroy() end
end
local function stopUnwalk()
    local c=Player.Character
    if c and savedAnim then savedAnim:Clone().Parent=c; savedAnim=nil end
end

-- Drop
local function dropAnimal()
    local h=getHum(); if h then h:UnequipTools() end
end

-- GUI
local sg=Instance.new("ScreenGui")
sg.Name="AlazDuel"; sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
sg.Parent=Player:FindFirstChildOfClass("PlayerGui") or Player.PlayerGui

local BG=Color3.fromRGB(28,28,28)
local CARD=Color3.fromRGB(38,38,38)
local ORG=Color3.fromRGB(220,130,50)
local WHT=Color3.fromRGB(255,255,255)
local GRY=Color3.fromRGB(80,80,80)
local DRK=Color3.fromRGB(15,15,15)

-- MENU BTN
local menuBtn=Instance.new("TextButton",sg)
menuBtn.Size=UDim2.new(0,72,0,28); menuBtn.Position=UDim2.new(0,5,0.38,-14)
menuBtn.BackgroundColor3=CARD; menuBtn.Text="MENU [U]"
menuBtn.TextColor3=ORG; menuBtn.Font=Enum.Font.GothamBold; menuBtn.TextSize=11
menuBtn.BorderSizePixel=0; menuBtn.ZIndex=20
Instance.new("UICorner",menuBtn).CornerRadius=UDim.new(0,6)
Instance.new("UIStroke",menuBtn).Color=ORG

-- GEAR BTN
local gearBtn=Instance.new("TextButton",sg)
gearBtn.Size=UDim2.new(0,26,0,26); gearBtn.Position=UDim2.new(0,120,0.38,-13)
gearBtn.BackgroundColor3=CARD; gearBtn.Text="⚙"
gearBtn.TextColor3=ORG; gearBtn.Font=Enum.Font.GothamBold; gearBtn.TextSize=15
gearBtn.BorderSizePixel=0; gearBtn.ZIndex=20
Instance.new("UICorner",gearBtn).CornerRadius=UDim.new(0,6)
Instance.new("UIStroke",gearBtn).Color=ORG

-- LEFT PANEL
local lPanel=Instance.new("Frame",sg)
lPanel.Size=UDim2.new(0,145,0,10); lPanel.Position=UDim2.new(0,5,0.38,18)
lPanel.BackgroundTransparency=1; lPanel.ZIndex=20; lPanel.AutomaticSize=Enum.AutomaticSize.Y
local lList=Instance.new("UIListLayout",lPanel)
lList.Padding=UDim.new(0,4); lList.SortOrder=Enum.SortOrder.LayoutOrder

local lO=0; local function nLO() lO=lO+1; return lO end
local activeKB=nil; local kbBtns={}

local function mkRow(label,kbName,tKey,onFn,offFn)
    local row=Instance.new("Frame",lPanel)
    row.Size=UDim2.new(1,0,0,36); row.BackgroundColor3=CARD
    row.BackgroundTransparency=0.15; row.BorderSizePixel=0
    row.ZIndex=21; row.LayoutOrder=nLO()
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)

    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-70,1,0); lbl.Position=UDim2.new(0,8,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label
    lbl.TextColor3=WHT; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=22

    local kb=Instance.new("TextButton",row)
    kb.Size=UDim2.new(0,36,0,22); kb.Position=UDim2.new(1,-66,0.5,-11)
    kb.BackgroundColor3=DRK; kb.Text="["..kbName.."]"
    kb.TextColor3=ORG; kb.Font=Enum.Font.GothamBold; kb.TextSize=9
    kb.BorderSizePixel=0; kb.ZIndex=22
    Instance.new("UICorner",kb).CornerRadius=UDim.new(0,4)
    kbBtns[tKey]={btn=kb,name=kbName}

    local dot=Instance.new("Frame",row)
    dot.Size=UDim2.new(0,10,0,10); dot.Position=UDim2.new(1,-14,0.5,-5)
    dot.BackgroundColor3=GRY; dot.BorderSizePixel=0; dot.ZIndex=22
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)

    local clk=Instance.new("TextButton",row)
    clk.Size=UDim2.new(0.65,0,1,0); clk.BackgroundTransparency=1; clk.Text=""; clk.ZIndex=23

    local isOn=false
    local function toggle(s)
        isOn=s; T[tKey]=isOn
        TweenService:Create(dot,TweenInfo.new(0.2),{BackgroundColor3=isOn and ORG or GRY}):Play()
        if isOn and onFn then onFn() end
        if not isOn and offFn then offFn() end
    end
    clk.MouseButton1Click:Connect(function() toggle(not isOn) end)
    kb.MouseButton1Click:Connect(function()
        activeKB=tKey; kb.Text="..."; kb.TextColor3=Color3.fromRGB(255,255,0)
    end)
end

local function mkAction(label,cb)
    local btn=Instance.new("TextButton",lPanel)
    btn.Size=UDim2.new(1,0,0,30); btn.BackgroundColor3=CARD
    btn.BackgroundTransparency=0.15; btn.Text=label
    btn.TextColor3=ORG; btn.Font=Enum.Font.GothamBold; btn.TextSize=12
    btn.BorderSizePixel=0; btn.ZIndex=21; btn.LayoutOrder=nLO()
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7)
    btn.MouseButton1Click:Connect(cb)
end

mkRow("Aimbot",    "X","Aimbot",    startAimbot,    stopAimbot)
mkRow("Auto Left", "Z","AutoLeft",  startAutoLeft,  stopAutoLeft)
mkRow("Auto Right","C","AutoRight", startAutoRight, stopAutoRight)
mkRow("Float",     "T","Float",     startFloat,     stopFloat)
mkAction("TAUNT", function() end)
mkAction("DROP",  dropAnimal)

-- SETTINGS PANEL
local sPanel=Instance.new("Frame",sg)
sPanel.Name="Settings"; sPanel.Size=UDim2.new(0,210,0,370)
sPanel.Position=UDim2.new(0.5,-105,0.5,-185)
sPanel.BackgroundColor3=BG; sPanel.BackgroundTransparency=0.05
sPanel.BorderSizePixel=0; sPanel.Active=true; sPanel.Draggable=true
sPanel.ClipsDescendants=true; sPanel.ZIndex=30; sPanel.Visible=false
Instance.new("UICorner",sPanel).CornerRadius=UDim.new(0,12)
Instance.new("UIStroke",sPanel).Color=ORG

local stitle=Instance.new("TextLabel",sPanel)
stitle.Size=UDim2.new(1,0,0,38); stitle.BackgroundTransparency=1
stitle.Text="Alaz Duel"; stitle.TextColor3=ORG
stitle.Font=Enum.Font.GothamBlack; stitle.TextSize=17
stitle.TextXAlignment=Enum.TextXAlignment.Center; stitle.ZIndex=31

local sdiv=Instance.new("Frame",sPanel)
sdiv.Size=UDim2.new(1,-20,0,1); sdiv.Position=UDim2.new(0,10,0,38)
sdiv.BackgroundColor3=ORG; sdiv.BorderSizePixel=0; sdiv.ZIndex=31

local ssub=Instance.new("TextLabel",sPanel)
ssub.Size=UDim2.new(1,0,0,18); ssub.Position=UDim2.new(0,0,0,42)
ssub.BackgroundTransparency=1; ssub.Text="SETTINGS"
ssub.TextColor3=ORG; ssub.Font=Enum.Font.GothamBold
ssub.TextSize=10; ssub.TextXAlignment=Enum.TextXAlignment.Center; ssub.ZIndex=31

local sScroll=Instance.new("ScrollingFrame",sPanel)
sScroll.Size=UDim2.new(1,0,1,-63); sScroll.Position=UDim2.new(0,0,0,63)
sScroll.BackgroundTransparency=1; sScroll.BorderSizePixel=0
sScroll.ScrollBarThickness=3; sScroll.ScrollBarImageColor3=ORG
sScroll.CanvasSize=UDim2.new(0,0,0,0); sScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
sScroll.ZIndex=31

local sList=Instance.new("UIListLayout",sScroll)
sList.Padding=UDim.new(0,4); sList.SortOrder=Enum.SortOrder.LayoutOrder
sList.HorizontalAlignment=Enum.HorizontalAlignment.Center
local sPad=Instance.new("UIPadding",sScroll)
sPad.PaddingLeft=UDim.new(0,8); sPad.PaddingRight=UDim.new(0,8)
sPad.PaddingTop=UDim.new(0,4); sPad.PaddingBottom=UDim.new(0,8)

local sO=0; local function nSO() sO=sO+1; return sO end

local function mkSToggle(title,tKey,onFn,offFn)
    local row=Instance.new("Frame",sScroll)
    row.Size=UDim2.new(1,0,0,38); row.BackgroundColor3=CARD
    row.BackgroundTransparency=0.3; row.BorderSizePixel=0
    row.ZIndex=32; row.LayoutOrder=nSO()
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",row).Color=ORG

    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-55,1,0); lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=title
    lbl.TextColor3=WHT; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=13
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=33

    local tb=Instance.new("Frame",row)
    tb.Size=UDim2.new(0,42,0,20); tb.Position=UDim2.new(1,-50,0.5,-10)
    tb.BackgroundColor3=GRY; tb.BorderSizePixel=0; tb.ZIndex=32
    Instance.new("UICorner",tb).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame",tb)
    knob.Size=UDim2.new(0,15,0,15); knob.Position=UDim2.new(0,3,0.5,-7.5)
    knob.BackgroundColor3=WHT; knob.BorderSizePixel=0; knob.ZIndex=33
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local clk=Instance.new("TextButton",row)
    clk.Size=UDim2.new(1,0,1,0); clk.BackgroundTransparency=1; clk.Text=""; clk.ZIndex=34

    local isOn=false
    local function sv(s)
        isOn=s; T[tKey]=isOn
        TweenService:Create(tb,TweenInfo.new(0.2),{BackgroundColor3=isOn and ORG or GRY}):Play()
        TweenService:Create(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back),{Position=isOn and UDim2.new(1,-18,0.5,-7.5) or UDim2.new(0,3,0.5,-7.5)}):Play()
        if isOn and onFn then onFn() end
        if not isOn and offFn then offFn() end
    end
    clk.MouseButton1Click:Connect(function() sv(not isOn) end)
end

local function mkSSlider(title,cfgKey,mn,mx)
    local cont=Instance.new("Frame",sScroll)
    cont.Size=UDim2.new(1,0,0,50); cont.BackgroundColor3=CARD
    cont.BackgroundTransparency=0.3; cont.BorderSizePixel=0
    cont.ZIndex=32; cont.LayoutOrder=nSO()
    Instance.new("UICorner",cont).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",cont).Color=ORG

    local tl=Instance.new("TextLabel",cont)
    tl.Size=UDim2.new(0.65,0,0,20); tl.Position=UDim2.new(0,10,0,4)
    tl.BackgroundTransparency=1; tl.Text=title
    tl.TextColor3=WHT; tl.Font=Enum.Font.GothamBold; tl.TextSize=12
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=33

    local vl=Instance.new("TextLabel",cont)
    vl.Size=UDim2.new(0.3,0,0,20); vl.Position=UDim2.new(0.7,0,0,4)
    vl.BackgroundTransparency=1; vl.Text=tostring(Cfg[cfgKey])
    vl.TextColor3=ORG; vl.Font=Enum.Font.GothamBold; vl.TextSize=12
    vl.TextXAlignment=Enum.TextXAlignment.Right; vl.ZIndex=33

    local track=Instance.new("Frame",cont)
    track.Size=UDim2.new(1,-16,0,5); track.Position=UDim2.new(0,8,0,32)
    track.BackgroundColor3=Color3.fromRGB(55,55,55); track.BorderSizePixel=0; track.ZIndex=32
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local pct=(Cfg[cfgKey]-mn)/(mx-mn)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=ORG
    fill.BorderSizePixel=0; fill.ZIndex=33
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local thumb=Instance.new("Frame",track)
    thumb.Size=UDim2.new(0,12,0,12); thumb.Position=UDim2.new(pct,-6,0.5,-6)
    thumb.BackgroundColor3=WHT; thumb.BorderSizePixel=0; thumb.ZIndex=34
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)

    local sBtn=Instance.new("TextButton",track)
    sBtn.Size=UDim2.new(1,0,4,0); sBtn.Position=UDim2.new(0,0,-1.5,0)
    sBtn.BackgroundTransparency=1; sBtn.Text=""; sBtn.ZIndex=35

    local dragging=false
    local function upd(rel)
        rel=math.clamp(rel,0,1)
        fill.Size=UDim2.new(rel,0,1,0); thumb.Position=UDim2.new(rel,-6,0.5,-6)
        local val=math.floor((mn+(mx-mn)*rel)*10)/10
        vl.Text=tostring(val); Cfg[cfgKey]=val
    end
    sBtn.MouseButton1Down:Connect(function() dragging=true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            upd((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X)
        end
    end)
end

local function mkSAction(label,cb)
    local btn=Instance.new("TextButton",sScroll)
    btn.Size=UDim2.new(1,0,0,34); btn.BackgroundColor3=CARD
    btn.BackgroundTransparency=0.2; btn.Text=label
    btn.TextColor3=ORG; btn.Font=Enum.Font.GothamBold; btn.TextSize=13
    btn.BorderSizePixel=0; btn.ZIndex=32; btn.LayoutOrder=nSO()
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",btn).Color=ORG
    btn.MouseButton1Click:Connect(cb)
end

mkSToggle("Auto Steal",   "AutoSteal",  startAutoSteal, stopAutoSteal)
mkSToggle("Steal Speed",  "StealSpeed", function() end, function() end)
mkSSlider("Carry Speed",  "CarrySpeed", 0,  60)
mkSToggle("Unwalk",       "Unwalk",     startUnwalk,    stopUnwalk)
mkSSlider("Speed Boost",  "Speed",      0,  120)
mkSSlider("Steal Radius", "StealRadius",5,  80)
mkSAction("RESET BUTTONS", function()
    for k in pairs(T) do T[k]=false end
    stopAutoSteal(); stopAutoLeft(); stopAutoRight()
    stopAimbot(); stopFloat(); stopUnwalk()
end)
mkSAction("SAVE CONFIG", function()
    pcall(function()
        if writefile then
            writefile("AlazDuel.json", game:GetService("HttpService"):JSONEncode(Cfg))
        end
    end)
end)

-- FPS Label
local fpsLbl=Instance.new("TextLabel",sg)
fpsLbl.Size=UDim2.new(0,90,0,40); fpsLbl.Position=UDim2.new(1,-100,0,8)
fpsLbl.BackgroundTransparency=1; fpsLbl.TextColor3=Color3.fromRGB(80,255,120)
fpsLbl.Font=Enum.Font.GothamBold; fpsLbl.TextSize=15; fpsLbl.ZIndex=5
local frames=0; local lastT=tick()
RunService.RenderStepped:Connect(function()
    frames+=1
    if tick()-lastT>=1 then
        local fps=frames; frames=0; lastT=tick()
        local ok2,ping=pcall(function() return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        fpsLbl.Text="FPS: "..fps.."
Ping: "..(ok2 and ping or "?")
    end
end)

-- Buttons
menuBtn.MouseButton1Click:Connect(function()
    guiVisible=not guiVisible; lPanel.Visible=guiVisible
    if not guiVisible then sPanel.Visible=false end
end)
gearBtn.MouseButton1Click:Connect(function()
    sPanel.Visible=not sPanel.Visible
end)

UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if activeKB then
        if kbBtns[activeKB] then
            kbBtns[activeKB].btn.Text="["..inp.KeyCode.Name.."]"
            kbBtns[activeKB].btn.TextColor3=ORG
        end
        activeKB=nil; return
    end
    if inp.KeyCode==Enum.KeyCode.U then
        guiVisible=not guiVisible; lPanel.Visible=guiVisible
        if not guiVisible then sPanel.Visible=false end
    end
    if inp.KeyCode==Enum.KeyCode.X then T.Aimbot=not T.Aimbot; if T.Aimbot then startAimbot() else stopAimbot() end end
    if inp.KeyCode==Enum.KeyCode.Z then T.AutoLeft=not T.AutoLeft; if T.AutoLeft then startAutoLeft() else stopAutoLeft() end end
    if inp.KeyCode==Enum.KeyCode.C then T.AutoRight=not T.AutoRight; if T.AutoRight then startAutoRight() else stopAutoRight() end end
    if inp.KeyCode==Enum.KeyCode.T then T.Float=not T.Float; if T.Float then startFloat() else stopFloat() end end
end)

Player.CharacterAdded:Connect(function()
    task.wait(1)
    if T.Aimbot then stopAimbot(); task.wait(0.1); startAimbot() end
    if T.AutoLeft then stopAutoLeft(); task.wait(0.1); startAutoLeft() end
    if T.AutoRight then stopAutoRight(); task.wait(0.1); startAutoRight() end
    if T.Float then startFloat() end
    if T.AutoSteal then startAutoSteal() end
end)

print("[Alaz Duel] Loaded! discord.gg/U4XXCxKUm")

end)
if not ok then warn("[Alaz Duel] Error: "..tostring(err)) end
