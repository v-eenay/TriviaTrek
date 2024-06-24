# Quiz App Documentation (Frontend)

## Project Overview

### Introduction
The Quiz App is a Flutter-based mobile application designed to offer an engaging and interactive platform for users to take quizzes on various topics. The front-end is developed using Flutter, ensuring a smooth and responsive user experience.

### Features
- User Authentication
- Multiple Choice Questions
- Timed Quizzes
- Leaderboards
- Real-time Results
- User Profiles

## Project Structure

### Frontend (Flutter)
- **Language**: Dart
- **Framework**: Flutter
- **Dependencies**:
  - `flutter_bloc`
  - `http`
  - `provider`
  - `shared_preferences`
  - `flutter_secure_storage`

## Setup and Run

### Prerequisites
- **Flutter SDK**: [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK**: Comes with Flutter

### Frontend Setup

1. **Clone the Repository**
    ```bash
    git clone <repository-url>
    cd quiz_app_flutter
    ```

2. **Install Dependencies**
    ```bash
    flutter pub get
    ```

3. **Run the App**
    ```bash
    flutter run
    ```

## Connecting to Backend

1. **Update Backend URL in Flutter**
    - Open `lib/config/constants.dart`
    - Update `BASE_URL` with your backend server URL

2. **Test the Connection**
    - Ensure both frontend and backend are running
    - Interact with the app to ensure it fetches data from the backend

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements
- Flutter documentation
- Community forums and tutorials

---
This documentation provides an overview of the project, instructions on how to set it up and run it. For any further questions or issues, please refer to the project's issue tracker or contact the maintainers.
