if not EasyCore then
    EasyCore={}
end

-- Funktion, um eine Stoppuhr zu starten
function StartStopwatch()
    return os.clock()
end

-- Funktion, um die vergangene Zeit seit dem Start der Stoppuhr abzurufen
function GetElapsedTime(startTime)
    return (os.clock() - startTime) * 1000 -- in Millisekunden umrechnen
end


local isRessourceStarted=false
-- Beispiel: Starte die Stoppuhr
local startWatch=StartStopwatch()
print("EasyCore initialize started")

while GetResourceState(GetCurrentResourceName())~="started" do
    Wait(0)
end

local differenceTimeInMs=GetElapsedTime(startWatch)
print(("EasyCore initialize finished after %s ms"):format(differenceTimeInMs))
