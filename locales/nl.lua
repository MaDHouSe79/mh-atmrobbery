--[[ ===================================================== ]]--
--[[            MH ATM Robbery Script by MaDHouSe          ]]--
--[[ ===================================================== ]]--

local Translations = {
    notify = {
        ['failed'] = "Het is mislukt om de bom te plaatsen",
        ['cooldown_active'] = "Je hebt een atm rob cooldown!",
        ['bom_explode_in_secs'] = "Bom explode in %{secs}..",
        ['missing_item'] = "Je hebt een %{item} nodig",
        ['police_notify'] = "ATM Robbery",
        ['payout_cash'] = "Je kreeg €%{amount} cash!",
        ['payout_markedbills'] = "Je kreeg €%{amount} zwartgeld!",
        ['payout_blackmoney'] = "Je kreeg €%{amount} zwart money!",
        ['already_robbed'] = "Deze ATM is al overvallen..",
        ['atm_robbery_reset'] = "The atm overvallen zijn gereset...",
        ['noCops'] = "Er zijn geen agenten online",
    },
    menu = {
        ['rob_atm'] = "Beroof ATM",
        ['use_atm'] = "Gebruik ATM",
        ['pickup_cash'] = "Raap geld op",
    },
    progressbar = {
        ['place_bomb'] = "Bom Plaatsen...",
        ['taking_money'] = "Taking money...",
    },
}

Lang = Locale:new({
    phrases = Translations, 
    warnOnMissing = true
})
