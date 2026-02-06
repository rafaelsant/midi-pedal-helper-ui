🚀 MIDI Pedal Helper - Technical Implementation Tasks
Phase 1: Data Architecture & Drivers
Goal: Create the foundation for multi-pedal support and SysEx generation.

Task 1.1: Pedal Profile & Driver Model
Context: Define the JSON structure for pedal commands and the Dart classes to parse them.

Gemini Prompt:

"I am building a Flutter app to control guitar pedals via an ESP32-S3 (USB Host). I need to create a 'Pedal Driver' system. Please generate a Dart model called PedalProfile that can be initialized from a JSON. The JSON should include: brand, model, a map of MIDI CC/SysEx commands, and a list of parameters (gain, level, etc.) with their min/max values. Also, create a SysexGenerator utility class that takes a command template from the JSON and a value, and returns a Uint8List ready to be sent via MIDI."

Phase 2: State Management & Dynamic Scenes
Goal: Implement the logic where Scene A, B, and C hold "unsaved" changes in memory.

Task 2.1: Multi-Scene State Controller
Context: Manage temporary vs. persistent states using a state management solution (like Riverpod or Bloc).

Gemini Prompt:

"In my Flutter app, I have a 'Song' which contains three 'Scenes' (A, B, and C). I need a State Management logic where: 1. Each scene has a dynamic name and a map of pedal parameters. 2. When the user switches from Scene A to B, the changes made in A must stay in memory even if not saved to the database yet. 3. There is a global 'Save' function that persists all three scenes to local storage at once. Provide a solution using [Riverpod/Bloc/Provider] to handle this 'Draft' vs 'Persistent' state."

Phase 3: MIDI Time & Tap Tempo
Goal: Convert BPM/Tap into specific SysEx values for the Cube Baby.

Task 3.1: Tap Tempo to Milliseconds Logic
Context: Calculate BPM and convert it to the specific byte value the pedal expects.

Gemini Prompt:

"I need a Flutter service for a 'Tap Tempo' button. It should: 1. Calculate BPM based on the last 4 taps. 2. Convert that BPM into milliseconds. 3. The Cube Baby pedal expects a specific SysEx or CC value for delay time (mapping 0-127 to a time range). Create a function that maps the calculated milliseconds to the closest 0-127 MIDI value based on a provided min/max millisecond range."

Phase 4: ESP32-S3 USB Host Bridge
Goal: Make the ESP32 a transparent "Pass-through" for the MIDI data.

Task 4.1: Low-Latency BLE to USB-MIDI Bridge
Context: The ESP32-S3 receives bytes via BLE and sends them to the pedal via USB.

Gemini Prompt:

"I am using an ESP32-S3 as a USB Host. Write an Arduino/C++ sketch using the USBHost_t36 or the native ESP32-S3 USB Host library. The logic should: 1. Initialize as a MIDI USB Host to talk to a pedal. 2. Set up a BLE MIDI characteristic. 3. When a MIDI message (especially SysEx) is received via BLE, it should immediately forward the raw bytes to the USB MIDI output. Keep the buffer handling efficient to minimize latency."

Phase 5: JSON Import/Export & Persistence
Goal: Sharing and backing up data.

Task 5.1: Serializing Setlists for JSON Export
Context: Use path_provider and dart:convert to share files.

Gemini Prompt:

"Create a service in Flutter to export and import 'Setlists'. A Setlist contains multiple Songs, each with 3 Scenes. I need: 1. A function to convert the entire Setlist object into a pretty-printed JSON string. 2. A function to share this file using the share_plus package. 3. A function to 'Import' a JSON file, validate its structure, and save it to the local database."