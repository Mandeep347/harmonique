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
