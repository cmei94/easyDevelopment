function GetPathByRessourceName (ressourceName)
    if ressourceName then
        local path = GetResourcePath(ressourceName)
        path = path:gsub('//', '/')..'/'
        return path
    end
    return false
end


function ReadTableFromFile(path, filename)
    local fileContent=Read(path, filename)
    if fileContent and fileContent~="" then
        return json.decode(fileContent)
    end
    return false
end

function Read (path, fileName)
    if path and path~="" and fileName and fileName~="" then
        local file = io.open(path ..fileName, "r")

        if file then
            local content = file:read("*all") -- Liest den gesamten Inhalt der Datei

            -- Schließe die Datei
            file:close()

            return content
        end
    end
    return false
end

function WriteTable(path, fileName, table)
    if path and path ~= "" and fileName and fileName ~= "" and table then
        -- JSON-Daten aus der Tabelle erstellen
        local encoded = json.encode(table, { indent = true })
        if not encoded then
            return false
        end
        
        -- Prüfen ob die Datei existiert und löschen um sicherzustellen, dass sie komplett überschrieben wird
        local oldFile = io.open(path .. fileName, "r")
        if oldFile then
            oldFile:close()
            os.remove(path .. fileName)
        end

        -- Neue Datei erstellen und mit neuen Daten schreiben
        local file = io.open(path .. fileName, "w")
        if file then
            file:write(encoded) -- Schreibt die neuen Daten in die Datei
            file:flush() -- Stellt sicher, dass alles geschrieben wurde
            file:close()
            return true
        end
    end
    return false
end

function Count(tbl)
    local count = 0
    if tbl then
        for _, _ in pairs(tbl) do
            count = count + 1
        end
    end
    return count
end