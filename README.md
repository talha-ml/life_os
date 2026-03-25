# 🚀 LifeOS - Premium Mission Control & Mood Tracker

**Student Name:** Muhammad Talha
**Reg No:** SP23-BCS-086
**Semester:** 7th (CS) - COMSATS
**Course:** Mobile Application Development
**Instructor:** Muhammad Abrar Saddique

---

## 📝 Project Overview
**LifeOS** is an executive-level productivity and task management application designed to bridge the gap between daily task execution and mental well-being. Built using **Flutter** and **SQLite**, it treats every task as a "Mission" and tracks the user's emotional state upon completion to provide deep productivity insights.

---

## 💎 Elite Features & Core Functionality

### 🔐 Biometric Vault (Security)
* **Secure Access:** App is protected by a native Fingerprint/FaceID lock screen.
* **Animated UI:** Features a pulsing "Heartbeat" animation on the authentication screen for a premium feel.

### 🧠 Mental Health Integration (FYP Link)
* **Mood Check-in:** Every completed mission prompts the user to record their mood (Sad to Awesome).
* **Emotional Analytics:** Correlates productivity with mood scores to identify burnout or peak performance periods.

### 🔁 Intelligent Automation & UI Customization
* **Smart Repeat Rules:** Automate recurring missions with Daily and Weekly repeat configurations, fulfilling advanced task management criteria.
* **Dynamic Theming:** Seamless one-tap switching between Premium Dark Mode and Light Mode for optimal user comfort.

### 🎯 Real-Time Progress Tracking
* **Efficiency Dashboard:** Features an animated Circular Progress Indicator that tracks daily mission completion rates in real-time, giving instant productivity feedback.

### 📊 Advanced Data Visualization
* **Category Distribution:** Real-time **Pie Charts** showing time spent across Study, Health, Work, and Personal sectors.
* **Volume Analysis:** **Bar Charts** visualizing task density for the week.

### 📂 Professional Data Export
* **Executive PDF Reports:** Generates a branded report with summary stats and mission status.
* **Excel/CSV Export:** Raw data export for external spreadsheet analysis and record-keeping.

### 🔔 High-Precision Scheduling
* **Exact Alarms:** Uses robust local notifications to ensure reminders trigger for upcoming tasks based on their due dates and times.
* **Smart Haptics:** Physical vibration feedback on mission "Launch" and "Accomplishment."
* **Task Management Lifecycle:** Full support for adding, editing, deleting, and marking tasks as completed.

---

## 🛠️ Technical Stack
* **Framework:** Flutter (Dart)
* **State Management:** Riverpod (Industry-standard reactive state).
* **Local Database:** SQLite (`sqflite`) with relational schema and versioning.
* **Charts:** `fl_chart` & `percent_indicator` for high-performance data rendering.
* **Core Utilities:** `flutter_local_notifications`, `local_auth`, `pdf`, `csv`.

---

## 🚀 How to Run
1. **Clone/Extract** the project folder.
2. Run `flutter pub get` in the terminal to fetch all dependencies.
3. Ensure your Android device/emulator has **Biometrics** (Fingerprint) enabled for the security screen.
4. Run the application:
   ```bash
   flutter run --release
