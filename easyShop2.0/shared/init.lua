EasyCore=exports["easyCore"].getCore()
ESX=EasyCore.FrameworkHelper.Framework
EasyEconomy=exports["easyEconomy"].GetEconomySystem()
RessourceName=GetCurrentResourceName()


if IsDuplicityVersion() then--if true it is server side
    NeededJobOnDutyCount=nil
else--clientSide
    NeededJobOnDutyCount={}
end