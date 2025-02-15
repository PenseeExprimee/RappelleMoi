import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rappellemoi/constants/routes.dart';
import 'package:rappellemoi/enums/menu_action.dart';
import 'package:rappellemoi/services/auth/auth_exceptions.dart';
import 'package:rappellemoi/services/auth/auth_service.dart';
import 'package:rappellemoi/services/bloc/auth_bloc.dart';
import 'package:rappellemoi/services/bloc/auth_event.dart';
import 'package:rappellemoi/services/bloc/auth_state.dart';
import 'package:rappellemoi/services/cloud/cloud_firebase_storage.dart';
import 'dart:developer' as devtools show log;

import 'package:rappellemoi/services/cloud/cloud_note.dart';
import 'package:rappellemoi/services/crud/notification.dart';
import 'package:rappellemoi/utilities/dialogs/choice_dialog.dart';
import 'package:rappellemoi/utilities/dialogs/error_dialog.dart';
import 'package:rappellemoi/utilities/dialogs/field_dialog_test.dart';
import 'package:rappellemoi/views/notes/list_notes_view.dart';


//This class defines the notes that will be defined on the note page.
class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  //declaration of the notes services
  late final FirebaseCloudStorage _notesService;
  late final LocalNotesService _localNotesService;

  @override
  void initState() {
    //initialize our service
    _notesService = FirebaseCloudStorage();
    _localNotesService = LocalNotesService();
    super.initState();
  }

  //define a getter for the id of the current user
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if(state is AuthStateLoggedIn){
          if(state.exception is InvalidCredentialsAuthException){
            await showErrorDialog(context,"Entrer des credentials valides.");
          }
          else if (state.exception is CouldNotDeleteTheAccountException){
            await showErrorDialog(context,"Il y a eu une erreur lors de la suppression de votre compte.");
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(createOrUpdateNotes);
                  },
                  icon: const Icon(Icons.add)),
              PopupMenuButton<MenuAction>(
                itemBuilder: (context) {
                  return [const PopupMenuItem<MenuAction>(
                      value: MenuAction.viewProfile,
                      child: Row(
                        children: [
                          Icon(Icons.people_rounded),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Voir mon profil')
                        ],
                      ),
                    ),
                    const PopupMenuItem<MenuAction>(
                      value: MenuAction.logout,
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Déconnexion')
                        ],
                      ),
                    ),
                    const PopupMenuItem<MenuAction>(
                      value: MenuAction.deleteAccount,
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Supprimer mon compte')
                        ],
                      ),
                    ),
                  ];
                },
                onSelected: (action) async {
                  switch (action) {
                    case MenuAction.viewProfile:
                      devtools.log("The user wants to see his profile");
                      Navigator.of(context).pushNamed(viewMyProfile);
                    case MenuAction.logout:
                      //send an event to the bloc to logout
                      devtools.log('Button logout pressed');
                      context.read<AuthBloc>().add(const AuthEventLoggedout());
                    case MenuAction.deleteAccount:
                      devtools.log('Button delete account pressed');
                      //Confirmation pop up
                      final choiceConfirmed = await choiceDialog(context,
                          "Supprimer votre compte supprimera toutes les notes associées. Voulez vous vraiment supprimer votre compte?");
                      devtools
                          .log("value of choice confirmed: $choiceConfirmed");
                      if (choiceConfirmed == true) {
                        devtools.log('choice confirmed and true');
                        //reauthenticate the user
                        final Map<String, String>? value =
                            await showFieldDialog(context, "Initial value of the dict");

                        if (value != null) {
                          context.read<AuthBloc>().add(
                              AuthEventDeleteMyAccount(credentials: value));
                        }
                       
                      }
                    default:
                      devtools.log(
                          "Something happened when trying to logout from the notification page");
                  }
                },
              )
            ],
            title: const Text('Crée ta notification!'),
          ),
          body: StreamBuilder(
            stream: _notesService.allNotes(
                ownerUserId:
                    userId), //the stream we are going to be subscribed to (stream of Coud Notes for a specific user)
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  //if the snaphot contains data, we return the a ListTile (to display the note to the user)
                  if (snapshot.hasData) {
                    //grab the notes
                    final allNotes = snapshot.data as Iterable<CloudNote>;
                    return NotesListView(
                        notes: allNotes,
                        onTap: (note) {
                          Navigator.of(context).pushNamed(
                            createOrUpdateNotes,
                            arguments: note,
                          );
                        },
                        onDelete: (note) {
                          devtools.log("Delete a note");
                          _notesService.deleteNote(noteId: note.noteId);
                          _localNotesService.deleteNote(cloudNoteid: note.noteId);
                          _localNotesService.deleteNotification(id: note.noteId);
                          _localNotesService.getAllNotes();
                        });
                  } else {
                    return const CircularProgressIndicator();
                  }
                default:
                  devtools.log("Notes view error...");
                  return const CircularProgressIndicator();
              }
            },
          )),
    );
  }
}
