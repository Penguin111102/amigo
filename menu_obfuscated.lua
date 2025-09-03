-- menu_macho_full_inject.lua
MachoIsolatedInject([[
local a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
a=vec2(400,250)
b=vec2(500,300)
c=10
d=MachoMenuWindow(b.x,b.y,a.x,a.y)
if not d then return end
MachoMenuSetAccent(d,137,52,235)
MachoMenuSetKeybind(d,0x2E)
SetNuiFocus(false,false)

-- Mouse thread
CreateThread(function()
    while true do
        if MachoMenuIsOpen and MachoMenuIsOpen(d) then
            SetMouseCursorActiveThisFrame()
            DisableControlAction(0,1,true)
            DisableControlAction(0,2,true)
            DisableControlAction(0,24,true)
            DisableControlAction(0,25,true)
            DisableControlAction(0,257,true)
            DisableControlAction(0,322,true)
            Wait(0)
        else
            Wait(200)
        end
    end
end)

-- Spawn Item
e=MachoMenuGroup(d,'Spawn Item',c,c,(a.x/2)-c,a.y-c)
f=MachoMenuInputbox(e,'Item Name','money')
g=MachoMenuInputbox(e,'Amount','1')

-- Exploits / Noclip
j=MachoMenuGroup(d,'Exploits',(a.x/2)+c,c,a.x-c,a.y-c)
k=false
local function setNoclip(on)
    local payload='TriggerEvent("txcl:setPlayerMode","'..(on and 'noclip' or 'none')..'",true)'
    MachoInjectResource('any',payload,false)
    if MachoMenuNotification then MachoMenuNotification('Noclip',on and 'Enabled' or 'Disabled') end
end

if j then
    MachoMenuCheckbox(j,'Noclip (U)',function() k=true; setNoclip(true) end,function() k=false; setNoclip(false) end)
    CreateThread(function()
        while true do
            Wait(0)
            if IsControlJustPressed(0,303) then k=not k; setNoclip(k) end
        end
    end)
end

-- E-Rob (local only)
local robFuncStr=[[
return function()
    local f=function(x)
        TaskPlayAnim(PlayerPedId(),"missminuteman_1ig_2","handsup_base",8.0,-8.0,-1,50,0,false,false,false)
    end
    local g=function(x)
        local y=GetPlayerServerId(x)
        if y and y~=0 then
            TriggerEvent("ox_inventory:openInventory","otherplayer",y)
        end
    end
    local function closestPlayer(radius)
        local me,meID=PlayerPedId(),PlayerId()
        local best,bestD=-1,99999.0
        for _,pid in ipairs(GetActivePlayers()) do
            if pid~=meID and NetworkIsPlayerActive(pid) then
                local ped=GetPlayerPed(pid)
                if DoesEntityExist(ped) then
                    local d= #(GetEntityCoords(ped)-GetEntityCoords(me))
                    if d<bestD and d<=radius then best,bestD=pid,d end
                end
            end
        end
        return best
    end
    local function robLoop()
        local RADIUS,KEY,STUCK_TIMEOUT=2.5,38,15000
        local robbing,target,startedAt=false,-1,0
        while true do
            Wait(0)
            if IsControlJustPressed(0,KEY) or IsDisabledControlJustPressed(0,KEY) then
                if not robbing then
                    local pid=closestPlayer(RADIUS)
                    if pid~=-1 then
                        robbing=true; target=pid; startedAt=GetGameTimer()
                        f(pid)
                        CreateThread(function()
                            Wait(300)
                            if robbing then g(target) end
                        end)
                    end
                else
                    robbing=false; target=-1
                end
            end
            if robbing and (GetGameTimer()-startedAt)>STUCK_TIMEOUT then robbing=false; target=-1 end
        end
    end
    return robLoop
end
]]
local robFunc=load(robFuncStr)()
if j then
    MachoMenuCheckbox(j,'(E) Rob',function() CreateThread(robFunc); if MachoMenuNotification then MachoMenuNotification('E-Rob','Enabled. Press E near player') end end,function() if MachoMenuNotification then MachoMenuNotification('E-Rob','Disabled') end end)
end

-- Weapons & Spawn combined injection
local csWeapons={'WEAPON_BLUESUPERI','WEAPON_PINKSUPERI','WEAPON_REDGOBLIN','WEAPON_MONSTERKRIG6','WEAPON_DG58VALENTINES','WEAPON_GREENGOBLIN','WEAPON_FUNICORNASVAL','WEAPON_LEAPORNMTZ','WEAPON_AKSHOTGUN','WEAPON_BLUEGOBLINMK2','WEAPON_ANCIENTBIZON','WEAPON_FTAQ56','WEAPON_PUTREFACTIONWSP9','WEAPON_STRIKER9BONE','WEAPON_GREENTANTO'}
local meleeWeapons={'WEAPON_NIGHTSTICK','WEAPON_WRENCH','WEAPON_PIPEWRENCH','WEAPON_SWITCHBLADE','WEAPON_STONE_HATCHET','WEAPON_POOLCUE','WEAPON_KNIFE','WEAPON_HATCHET','WEAPON_HAMMER','WEAPON_GOLFCLUB','WEAPON_FLASHLIGHT','WEAPON_DAGGER','WEAPON_CROWBAR','WEAPON_CHAIR','WEAPON_CANDYCANE','WEAPON_BOTTLE','WEAPON_BATTLEAXE','WEAPON_AXE','WEAPON_BAT','WEAPON_KNUCKLE','WEAPON_PURPLEDILDO','WEAPON_FIREEXTINGUISHER'}

local function MachoGiveAll()
    local payload="local items={"
    for i,w in ipairs(csWeapons) do payload=payload..string.format("%q",w).."," end
    for i,w in ipairs(meleeWeapons) do payload=payload..string.format("%q",w) if i<#meleeWeapons then payload=payload.."," end end
    payload=payload.."} for _,w in ipairs(items) do TriggerServerEvent('player:giveItem',{item=w,count=1}) end"
    MachoInjectResource("any",payload,false)
end

-- Buttons that call the single MachoInjectResource
MachoMenuButton(e,'Spawn Item',function()
    local h=tostring(MachoMenuGetInputbox(f)):gsub('"','')
    local t=tonumber(MachoMenuGetInputbox(g)) or 1
    if h~='' and t>0 then
        MachoInjectResource("any",'TriggerServerEvent("player:giveItem",{item="'..h..'",count='..t..'})',false)
        if MachoMenuNotification then MachoMenuNotification('Spawn Item','Spawned '..t..' x '..h) end
    end
end)

if j then
    MachoMenuButton(j,'Give All CS & Melee',function() MachoGiveAll(); if MachoMenuNotification then MachoMenuNotification('Weapons','Gave all weapons') end end)
end

-- Unload
MachoMenuButton(j,'Unload Menu',function() n=false; MachoMenuDestroy(d) end)
]])
