# Banka

A personal finance management mobile application developed with Flutter.

## Features

- 📊 Track expenses and income
- 💰 Transaction management with categorization
- 📈 Statistics and data visualization
- 💾 Local storage with SQLite
- 📱 Intuitive and responsive user interface

## Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 2.17.0 or higher)
- Android Studio / VS Code
- Git

## Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## Build the apk

1. Run `flutter build apk` to build the apk
2. Find the apk in the `build/app/outputs/flutter-apk/` directory

## Database

The application uses SQLite for local data storage. Transactions are stored with the following information:
- Amount
- Type (Expense/Income)
- Category
- Date
- Description

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
