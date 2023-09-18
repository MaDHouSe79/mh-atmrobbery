--[[ ===================================================== ]]--
--[[            MH ATM Robbery Script by MaDHouSe          ]]--
--[[ ===================================================== ]]--

local QBCore = exports['qb-core']:GetCoreObject()
local num = nil
local isTakingMoney = false
local lootedAtms = {}
local cooldown = false

---Notify player
---@param message the notify message
---@param type the type of message
---@param time the show time of the message
---@return Notify
local function Notify(message, type, time)
    if Config.Notify == "okokNotify" then
        exports['okokNotify']:Alert(Config.NotifyTitle, message, time, type)
    elseif Config.Notify == "qb-core" then
        if type == "info" then type = "primary" end
        QBCore.Functions.Notify({text = Config.NotifyTitle, caption = message}, type, time)
    elseif Config.Notify == "roda-notify" then
        exports['Roda_Notifications']:showNotify(Config.NotifyTitle, message, type, time)
    else
        print(Lang:t('info.not_supported',{resource = GetCurrentResourceName()}))
    end
end

---Reset the system
local function Reset()
    for k, v in pairs(lootedAtms) do
        v = nil
    end
    lootedAtms = {}
end

---Actived a cooldown
local function RunCoolDown()
    cooldown = true
    SetTimeout(Config.CoolDownTime * 1000, function()
        cooldown = false
        Reset()
    end)
end

---A check to see if this atm entity is already looted.
---@param entity id
local function IsAtmAlreadyLooted(entity)
    local looted = false
    for k, v in pairs(lootedAtms) do
        if v.atm == entity then
            looted = true
        end
    end
    return looted
end

---Set an atm as looted.
---@param entity id
local function AtmHasLooted(entity)
    if IsAtmAlreadyLooted(entity) then return end
    lootedAtms[#lootedAtms + 1] = {atm = entity}
    TriggerServerEvent('mh-atmrobbery:server:setlooted', entity)
end

---Get the distance between 2 coords
---@param pos1 location of position 1
---@param pos2 location of position 2
---@return int
local function GetDistance(pos1, pos2)
    return #(vector3(pos1.x, pos1.y, pos1.z) - vector3(pos2.x, pos2.y, pos2.z))
end

---Place a cash prop on the ground
---@param atmCoords location of the current atm
---@param dropCoords location of the current position from the player.
local function AddCashOnGround(atmCoords, dropCoords)
    local cashpile = Config.CashPiles[math.random(1, #Config.CashPiles)]
    local hash = GetHashKey(cashpile)
    local cashProp = CreateObject(hash, dropCoords.x, dropCoords.y, dropCoords.z - 1.4, true, true, false)
    Citizen.Wait(1000)
    FreezeEntityPosition(cashProp, true)
end

---Add a bom in the current atm
---@param atmCoords location of the current atm
---@param dropCoords location of the current position from the player.
---@param entity id
local function AddBom(atmCoords, entity, dropCoords)
    GiveWeaponToPed(PlayerPedId(), GetHashKey("weapon_stickybomb"), 1, false, true)
    local heading = GetEntityHeading(atmCoords)-- before this is was-> 218.5                                                                   
    TaskPlantBomb(PlayerPedId(), atmCoords, heading)
    Citizen.Wait(1500)
    local time = 5
    while time > 0 do 
	QBCore.Functions.Notify(Lang:t('notify.bom_explode_in_secs', {secs = time}))
	Citizen.Wait(1000)
	time = time - 1
    end
    FreezeEntityPosition(entity, false)
    AddExplosion(atmCoords.x, atmCoords.y, atmCoords.z, EXPLOSION_STICKYBOMB, 4.0, true, false, 20.0)
    AddCashOnGround(atmCoords, dropCoords)
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        num = nil
        isTakingMoney = false
        lootedAtms = {}
        cooldown = false
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        num = nil
        isTakingMoney = false
        lootedAtms = {}
        cooldown = false
    end
end)

RegisterNetEvent('mh-atmrobbery:client:notify', function(message, type, time)
    Notify(message, type, time)
end)

RegisterNetEvent('mh-atmrobbery:client:reset', function()
    Reset()
end)

RegisterNetEvent('mh-atmrobbery:client:takemoney', function(entity)
    local playerPed = PlayerPedId()
    TaskTurnPedToFaceEntity(PlayerPedId(), entity, 5000)
    isTakingMoney = true
    Citizen.Wait(1000)
    QBCore.Functions.Progressbar("take_money", Lang:t('progressbar.taking_money'), Config.TakeMoneyTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@heists@ornate_bank@grab_cash_heels",
        anim = "grab",
        flags = 16,
    }, {
       model = "prop_cs_heist_bag_02",
       bone = 57005,
       coords = { x = -0.005, y = 0.00, z = -0.16 },
       rotation = { x = 250.0, y = -30.0, z = 0.0 },
    }, {}, function() -- Done
        StopAnimTask(playerPed, "anim@heists@ornate_bank@grab_cash_heels", "grab", 1.0)
	SetPedComponentVariation(playerPed, 5, 47, 0, 0)
        isTakingMoney = false
        Citizen.Wait(1000)
        ResetPedMovementClipset(playerPed, 0)
        ResetPedWeaponMovementClipset(playerPed)
        ResetPedStrafeClipset(playerPed)
        DeleteEntity(entity)
        TriggerServerEvent('mh-atmrobbery:server:payout')
        TriggerServerEvent("police:server:policeAlert", Lang:t('notify.police_notify'))
    end, function() -- Cancel
        ClearPedTasks(playerPed)
        isTakingMoney = false
        StopAnimTask(playerPed, "anim@heists@ornate_bank@grab_cash_heels", "grab", 1.0)
	SetPedComponentVariation(playerPed, 5, 47, 0, 0)
    end)
end)

RegisterNetEvent('mh-atmrobbery:client:start', function(entity)
    if cooldown then return QBCore.Functions.Notify(Lang:t('notify.cooldown_active'), 'error', 7500) end
    QBCore.Functions.TriggerCallback('mh-atmrobbery:server:canirobatm', function(state)
        if state == false then
            local atmCoords = GetEntityCoords(entity)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed, true)
            for _, v in pairs(Config.Models) do
                local hash = GetHashKey(v)
                local atm = IsObjectNearPoint(hash, playerCoords.x, playerCoords.y, playerCoords.z, 1.5)
                if atm then
                    RunCoolDown()
                    AtmHasLooted(entity)
                    TaskTurnPedToFaceEntity(PlayerPedId(), entity, 5000)
                    Citizen.Wait(1000)
                    if Config.UseItem then
                        QBCore.Functions.TriggerCallback('mh-atmrobbery:server:hasItem', function(hasBom)
                            if hasBom then
                                local dropCoords = GetEntityCoords(playerPed)
                                QBCore.Functions.Progressbar('rob_atm', Lang:t('progressbar.place_bomb'), Config.PlaceBompTime, false, true, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {
                                    animDict = 'anim@gangops@facility@servers@',
                                    anim = 'hotwire',
                                    flags = 16,
                                }, {}, {}, function() 
                                    ClearPedTasks(ped)
                                    AddBom(atmCoords, entity, dropCoords)
                                end, function() 
                                    ClearPedTasks(ped)
                                    QBCore.Functions.Notify(Lang:t('notify.failed'), 'error', 5000)
                                end)
                            else
                                QBCore.Functions.Notify(Lang:t('notify.missing_item', {item = Config.BomItem}), 'error', 5000)
                            end
                        end)
                    else
                        local dropCoords = GetEntityCoords(playerPed)
                        QBCore.Functions.Progressbar('rob_atm', Lang:t('progressbar.place_bomb'), 10000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {
                            animDict = 'anim@gangops@facility@servers@',
                            anim = 'hotwire',
                            flags = 16,
                        }, {}, {}, function() 
                            ClearPedTasks(playerPed)
                            AddBom(atmCoords, entity, dropCoords)
                        end, function() 
                            ClearPedTasks(playerPed)
                            QBCore.Functions.Notify(Lang:t('notify.failed'), 'error', 5000)
                        end)
                    end
                end
            end
        else
            QBCore.Functions.Notify(Lang:t('notify.already_robbed'), 'error', 5000)
        end
    end, entity)
end)

