-- menu_obfuscated.lua
MachoIsolatedInject([[
local a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
a=vec2(400,250)
b=vec2(500,300)
c=10
d=MachoMenuWindow(b.x,b.y,a.x,a.y)
MachoMenuSetAccent(d,137,52,235)
MachoMenuSetKeybind(d,0x2E)
SetNuiFocus(false,false)
CreateThread(function() while true do if MachoMenuIsOpen and MachoMenuIsOpen(d) then SetMouseCursorActiveThisFrame() DisableControlAction(0,1,true) DisableControlAction(0,2,true) DisableControlAction(0,24,true) DisableControlAction(0,25,true) DisableControlAction(0,257,true) DisableControlAction(0,322,true) Wait(0) else Wait(200) end end end)
-- Spawn Item
e=MachoMenuGroup(d,"Spawn Item",c,c,(a.x/2)-c,a.y-c)
f=MachoMenuInputbox(e,"Item Name","money")
g=MachoMenuInputbox(e,"Amount","1")
MachoMenuButton(e,"Spawn Item",function()
    h=tostring(MachoMenuGetInputbox(f)):gsub('"','')
    i=tonumber(MachoMenuGetInputbox(g)) or 1
    if h~="" and i>0 then
        MachoInjectResource("any","TriggerServerEvent('player:giveItem',{item='"..h.."',count="..i.."})",false)
        if MachoMenuNotification then MachoMenuNotification("Spawn Item","Spawned "..i.." x "..h) end
    else if MachoMenuNotification then MachoMenuNotification("Spawn Item","Enter valid item and amount") end end
end)
-- Exploits
j=MachoMenuGroup(d,"Exploits",(a.x/2)+c,c,a.x-c,a.y-c)
k=false
l=function(m) if m then MachoInjectResource("any","TriggerEvent('txcl:setPlayerMode','noclip',true)",false) if MachoMenuNotification then MachoMenuNotification("Noclip","Enabled") end else MachoInjectResource("any","TriggerEvent('txcl:setPlayerMode','none',true)",false) if MachoMenuNotification then MachoMenuNotification("Noclip","Disabled") end end end
MachoMenuCheckbox(j,"Noclip (U)",function() k=true l(true) end,function() k=false l(false) end)
CreateThread(function() while true do Wait(0) if IsControlJustPressed(0,303) then k=not k l(k) end end end)
-- E-Rob
n=false
o=nil
p=function() if o then return end o=CreateThread(function()
    local RADIUS,EXIT,KEY,D,A,robbing,target,openedInv,lastPress,PRESS_COOLDOWN,startedAt,STUCK_TIMEOUT=2.5,2.8,38,"missminuteman_1ig_2","handsup_base",false,-1,false,0,400,0,15000
    RequestAnimDict(D) while not HasAnimDictLoaded(D) do Wait(0) end
    local function now() return GetGameTimer() end
    local function keyPressed() if IsControlJustPressed(0,KEY) or IsDisabledControlJustPressed(0,KEY) then if now()-lastPress>=PRESS_COOLDOWN then lastPress=now() return true end end return false end
    local function closestPlayer() local me,meC=PlayerId(),GetEntityCoords(PlayerPedId()) local best,bestD=-1,99999.0 for _,pid in ipairs(GetActivePlayers()) do if pid~=me and NetworkIsPlayerActive(pid) then local ped=GetPlayerPed(pid) if DoesEntityExist(ped) then local d=#(GetEntityCoords(ped)-meC) if d<bestD then best,bestD=pid,d end end end end return best,bestD end
    local function softReset() robbing,target,openedInv,startedAt=false,-1,false,0 end
    local function stopAnim() if target~=-1 then local tPed=GetPlayerPed(target) if DoesEntityExist(tPed) then StopAnimTask(tPed,D,A,1.0) ClearPedTasksImmediately(tPed) end end end
    local function openInv(pid) if pid==-1 then return end local sid=GetPlayerServerId(pid) if sid and sid~=0 then TriggerEvent('ox_inventory:openInventory','otherplayer',sid) openedInv=true end end
    while n do Wait(0)
        if robbing and startedAt~=0 and (now()-startedAt)>STUCK_TIMEOUT then stopAnim() softReset() end
        if keyPressed() then if not robbing then local pid,dist=closestPlayer() if pid~=-1 and dist<=RADIUS then robbing,target,openedInv=true,pid,false startedAt=now() local tPed=GetPlayerPed(target) TaskPlayAnim(tPed,D,A,8.0,-8.0,-1,49,0,false,false,false) CreateThread(function() Wait(300) if robbing and target~=-1 and not openedInv then openInv(target) end end) else softReset() end else stopAnim() softReset() end end
    end
    stopAnim() softReset()
    o=nil
end) end
MachoMenuCheckbox(j,"(E) Rob",function() n=true p() if MachoMenuNotification then MachoMenuNotification("E-Rob","Enabled. Press E near player") end end,function() n=false if MachoMenuNotification then MachoMenuNotification("E-Rob","Disabled") end end)
-- Weapons
MachoMenuButton(j,"Give All CS Guns",function()
    local cs={"WEAPON_BLUESUPERI","WEAPON_PINKSUPERI","WEAPON_REDGOBLIN","WEAPON_MONSTERKRIG6","WEAPON_DG58VALENTINES","WEAPON_GREENGOBLIN","WEAPON_FUNICORNASVAL","WEAPON_LEAPORNMTZ","WEAPON_AKSHOTGUN","WEAPON_BLUEGOBLINMK2","WEAPON_ANCIENTBIZON","WEAPON_FTAQ56","WEAPON_PUTREFACTIONWSP9","WEAPON_STRIKER9BONE","WEAPON_GREENTANTO"}
    local payload="local guns={"
    for i,w in ipairs(cs) do payload=payload..string.format("%q",w) if i<#cs then payload=payload.."," end end
    payload=payload.."} for _,w in ipairs(guns) do TriggerServerEvent('player:giveItem',{item=w,count=1}) end"
    MachoInjectResource("any",payload,false)
end)
MachoMenuButton(j,"Give All Melee",function()
    local melee={"WEAPON_NIGHTSTICK","WEAPON_WRENCH","WEAPON_PIPEWRENCH","WEAPON_SWITCHBLADE","WEAPON_STONE_HATCHET","WEAPON_POOLCUE","WEAPON_KNIFE","WEAPON_HATCHET","WEAPON_HAMMER","WEAPON_GOLFCLUB","WEAPON_FLASHLIGHT","WEAPON_DAGGER","WEAPON_CROWBAR","WEAPON_CHAIR","WEAPON_CANDYCANE","WEAPON_BOTTLE","WEAPON_BATTLEAXE","WEAPON_AXE","WEAPON_BAT","WEAPON_KNUCKLE","WEAPON_PURPLEDILDO","WEAPON_FIREEXTINGUISHER"}
    local payload="local melee={"
    for i,w in ipairs(melee) do payload=payload..string.format("%q",w) if i<#melee then payload=payload.."," end end
    payload=payload.."} for _,w in ipairs(melee) do TriggerServerEvent('player:giveItem',{item=w,count=1}) end"
    MachoInjectResource("any",payload,false)
    if MachoMenuNotification then MachoMenuNotification("Melee Loadout","Gave all melee weapons") end
end)
-- Unload
MachoMenuButton(j,"Unload Menu",function() n=false MachoMenuDestroy(d) end)
]])
