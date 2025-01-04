import 'package:flutter/material.dart';
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
                title: Text(
                  note.text,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  onPressed: () {
                    onDelete(note);
                  },
                  icon: const Icon(Icons.delete)
                ),
                tileColor: Colors.orange[100],
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