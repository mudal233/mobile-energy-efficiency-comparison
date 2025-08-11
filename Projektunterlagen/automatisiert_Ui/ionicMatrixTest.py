import time
import subprocess
import re
from appium import webdriver
from appium.options.common.base import AppiumOptions
from appium.webdriver.common.appiumby import AppiumBy
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait

# --- Testwerte definieren ---
test_values = [10,20,30,40,50,60,70,80,90,100]

# --- Appium Optionen ---
options = AppiumOptions()
options.load_capabilities({
    "appium:automationName": "UiAutomator2",
    "platformName": "Android",
    "appium:platformVersion": "14",
    "appium:deviceName": "46041FDAP000TA",
    "appium:app": "C:\\Users\\motaz\\Desktop\\vue\\matrix-multiplication-app\\android\\app\\build\\intermediates\\apk\\debug\\app-debug.apk",
    "appium:ensureWebviewsHavePages": True,
    "appium:nativeWebScreenshot": True,
    "appium:newCommandTimeout": 10000,
    "appium:connectHardwareKeyboard": True,
    "appium:chromedriverAutodownload": True,
    "appium:autoWebview": False
})

driver = webdriver.Remote("http://127.0.0.1:4723/wd/hub", options=options)
wait = WebDriverWait(driver, 30)
time.sleep(2)

# --- Testdurchläufe ---
for i, value in enumerate(test_values):

    contexts = driver.contexts
    for ctx in contexts:
        if "WEBVIEW" in ctx:
            driver.switch_to.context(ctx)
            print(f"🌐 WebView aktiviert: {ctx}")
            break
    print(f"\n🚀 Starte Test {i + 1} mit Eingabewert: {value}")

    trace_name = f"test_trace_{value}.perfetto-trace"
    device_trace_path = f"/data/misc/perfetto-traces/{trace_name}"
    local_trace_path = f"C:/Users/motaz/PycharmProjects/PythonProject2/ionicMatrixTest/test/{trace_name}"
    config_path = "C:/Users/motaz/PycharmProjects/PythonProject2/ionicMatrixTest/trace_config.txt"

    # --- Perfetto starten ---
    print("🔴 Starte Perfetto-Trace auf dem Gerät...")
    perfetto_cmd = f'adb shell perfetto --background -c - --txt --out {device_trace_path} < "{config_path}"'
    subprocess.Popen(perfetto_cmd, shell=True)
    time.sleep(2)

    # --- Eingabe setzen ---
    input_field = wait.until(
        lambda d: d.find_element(AppiumBy.CSS_SELECTOR, "#ion-input-0")
    )
    input_field.clear()
    input_field.send_keys(str(value))
    print(f"🔢 Eingabewert gesetzt: {value}")

    # --- Start-Button klicken ---
    start_button = wait.until(
        lambda d: d.find_element(AppiumBy.XPATH, "//ion-button[contains(., 'Matrix multiplizieren')]")
    )
    start_button.click()
    print("🚀 Start-Button geklickt")

    # --- Warten bis Anzahl Berechnungen erreicht ist ---
    print("⏳ Warte, bis die Anzahl Berechnungen erreicht ist...")

    start_time = time.time()
    last_ping_time = start_time

    while True:
        current_time = time.time()



        # Alle 5 Minuten ein Ping
        if (current_time - last_ping_time) > 300:  # 300 Sekunden = 5 Minuten
            try:
                print("🔄 Sende Keep-Alive Ping (page_source abrufen)...")
                _ = driver.page_source  # oder driver.current_context
                last_ping_time = current_time
            except Exception as e:
                print(f"❌ Fehler beim Keep-Alive Ping: {e}")
                break

        try:
            result_element = driver.find_element(AppiumBy.XPATH, "//h2[contains(text(), 'Anzahl Berechnungen')]")
            result_text = result_element.text

            match = re.search(r"\d+", result_text)
            if match:
                number_only = int(match.group())
                print(f"📊 Aktueller Stand: {number_only} / erwartet: {value}")
                if number_only == value:
                    print(f"✅ Erwartete Anzahl Berechnungen {value} erreicht!")
                    break
            else:
                print("⚠️ Keine Zahl im Text gefunden.")

        except Exception as e:
            print(f"⚠️ Fehler beim Lesen der Anzahl: {e}")
            print("🔄 Versuche, das Element neu zu finden...")
            time.sleep(2)

            try:
                result_element = driver.find_element(AppiumBy.XPATH, "//h2[contains(text(), 'Anzahl Berechnungen')]")
                result_text = result_element.text
                print(result_text)
            except Exception as inner_e:
                print(f"❌ Wieder Fehler beim Neu-Finden: {inner_e}")
                print("⏳ Warten und nächster Versuch...")
                time.sleep(5)

        time.sleep(2)  # kleine Pause am Ende # Normale Pause, um nicht zu spammen

    # --- Test abgeschlossen ---
    print("✅ Test abgeschlossen. Stoppe Perfetto...")

    subprocess.run("adb shell killall perfetto", shell=True)
    time.sleep(2)

    # --- Trace-Datei kopieren ---
    print("💾 Lade Trace-Datei herunter...")
    subprocess.run(
        f'adb pull {device_trace_path} \"{local_trace_path}\"',
        shell=True
    )
    print(f"✅ Trace gespeichert: {local_trace_path}")
    time.sleep(2)

# --- Testende ---
print("\n🎉 Alle Tests abgeschlossen!")
driver.quit()
