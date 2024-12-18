--[[ ===================================================== ]]--
--[[            MH ATM Robbery Script by MaDHouSe          ]]--
--[[ ===================================================== ]]--
local QBCore = exports['qb-core']:GetCoreObject()
local resetTimer = 900 -- 900 -- 15 min
local netEntities = {}

local function Reset()
    Citizen.SetTimeout(resetTimer * 1000, function()
        netEntities = {}
        if Config.SendResetMessage then
            TriggerClientEvent('mh-atmrobbery:client:notify', -1, Lang:t('notify.atm_robbery_reset'), "success", 5000)
            TriggerClientEvent('mh-atmrobbery:client:reset', -1)
        end
        Reset()
    end)
end

local function CountCops()
    local online = 0
    for k, id in pairs(QBCore.Functions.GetPlayers()) do
        local target = QBCore.Functions.GetPlayer(id)
        if target.PlayerData.job.name == "police" and target.PlayerData.job.onduty then
            online = online + 1
        end
    end
    return online
end

local function IsAlreadyLooted(entity)
    local found = false
    if netEntities[entity] then found = true end
    return found
end

local function SetIsLooted(entity)
    if not netEntities[entity] then netEntities[entity] = true end
end

QBCore.Functions.CreateCallback("mh-atmrobbery:server:CountCops", function(source, cb)
    cb(CountCops())
end)

QBCore.Functions.CreateCallback("mh-atmrobbery:server:canirobatm", function(source, cb, netID)
    cb(IsAlreadyLooted(netID))
end)

QBCore.Functions.CreateCallback("mh-atmrobbery:server:hasItem", function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local hasItem = QBCore.Functions.HasItem(src, Config.BomItem, 1) -- Adjusted to correctly access HasItem
        if hasItem then
            Player.Functions.RemoveItem(Config.BomItem, 1)
            TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[Config.BomItem], "remove", 1) -- Corrected item reference
            cb(true)
        end
    end
    cb(false)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        netEntities = {}
        Reset()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        netEntities = {}
        Reset()
    end
end)

RegisterNetEvent('mh-atmrobbery:server:payout', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Config.UseCash and not Config.UseMarkedBills and not Config.UseBlackMoney then
        local amount = math.floor(math.random(Config.MinCash ,Config.MaxCash))
        Player.Functions.AddMoney('cash', amount)
        TriggerClientEvent('mh-atmrobbery:client:notify', src, Lang:t('notify.payout_cash', {amount = amount}), 'success') 
    elseif Config.UseMarkedBills and not Config.UseBlackMoney then
        local amount = math.floor(math.random(Config.MinMarkedWorth, Config.MaxMarkedWorth))
        local info = {worth = amount}
        Player.Functions.AddItem('markedbills', 1, false, info)
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "add", 1)
        TriggerClientEvent('mh-atmrobbery:client:notify', src, Lang:t('notify.payout_markedbills', {amount = amount}), 'success') 
    elseif Config.UseBlackMoney and not Config.UseMarkedBills then
        local amount = math.floor(math.random(Config.MinBlackMoney, Config.MaxBlackMoney))
        Player.Functions.AddItem('black_money', amount, false, info)
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items['black_money'], "add", amount)
        TriggerClientEvent('mh-atmrobbery:client:notify', src, Lang:t('notify.payout_blackmoney', {amount = amount}), 'success')
    end
end)

RegisterNetEvent('mh-atmrobbery:server:setlooted', function(entity)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not IsAlreadyLooted(entity) then SetIsLooted(entity) end
end)
