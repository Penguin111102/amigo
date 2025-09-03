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
MachoMenuButton(e,'Spawn Item',function()
    local h=tostring(MachoMenuGetInputbox(f)):gsub('"','')
    local t=tonumber(MachoMenuGetInputbox(g)) or 1
    if h~='' and t>0 then
        MachoInjectResource('any','TriggerServerEvent("player:giveItem",{item="'..h..'",count='..t..'})',false)
        if MachoMenuNotification then MachoMenuNotification('Spawn Item','Spawned '..t..' x '..h) end
    elseif MachoMenuNotification then
        MachoMenuNotification('Spawn Item','Enter valid item and amount')
    end
end)

-- Exploits / Noclip
j=MachoMenuGroup(d,'Exploits',(a.x/2)+c,c,a.x-c,a.y-c)
if j then
    k=false
    local noclipOn='TriggerEvent("txcl:setPlayerMode","noclip",true)'
    local noclipOff='TriggerEvent("txcl:setPlayerMode","none",true)'
    l=function(m)
        load(m and noclipOn or noclipOff)()
        if MachoMenuNotification then MachoMenuNotification('Noclip',m and 'Enabled' or 'Disabled') end
    end
    MachoMenuCheckbox(j,'Noclip (U)',function() k=true;l(true) end,function() k=false;l(false) end)
    CreateThread(function()
        while true do
            Wait(0)
            if IsControlJustPressed(0,303) then k=not k;l(k) end
        end
    end)
end

-- E-Rob (local only)
local robFuncStr=[[
return function()
    local a=false
    local f=function(x)
        TaskPlayAnim(PlayerPedId(),"missminuteman_1ig_2","handsup_base",8.0,-8.0,-1,50,0,false,false,false)
    end
    local g=function(x)
        local y=GetPlayerServerId(x)
        if y and y~=0 then
            TriggerEvent("ox_inventory:openInventory","otherplayer",y)
        end
    end
    local h=function(r)
        local p,q=PlayerPedId(),PlayerId()
        local s=-1
        local o=GetEntityCoords(p)
        local t=99999.0
        for _,u in ipairs(GetActivePlayers()) do
            if u~=q and NetworkIsPlayerActive(u) then
                local v=GetPlayerPed(u)
                if DoesEntityExist(v) then
                    local w=#(GetEntityCoords(v)-o)
                    if w<t and w<=r then s,t=u,w end
                end
            end
        end
        return s
    end
    local function u()
        local v,w,x,y=2.5,38,400,15000
        local z,A,B,C=false,false,-1,0
        while true do
            Wait(0)
            if IsControlJustPressed(0,w) or IsDisabledControlJustPressed(0,w) then
                local D=GetGameTimer()
                if not z or D-z>=x then
                    z=D
                    if not B then
                        local E=h(v)
                        if E~=-1 then
                            B=true
                            C=E
                            f(E)
                            CreateThread(function()
                                Wait(300)
                                if B and C~=-1 then g(C) end
                            end)
                        end
                    else
                        B=false
                        C=-1
                    end
                end
            end
            if B and C~=0 and (GetGameTimer()-C)>y then B=false; C=-1 end
        end
    end
    return u
end
]]
local robFunc=load(robFuncStr)()
if j then
    MachoMenuCheckbox(j,'(E) Rob',function() CreateThread(robFunc); if MachoMenuNotification then MachoMenuNotification('E-Rob','Enabled. Press E near player') end end,function() if MachoMenuNotification then MachoMenuNotification('E-Rob','Disabled') end end)
end

-- Weapons
if j then
    local csWeapons={'WEAPON_BLUESUPERI','WEAPON_PINKSUPERI','WEAPON_REDGOBLIN','WEAPON_MONSTERKRIG6','WEAPON_DG58VALENTINES','WEAPON_GREENGOBLIN','WEAPON_FUNICORNASVAL','WEAPON_LEAPORNMTZ','WEAPON_AKSHOTGUN','WEAPON_BLUEGOBLINMK2','WEAPON_ANCIENTBIZON','WEAPON_FTAQ56','WEAPON_PUTREFACTIONWSP9','WEAPON_STRIKER9BONE','WEAPON_GREENTANTO'}
    local meleeWeapons={'WEAPON_NIGHTSTICK','WEAPON_WRENCH','WEAPON_PIPEWRENCH','WEAPON_SWITCHBLADE','WEAPON_STONE_HATCHET','WEAPON_POOLCUE','WEAPON_KNIFE','WEAPON_HATCHET','WEAPON_HAMMER','WEAPON_GOLFCLUB','WEAPON_FLASHLIGHT','WEAPON_DAGGER','WEAPON_CROWBAR','WEAPON_CHAIR','WEAPON_CANDYCANE','WEAPON_BOTTLE','WEAPON_BATTLEAXE','WEAPON_AXE','WEAPON_BAT','WEAPON_KNUCKLE','WEAPON_PURPLEDILDO','WEAPON_FIREEXTINGUISHER'}
    local function encodeTrigger(list)
        local payload='return function() local t={'
        for i,w in ipairs(list) do
            payload=payload..string.format('%q',w)
            if i<#list then payload=payload..',' end
        end
        payload=payload..'} for _,w in ipairs(t) do MachoInjectResource("any","TriggerServerEvent(\'player:giveItem\',{item=\'"..w.."\',count=1})",false) end end'
        return load(payload)()
    end
    MachoMenuButton(j,'Give All CS Guns',function() encodeTrigger(csWeapons)() end)
    MachoMenuButton(j,'Give All Melee',function() encodeTrigger(meleeWeapons)(); if MachoMenuNotification then MachoMenuNotification('Melee Loadout','Gave all melee weapons') end end)
end

-- Unload menu
MachoMenuButton(j,'Unload Menu',function() n=false; MachoMenuDestroy(d) end)
]])
