# So bekommst du deine .exe über GitHub (ohne Installation auf deinem PC)

Da du Flutter nicht auf deinem PC hast, nutzen wir GitHub Actions. GitHub stellt einen Windows-Server bereit, der die App für dich baut.

## Schritt 1: GitHub Repository erstellen
1. Geh auf [github.com](https://github.com) und logge dich ein.
2. Erstelle ein neues Repository (Name egal, z.B. `team-system-app`).
3. Wähle "Private", wenn nur du den Code sehen sollst.

## Schritt 2: Code hochladen
1. Entpacke meine ZIP-Datei.
2. Gehe in den Ordner `team-system/app`.
3. Lade **alle** Dateien aus diesem Ordner (inklusive des versteckten `.github` Ordners) in dein neues GitHub Repository hoch.
   * *Tipp:* Am einfachsten geht das, wenn du die Dateien einfach per Drag & Drop in das Browserfenster deines Repositories ziehst.

## Schritt 3: Den Build starten
1. Sobald die Dateien hochgeladen sind, klicke oben auf den Reiter **"Actions"**.
2. Du wirst dort einen Workflow namens **"Build Windows EXE"** sehen.
3. Falls er nicht automatisch startet, klicke auf "Run workflow".

## Schritt 4: Die .exe herunterladen
1. Warte ca. 5-10 Minuten, bis der grüne Haken erscheint.
2. Klicke auf den fertigen "Build Windows EXE" Durchlauf.
3. Scrolle nach unten zum Bereich **"Artifacts"**.
4. Dort findest du eine Datei namens `windows-release.zip`. Lade sie herunter.
5. In dieser ZIP-Datei findest du deinen `Release`-Ordner mit der fertigen `.exe`!

**Hinweis:** Denke daran, dass du den gesamten Inhalt des `Release`-Ordners brauchst, damit das Programm läuft, nicht nur die einzelne .exe Datei.
