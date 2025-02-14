import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rappellemoi/extensions/filter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:rappellemoi/services/crud/crud_exceptions.dart';
import 'dart:developer' as devtools show log;

 // Gonna talk with our database

const idcolumn = 'id';
const cloudNoteIdColumn = "cloud_note_id";
const emailColumn = 'email';
const userIdColumn = 'user_id';
const authUserIdColumn = "auth_user_id";
const textColumn = 'text';
const dateColumn= 'date';
const noteIdColumn = 'note_id';

const dbName = 'notes.db'; //file our database is gonna be stored in
const noteTable = 'note';
const userTable = 'user';
const notificationTable = 'notification';


const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	      "id"	INTEGER,
        "auth_user_id" STRING,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
       );''';

const createNotificationTable = '''CREATE TABLE IF NOT EXISTS "notification" (
	      "id"	INTEGER NOT NULL,
        "note_id" STRING,
        "date"	STRING,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("note_id") REFERENCES "note"("id"));;
       );''';


const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
  "id" INTEGER NOT NULL,
  "cloud_note_id"	STRING,
  "user_id"	STRING,
  "text"	STRING,
  "date" STRING,
  PRIMARY KEY("id" AUTOINCREMENT),
  FOREIGN KEY("user_id") REFERENCES "user"("id"));
);''';


class LocalNotesService {
  
  //make sure that when a user gets to the main UI, there is an existing user with the credentials that have been used in the database
  Future <DatabaseUser> getOrCreateUser({
    required String email,
    required String authUserId,
    bool setAsCurrentUser = true,
    }) async {

    //first, try to get the user from the database.
    try{
      devtools.log("Inside the get or create function, call to the get user fucntion");
      final user = await getUser(email: email);
      devtools.log("In the get or create user function, After getting the user");
      if(setAsCurrentUser){
        _user = user;
      }
      return user;
    } on CouldNotFindUserInDatabase {
      devtools.log("In the get or create user fuction,could not find the user in the local database, so let's create one");
      //this error happens if the user could not be found, we create a user instead of getting one
      final createdUser = await createUser(email: email, authUserId: authUserId);
      if(setAsCurrentUser){
        _user = createdUser;
      }
      devtools.log("In the get or create user function, return the created user");
      return createdUser;
    } catch (e){
        devtools.log("Error, in the get or create user function: $e");
        // in case the user could not be created, we catch it here because not catched in create user function
        rethrow;
    }
    
  }

//will cache all of our notes and notifications
  List <DatabaseNote> _notes = [];


  //we need to have the user in here so the notes we render are only the notes of the user
  DatabaseUser? _user;


