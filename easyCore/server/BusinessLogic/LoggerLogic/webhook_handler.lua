-- The table of queues, keyed by webhook URL.
WebhookQueues = {}

-- A simple mutex lock to ensure thread-safe access to the WebhookQueues table.
local queueLock = false

-- A table to keep track of which webhook URLs have an active worker thread.
local activeWorkers = {}

-- Export this function so other scripts can use it.
function QueueWebhookMessage(webhookUrl, embedObject)
    if not webhookUrl or type(webhookUrl) ~= "string" or webhookUrl == "" then
        print("^1[Logger-Error]^7 Tried to queue a webhook message with an invalid URL.")
        return
    end

    -- 1. Lock the queue to safely add the new message.
    while queueLock do Wait(0) end
    queueLock = true

    -- 2. Add the message to the correct queue.
    if not WebhookQueues[webhookUrl] then
        WebhookQueues[webhookUrl] = {} -- Create queue if it doesn't exist.
    end
    table.insert(WebhookQueues[webhookUrl], embedObject)

    -- 3. Unlock the queue.
    queueLock = false
end

-- This is the "Manager" thread.
-- Its job is to check for pending messages and start "Worker" threads if needed.
CreateThread(function()
    while true do
        Wait(500) -- Check for new work every half a second.

        -- We need to lock the queue even for reading to prevent conflicts
        -- while the manager is iterating and a worker might be starting.
        while queueLock do Wait(0) end
        queueLock = true
        
        for url, queue in pairs(WebhookQueues) do
            -- If a queue has messages AND no worker is currently active for this URL...
            if #queue > 0 and not activeWorkers[url] then
                -- ...then mark it as active and start a new worker thread for it.
                activeWorkers[url] = true
                
                -- Start a new coroutine to process this specific queue.
                CreateThread(function()
                    -- As long as there are messages, this worker will process them.
                    while activeWorkers[url] do
                        local embedsToSend = {}

                        -- Lock the queue to safely grab a batch of messages.
                        while queueLock do Wait(0) end
                        queueLock = true

                        local batchSize = math.min(#WebhookQueues[url], 10) -- Take up to 10 embeds.
                        for i = 1, batchSize do
                            table.insert(embedsToSend, table.remove(WebhookQueues[url], 1))
                        end
                        
                        -- Check if the queue is now empty for this URL.
                        local isQueueEmpty = #WebhookQueues[url] == 0
                        
                        -- Unlock the queue immediately after modification.
                        queueLock = false 

                        -- If we collected embeds, send them.
                        if #embedsToSend > 0 then
                            local payload = json.encode({ embeds = embedsToSend })

                            PerformHttpRequest(url, function(err, text, headers)
                                if err ~= 200 and err ~= 204 then -- 200/204 are success codes
                                    print(string.format("^1[Logger-Error]^7 Failed to send webhook to %s. Status: %s, Response: %s", url, err, text))
                                end
                            end, "POST", payload, { ["Content-Type"] = "application/json" })

                            -- Wait 2 seconds to respect Discord's rate limit (30 messages/min).
                            Wait(2000)
                        end
                        
                        -- If the queue was empty after our batch, the worker's job is done.
                        if isQueueEmpty then
                            activeWorkers[url] = nil -- Mark worker as inactive.
                            break -- Exit the loop, terminating the thread.
                        end
                    end
                end)
            end
        end

        -- Unlock the queue after the manager has finished its check.
        queueLock = false
    end
end)