IsReading=false
IsWriting=false

if not EasyCore then
    EasyCore={}
end


--ClientCache

TotalClientCache={}
RessourcePath=""
ClientCacheFolder=""
TotalClientCacheFilePath=""
ClientCacheFileName=""

Citizen.CreateThread(function()
    while not EasyCore.Utils do
        Citizen.Wait(1000)
    end
    IsReading=true
    IsWriting=true
    RessourcePath = EasyCore.Utils.GetPathByRessourceName(GetCurrentResourceName())
    ClientCacheFolder= Config.Cache.Client.Folder
    ClientCacheFileName = Config.Cache.Client.FileName
    TotalClientCacheFilePath=RessourcePath.."/"..ClientCacheFolder.."/"..ClientCacheFileName
    EasyCore.Folder.CheckOrCreateFolder(RessourcePath..ClientCacheFolder)
    TotalClientCache=ReadTableFromFile(RessourcePath..ClientCacheFolder.."/", ClientCacheFileName)
    if not TotalClientCache then
        error("Es fehlt eine Datei die im json format auslesbar ist. Eine leere json List [] ist auch okay. Die Datei sollte hier sein: "..TotalClientCacheFilePath)
    end
    IsReading=false
    IsWriting=false
end)

---read content from json file and decode json to table
---@param path string
---@param filename string
---@return table|boolean
function ReadTableFromFile(path, filename)
    local fileContent=EasyCore.File.Read(path, filename)
    if fileContent and fileContent~="" then
        return json.decode(fileContent)
    end
    return false
end

---Save table to json file
---@param table table
---@param path string
---@param filename string
function SaveTableToFile(table, path, filename)
    IsWriting=true
    EasyCore.File.WriteTable(path, filename, EasyCore.File.Mode.Overwrite, table)
    IsWriting=false
end

---Set data for Cient in cache
---@param source integer
---@param cb any
---@param args table with properties (text) ressourceName (text) key (any) value
---@return boolean
FRAMEWORK.RegisterServerCallback("EasyCore:SetClientCacheKeyValue", function(source, cb, args)
    local result = false
    local ressourceName=args.ressourceName
    local key=args.key
    local value=args.value
    if ressourceName and type(ressourceName) == "string" and ressourceName~="" and key and type(key) == "string" and key~="" and value then
        while IsWriting do
            Citizen.Wait(100)
        end
        local playerData = EasyCore.FrameworkHelper.GetPlayerData(source)
        if not TotalClientCache[ressourceName] then
            TotalClientCache[ressourceName]={}
        end
        local identifier = playerData.getIdentifier()
        if playerData and identifier then
            if not TotalClientCache[ressourceName][identifier] then
                TotalClientCache[ressourceName][identifier]={}
            end
            TotalClientCache[ressourceName][identifier][key]=
            {
                Value=value,
                ValueType=type(value),
                LastTimeUpdatedTimestamp=os.time()
            }
            if TotalClientCache[ressourceName][identifier][key] then
                result=true
                SaveTableToFile(TotalClientCache, RessourcePath..ClientCacheFolder.."/", ClientCacheFileName)
            end
        end
    end
    return cb(result)
end)

---Get Data from cache by key
---@param source integer
---@param cb any
---@param args table with properties (text) ressourceName (text) key 
---@return table|boolean
FRAMEWORK.RegisterServerCallback("EasyCore:GetClientCacheKeyValue", function(source, cb, args)
    local result = false
    local ressourceName=args.ressourceName
    local key=args.key
    if ressourceName and type(ressourceName) == "string" and ressourceName~="" and key and type(key) == "string" and key~="" then 
        if TotalClientCache and TotalClientCache[ressourceName] then
            local playerData = EasyCore.FrameworkHelper.GetPlayerData(source)
            local identifier = playerData.getIdentifier()
            if playerData and identifier then
                if TotalClientCache[ressourceName][identifier] and TotalClientCache[ressourceName][identifier][key] then
                    result=TotalClientCache[ressourceName][identifier][key]
                end
            end
        end
    end
    return cb(result)
end)

---Get total Data from cache by character
---@param source integer
---@param cb any
---@param args table with properties (text) ressourceName
---@return table|boolean
FRAMEWORK.RegisterServerCallback("EasyCore:GetTotalClientCache", function(source, cb, args)
    local result = false
    local ressourceName=args.ressourceName
    if ressourceName and type(ressourceName) == "string" and ressourceName~="" then 
        if TotalClientCache and TotalClientCache[ressourceName] then
            local playerData = EasyCore.FrameworkHelper.GetPlayerData(source)
            local identifier = playerData.getIdentifier()
            if playerData and identifier then
                if TotalClientCache[ressourceName][identifier] then
                    result=TotalClientCache[ressourceName][identifier]
                end
            end
        end
    end
    return cb(result)
end)

---Invalidate total Data from cache by character
---@param source integer
---@param cb any
---@param args table with properties (text) ressourceName
---@return boolean
FRAMEWORK.RegisterServerCallback("EasyCore:InvalidateTotalClientCachData", function(source, cb, args)
    local result = false
    local ressourceName=args.ressourceName
    if ressourceName and type(ressourceName) == "string" and ressourceName~="" then 
        if TotalClientCache and TotalClientCache[ressourceName] then
            local playerData = EasyCore.FrameworkHelper.GetPlayerData(source)
            local identifier = playerData.getIdentifier()
            if playerData and identifier then
                if TotalClientCache[ressourceName][identifier] then
                    TotalClientCache[ressourceName][identifier]=nil
                end
            end
            SaveTableToFile(TotalClientCache, RessourcePath..ClientCacheFolder.."/", ClientCacheFileName)
        end
        result=true
    end
    return cb(result)
end)


