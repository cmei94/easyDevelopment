if not EasyCore then
    EasyCore={}
end

FRAMEWORK = exports["es_extended"]:getSharedObject()

exports('getCore', function()
    while not next(EasyCore) do
        Wait(50)
    end
    return EasyCore
end)