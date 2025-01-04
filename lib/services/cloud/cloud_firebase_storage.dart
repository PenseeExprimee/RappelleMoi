import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rappellemoi/services/cloud/cloud_note.dart';
import 'dart:developer' as devtools show log;

import 'package:rappellemoi/services/cloud/cloud_note_exceptions.dart';

class FirebaseCloudStorage {

  //create a singleton of the class storage
  static final FirebaseCloudStorage  _sharedInstance = FirebaseCloudStorage._privateConstructor();
  FirebaseCloudStorage._privateConstructor();
  factory FirebaseCloudStorage() => _sharedInstance;


  //create a collection in Firestore
  final notesCollection = FirebaseFirestore.instance.collection('notes');

  //function to create a note
  Future<CloudNote> createNewNote({required String ownerUserId}) async {

    try{
      //create the note, add it to the collection
      final newNote = await notesCollection.add({
        'user_id': ownerUserId,
        'text': '' //empty for now
      });
      
      //get the note you just created
      final fetchedNote = await newNote.get();
      devtools.log('fetched note $fetchedNote');

      //return the cloud note
      return CloudNote(
        noteId: fetchedNote.id,
        userId: ownerUserId,
        text: '',
        //notificationDate: DateTime.now()
      );
    } catch (e){
      throw CouldNotCreateNote();
    }
  }

  Future<void> updateNote({required String noteId, required String text}) async{
    
    try{
      await notesCollection.doc(noteId).update({
        'text': text
      });
    } catch(e){
      devtools.log('An error appeared when you tried to update the note: $e');
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
  Stream<Iterable<CloudNote>> allNotes({required ownerUserId}) =>
    notesCollection.snapshots().map((event) => event.docs
    .map((doc) => CloudNote.fromSnapshot(doc))
    .where((note)=> note.userId == ownerUserId)
    );

  //get notes
  Future<Iterable<CloudNote>> getNotes({required ownerUserId}) async {
    
    try{
      return await notesCollection.where(
        'user_id',
        isEqualTo: ownerUserId
      ).get()
      .then((value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    } catch(e){
      devtools.log('An error appeared when you tried to get the notes: $e');
      throw CouldNotGetAllNotes();
    }
  }

}