# 🔗 Flutter YouTube Sync Playback App

This project is a real-time **multi-device YouTube sync player** built with **Flutter** and **Firebase Realtime Database**.

It allows a **host** to create a room, enter a YouTube video URL, and control video playback. Other **participants** can join the room and watch the same video **in perfect sync**, across multiple Android or Web devices.

---

## 📱 Features

- 🎬 Play YouTube videos on Host screen using [youtube_player_flutter](https://pub.dev/packages/youtube_player_flutter)
- 🔁 Participants join a room and automatically sync video position and playback state
- 🔄 Real-time sync of:
  - Video URL
  - Play/Pause state
  - Seek position
- ⚡ Firebase Realtime Database for fast sync and minimal latency
- 🧠 Lag compensation using timestamps and delay calculation
- 👥 Participant count shown on Host screen
- 🌐 Works on Android and Web (with autoplay limitations on Web)

---

## 🚀 Getting Started

### 1. 🔧 Prerequisites

- Flutter SDK
- Firebase account and project
- YouTube API key (if needed for other features)
- Android/iOS/Web setup

### 2. 🛠 Setup Firebase Realtime Database

## 🔥 Firebase Configuration

This project uses Firebase. The file `android/app/google-services.json` has been excluded from the repository for security reasons.

To run the project:

1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Create a Firebase project or use the existing one.
3. Register your Android app with the package name `com.mnd.harmonique`.
4. Download the `google-services.json` file.
5. Place it inside the `android/app/` directory.
6. Enable Realtime Database
7. Set rules (for development only):

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

📂 Project Structure
```
/lib
├── host_playback_screen.dart      # Host screen with video URL input and controls
├── participant_screen.dart        # Participant screen to sync and play video
├── firebase_service.dart          # Handles reading/writing from Firebase
├── sync_utils.dart                # Delay compensation and sync logic
└── main.dart                      # App entry point
```

🔑 Key Concepts
🔸 Sync via Firebase
- Host writes:
  - isPlaying
  - currentTime
  - lastUpdated (Firebase server timestamp)
  - videoUrl

- Participant reads:
  - Calculates delay using DateTime.now() and lastUpdated
  - Seeks to correct position if out of sync

🔸 Participant Count
- Each join increments a counter in:
```bash
rooms/{roomId}/participantCount
```
- On exit (dispose), the count is decremented.

🌐 Web Compatibility Notes
- Due to browser autoplay restrictions:
  - Video must be muted for autoplay to work on Web
  - Use mute: true and a "Tap to Play" button to enable manual start

📦 Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  youtube_player_flutter: ^8.0.0
  firebase_core: ^2.0.0
  firebase_database: ^10.0.0
  uuid: ^4.0.0
  http: ^0.13.5
```

📈 Future Improvements
- Auth system for host/participants
- Chat with host during watch party
- Video thumbnails for previews
- Room expiration and cleanup
- Better error handling on sync failures

🧑‍💻 Developed By
Mandeep
👨‍🎓 B.Tech CSE Student
📍 Ghaziabad, India

🌟 Give it a Star!
If this project helped you learn something or inspired your own project, feel free to ⭐ star the repo and share it!

📄 License
This project is licensed under the MIT License.
