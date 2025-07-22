if not EasyCore then
    EasyCore={}
end

EasyCore.TextUi={}
--- show TextUi
---@param message any
---@param type any
EasyCore.TextUi.ShowUi=function(message, type)
    FRAMEWORK.TextUI(message,type)
end

--- hide TextUi
EasyCore.TextUi.HideUi=function()
    FRAMEWORK.HideUI()
end