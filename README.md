# 💰 Expense Tracker App – Flutter

A simple yet powerful Flutter app for tracking your daily expenses. Record transactions, view summaries, and stay on top of your budget — all in a clean, user-friendly interface.

## 📱 Features

- Add, edit, and delete expense entries
- Daily and total expense summary
- Uses local storage (Hive / SharedPreferences)
- Custom date and category filtering
- Responsive design for all screen sizes

## 📁 Project Structure (example)

```
lib/
├── main.dart
├── models/
│   └── expense.dart
├── screens/
│   ├── home_screen.dart
│   └── add_expense_screen.dart
├── widgets/
│   ├── expense_list.dart
│   └── expense_tile.dart
└── utils/
    └── storage_manager.dart
```

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/your-username/expense_tracker_flutter.git
cd expense_tracker_flutter
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

Make sure you have an emulator running or a device connected.

## 🛠️ Tech Stack

- Flutter & Dart
- Local storage: Hive / SharedPreferences
- Provider or setState (for state management)
- Custom Widgets & Layouts

## 🤝 Contributing

Pull requests are welcome. Feel free to fork the repository and improve it!

## 📄 License

This project is licensed under the [MIT License](LICENSE).

## 💡 Credits

Built with ❤️ in Flutter to learn budgeting apps and local storage handling.
