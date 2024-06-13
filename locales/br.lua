--[[ ===================================================== ]]--
--[[            MH ATM Robbery Script by MaDHouSe          ]]--
--[[ ===================================================== ]]--

local Translations = {
    notify = {
        ['failed'] = "Falha em plantar a Bomba",
        ['cooldown_active'] = "Você está com um cooldown ativo!",
        ['bom_explode_in_secs'] = "A bomba vai explodir em %{segs}..",
        ['missing_item'] = "Você de uma %{item}!",
        ['police_notify'] = "Roubo de ATM",
        ['payout_cash'] = "Você recebeu $%{amount} reais!",
        ['payout_markedbills'] = "Você recebeu $%{amount} reais em notas marcadas!",
        ['payout_blackmoney'] = "Você recebeu $%{amount} reais em dinheiro sujo!",
        ['already_robbed'] = "Este ATM já foi roubado...",
        ['atm_robbery_reset'] = "O roubo de ATM resetou...",
        ['noCops'] = "Não há policiais suficientes em serviço",
    },
    menu = {
        ['rob_atm'] = "Roubar ATM",
        ['use_atm'] = "Usar ATM",
        ['pickup_cash'] = "Pegar o Dinheiro",
    },
    progressbar = {
        ['place_bomb'] = "Colocando a Bomba...",
        ['taking_money'] = "Pegando o Dinheiro...",
    },
}

Lang = Locale:new({
    phrases = Translations, 
    warnOnMissing = true
})
