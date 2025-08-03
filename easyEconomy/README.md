`easyEconomy` ist eine Ressource für FiveM, die auf dem `easyCore` und dem ESX-Framework aufbaut. Sie implementiert ein dynamisches Wirtschaftssystem, das auf Angebot und Nachfrage basiert, um die Preise von Gegenständen variabel zu gestalten und so eine realistische und sich über die Zeit verändernde Wirtschaft auf deinem Server zu simulieren.

Features
--------

-   Dynamisches Preissystem: Kauf- und Verkaufspreise passen sich automatisch an, je nachdem, wie oft Gegenstände von Spielern ge- oder verkauft werden.

-   Komplexe Einflussfaktoren: Die Wirtschaft wird nicht nur durch Angebot und Nachfrage, sondern auch durch konfigurierbare Quer-Einflüsse zwischen Gegenständen, Kategorien und sogar Spieler-Berufen beeinflusst.

-   Börsen (Stock Markets): Du kannst beliebig viele Orte (sowohl mit als auch ohne NPC) auf der Karte definieren, an denen Spieler die aktuellen Preise einsehen und handeln können.

-   Tablet-UI: Eine übersichtliche Benutzeroberfläche zeigt die aktuellen Marktpreise an. Sie ist über eine konfigurierbare Taste an den Börsen zugänglich.

-   Hohe Konfigurierbarkeit: Nahezu jeder Aspekt des Systems lässt sich über gut strukturierte Konfigurationsdateien anpassen.

-   Logging: Vollständige Integration in das Logging-System von `easyCore`, um alle wichtigen wirtschaftlichen Transaktionen nachzuverfolgen.

-   Automatischer Preis-Reset: Die Preise können nach einer einstellbaren Zeitspanne automatisch auf ihre Standardwerte zurückgesetzt werden, um eine unkontrollierte Inflation oder Deflation zu verhindern.

Abhängigkeiten
--------------

Stelle sicher, dass die folgenden Ressourcen auf deinem Server installiert sind und vor `easyEconomy` gestartet werden:

-   `/onesync` (muss in der server.cfg aktiviert sein)

-   `oxmysql`

-   `easyCore`

-   `es_extended`

-   `ox_inventory` (wird für die Anzeige von Gegenstandsbildern in der UI benötigt)

Installation
------------

1.  Lade das `easyEconomy`-Verzeichnis herunter.

2.  Platziere den Ordner in deinem `resources`-Verzeichnis.

3.  Füge `ensure easyEconomy` zu deiner `server.cfg` (oder `resources.cfg`) hinzu. Achte darauf, dass es nach den oben genannten Abhängigkeiten geladen wird.

    ```
    # Beispiel für die Lade-Reihenfolge
    ensure es_extended
    ensure oxmysql
    ensure easyCore
    ensure ox_inventory

    ensure easyEconomy

    ```

4.  Passe die Konfigurationsdateien im `shared/`-Verzeichnis an deine Bedürfnisse an. Die notwendigen Datenbanktabellen werden beim Start der Ressource automatisch erstellt, falls sie noch nicht existieren.

Konfiguration im Detail
-----------------------

Die gesamte Konfiguration des Skripts findet in den Lua-Dateien im `shared/`-Verzeichnis statt. Hier kannst du das System bis ins kleinste Detail anpassen.

### `shared/config.lua` - Die Hauptkonfiguration

Diese Datei enthält die grundlegenden Einstellungen für das Wirtschaftssystem.

#### `Config.Features`

-   `useLogging`: (`true`/`false`) - Aktiviert das Logging von Kauf- und Verkaufsaktionen über `easyCore`.

-   `autoInitItemsInDatabase`: (`true`/`false`) - Wenn `true`, sorgt das Skript beim Start dafür, dass alle in `ox_inventory` registrierten Items in der Datenbank vorhanden sind. Es wird empfohlen, diese Einstellung auf `true` zu belassen.

-   `autoResetItemsToDefaultPrice`: (`true`/`false`) - Aktiviert den automatischen Preis-Reset.

-   `resetTimer`: (Zahl in Minuten) - Definiert das Intervall für den automatischen Preis-Reset (z.B. `1440` für 24 Stunden).

#### `Config.Database`

-   `categoryTable`: Name der Tabelle für die Item-Kategorien.

-   `itemTable`: Name der Tabelle für die Items und ihre Preise.

#### `Config.Tablet`

-   `keyToOpen`: (Zahl) - Die Taste zum Öffnen des Tablets. Standard ist `38` (Taste E).

-   `animation`: (`true`/`false`) - Legt fest, ob der Spieler eine Animation ausführt.

#### `Config.StockMarket`

Hier definierst du die einzelnen Börsen mit Koordinaten, NPCs, Markern, Blips und spezifischen Handels-Einstellungen (`items`, `categories`, `showAllItems`).

### `shared/influence.lua` - Die Beeinflussungs-Logik

Diese Datei ist das Herzstück der dynamischen Wirtschaft. Hier legst du fest, wie sich verschiedene Aktionen auf die Preise auswirken.

