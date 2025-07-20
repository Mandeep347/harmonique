import 'package:flutter/material.dart';
import 'package:harmonique/Screens/host_playback_screen.dart';
import 'package:harmonique/Screens/participants_playback_screen.dart';
import 'package:harmonique/Services/firebase_service.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  TextEditingController roomCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => HostPlaybackScreen()));
            }, child: Text("Create Room")),

            SizedBox(height: 20,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                Container(
                  height: 50,
                  width: 200,
                  child: TextField(
                    controller: roomCodeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Enter room code",
                    ),
                  ),
                ),

                ElevatedButton(onPressed: () async {
                  if( await FirebaseService.checkIfRoomExist(roomId: roomCodeController.text)){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ParticipantsPlaybackScreen(roomId: roomCodeController.text,)));
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Room don't exist, find correct or create new room")),
                    );
                    roomCodeController.text = "";
                  }
                }, child: Text("Join room")),

              ],
            ),

          ],
        ),
      ),
    );
  }
}