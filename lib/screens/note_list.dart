import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:todolistflutter/db/database_helper.dart';
import 'package:todolistflutter/model/note.dart';
import 'package:todolistflutter/screens/note_detail.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateNotes();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ToDos'),
      ),
      body: getNotes(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("FAB Tapped");
          navigateToDetail(Note('', '', 2), 'Add ToDo');
        },
        tooltip: 'Add ToDo',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNotes() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
        itemCount: count,
        padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
        itemBuilder: (BuildContext context, int pos) {
          return Padding(
            padding: EdgeInsets.only(bottom: 6.0),
            child: Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      getPriorityColor(this.noteList[pos].priority),
                  child: getPriorityIcon(this.noteList[pos].priority),
                ),
                title: Text(
                  this.noteList[pos].title,
                  style: titleStyle,
                ),
                subtitle: Text(this.noteList[pos].date),
                trailing: GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    _deleteNote(context, noteList[pos]);
                  },
                ),
                onTap: () {
                  debugPrint("ListTile Tapped");
                  navigateToDetail(this.noteList[pos], 'Edit ToDo');
                },
              ),
            ),
          );
        });
  }

  // return color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }

  // return icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _deleteNote(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _displaySnackBar(context, 'Todo Deleted Successfully');
      updateNotes();
    }
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateNotes();
    }
  }

  void _displaySnackBar(BuildContext context, String msg) {
    final snackBar = SnackBar(content: Text(msg));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void updateNotes() {
    final Future<Database> db = databaseHelper.initDB();
    db.then((database) {
      Future<List<Note>> notes = databaseHelper.getActualNotes();
      notes.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
