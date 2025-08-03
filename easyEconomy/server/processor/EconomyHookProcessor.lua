---@class EconomyHookProcessor

EconomyHookProcessor = {}
EconomyHookProcessor.__index = EconomyHookProcessor

local eventHooks = {}
local hookId = 0
local microtime = os.microtime

function EconomyHookProcessor:new()
    local economyHookProcessor = {}
    setmetatable(economyHookProcessor, self)
    return economyHookProcessor
end

function EconomyHookProcessor:RegisterEventHook(event, cb)
    local requestId=EasyCore.Utils.Guid()
    if not eventHooks[event] then
        eventHooks[event] = {}
    end

	local mt = getmetatable(cb)
	mt.__index = nil
	mt.__newindex = nil
   	cb.resource = GetInvokingResource()
	hookId = hookId + 1
	cb.hookId = hookId
    EasyCore.Logger.LogDebug(RessourceName, requestId, ('%s register hook for event: "%s" and hook-id: %s'):format(cb.resource , event, hookId))
	-- if options then
	-- 	for k, v in pairs(options) do
	-- 		cb[k] = v
	-- 	end
	-- end
    eventHooks[event][#eventHooks[event] + 1] = cb
	return hookId
end

function EconomyHookProcessor:RemoveResourceHooks(resource, id)
    local requestId=EasyCore.Utils.Guid()
    for _, hooks in pairs(eventHooks) do
        for i = #hooks, 1, -1 do
			local hook = hooks[i]

            if hook.resource == resource and (not id or hook.hookId == id) then
                table.remove(hooks, i)
            end
        end
    end
end

function EconomyHookProcessor:TriggerEventHooks(event, payload)
    local requestId=EasyCore.Utils.Guid()
    local hooks = eventHooks[event]

    if hooks then
        for i = 1, #hooks do
            local hook = hooks[i]
            EasyCore.Logger.LogDebug(RessourceName, requestId, ('Triggering event hook "%s:%s:%s".'):format(hook.resource, event, i))
            local start = microtime()
            local _, response = pcall(hooks[i], payload)
			local executionTime = microtime() - start
            if executionTime >= 100000 then
                EasyCore.Logger.LogWarning(RessourceName, requestId, ('Execution of event hook "%s:%s:%s" took %.2fms.'):format(hook.resource, event, i, executionTime / 1e3))
            else
                EasyCore.Logger.LogDebug(RessourceName, requestId, ('Execution of event hook "%s:%s:%s" took %.2fms.'):format(hook.resource, event, i, executionTime / 1e3))
            end

            if response==false then
                return false
            end
        end
    end

    return true
end