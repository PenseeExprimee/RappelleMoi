

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class CloudNote {
  static final _defaultDate = DateTime (2054,1,1);
  final String noteId;
  final String userId;
  final String text;
  final DateTime? notificationDate;

  CloudNote({
    required this.noteId,
    required this.userId,
    required this.text,
    notificationDate,
  }):notificationDate = (notificationDate ?? _defaultDate);

  //factory constrctor to get the note from the database and transform it into one of our CloudNote :D

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot):
  noteId = snapshot.id,
  userId = snapshot.data()['user_id'],
  text = snapshot.data()['text'] as String,
  notificationDate = snapshot.data()['execution_date'].toDate();
}