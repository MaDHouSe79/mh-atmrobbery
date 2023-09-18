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

local function IsAlreadyLooted(entity)
    local found = false
    if netEntities[entity] then found = true end
    return found
end

local function SetIsLooted(entity)
    if not netEntities[entity] then netEntities[entity] = true end
end

QBCore.Functions.CreateCallback("mh-atmrobbery:server:canirobatm", function(source, cb, netID)
    cb(IsAlreadyLooted(netID)) -- must return false to rob atm.
end)

QBCore.Functions.CreateCallback("mh-atmrobbery:server:hasItem", function(source, cb)
    local src = source
    local hasItem = QBCore.Functions.HasItem(src, Config.BomItem, 1)
    if hasItem then
        Player.Functions.RemoveItem(Config.BomItem, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[tmpData[i].name], "remove", 1)
        cb(true)
    else
        cb(false)
    end
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
    if Config.UseCash then
        local amount = math.random(Config.MinCash, Config.MaxCash)
        Player.Functions.AddMoney('cash', amount)
        TriggerClientEvent('mh-atmrobbery:client:notify', src, Lang:t('notify.payout_cash', {amount = amount}), 'success') 
    elseif Config.UseBlackMoney then
        local amount = math.random(Config.MinMarkedBills, Config.MaxMarkedBills)
        local info = {worth = math.random(Config.MinMarkedWorth, Config.MaxMarkedWorth)}
        Player.Functions.AddItem('markedbills', amount, false, info)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "add", amount)
        TriggerClientEvent('mh-atmrobbery:client:notify', src, Lang:t('notify.payout_markedbills', {amount = amount}), 'success') 
    end
end)

RegisterNetEvent('mh-atmrobbery:server:setlooted', function(entity)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not IsAlreadyLooted(entity) then SetIsLooted(entity) end
end)
