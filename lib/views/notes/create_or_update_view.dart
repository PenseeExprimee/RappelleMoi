import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rappellemoi/generics/get_arguments.dart';
import 'package:rappellemoi/notification/notification_service.dart';
import 'package:rappellemoi/services/auth/auth_service.dart';
import 'package:rappellemoi/services/bloc/auth_bloc.dart';
import 'package:rappellemoi/services/bloc/auth_event.dart';
import 'package:rappellemoi/services/cloud/cloud_firebase_storage.dart';
import 'package:rappellemoi/services/cloud/cloud_note.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
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

    //If the user clicked on "re-schedule", he can update the note
    if((ModalRoute.of(context)!.settings.arguments) != null){
      _textController.text = (ModalRoute.of(context)!.settings.arguments).toString();
    }

    //Grab an existing note if there is one
    final existingNote = context.getArgument<CloudNote>();
    if (existingNote != null){
      devtools.log("there is an existing note");
      _note = existingNote;
      _textController.text = existingNote.text;
      

      if(flag == 1 ){ //we just called selected date
        devtools.log('flag equal to one');
        devtools.log(_dateTimeController.text);
        await _notesService.updateNoteTime(noteId: existingNote.noteId, notificationDate: DateTime.parse(_dateTimeController.text));
        flag =0;
        return existingNote;
    
      } else{
        _date = existingNote.notificationDate;
        if(_date != null){
          devtools.log("HEEEEEEEEEEEEERE");
          devtools.log(_date.toString());
          var finalDate = DateFormat('d MMMM yyyy HH:mm').format(_date!);
          devtools.log(finalDate);
          _dateTimeController.text = finalDate;
          return existingNote;
        }
        
        var splitTime = '${_date.toString().split(" ")[0]} ${_date.toString().split(" ")[1].substring(0,5)}';
        _dateTimeController.text = splitTime;
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
    devtools.log("New note notification date: ${newNote.notificationDate}");
    _dateTimeController.text = changeDateFormatFromString(newNote.notificationDate!); //newNote.notificationDate.toString().split(" ")[0];
    return newNote;
  }

  void deleteNoteIfTextIsEmpty(){ //the note get deleted even if the date is not empty -> no text no date
    final currentNote = _note;

    if(currentNote != null && _textController.text.isEmpty){ //the user clicked to add a note but did not enter anything in the text field
      _notesService.deleteNote(noteId: currentNote.noteId);
    }
  }

  
  DateTime changeDateFormat(String time){
    DateFormat inputFormat = DateFormat('d MMMM yyyy HH:mm');
    DateTime parsedDate = inputFormat.parse(time);
    return parsedDate;
  }

  String changeDateFormatFromString(DateTime time){
    // Define the desired format
    DateFormat formatter = DateFormat('d MMMM yyyy HH:mm');
    // Format the DateTime object to a string
    String formattedDate = formatter.format(time);
    return(formattedDate); // Example output: "6 January 2025 15:45"
  }

  void saveNoteIfTextNotEmpty() async { //the note get saved only if the text is not empty
    final currentNote = _note;
    if(currentNote !=null && _textController.text.isNotEmpty){
      devtools.log('Save my note please :D');
      devtools.log("DateTime text: ${_dateTimeController.text}");
      

      //Parse the string into a datetime object
      var parsedDate = changeDateFormat(_dateTimeController.text);
      devtools.log("Datetime parse: ${DateTime.parse(parsedDate.toString())}");

      //Create the notification here
      NotificationService.scheduleNotification(
              title: 'Rappelle moi :D',
              body: _textController.text,
              scheduledNotificationDateTime: parsedDate,
              payLoad: currentNote.noteId,
              );
      
      //Update the note
      await _notesService.updateNote(
        noteId: currentNote.noteId, 
        text: _textController.text,
        notificationDate: parsedDate
      );
    }
  }

  void _textControllerListener() async {
    final currentNote = _note;
    if(currentNote == null){ //there is no note
      return;
    }
    devtools.log("Date format ok? ${_dateTimeController.text}");
    //Parse the string into a datetime object
    var parsedDate = changeDateFormat(_dateTimeController.text);

    await _notesService.updateNote(
      noteId: currentNote.noteId,
      text: _textController.text,
      notificationDate: parsedDate
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

    var parsedDate = changeDateFormat(_dateTimeController.text);
      
    await _notesService.updateNote(
      noteId: currentNote.noteId,
      text: _textController.text,
      notificationDate: parsedDate
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
    devtools.log(_dateTimeController.text);
    DateTime? _picked = await DatePicker.showDateTimePicker(
    context,
    showTitleActions: true,
    minTime: DateTime.now(),
    maxTime: DateTime(3000,1,1),
    currentTime: changeDateFormat(_dateTimeController.text),
    onConfirm: (time) {
      devtools.log("_selecteDate function date: ${time.toString().split(" ")[0]}");

      //Check if the time selected is in the future, if not, send an overlay
      if(!time.isAfter(DateTime.now())){
        //show an overlay saying the date selected has to be in the future
        devtools.log('The selected time is not in the future!!');
        _showPopup(context);
      }
      setState((){
        var finalDate = DateFormat('d MMMM yyyy HH:mm').format(time);
        _dateTimeController.text = finalDate;
        flag = 1;
      });
    },
  );

  return;
}

  void _showPopup(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Date invalide"),
            content: const Text("La date choisie doit être dans le futur."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Ferme la boîte de dialogue
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
  }
}


