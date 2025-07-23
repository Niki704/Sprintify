#include <ESP8266WiFi.h>
#include <ESP8266Firebase.h>
#include <NTPClient.h>
#include <WiFiUdp.h>

#define WIFI_SSID "Niki"
#define WIFI_PASSWORD "NikiHotspot"
#define DB_URL "https://sprint-tracker-sys-default-rtdb.asia-southeast1.firebasedatabase.app/"

// IR sensor pin configuration
const int IR_PIN = D7;

Firebase fb(DB_URL);
WiFiUDP udp;
NTPClient ntp(udp, "pool.ntp.org", 19800); // GMT+5:30

// Internal state
String activeRaceId = "";
String raceState = "";
unsigned long lapStartMs = 0;
int totalLaps = 0;
int lapIndex = 0;
bool isRacing = false;
bool irLock = false;

unsigned long epochBase = 0;
unsigned long baseMillis = 0;

void setup() {
  Serial.begin(115200);

  pinMode(IR_PIN, INPUT); // Or INPUT_PULLUP if needed

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(400);
  }
  Serial.println("\nWiFi Ready.");

  ntp.begin();

  Serial.print("Syncing time");
  bool timeSynced = false;
  while (!timeSynced) {
    timeSynced = ntp.update();
    Serial.print(".");
    delay(500);
  }
  Serial.println("\nNTP time synced!");
  Serial.print("Epoch: ");
  Serial.println(ntp.getEpochTime());

  // Store base epoch + local millis
  epochBase = ntp.getEpochTime();
  baseMillis = millis();
  Serial.println("Epoch base: " + String(epochBase));

  fb.json(true);

  Serial.println("IR sensor ready. Obstruct to test:");
  for (int i = 0; i < 8; i++) {
    Serial.println("Sensor: " + String(digitalRead(IR_PIN)));
    delay(400);
  }
}

void loop() {
  ntp.update();

  String raceId = fb.getString("current_sprint_session/status");
  if (raceId != activeRaceId) {
    activeRaceId = raceId;
    Serial.println("New Race ID: " + activeRaceId);
  }

  String fetchedState = fb.getString("current_sprint_session/status");
  fetchedState.trim();
  fetchedState.replace("\"", "");

  if (fetchedState != raceState) {
    raceState = fetchedState;
    Serial.println("Race State: " + raceState);

    if (raceState == "RACE_IN_PROGRESS") {
      isRacing = true;
      lapIndex = 1;
      totalLaps = fb.getInt("current_sprint_session/lapCount");
      Serial.println("Laps to run: " + String(totalLaps));
    } else if (raceState == "DEVICE_READY") {
      isRacing = false;
    }
  }

  if (isRacing && lapIndex <= totalLaps) {
    int irStatus = digitalRead(IR_PIN);
    static unsigned long lastOut = 0;

    if (millis() - lastOut > 800) {
      Serial.println("IR State: " + String(irStatus));
      lastOut = millis();
    }

    // Use LOW for INPUT_PULLUP
    if (irStatus == LOW && !irLock) {
      irLock = true;

      // ✅ Proper true milliseconds
      lapStartMs = (epochBase * 1000UL) + (millis() - baseMillis);

      String node = "current_sprint_session/laps/" + String(lapIndex) + "/startTime";

      if (fb.setInt(node, lapStartMs)) {
        Serial.println("Lap " + String(lapIndex) + " -> startTime: " + String(lapStartMs));
      } else {
        Serial.println("Firebase write failed.");
      }

      lapIndex++;
      if (lapIndex > totalLaps) {
        isRacing = false;
        Serial.println("All laps triggered.");
      }
    } else if (irStatus == HIGH) {
      irLock = false;
    }
  }

  delay(40);
}
