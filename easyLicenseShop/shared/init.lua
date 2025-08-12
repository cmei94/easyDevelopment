EasyCore = exports["easyCore"]:getCore()
ESX=EasyCore.FrameworkHelper.Framework
RessourceName=GetCurrentResourceName()

if IsDuplicityVersion() then--if true it is server side
    
else--clientSide

    --utils
    ---Show esx default text ui
    ---@param message any
    ---@param type any
    function ShowTextUI(message, type)
        ESX.TextUI(message, type)
    end

    function HideTextUI()
        ESX.HideUI()
    end
end