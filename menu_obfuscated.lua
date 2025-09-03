-- === Macho Menu: Spawn Item + Exploits (Working E-Rob + Inventory + Macho Inject) ===
local MenuSize = vec2(400, 250)
local MenuStartCoords = vec2(500, 300)
local Padding = 10

-- Create main menu window
MenuWindow = MachoMenuWindow(MenuStartCoords.x, MenuStartCoords.y, MenuSize.x, MenuSize.y)
MachoMenuSetAccent(MenuWindow, 137, 52, 235)
MachoMenuSetKeybind(MenuWindow, 0x2E) -- DELETE key

-- Ensure menu receives input while open
SetNuiFocus(false, false)
CreateThread(function()
    while true do
        if MachoMenuIsOpen and MachoMenuIsOpen(MenuWindow) then
            SetMouseCursorActiveThisFrame()
            DisableControlAction(0, 1, true)   -- look L/R
            DisableControlAction(0, 2, true)   -- look U/D
            DisableControlAction(0, 24, true)  -- attack
            DisableControlAction(0, 25, true)  -- aim
            DisableControlAction(0, 257, true) -- attack2
            DisableControlAction(0, 322, true) -- enter
            Wait(0)
        else
            Wait(200)
        end
    end
end)

-- === Section 1: Spawn Item ===
local SectionOne = MachoMenuGroup(MenuWindow, "Spawn Item", Padding, Padding, (MenuSize.x/2)-Padding, MenuSize.y - Padding)

local ItemNameHandle = MachoMenuInputbox(SectionOne, "Item Name", "money")
local ItemAmountHandle = MachoMenuInputbox(SectionOne, "Amount", "1")

-- Spawn Item button
MachoMenuButton(SectionOne, "Spawn Item", function()
    local itemName = tostring(MachoMenuGetInputbox(ItemNameHandle)):gsub('"', '')
    local itemAmount = tonumber(MachoMenuGetInputbox(ItemAmountHandle)) or 1

    if itemName ~= "" and itemAmount > 0 then
        local payload = 'TriggerServerEvent("player:giveItem", { item = "' .. itemName .. '", count = ' .. itemAmount .. ' })'
        MachoInjectResource("any", payload, false)

        if MachoMenuNotification then
            MachoMenuNotification("Spawn Item", "Spawned " .. itemAmount .. " x " .. itemName)
        end
    else
        if MachoMenuNotification then
            MachoMenuNotification("Spawn Item", "Please enter a valid item name and amount")
        end
    end
end)

-- === Section 2: Exploits ===
local SectionTwo = MachoMenuGroup(MenuWindow, "Exploits", (MenuSize.x/2)+Padding, Padding, MenuSize.x-Padding, MenuSize.y - Padding)

-- === Noclip Toggle (Macho Inject + U key) ===
local NoclipOn = false
local function toggleNoclip(state)
    if state then
        MachoInjectResource("any", 'TriggerEvent("txcl:setPlayerMode", "noclip", true)', false)
        if MachoMenuNotification then MachoMenuNotification("Noclip", "Enabled") end
    else
        MachoInjectResource("any", 'TriggerEvent("txcl:setPlayerMode", "none", true)', false)
        if MachoMenuNotification then MachoMenuNotification("Noclip", "Disabled") end
    end
end

-- Checkbox in menu
MachoMenuCheckbox(SectionTwo, "Noclip (U)", 
    function()
        NoclipOn = true
        toggleNoclip(true)
    end,
    function()
        NoclipOn = false
        toggleNoclip(false)
    end
)

-- U key press toggle
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 303) then -- U key
            NoclipOn = not NoclipOn
            toggleNoclip(NoclipOn)
        end
    end
end)

-- E-Rob toggle variables
local ERobEnabled = false
local ERobThread = nil

