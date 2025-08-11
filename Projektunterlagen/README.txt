# Matrix-Benchmark Tests – Setup & Ausführung

Dieses Projekt enthält ein Python-Skript, das eine Android-App automatisiert, Messläufe mit unterschiedlichen Eingabewerten startet und für jeden Lauf einen **Perfetto-Trace** vom Gerät zieht.

## 1. Benötigte Tools & Installation

Hier ist eine klare Liste der Tools, die du brauchst, und wie du sie installierst:

### 1.1 Python (>= 3.9)
- **Warum?** Zum Ausführen des Automatisierungsskripts.
- **Installation:**
  - **Windows:** Lade den Installer von https://www.python.org/downloads/ herunter und installiere mit der Option *Add to PATH*.
  - **macOS:** `brew install python`
  - **Linux (Debian/Ubuntu):** `sudo apt install python3 python3-venv`

Prüfen:
```bash
python --version
```

### 1.2 Node.js (>= 16) & npm
- **Warum?** Appium Server benötigt Node.js.
- **Installation:**
  - **Windows/macOS/Linux:** Lade den Installer von https://nodejs.org/ (LTS-Version) herunter.
  - **macOS (brew):** `brew install node`
  - **Linux (Debian/Ubuntu):** `sudo apt install nodejs npm`

Prüfen:
```bash
node -v
npm -v
```

### 1.3 Java JDK (>= 11)
- **Warum?** Android-Build-Tools und ADB benötigen Java.
- **Installation:**
  - **Windows/macOS/Linux:** Lade das JDK von https://adoptium.net oder https://www.oracle.com/java/technologies/javase-downloads.html herunter und installiere es.
  - **macOS (brew):** `brew install openjdk@17`
  - **Linux (Debian/Ubuntu):** `sudo apt install openjdk-17-jdk`

Prüfen:
```bash
java -version
```

### 1.4 Android SDK & Platform-Tools (ADB)
- **Warum?** Kommunikation mit dem Android-Gerät.
- **Installation:**
  - **Mit Android Studio:** *SDK Manager → SDK Tools → Android SDK Platform-Tools* installieren.
  - **Ohne Android Studio:** Lade *platform-tools* von https://developer.android.com/studio/releases/platform-tools herunter, entpacke und füge zum `PATH` hinzu.

Prüfen:
```bash
adb version
```

### 1.5 Appium Server v2
- **Warum?** Steuerung der Android-App via WebDriver.
- **Installation:**
```bash
npm install -g appium
```
Prüfen:
```bash
appium -v
```

### 1.6 Appium UiAutomator2 Driver
- **Warum?** Appium-Driver für Android Native-Apps.
- **Installation:**
```bash
appium driver install uiautomator2
```

### 1.7 Appium Python Client
- **Warum?** Python-Bindings für Appium.
- **Installation:**
```bash
pip install Appium-Python-Client
```

### 1.8 Selenium für Python
- **Warum?** WebDriver-Wartefunktionen (Expected Conditions, Waits).
- **Installation:**
```bash
pip install selenium
```

### 1.9 Perfetto (bereits in Android enthalten)
- **Warum?** Performance-Trace aufnehmen.
- **Installation:** Keine extra Installation nötig – ist ab Android 10 Teil des Systems.

---

## 2. Android-Gerät vorbereiten

1. **USB-Debugging** aktivieren  
   - Einstellungen → Über das Telefon → 7× auf *Build-Nummer* tippen → Entwickleroptionen → USB-Debugging einschalten.

2. **Gerät verbinden & prüfen**
```bash
adb devices
# Gerät muss in der Liste erscheinen
```

3. (Optional) **APK installieren**
```bash
adb install -r "Pfad/zur/app-debug.apk"
```

---

## 3. Tests ausführen

1. **Appium Server starten**
```bash
appium
```
Standard-Port: `http://127.0.0.1:4723`

2. **Python-Skript starten**
```bash
python run_tests.py
```

Das Skript:
- Startet Perfetto auf dem Gerät
- Gibt Testwerte in die App ein
- Startet die Berechnung
- Wartet bis der Button wieder aktiv ist
- Stoppt Perfetto
- Lädt Trace-Datei lokal herunter

---

## 4. Häufige Probleme & Tipps

- **ADB nicht gefunden:** Prüfe, ob `platform-tools` im `PATH` liegt.
- **Appium findet Driver nicht:** `appium driver install uiautomator2` erneut ausführen.
- **UI-Element nicht gefunden:** IDs mit Appium Inspector prüfen und im Script anpassen.
- **Keine Schreibrechte für `/data/misc/perfetto-traces`:** Alternativen Pfad wie `/sdcard/Download` verwenden.

---
