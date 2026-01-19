Config = {}

Config.DrawDistance = 12.0
Config.Marker = {
  type = 1,
  size = vector3(1.2, 1.2, 0.8),
  color = { r = 120, g = 90, b = 200, a = 120 }
}

-- Jobname der Polizei in deinem ESX
Config.PoliceJobName = 'police'

-- Presets in der NUI (wie im Bild)
Config.Presets = { 10000, 20000, 30000 }

-- Mehrere Standorte, jeweils mit eigener Fee (z.B. 0.28 = 28%)
Config.Laundries = {
  {
    label = 'Moneywash #1',
    coords = vector3(1137.85, -989.25, 46.11),
    fee = 0.28
  },
  {
    label = 'Moneywash #2',
    coords = vector3(-186.35, -1309.28, 31.30),
    fee = 0.20
  }
}
