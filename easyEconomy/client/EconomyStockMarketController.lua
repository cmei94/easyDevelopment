local economyStockMarketProcessor=EconomyStockMarketProcessor:new()

while not ClientInit do
    Wait(500)
end

economyStockMarketProcessor:StartStockMarketSystem()

---Close the tablet
---@param data table callback data
---@param cb function
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    economyStockMarketProcessor:CloseTablet()

end)


