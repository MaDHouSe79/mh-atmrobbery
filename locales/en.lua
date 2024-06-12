--[[ ===================================================== ]]--
--[[            MH ATM Robbery Script by MaDHouSe          ]]--
--[[ ===================================================== ]]--

local Translations = {
    notify = {
        ['failed'] = "Failed to plant the bomb",
        ['cooldown_active'] = "You have an ATM rob cooldown!",
        ['bom_explode_in_secs'] = "Bomb explode in %{secs}..",
        ['missing_item'] = "you need a %{item}!",
        ['police_notify'] = "ATM Robbery",
        ['payout_cash'] = "You received $%{amount} cash!",
        ['payout_markedbills'] = "You received $%{amount} marked bills!",
        ['payout_blackmoney'] = "You received $%{amount} black money!",
        ['already_robbed'] = "This ATM is already robbed..",
        ['atm_robbery_reset'] = "The atm robbery has been reset...",
        ['noCops'] = "There are no agents online",
    },
    menu = {
        ['rob_atm'] = "Rob ATM",
        ['use_atm'] = "Use ATM",
        ['pickup_cash'] = "Pick up cash",
    },
    progressbar = {
        ['place_bomb'] = "Placing Bomb...",
        ['taking_money'] = "Taking money...",
    },
}

Lang = Locale:new({
    phrases = Translations, 
    warnOnMissing = true
})
