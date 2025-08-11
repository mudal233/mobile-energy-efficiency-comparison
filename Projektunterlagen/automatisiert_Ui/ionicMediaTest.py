import time
import subprocess
from appium import webdriver
from appium.options.common.base import AppiumOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# --- Testwerte definieren ---
test_values = [1, 2, 3, 4, 5,6,7,8,9,10]

# --- Appium Optionen ---
options = AppiumOptions()
options.load_capabilities({
    "platformName": "Android",
    "appium:automationName": "UiAutomator2",
    "appium:deviceName": "46041FDAP000TA",
    "appium:app": "C:\\Users\\motaz\\Desktop\\vue\\ionicmediabenchmark\\android\\app\\build\\intermediates\\apk\\debug\\app-debug.apk",
    "appium:autoWebview": False,  # wir wechseln selbst manuell den Kontext
    "appium:newCommandTimeout": 3600,
    "appium:ensureWebviewsHavePages": True
})

driver = webdriver.Remote("http://127.0.0.1:4723", options=options)
wait = WebDriverWait(driver, 30)

# --- Warte auf WebView & wechsle Kontext ---
time.sleep(5)  # Zeit geben, bis WebView geladen ist
contexts = driver.contexts
print(f"📱 Verfügbare Kontexte: {contexts}")

# Wechsel zu WebView
for context in contexts:
    if 'WEBVIEW' in context:
        driver.switch_to.context(context)
        print(f"🔄 Wechsel zu Kontext: {context}")
        break
else:
    raise Exception("❌ Kein WebView-Kontext gefunden")

# --- Testdurchläufe ---
for i, value in enumerate(test_values):
    print(f"\n🚀 Starte Test {i+1} mit Eingabewert: {value}")

    trace_name = f"media_trace_{value}.perfetto-trace"
    device_trace_path = f"/data/misc/perfetto-traces/{trace_name}"
    local_trace_path = f"C:/Users/motaz/PycharmProjects/PythonProject2/ionicMediaTest/trace/{trace_name}"

    # --- Perfetto starten ---
    print("🔴 Starte Perfetto-Trace auf dem Gerät...")
    perfetto_cmd = (
        f'adb shell perfetto --background -c - --txt --out {device_trace_path} < '
        f'"C:/Users/motaz/PycharmProjects/PythonProject2/ionicMediaTest/trace_config.txt"'
    )
    subprocess.Popen(perfetto_cmd, shell=True)
    time.sleep(2)

    # --- Ionic: Eingabe setzen und Button drücken ---
    input_field = wait.until(EC.presence_of_element_located((
        By.CSS_SELECTOR, 'input[inputID="repeat"]'
    )))
    start_button = wait.until(EC.element_to_be_clickable((
        By.XPATH, '//button[contains(text(),"Start") or contains(text(),"Los")]'
    )))

    input_field.clear()
    input_field.send_keys(str(value))
    start_button.click()
    print("📲 Test gestartet... warte auf Beendigung")
    time.sleep(2)

    # --- Warten, bis Button wieder aktiv ist ---
    while True:
        try:
            if start_button.is_enabled():
                break
        except Exception:
            pass
        time.sleep(1)

    print("✅ Test beendet. Stoppe Perfetto...")
    subprocess.run("adb shell killall perfetto", shell=True)
    time.sleep(2)

    # --- Datei herunterladen ---
    print("💾 Trace-Datei wird heruntergeladen...")
    subprocess.run(
        f'adb pull {device_trace_path} "{local_trace_path}"',
        shell=True
    )
    print(f"✅ Trace gespeichert: {local_trace_path}")
    time.sleep(2)

# --- Abschluss ---
print("\n🎉 Alle WebView-Benchmark-Tests abgeschlossen!")
driver.quit()
