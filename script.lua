-- ╔════════════════════════════════════╗
-- ║  ALAM HUB | discord.gg/U4XXCxKUm  ║
-- ╚════════════════════════════════════╝
repeat task.wait() until game:IsLoaded()
local Pl=game:GetService("Players").LocalPlayer
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
if not Pl.Character then Pl.CharacterAdded:Wait() end
task.wait(0.5)
local Cfg={Speed=60,StealSpeed=29,AimbotSpeed=55,SpinSpeed=50,StealRadius=25}
local T={AutoLeft=false,AutoRight=false,Float=false,BatAimbot=false,Spinbot=false,InstantGrab=false,SpeedBoost=false,SpeedSteal=false,AntiRagdoll=false,NoAnim=false}
local KB={AutoLeft=Enum.KeyCode.Q,AutoRight=Enum.KeyCode.E,InstantGrab=Enum.KeyCode.V,BatAimbot=Enum.KeyCode.Z,Float=Enum.KeyCode.F,SpeedBoost=Enum.KeyCode.B,AntiRagdoll=Enum.KeyCode.X,NoAnim=Enum.KeyCode.N,Spinbot=Enum.KeyCode.T,Ungrab=Enum.KeyCode.C,ToggleUI=Enum.KeyCode.U}
local C={};local floatY,floatConn,spinBAV,savedAnim=nil,nil,nil,nil;local lastGrab=0;local lP,rP=1,1;local guiVisible=true
local function getH()local c=Pl.Character;return c and c:FindFirstChild("HumanoidRootPart")end
local function getHum()local c=Pl.Character;return c and c:FindFirstChildOfClass("Humanoid")end
local PL1=Vector3.new(-476.48,-6.28,92.73);local PL2=Vector3.new(-483.12,-4.95,94.80)
local PR1=Vector3.new(-476.16,-6.52,25.62);local PR2=Vector3.new(-483.04,-5.09,23.14)
local function isMyPlot(n)
    local plots=workspace:FindFirstChild("Plots");if not plots then return false end
    local plot=plots:FindFirstChild(n);if not plot then return false end
    local sign=plot:FindFirstChild("PlotSign")
    if sign then local yb=sign:FindFirstChild("YourBase");if yb and yb:IsA("BillboardGui")then return yb.Enabled end end
    return false
end
RS.Heartbeat:Connect(function()
    local hrp=getH();local hum=getHum();if not hrp or not hum then return end
    local md=hum.MoveDirection;if md.Magnitude<0.1 or hum.FloorMaterial==Enum.Material.Air then return end
    local spd=(Pl:GetAttribute("Stealing")and T.SpeedSteal)and Cfg.StealSpeed or(T.SpeedBoost and Cfg.Speed or nil)
    if spd then hrp.AssemblyLinearVelocity=Vector3.new(md.X*spd,hrp.AssemblyLinearVelocity.Y,md.Z*spd)end
end)
local function startFloat()
    local hrp=getH();if not hrp then return end;floatY=hrp.Position.Y
    if floatConn then floatConn:Disconnect()end
    floatConn=RS.Heartbeat:Connect(function()
        if not T.Float then return end;local h=getH();if not h then return end
        h.AssemblyLinearVelocity=Vector3.new(h.AssemblyLinearVelocity.X,0,h.AssemblyLinearVelocity.Z)
        if floatY and math.abs(h.Position.Y-floatY)>0.5 then h.CFrame=CFrame.new(h.Position.X,floatY,h.Position.Z)end
    end)
end
local function stopFloat()if floatConn then floatConn:Disconnect();floatConn=nil end end
local function startAimbot()
    if C.aim then return end
    C.aim=RS.Heartbeat:Connect(function()
        if not T.BatAimbot then return end
        local hrp=getH();if not hrp then return end
        local best,bd=nil,math.huge
        for _,p in ipairs(game:GetService("Players"):GetPlayers())do
            if p~=Pl and p.Character then
                local eh=p.Character:FindFirstChild("HumanoidRootPart")
                local h2=p.Character:FindFirstChildOfClass("Humanoid")
                if eh and h2 and h2.Health>0 then local d=(eh.Position-hrp.Position).Magnitude;if d<bd then bd=d;best=eh end end
            end
        end
        if not best then return end
        local f=Vector3.new(best.Position.X-hrp.Position.X,0,best.Position.Z-hrp.Position.Z)
        if f.Magnitude>1 then local m=f.Unit;hrp.AssemblyLinearVelocity=Vector3.new(m.X*Cfg.AimbotSpeed,hrp.AssemblyLinearVelocity.Y,m.Z*Cfg.AimbotSpeed)end
    end)
