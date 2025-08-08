# 💸 Expense Tracker App – Flutter

A beginner-friendly Flutter app to track expenses with input fields and bar chart visualization. It’s designed for learning state management, custom widgets, and UI layout in Flutter — no database or persistent storage included (yet!).

## 📱 Features

- Add new expense items with title, amount, date, and category
- Expenses displayed in a list format
- Weekly chart to visualize spending patterns
- Custom UI components and clean layout
- No backend or local database yet (purely in-memory)

## 📁 Folder Structure

```
lib/
├── main.dart
├── models/
│   └── expense.dart
├── widgets/
│   ├── chart/
│   │   ├── chart.dart
│   │   └── chart_bar.dart
│   ├── expenses_list/
│   │   ├── expenses_list.dart
│   │   └── expense_item.dart
│   ├── new_expense.dart
│   └── expenses.dart
```

## 🚀 Getting Started

Make sure you have Flutter installed. Then:

### 1. Clone the repository

```bash
git clone https://github.com/your-username/expense_tracker_app.git
cd expense_tracker_app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

Ensure a device or emulator is connected.

## 🛠️ Tech Stack

- Flutter & Dart
- Stateless and Stateful widgets
- Custom components
- In-memory data handling (no persistent storage)

## 📄 License

This project is licensed under the [MIT License](LICENSE).

## 🙌 Credits

Built for learning Flutter UI basics and stateful widget patterns.
