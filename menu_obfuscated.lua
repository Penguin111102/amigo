-- menu_obfuscated_fixed.lua
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

-- E-Rob (fully obfuscated & fixed)
MachoInjectResource("any",[[
local a,b=false,nil

RegisterNetEvent('rob:requestHandsUp', function()
    local c=PlayerPedId()
    local d,e="missminuteman_1ig_2","handsup_base"
    RequestAnimDict(d)
    while not HasAnimDictLoaded(d) do Wait(0) end
    TaskPlayAnim(c,d,e,8.0,-8.0,-1,50,0,false,false,false)
end)

local function f(g) TriggerServerEvent('rob:requestHandsUp',g) end
local function h(i)
    local j=GetPlayerServerId(i)
    if j and j~=0 then TriggerEvent('ox_inventory:openInventory','otherplayer',j) end
end

local function k(l)
    local m,n=PlayerPedId(),PlayerId()
    local o=GetEntityCoords(m)
    local p,q=-1,99999.0
    for _,r in ipairs(GetActivePlayers()) do
        if r~=n and NetworkIsPlayerActive(r) then
            local s=GetPlayerPed(r)
            if DoesEntityExist(s) then
                local t=#(GetEntityCoords(s)-o)
                if t<q and t<=l then p,q=r,t end
            end
        end
    end
    return p
end

local function u()
    local v,w,x,y=2.5,38,400,15000
    local z,A,B,C=false,false,-1,0
    while a do Wait(0)
        if IsControlJustPressed(0,w) or IsDisabledControlJustPressed(0,w) then
            local D=GetGameTimer()
            if not z or D-z>=x then
                z=D
                if not B then
                    local E=k(v)
                    if E~=-1 then
                        B=true
                        C=E
                        local F=GetPlayerServerId(E)
                        f(F)
                        CreateThread(function() Wait(300) if B and C~=-1 then h(C) end end)
                    end
                else B=false C=-1 end
            end
        end
        if B and C~=0 and (GetGameTimer()-C)>y then B=false C=-1 end
    end
end

MachoMenuCheckbox(j,"(E) Rob",function()
    a=true
    CreateThread(u)
    if MachoMenuNotification then MachoMenuNotification("E-Rob","Enabled. Press E near player") end
end,function()
    a=false
    if MachoMenuNotification then MachoMenuNotification("E-Rob","Disabled") end
end)
]],false)

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