end
local function stopAimbot()if C.aim then C.aim:Disconnect();C.aim=nil end end
local function startSpin()
    local hrp=getH();if not hrp then return end
    if spinBAV then spinBAV:Destroy()end
    spinBAV=Instance.new("BodyAngularVelocity");spinBAV.MaxTorque=Vector3.new(0,math.huge,0)
    spinBAV.AngularVelocity=Vector3.new(0,Cfg.SpinSpeed,0);spinBAV.Parent=hrp
end
local function stopSpin()if spinBAV then spinBAV:Destroy();spinBAV=nil end end
local function startAntiRag()
    if C.ar then return end
    C.ar=RS.Heartbeat:Connect(function()
        if not T.AntiRagdoll then return end
        local c=Pl.Character;if not c then return end
        local hum=c:FindFirstChildOfClass("Humanoid");local hrp=c:FindFirstChild("HumanoidRootPart")
        if hum then local s=hum:GetState();if s==Enum.HumanoidStateType.Physics or s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.FallingDown then hum:ChangeState(Enum.HumanoidStateType.Running);if hrp then hrp.AssemblyLinearVelocity=Vector3.zero end end end
    end)
end
local function stopAntiRag()if C.ar then C.ar:Disconnect();C.ar=nil end end
local function startNoAnim()
    local c=Pl.Character;if not c then return end
    local hum=getHum();if hum then for _,t in ipairs(hum:GetPlayingAnimationTracks())do t:Stop(0)end end
    local a=c:FindFirstChild("Animate");if a then savedAnim=a:Clone();a:Destroy()end
end
local function stopNoAnim()local c=Pl.Character;if c and savedAnim then savedAnim:Clone().Parent=c;savedAnim=nil end end
local function startAutoLeft()
    if C.aL then C.aL:Disconnect()end;lP=1
    C.aL=RS.Heartbeat:Connect(function()
        if not T.AutoLeft then return end
        local hrp=getH();local hum=getHum();if not hrp or not hum then return end
        local tgt=lP==1 and PL1 or PL2;local dist=(Vector3.new(tgt.X,hrp.Position.Y,tgt.Z)-hrp.Position).Magnitude
        if dist<1.5 then if lP==1 then lP=2 else hum:Move(Vector3.zero,false);hrp.AssemblyLinearVelocity=Vector3.zero;T.AutoLeft=false;C.aL:Disconnect();C.aL=nil;return end end
        local d=(tgt-hrp.Position);local m=Vector3.new(d.X,0,d.Z).Unit
        hum:Move(m,false);hrp.AssemblyLinearVelocity=Vector3.new(m.X*Cfg.Speed,hrp.AssemblyLinearVelocity.Y,m.Z*Cfg.Speed)
    end)
end
local function stopAutoLeft()if C.aL then C.aL:Disconnect();C.aL=nil end;local h=getHum();if h then h:Move(Vector3.zero,false)end;T.AutoLeft=false end
local function startAutoRight()
    if C.aR then C.aR:Disconnect()end;rP=1
    C.aR=RS.Heartbeat:Connect(function()
        if not T.AutoRight then return end
        local hrp=getH();local hum=getHum();if not hrp or not hum then return end
        local tgt=rP==1 and PR1 or PR2;local dist=(Vector3.new(tgt.X,hrp.Position.Y,tgt.Z)-hrp.Position).Magnitude
        if dist<1.5 then if rP==1 then rP=2 else hum:Move(Vector3.zero,false);hrp.AssemblyLinearVelocity=Vector3.zero;T.AutoRight=false;C.aR:Disconnect();C.aR=nil;return end end
        local d=(tgt-hrp.Position);local m=Vector3.new(d.X,0,d.Z).Unit
        hum:Move(m,false);hrp.AssemblyLinearVelocity=Vector3.new(m.X*Cfg.Speed,hrp.AssemblyLinearVelocity.Y,m.Z*Cfg.Speed)
    end)
