import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rappellemoi/services/cloud/cloud_note.dart';


typedef NotesCallback = void Function (CloudNote note);

class NotesListView extends StatelessWidget {
  
  final NotesCallback onTap;
  final NotesCallback onDelete;
  final Iterable<CloudNote> notes;

  const NotesListView({super.key, 
    required this.onTap,
    required this.onDelete,
    required this.notes
  });

  String changeDateFormatFromString(DateTime time){
    // Define the desired format
    DateFormat formatter = DateFormat('d MMMM yyyy HH:mm');
    // Format the DateTime object to a string
    String formattedDate = formatter.format(time);
    return(formattedDate); // Example output: "6 January 2025 15:45"
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length, // the amount of notes to display
      itemBuilder: (context, index){
        final note = notes.elementAt(index);
        final screenWidth = MediaQuery.of(context).size.width;
        return  Column(
          children: [
            const SizedBox(height: 40,),
            SizedBox(
              width: screenWidth * 0.9,
              child: ListTile(
                onTap: (){
                  onTap(note); //when we tape on a note, call the function onTap
                },
                title:  Column(
                  children: [
                     Text("Date: ${changeDateFormatFromString(note.notificationDate!)}"),
                     const SizedBox(height: 10,),
                     Text("${note.text}")
                     
                  ],
                ),
                trailing: IconButton(
                  onPressed: () {
                    onDelete(note);
                  },
                  icon: const Icon(Icons.delete)
                ),
                tileColor: Colors.blue[100],
                shape: RoundedRectangleBorder( //add style to the tile
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        );
      },
      //separatorBuilder: (context, index)=> const SizedBox(height: 5,),
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }
}

// Text(
//                   note.text,
//                   maxLines: 1,
//                   softWrap: true,
//                   overflow: TextOverflow.ellipsis,
//                 ),