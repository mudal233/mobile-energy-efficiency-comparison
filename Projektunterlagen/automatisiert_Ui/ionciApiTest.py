import time
import subprocess
from appium import webdriver
from appium.options.common.base import AppiumOptions

# --- Zeitdauern in Minuten ---
zeitdauern_min = [5,10,15,20,25,30,35,40,45,50]

# --- Appium Konfiguration ---
options = AppiumOptions()
options.load_capabilities({
    "appium:automationName": "UiAutomator2",
    "platformName": "Android",
    "appium:platformVersion": "14",
    "appium:deviceName": "46041FDAP000TA",
    "appium:app": "C:\\Users\\motaz\\Desktop\\ionic\\ionic-crypto\\android\\app\\build\\intermediates\\apk\\debug\\app-debug.apk",
    "appium:ensureWebviewsHavePages": True,
    "appium:nativeWebScreenshot": True,
    "appium:newCommandTimeout": 100000,
    "appium:connectHardwareKeyboard": True,
    "appium:chromedriverAutodownload": True,
    "appium:autoWebview": False
})

driver = webdriver.Remote("http://127.0.0.1:4723/wd/hub", options=options)
time.sleep(5)  # App starten lassen

# --- WebView-Kontext aktivieren ---
contexts = driver.contexts
for ctx in contexts:
    if "WEBVIEW" in ctx:
        driver.switch_to.context(ctx)
        print(f"🌐 Switched to WebView: {ctx}")
        break

# --- Testdurchläufe ---
for i, dauer_min in enumerate(zeitdauern_min):
    dauer_sec = dauer_min * 60
    print(f"\n🚀 Starte Test {i+1} für {dauer_min} Minute(n)")

    # --- Trace-Dateien definieren ---
    trace_name = f"ionic_trace_{dauer_min}min.perfetto-trace"
    device_trace_path = f"/data/misc/perfetto-traces/{trace_name}"
    local_trace_path = f"C:/Users/motaz/PycharmProjects/PythonProject2/ionicApiTest/kette1/{trace_name}"
    config_path = "C:/Users/motaz/PycharmProjects/PythonProject2/ionicApiTest/trace_config.txt"

    # --- Starte Perfetto ---
    print("🔴 Starte Perfetto...")
    perfetto_cmd = f'adb shell perfetto --background -c - --txt --out {device_trace_path} < "{config_path}"'
    subprocess.Popen(perfetto_cmd, shell=True)
    time.sleep(2)

    # --- App einfach laufen lassen ---
    print(f"⏳ App läuft für {dauer_min} Minute(n)...")
    time.sleep(dauer_sec)

    # --- Stoppe Perfetto ---
    print("🛑 Stoppe Perfetto...")
    subprocess.run("adb shell killall perfetto", shell=True)
    time.sleep(2)

    # --- Trace herunterladen ---
    print("💾 Lade Trace-Datei herunter...")
    subprocess.run(f'adb pull {device_trace_path} "{local_trace_path}"', shell=True)
    print(f"✅ Trace gespeichert unter: {local_trace_path}")
    time.sleep(2)

# --- Test fertig ---
driver.quit()
print("\n🎉 Alle Ionic-Tests abgeschlossen!")
