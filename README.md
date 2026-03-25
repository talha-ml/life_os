# 🚀 LifeOS - Premium Mission Control & Mood Tracker
**Student Name:** Muhammad Talha  
**Reg No:** SP23-BCS-086  
**Semester:** 7th (CS) - COMSATS

---

## 📝 Project Overview
**LifeOS** is an executive-level productivity application designed to bridge the gap between task management and mental well-being. Built using **Flutter** and **Riverpod**, it treats every task as a "Mission" and tracks the user's emotional state upon completion to provide deep productivity insights.

---

## 💎 Elite Features

### 🔐 Biometric Vault (Security)
* **Secure Access:** App is protected by a native Fingerprint/FaceID lock screen.
* **Animated UI:** Features a pulsing "Heartbeat" animation on the authentication screen for a premium feel.

### 🧠 Mental Health Integration (FYP Link)
* **Mood Check-in:** Every completed mission prompts the user to record their mood (Sad to Awesome).
* **Emotional Analytics:** Correlates productivity with mood scores to identify burnout or peak performance periods.

### 📊 Advanced Data Visualization
* **Category Distribution:** Real-time **Pie Charts** showing time spent across Study, Health, Work, and Personal sectors.
* **Volume Analysis:** **Bar Charts** visualizing task density for the week.

### 📂 Professional Data Export
* **Executive PDF Reports:** Generates a branded report with summary stats, mission status, and dev credentials.
* **Excel/CSV Export:** Raw data export for external spreadsheet analysis and record-keeping.

### 🔔 High-Precision Scheduling
* **Exact Alarms:** Uses Android’s `SCHEDULE_EXACT_ALARM` to ensure reminders trigger even in "Doze" or battery-saving modes.
* **Smart Haptics:** Physical vibration feedback on mission "Launch" and "Accomplishment."

---

## 🛠️ Technical Stack
* **State Management:** Riverpod (Industry-standard reactive state).
* **Local Database:** SQLite (`sqflite`) with relational schema and versioning.
* **Charts:** `fl_chart` for high-performance data rendering.
* **Calendar:** `table_calendar` for interactive mission planning.
* **Animations:** **Lottie** (JSON-based vector animations) and Tween Builders.

---

## 🚀 How to Run
1. **Clone/Extract** the project folder.
2. Run `flutter pub get` in the terminal.
3. Ensure your Android device/emulator has **Biometrics** (Fingerprint) enabled.
4. Run the app:
   ```bash
   flutter run --release