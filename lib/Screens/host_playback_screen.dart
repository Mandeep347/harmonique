import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harmonique/Services/firebase_service.dart';
import 'package:harmonique/Widgets/custom_youtube_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HostPlaybackScreen extends StatefulWidget {
  const HostPlaybackScreen({super.key});

  @override
  State<HostPlaybackScreen> createState() => _HostPlaybackScreenState();
}

class _HostPlaybackScreenState extends State<HostPlaybackScreen> {
  final roomId = Uuid().v4().substring(0, 6); // 5 digit room id
  YoutubePlayerController? _controller;
  late TextEditingController _urlTextController = TextEditingController();
  late DatabaseReference dbRef;
  String? _videoId;
  double _currentPosition = 0;
  double _videoDuration = 1;
  int participantCount = 0;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref("rooms/$roomId");
    listenForPlaybackState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _urlTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    var urlTextController = TextEditingController();

    dbRef.onValue.listen((event) {
      final count = event.snapshot.value as int? ?? 0;
      setState(() {
        participantCount = count;
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Room Created : $roomId",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: screenHeight * 0.06,
                  width: screenWidth * 0.5,
                  child: TextField(
                    controller: _urlTextController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter youtube url",
                    ),
                  ),
                ),
                ElevatedButton(onPressed: loadVideo, child: Text("Go")),
                Icon(Icons.people),
                Text(": $participantCount")
              ],
            ),
            if (_controller != null)
              CustomYoutubeWidget.CustomYoutubeFrame(
                  ytheight: screenWidth * 0.566,
                  ytwidth: screenWidth,
                  controller: _controller!,
                  showVideoProgressBar: false,
                  setState: () {
                    setState(() {});
                  },
                  dbRef: dbRef
              )
          ],
        ),
      ),
    );
  }

  loadVideo() {
    final inputUrl = _urlTextController?.text.trim();
    final videoId = YoutubePlayer.convertUrlToId(inputUrl!);

    if (videoId != null) {
      FirebaseService.updateUrl(inputUrl, dbRef);

      if (_controller == null) {
        _controller = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              mute: kIsWeb ? true : false,
              hideControls: true,
              disableDragSeek: true,
              controlsVisibleAtStart: false,
              hideThumbnail: true,
            ))
          ..addListener(_onPlayerChanged);
      } else {
        _controller!.load(videoId);
      }
      FirebaseService.updatePlaybackState(
          true, _controller!.value.position, dbRef);

      setState(() {
        _videoId = videoId;
        _urlTextController.text = "";
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Youtube Url")),
      );
    }
  }

  void _onPlayerChanged() {
    if (_controller!.value.isReady && mounted) {
      final pos = _controller!.value.position.inSeconds.toDouble();
      final dur = _controller!.metadata.duration.inSeconds.toDouble();
      setState(() {
        _currentPosition = pos;
        _videoDuration = dur > 0 ? dur : 1;
      });
    }

    // Sync to Firebase
    //updatePlaybackState(isPlaying, position);
  }

  listenForPlaybackState(){
    dbRef.child("playbackState").onValue.listen((event) {
      if (_controller == null || !_controller!.value.isReady) return;

      final data = event.snapshot.value as Map?;
      if (data == null) return;

      final bool isPlaying = data["isPlaying"] ?? false;
      final double currentTime = (data["currentTime"] ?? 0).toDouble();
      final int serverTimestamp = data["lastUpdated"] ?? 0;

      final int now = DateTime.now().millisecondsSinceEpoch;
      final double delayInSeconds = ((now - serverTimestamp) / 1000);
      final double correctedTime = currentTime;
      final Duration correctedPosition = Duration(seconds: correctedTime.floor());
      final Duration currentPosition = _controller!.value.position;
      final diff = (currentPosition.inSeconds - correctedTime).abs();

      const syncThreshold = 1.0;
      // Sync if difference > 1 second
      if (diff > syncThreshold) {
        _controller!.seekTo(correctedPosition);
      }

      if (isPlaying && !_controller!.value.isPlaying) {
        _controller!.play();
      } else if (!isPlaying && _controller!.value.isPlaying) {
        _controller!.pause();
      }
    });
  }
}
