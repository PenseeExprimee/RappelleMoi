import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rappellemoi/services/cloud/cloud_note.dart';
import 'dart:developer' as devtools show log;

import 'package:rappellemoi/services/cloud/cloud_note_exceptions.dart';

//These are all the functions used to handle the notes.

class FirebaseCloudStorage {

  //create a singleton of the class storage
  static final FirebaseCloudStorage  _sharedInstance = FirebaseCloudStorage._privateConstructor();
  FirebaseCloudStorage._privateConstructor();
  factory FirebaseCloudStorage() => _sharedInstance;


  //create a collection in Firestore
  final notesCollection = FirebaseFirestore.instance.collection('notes');

  //function to create a note
  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final currentDate = DateTime.now();
    devtools.log("We are creating a new note, show me the date: $currentDate");
    try{
      //create the note, add it to the collection
      
      final newNote = await notesCollection.add({
        'user_id': ownerUserId,
        'text': '', //empty for now,
        'execution_date': currentDate
      });
      
      //get the note you just created
      final fetchedNote = await newNote.get();

      //return the cloud note
      return CloudNote(
        noteId: fetchedNote.id,
        userId: ownerUserId,
        text: '',
        notificationDate: currentDate
      );
    } catch (e){
      throw CouldNotCreateNote();
    }
  }

  Future<void> updateNote({required String noteId, required String text, required DateTime notificationDate}) async{
    
    try{
      await notesCollection.doc(noteId).update({
        'text': text,
        'execution_date': notificationDate
      });
    } catch(e){
      devtools.log('An error appeared when you tried to update the note: $e');
      throw CouldNotUpdateNote();
    }

  }

  Future<void> updateNoteTime({required String noteId,required DateTime notificationDate}) async{
    
    try{
      await notesCollection.doc(noteId).update({
        'execution_date': notificationDate
      });
      devtools.log('Note successufully updated');
    } catch(e){
      devtools.log('An error appeared when you tried to update the time of the note: $e');
      throw CouldNotUpdateNote();
    }

  }

  Future <void> deleteNote({required noteId}) async {
    try {
      await notesCollection.doc(noteId).delete();
    } catch (e) {
      devtools.log('An error occured when you tried to delete this note $e');
      throw CouldNoteDeleteNote();
    }
  }

  //build a stream of notes for a specific user
  //Filter the notes before reading them so we do not retrieve all notes in the database
  Stream<Iterable<CloudNote>> allNotes({required ownerUserId}){
    final allNotes = notesCollection
    .where('user_id', isEqualTo: ownerUserId).
    snapshots()
    .map((event) => event.docs
    .map((doc) => CloudNote.fromSnapshot(doc)));

    return allNotes;
  }


}