#### Wichtige Information: Priorität der Einflüsse

Das Skript prüft die Konfiguration in einer festen Reihenfolge. Sobald eine passende Regel gefunden wird, wird diese angewendet:

1.  Höchste Priorität: `Config.ItemInfluence`

    -   Das Skript prüft zuerst, ob für das gehandelte Item ein spezifischer Eintrag hier existiert.

2.  Zweite Priorität: `Config.CategoryInfluence`

    -   Wenn für das Item kein Eintrag in `ItemInfluence` gefunden wird, wird geprüft, ob für die Kategorie des Items ein Eintrag hier existiert.

3.  Letzte Priorität: Standard-Verhalten

    -   Wird in keiner der beiden Konfigurationen eine Regel gefunden, wird nur die Kategorie des gehandelten Items selbst beeinflusst.

Zusammenfassung der Priorität: `ItemInfluence` -> `CategoryInfluence` -> `Standard-Verhalten`

Absolut Wichtig: Unabhängig von den oben genannten Regeln wird der Preis des gehandelten Items selbst immer beeinflusst. Die Konfigurationen fügen nur zusätzliche Effekte hinzu.

#### `Config.ItemInfluence` (Höchste Priorität)

Hier definierst du Regeln für einzelne, spezifische Items.

-   Struktur: Der Schlüssel der Tabelle ist der Name des Items (z.B. `["wool"]`).

    -   `InfluenceToCategories`: Eine Liste von Kategorie-Namen, deren Preise ebenfalls beeinflusst werden sollen.

    -   `InfluenceToItems`: Eine Liste von Item-Namen, deren Preise ebenfalls beeinflusst werden sollen.

    -   `InfluenceByJob`: Eine Tabelle, um temporäre Preisänderungen basierend auf der Anzahl der Spieler in einem bestimmten Beruf zu definieren.

        -   Der Schlüssel ist der Job-Name (z.B. `["police"]`).

        -   `Count`: Die Mindestanzahl an Spielern in diesem Job, damit die Regel aktiv wird.

        -   `SellPriceInfluence`: Ein Wert, der zum Verkaufspreis addiert (positiv) oder subtrahiert (negativ) wird.

        -   `BuyPriceInfluence`: Ein Wert, der zum Kaufpreis addiert oder subtrahiert wird.

Beispiel:

```
Config.ItemInfluence = {
    ["wool"] = { -- Wenn "wool" gehandelt wird...
        -- Beeinflusse zusätzlich die Preise aller Items in der Kategorie "Default"
        InfluenceToCategories = { "Default" },

        -- Beeinflusse zusätzlich die Preise der Items "wool" und "bread"
        InfluenceToItems = { "wool", "bread" },

        -- Wenn mindestens 1 Polizist online ist...
        InfluenceByJob = {
            ["police"] = {
                Count = 1,
                SellPriceInfluence = 10,  -- ...erhöhe den Verkaufspreis um 10
                BuyPriceInfluence = -10, -- ...und senke den Kaufpreis um 10
            },
        }
    },
}

```

#### `Config.CategoryInfluence` (Zweite Priorität)

Dies ist der Fallback, wenn keine `ItemInfluence`-Regel gefunden wurde.

-   Struktur: Der Schlüssel der Tabelle ist der Name der Kategorie (z.B. `["Default"]`).

    -   `InfluenceToCategories`: Eine Liste von anderen Kategorie-Namen, die ebenfalls beeinflusst werden sollen.

    -   `InfluenceByJob`: Funktioniert exakt wie bei `ItemInfluence`, beeinflusst aber alle Items der hier definierten Kategorie.

Beispiel:

```
Config.CategoryInfluence = {
    ["Default"] = { -- Wenn ein Item der Kategorie "Default" gehandelt wird...
        -- ...und keine spezifische Regel in ItemInfluence existiert...

        -- Beeinflusse auch die Preise aller Items in der Kategorie "Default"
        InfluenceToCategories = { "Default" },

        InfluenceByJob = {
            ["police"] = {
                Count = 3,
                SellPriceInfluence = 10,
                BuyPriceInfluence = -10,
            },
        }
    },
}

```

API-Nutzung & Events
--------------------

Du kannst die Funktionen von `easyEconomy` in deinen eigenen Skripten nutzen.

### API-Funktionen

Zuerst musst du das globale Objekt exportieren:

```
EasyEconomy = exports['easyEconomy']:GetEconomySystem()

```

-   `EasyEconomy.GetEconomyItems(items)`: Gibt die aktuellen Preisinformationen zurück.

-   `EasyEconomy.SellItems(items)`: Muss beim Verkauf von Items aufgerufen werden. Format: `{["item_name"] = amount}`.

-   `EasyEconomy.BuyItems(items)`: Muss beim Kauf von Items aufgerufen werden.

### Hook-System

-   `EasyEconomy.RegisterHook(event, callback)`: Registriert einen Hook.

-   `EasyEconomy.RemoveHook(id)`: Entfernt einen Hook.

-   Verfügbares Event: `refreshReadEconomyItems` (wird bei Preis-Updates ausgelöst).