end
local function stopAutoRight()if C.aR then C.aR:Disconnect();C.aR=nil end;local h=getHum();if h then h:Move(Vector3.zero,false)end;T.AutoRight=false end
local function findPrompt()
    local hrp=getH();if not hrp then return nil end
    local plots=workspace:FindFirstChild("Plots");if not plots then return nil end
    local np,nd=nil,math.huge
    for _,plot in ipairs(plots:GetChildren())do
        if isMyPlot(plot.Name)then continue end
        local pods=plot:FindFirstChild("AnimalPodiums");if not pods then continue end
        for _,pod in ipairs(pods:GetChildren())do
            pcall(function()
                local base=pod:FindFirstChild("Base");local spawn=base and base:FindFirstChild("Spawn")
                if spawn then local dist=(spawn.Position-hrp.Position).Magnitude
                    if dist<nd and dist<=Cfg.StealRadius then
                        local att=spawn:FindFirstChild("PromptAttachment")
                        if att then for _,ch in ipairs(att:GetChildren())do if ch:IsA("ProximityPrompt")then np=ch;nd=dist;break end end end
                    end
                end
            end)
        end
    end
    return np
end
local function startGrab()
    if C.grab then return end
    C.grab=RS.Heartbeat:Connect(function()
        if not T.InstantGrab then return end;if tick()-lastGrab<0.3 then return end
        local hum=getHum();if hum and hum.FloorMaterial==Enum.Material.Air then return end
        local p=findPrompt();if p and p.Parent then lastGrab=tick();pcall(function()fireproximityprompt(p)end)end
    end)
end
local function stopGrab()if C.grab then C.grab:Disconnect();C.grab=nil end end
local function tpToBrainrot()
    local hrp=getH();if not hrp then return end
    local plots=workspace:FindFirstChild("Plots");if not plots then return end
    local ok,S=pcall(function()local rs=game:GetService("ReplicatedStorage");return{Sync=require(rs:WaitForChild("Packages"):WaitForChild("Synchronizer")),Shared=require(rs:WaitForChild("Shared"):WaitForChild("Animals"))}end)
    if not ok then return end
    local best,bestVal=nil,-1
    for _,plot in ipairs(plots:GetChildren())do
        if isMyPlot(plot.Name)then continue end
        pcall(function()
            local ch=S.Sync:Get(plot.Name);if not ch then return end
            local list=ch:Get("AnimalList");if not list then return end
            local pods=plot:FindFirstChild("AnimalPodiums");if not pods then return end
            for slot,data in pairs(list)do
                if type(data)~="table"then continue end
                local val=S.Shared:GetGeneration(data.Index,data.Mutation,data.Traits,nil)or 0
                if val>bestVal then bestVal=val;local pod=pods:FindFirstChild(tostring(slot));if pod then best=pod end end
            end
        end)
    end
    if best then hrp.CFrame=CFrame.new(best:GetPivot().Position+Vector3.new(0,5,0))end
