import time
import subprocess
from appium import webdriver
from appium.options.common.base import AppiumOptions
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# --- Test values ---
test_values = [100,200,300,400,500,600,700,800,900,1000]

# --- Appium Configuration ---
options = AppiumOptions()
options.load_capabilities({
    "appium:automationName": "UiAutomator2",
    "platformName": "Android",
    "appium:platformVersion": "14",
    "appium:deviceName": "46041FDAP000TA",
    "appium:app": "C:\\Users\\motaz\\Desktop\\vue\\gps-benchmark-vue\\android\\app\\build\\intermediates\\apk\\debug\\app-debug.apk",
    "appium:ensureWebviewsHavePages": True,
    "appium:nativeWebScreenshot": True,
    "appium:newCommandTimeout": 3600,
    "appium:connectHardwareKeyboard": True,
    "appium:chromedriverAutodownload": True,
    "appium:autoWebview": False
})

driver = webdriver.Remote("http://127.0.0.1:4723/wd/hub", options=options)
wait = WebDriverWait(driver, 20)

# --- Switch to WebView ---
time.sleep(3)
contexts = driver.contexts
for ctx in contexts:
    if "WEBVIEW" in ctx:
        driver.switch_to.context(ctx)
        print(f"🌐 Switched to WebView: {ctx}")
        break

# --- Run through all test inputs ---
for i, value in enumerate(test_values):
    print(f"\n🚀 Running Test {i+1} with input: {value}")

    # --- Perfetto trace file setup ---
    trace_name = f"test_trace_{value}.perfetto-trace"
    device_trace_path = f"/data/misc/perfetto-traces/{trace_name}"
    local_trace_path = f"C:/Users/motaz/PycharmProjects/PythonProject2/ionicGbsTest/trace/{trace_name}"
    config_path = "C:/Users/motaz/PycharmProjects/PythonProject2/ionicGbsTest/trace_config.txt"

    # --- Start Perfetto ---
    print("🔴 Starting Perfetto...")
    perfetto_cmd = f'adb shell perfetto --background -c - --txt --out {device_trace_path} < "{config_path}"'
    subprocess.Popen(perfetto_cmd, shell=True)
    time.sleep(2)

    # --- Input field and value ---
    input_field = wait.until(EC.presence_of_element_located((
        AppiumBy.CSS_SELECTOR, "#ion-input-0"
    )))
    input_field.clear()
    input_field.send_keys(str(value))
    print("🔢 Value entered.")

    # --- Start button click ---
    start_button = wait.until(EC.presence_of_element_located((
        AppiumBy.XPATH, "//ion-button[contains(., 'Start')]"
    )))
    start_button.click()
    print("🚀 Start button clicked.")

    # --- Wait for button to be re-enabled (custom check!) ---
    print("⏳ Waiting for the button to be re-enabled...")
    while True:
        is_disabled = driver.execute_script(
            "return arguments[0].hasAttribute('disabled') || arguments[0].innerText.includes('Läuft')",
            start_button
        )
        time.sleep(1)
        if not is_disabled:
            break


    print("✅ Test finished. Stopping Perfetto...")
    subprocess.run("adb shell killall perfetto", shell=True)
    time.sleep(2)

    # --- Pull trace file ---
    print("💾 Pulling trace file...")
    subprocess.run(f'adb pull {device_trace_path} "{local_trace_path}"', shell=True)
    print(f"✅ Trace saved to: {local_trace_path}")
    time.sleep(2)

# --- Done ---
driver.quit()
print("\n🎉 All tests complete!")
