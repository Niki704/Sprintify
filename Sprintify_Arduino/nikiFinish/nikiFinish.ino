#include <ESP8266WiFi.h>
#include <ESP8266Firebase.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// === WIFI SETTINGS ===
#define WIFI_SSID "Niki"
#define WIFI_PASSWORD "NikiHotspot"
#define DB_URL "https://sprint-tracker-sys-default-rtdb.asia-southeast1.firebasedatabase.app/"

// === HARDWARE PINS ===
const int SENSOR_PIN = D7;
const int ROTARY_A = D5;
const int ROTARY_B = D6;
const int ROTARY_SW = D3;

// === DISPLAY ===
LiquidCrystal_I2C screen(0x27, 16, 2);

// === SERVICES ===
Firebase fb(DB_URL);
WiFiUDP udpClient;
NTPClient rtc(udpClient, "pool.ntp.org", 19800);

// === ROTARY ===
int rotaryVal = 0;
int prevA = LOW;
float lapLength = 0.0;
bool rotaryChanged = false;

// === SESSION STATE ===
String sessionState = "";
int totalRounds = 0;
int roundNow = 1;
bool running = false;
bool sensorLatch = false;
unsigned long debounceRotary = 0;
unsigned long debounceSensor = 0;
unsigned long lastPoll = 0;

void wifiConnect() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    screen.setCursor(0, 1);
    screen.print("Connecting WiFi..");
    delay(300);
  }
}

void setupLCD() {
  Wire.begin(D2, D1);
  screen.init();
  screen.backlight();
  screen.clear();
  screen.print("Booting...");
}

void setup() {
  Serial.begin(115200);

  pinMode(ROTARY_A, INPUT);
  pinMode(ROTARY_B, INPUT);
  pinMode(ROTARY_SW, INPUT_PULLUP);
  pinMode(SENSOR_PIN, INPUT);

  setupLCD();
  wifiConnect();

  rtc.begin();
  fb.json(true);

  screen.clear();
  screen.print("Ready!");
}

void loop() {
  rtc.update();

  if (millis() - lastPoll > 500) {
    syncSession();
    lastPoll = millis();
  }

  handleRotary();

  if (running) {
    trackLaps();
  }

  delay(5);
}

void syncSession() {
  String newStatus = fb.getString("current_sprint_session/status");
  newStatus.trim();
  newStatus.replace("\"", "");

  if (newStatus != sessionState) {
    sessionState = newStatus;
    screen.clear();
    Serial.println("Session: " + sessionState);

    if (sessionState == "SETUP_COMPLETE") {
      rotaryVal = 0;
      lapLength = 0.0;
      screen.print("Set Distance");
    } else if (sessionState == "DEVICE_READY") {
      roundNow = 1;
      screen.print("Waiting Start");
    } else if (sessionState == "RACE_IN_PROGRESS") {
      running = true;
      totalRounds = fb.getInt("current_sprint_session/lapCount");
      screen.print("GO! Laps: " + String(totalRounds));
    } else if (sessionState == "RACE_COMPLETE") {
      running = false;
      screen.print("Finished");
    }
  }
}

void handleRotary() {
  int A = digitalRead(ROTARY_A);
  if (A != prevA && millis() - debounceRotary > 5) {
    if (digitalRead(ROTARY_B) != A) {
      rotaryVal--;
      lapLength -= 50.0 / 30;
    } else {
      rotaryVal++;
      lapLength += 50.0 / 30;
    }
    rotaryChanged = true;
    debounceRotary = millis();
  }
  prevA = A;

  if (rotaryChanged && sessionState == "SETUP_COMPLETE") {
    int planned = fb.getInt("current_sprint_session/distancePerLap");
    screen.setCursor(0, 1);
    screen.print("Set:" + String(lapLength) + "m Goal:" + String(planned) + "m ");
    rotaryChanged = false;
  }
}

void trackLaps() {
  if (roundNow > totalRounds) {
    running = false;
    return;
  }

  int sensorVal = digitalRead(SENSOR_PIN);
  if (sensorVal == LOW && !sensorLatch && millis() - debounceSensor > 1000) {
    sensorLatch = true;
    debounceSensor = millis();

    unsigned long now = rtc.getEpochTime();

    // Write endTime for this lap
    String endPath = "current_sprint_session/laps/" + String(roundNow) + "/endTime";
    bool ok = fb.setInt(endPath, now);

    if (ok) {
      Serial.println("Lap " + String(roundNow) + " End: " + String(now));
    } else {
      Serial.println("Failed to save endTime");
    }

    // Optional: read startTime if needed
    String startPath = "current_sprint_session/laps/" + String(roundNow) + "/startTime";
    int started = fb.getInt(startPath);
    if (started == 0) {
      // First time crossing? Save startTime.
      fb.setInt(startPath, now);
      Serial.println("StartTime set for Lap " + String(roundNow));
    }

    screen.clear();
    screen.print("Lap " + String(roundNow));
    screen.setCursor(0, 1);
    screen.print("End: " + String(now));

    roundNow++;
  } else if (sensorVal == HIGH) {
    sensorLatch = false;
  }
}