CreateThread(function()
    exports['qb-target']:AddTargetModel(Config.Models, {
        options = {
            { 
                type = "client",
                event = "mh-atmrobbery:client:start",
                icon = "fas fa-screwdriver",
                label = Lang:t('menu.rob_atm'),
                action = function(entity)
                    if IsPedAPlayer(entity) then return false end
                    if IsAtmAlreadyLooted(entity) then return false end
                    TriggerEvent('mh-atmrobbery:client:start', entity)
                end,
                canInteract = function(entity, distance, data)
                    if IsPedAPlayer(entity) then return false end
                    if IsAtmAlreadyLooted(entity) then return false end
                    return true
                end
            },
            {
                event = 'qb-atms:server:enteratm',
                type = 'server',
                icon = "fas fa-credit-card",
                label = Lang:t('menu.use_atm'),
            },
        },
        distance = 1.5 
    })
    exports['qb-target']:AddTargetModel(Config.CashPiles, {
        options = {
            { 
                type = "client",
                event = "mh-atmrobbery:client:takemoney",
                icon = "fas fa-screwdriver",
                label = Lang:t('menu.pickup_cash'),
                action = function(entity)
                    if IsPedAPlayer(entity) then return false end
                    TriggerEvent('mh-atmrobbery:client:takemoney', entity)
                end,
                canInteract = function(entity, distance, data)
                    if IsPedAPlayer(entity) then return false end
                    return true
                end
            },
        },
        distance = 1.5 
    })
end)

Citizen.CreateThread( function()
    while true do 
        Citizen.Wait(1)
        if isTakingMoney then
            local playerPed = PlayerPedId()
            RequestAnimSet("move_ped_crouched")
            while (not HasAnimSetLoaded("move_ped_crouched")) do 
                Citizen.Wait(100)
            end 
            SetPedMovementClipset(playerPed, "move_ped_crouched", 0.25)
        end
    end
end)
