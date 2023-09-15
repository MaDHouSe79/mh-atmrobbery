--[[ ===================================================== ]]--
--[[            MH ATM Robbery Script by MaDHouSe          ]]--
--[[ ===================================================== ]]--

Config = {}

-- Default:(qb-core), you can also use (roda-notify/okokNotify)
Config.Notify = "qb-core"                      
Config.NotifyTitle = "ATM Robbery"

-- For Cash
Config.UseCash = true           
Config.MinCash = 500
Config.MaxCash = 2000

-- For MarkedBills
Config.UseBlackMoney = false
Config.MinMarkedBills = 1 
Config.MaxMarkedBills = 5
Config.MinMarkedWorth = 500
Config.MaxMarkedWorth = 1500

-- Use item
Config.UseItem = false
Config.BomItem = "weapon_stickybomb"

-- Progressbar timers
Config.TakeMoneyTime = 10000
Config.PlaceBompTime = 15000

-- cooldown, so players can't use it the hole time. make sure you add at least more than 300 secs
-- (5 * 1000) = 5 sec
-- (300 * 1000) = 5 min
-- (3600 * 1000) = 1 hour 
Config.CoolDownTime = 3600

-- if true a notify to all players will be send with a message that the atm robbery has been reset...
Config.SendResetMessage = true

Config.CashPiles = {
    "bkr_prop_bkr_cashpile_02",
}

Config.Models = {
    'prop_atm_02',
    'prop_atm_03',
    'prop_fleeca_atm',
}

Config.IgnoreJob = {
    ["police"] = true,
    ["ambulance"] = true,
    ["mechanic"] = true,
}