if not EasyCore then
    EasyCore={}
end

--Files Write Delete Change

EasyCore.File={}

EasyCore.File.Mode={}
EasyCore.File.Mode.Overwrite="w"--Dieser Modus steht für "Schreiben" (write). Wenn die Datei bereits existiert, wird ihr vorheriger Inhalt gelöscht, und die Datei wird geöffnet, um neue Daten zu schreiben. Wenn die Datei nicht existiert, wird eine neue Datei mit dem angegebenen Namen erstellt.
EasyCore.File.Mode.Add="a+"--Zusammengefasst bedeutet "a+" also, dass die Datei zum Anhängen geöffnet wird, was bedeutet, dass neue Daten am Ende der Datei hinzugefügt werden, und dass sie auch zum Lesen geöffnet ist, sodass du bereits vorhandene Daten lesen kannst, falls sie vorhanden sind.
EasyCore.File.Mode.Read="r"

---encode table to json and write it to special file
---@param path string 
---@param fileName string
---@param writeMode string
---@param table table
EasyCore.File.WriteTable=function (path, fileName, writeMode, table)
    if path and path~="" and fileName and fileName~=""  and writeMode and table then
        local file = io.open(path .. fileName, writeMode)

        if file then
            file:write(json.encode(table, { indent = true }), "\n")
            file:close()
        end
    end
end

---write something to special file
---@param path string
---@param fileName string
---@param writeMode string
---@param text string
EasyCore.File.WriteText=function (path, fileName, writeMode, text)
    if path and path~="" and fileName and fileName~="" and writeMode and text then
        local file = io.open(path .. fileName, writeMode)

        if file then
            file:write(text, "\n")
            file:close()
        end
    end
end

---copy content of one file to another
---@param originPath string
---@param originFileName string
---@param targetPath string
---@param targetFileName string
---@return boolean
EasyCore.File.Copy=function (originPath, originFileName, targetPath, targetFileName)
    if originPath and originPath~="" and originFileName and originFileName~="" and targetPath and targetPath~="" and targetFileName and targetFileName~="" then
        local read=EasyCore.File.Read(originPath, originFileName)
        if read then
            EasyCore.File.WriteText(targetPath, targetFileName, EasyCore.File.Mode.Overwrite, read)
        end
    end
    return false
end

---read content from file
---@param path string
---@param fileName string
---@return string
EasyCore.File.Read=function (path, fileName)
    if path and path~="" and fileName and fileName~="" then
        local file = io.open(path .. fileName, EasyCore.File.Mode.Read)
        if file then
            local content = file:read("*all") -- Liest den gesamten Inhalt der Datei

            -- Schließe die Datei
            file:close()

            return content
        end
    end
    return false
end

---Delete file
---@param path string
---@param fileName string
---@return boolean
EasyCore.File.Delete=function (path, fileName)
    if path and path~="" and fileName and fileName~="" then
        os.remove(path..fileName)
        return true
    end
    return false
end

---Check if file is older than timeInSeconds
---@param directoryPath string
---@param fileName string
---@param timeInSeconds number
---@return boolean
EasyCore.File.IsOlderThanTimeByName = function(fileName, timeInSeconds)
    -- Unterstützte Datumsformate als Muster
    local datePatterns = {
        { pattern = "(%d%d)%-(%d%d)%-(%d%d%d%d)", order = { "day", "month", "year" } }, -- 13-05-2025
        -- Weitere Formate können hier hinzugefügt werden, z.B.:
        -- { pattern = "(%d%d%d%d)_(%d%d)_(%d%d)", order = { "year", "month", "day" } }, -- 2025_05_13
    }

    local dateTable = nil

    for _, fmt in ipairs(datePatterns) do
        local captures = { fileName:match(fmt.pattern) }
        if #captures == #fmt.order then
            dateTable = {}
            for i, key in ipairs(fmt.order) do
                dateTable[key] = tonumber(captures[i])
            end
            break
        end
    end

    if not dateTable or not dateTable.year or not dateTable.month or not dateTable.day then
        return false -- Kein gültiges Datum gefunden
    end

    local fileTime = os.time({
        year = dateTable.year,
        month = dateTable.month,
        day = dateTable.day,
        hour = 0, min = 0, sec = 0
    })

    local now = os.time()
    return (now - fileTime) > timeInSeconds
end