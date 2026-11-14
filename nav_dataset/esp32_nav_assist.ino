/*
  Smart Navigation Assist — ESP32 firmware (Phase 1: serial test build)
  Reads HC-SR04 ultrasonic distance, drives left/right haptic motors,
  and streams CSV lines over Serial so MATLAB (or the phone app) can
  read live data: distance_m,decision,haptic

  Wiring:
    HC-SR04  TRIG -> GPIO 5
    HC-SR04  ECHO -> GPIO 18
    Left motor driver  -> GPIO 12
    Right motor driver -> GPIO 13
*/

const int TRIG_PIN = 5;
const int ECHO_PIN = 18;
const int LEFT_MOTOR = 12;
const int RIGHT_MOTOR = 13;

void setup() {
  Serial.begin(115200);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  pinMode(LEFT_MOTOR, OUTPUT);
  pinMode(RIGHT_MOTOR, OUTPUT);
}

float readDistanceCM() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH, 30000); // 30ms timeout ~ 5m max
  if (duration == 0) return -1; // no echo / out of range
  return duration * 0.0343 / 2.0; // speed of sound in cm/us
}

void loop() {
  float distCM = readDistanceCM();
  float distM = (distCM < 0) ? 10.0 : distCM / 100.0;

  // Simple placeholder decision logic (the phone/AI decides the
  // object class + side in the full system; this is just distance-based
  // for hardware bring-up testing).
  String decision;
  bool leftOn = false, rightOn = false;

  if (distM < 1.0) {
    decision = "stop";
    leftOn = true;
    rightOn = true;
  } else if (distM < 2.5) {
    decision = "caution";
    leftOn = true;
    rightOn = false;
  } else {
    decision = "forward";
  }

  digitalWrite(LEFT_MOTOR, leftOn ? HIGH : LOW);
  digitalWrite(RIGHT_MOTOR, rightOn ? HIGH : LOW);

  // Stream as CSV: distance_m,decision,haptic
  String haptic = (leftOn && rightOn) ? "both" : (leftOn ? "left" : (rightOn ? "right" : "none"));
  Serial.print(distM, 2);
  Serial.print(",");
  Serial.print(decision);
  Serial.print(",");
  Serial.println(haptic);

  delay(200); // ~5 readings/sec
}
