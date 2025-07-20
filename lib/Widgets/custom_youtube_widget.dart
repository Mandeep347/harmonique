import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:harmonique/Services/firebase_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

bool _showControls = false;
Timer? _hideTimer;
bool isDragging = false;
double _currentPosition = 0;
double _videoDuration = 1;

class CustomYoutubeWidget{

  static CustomYoutubeFrame({
    required double ytheight,
    required double ytwidth,
    required YoutubePlayerController controller,
    required bool showVideoProgressBar,
    required VoidCallback setState,
    required DatabaseReference dbRef
  }){
    
    controller.addListener((){
      if(!isDragging){
        final position = controller.value.position.inSeconds.toDouble();
        final duration = controller.value.metaData.duration.inSeconds.toDouble();

        _currentPosition = position;
        _videoDuration = duration > 0 ? duration : 1;
        setState();
      }
    });

    return Stack(
      children: [
        YoutubePlayer(controller: controller,showVideoProgressIndicator: showVideoProgressBar,),
        Positioned(
          top: 0,
          left: 0,
          child: InkWell(
            onTap: (){ _toggleControls(setState: setState); },
            onDoubleTap: (){
              final current = controller.value.position;
              var newPosition = Duration(seconds: 0);
              if(current > Duration(seconds: 10)){
                final newPosition  = current - Duration(seconds: 10);
                controller.seekTo(newPosition);
              }else{
                controller.seekTo(newPosition);
              }
              FirebaseService.updatePlaybackState(true, controller.value.position, dbRef);
            },
            child: Container(
              height: ytheight * 0.85,
              width: ytwidth * 0.50,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: InkWell(
            onTap: (){ _toggleControls(setState: setState); },
            onDoubleTap: (){
              final current = controller.value.position;
              final newPosition = current + Duration(seconds: 10);
              if((_videoDuration - newPosition.inSeconds.toInt()) <= 10 ){
                controller.seekTo(controller.metadata.duration);
              }else{
                controller.seekTo(newPosition);
              }
              FirebaseService.updatePlaybackState(true, controller.value.position, dbRef);
            },
            child: Container(
              height: ytheight * 0.85,
              width: ytwidth * 0.50,
            ),
          ),
        ),
        Positioned(
          bottom: -10,
          left: 30,
          child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
            child: _showControls
            ? Column(
              children: [
                IconButton(onPressed: (){
                  FirebaseService.updatePlaybackState(controller.value.isPlaying ? false : true, controller.value.position, dbRef);
                  if(controller.value.isPlaying){
                    controller.pause();
                  }else{
                    controller.play();
                  }
                },
                    icon: Icon(
                      controller.value.isPlaying ?  Icons.pause: Icons.play_arrow,
                      color: Colors.white,
                      size: 60,
                    )
                ),
                SizedBox(height: ytheight * 0.1,),
                Container(
                  width: ytwidth * 0.83,
                  child: Slider(
                    value: _currentPosition.clamp(0, _videoDuration),
                    min: 0,
                    max: _videoDuration,
                    divisions: _videoDuration.toInt(),
                    label: formatTime(_currentPosition),
                    onChanged: (value){
                      isDragging = true;
                      _currentPosition = value;
                      setState();
                    },
                    onChangeEnd: (value){
                      controller.seekTo(Duration(seconds: value.toInt()));
                      FirebaseService.updatePlaybackState(true, controller.value.position, dbRef);
                      isDragging = false;
                      setState();
                    },
                  ),
                ),
              ],
            )
            : SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  static String formatTime(double seconds) {
    final Duration duration = Duration(seconds: seconds.toInt());
    return duration.toString().split('.').first.padLeft(8, "0");
  }

  static _toggleControls({required VoidCallback setState}){
    _showControls = true;
    setState();
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: 3), (){ _showControls = false; setState(); } );
  }
}