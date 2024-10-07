# Chatify

Chatify is a chat application built using Flutter, Firebase Authentication, and Firestore Database. It allows users to send messages in real-time, block/unblock other users, and report chat issues, providing a comprehensive and secure messaging experience.

## Features

- **User Authentication**: Sign up and log in using Firebase Authentication.
- **Real-time Messaging**: Send and receive messages instantly using Firestore.
- **Block/Unblock Users**: Block users to prevent them from contacting you and unblock them when needed.
- **Chat Reporting**: Report chats for inappropriate content or behavior.

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase account
- An existing Firebase project with Firestore and Firebase Authentication enabled

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/raafihilmi/chatify_client.git
   cd chatify_client
2. Install dependencies:

   ```bash
   flutter pub get

3. Set up Firebase:
    - Create a Firebase project in the Firebase Console.
    - Enable Firestore Database and Firebase Authentication 
    - Add your Flutter app to the Firebase project.
    - Download the google-services.json file and place it in the android/app directory.
    - Configure Firebase in your Flutter app.
4. Run the application:
   ```bash
     flutter run
