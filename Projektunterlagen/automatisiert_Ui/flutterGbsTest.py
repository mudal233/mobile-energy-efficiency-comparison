import time
import subprocess
from appium import webdriver
from appium.options.common.base import AppiumOptions
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# --- Testwerte definieren ---
test_values = [100,200,300,400,500,600,700,800,900,1000]

# --- Appium Optionen ---
options = AppiumOptions()
options.load_capabilities({
    "appium:automationName": "UiAutomator2",
    "platformName": "Android",
    "appium:platformVersion": "14",
    "appium:deviceName": "46041FDAP000TA",
    "appium:app": "C:\\Users\\motaz\\AndroidStudioProjects\\gps_benchmark_flutter\\build\\app\\outputs\\apk\\debug\\app-debug.apk",
    "appium:ensureWebviewsHavePages": True,
    "appium:nativeWebScreenshot": True,
    "appium:newCommandTimeout": 3600,
    "appium:connectHardwareKeyboard": True
})

driver = webdriver.Remote("http://127.0.0.1:4723", options=options)
wait = WebDriverWait(driver, 30)

# --- UI-Elemente holen per XPath (Flutter Widgets) ---
input_field = wait.until(EC.presence_of_element_located((
    AppiumBy.XPATH, "//android.widget.EditText"
)))
start_button = wait.until(EC.presence_of_element_located((
    AppiumBy.XPATH, "//android.widget.Button[@content-desc='Start']"
)))

# --- Testdurchläufe ---
for i, value in enumerate(test_values):
    print(f"\n🚀 Starte Test {i+1} mit Eingabewert: {value}")

    trace_name = f"test_trace_{value}.perfetto-trace"
    device_trace_path = f"/data/misc/perfetto-traces/{trace_name}"
    local_trace_path = f"C:/Users/motaz/PycharmProjects/PythonProject2/flutterGbsTest/trace/{trace_name}"

    # --- Perfetto starten ---
    print("🔴 Starte Perfetto-Trace auf dem Gerät...")
    perfetto_cmd = (
        f'adb shell perfetto --background -c - --txt --out {device_trace_path} < '
        f'"C:/Users/motaz/PycharmProjects/PythonProject2/flutterGbsTest/trace_config.txt"'
    )
    subprocess.Popen(perfetto_cmd, shell=True)
    time.sleep(2)

    # --- Eingabe setzen & Start drücken ---
    input_field.click()
    input_field.clear()
    input_field.send_keys(str(value))
    start_button.click()
    print("📲 Test gestartet... warte auf Beendigung")

    # --- Warte bis Button wieder aktiv (nicht mehr disabled) ist ---
    while not start_button.is_enabled():
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

print("\n🎉 Alle Tests abgeschlossen!")
driver.quit()
