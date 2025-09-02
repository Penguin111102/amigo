-- E-Rob (fully obfuscated)
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
