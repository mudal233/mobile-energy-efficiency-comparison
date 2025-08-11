import time
import subprocess
from appium import webdriver
from appium.options.common.base import AppiumOptions
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# --- Testwerte definieren ---
test_values = [1, 2, 3, 4, 5,6,7,8,9,10]

# --- Appium Optionen ---
options = AppiumOptions()
options.load_capabilities({
    "platformName": "Android",
    "appium:deviceName": "46041FDAP000TA",
    "appium:automationName": "Flutter",
    "appium:app": "C:\\Users\\motaz\\AndroidStudioProjects\\fluttermediabenchmark\\app\\build\\intermediates\\apk\\debug\\app-debug.apk",
    "appium:newCommandTimeout": 3600
})

driver = webdriver.Remote("http://127.0.0.1:4723", options=options)
wait = WebDriverWait(driver, 30)

# --- Warten bis Flutter geladen ist ---
driver.execute_script('flutter:waitForFirstFrame')

# --- Testdurchläufe ---
for i, value in enumerate(test_values):
    print(f"\n🚀 Starte Test {i+1} mit Eingabewert: {value}")

    trace_name = f"media_trace_{value}.perfetto-trace"
    device_trace_path = f"/data/misc/perfetto-traces/{trace_name}"
    local_trace_path = f"C:/Users/motaz/PycharmProjects/PythonProject2/flutterMediaTest/trace/{trace_name}"

    # --- Perfetto starten ---
    print("🔴 Starte Perfetto-Trace auf dem Gerät...")
    perfetto_cmd = (
        f'adb shell perfetto --background -c - --txt --out {device_trace_path} < '
        f'"C:/Users/motaz/PycharmProjects/PythonProject2/flutterMediaTest/trace_config.txt"'
    )
    subprocess.Popen(perfetto_cmd, shell=True)
    time.sleep(2)

    # --- Flutter Widgets interagieren ---
    input_field = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "repeatInput")
    start_button = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "startButton")

    input_field.click()
    input_field.clear()
    input_field.send_keys(str(value))
    start_button.click()
    print("📲 Test gestartet... warte auf Beendigung")
    time.sleep(2)

    # --- Warten, bis Button wieder aktiv ist (z. B. durch erneutes Finden) ---
    while True:
        try:
            start_button = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "startButton")
            if start_button.is_enabled():
                break
        except Exception:
            pass
        time.sleep(1)

    print("✅ Test beendet. Stoppe Perfetto...")
    subprocess.run("adb shell killall perfetto", shell=True)
    time.sleep(2)

    print("💾 Trace-Datei wird heruntergeladen...")
    subprocess.run(
        f'adb pull {device_trace_path} "{local_trace_path}"',
        shell=True
    )
    print(f"✅ Trace gespeichert: {local_trace_path}")
    time.sleep(2)

# --- Ende ---
print("\n🎉 Alle Media-Benchmark-Tests abgeschlossen!")
driver.quit()
