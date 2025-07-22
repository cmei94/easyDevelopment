ClientImport:
EasyCore=exports['easyCore']:getCore()

ServerImport:
EasyCore=exports['easyCore']:getCore()

BSP nach import in Script:
EasyCore.Notifications.TipRight("Hallo", 2000)

Oder Ganzes Script Beispiel (so wie im Beispiel funktioniert es Server und ClientSeitig):
EasyCore=exports['easyCore']:getCore()

Citizen.CreateThread(function()
    local requestId=EasyCore.Utils.Guid()
    EasyCore.Logger.LogError(GetCurrentResourceName(),requestId, ("%s Hat misst gebaut im Menü %s!"):format(GetPlayerName(PlayerId()), "SpielerMenü"))
end)