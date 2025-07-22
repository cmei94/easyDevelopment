if not EasyCore then
    EasyCore={}
end

--Folder
EasyCore.Folder={}

---Check folder exists if not it will be created
---@param path string
EasyCore.Folder.CheckOrCreateFolder=function(path)
 -- Überprüfe, ob der Ordner existiert
    local success1, errorMessage1 = os.rename(path, path)
    if not success1 then
        -- Ordner existiert nicht, erstelle ihn
        local mkdirCommand = 'mkdir "' .. path ..'"'
        local exitCode = os.execute(mkdirCommand)
        local success2, errorMessage2 = os.rename(path, path)
        if success2 then
            print("Ordner erfolgreich erstellt:", path)
        else
            error("Fehler beim Erstellen des Ordners. Pfad: "..path.." ErrorMessage:"..errorMessage2)
        end
    end
end

---Check folder files older than timeInSecondsForDelete
---@param directoryPath string
---@param timeInSecondsForDelete number
EasyCore.Folder.DeleteOlderFiles=function(directoryPath, timeInSecondsForDelete)
    for line in io.popen('dir "' .. directoryPath .. '" /b'):lines() do
        local fileName = line

        if fileName ~= "." and fileName ~= ".." then
            if EasyCore.File.IsOlderThanTimeByName
            (fileName, timeInSecondsForDelete) then
                EasyCore.File.Delete(directoryPath, fileName)
            end    
        end
    end
end