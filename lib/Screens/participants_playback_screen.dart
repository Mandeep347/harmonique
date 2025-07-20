import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:harmonique/Widgets/custom_youtube_widget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ParticipantsPlaybackScreen extends StatefulWidget{
  final String roomId;

  const ParticipantsPlaybackScreen({super.key, required this.roomId});

  @override
  State<ParticipantsPlaybackScreen> createState() => _ParticipantsPlaybackScreenState();
}

class _ParticipantsPlaybackScreenState extends State<ParticipantsPlaybackScreen> {
  late DatabaseReference roomRef;
  YoutubePlayerController? _controller;
  bool isVideoLoaded = false;
  double _currentPosition = 0;
  double _videoDuration = 1;

  @override
  void initState() {
    super.initState();
    roomRef = FirebaseDatabase.instance.ref('rooms/${widget.roomId}');
    roomRef.child("participantCount").runTransaction((Object? currentData) {
      final currentValue = (currentData as int?) ?? 0;
      return Transaction.success(currentValue + 1);
    });
    listenForVideoUrl();
  }

  @override
  void dispose() {
    _controller?.dispose();
    roomRef.child("participantCount").runTransaction((Object? currentData) {
      final currentValue = (currentData as int?) ?? 1;
      final newValue = (currentValue - 1).clamp(0, currentValue);
      return Transaction.success(newValue);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final String roomId = widget.roomId;

    return Scaffold(
      appBar: AppBar(
        title: Text("Joined Room : $roomId", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Center(
          child: Column(
            children: [
              isVideoLoaded ? CustomYoutubeWidget.CustomYoutubeFrame(
                  ytheight: screenWidth * 0.566,
                  ytwidth: screenWidth,
                  controller: _controller!,
                  showVideoProgressBar: false,
                  setState: () {
                    setState(() {});
                  },
                  dbRef: roomRef
              ): CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  listenForVideoUrl(){
    roomRef.child("videoUrl").onValue.listen((event) {
      final url = event.snapshot.value as String?;
      if (url != null && YoutubePlayer.convertUrlToId(url) != null) {
        final videoId = YoutubePlayer.convertUrlToId(url)!;
        print("🎥 Received videoUrl: $url");

        if(_controller == null){
          // first time init
          _controller = YoutubePlayerController(
            initialVideoId: videoId,
            flags: YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
              hideControls: true,
              disableDragSeek: true,
              controlsVisibleAtStart: false,
              hideThumbnail: true,
            ),
          )..addListener(_onPlayerChanged);

          setState(() {
            isVideoLoaded = true;
          });

          listenForPlaybackState();
        }else{
          _controller!.load(videoId);
        }
      }
    });
  }

  listenForPlaybackState(){
    roomRef.child("playbackState").onValue.listen((event) {
      if (_controller == null || !_controller!.value.isReady) return;

      final data = event.snapshot.value as Map?;
      if (data == null) return;

      final bool isPlaying = data["isPlaying"] ?? false;
      final double currentTime = (data["currentTime"] ?? 0).toDouble();
      final int serverTimestamp = data["lastUpdated"] ?? 0;

      final int now = DateTime.now().millisecondsSinceEpoch;
      final double delayInSeconds = ((now - serverTimestamp) / 1000);
      final double correctedTime = currentTime + delayInSeconds;
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

  void _onPlayerChanged() {
    if (_controller!.value.isReady && mounted) {
      final pos = _controller!.value.position.inSeconds.toDouble();
      final dur = _controller!.metadata.duration.inSeconds.toDouble();
      setState(() {
        _currentPosition = pos;
        _videoDuration = dur > 0 ? dur : 1;
      });
    }
  }

}
