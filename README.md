# 🚀 LifeOS - Premium Mission Control & Mood Tracker

[cite_start]**Student Name:** Muhammad Talha 
[cite_start]**Reg No:** SP23-BCS-086 
**Semester:** 7th (CS) - COMSATS
[cite_start]**Course:** Mobile Application Development [cite: 4]
[cite_start]**Instructor:** Muhammad Abrar Saddique [cite: 5]

---

## 📝 Project Overview
[cite_start]**LifeOS** is an executive-level productivity and task management application [cite: 9] designed to bridge the gap between daily task execution and mental well-being. [cite_start]Built using **Flutter** and **SQLite**[cite: 9], it treats every task as a "Mission" and tracks the user's emotional state upon completion to provide deep productivity insights.

---

## 💎 Elite Features & Core Functionality

### 🔐 Biometric Vault (Security)
* **Secure Access:** App is protected by a native Fingerprint/FaceID lock screen.
* **Animated UI:** Features a pulsing "Heartbeat" animation on the authentication screen for a premium feel.

### 🧠 Mental Health Integration (FYP Link)
* **Mood Check-in:** Every completed mission prompts the user to record their mood (Sad to Awesome).
* **Emotional Analytics:** Correlates productivity with mood scores to identify burnout or peak performance periods.

### 🔁 Intelligent Automation & UI Customization
* [cite_start]**Smart Repeat Rules:** Automate recurring missions with Daily and Weekly repeat configurations[cite: 34], fulfilling advanced task management criteria.
* [cite_start]**Dynamic Theming:** Seamless one-tap switching between Premium Dark Mode and Light Mode [cite: 29, 30] for optimal user comfort.

### 🎯 Real-Time Progress Tracking
* [cite_start]**Efficiency Dashboard:** Features an animated Circular Progress Indicator that tracks daily mission completion rates in real-time[cite: 32], giving instant productivity feedback.

### 📊 Advanced Data Visualization
* **Category Distribution:** Real-time **Pie Charts** showing time spent across Study, Health, Work, and Personal sectors.
* **Volume Analysis:** **Bar Charts** visualizing task density for the week.

### 📂 Professional Data Export
* [cite_start]**Executive PDF Reports:** Generates a branded report with summary stats and mission status[cite: 33].
* [cite_start]**Excel/CSV Export:** Raw data export for external spreadsheet analysis and record-keeping[cite: 33].

### 🔔 High-Precision Scheduling
* [cite_start]**Exact Alarms:** Uses robust local notifications [cite: 36] [cite_start]to ensure reminders trigger for upcoming tasks based on their due dates and times[cite: 36].
* **Smart Haptics:** Physical vibration feedback on mission "Launch" and "Accomplishment."
* [cite_start]**Task Management Lifecycle:** Full support for adding, editing, deleting, and marking tasks as completed[cite: 24, 25, 26, 27].

---

## 🛠️ Technical Stack
* [cite_start]**Framework:** Flutter (Dart) [cite: 42]
* **State Management:** Riverpod (Industry-standard reactive state).
* [cite_start]**Local Database:** SQLite (`sqflite`) with relational schema and versioning[cite: 43].
* **Charts:** `fl_chart` & `percent_indicator` for high-performance data rendering.
* [cite_start]**Core Utilities:** `flutter_local_notifications`, `local_auth`, `pdf`, `csv`[cite: 44].

---

## 🚀 How to Run
1. **Clone/Extract** the project folder.
2. Run `flutter pub get` in the terminal to fetch all dependencies.
3. Ensure your Android device/emulator has **Biometrics** (Fingerprint) enabled for the security screen.
4. Run the application:
   ```bash
   flutter run --release
