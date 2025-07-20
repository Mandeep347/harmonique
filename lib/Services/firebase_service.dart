import 'package:firebase_database/firebase_database.dart';

class FirebaseService{

  static updatePlaybackState(bool isPlaying, Duration position, DatabaseReference dbRef) {
    dbRef.child("playbackState").set({
      "isPlaying": isPlaying,
      "currentTime": position.inMilliseconds / 1000,
      "lastUpdated": ServerValue.timestamp,
    });
    print("Playback state updated");
  }

  static updateUrl(String inputUrl, DatabaseReference dbRef){
    dbRef.child("videoUrl").set(inputUrl);
  }

  static checkIfRoomExist({required String roomId}) async {
    final DatabaseReference tempDbRef = FirebaseDatabase.instance.ref("rooms/$roomId");
    final snapShot = await tempDbRef.get();
    return snapShot.exists;
  }
}