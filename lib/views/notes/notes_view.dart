import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rappellemoi/constants/routes.dart';
import 'package:rappellemoi/enums/menu_action.dart';
import 'package:rappellemoi/services/auth/auth_service.dart';
import 'package:rappellemoi/services/bloc/auth_bloc.dart';
import 'package:rappellemoi/services/bloc/auth_event.dart';
import 'package:rappellemoi/services/cloud/cloud_firebase_storage.dart';
import 'dart:developer' as devtools show log;

import 'package:rappellemoi/services/cloud/cloud_note.dart';
import 'package:rappellemoi/utilities/dialogs/choice_dialog.dart';
import 'package:rappellemoi/utilities/dialogs/field_dialog.dart';
import 'package:rappellemoi/utilities/dialogs/field_dialog_test.dart';
import 'package:rappellemoi/views/notes/list_notes_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  
  //declaration of the notes services
  late final FirebaseCloudStorage _notesService;

  @override
  void initState() {
    //initialize our service
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  //define a getter for the id of the current user
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed:(){
              Navigator.of(context).pushNamed(createOrUpdateNotes);
            },
            icon: const Icon(Icons.add)
          ),
          PopupMenuButton<MenuAction>(
            itemBuilder:(context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Row(children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10,),
                    Text('Logout')
                    ],),
                  ),
                  const PopupMenuItem<MenuAction>(
                  value: MenuAction.deleteAccount,
                  child: Row(children: [
                    Icon(Icons.delete),
                    SizedBox(width: 10,),
                    Text('Delete my account')
                    ],),
                  ),
                  
              ];
            },
            onSelected: (action) async{
              switch (action) {
                case MenuAction.logout:
                  //send an event to the bloc to logout
                  devtools.log('Button logout pressed');
                  context.read<AuthBloc>().add(const AuthEventLoggedout());
                case MenuAction.deleteAccount:
                  devtools.log('Button delete account pressed');
                  //Confirmation pop up
                  final choiceConfirmed = await choiceDialog(context, "Supprimer votre compte supprimera toutes les notes associées. Voulez vous vraiment supprimer votre compte?");
                   devtools.log("value of choice confirmed: $choiceConfirmed"); 
                  if(choiceConfirmed == true){
                    devtools.log('choice confirmed and true');
                    //reauthenticate the user
                    final Map<String, String>?value = await showFieldDialog(context, "Je sais pas");
                    
                    if(value !=null){
                    context.read<AuthBloc>().add(AuthEventDeleteMyAccount(credentials: value));
                    }
                    //get all notes and delete them
                    // final allNotes = await _notesService.getNotes(ownerUserId: userId);
                    // allNotes.forEach((note){
                    //   devtools.log("These are the notes: ${note.noteId}");
                    //   //call delete note
                    //   _notesService.deleteNote(noteId: note.noteId);
                    // });
                  }
                default:
                  devtools.log("Something happened when trying to logout from the notification page");
              }
            },
          )
        ],
        title: const Text('Ta liste de future notifications'),
      ),

      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId), //the stream we are going to be subscribed to (stream of Coud Notes for a specific user) 
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.waiting:
            case ConnectionState.active:
              //if the snaphot contains data, we return the a ListTile (to display the note to the user)
              if(snapshot.hasData){
                //grab the notes
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes:allNotes,
                  onTap: (note){
                    Navigator.of(context).pushNamed(
                      createOrUpdateNotes,
                      arguments: note,
                      );
                    
                  }, 
                  onDelete: (note){
                    devtools.log("Delete a note");
                    _notesService.deleteNote(noteId: note.noteId);
                  }
                );
              }
              else{
                return const CircularProgressIndicator();
              }
            default:
              devtools.log("I don't know what is going on, please wait...");
              return const CircularProgressIndicator();
          }
        },
    ));
  }
}