import time
import random
import string
import subprocess
from appium import webdriver
from appium.options.common.base import AppiumOptions
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# --- Testwerte definieren ---
test_counts = [50,100,150,200,250,300,350,400,450,500]  # Ändere auf 50, 100, ... für echte Tests

# --- Pfade definieren ---
trace_config = "C:/Users/motaz/PycharmProjects/PythonProject2/javaNotizTest/trace_config.txt"
trace_output_dir = "C:/Users/motaz/PycharmProjects/PythonProject2/javaNotizTest/trace"

# --- Appium Optionen ---
options = AppiumOptions()
options.load_capabilities({
    "appium:automationName": "UiAutomator2",
    "platformName": "Android",
    "appium:platformVersion": "14",
    "appium:deviceName": "46041FDAP000TA",
    "appium:app": "C:\\Users\\motaz\\AndroidStudioProjects\\notesapp\\app\\build\\intermediates\\apk\\debug\\app-debug.apk",
    "appium:newCommandTimeout": 3600,
})

driver = webdriver.Remote("http://127.0.0.1:4723", options=options)
wait = WebDriverWait(driver, 30)
fab = wait.until(EC.presence_of_element_located((AppiumBy.ID, "com.example.notesapp:id/fabManualAdd")))
fab.click()
# --- Testdurchläufe ---
for idx, count in enumerate(test_counts):
    print(f"\n🚀 Starte Test {idx + 1} – {count} Notizen")

    trace_name = f"notes_trace_{count}.perfetto-trace"
    device_trace_path = f"/data/misc/perfetto-traces/{trace_name}"
    local_trace_path = f"{trace_output_dir}/{trace_name}"

    # --- Perfetto starten ---
    print("🔴 Starte Perfetto-Trace auf dem Gerät...")
    perfetto_cmd = (
        f'adb shell perfetto --background -c - --txt --out {device_trace_path} < "{trace_config}"'
    )
    subprocess.Popen(perfetto_cmd, shell=True)
    time.sleep(2)

    # --- Notizen erstellen ---
    for i in range(1, count + 1):
        print(f"📝 Notiz {i}/{count}")



        title = f"Titel {i}"
        title_field = wait.until(EC.presence_of_element_located((AppiumBy.ID, "com.example.notesapp:id/edit_title")))
        title_field.send_keys(title)

        content = ' '.join(
            ''.join(random.choices(string.ascii_lowercase, k=8)).capitalize() + '.' for _ in range(20)
        )
        content_field = wait.until(EC.presence_of_element_located((AppiumBy.ID, "com.example.notesapp:id/edit_content")))
        content_field.send_keys(content)

        spinner = wait.until(EC.presence_of_element_located((AppiumBy.ID, "android:id/text1")))
        spinner.click()
        idee = wait.until(EC.presence_of_element_located((
            AppiumBy.XPATH, "//android.widget.CheckedTextView[@resource-id='android:id/text1' and @text='Idee']"
        )))
        idee.click()

        save_button = wait.until(EC.presence_of_element_located((AppiumBy.ID, "com.example.notesapp:id/btn_save_note")))
        save_button.click()
        time.sleep(0.5)

    # --- Perfetto stoppen ---
    print("✅ Test beendet. Stoppe Perfetto...")
    subprocess.run("adb shell killall perfetto", shell=True)
    time.sleep(2)

    # --- Trace-Datei kopieren ---
    print("💾 Trace-Datei wird heruntergeladen...")
    subprocess.run(
        f'adb pull {device_trace_path} "{local_trace_path}"',
        shell=True
    )
    print(f"✅ Trace gespeichert: {local_trace_path}")
    time.sleep(2)

# --- Ende ---
print("\n🎉 Alle Notiz-Benchmark-Tests abgeschlossen!")
driver.quit()
