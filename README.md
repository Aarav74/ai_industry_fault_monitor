# 🚀 IoT Dashboard App (Flutter)

A **modern, responsive IoT Dashboard** built with Flutter, providing real-time monitoring of sensor data, alerts, analytics, and emergency controls.  
This project is designed as a scalable base for **IoT, Smart Home, and Industrial Monitoring** systems.

---

## 📌 Features

- 📡 **Connection Header**  
  Displays current IP address, connection status, and auto-refresh toggle.

- 📊 **Sensor Dashboard**  
  - Real-time sensor cards with icons, values, units, and status.  
  - Trends visualization (last 7 readings).  
  - Tap to view detailed sensor info.  
  - Long-press for extended actions (history, calibration).

- 📈 **Analytics View**  
  Placeholder screen for detailed trends and advanced data visualization.

- 🔔 **Alerts View**  
  Centralized system alerts and notification settings.

- 🛑 **Emergency Stop FAB**  
  Prominent floating action button for triggering an **emergency stop** with confirmation dialog.

- 🔄 **Auto Refresh**  
  Background data refresh with configurable toggle.

---

## 🛠️ Tech Stack

- [Flutter](https://flutter.dev/) (UI framework)  
- [Dart](https://dart.dev/) (programming language)  
- [sizer](https://pub.dev/packages/sizer) (responsive sizing)  
- **Custom Widgets**:  
  - `ConnectionHeaderWidget`  
  - `SensorCardWidget`  
  - `EmergencyFabWidget`  
  - `CustomIconWidget`  

---

## 📂 Project Structure

```
lib/
├── core/
│   └── app_export.dart      # Global theme, constants, helpers
├── screens/
│   └── dashboard/
│       ├── dashboard_screen.dart
│       └── widgets/
│           ├── connection_header_widget.dart
│           ├── emergency_fab_widget.dart
│           └── sensor_card_widget.dart
```

---

## 🚀 Getting Started

### 1. Clone the repo
```bash
git clone https://github.com/your-username/iot-dashboard-flutter.git
cd iot-dashboard-flutter
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run the app
```bash
flutter run
```

---

## 📸 Screenshots (optional)
_Add screenshots of your Dashboard, Analytics, and Alerts tabs here._

---

## 📌 Roadmap

- ✅ Mock sensor data with refresh  
- ✅ Dashboard, Analytics, Alerts tabs  
- ✅ Emergency stop with confirmation  
- ⏳ Integrate backend API for real data  
- ⏳ Advanced charts for analytics  
- ⏳ Push notifications for alerts  

---

## 🤝 Contributing

Contributions are welcome!  
1. Fork the repo  
2. Create a new branch (`feature/new-feature`)  
3. Commit your changes  
4. Push and create a PR  

---

## 📜 License

This project is licensed under the **MIT License** – feel free to use and modify for your own projects.
