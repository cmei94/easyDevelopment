`easyCore` ist eine geteilte Bibliothek (Shared Resource) für FiveM-Server, die auf dem ESX-Framework aufbaut. Sie stellt eine Sammlung von zentralen und wiederverwendbaren Funktionen bereit, um die Entwicklung anderer Ressourcen zu beschleunigen und zu standardisieren.

* * * * *

Deutsch
-------

### Features

-   **Leistungsstarkes Logging-System**: Konfigurierbares Logging in Dateien, die Konsole und an Discord-Webhooks mit verschiedenen Log-Levels (`debug`, `info`, `warning`, `error`).

-   **Automatisierte Event-Logs**: Protokolliert Server- und txAdmin-Events (z.B. `playerConnecting`, `onResourceStart`, `playerBanned`) automatisch an separate Webhooks.

-   **Abstrahierte Datenbankfunktionen**: Vereinfachter und sicherer Zugriff auf die Datenbank (`oxmysql`) für Abfragen und Transaktionen.

-   **Benachrichtigungssystem**: Ein Wrapper, der gängige Benachrichtigungssysteme wie `okokNotify` oder die Standard-ESX-Benachrichtigungen unterstützt.

-   **Server-seitiges Caching**: Ein Mechanismus zum Zwischenspeichern von client-spezifischen Daten auf dem Server, um Datenbankabfragen zu reduzieren.

-   **Hilfsfunktionen (Utils)**: Eine umfangreiche Sammlung von Helferfunktionen für Aufgaben wie das Generieren von GUIDs, das Klonen von Tabellen, das Prüfen von Listen und mehr.

-   **Datei- und Ordner-Management**: Serverseitige Funktionen zum Lesen, Schreiben, Kopieren und Löschen von Dateien sowie zum automatischen Entfernen alter Log-Dateien.

### Abhängigkeiten

Für den Betrieb von `easyCore` müssen die folgenden Ressourcen auf deinem Server installiert und gestartet sein:

-   `es_extended`

-   `oxmysql`

### Installation

1.  Lade das `easyCore`-Verzeichnis herunter.

2.  Platziere den `easyCore`-Ordner in deinem `resources`-Verzeichnis.

3.  Stelle sicher, dass die Dependencies **vor** `easyCore` in deiner `server.cfg` (oder `resources.cfg`) gestartet werden.

    Code-Snippet

    ```
    ensure es_extended
    ensure oxmysql

    ensure easyCore

    ```

4.  Passe die Konfigurationsdateien im `shared/Config/`-Ordner an deine Bedürfnisse an.

### Konfiguration

Die gesamte Konfiguration findet im `shared/Config/`-Verzeichnis statt.

#### `shared/Config/Logger/config.lua`

Hier werden die Grundeinstellungen des Loggers vorgenommen:

-   `Config.Logger.ServerLog.Enable`: Aktiviert oder deaktiviert das gesamte serverseitige Logging.

-   `Config.Logger.ServerLog.LogFile.LogLevel`: Legt den minimalen Log-Level für einzelne Log-Dateien fest.

-   `Config.Logger.ServerLog.Console.LogLevel`: Legt den minimalen Log-Level für die Server-Konsole fest.

-   `Config.Logger.ServerLog.EnableWebhooks`: Aktiviert das Senden von Standard-Logs an Discord.

-   `Config.Logger.ServerLog.EnableEventWebhooks`: Aktiviert das Senden von Event-Logs (z.B. `playerConnecting`) an Discord.

-   `Config.Logger.ServerLog.EnableAutoLogFileDelete`: Aktiviert das automatische Löschen von alten Log-Dateien nach der in `EnableAutoLogFileDeleteTimeInHours` definierten Zeit.

#### `shared/Config/Logger/config-webhooks.lua`

Hier werden die Discord-Webhooks konfiguriert:

-   `Config.Logger.WebhookLogLevel`: Definiert den minimalen Log-Level, ab dem eine Nachricht an einen Standard-Webhook gesendet wird.

-   `Config.Logger.Webhooks`: Eine Tabelle, in der du für jede Ressource eine eigene Webhook-URL hinterlegen kannst.

-   `Config.Logger.EventWebhooks`: Eigene Webhooks für spezifische Server- oder txAdmin-Events.

#### `shared/Config/configBlacklists.lua`

