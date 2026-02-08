# Deployment-Dokumentation für das Team-Kommunikationssystem

Dieses Dokument beschreibt die notwendigen Schritte zum Deployment des Team-Kommunikationssystems, bestehend aus dem Node.js-Backend, der PostgreSQL-Datenbank, der Flutter-Anwendung (PC & Mobile) und dem Minecraft-Plugin.

## 1. Backend-Deployment (Node.js)

Das Backend ist das Herzstück des Systems und muss auf einem Server mit permanenter Internetverbindung laufen. Es wird empfohlen, einen Virtual Private Server (VPS) mit Ubuntu 22.04 oder einer ähnlichen Linux-Distribution zu verwenden.

### 1.1 Server-Vorbereitung

1.  **Node.js und npm installieren:**
    ```bash
    sudo apt update
    sudo apt install -y nodejs npm
    ```
2.  **PostgreSQL-Client installieren (falls nicht bereits vorhanden):**
    ```bash
    sudo apt install -y postgresql-client
    ```
3.  **Git installieren:**
    ```bash
    sudo apt install -y git
    ```
4.  **Projekt klonen:**
    Navigieren Sie zu dem Verzeichnis, in dem Sie das Backend speichern möchten (z.B. `/var/www/`):
    ```bash
    cd /var/www/
    sudo git clone <URL_ZU_IHREM_GIT_REPOSITORY>/team-system.git
    cd team-system/backend
    ```

### 1.2 Abhängigkeiten installieren

Navigieren Sie in das Backend-Verzeichnis und installieren Sie die Node.js-Abhängigkeiten:

```bash
cd /var/www/team-system/backend
npm install
```

### 1.3 Umgebungsvariablen konfigurieren

Erstellen Sie eine `.env`-Datei im `backend`-Verzeichnis basierend auf der `.env.example`-Datei. Ersetzen Sie die Platzhalter durch Ihre tatsächlichen Werte:

```bash
cp .env.example .env
nano .env
```

Beispiel `.env` Inhalt:

```
PORT=3000
DATABASE_URL=postgresql://<db_user>:<db_password>@<db_host>:<db_port>/<db_name>
JWT_SECRET=Ihr_sehr_geheimes_JWT_Geheimnis_hier_einfuegen
```

*   `DATABASE_URL`: Die Verbindungszeichenfolge zu Ihrer PostgreSQL-Datenbank (siehe Abschnitt 2).
*   `JWT_SECRET`: Ein langes, zufälliges und sicheres Geheimnis für die JSON Web Token (JWT) Signierung. Generieren Sie ein komplexes Geheimnis.

### 1.4 Backend starten

Um das Backend zu starten, können Sie den folgenden Befehl verwenden:

```bash
npm start
```

Für den Produktivbetrieb wird empfohlen, einen Prozessmanager wie PM2 zu verwenden, um das Backend im Hintergrund laufen zu lassen und bei Abstürzen automatisch neu zu starten:

```bash
sudo npm install -g pm2
pm2 start index.js --name 
"team-system-backend"
pm2 save
pm2 startup
```

### 1.5 Nginx als Reverse Proxy einrichten

Um das Backend über eine Domain und Port 80/443 erreichbar zu machen, verwenden wir Nginx als Reverse Proxy.

1.  **Nginx installieren:**
    ```bash
    sudo apt install -y nginx
    ```
2.  **Nginx-Konfigurationsdatei erstellen:**
    Erstellen Sie eine neue Konfigurationsdatei für Ihre Domain (z.B. `/etc/nginx/sites-available/api.yourdomain.com`):
    ```bash
    sudo nano /etc/nginx/sites-available/api.yourdomain.com
    ```
    Fügen Sie folgenden Inhalt ein (ersetzen Sie `api.yourdomain.com` durch Ihre tatsächliche Domain):
    ```nginx
    server {
        listen 80;
        server_name api.yourdomain.com;

        location / {
            proxy_pass http://localhost:3000; # Port, auf dem Ihr Node.js-Backend läuft
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
    ```
