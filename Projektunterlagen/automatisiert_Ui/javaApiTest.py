import time
import subprocess
from appium import webdriver
from appium.options.common.base import AppiumOptions

# --- Zeitdauern in Minuten ---
zeitdauern_min = [5,10,15,20,25,30,35,40,45,50]

# --- Appium Optionen für CryptoPriceAppJava ---
options = AppiumOptions()
options.load_capabilities({
    "appium:automationName": "UiAutomator2",
    "platformName": "Android",
    "appium:platformVersion": "14",
    "appium:deviceName": "46041FDAP000TA",
    "appium:app": "C:\\Users\\motaz\\AndroidStudioProjects\\CryptoPriceAppJava\\app\\build\\intermediates\\apk\\debug\\app-debug.apk",
    "appium:ensureWebviewsHavePages": True,
    "appium:nativeWebScreenshot": True,
    "appium:newCommandTimeout": 100000,
    "appium:connectHardwareKeyboard": True
})

driver = webdriver.Remote("http://127.0.0.1:4723", options=options)
time.sleep(5)  # Zeit für App-Start

# --- Testdurchläufe für jede Zeitdauer ---
for i, dauer_min in enumerate(zeitdauern_min):
    dauer_sec = dauer_min * 60
    print(f"\n🚀 Starte Test {i+1} für {dauer_min} Minute(n)")

    # Trace-Dateinamen
    trace_name = f"test_trace_{dauer_min}min.perfetto-trace"
    device_trace_path = f"/data/misc/perfetto-traces/{trace_name}"
    local_trace_path = f"C:/Users/motaz/PycharmProjects/PythonProject2/javaApiTest/kette1/{trace_name}"

    # Starte Perfetto
    print("🔴 Starte Perfetto-Trace auf dem Gerät...")
    perfetto_cmd = (
        f'adb shell perfetto --background -c - --txt --out {device_trace_path} < '
        f'"C:/Users/motaz/PycharmProjects/PythonProject2/javaApiTest/trace_config.txt"'
    )
    subprocess.Popen(perfetto_cmd, shell=True)
    time.sleep(2)

    # App läuft einfach für X Minuten
    print(f"⏳ App läuft für {dauer_min} Minute(n)...")
    time.sleep(dauer_sec)

    # Stoppe Perfetto
    print("🛑 Stoppe Perfetto...")
    subprocess.run("adb shell killall perfetto", shell=True)
    time.sleep(2)

    # Trace-Datei herunterladen
    print("💾 Lade Trace-Datei herunter...")
    subprocess.run(
        f'adb pull {device_trace_path} "{local_trace_path}"',
        shell=True
    )
    print(f"✅ Trace gespeichert: {local_trace_path}")
    time.sleep(2)

# Test abgeschlossen
print("\n🎉 Alle Zeitdauer-Tests abgeschlossen!")
driver.quit()