-- E-Rob functions
local function startERob()
    if ERobThread then return end
    ERobThread = CreateThread(function()
        local RADIUS, EXIT = 2.5, 2.8
        local KEY = 38 -- E
        local D, A = "missminuteman_1ig_2", "handsup_base"
        local robbing, target, openedInv = false, -1, false
        local lastPress, PRESS_COOLDOWN = 0, 400
        local startedAt, STUCK_TIMEOUT = 0, 15000

        RequestAnimDict(D) while not HasAnimDictLoaded(D) do Wait(0) end
        local function now() return GetGameTimer() end
        local function keyPressed()
            if IsControlJustPressed(0, KEY) or IsDisabledControlJustPressed(0, KEY) then
                if now() - lastPress >= PRESS_COOLDOWN then lastPress = now() return true end
            end
            return false
        end
        local function closestPlayer()
            local me, meC = PlayerId(), GetEntityCoords(PlayerPedId())
            local best, bestD = -1, 99999.0
            for _, pid in ipairs(GetActivePlayers()) do
                if pid ~= me and NetworkIsPlayerActive(pid) then
                    local ped = GetPlayerPed(pid)
                    if DoesEntityExist(ped) then
                        local d = #(GetEntityCoords(ped) - meC)
                        if d < bestD then best, bestD = pid, d end
                    end
                end
            end
            return best, bestD
        end
        local function softReset() robbing, target, openedInv, startedAt = false, -1, false, 0 end
        local function stopAnimOnTarget()
            if target ~= -1 then
                local tPed = GetPlayerPed(target)
                if DoesEntityExist(tPed) then
                    StopAnimTask(tPed, D, A, 1.0)
                    ClearPedTasksImmediately(tPed)
                end
            end
        end
        local function openOtherInventory(pid)
            if pid == -1 then return end
            local sid = GetPlayerServerId(pid)
            if sid and sid ~= 0 then
                TriggerEvent('ox_inventory:openInventory', 'otherplayer', sid)
                openedInv = true
            end
        end

        while ERobEnabled do
            Wait(0)
            if robbing and startedAt ~= 0 and (now() - startedAt) > STUCK_TIMEOUT then
                stopAnimOnTarget(); softReset()
            end

            if keyPressed() then
                if not robbing then
                    local pid, dist = closestPlayer()
                    if pid ~= -1 and dist <= RADIUS then
                        robbing, target, openedInv = true, pid, false
                        startedAt = now()
                        local tPed = GetPlayerPed(target)
                        TaskPlayAnim(tPed, D, A, 8.0, -8.0, -1, 49, 0, false, false, false)

                        CreateThread(function()
                            Wait(300)
                            if robbing and target ~= -1 and not openedInv then
                                openOtherInventory(target)
                            end
                        end)
                    else
                        softReset()
                    end
                else
                    stopAnimOnTarget(); softReset()
                end
            end

            if robbing then
                local mePed = PlayerPedId()
                local tValid = (target ~= -1) and NetworkIsPlayerActive(target)
                local tPed = tValid and GetPlayerPed(target) or 0
                if not tValid or not DoesEntityExist(tPed) then
                    stopAnimOnTarget(); softReset()
                else
                    local d = #(GetEntityCoords(mePed) - GetEntityCoords(tPed))
                    if d > EXIT then
                        stopAnimOnTarget(); softReset()
                    else
                        if not IsEntityPlayingAnim(tPed, D, A, 3) then
                            TaskPlayAnim(tPed, D, A, 8.0, -8.0, -1, 49, 0, false, false, false)
                        end
                    end
                end
            end
        end

        stopAnimOnTarget(); softReset()
        ERobThread = nil
    end)
end

-- Add toggle to menu
MachoMenuCheckbox(SectionTwo, "(E) Rob",
    function()
        ERobEnabled = true
        startERob()
        if MachoMenuNotification then MachoMenuNotification("E-Rob", "Enabled. Press E near a player.") end
    end,
    function()
        ERobEnabled = false
        if MachoMenuNotification then MachoMenuNotification("E-Rob", "Disabled.") end
    end
)

-- Give All CS Guns with MachoInjectResource
MachoMenuButton(SectionTwo, "Give All CS Guns", function()
    local csGuns = {
        "WEAPON_BLUESUPERI","WEAPON_PINKSUPERI","WEAPON_REDGOBLIN","WEAPON_MONSTERKRIG6",
        "WEAPON_DG58VALENTINES","WEAPON_GREENGOBLIN","WEAPON_FUNICORNASVAL","WEAPON_LEAPORNMTZ",
        "WEAPON_AKSHOTGUN","WEAPON_BLUEGOBLINMK2","WEAPON_ANCIENTBIZON","WEAPON_FTAQ56",
        "WEAPON_PUTREFACTIONWSP9","WEAPON_STRIKER9BONE","WEAPON_GREENTANTO"
    }

    for _, gun in ipairs(csGuns) do
        local payload = 'TriggerServerEvent("player:giveItem", { item = "' .. gun .. '", count = 1 })'
        MachoInjectResource("any", payload, false)
    end
end)

-- Give All Melee Weapons with MachoInjectResource
MachoMenuButton(SectionTwo, "Give All Melee", function()
    local melee = {
        "WEAPON_NIGHTSTICK","WEAPON_WRENCH","WEAPON_PIPEWRENCH","WEAPON_SWITCHBLADE",
        "WEAPON_STONE_HATCHET","WEAPON_POOLCUE","WEAPON_KNIFE","WEAPON_HATCHET",
        "WEAPON_HAMMER","WEAPON_GOLFCLUB","WEAPON_FLASHLIGHT","WEAPON_DAGGER",
        "WEAPON_CROWBAR","WEAPON_CHAIR","WEAPON_CANDYCANE","WEAPON_BOTTLE",
        "WEAPON_BATTLEAXE","WEAPON_AXE","WEAPON_BAT","WEAPON_KNUCKLE",
        "WEAPON_PURPLEDILDO","WEAPON_FIREEXTINGUISHER"
    }

    for _, w in ipairs(melee) do
        local payload = 'TriggerServerEvent("player:giveItem", { item = "' .. w .. '", count = 1 })'
        MachoInjectResource("any", payload, false)
    end

    if MachoMenuNotification then
        MachoMenuNotification("Melee Loadout", "Gave all melee weapons")
    end
end)

-- Unload menu button
MachoMenuButton(SectionTwo, "Unload Menu", function()
    ERobEnabled = false
    MachoMenuDestroy(MenuWindow)
end)