3.  **Konfiguration aktivieren und Nginx neu starten:**
    ```bash
    sudo ln -s /etc/nginx/sites-available/api.yourdomain.com /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl restart nginx
    ```

### 1.6 SSL-Verschlüsselung mit Certbot (Let's Encrypt)

Um die Kommunikation zu sichern, richten wir ein kostenloses SSL-Zertifikat ein.

1.  **Certbot installieren:**
    ```bash
    sudo snap install core
    sudo snap refresh core
    sudo snap install --classic certbot
    sudo ln -s /snap/bin/certbot /usr/bin/certbot
    ```
2.  **SSL-Zertifikat für Nginx anfordern:**
    ```bash
    sudo certbot --nginx -d api.yourdomain.com
    ```
    Folgen Sie den Anweisungen. Certbot konfiguriert Nginx automatisch für HTTPS und richtet die automatische Verlängerung ein.

## 2. Datenbank-Setup (PostgreSQL)

### 2.1 PostgreSQL installieren und konfigurieren

1.  **PostgreSQL installieren:**
    ```bash
    sudo apt install -y postgresql postgresql-contrib
    ```
2.  **PostgreSQL-Dienst starten und aktivieren:**
    ```bash
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    ```
3.  **Neuen Benutzer und Datenbank erstellen:**
    Wechseln Sie zum PostgreSQL-Benutzer und erstellen Sie einen neuen Benutzer und eine Datenbank für Ihr System. Ersetzen Sie `<db_user>`, `<db_password>` und `<db_name>` durch Ihre gewünschten Werte.
    ```bash
    sudo -i -u postgres
    createuser --interactive
    # Geben Sie den Benutzernamen ein (z.B. teamsystem_user)
    # Sagen Sie 'y' für Superuser-Rechte (für einfache Einrichtung, später einschränken)
    createdb <db_name>
    psql -c "ALTER USER <db_user> WITH PASSWORD '<db_password>';"
    exit
    ```
4.  **Datenbank-Schema anwenden:**
    Importieren Sie das `schema.sql` in Ihre neue Datenbank:
    ```bash
    psql -h localhost -U <db_user> -d <db_name> -f /var/www/team-system/backend/schema.sql
    ```

### 2.2 LuckPerms-Datenbank-Verbindung

Stellen Sie sicher, dass Ihr Backend eine Verbindung zur LuckPerms-Datenbank herstellen kann. Dies bedeutet, dass die LuckPerms-Datenbank (z.B. MySQL oder PostgreSQL) vom Backend-Server aus erreichbar sein muss. Wenn LuckPerms eine separate Datenbank verwendet, müssen Sie die `DATABASE_URL` in der `.env`-Datei des Backends entsprechend anpassen, um auch die LuckPerms-Datenbank abfragen zu können (oder eine separate Verbindung dafür einrichten).

## 3. Flutter-App-Build und Distribution

Die Flutter-App kann für verschiedene Plattformen gebaut werden:

### 3.1 Desktop (Windows, macOS, Linux)