Diese Datei enthält Listen mit Wörtern, die gefiltert werden sollen:

-   `Config.Blacklists.LogMessageBlackList`: Verhindert, dass bestimmte Begriffe in den Logs erscheinen.

-   `Config.Blacklists.ForbiddenInChat`: Liste verbotener Wörter für den Ingame-Chat.

### API-Nutzung & Beispiele

Um die Funktionen von `easyCore` in deinen eigenen Skripten zu nutzen, musst du zuerst das Core-Objekt importieren. Dies funktioniert sowohl client- als auch serverseitig identisch.

Lua

```
EasyCore = exports['easyCore']:getCore()

```

#### Logger

Der Logger ist eine der Kernfunktionen. Du kannst Nachrichten mit verschiedenen Prioritäten loggen.

**Beispiel:**

Lua

```
Citizen.CreateThread(function()
    -- Generiert eine einzigartige ID für diese Anfrage/diesen Vorgang
    local requestId = EasyCore.Utils.Guid()

    -- Loggt eine Fehlermeldung
    EasyCore.Logger.LogError(
        GetCurrentResourceName(), -- Name der aktuellen Ressource
        requestId,
        ("Spieler %s hat einen Fehler im Menü %s verursacht!"):format(GetPlayerName(PlayerId()), "SpielerMenü")
    )

    -- Loggt eine Info-Nachricht
    EasyCore.Logger.LogInfo(GetCurrentResourceName(), requestId, "Menü erfolgreich geöffnet.")
end)

```

#### Notifications

Das Benachrichtigungssystem ist ein Wrapper, der je nach Konfiguration in `config.lua` entweder `okokNotify` oder die Standard-ESX-Benachrichtigungen verwendet.

**Beispiel (Serverseitig):**

Lua

```
-- Zeigt eine Erfolgsmeldung für einen bestimmten Spieler an
EasyCore.Notifications.Success(source, "Erfolg", "Aktion wurde erfolgreich ausgeführt!", 5000, true)

-- Zeigt eine Fehlermeldung an
EasyCore.Notifications.Error(source, "Fehler", "Aktion fehlgeschlagen!", 5000, true)

```

#### Database (Server-side)

Stellt einfache Funktionen zur Interaktion mit der Datenbank bereit.

**Beispiel:**

Lua

```
local sql = "SELECT * FROM users WHERE id = ?"
local params = { 1 }

local result = EasyCore.DB.QueryExecut(sql, params)

if result.IsQueryExecuteSuccess and result.QueryResult[1] then
    print("Benutzer gefunden:", json.encode(result.QueryResult[1]))
else
    print("Fehler bei der Datenbankabfrage:", result.Error)
end

```

#### Utils

`easyCore` bietet viele nützliche Hilfsfunktionen, die du in deinen Skripten verwenden kannst.

**Beispiel:**

Lua

```
-- Eine einzigartige ID generieren
local newId = EasyCore.Utils.Guid()

-- Prüfen, ob eine Tabelle leer ist
local myTable = {}
if not EasyCore.Utils.CheckTableCountNotZero(myTable) then
    print("Die Tabelle ist leer.")
end

-- Prüfen, ob ein Wert in einer Tabelle enthalten ist
local allowedJobs = { "police", "ambulance" }
if EasyCore.Utils.Contains(allowedJobs, "police") then
    print("Der Job 'police' ist erlaubt.")
end

```

* * * * *

English
-------

### Features

-   **Powerful Logging System**: Configurable logging to files, the console, and Discord webhooks with different log levels (`debug`, `info`, `warning`, `error`).

-   **Automated Event Logs**: Automatically logs server and txAdmin events (e.g., `playerConnecting`, `onResourceStart`, `playerBanned`) to separate webhooks.

-   **Abstracted Database Functions**: Simplified and secure access to the database (`oxmysql`) for queries and transactions.

-   **Notification System**: A wrapper that supports common notification systems like `okokNotify` or the default ESX notifications.

-   **Server-side Caching**: A mechanism for caching client-specific data on the server to reduce database queries.

-   **Utility Functions (Utils)**: An extensive collection of helper functions for tasks like generating GUIDs, cloning tables, checking lists, and more.

-   **File and Folder Management**: Server-side functions for reading, writing, copying, and deleting files, as well as automatically removing old log files.

### Dependencies

To run `easyCore`, the following resources must be installed and started on your server:

-   `es_extended`

-   `oxmysql`

### Installation

1.  Download the `easyCore` directory.

2.  Place the `easyCore` folder in your `resources` directory.

3.  Ensure that the dependencies are started **before** `easyCore` in your `server.cfg` (or `resources.cfg`).

    Code-Snippet

    ```
    ensure es_extended
    ensure oxmysql

    ensure easyCore

    ```

4.  Adjust the configuration files in the `shared/Config/` folder to your needs.

### Configuration

All configuration takes place in the `shared/Config/` directory.

#### `shared/Config/Logger/config.lua`

This is where the basic logger settings are configured:

-   `Config.Logger.ServerLog.Enable`: Enables or disables all server-side logging.

-   `Config.Logger.ServerLog.LogFile.LogLevel`: Sets the minimum log level for individual log files.

-   `Config.Logger.ServerLog.Console.LogLevel`: Sets the minimum log level for the server console output.

-   `Config.Logger.ServerLog.EnableWebhooks`: Enables sending standard logs to Discord.

-   `Config.Logger.ServerLog.EnableEventWebhooks`: Enables sending event-specific logs (e.g., `playerConnecting`) to Discord.

-   `Config.Logger.ServerLog.EnableAutoLogFileDelete`: Enables the automatic deletion of old log files after the time defined in `EnableAutoLogFileDeleteTimeInHours`.

#### `shared/Config/Logger/config-webhooks.lua`

This is where Discord webhooks are configured:

-   `Config.Logger.WebhookLogLevel`: Defines the minimum log level for a message to be sent to a standard webhook.

-   `Config.Logger.Webhooks`: A table where you can define a unique webhook URL for each resource.

-   `Config.Logger.EventWebhooks`: Custom webhooks for specific server or txAdmin events.

#### `shared/Config/configBlacklists.lua`

This file contains lists of words to be filtered:

-   `Config.Blacklists.LogMessageBlackList`: Prevents certain terms from appearing in the logs.

-   `Config.Blacklists.ForbiddenInChat`: A list of forbidden words for the in-game chat.

### API Usage & Examples

To use the functions of `easyCore` in your own scripts, you must first import the core object. This works identically on both the client and server sides.

Lua

```
EasyCore = exports['easyCore']:getCore()

```

#### Logger

The logger is one of the core features. You can log messages with different priorities.

**Example:**

Lua

```
Citizen.CreateThread(function()
    -- Generate a unique ID for this request/operation
    local requestId = EasyCore.Utils.Guid()

    -- Log an error message
    EasyCore.Logger.LogError(
        GetCurrentResourceName(), -- Name of the current resource
        requestId,
        ("Player %s caused an error in the %s menu!"):format(GetPlayerName(PlayerId()), "PlayerMenu")
    )

    -- Log an info message
    EasyCore.Logger.LogInfo(GetCurrentResourceName(), requestId, "Menu opened successfully.")
end)

```

#### Notifications

The notification system is a wrapper that, depending on the configuration in `config.lua`, uses either `okokNotify` or the standard ESX notifications.

**Example (Server-side):**

Lua

```
-- Show a success notification for a specific player
EasyCore.Notifications.Success(source, "Success", "Action was executed successfully!", 5000, true)

-- Show an error notification
EasyCore.Notifications.Error(source, "Error", "Action failed!", 5000, true)

```

#### Database (Server-side)

Provides simple functions for interacting with the database.

**Example:**

Lua

```
local sql = "SELECT * FROM users WHERE id = ?"
local params = { 1 }

local result = EasyCore.DB.QueryExecut(sql, params)

if result.IsQueryExecuteSuccess and result.QueryResult[1] then
    print("User found:", json.encode(result.QueryResult[1]))
else
    print("Error during database query:", result.Error)
end

```

#### Utils

`easyCore` offers many useful helper functions that you can use in your scripts.

**Example:**

Lua

```
-- Generate a unique ID
local newId = EasyCore.Utils.Guid()

-- Check if a table is empty
local myTable = {}
if not EasyCore.Utils.CheckTableCountNotZero(myTable) then
    print("The table is empty.")
end

-- Check if a value is contained in a table
local allowedJobs = { "police", "ambulance" }
if EasyCore.Utils.Contains(allowedJobs, "police") then
    print("The 'police' job is allowed.")
end
```