  //create a singleton
  static final LocalNotesService _shared = LocalNotesService._sharedInstance();
  LocalNotesService._sharedInstance(){
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () { //will be called when a new listener subscribes to the note tream constroller's stream
        //the stream of the note stream controller has to be populated with all we read from the database in _notes
        _notesStreamController.sink.add(_notes);
      },
    );
  } 
  factory LocalNotesService() => _shared; //now when initState calls notesService constructor it will call this one
  
 //everything is gonna be read from the outside through this
  late final StreamController <List<DatabaseNote>> _notesStreamController; //can create new listeners to listen to the changes made to the pipe
  
  //we use the stream controller to get all the notes of a current user
  Stream <List<DatabaseNote>> get allNotes => //thank to this, we return a stream of list of notes, from the current user only
    _notesStreamController.stream.filter((note){
    final currentUser = _user;
    if(currentUser != null){
      //the user is set
      return note.userId == currentUser.id; //returns a boolean, not a note
    } else {
      throw UserShouldBeSetBeforeReadingAllNotes(); 
    }
  });
  
  //the goal from this function is to read notes from the database and place it in the notes list and the stream controller
  Future <void> _cacheNotes() async{
    final allNotes = await getAllNotes();

    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
    devtools.log("Done with caching notes");
  }

  //we will store our database in here
  Database? _db;
  //for every function we will write later, this will check if the database exists, and if not, throw an error
  Database _getDatabaseOrThrow(){
    //only makes sure that there is an instance of the database, not sure that the database is actually open
    final db = _db;
    if(db == null){
      devtools.log('The database is null');
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }

  }
  
  //Function to make sure that the database is actually open
  Future <void> _ensureDbIsOpen() async {
    try{
      //Make sure that we are not opening the database over and over again
      await open();
    } on DatabaseAlreadyOpenException{
      //empty
    }
  }
  //we need an async function to open the database and store it in the note service
  Future <void> open() async {
    if (_db != null) { //it means that the database is already open
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      //create the note table
      await db.execute(createUserTable);
      //create the note table
      await db.execute(createNoteTable);
      //create notification table
      await db.execute(createNotificationTable);

      //after openeing the database, we cache all the notes available
      await _cacheNotes();

    } on MissingPlatformDirectoryException {
        throw UnableToGetDocumentDirectory();
    }
  } 
  //we also need an async function to close the database
  Future <void> close() async {
    final db = _db;
    if(db == null){
      throw DatabaseIsNotOpen();
    } else {
      await db.close(); //this close function comes from sqflite api file
      _db = null;
    }
  }

  //delete a user
  Future <void> deleteUser({required String email}) async{
    await _ensureDbIsOpen();
    final db  = _getDatabaseOrThrow();
    final deletedCount = await db.delete( //returns a future of the number of deleted accounts
      userTable,
      where:'email =?',
      whereArgs: [email.toLowerCase()], //we made email unique so we can delete users according to their email.
    );

    if(deletedCount !=1){
      throw CouldNotDeleteUser;
    }
  }

  //create a user
  Future <DatabaseUser> createUser({required String email, required String authUserId}) async {
    try {
      await _ensureDbIsOpen();
      final db = _getDatabaseOrThrow();
  
      //insert the user in the table
      final userId = await db.insert(userTable,{
        emailColumn: email.toLowerCase(),
        authUserIdColumn: authUserId,
      });

      return DatabaseUser(
        id: userId,
        email: email,
        authUserId: authUserId,
        );
    } catch (e){
      devtools.log("Error in create function: $e");
      throw CouldNotFindUser();
    }
  
  }

  Future <DatabaseUser> getUser({required String email}) async {
    try{
      devtools.log("Start the get user function");
      await _ensureDbIsOpen();
      final db =_getDatabaseOrThrow();
      final results = await db.query(
        userTable,
        limit: 1,
        where : 'email =?',
        whereArgs: [email.toLowerCase()],
      );
      devtools.log("AAAAAAAA");
      devtools.log("In the get user function}");
      //we need to make sure that the user exists
      if(results.isEmpty){
        throw CouldNotFindUserInDatabase();
      } else {
        devtools.log("In the get user function, return the user: ${results.first}");
        return DatabaseUser.fromRow(results.first); //first row that was read from the user table
      }
    } catch (e){
      devtools.log("An error occured while trying to get the user: $e");
      throw CouldNotFindUserInDatabase();
    }

  }

  Future <DatabaseNote> createNote({required DatabaseUser owner, required String cloudNoteId}) async {
      
    try{
      devtools.log("In the create note function");
      await _ensureDbIsOpen();
      final db = _getDatabaseOrThrow();

      //make sure that the user exists in the database
      devtools.log("Inside the create note function, call to the get user function");
      final dbUser = await getUser(email: owner.email);
      //make sure that the id of the provided database owner actually exists in the database (so they have the same email and the same id)
      if(dbUser != owner){
        throw CouldNotFindUser();
      }

      const text = '';
      var date = DateTime.now();
      //actually create the note
      final noteId = await db.insert(noteTable,{
        cloudNoteIdColumn: cloudNoteId,
        userIdColumn : owner.authUserId,
        textColumn: text,
        dateColumn: date.toString(),
      });
      //return the new note
      final note = DatabaseNote(
        id: noteId,
        cloudNoteId: cloudNoteId,
        userId: owner.authUserId, //to change to use the user.uid
        text: text,
        date: date.toString()
      );

      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    } catch (e){
      devtools.log("Error during the creation of the note in local database: $e");
      throw CouldNotCreateNote();
    }
  }

  Future <void> createNotification({required DatabaseNote localNote}) async {
    devtools.log("inside the create notification function");
    try{
      await _ensureDbIsOpen();
      final db = _getDatabaseOrThrow();

      //Get the notification
      final notifications = await db.query(
        notificationTable,
        limit: 1,
        where: 'note_id=?',
        whereArgs: [localNote.cloudNoteId],
        );
      
      if(notifications.isEmpty){
        //The notification does not exist yet, needs to be created
          final noteId = await db.insert(notificationTable,{
            noteIdColumn: localNote.cloudNoteId,
            dateColumn: localNote.date.toString(),
          });

          //verify the notification just created
          final results = await db.query(
          notificationTable,
          limit: 1,
          where : 'id =?',
          whereArgs: [noteId],
        );
        devtools.log("This is the notification that has just been created: $results");
      } else {
        //The notification exits and needs to be updated
        devtools.log("Create notification: Update the existing notification");
        //update DB
        final updatesCount = await db.update(
          notificationTable, {
            dateColumn: localNote.date,
          },
          where: 'note_id=?',
          whereArgs: [localNote.cloudNoteId],
        );
        devtools.log("Create notification: number of updates: $updatesCount");
      }
      

    } catch (e){
      devtools.log("Error during the creation of the notification in local database: $e");
      throw CouldNotCreateNote();
    }
  }
  
  Future <void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
          noteTable,
          where: 'cloud_note_id=?',
          whereArgs: [id]
    );
    if(deletedCount == 0){
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.cloudNoteId == id); //we remove from the cache the notes(s) that have been deleted.
      _notesStreamController.add(_notes);
    }
  }

  Future <int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db  = _getDatabaseOrThrow();
    final numberOfDeletions =  await db.delete(noteTable); //since we only pass the name of the table it is going to delete all rows.
    
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }

  //retrieve a specific note
  Future <DatabaseNote> getNote({required String id}) async{
    devtools.log("Inside the get note function");
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
    noteTable,
    limit: 1,
    where: 'cloud_note_id=?',
    whereArgs: [id],
    );

    if(notes.isEmpty){
      devtools.log("Inside get note function, Could not find the note to update :Ddddd");
      var noteTableState = await getAllNotes();
      devtools.log("Inside get note function, Current note table: ${noteTableState.toString()}");
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      //update the copy of the note we has in our cache, to make sure that we have the latest one if any change has been performed on the database
      _notes.removeWhere((note) => note.cloudNoteId == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }

    

  }

  //get all the notes for the given user
  Future <Iterable<DatabaseNote>> getAllNotes() async {
    try {
      devtools.log("Inside get all notes");
      await _ensureDbIsOpen();
      final db = _getDatabaseOrThrow();
      devtools.log("Inside get all notes, database open ok");
      final notes = await db.query(noteTable);
      final notification = await db.query(notificationTable);
      devtools.log("Inside get all notes after db query ");
      devtools.log('Inside get all notes return tf is this log: ${notes.toString()}');
      devtools.log('Inside the get all notification: ${notification.toString()}');
      return notes.map((noteRow) => DatabaseNote.fromRow(noteRow)); //la focntion map prend chacun des row et renvoie le row sous forme de Datbase Row
    } catch (e){
      devtools.log("An error occured in getAllNotes function: $e");
      throw CouldNotGetAllNotes();
    }
  }

  Future <DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
    required DateTime date,
  }) async {
    try{
      await _ensureDbIsOpen();
      final db = _getDatabaseOrThrow();
      devtools.log("Update local note function, id : ${note.cloudNoteId}");
      devtools.log("Update local note function, text of the note: $text");
      devtools.log("Update local note function, date of the note $date");
      //final noteTableState = await getAllNotes();
      //devtools.log("Update local note function, current note table: ${noteTableState.toString()}");
      final noteToUpdate = await getNote(id: note.cloudNoteId); // will throw an error if the note does not exist, we do not need a return value
      //update DB
      final updatesCount = await db.update(
        noteTable, {
          textColumn: text,
          dateColumn: date.toString(),
        },
        where: 'cloud_note_id=?',
        whereArgs: [note.cloudNoteId],
      );
      devtools.log("Update local note function, How many lines got updated?: $updatesCount");

      if(updatesCount ==0){
        throw CouldNotUpdateNote();
      } else {
        final updatedNote = await getNote(id: note.cloudNoteId); //we have updated the table with the new note, now we retrieve it.
        devtools.log("Update local note function, This is the updated note: ${updatedNote.toString()}");
        //update the cache
        _notes.removeWhere((note) => note.cloudNoteId == updatedNote.cloudNoteId);
        _notes.add(updatedNote);
        _notesStreamController.add(_notes);
        final allNotesShow = await getAllNotes();
        devtools.log("Update note function, state of the database after update: ${allNotesShow.toString()}");
        return updatedNote;
      }
    } catch(e){
      devtools.log("An error occured during the update of the local note: $e");
      throw CouldNotUpdateNote();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String authUserId;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
    required this.authUserId
  });

  DatabaseUser.fromRow(Map<String, Object?> map):  //that's a constructor
    id = map[idcolumn] as int,
    email = map[emailColumn] as String,
    authUserId = map[authUserIdColumn] as String;

  @override
  String toString() => 'DatabaseUser: ID = $id,Auth_user_id = $authUserId, email = $email'; //will be used to read information from our instances

  @override 
  bool operator == (covariant DatabaseUser other) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
}


class DatabaseNote {
  final int id;
  final String cloudNoteId;
  final String userId;
  final String text;
  final String date;
  
  DatabaseNote({
    required this.id,
    required this.cloudNoteId,
    required this.userId,
    required this.text,
    required this.date,
  });

  DatabaseNote.fromRow(Map<String, Object?> map):  //that's a constructor
    id = map[idcolumn] as int,
    cloudNoteId = map[cloudNoteIdColumn] as String,
    userId = map[userIdColumn] as String,
    text = map[textColumn] as String,
    date = map[dateColumn] as String; //we transform an integer into a boolean. Le ? sert de if\else


  @override
  String toString() => 'Note, ID = $cloudNoteId, userId = $userId, text = $text, date= $date';


  @override 
  bool operator == (covariant DatabaseNote other) => cloudNoteId == other.cloudNoteId;
  
  @override
  int get hashCode => cloudNoteId.hashCode;
}