1.  **Flutter SDK installieren:** Folgen Sie der offiziellen Anleitung: [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2.  **Desktop-Unterstützung aktivieren:**
    ```bash
    flutter config --enable-windows-desktop
    flutter config --enable-macos-desktop
    flutter config --enable-linux-desktop
    ```
3.  **Build erstellen:** Navigieren Sie in das `team-system/app`-Verzeichnis und führen Sie den Build-Befehl aus:
    ```bash
    cd /path/to/team-system/app
    flutter build windows
    # oder flutter build macos
    # oder flutter build linux
    ```
    Die ausführbare Datei (.exe für Windows) finden Sie im Ordner `build/windows/runner/Release/`.

### 3.2 Mobile (Android, iOS)

1.  **Flutter SDK und Entwicklungsumgebung einrichten:** Folgen Sie der offiziellen Anleitung: [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2.  **Build erstellen:** Navigieren Sie in das `team-system/app`-Verzeichnis und führen Sie den Build-Befehl aus:
    ```bash
    cd /path/to/team-system/app
    flutter build apk --release
    # oder flutter build appbundle --release (für Google Play Store)
    # oder flutter build ios --release (für iOS, benötigt macOS)
    ```
    Die APK-Datei für Android finden Sie unter `build/app/outputs/flutter/apk/app-release.apk`.

### 3.3 API-URL in der App anpassen

Bevor Sie die App bauen, müssen Sie die API-URL in der `auth_service.dart` anpassen:

```dart
// team-system/app/lib/services/auth_service.dart
final response = await http.post(
  Uri.parse("https://api.yourdomain.com/api/login"), // <-- HIER ANPASSEN
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({"username": username, "password": password}),
);
```

## 4. Minecraft-Plugin-Kompilierung und Installation

### 4.1 Plugin kompilieren

Das Minecraft-Plugin wurde in Java geschrieben und benötigt eine Kompilierung zu einer `.jar`-Datei. Dies geschieht typischerweise mit Build-Tools wie Maven oder Gradle. Da das Projektgerüst hier nicht vollständig ist, wird der manuelle Kompilierungsprozess beschrieben.

1.  **Java Development Kit (JDK) installieren:** Stellen Sie sicher, dass JDK 17 oder höher installiert ist.
    ```bash
    sudo apt install -y openjdk-17-jdk
    ```
2.  **Maven installieren:**
    ```bash
    sudo apt install -y maven
    ```
3.  **Plugin-Code anpassen:**
    Öffnen Sie die Datei `team-system/plugin/src/main/java/im/manus/teamsystem/TeamSystemPlugin.java` und passen Sie die `your-api-url.com` an die tatsächliche URL Ihres Backends an:
    ```java
    // ...
    URL url = new URL("https://api.yourdomain.com/api/users"); // <-- HIER ANPASSEN
    // ...
    ```
4.  **Kompilieren:** Navigieren Sie in das `team-system/plugin`-Verzeichnis und kompilieren Sie das Plugin:
    ```bash
    cd /path/to/team-system/plugin
    # Wenn Sie ein Maven-Projektgerüst hätten, wäre es 'mvn clean package'
    # Für eine manuelle Kompilierung (Beispiel):
    # javac -d target/classes src/main/java/im/manus/teamsystem/TeamSystemPlugin.java
    # jar -cvf target/TeamSystem-1.0.0.jar -C target/classes .
    ```
    *Hinweis: Für ein vollständiges Minecraft-Plugin-Projekt würden Sie ein `pom.xml` (Maven) oder `build.gradle` (Gradle) verwenden, um den Build-Prozess zu automatisieren. Die obigen `javac`/`jar`-Befehle sind vereinfacht und dienen nur als Beispiel.* Die resultierende `.jar`-Datei finden Sie im `target/`-Verzeichnis.

### 4.2 Plugin installieren

1.  **`.jar`-Datei kopieren:** Kopieren Sie die kompilierte `TeamSystem-1.0.0.jar`-Datei in den `plugins`-Ordner Ihres Spigot/Paper/Purpur-Servers.
2.  **Server neu starten:** Starten Sie Ihren Minecraft-Server neu, damit das Plugin geladen wird.
3.  **LuckPerms-Integration:** Stellen Sie sicher, dass LuckPerms auf Ihrem Server installiert und konfiguriert ist, da unser Plugin davon abhängt.

## 5. Referenzen

*   [Node.js Offizielle Website](https://nodejs.org/)
*   [Express.js Offizielle Website](https://expressjs.com/)
*   [PostgreSQL Offizielle Website](https://www.postgresql.org/)
*   [Flutter Offizielle Website](https://flutter.dev/)
*   [Nginx Offizielle Website](https://nginx.org/)
*   [Certbot (Let's Encrypt) Offizielle Website](https://certbot.eff.org/)
*   [LuckPerms Wiki](https://luckperms.net/wiki/Home)
