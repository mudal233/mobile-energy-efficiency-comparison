import time
import random
import string
import subprocess
from appium import webdriver
from appium.options.common.base import AppiumOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# --- Testwerte definieren ---
test_counts = [50, 100, 150, 200, 250, 300, 350, 400, 450, 500]

# --- Pfade definieren ---
trace_config = "C:/Users/motaz/PycharmProjects/PythonProject2/ionicNotizTest/trace_config.txt"
trace_output_dir = "C:/Users/motaz/PycharmProjects/PythonProject2/ionnicNotizTest/trace"

# --- Appium Optionen ---
options = AppiumOptions()
options.load_capabilities({
    "platformName": "Android",
    "appium:automationName": "UiAutomator2",
    "appium:platformVersion": "14",
    "appium:deviceName": "46041FDAP000TA",
    "appium:app": "C:\\Users\\motaz\\Desktop\\vue\\notizApp\\android\\app\\build\\intermediates\\apk\\debug\\app-debug.apk",
    "appium:newCommandTimeout": 3600,
    "appium:autoWebview": False,
    "appium:ensureWebviewsHavePages": True
})

driver = webdriver.Remote("http://127.0.0.1:4723", options=options)
wait = WebDriverWait(driver, 30)

# --- Kontextwechsel zu WebView ---
time.sleep(5)
contexts = driver.contexts
print(f"📱 Verfügbare Kontexte: {contexts}")

webview_context = next((c for c in contexts if "WEBVIEW" in c), None)
if not webview_context:
    raise Exception("❌ Kein WebView-Kontext gefunden")
driver.switch_to.context(webview_context)
print(f"🔄 Kontext gewechselt zu: {webview_context}")

# --- App initialisieren: z. B. FAB klicken, wenn vorhanden ---
fab = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, 'ion-fab-button')))
fab.click()

# --- Testdurchläufe ---
for idx, count in enumerate(test_counts):
    print(f"\n🚀 Starte Test {idx + 1} – {count} Notizen")

    trace_name = f"notes_trace_{count}.perfetto-trace"
    device_trace_path = f"/data/misc/perfetto-traces/{trace_name}"
    local_trace_path = f"{trace_output_dir}/{trace_name}"

    print("🔴 Starte Perfetto-Trace auf dem Gerät...")
    perfetto_cmd = (
        f'adb shell perfetto --background -c - --txt --out {device_trace_path} < "{trace_config}"'
    )
    subprocess.Popen(perfetto_cmd, shell=True)
    time.sleep(2)

    for i in range(1, count + 1):
        print(f"📝 Notiz {i}/{count}")

        # Titel
        title = f"Titel {i}"
        title_field = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, 'input[formcontrolname="title"]')))
        title_field.clear()
        title_field.send_keys(title)

        # Inhalt
        content = ' '.join(
            ''.join(random.choices(string.ascii_lowercase, k=8)).capitalize() + '.' for _ in range(20)
        )
        content_field = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, 'textarea[formcontrolname="content"]')))
        content_field.clear()
        content_field.send_keys(content)

        # Kategorie Dropdown (z. B. „Idee“)
        dropdown = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, 'ion-select[name="category"]')))
        dropdown.click()
        idee_option = wait.until(EC.element_to_be_clickable((By.XPATH, '//ion-select-option[contains(text(),"Idee")]')))
        idee_option.click()

        # Speichern
        save_button = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, 'ion-button[type="submit"]')))
        save_button.click()

        time.sleep(0.5)

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
print("\n🎉 Alle Ionic-Notiz-Benchmark-Tests abgeschlossen!")
driver.quit()
