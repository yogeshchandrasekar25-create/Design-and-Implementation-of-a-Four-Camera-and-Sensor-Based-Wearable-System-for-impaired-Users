# Smart Navigation Assist System — Dataset

Synthetic multimodal dataset for testing your full pipeline (camera → AI
detection → ultrasonic distance → decision engine → voice/haptic output).

## Contents
- `classes.txt` — 3 detection classes: `person`, `vehicle`, `obstacle`
- `labels/frame_XXXXX.txt` — YOLO-format bounding box labels
  (`class_id x_center y_center width height`, normalized 0–1)
- `sensor_log.csv` — 500 rows pairing each frame with camera source
  (front/left/right/back) and simulated ultrasonic distance (0–10 m)
- `system_output.json` — ground-truth voice message, haptic pattern,
  and navigation decision (stop/forward/turn_left/turn_right) your
  controller should output for each frame
- `generate_dataset.py` — the generator script (edit `N_SAMPLES`,
  class list, or probability weights to regenerate more/different data)

## Important: no real images included
This gives you labels + sensor data to test your decision logic and
data pipeline end-to-end, but not actual photos. To train the real
TFLite object detector, pair these label formats with real image
sources such as:
- **COCO** (person, car classes) — cocodataset.org
- **INRIA Person Dataset** — pedestrian detection
- **KITTI / BDD100K** — vehicles and street obstacles from a
  ego-centric camera view, closer to your use case

You can re-run `generate_dataset.py` after collecting your own photos
from the 4 cameras to auto-generate matching label stubs, then
correct the bounding boxes with a tool like LabelImg or CVAT.

## Using the data
- For model training: point a YOLO training config at `labels/` and
  your matched `images/` folder, using `classes.txt` as the class map.
- For system testing: iterate over `system_output.json` to feed
  expected inputs into your ESP32/controller logic and check it
  produces the matching voice + haptic output.
