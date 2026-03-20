-- ALAM HUB | discord.gg/U4XXCxKUm
repeat task.wait()until game:IsLoaded()
task.wait(1)
local Pl=game:GetService("Players").LocalPlayer
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
if not Pl.Character then Pl.CharacterAdded:Wait()end
task.wait(0.5)
local C={}
local T={AutoLeft=false,AutoRight=false,Float=false,BatAimbot=false,Spinbot=false,InstantGrab=false,SpeedBoost=false,SpeedSteal=false,AntiRagdoll=false,NoAnim=false}
local Cfg={Speed=60,StealSpeed=29,AimbotSpeed=55,SpinSpeed=50,StealRadius=25}
local lP=1,rP=1
local floatY,floatConn,spinBAV=nil,nil,nil
local lastGrab=0
local function getH()local c=Pl.Character;return c and c:FindFirstChild("HumanoidRootPart")end
local function getHum()local c=Pl.Character;return c and c:FindFirstChildOfClass("Humanoid")end
local function getMD()local h=getHum();return h and h.MoveDirection or Vector3.zero end
local function isMyPlot(n)
local plots=workspace:FindFirstChild("Plots");if not plots then return false end
local plot=plots:FindFirstChild(n);if not plot then return false end
local sign=plot:FindFirstChild("PlotSign")
if sign then local yb=sign:FindFirstChild("YourBase");if yb and yb:IsA("BillboardGui")then return yb.Enabled end end
return false
end
RS.Heartbeat:Connect(function()
local hrp=getH();local hum=getHum();if not hrp or not hum then return end
local md=getMD();if md.Magnitude<0.1 then return end
if hum.FloorMaterial==Enum.Material.Air then return end
local stealing=Pl:GetAttribute("Stealing")
local spd=(stealing and T.SpeedSteal)and Cfg.StealSpeed or(T.SpeedBoost and Cfg.Speed or nil)
if spd then hrp.AssemblyLinearVelocity=Vector3.new(md.X*spd,hrp.AssemblyLinearVelocity.Y,md.Z*spd)end
end)
local function startFloat()
local hrp=getH();if not hrp then return end
floatY=hrp.Position.Y
if floatConn then floatConn:Disconnect()end
floatConn=RS.Heartbeat:Connect(function()
if not T.Float then return end
local h=getH();if not h then return end
h.AssemblyLinearVelocity=Vector3.new(h.AssemblyLinearVelocity.X,0,h.AssemblyLinearVelocity.Z)
if floatY and math.abs(h.Position.Y-floatY)>0.5 then h.CFrame=CFrame.new(h.Position.X,floatY,h.Position.Z)end
end)
end
local function stopFloat()if floatConn then floatConn:Disconnect();floatConn=nil end end
local function startAimbot()
if C.aim then return end
C.aim=RS.Heartbeat:Connect(function()
if not T.BatAimbot then return end
local hrp=getH();local hum=getHum();if not hrp or not hum then return end
local best,bd=nil,math.huge
for _,p in ipairs(game:GetService("Players"):GetPlayers())do
if p~=Pl and p.Character then
local eh=p.Character:FindFirstChild("HumanoidRootPart")
local h2=p.Character:FindFirstChildOfClass("Humanoid")
if eh and h2 and h2.Health>0 then
local d=(eh.Position-hrp.Position).Magnitude
if d<bd then bd=d;best=eh end
end
end
end
if not best then return end
local flat=Vector3.new(best.Position.X-hrp.Position.X,0,best.Position.Z-hrp.Position.Z)
if flat.Magnitude>1 then local md2=flat.Unit;hrp.AssemblyLinearVelocity=Vector3.new(md2.X*Cfg.AimbotSpeed,hrp.AssemblyLinearVelocity.Y,md2.Z*Cfg.AimbotSpeed)end
end)
end
local function stopAimbot()if C.aim then C.aim:Disconnect();C.aim=nil end end
local function startSpin()
local hrp=getH();if not hrp then return end
if spinBAV then spinBAV:Destroy()end
spinBAV=Instance.new("BodyAngularVelocity")
spinBAV.MaxTorque=Vector3.new(0,math.huge,0)
spinBAV.AngularVelocity=Vector3.new(0,Cfg.SpinSpeed,0)
spinBAV.Parent=hrp
end
local function stopSpin()if spinBAV then spinBAV:Destroy();spinBAV=nil end end
local function startAntiRag()
if C.ar then return end
C.ar=RS.Heartbeat:Connect(function()
if not T.AntiRagdoll then return end
local c=Pl.Character;if not c then return end
local hum=c:FindFirstChildOfClass("Humanoid");local hrp=c:FindFirstChild("HumanoidRootPart")
if hum then
local s=hum:GetState()
if s==Enum.HumanoidStateType.Physics or s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.FallingDown then
hum:ChangeState(Enum.HumanoidStateType.Running)
if hrp then hrp.AssemblyLinearVelocity=Vector3.zero end
end
end
end)
end
local function stopAntiRag()if C.ar then C.ar:Disconnect();C.ar=nil end end
local savedAnim=nil
local function startNoAnim()
local c=Pl.Character;if not c then return end
local hum=getHum();if hum then for _,t in ipairs(hum:GetPlayingAnimationTracks())do t:Stop(0)end end
local a=c:FindFirstChild("Animate");if a then savedAnim=a:Clone();a:Destroy()end
end
local function stopNoAnim()local c=Pl.Character;if c and savedAnim then savedAnim:Clone().Parent=c;savedAnim=nil end end
local PL1=Vector3.new(-476.48,-6.28,92.73);local PL2=Vector3.new(-483.12,-4.95,94.80)
local PR1=Vector3.new(-476.16,-6.52,25.62);local PR2=Vector3.new(-483.04,-5.09,23.14)
local function startAutoLeft()
if C.aL then C.aL:Disconnect()end;lP=1
C.aL=RS.Heartbeat:Connect(function()
if not T.AutoLeft then return end
local hrp=getH();local hum=getHum();if not hrp or not hum then return end
local tgt=lP==1 and PL1 or PL2
local dist=(Vector3.new(tgt.X,hrp.Position.Y,tgt.Z)-hrp.Position).Magnitude
if dist<1.5 then
if lP==1 then lP=2
else hum:Move(Vector3.zero,false);hrp.AssemblyLinearVelocity=Vector3.zero;T.AutoLeft=false;C.aL:Disconnect();C.aL=nil;return end
end
local d=(tgt-hrp.Position);local md2=Vector3.new(d.X,0,d.Z).Unit
hum:Move(md2,false);hrp.AssemblyLinearVelocity=Vector3.new(md2.X*Cfg.Speed,hrp.AssemblyLinearVelocity.Y,md2.Z*Cfg.Speed)
end)
end
local function stopAutoLeft()if C.aL then C.aL:Disconnect();C.aL=nil end;local h=getHum();if h then h:Move(Vector3.zero,false)end;T.AutoLeft=false end
local function startAutoRight()
if C.aR then C.aR:Disconnect()end;rP=1
C.aR=RS.Heartbeat:Connect(function()
if not T.AutoRight then return end
local hrp=getH();local hum=getHum();if not hrp or not hum then return end
local tgt=rP==1 and PR1 or PR2
local dist=(Vector3.new(tgt.X,hrp.Position.Y,tgt.Z)-hrp.Position).Magnitude
if dist<1.5 then
if rP==1 then rP=2
else hum:Move(Vector3.zero,false);hrp.AssemblyLinearVelocity=Vector3.zero;T.AutoRight=false;C.aR:Disconnect();C.aR=nil;return end
end
local d=(tgt-hrp.Position);local md2=Vector3.new(d.X,0,d.Z).Unit
hum:Move(md2,false);hrp.AssemblyLinearVelocity=Vector3.new(md2.X*Cfg.Speed,hrp.AssemblyLinearVelocity.Y,md2.Z*Cfg.Speed)
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
if spawn then
local dist=(spawn.Position-hrp.Position).Magnitude
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
if not T.InstantGrab then return end
if tick()-lastGrab<0.3 then return end
local hum=getHum();if hum and hum.FloorMaterial==Enum.Material.Air then return end
local p=findPrompt();if p and p.Parent then lastGrab=tick();pcall(function()fireproximityprompt(p)end)end
end)
end
local function stopGrab()if C.grab then C.grab:Disconnect();C.grab=nil end end
-- GUI
local sg=Instance.new("ScreenGui");sg.Name="AlamHub";sg.ResetOnSpawn=false;sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
sg.Parent=Pl:FindFirstChildOfClass("PlayerGui")or Pl.PlayerGui
local BG=Color3.fromRGB(10,13,20);local CARD=Color3.fromRGB(18,22,32);local BLUE=Color3.fromRGB(0,180,255)
local WHT=Color3.fromRGB(255,255,255);local GRY=Color3.fromRGB(50,65,90);local DGRY=Color3.fromRGB(22,28,42)
local function tw(o,p,t)TS:Create(o,TweenInfo.new(t or 0.15),p):Play()end
-- ICON
local icon=Instance.new("TextButton",sg);icon.Size=UDim2.new(0,52,0,52);icon.Position=UDim2.new(0,8,0.38,0)
icon.BackgroundColor3=Color3.fromRGB(8,12,20);icon.Text="A";icon.TextColor3=BLUE
icon.Font=Enum.Font.GothamBlack;icon.TextSize=26;icon.BorderSizePixel=0;icon.ZIndex=100
Instance.new("UICorner",icon).CornerRadius=UDim.new(0,12)
Instance.new("UIStroke",icon).Color=BLUE
-- MAIN
local main=Instance.new("Frame",sg);main.Size=UDim2.new(0,360,0,560)
main.Position=UDim2.new(0.5,-180,0.5,-280);main.BackgroundColor3=BG
main.BackgroundTransparency=0.05;main.BorderSizePixel=0;main.Active=true;main.Draggable=true
main.ClipsDescendants=true;main.ZIndex=10
Instance.new("UICorner",main).CornerRadius=UDim.new(0,16)
Instance.new("UIStroke",main).Color=BLUE
local titleLbl=Instance.new("TextLabel",main);titleLbl.Size=UDim2.new(1,0,0,38)
titleLbl.BackgroundTransparency=1;titleLbl.Text="ALAM HUB";titleLbl.TextColor3=BLUE
titleLbl.Font=Enum.Font.GothamBlack;titleLbl.TextSize=20;titleLbl.ZIndex=11
local div=Instance.new("Frame",main);div.Size=UDim2.new(1,-20,0,1);div.Position=UDim2.new(0,10,0,38)
div.BackgroundColor3=BLUE;div.BorderSizePixel=0;div.ZIndex=11
-- TABS
local tabBar=Instance.new("Frame",main);tabBar.Size=UDim2.new(1,-16,0,34);tabBar.Position=UDim2.new(0,8,0,44)
tabBar.BackgroundColor3=DGRY;tabBar.BorderSizePixel=0;tabBar.ZIndex=11
Instance.new("UICorner",tabBar).CornerRadius=UDim.new(0,8)
local TABS={"FEATURES","KEYBINDS","SETTINGS"}
local tabBtns={};local curTab="FEATURES"
local tabInd=Instance.new("Frame",tabBar);tabInd.Size=UDim2.new(0,116,1,-4);tabInd.Position=UDim2.new(0,2,0,2)
tabInd.BackgroundColor3=BLUE;tabInd.BorderSizePixel=0;tabInd.ZIndex=11
Instance.new("UICorner",tabInd).CornerRadius=UDim.new(0,6)
for i,name in ipairs(TABS)do
local btn=Instance.new("TextButton",tabBar);btn.Size=UDim2.new(0,116,1,0);btn.Position=UDim2.new(0,(i-1)*118,0,0)
btn.BackgroundTransparency=1;btn.Text=name;btn.TextColor3=name==curTab and WHT or GRY
btn.Font=Enum.Font.GothamBold;btn.TextSize=10;btn.ZIndex=12;tabBtns[name]=btn
end
-- CONTENT
local content=Instance.new("Frame",main);content.Size=UDim2.new(1,-16,1,-88);content.Position=UDim2.new(0,8,0,84)
content.BackgroundTransparency=1;content.ZIndex=11
local function mkScroll()
local p=Instance.new("ScrollingFrame",content);p.Size=UDim2.new(1,0,1,0)
p.BackgroundTransparency=1;p.BorderSizePixel=0;p.ScrollBarThickness=3;p.ScrollBarImageColor3=BLUE
p.CanvasSize=UDim2.new(0,0,0,0);p.AutomaticCanvasSize=Enum.AutomaticSize.Y;p.ZIndex=12;p.Visible=false
local l=Instance.new("UIListLayout",p);l.Padding=UDim.new(0,3);l.SortOrder=Enum.SortOrder.LayoutOrder
Instance.new("UIPadding",p).PaddingBottom=UDim.new(0,10)
return p
end
local featP=mkScroll();featP.Visible=true
local kbP=mkScroll()
local setP=mkScroll()
local panels={FEATURES=featP,KEYBINDS=kbP,SETTINGS=setP}
local function switchTab(name)
curTab=name
for n,p in pairs(panels)do p.Visible=(n==name)end
for n,b in pairs(tabBtns)do b.TextColor3=(n==name)and WHT or GRY end
local idx=0;for i,t in ipairs(TABS)do if t==name then idx=i-1;break end end
tw(tabInd,{Position=UDim2.new(0,2+idx*118,0,2)})
end
for name,btn in pairs(tabBtns)do btn.MouseButton1Click:Connect(function()switchTab(name)end)end
local fO=0
local function mkRow(label,tKey,onFn,offFn)
fO+=1
local row=Instance.new("Frame",featP);row.Size=UDim2.new(1,0,0,42);row.BackgroundColor3=CARD
row.BackgroundTransparency=0.25;row.BorderSizePixel=0;row.ZIndex=13;row.LayoutOrder=fO
Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
local lbl=Instance.new("TextLabel",row);lbl.Size=UDim2.new(1,-58,1,0);lbl.Position=UDim2.new(0,14,0,0)
lbl.BackgroundTransparency=1;lbl.Text=label;lbl.TextColor3=WHT;lbl.Font=Enum.Font.GothamBold;lbl.TextSize=13
lbl.TextXAlignment=Enum.TextXAlignment.Left;lbl.ZIndex=14
local tb=Instance.new("Frame",row);tb.Size=UDim2.new(0,44,0,22);tb.Position=UDim2.new(1,-52,0.5,-11)
tb.BackgroundColor3=Color3.fromRGB(35,45,70);tb.BorderSizePixel=0;tb.ZIndex=13
Instance.new("UICorner",tb).CornerRadius=UDim.new(1,0)
local knob=Instance.new("Frame",tb);knob.Size=UDim2.new(0,18,0,18);knob.Position=UDim2.new(0,3,0.5,-9)
knob.BackgroundColor3=WHT;knob.BorderSizePixel=0;knob.ZIndex=14
Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
local clk=Instance.new("TextButton",row);clk.Size=UDim2.new(1,0,1,0);clk.BackgroundTransparency=1;clk.Text="";clk.ZIndex=15
local isOn=false
local function sv(s)
isOn=s;T[tKey]=isOn
tw(tb,{BackgroundColor3=isOn and BLUE or Color3.fromRGB(35,45,70)})
tw(knob,{Position=isOn and UDim2.new(1,-21,0.5,-9)or UDim2.new(0,3,0.5,-9)})
if isOn and onFn then onFn()end;if not isOn and offFn then offFn()end
end
clk.MouseButton1Click:Connect(function()sv(not isOn)end)
end
local function mkBtn(label,cb)
fO+=1
local btn=Instance.new("TextButton",featP);btn.Size=UDim2.new(1,0,0,46);btn.BackgroundColor3=BLUE
btn.BorderSizePixel=0;btn.Text=label;btn.TextColor3=Color3.fromRGB(5,10,20)
btn.Font=Enum.Font.GothamBlack;btn.TextSize=14;btn.ZIndex=13;btn.LayoutOrder=fO
Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
btn.MouseButton1Click:Connect(cb)
end
local function mkSep()fO+=1;local s=Instance.new("Frame",featP);s.Size=UDim2.new(1,0,0,1);s.BackgroundColor3=Color3.fromRGB(25,35,55);s.BorderSizePixel=0;s.ZIndex=13;s.LayoutOrder=fO end
mkRow("Auto Left",       "AutoLeft",    startAutoLeft,  stopAutoLeft)  mkSep()
mkRow("Auto Right",      "AutoRight",   startAutoRight, stopAutoRight) mkSep()
mkBtn("TP to Brainrot",function()
local hrp=getH();if not hrp then return end
local plots=workspace:FindFirstChild("Plots");if not plots then return end
local ok2,S=pcall(function()local rs=game:GetService("ReplicatedStorage");return{Sync=require(rs:WaitForChild("Packages"):WaitForChild("Synchronizer")),Shared=require(rs:WaitForChild("Shared"):WaitForChild("Animals"))}end)
if not ok2 then return end
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
end) mkSep()
mkRow("Float",           "Float",       startFloat,     stopFloat)     mkSep()
mkRow("Speed Boost",     "SpeedBoost",  nil,            nil)           mkSep()
mkRow("Speed Steal",     "SpeedSteal",  nil,            nil)           mkSep()
mkRow("Instant Grab",    "InstantGrab", startGrab,      stopGrab)      mkSep()
mkRow("Bat Aimbot",      "BatAimbot",   startAimbot,    stopAimbot)    mkSep()
mkRow("Anti Ragdoll",    "AntiRagdoll", startAntiRag,   stopAntiRag)   mkSep()
mkRow("No Animations",   "NoAnim",      startNoAnim,    stopNoAnim)    mkSep()
mkRow("Spinbot",         "Spinbot",     startSpin,      stopSpin)      mkSep()
mkRow("Ungrab",          "Ungrab",      nil,            nil)           mkSep()
mkBtn("TAUNT",function()local hum=getHum();if hum then hum:UnequipTools()end end)
-- KEYBINDS
local KB={AutoLeft=Enum.KeyCode.Q,AutoRight=Enum.KeyCode.E,InstantGrab=Enum.KeyCode.V,BatAimbot=Enum.KeyCode.Z,Float=Enum.KeyCode.F,SpeedBoost=Enum.KeyCode.B,AntiRagdoll=Enum.KeyCode.X,NoAnim=Enum.KeyCode.N,Spinbot=Enum.KeyCode.T,Ungrab=Enum.KeyCode.C,ToggleUI=Enum.KeyCode.U}
local activeRebind=nil;local kbDisplays={}
local kbO=0
local function mkKbRow(label,kbKey)
kbO+=1
local row=Instance.new("Frame",kbP);row.Size=UDim2.new(1,0,0,48);row.BackgroundColor3=CARD
row.BackgroundTransparency=0.25;row.BorderSizePixel=0;row.ZIndex=13;row.LayoutOrder=kbO
Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
local badge=Instance.new("TextButton",row);badge.Size=UDim2.new(0,42,0,42);badge.Position=UDim2.new(0,3,0.5,-21)
badge.BackgroundColor3=BLUE;badge.BorderSizePixel=0
local kv=KB[kbKey];badge.Text=kv and(kv==Enum.KeyCode.Unknown and"NONE"or kv.Name)or"?"
badge.TextColor3=Color3.fromRGB(5,10,20);badge.Font=Enum.Font.GothamBlack;badge.TextSize=11;badge.ZIndex=14
Instance.new("UICorner",badge).CornerRadius=UDim.new(0,7);kbDisplays[kbKey]=badge
local lbl=Instance.new("TextLabel",row);lbl.Size=UDim2.new(1,-56,1,0);lbl.Position=UDim2.new(0,54,0,0)
lbl.BackgroundTransparency=1;lbl.Text=label;lbl.TextColor3=WHT;lbl.Font=Enum.Font.GothamBold;lbl.TextSize=13
lbl.TextXAlignment=Enum.TextXAlignment.Left;lbl.ZIndex=14
badge.MouseButton1Click:Connect(function()activeRebind=kbKey;badge.Text="...";badge.BackgroundColor3=Color3.fromRGB(255,200,0)end)
local sep=Instance.new("Frame",kbP);sep.Size=UDim2.new(1,0,0,1);sep.BackgroundColor3=Color3.fromRGB(25,35,55);sep.BorderSizePixel=0;sep.ZIndex=13;sep.LayoutOrder=kbO+0.5
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
-- SETTINGS
local sO=0
local function mkSetRow(label,cfgKey,min,max)
sO+=1
local row=Instance.new("Frame",setP);row.Size=UDim2.new(1,0,0,50);row.BackgroundColor3=CARD
row.BackgroundTransparency=0.25;row.BorderSizePixel=0;row.ZIndex=13;row.LayoutOrder=sO
Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
local lbl=Instance.new("TextLabel",row);lbl.Size=UDim2.new(0.58,0,1,0);lbl.Position=UDim2.new(0,12,0,0)
lbl.BackgroundTransparency=1;lbl.Text=label;lbl.TextColor3=WHT;lbl.Font=Enum.Font.GothamBold;lbl.TextSize=13
lbl.TextXAlignment=Enum.TextXAlignment.Left;lbl.ZIndex=14
local vBox=Instance.new("TextButton",row);vBox.Size=UDim2.new(0,78,0,32);vBox.Position=UDim2.new(1,-86,0.5,-16)
vBox.BackgroundColor3=BLUE;vBox.BorderSizePixel=0;vBox.Text=tostring(Cfg[cfgKey])
vBox.TextColor3=Color3.fromRGB(5,10,20);vBox.Font=Enum.Font.GothamBlack;vBox.TextSize=14;vBox.ZIndex=14
Instance.new("UICorner",vBox).CornerRadius=UDim.new(0,8)
vBox.MouseButton1Click:Connect(function()
local step=(max-min)/10;local cur=Cfg[cfgKey]
local presets={};for i=min,max,step do table.insert(presets,math.floor(i*10)/10)end
local idx=1;for i,v in ipairs(presets)do if v==cur then idx=i;break end end
idx=(idx%#presets)+1;Cfg[cfgKey]=presets[idx];vBox.Text=tostring(presets[idx])
if cfgKey=="SpinSpeed"and spinBAV then spinBAV.AngularVelocity=Vector3.new(0,Cfg.SpinSpeed,0)end
end)
local sep=Instance.new("Frame",setP);sep.Size=UDim2.new(1,0,0,1);sep.BackgroundColor3=Color3.fromRGB(25,35,55);sep.BorderSizePixel=0;sep.ZIndex=13;sep.LayoutOrder=sO+0.5
end
mkSetRow("Speed Boost",        "Speed",       0,  150)
mkSetRow("Speed While Steal",  "StealSpeed",  0,  100)
mkSetRow("Aimbot Speed",       "AimbotSpeed", 10, 200)
mkSetRow("Spinbot Speed",      "SpinSpeed",   1,  200)
mkSetRow("Steal Radius",       "StealRadius", 5,  80)
sO+=1
local rstBtn=Instance.new("TextButton",setP);rstBtn.Size=UDim2.new(1,0,0,44);rstBtn.BackgroundColor3=BLUE
rstBtn.BorderSizePixel=0;rstBtn.Text="RESET DEFAULTS";rstBtn.TextColor3=Color3.fromRGB(5,10,20)
rstBtn.Font=Enum.Font.GothamBlack;rstBtn.TextSize=14;rstBtn.ZIndex=13;rstBtn.LayoutOrder=sO
Instance.new("UICorner",rstBtn).CornerRadius=UDim.new(0,10)
rstBtn.MouseButton1Click:Connect(function()Cfg={Speed=60,StealSpeed=29,AimbotSpeed=55,SpinSpeed=50,StealRadius=25}end)
-- RIGHT MINI PANEL
local rp=Instance.new("Frame",sg);rp.Size=UDim2.new(0,150,0,172);rp.Position=UDim2.new(1,-160,0.5,-86)
rp.BackgroundColor3=Color3.fromRGB(8,12,20);rp.BorderSizePixel=0;rp.ZIndex=10
Instance.new("UICorner",rp).CornerRadius=UDim.new(0,14);Instance.new("UIStroke",rp).Color=BLUE
local rpT=Instance.new("TextLabel",rp);rpT.Size=UDim2.new(1,0,0,30);rpT.BackgroundTransparency=1
rpT.Text="ALAM HUB";rpT.TextColor3=BLUE;rpT.Font=Enum.Font.GothamBlack;rpT.TextSize=13
rpT.TextXAlignment=Enum.TextXAlignment.Center;rpT.ZIndex=11
local rpS=Instance.new("TextLabel",rp);rpS.Size=UDim2.new(1,0,0,14);rpS.Position=UDim2.new(0,0,0,28)
rpS.BackgroundTransparency=1;rpS.Text="TP to Brainrot";rpS.TextColor3=GRY;rpS.Font=Enum.Font.Gotham;rpS.TextSize=10
rpS.TextXAlignment=Enum.TextXAlignment.Center;rpS.ZIndex=11
local function mkRPB(label,yp,cb)
local btn=Instance.new("TextButton",rp);btn.Size=UDim2.new(1,-14,0,32);btn.Position=UDim2.new(0,7,0,yp)
btn.BackgroundColor3=Color3.fromRGB(22,28,45);btn.BorderSizePixel=0;btn.Text=label
btn.TextColor3=GRY;btn.Font=Enum.Font.GothamBold;btn.TextSize=12;btn.ZIndex=11
Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8);btn.MouseButton1Click:Connect(cb)
end
mkRPB("Left Side",  46, function()local h=getH();if h then h.CFrame=CFrame.new(PL1)end end)
mkRPB("Right Side", 84, function()local h=getH();if h then h.CFrame=CFrame.new(PR1)end end)
local autoLRon=false
local alrBtn=Instance.new("TextButton",rp);alrBtn.Size=UDim2.new(1,-14,0,32);alrBtn.Position=UDim2.new(0,7,0,122)
alrBtn.BackgroundColor3=Color3.fromRGB(22,28,45);alrBtn.BorderSizePixel=0
alrBtn.TextColor3=GRY;alrBtn.Font=Enum.Font.GothamBold;alrBtn.TextSize=12;alrBtn.ZIndex=11
Instance.new("UICorner",alrBtn).CornerRadius=UDim.new(0,8)
local function updateALR()alrBtn.Text="Auto L/R: "..(autoLRon and"ON"or"OFF");alrBtn.TextColor3=autoLRon and BLUE or GRY end
updateALR()
alrBtn.MouseButton1Click:Connect(function()
autoLRon=not autoLRon
if autoLRon then T.AutoLeft=true;startAutoLeft()else stopAutoLeft();stopAutoRight()end
updateALR()
end)
-- TOGGLE
local guiVisible=true
icon.MouseButton1Click:Connect(function()guiVisible=not guiVisible;main.Visible=guiVisible;rp.Visible=guiVisible end)
-- INPUT
UIS.InputBegan:Connect(function(inp,gpe)
if gpe then return end
if activeRebind then
KB[activeRebind]=inp.KeyCode
if kbDisplays[activeRebind]then kbDisplays[activeRebind].Text=inp.KeyCode==Enum.KeyCode.Unknown and"NONE"or inp.KeyCode.Name;kbDisplays[activeRebind].BackgroundColor3=BLUE end
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
if k==KB.Ungrab then local hum=getHum();if hum then hum:UnequipTools()end end
end)
Pl.CharacterAdded:Connect(function()
task.wait(1)
if T.AntiRagdoll then stopAntiRag();task.wait(0.1);startAntiRag()end
if T.BatAimbot then stopAimbot();task.wait(0.1);startAimbot()end
if T.AutoLeft then stopAutoLeft();task.wait(0.1);startAutoLeft()end
if T.AutoRight then stopAutoRight();task.wait(0.1);startAutoRight()end
if T.Float then startFloat()end
if T.Spinbot then startSpin()end
if T.InstantGrab then startGrab()end
end)
print("[ALAM HUB] Loaded! discord.gg/U4XXCxKUm")
