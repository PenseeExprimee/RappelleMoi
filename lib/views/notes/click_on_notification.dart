import 'package:flutter/material.dart';
import 'package:rappellemoi/constants/routes.dart';
import 'package:rappellemoi/services/cloud/cloud_firebase_storage.dart';
import 'dart:convert';
import 'package:rappellemoi/main.dart';


//This class defines the page that will be displayed  when the user clicks on the notification.

class ClickOnNotificationView extends StatefulWidget {
  const ClickOnNotificationView({super.key});

  @override
  State<ClickOnNotificationView> createState() => _ClickOnNotificationViewState();
}

class _ClickOnNotificationViewState extends State<ClickOnNotificationView> {

  late final FirebaseCloudStorage _notesService;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final note = (ModalRoute.of(context)!.settings.arguments).toString();
    final Map<String, dynamic> data = jsonDecode(note);
    final String? body = data['body'];
    final String? noteId = data['note_id'];
    final screenWidth = MediaQuery.of(context).size.width;
    
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("C'est l'heure!!! :D"),
        
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox( height: 70,),
            Container(
            height: 75.0,
            width: 75.0,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:  AssetImage('assets/images/cute.jpg'),
                fit: BoxFit.contain
              )
            ),
          ),
          const SizedBox(height: 20,),
            SizedBox(
              width: screenWidth * 0.9 ,
              child: Container(
                padding: const EdgeInsets.all(8.0), // Padding inside the orange box
                decoration: BoxDecoration(
                  color: Colors.blue[200], // Orange background for the box
                  borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
                ),
                child: Center(
                  child: Text(
                    body!,
                    style: const TextStyle(
                      color: Colors.white, // Text color to contrast with the orange background
                      fontSize: 16, // Adjust size as needed
                      fontWeight: FontWeight.bold, // Optional: Make text bold
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox( height: 30,),
             Row(children: [
                  const SizedBox(width: 30,),
                  Container(
                    padding: const EdgeInsets.all(8.0), // Padding inside the orange box
                    child:  ElevatedButton(
                        onPressed: () {
                          
                          //Delete the actual note
                           _notesService.deleteNote(noteId: noteId);

                           //Go to the page to update the note
                           navigatorKey.currentState?.pushReplacementNamed(
                            createOrUpdateNotes,
                            arguments: body,
                      );
                          
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[300], // Text color
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Button padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                          ),
                        ),
                        child: const Text("Re-programmer",
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                      )
                  ),
                  const SizedBox(width: 90,),
                  Container(
                    padding: const EdgeInsets.all(8.0), // Padding inside the orange box
                    
                    child: ElevatedButton(
                        onPressed: () {
                          // Button action
                          _notesService.deleteNote(noteId: noteId);
                          navigatorKey.currentState?.pop();

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[100], // Text color
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Button padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                          ),
                        ),
                        child: const Text("C'est fait!",
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                      )


                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}