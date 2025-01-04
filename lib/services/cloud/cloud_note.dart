

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class CloudNote {

  final String noteId;
  final String userId;
  final String text;
  //final DateTime notificationDate;

  const CloudNote({
    required this.noteId,
    required this.userId,
    required this.text,
    //required this.notificationDate
  });

  //factory constrctor to get the note from the database and transform it into one of our CloudNote :D

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot):
  noteId = snapshot.id,
  userId = snapshot.data()['user_id'],
  text = snapshot.data()['text'] as String;
  //notificationDate = snapshot.data()['execution_date'];
}