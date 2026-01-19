local ESX = exports['es_extended']:getSharedObject()

local uiOpen = false
local currentLaundryIndex = nil

local function ShowHelp(msg)
  BeginTextCommandDisplayHelp('STRING')
  AddTextComponentSubstringPlayerName(msg)
  EndTextCommandDisplayHelp(0, false, true, -1)
end

local function OpenUI(laundryIndex)
  if uiOpen then return end
  uiOpen = true
  currentLaundryIndex = laundryIndex

  SetNuiFocus(true, true)
  SetNuiFocusKeepInput(false)

  ESX.TriggerServerCallback('ccp_moneywash:getUiData', function(data)
    SendNUIMessage({
      action = 'open',
      black = data.black,
      cops = data.cops,
      fee = data.fee, -- as fraction, e.g. 0.28
      presets = data.presets
    })
  end, laundryIndex)
end

local function CloseUI()
  if not uiOpen then return end
  uiOpen = false
  currentLaundryIndex = nil
  SetNuiFocus(false, false)
  SendNUIMessage({ action = 'close' })
end

RegisterNUICallback('close', function(_, cb)
  CloseUI()
  cb('ok')
end)

RegisterNUICallback('wash', function(payload, cb)
  local amount = tonumber(payload.amount) or 0
  if amount <= 0 then
    cb({ ok = false, message = 'invalid_amount' })
    return
  end

  ESX.TriggerServerCallback('ccp_moneywash:wash', function(res)
    if res.ok then
      -- Refresh UI numbers after wash
      ESX.TriggerServerCallback('ccp_moneywash:getUiData', function(data)
        SendNUIMessage({
          action = 'refresh',
          black = data.black,
          cops = data.cops,
          fee = data.fee
        })
      end, currentLaundryIndex)
    end
    cb(res)
  end, currentLaundryIndex, amount)
end)

CreateThread(function()
  while true do
    local sleep = 1000
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)

    for i = 1, #Config.Laundries do
      local v = Config.Laundries[i]
      local dist = #(pcoords - v.coords)

      if dist < Config.DrawDistance then
        sleep = 0
        DrawMarker(
          Config.Marker.type,
          v.coords.x, v.coords.y, v.coords.z - 0.98,
          0.0, 0.0, 0.0,
          0.0, 0.0, 0.0,
          Config.Marker.size.x, Config.Marker.size.y, Config.Marker.size.z,
          Config.Marker.color.r, Config.Marker.color.g, Config.Marker.color.b, Config.Marker.color.a,
          false, true, 2, false, nil, nil, false
        )

        if dist < 1.6 and not uiOpen then
          ShowHelp('Drücke ~INPUT_CONTEXT~ um Geld zu waschen')
          if IsControlJustReleased(0, 38) then -- E
            OpenUI(i)
          end
        end
      end
    end

    if uiOpen then
      sleep = 0
      if IsControlJustReleased(0, 322) then -- ESC
        CloseUI()
      end
    end

    Wait(sleep)
  end
end)