end
-- GUI
local sg=Instance.new("ScreenGui");sg.Name="AlamHub";sg.ResetOnSpawn=false;sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;sg.Parent=Pl:FindFirstChildOfClass("PlayerGui")or Pl.PlayerGui
local BG=Color3.fromRGB(10,13,20);local CARD=Color3.fromRGB(18,22,32);local BLUE=Color3.fromRGB(0,180,255);local WHT=Color3.fromRGB(255,255,255);local GRY=Color3.fromRGB(50,65,90);local DGRY=Color3.fromRGB(22,28,42)
local function tw(o,p,t)TS:Create(o,TweenInfo.new(t or 0.15),p):Play()end
local function newEl(cls,props,par)local e=Instance.new(cls);for k,v in pairs(props)do e[k]=v end;if par then e.Parent=par end;return e end
local function corner(r,p)return newEl("UICorner",{CornerRadius=UDim.new(0,r or 8)},p)end
local function stroke(c,t,p)return newEl("UIStroke",{Color=c,Thickness=t or 1.5},p)end
local iconBtn=newEl("TextButton",{Size=UDim2.new(0,52,0,52),Position=UDim2.new(0,8,0.38,0),BackgroundColor3=Color3.fromRGB(8,12,20),Text="A",TextColor3=BLUE,Font=Enum.Font.GothamBlack,TextSize=26,BorderSizePixel=0,ZIndex=100},sg)
corner(12,iconBtn);stroke(BLUE,2,iconBtn)
local main=newEl("Frame",{Size=UDim2.new(0,360,0,560),Position=UDim2.new(0.5,-180,0.5,-280),BackgroundColor3=BG,BackgroundTransparency=0.05,BorderSizePixel=0,Active=true,Draggable=true,ClipsDescendants=true,ZIndex=10},sg)
corner(16,main);stroke(BLUE,2,main)
newEl("TextLabel",{Size=UDim2.new(1,0,0,38),BackgroundTransparency=1,Text="ALAM HUB",TextColor3=BLUE,Font=Enum.Font.GothamBlack,TextSize=20,ZIndex=11},main)
newEl("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,38),BackgroundColor3=BLUE,BorderSizePixel=0,ZIndex=11},main)
local tabBar=newEl("Frame",{Size=UDim2.new(1,-16,0,34),Position=UDim2.new(0,8,0,44),BackgroundColor3=DGRY,BorderSizePixel=0,ZIndex=11},main)
corner(8,tabBar)
local TABS={"FEATURES","KEYBINDS","SETTINGS"};local tabBtns={}
local tabInd=newEl("Frame",{Size=UDim2.new(0,116,1,-4),Position=UDim2.new(0,2,0,2),BackgroundColor3=BLUE,BorderSizePixel=0,ZIndex=11},tabBar);corner(6,tabInd)
for i,name in ipairs(TABS)do
    local btn=newEl("TextButton",{Size=UDim2.new(0,116,1,0),Position=UDim2.new(0,(i-1)*118,0,0),BackgroundTransparency=1,Text=name,TextColor3=name=="FEATURES"and WHT or GRY,Font=Enum.Font.GothamBold,TextSize=10,ZIndex=12},tabBar)
    tabBtns[name]=btn
end
local ca=newEl("Frame",{Size=UDim2.new(1,-16,1,-88),Position=UDim2.new(0,8,0,84),BackgroundTransparency=1,ZIndex=11},main)
local function mkScroll()
    local p=newEl("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=BLUE,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=12,Visible=false},ca)
    local l=newEl("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},p)
    newEl("UIPadding",{PaddingBottom=UDim.new(0,10)},p);return p
end
local fP=mkScroll();fP.Visible=true;local kP=mkScroll();local sP=mkScroll()
local panels={FEATURES=fP,KEYBINDS=kP,SETTINGS=sP}
local function switchTab(name)
    for n,p in pairs(panels)do p.Visible=(n==name)end
    for n,b in pairs(tabBtns)do b.TextColor3=(n==name)and WHT or GRY end
    local idx=0;for i,t in ipairs(TABS)do if t==name then idx=i-1;break end end
    tw(tabInd,{Position=UDim2.new(0,2+idx*118,0,2)})
end
for name,btn in pairs(tabBtns)do btn.MouseButton1Click:Connect(function()switchTab(name)end)end
local fO=0
local function mkRow(label,tKey,onFn,offFn)
    fO=fO+1
    local row=newEl("Frame",{Size=UDim2.new(1,0,0,42),BackgroundColor3=CARD,BackgroundTransparency=0.25,BorderSizePixel=0,ZIndex=13,LayoutOrder=fO},fP);corner(8,row)
    newEl("TextLabel",{Size=UDim2.new(1,-58,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=label,TextColor3=WHT,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=14},row)
    local tb=newEl("Frame",{Size=UDim2.new(0,44,0,22),Position=UDim2.new(1,-52,0.5,-11),BackgroundColor3=Color3.fromRGB(35,45,70),BorderSizePixel=0,ZIndex=13},row);corner(100,tb)
    local knob=newEl("Frame",{Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=WHT,BorderSizePixel=0,ZIndex=14},tb);corner(100,knob)
    local clk=newEl("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=15},row)
    local isOn=false
    local function sv(s)isOn=s;T[tKey]=isOn;tw(tb,{BackgroundColor3=isOn and BLUE or Color3.fromRGB(35,45,70)});tw(knob,{Position=isOn and UDim2.new(1,-21,0.5,-9)or UDim2.new(0,3,0.5,-9)});if isOn and onFn then onFn()end;if not isOn and offFn then offFn()end end
    clk.MouseButton1Click:Connect(function()sv(not isOn)end)
end
local function mkBtn(label,cb)
    fO=fO+1
    local btn=newEl("TextButton",{Size=UDim2.new(1,0,0,46),BackgroundColor3=BLUE,BorderSizePixel=0,Text=label,TextColor3=Color3.fromRGB(5,10,20),Font=Enum.Font.GothamBlack,TextSize=14,ZIndex=13,LayoutOrder=fO},fP);corner(10,btn);btn.MouseButton1Click:Connect(cb)
end
local function mkSep()fO=fO+1;newEl("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.fromRGB(25,35,55),BorderSizePixel=0,ZIndex=13,LayoutOrder=fO},fP)end
mkRow("Auto Left","AutoLeft",startAutoLeft,stopAutoLeft);mkSep()
mkRow("Auto Right","AutoRight",startAutoRight,stopAutoRight);mkSep()
mkBtn("TP to Brainrot",tpToBrainrot);mkSep()
mkRow("Float","Float",startFloat,stopFloat);mkSep()
mkRow("Speed Boost","SpeedBoost",nil,nil);mkSep()
mkRow("Speed Steal","SpeedSteal",nil,nil);mkSep()
mkRow("Instant Grab","InstantGrab",startGrab,stopGrab);mkSep()
mkRow("Bat Aimbot","BatAimbot",startAimbot,stopAimbot);mkSep()
mkRow("Anti Ragdoll","AntiRagdoll",startAntiRag,stopAntiRag);mkSep()
mkRow("No Animations","NoAnim",startNoAnim,stopNoAnim);mkSep()
mkRow("Spinbot","Spinbot",startSpin,stopSpin);mkSep()
mkBtn("TAUNT",function()local h=getHum();if h then h:UnequipTools()end end)
local kbO=0;local activeRebind=nil;local kbD={}
local function mkKbRow(label,kbKey)
    kbO=kbO+1
    local row=newEl("Frame",{Size=UDim2.new(1,0,0,48),BackgroundColor3=CARD,BackgroundTransparency=0.25,BorderSizePixel=0,ZIndex=13,LayoutOrder=kbO},kP);corner(8,row)
    local kv=KB[kbKey]
    local badge=newEl("TextButton",{Size=UDim2.new(0,42,0,42),Position=UDim2.new(0,3,0.5,-21),BackgroundColor3=BLUE,BorderSizePixel=0,Text=kv and(kv==Enum.KeyCode.Unknown and"NONE"or kv.Name)or"?",TextColor3=Color3.fromRGB(5,10,20),Font=Enum.Font.GothamBlack,TextSize=11,ZIndex=14},row);corner(7,badge);kbD[kbKey]=badge
    newEl("TextLabel",{Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,54,0,0),BackgroundTransparency=1,Text=label,TextColor3=WHT,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=14},row)
    badge.MouseButton1Click:Connect(function()activeRebind=kbKey;badge.Text="...";badge.BackgroundColor3=Color3.fromRGB(255,200,0)end)
    kbO=kbO+1;newEl("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.fromRGB(25,35,55),BorderSizePixel=0,ZIndex=13,LayoutOrder=kbO},kP)
end
mkKbRow("Auto Left","AutoLeft");mkKbRow("Auto Right","AutoRight");mkKbRow("Instant Grab","InstantGrab")
mkKbRow("Bat Aimbot","BatAimbot");mkKbRow("Float","Float");mkKbRow("Speed Boost","SpeedBoost")
mkKbRow("Anti Ragdoll","AntiRagdoll");mkKbRow("No Anim","NoAnim");mkKbRow("Spinbot","Spinbot")
mkKbRow("Ungrab","Ungrab");mkKbRow("Toggle UI","ToggleUI")
local sO=0
local function mkSetRow(label,cfgKey,min,max)
    sO=sO+1
    local row=newEl("Frame",{Size=UDim2.new(1,0,0,50),BackgroundColor3=CARD,BackgroundTransparency=0.25,BorderSizePixel=0,ZIndex=13,LayoutOrder=sO},sP);corner(8,row)
    newEl("TextLabel",{Size=UDim2.new(0.58,0,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text=label,TextColor3=WHT,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=14},row)
    local vBox=newEl("TextButton",{Size=UDim2.new(0,78,0,32),Position=UDim2.new(1,-86,0.5,-16),BackgroundColor3=BLUE,BorderSizePixel=0,Text=tostring(Cfg[cfgKey]),TextColor3=Color3.fromRGB(5,10,20),Font=Enum.Font.GothamBlack,TextSize=14,ZIndex=14},row);corner(8,vBox)
    vBox.MouseButton1Click:Connect(function()
        local step=(max-min)/10;local cur=Cfg[cfgKey];local presets={};for i=min,max,step do table.insert(presets,math.floor(i*10)/10)end
        local idx=1;for i,v in ipairs(presets)do if v==cur then idx=i;break end end
        idx=(idx%#presets)+1;Cfg[cfgKey]=presets[idx];vBox.Text=tostring(presets[idx])
        if cfgKey=="SpinSpeed"and spinBAV then spinBAV.AngularVelocity=Vector3.new(0,Cfg.SpinSpeed,0)end
    end)
    sO=sO+1;newEl("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.fromRGB(25,35,55),BorderSizePixel=0,ZIndex=13,LayoutOrder=sO},sP)
end
mkSetRow("Speed Boost","Speed",0,150);mkSetRow("Speed Steal","StealSpeed",0,100)
mkSetRow("Aimbot Speed","AimbotSpeed",10,200);mkSetRow("Spinbot Speed","SpinSpeed",1,200);mkSetRow("Steal Radius","StealRadius",5,80)
sO=sO+1
local rstBtn=newEl("TextButton",{Size=UDim2.new(1,0,0,44),BackgroundColor3=BLUE,BorderSizePixel=0,Text="RESET DEFAULTS",TextColor3=Color3.fromRGB(5,10,20),Font=Enum.Font.GothamBlack,TextSize=14,ZIndex=13,LayoutOrder=sO},sP);corner(10,rstBtn)
rstBtn.MouseButton1Click:Connect(function()Cfg={Speed=60,StealSpeed=29,AimbotSpeed=55,SpinSpeed=50,StealRadius=25}end)
-- RIGHT PANEL
local rp=newEl("Frame",{Size=UDim2.new(0,150,0,172),Position=UDim2.new(1,-160,0.5,-86),BackgroundColor3=Color3.fromRGB(8,12,20),BorderSizePixel=0,ZIndex=10},sg);corner(14,rp);stroke(BLUE,2,rp)
newEl("TextLabel",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,Text="ALAM HUB",TextColor3=BLUE,Font=Enum.Font.GothamBlack,TextSize=13,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=11},rp)
newEl("TextLabel",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,28),BackgroundTransparency=1,Text="TP to Brainrot",TextColor3=GRY,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=11},rp)
local function mkRPBtn(label,yp,cb)
    local btn=newEl("TextButton",{Size=UDim2.new(1,-14,0,32),Position=UDim2.new(0,7,0,yp),BackgroundColor3=Color3.fromRGB(22,28,45),BorderSizePixel=0,Text=label,TextColor3=GRY,Font=Enum.Font.GothamBold,TextSize=12,ZIndex=11},rp);corner(8,btn);btn.MouseButton1Click:Connect(cb)
end
mkRPBtn("Left Side",46,function()local h=getH();if h then h.CFrame=CFrame.new(PL1)end end)
mkRPBtn("Right Side",84,function()local h=getH();if h then h.CFrame=CFrame.new(PR1)end end)
local autoLRon=false
local alrBtn=newEl("TextButton",{Size=UDim2.new(1,-14,0,32),Position=UDim2.new(0,7,0,122),BackgroundColor3=Color3.fromRGB(22,28,45),BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=12,ZIndex=11},rp);corner(8,alrBtn)
local function updateALR()alrBtn.Text="Auto L/R: "..(autoLRon and"ON"or"OFF");alrBtn.TextColor3=autoLRon and BLUE or GRY end;updateALR()
alrBtn.MouseButton1Click:Connect(function()autoLRon=not autoLRon;if autoLRon then T.AutoLeft=true;startAutoLeft()else stopAutoLeft();stopAutoRight()end;updateALR()end)
-- MOBILE BUTTONS (always visible)
local mobF=newEl("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=199},sg)
local function mkMob(label,x,y,cb)
    local btn=newEl("TextButton",{Size=UDim2.new(0,68,0,68),Position=UDim2.new(x,0,y,0),BackgroundColor3=Color3.fromRGB(8,25,55),BackgroundTransparency=0.1,Text=label,TextColor3=BLUE,Font=Enum.Font.GothamBlack,TextSize=11,TextWrapped=true,BorderSizePixel=0,ZIndex=200},mobF)
    corner(100,btn);stroke(BLUE,2,btn)
    local isOn=false
    btn.MouseButton1Click:Connect(function()if cb then cb()end;isOn=not isOn;tw(btn,{BackgroundColor3=isOn and BLUE or Color3.fromRGB(8,25,55)});btn.TextColor3=isOn and Color3.fromRGB(5,10,20)or BLUE end)
end
mkMob("AUTO
PLAY",0.01,0.22,function()end)
mkMob("PLASMA
LEFT",0.01,0.34,function()T.AutoLeft=not T.AutoLeft;if T.AutoLeft then startAutoLeft()else stopAutoLeft()end end)
mkMob("PLASMA
RIGHT",0.01,0.46,function()T.AutoRight=not T.AutoRight;if T.AutoRight then startAutoRight()else stopAutoRight()end end)
mkMob("FLOAT",0.82,0.18,function()T.Float=not T.Float;if T.Float then startFloat()else stopFloat()end end)
mkMob("UNGRAB",0.72,0.30,function()local h=getHum();if h then h:UnequipTools()end end)
mkMob("BAT
AIMBOT",0.84,0.30,function()T.BatAimbot=not T.BatAimbot;if T.BatAimbot then startAimbot()else stopAimbot()end end)
mkMob("TAUNT",0.72,0.42,function()local h=getHum();if h then h:UnequipTools()end end)
mkMob("SPINBOT",0.84,0.42,function()T.Spinbot=not T.Spinbot;if T.Spinbot then startSpin()else stopSpin()end end)
-- TOGGLE
iconBtn.MouseButton1Click:Connect(function()guiVisible=not guiVisible;main.Visible=guiVisible;rp.Visible=guiVisible end)
-- INPUT
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if activeRebind then
        KB[activeRebind]=inp.KeyCode
        if kbD[activeRebind]then kbD[activeRebind].Text=inp.KeyCode==Enum.KeyCode.Unknown and"NONE"or inp.KeyCode.Name;kbD[activeRebind].BackgroundColor3=BLUE end
        activeRebind=nil;return
    end
    local k=inp.KeyCode
    if k==KB.ToggleUI then guiVisible=not guiVisible;main.Visible=guiVisible;rp.Visible=guiVisible end
    if k==KB.AutoLeft then T.AutoLeft=not T.AutoLeft;if T.AutoLeft then startAutoLeft()else stopAutoLeft()end end
    if k==KB.AutoRight then T.AutoRight=not T.AutoRight;if T.AutoRight then startAutoRight()else stopAutoRight()end end
    if k==KB.InstantGrab then T.InstantGrab=not T.InstantGrab;if T.InstantGrab then startGrab()else stopGrab()end end
    if k==KB.BatAimbot then T.BatAimbot=not T.BatAimbot;if T.BatAimbot then startAimbot()else stopAimbot()end end
    if k==KB.Float then T.Float=not T.Float;if T.Float then startFloat()else stopFloat()end end
    if k==KB.SpeedBoost then T.SpeedBoost=not T.SpeedBoost end
    if k==KB.AntiRagdoll then T.AntiRagdoll=not T.AntiRagdoll;if T.AntiRagdoll then startAntiRag()else stopAntiRag()end end
    if k==KB.NoAnim then T.NoAnim=not T.NoAnim;if T.NoAnim then startNoAnim()else stopNoAnim()end end
    if k==KB.Spinbot then T.Spinbot=not T.Spinbot;if T.Spinbot then startSpin()else stopSpin()end end
    if k==KB.Ungrab then local h=getHum();if h then h:UnequipTools()end end
end)
Pl.CharacterAdded:Connect(function()
    task.wait(1)
    if T.AntiRagdoll then stopAntiRag();task.wait(0.1);startAntiRag()end
    if T.BatAimbot then stopAimbot();task.wait(0.1);startAimbot()end
    if T.AutoLeft then stopAutoLeft();task.wait(0.1);startAutoLeft()end
    if T.AutoRight then stopAutoRight();task.wait(0.1);startAutoRight()end
    if T.Float then startFloat()end;if T.Spinbot then startSpin()end;if T.InstantGrab then startGrab()end
end)
print("[ALAM HUB] Loaded! discord.gg/U4XXCxKUm | U=Toggle")
