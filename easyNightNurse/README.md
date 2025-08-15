Deutsch
=======

`easyNightNurse` ist ein Skript für FiveM, das es Spielern ermöglicht, sich wiederzubeleben und zu heilen, wenn kein Sanitäter im Dienst ist.

Features
--------

-   **Wiederbelebung und Heilung**: Spieler können sich an festgelegten Orten wiederbeleben oder heilen lassen.

-   **Bezahlung**: Die Kosten für die Behandlung werden automatisch vom Konto des Spielers abgebucht.

-   **Anpassbare Stationen**: Du kannst beliebig viele Stationen mit unterschiedlichen Preisen, Positionen und NPCs erstellen.

-   **Abhängigkeit von Sanitätern**: Das System ist nur aktiv, wenn nicht genügend Sanitäter im Dienst sind.

Abhängigkeiten
--------------

-   `rprogress`

-   `easyCore`

Installation
------------

1.  Lade das `easyNightNurse`-Verzeichnis herunter.

2.  Platziere den Ordner in deinem `resources`-Verzeichnis.

3.  Füge `ensure easyNightNurse` zu deiner `server.cfg` hinzu. Achte darauf, dass es nach den Abhängigkeiten geladen wird.

Konfiguration
-------------

Die gesamte Konfiguration des Skripts findet in der Datei `shared/config.lua` statt.

### `Config.Features`

-   `UseOkOkTextUi`: (`true`/`false`) - Legt fest, ob `okokTextUI` für Interaktions-aufforderungen verwendet wird.

-   `EnableSetMoneyToSociety`: (`true`/`false`) - Wenn `true`, wird das verdiente Geld auf die Konten der Gesellschaften eingezahlt.

-   `PaySocieties`: Eine Tabelle, die die Namen der Gesellschaftskonten enthält, auf die das Geld eingezahlt werden soll.

### `Config.ClientFunctions`

Diese Funktionen müssen an dein spezifisches Gesundheits-/Todessystem angepasst werden.

-   `HealthCheck`: Überprüft den Gesundheitszustand des Spielers.

-   `HealPlayer`: Funktion, die zum Heilen eines verletzten Spielers aufgerufen wird.

-   `RevivePlayer`: Funktion, die zum Wiederbeleben eines toten/niedergeschlagenen Spielers aufgerufen wird.

### `Config.General`

-   `InteractKey`: Die Taste für die Interaktion mit der Nachtschwester.

-   `CreateDistance`: Die Entfernung, in der der Marker/Ped der Krankenschwester erstellt wird.

### `Config.Nurses`

Hier definierst du die einzelnen Krankenschwester-Stationen.

-   **`Label`**: Der Name der Station.

-   **`Position`**: Die `vector4`-Koordinaten der Station.

-   **`InteractDistance`**: Die Interaktionsentfernung.

-   **`Display`**:

    -   `UsePed`: (`true`/`false`) - Legt fest, ob ein Ped verwendet werden soll.

    -   `PedModel`: Das Modell des Peds.

-   **`Blip`**:

    -   `Enable`: (`true`/`false`) - Legt fest, ob ein Blip auf der Karte angezeigt werden soll.

-   **`RevivePrice`**: Der Preis für eine Wiederbelebung.

-   **`HealingPrice`**: Der Preis für eine Heilung.

-   **`DisableCondition`**:

    -   `NeededJobs`: Die zu zählenden Jobs.

    -   `OnDutyCount`: Die Anzahl der Spieler im Dienst, ab der die Station deaktiviert wird.

-   **`TreatmentPositions`**: Hier definierst du die Behandlungsbetten.

* * * * *

English
=======

`easyNightNurse` is a script for FiveM that allows players to revive and heal themselves when no medics are on duty.

Features
--------

-   **Revive and Heal**: Players can revive or heal themselves at designated locations.

-   **Payment**: The cost of treatment is automatically deducted from the player's account.

-   **Customizable Stations**: You can create any number of stations with different prices, positions, and NPCs.

-   **Dependency on Medics**: The system is only active when there are not enough medics on duty.

Dependencies
------------

-   `rprogress`

-   `easyCore`

Installation
------------

1.  Download the `easyNightNurse` directory.

2.  Place the folder in your `resources` directory.

3.  Add `ensure easyNightNurse` to your `server.cfg`. Make sure it is loaded after the dependencies.

Configuration
-------------

The entire configuration of the script takes place in the `shared/config.lua` file.

### `Config.Features`

-   `UseOkOkTextUi`: (`true`/`false`) - Determines whether `okokTextUI` is used for interaction prompts.

-   `EnableSetMoneyToSociety`: (`true`/`false`) - If `true`, the money earned will be deposited into the society accounts.

-   `PaySocieties`: A table containing the names of the society accounts to which the money should be deposited.

### `Config.ClientFunctions`

These functions must be adapted to your specific health/death system.

-   `HealthCheck`: Checks the player's health status.

-   `HealPlayer`: Function called to heal an injured player.

-   `RevivePlayer`: Function called to revive a dead/downed player.

### `Config.General`

-   `InteractKey`: The key for interacting with the Night Nurse.

-   `CreateDistance`: The distance at which the nurse's marker/ped is created.

### `Config.Nurses`

Here you define the individual nurse stations.

-   **`Label`**: The name of the station.

-   **`Position`**: The `vector4` coordinates of the station.

-   **`InteractDistance`**: The interaction distance.

-   **`Display`**:

    -   `UsePed`: (`true`/`false`) - Determines whether a ped should be used.

    -   `PedModel`: The model of the ped.

-   **`Blip`**:

    -   `Enable`: (`true`/`false`) - Determines whether a blip should be displayed on the map.

-   **`RevivePrice`**: The price for a revival.

-   **`HealingPrice`**: The price for healing.

-   **`DisableCondition`**:

    -   `NeededJobs`: The jobs to be counted.

    -   `OnDutyCount`: The number of players on duty at which the station is deactivated.

-   **`TreatmentPositions`**: Here you define the treatment beds.
