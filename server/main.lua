local ESX = exports['es_extended']:getSharedObject()

local function CountCops()
  local xPlayers = ESX.GetExtendedPlayers()
  local cops = 0
  for _, xPlayer in pairs(xPlayers) do
    if xPlayer and xPlayer.job and xPlayer.job.name == Config.PoliceJobName then
      cops = cops + 1
    end
  end
  return cops
end

ESX.RegisterServerCallback('ccp_moneywash:getUiData', function(source, cb, laundryIndex)
  local xPlayer = ESX.GetPlayerFromId(source)
  if not xPlayer then cb({ black = 0, cops = 0, fee = 0.0, presets = Config.Presets }) return end

  local laundry = Config.Laundries[tonumber(laundryIndex)]
  local fee = (laundry and laundry.fee) or 0.0

  local black = 0
  local acct = xPlayer.getAccount('black_money')
  if acct and acct.money then black = acct.money end

  cb({
    black = black,
    cops = CountCops(),
    fee = fee,
    presets = Config.Presets
  })
end)

ESX.RegisterServerCallback('ccp_moneywash:wash', function(source, cb, laundryIndex, amount)
  local xPlayer = ESX.GetPlayerFromId(source)
  amount = tonumber(amount) or 0
  if not xPlayer or amount <= 0 then
    cb({ ok = false, message = 'invalid' })
    return
  end

  local laundry = Config.Laundries[tonumber(laundryIndex)]
  if not laundry then
    cb({ ok = false, message = 'invalid_laundry' })
    return
  end

  local fee = laundry.fee or 0.0

  local blackAcct = xPlayer.getAccount('black_money')
  local black = (blackAcct and blackAcct.money) or 0

  if black < amount then
    cb({ ok = false, message = 'not_enough_black' })
    return
  end

  local payout = math.floor(amount * (1.0 - fee))
  if payout <= 0 then
    cb({ ok = false, message = 'payout_zero' })
    return
  end

  xPlayer.removeAccountMoney('black_money', amount)
  xPlayer.addMoney(payout)

  cb({ ok = true, payout = payout })
end)
