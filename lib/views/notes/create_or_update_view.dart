import 'package:flutter/material.dart';
import 'package:rappellemoi/generics/get_arguments.dart';
import 'package:rappellemoi/services/auth/auth_service.dart';
import 'package:rappellemoi/services/cloud/cloud_firebase_storage.dart';
import 'package:rappellemoi/services/cloud/cloud_note.dart';
import 'dart:developer' as devtools show log;

class CreateOrUpdateNotesView extends StatefulWidget {
  const CreateOrUpdateNotesView({super.key});

  @override
  State<CreateOrUpdateNotesView> createState() => _CreateOrUpdateNotesViewState();
}

class _CreateOrUpdateNotesViewState extends State<CreateOrUpdateNotesView> {

  CloudNote? _note;
  late final TextEditingController _textController;
  late final FirebaseCloudStorage _notesService;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage(); //always the same because we created a singleton
    _textController = TextEditingController();
    super.initState();
  }

  Future <CloudNote> createOrGetExistingNote(BuildContext context) async {

    //Grab an existing note if there is one
    final existingNote = context.getArgument<CloudNote>();
    devtools.log('this is the existing note $existingNote');
    if (existingNote != null){
      devtools.log("there is an existing note");
      _note = existingNote;
      _textController.text = existingNote.text;
      return existingNote;
    }

    //in case there is no note in the current stack, check of there is something in note
    final actualNote = _note;
    if(actualNote != null){
      return actualNote;
    }

    //Get the id of the currentUser before calling createNewNote
    final currentUser = AuthService.firebase().currentUser!;
    final currentId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: currentId);
    _note = newNote;
    return newNote;
  }

  void deleteNoteIfTextIsEmpty(){
    final currentNote = _note;

    if(currentNote != null && _textController.text.isEmpty){ //the user clicked to add a note but did not enter anything in the text field
      _notesService.deleteNote(noteId: currentNote.noteId);
    }
  }

  void saveNoteIfTextNotEmpty() async {
    final currentNote = _note;
    if(currentNote !=null && _textController.text.isNotEmpty){
      devtools.log('Save my note please :D');
      await _notesService.updateNote(
        noteId: currentNote.noteId, 
        text: _textController.text
      );
    }
  }

  void _textControllerListener() async {
    final currentNote = _note;
    if(currentNote == null){ //there is no note
      return;
    }
    await _notesService.updateNote(
      noteId: currentNote.noteId,
      text: _textController.text
    );
  }

  void setupTextControllerListener(){
    _textController.removeListener(_textControllerListener); //remove the function that reacts to text modification
    _textController.addListener(_textControllerListener); //add a function that reacts to text modification
  }

  @override
  void dispose() {
    deleteNoteIfTextIsEmpty();
    saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ta notification'),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context), 
        builder: (context, snapshot){
          switch(snapshot.connectionState){

            case ConnectionState.done:
              devtools.log('Setup text editing controller');
              setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null, //the text space expands when the user is typing
                decoration: const InputDecoration(
                  hintText: 'Enter your note...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))
                      ),
                )
              );
            default:
            devtools.log('default option of create or get existing note');
              return const CircularProgressIndicator();
          }
        }
        )
      );

  }
}