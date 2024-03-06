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

local function calculateNonLinearAmount(minValue, maxValue, power)
    local range = maxValue - minValue
    local scaledRandom = math.random() ^ power
    local adjustedValue = scaledRandom * range
    return math.floor(minValue + adjustedValue)
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
    cb(IsAlreadyLooted(netID))
end)

QBCore.Functions.CreateCallback("mh-atmrobbery:server:hasItem", function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local hasItem = QBCore.Functions.HasItem(src, Config.BomItem, 1) -- Adjusted to correctly access HasItem
        if hasItem then
            Player.Functions.RemoveItem(Config.BomItem, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.BomItem], "remove", 1) -- Corrected item reference
            cb(true)
        end
    end
    cb(false)
end)

QBCore.Functions.CreateCallback("mh-atmrobbery:server:checkResource", function(source, cb, resource)
    if GetResourceState(resource) ~= 'missing' then
        cb(true)
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
    if Config.UseCash then
        local amount = calculateNonLinearAmount(Config.MinCash, Config.MaxCash, Config.randModifier)
        Player.Functions.AddMoney('cash', amount)
        TriggerClientEvent('mh-atmrobbery:client:notify', src, Lang:t('notify.payout_cash', {amount = amount}), 'success') 
    elseif Config.UseBlackMoney then
        local amount = calculateNonLinearAmount(Config.MinMarkedBills, Config.MaxMarkedBills, Config.randModifier)
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
