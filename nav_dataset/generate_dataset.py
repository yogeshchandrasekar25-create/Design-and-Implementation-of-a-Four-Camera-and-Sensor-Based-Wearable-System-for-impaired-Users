"""
Synthetic dataset generator for the Smart Navigation Assist System.

Produces:
1. YOLO-format label files (labels/*.txt) - one per synthetic frame,
   with class + bounding box, for the object detection model.
2. classes.txt - class name list (YOLO/COCO style).
3. sensor_log.csv - paired ultrasonic distance + camera position data.
4. system_output.json - the ground-truth navigation decision
   (voice message + haptic pattern) the controller should produce
   for each frame, so you can test the decision engine end-to-end.

NOTE: This generates LABELS + SENSOR DATA only, not real photographs.
Pair these labels with real images (see README.md) when you're ready
to train the actual TFLite model. Until then, this lets you fully
test your data pipeline, decision engine, and output logic.
"""

import csv
import json
import random

random.seed(42)

CLASSES = ["person", "vehicle", "animal", "cyclist", "obstacle"]
CAMERAS = ["front", "left", "right", "back"]

VOICE_MESSAGES = {
    "person": "Person on {side}",
    "vehicle": "Vehicle approaching",
    "animal": "Animal on {side}",
    "cyclist": "Cyclist on {side}",
    "obstacle": "Obstacle ahead",
    "none": "Go forward",
}

HAPTIC_MAP = {
    "left": "Left Vibration",
    "right": "Right Vibration",
    "front_close": "Both Feet Vibration",
    "clear": "No Vibration",
}

N_SAMPLES = 500

with open("classes.txt", "w") as f:
    f.write("\n".join(CLASSES) + "\n")

sensor_rows = []
system_outputs = []

for i in range(N_SAMPLES):
    frame_id = f"frame_{i:05d}"
    camera = random.choice(CAMERAS)
    has_object = random.random() < 0.7  # 70% of frames contain a detection
    label_lines = []

    if has_object:
        n_objects = random.choice([1, 1, 1, 2])  # mostly single object
        for _ in range(n_objects):
            cls_id = random.randint(0, len(CLASSES) - 1)
            cls_name = CLASSES[cls_id]
            # YOLO format: class x_center y_center width height (normalized 0-1)
            x_center = round(random.uniform(0.15, 0.85), 3)
            y_center = round(random.uniform(0.3, 0.8), 3)
            w = round(random.uniform(0.08, 0.35), 3)
            h = round(random.uniform(0.15, 0.6), 3)
            label_lines.append(f"{cls_id} {x_center} {y_center} {w} {h}")
        primary_class = CLASSES[int(label_lines[0].split()[0])]
        primary_x = float(label_lines[0].split()[1])
    else:
        primary_class = "none"
        primary_x = 0.5

    with open(f"labels/{frame_id}.txt", "w") as f:
        f.write("\n".join(label_lines))

    # Simulated ultrasonic distance (0-10 m), closer when object present
    distance_m = round(random.uniform(0.3, 3.0), 2) if has_object else round(random.uniform(3.0, 10.0), 2)

    # Determine side for voice/haptic logic
    if primary_x < 0.4:
        side = "left"
    elif primary_x > 0.6:
        side = "right"
    else:
        side = "center"

    # Decision engine logic (ground truth for testing)
    if not has_object:
        voice = VOICE_MESSAGES["none"]
        haptic = HAPTIC_MAP["clear"]
        decision = "forward"
    elif distance_m < 1.0:
        voice = "Stop"
        haptic = HAPTIC_MAP["front_close"]
        decision = "stop"
    else:
        voice = VOICE_MESSAGES[primary_class].format(side=side)
        haptic = HAPTIC_MAP.get(side, HAPTIC_MAP["clear"])
        decision = "turn_left" if side == "left" else ("turn_right" if side == "right" else "forward")

    sensor_rows.append({
        "frame_id": frame_id,
        "camera_source": camera,
        "ultrasonic_distance_m": distance_m,
        "detected_class": primary_class,
        "position": side,
    })

    system_outputs.append({
        "frame_id": frame_id,
        "camera_source": camera,
        "detected_class": primary_class,
        "distance_m": distance_m,
        "voice_output": voice,
        "haptic_feedback": haptic,
        "navigation_decision": decision,
    })

with open("sensor_log.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(sensor_rows[0].keys()))
    writer.writeheader()
    writer.writerows(sensor_rows)

with open("system_output.json", "w") as f:
    json.dump(system_outputs, f, indent=2)

print(f"Generated {N_SAMPLES} samples: labels/, sensor_log.csv, system_output.json, classes.txt")
