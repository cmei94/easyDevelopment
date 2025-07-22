if not EasyCore then
    EasyCore={}
end

EasyCore.DB={}

---db query execute 
---@param query string
---@param queryParameters table|nil
---@return table
EasyCore.DB.QueryExecut = function(query, queryParameters)
    local result = {
        IsQueryExecuteSuccess = false,
        QueryResult = nil,
        Error = nil,
    }
    if type(query) ~= "string" or query == "" then
        EasyCore.Logger.LogError("easyCore", EasyCoreRequestId, "Db query is empty or not a string!")
        result.Error = "Query is empty or not a string"
        return result
    end
    if type(queryParameters) ~= "table" then
        queryParameters = {}
    end

    local p = promise.new()
    local status, err = pcall(function()
        exports.oxmysql:execute(query, queryParameters, function(dbResult)
            p:resolve(dbResult)
        end)
    end)
    local queryResult = Citizen.Await(p)
    if not status then
        result.Error = err
        EasyCore.Logger.LogError("easyCore", EasyCoreRequestId, "Db query failed: " .. tostring(err))
        return result
    end

    result.IsQueryExecuteSuccess = queryResult ~= nil
    result.QueryResult = queryResult
    return result
end

---Async db query execute 
---@param query string
---@param queryParameters table
---@return table
EasyCore.DB.QueryExecutAsync=function(query, queryParameters)
    if not queryParameters then
        queryParameters={}
    end
    if not query then
        local currentTime = os.time()
        local now=os.date('%d-%m-%Y %H:%M:%S', currentTime)
        EasyLog.WriteLog("easyCore", now, "Db query is Empty!" )
        return result
    end

    exports.oxmysql:execute(query, queryParameters, function(result)
        p:resolve(result)
    end)
end

--- transction queryGenerateList
---@param queries table of table with query and values local queries = {
---                                                                         { 'INSERT INTO `test` (id) VALUES (?)', { 1 }},
---                                                                         { 'INSERT INTO `test` (id, name) VALUES (?, ?)', { 2, 'bob' }},
---                                                                 }
EasyCore.DB.QueriesTransactionExecut=function(queries)
    local result={
        IsQueryExecuteSuccess=false,
        QueryResult=nil,
    }
    if not queries then
        local currentTime = os.time()
        local now=os.date('%d-%m-%Y %H:%M:%S', currentTime)
        EasyCore.Logger.LogError("easyCore", EasyCoreRequestId,"Db query is Empty!" )
        return result
    end
    local p = promise.new()
    exports.oxmysql:transaction(queries, function(result)
        p:resolve(result)
    end)
    local queryResult = Citizen.Await(p)
    result.IsQueryExecuteSuccess=true
    result.QueryResult=queryResult
    return result
end