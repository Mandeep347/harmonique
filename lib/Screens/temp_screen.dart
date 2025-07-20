import 'package:flutter/material.dart';
import 'package:harmonique/Widgets/custom_youtube_widget.dart';

class TempScreen extends StatefulWidget{
  const TempScreen({super.key});

  @override
  State<TempScreen> createState() => _TempScreenState();
}

class _TempScreenState extends State<TempScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("data"),
          ],
        ),
      ),
    );
  }
}