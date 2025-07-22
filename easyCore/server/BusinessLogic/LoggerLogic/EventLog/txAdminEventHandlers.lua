-- Global table to store player names, updated periodically.
names = {};

-- Only register txAdmin event handlers if event webhooks are enabled.
if Config.Logger.ServerLog.EnableEventWebhooks then
	-- Create a thread to periodically update player names.
	CreateThread(function()
		while true do
			Wait(1000); -- Wait for 1 second.
			for k, v in pairs(GetPlayers()) do
				names[v] = GetPlayerName(v);
			end;
		end;
	end);

    --- Summary: Handles the 'txAdmin:events:scheduledRestart' event.
    --- Sends a webhook notification about a scheduled server restart.
    ---@param data table Data provided by the txAdmin event, including 'secondsRemaining'.
	AddEventHandler("txAdmin:events:scheduledRestart", function(data)
		local messageObject = {
			EventName = "txAdmin:events:scheduledRestart",
			Message = ("Server will restart in %s"):format(SecondsToClock(data.secondsRemaining)),
			Color = Config.Logger.Color["info"]
		};
		SendEventLogPerWebhook(messageObject);
	end);

    --- Summary: Handles the 'txAdmin:events:playerKicked' event.
    --- Sends a webhook notification when a player is kicked.
    ---@param data table Data provided by the txAdmin event, including 'author', 'target' (player ID), and 'reason'.
	AddEventHandler("txAdmin:events:playerKicked", function(data)
		local messageObject = {
			EventName = "txAdmin:events:playerKicked",
			Message = ("**%s** kicked **%s**\nReason: `%s`"):format(data.author, names[data.target], data.reason),
			Color = Config.Logger.Color["info"]
		};
		SendEventLogPerWebhook(messageObject);
	end);

    --- Summary: Handles the 'txAdmin:events:playerWarned' event.
    --- Sends a webhook notification when a player is warned.
    --- Includes PlayerId for detailed logging in the embed.
    ---@param data table Data provided by the txAdmin event, including 'author', 'target' (player ID), 'actionId', and 'reason'.
	AddEventHandler("txAdmin:events:playerWarned", function(data)
		local messageObject = {
			EventName = "txAdmin:events:playerWarned",
			PlayerId = data.target, -- Include PlayerId for use in SendEventLogPerWebhook.
			Message = ("**%s** warned **%s**\nAction Id: `%s`\nReason: `%s`"):format(data.author, GetPlayerName(data.target), data.actionId, data.reason),
			Color = Config.Logger.Color["info"]
		};
		SendEventLogPerWebhook(messageObject);
	end);

    --- Summary: Handles the 'txAdmin:events:playerBanned' event.
    --- Sends a webhook notification when a player is banned, including ban duration.
    ---@param data table Data provided by the txAdmin event, including 'author', 'target' (player ID), 'actionId', 'reason', and 'expiration'.
	AddEventHandler("txAdmin:events:playerBanned", function(data)
		local messageObject = {
			EventName = "txAdmin:events:playerBanned",
			Color = Config.Logger.Color["info"]
		};
		if data.expiration == false then
			messageObject.Message = ("**%s** banned **%s**\nAction Id: `%s`\nReason: `%s`\nDuration: `Perm`"):format(data.author, names[data.target], data.actionId, data.reason);
		else
			messageObject.Message = ("**%s** banned **%s**\nAction Id: `%s`\nReason: `%s`\nDuration: `%s`"):format(data.author, names[data.target], data.actionId, data.reason, data.expiration);
		end;
		SendEventLogPerWebhook(messageObject);
	end);

    --- Summary: Handles the 'txAdmin:events:playerWhitelisted' event.
    --- Sends a webhook notification when a player is whitelisted.
    --- Includes PlayerId for detailed logging in the embed.
    ---@param data table Data provided by the txAdmin event, including 'author', 'target' (player ID), and 'actionId'.
	AddEventHandler("txAdmin:events:playerWhitelisted", function(data)
		local messageObject = {
			EventName = "txAdmin:events:playerWhitelisted",
			PlayerId = data.target, -- Include PlayerId for use in SendEventLogPerWebhook if GetPlayerName is useful.
			Message = ("**%s** whitelisted `%s`\nAction Id: `%s`"):format(data.author, data.target, data.actionId),
			Color = Config.Logger.Color["info"]
		};
		SendEventLogPerWebhook(messageObject);
	end);

    --- Summary: Handles the 'txAdmin:events:configChanged' event.
    --- Sends a webhook notification when the server.cfg is changed.
    ---@param data table Data provided by the txAdmin event (may be empty or contain details).
	AddEventHandler("txAdmin:events:configChanged", function(data)
		local messageObject = {
			EventName = "txAdmin:events:configChanged",
			Message = "The server.cfg has been changed.",
			Color = Config.Logger.Color["info"]
		};
		SendEventLogPerWebhook(messageObject);
	end);

    --- Summary: Handles the 'txAdmin:events:healedPlayer' event.
    --- Sends a webhook notification when a player (or the entire server) is healed.
    ---@param data table Data provided by the txAdmin event, including 'id' (player ID or -1 for all).
	AddEventHandler("txAdmin:events:healedPlayer", function(data)
		local messageObject = {
			EventName = "txAdmin:events:healedPlayer",
			Color = Config.Logger.Color["info"]
		};
		if data.id == (-1) then
			messageObject.Message = "The entire server was healed";
		else
			messageObject.Message = ("**%s** was healed."):format(GetPlayerName(data.id));
			messageObject.PlayerId = data.id; -- Include PlayerId for detailed logging in the embed.
		end;
		SendEventLogPerWebhook(messageObject);
	end);

    --- Summary: Handles the 'txAdmin:events:announcement' event.
    --- Sends a webhook notification for a new announcement.
    ---@param data table Data provided by the txAdmin event, including 'author' and 'message'.
	AddEventHandler("txAdmin:events:announcement", function(data)
		local messageObject = {
			EventName = "txAdmin:events:announcement",
			Message = ("**%s** announcement created.\n`%s`"):format(data.author, data.message),
			Color = Config.Logger.Color["info"]
		};
		SendEventLogPerWebhook(messageObject);
	end);

    --- Summary: Handles the 'txAdmin:events:serverShuttingDown' event.
    --- Sends a webhook notification when the server is shutting down.
    ---@param data table Data provided by the txAdmin event, including 'delay', 'author', and 'message'.
	AddEventHandler("txAdmin:events:serverShuttingDown", function(data)
		local messageObject = {
			EventName = "txAdmin:events:serverShuttingDown",
			Message = ("Server shutting down `%s`\n**Executed by:** `%s`\n**Message:** `%s`"):format(SecondsToClock(data.delay / 1000), data.author, data.message),
			Color = Config.Logger.Color["info"]
		};
		SendEventLogPerWebhook(messageObject);
	end);

    --- Summary: Converts a given number of seconds into a formatted "minutes, seconds" string.
    ---@param sec number The total number of seconds.
    ---@return string The formatted time string (e.g., "5 minutes, 30 seconds." or "45 seconds.").
	function SecondsToClock(sec)
		local minutes = math.floor(sec / 60);
		local seconds = sec - minutes * 60;
		if minutes == 0 then
			return string.format("%d seconds.", seconds);
		else
			-- Corrected typo: "Praktikum" to "Sekunden".
			return string.format("%d minutes, %d seconds.", minutes, seconds);
		end;
	end;
end