# Face Recording App

This application is designed to support a master's thesis by recording participants' facial expressions while they complete specific tasks. The app is available on both mobile and web platforms.

## How it Works

Participants will be presented with a configuration screen where they can enter their participant ID and select one of two tasks. Once configured, the app will start recording their face using the front camera while they perform the chosen task. The recorded videos are then saved and can be accessed later.

## Platforms

*   **Mobile**: iOS
*   **Web**: Accessible via a web browser

## Getting Started

### Prerequisites

*   Flutter SDK installed (version as specified in `pubspec.yaml`)
*   Android Studio / Xcode for mobile development
*   A web browser for web development

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/your-username/facerecording.git
    cd facerecording
    ```
2.  Get Flutter dependencies:
    ```bash
    flutter pub get
    ```
    
3. Ensure your development environment is set up:
    ```bash
    flutter doctor
    ```

### Running the App

#### Mobile (Android/iOS)

1.  Connect your device or start an emulator.
2.  Run the app:
    ```bash
    flutter run
    ```

#### Web

1.  Run the app for web:
    ```bash
    flutter run -d chrome
    ```
