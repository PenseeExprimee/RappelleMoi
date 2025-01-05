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
  DateTime? _date; 
  late final TextEditingController _textController;
  late final TextEditingController _dateTimeController;
  late final FirebaseCloudStorage _notesService;

  var flag = 0;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage(); //always the same because we created a singleton
    _textController = TextEditingController();
    _dateTimeController = TextEditingController();
    super.initState();
  }

  Future <CloudNote> createOrGetExistingNote(BuildContext context) async {

    //Grab an existing note if there is one
    final existingNote = context.getArgument<CloudNote>();
    if (existingNote != null){
      devtools.log("there is an existing note");
      _note = existingNote;
      _textController.text = existingNote.text;
      
      devtools.log('Existing note controller: ${existingNote.notificationDate}');
      devtools.log('Date time controller: ${_dateTimeController.text}');

      if(flag == 1 ){ //we just called selected date
        devtools.log('flag equal to one');
        await _notesService.updateNoteTime(noteId: existingNote.noteId, notificationDate: DateTime.parse(_dateTimeController.text));
        flag =0;
        return existingNote;
    
      } else{
        _date = existingNote.notificationDate;
        _dateTimeController.text = existingNote.notificationDate.toString().split(" ")[0];
        return existingNote;
    }
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
    _dateTimeController.text = newNote.notificationDate.toString().split(" ")[0];
    return newNote;
  }

  void deleteNoteIfTextIsEmpty(){ //the note get deleted even if the date is not empty -> no text no date
    final currentNote = _note;

    if(currentNote != null && _textController.text.isEmpty){ //the user clicked to add a note but did not enter anything in the text field
      _notesService.deleteNote(noteId: currentNote.noteId);
    }
  }

  void saveNoteIfTextNotEmpty() async { //the note get saved only if the text is not empty
    final currentNote = _note;
    if(currentNote !=null && _textController.text.isNotEmpty){
      devtools.log('Save my note please :D');
      devtools.log("DateTime text: ${_dateTimeController.text}");
      await _notesService.updateNote(
        noteId: currentNote.noteId, 
        text: _textController.text,
        notificationDate: DateTime.parse(_dateTimeController.text)
      );
    }
  }

  void _textControllerListener() async {
    final currentNote = _note;
    if(currentNote == null){ //there is no note
      return;
    }
    devtools.log("Date format ok? ${_dateTimeController.text}");
    await _notesService.updateNote(
      noteId: currentNote.noteId,
      text: _textController.text,
      notificationDate: DateTime.parse(_dateTimeController.text)
    );
  }

  void _dateTimeControllerListener() async {
    final currentDate = _date;
    final currentNote = _note;
    if(currentDate == null){ //there is no date
      return;
    }
    if(currentNote == null){ //there is no note
      return;
    }
    await _notesService.updateNote(
      noteId: currentNote.noteId,
      text: _textController.text,
      notificationDate: DateTime.parse(_dateTimeController.text)
    );
  }

  void setupTextControllerListener(){
    _textController.removeListener(_textControllerListener); //remove the function that reacts to text modification
    _textController.addListener(_textControllerListener); //add a function that reacts to text modification

    _dateTimeController.removeListener(_dateTimeControllerListener);
    _dateTimeController.addListener(_dateTimeControllerListener);
  }

  @override
  void dispose() {
    deleteNoteIfTextIsEmpty();
    saveNoteIfTextNotEmpty();
    _textController.dispose();
    _dateTimeController.dispose();
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
              return  Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10,),
                    const Text("Tu peux ici créer et programmer ta notification. Elle te sera envoyée à la date et l'heure prévue."),
                    const SizedBox(height: 40,),
                    const Align(
                      alignment:Alignment.topLeft,
                      child:Text('Texte'),
                    ),
                    const SizedBox(height: 10,),
                    TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null, //the text space expands when the user is typing
                      decoration: const InputDecoration(
                        hintText: 'Enter your note...',
                        prefixIcon: Icon(Icons.note_alt_sharp),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                            ),
                      )
                    ),
                    const SizedBox(height: 20,),
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text('Date'),
                    ),
                    const SizedBox(height: 10,),
                     TextField(
                      controller: _dateTimeController,
                      onTap:() {
                        _selectedDate();
                      },
                      decoration: const InputDecoration(
                        hintText: 'DATE',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0))
                        )
                      ),
                    )
                  ],
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        }
        )
      );

  }
  Future <void> _selectedDate() async {
    devtools.log('selected date called');
  DateTime? _picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100)
  );

  if (_picked != null){
    devtools.log("_selecteDate function date: ${_picked.toString().split(" ")[0]}");
    setState((){
      _dateTimeController.text = _picked.toString().split(" ")[0];
      //flag = 1;
    });
      flag = 1;
    devtools.log("Datetime controller ${_dateTimeController.text}");

  }
  return;
}
}


