import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolistflutter/db/database_helper.dart';
import 'package:todolistflutter/model/note.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  static var _priority = ['High', 'Low'];
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  String appBarTitle;
  Note note;

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descController.text = note.description;

    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                moveToLastScreen();
              },
            ),
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                // First element
                ListTile(
                  title: DropdownButton(
                    items: _priority.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    style: textStyle,
                    value: getPriorityString(note.priority),
                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        getPriorityInt(valueSelectedByUser);
                        debugPrint('User selected: $valueSelectedByUser');
                      });
                    },
                  ),
                ),

                // second element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      updateTitle();
                      debugPrint('New value is $value');
                    },
                    decoration: InputDecoration(
                        labelStyle: textStyle,
                        labelText: 'Title',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // third element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: descController,
                    style: textStyle,
                    onChanged: (value) {
                      updateDesc();
                      debugPrint('New value is $value');
                    },
                    decoration: InputDecoration(
                        labelStyle: textStyle,
                        labelText: 'Description',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                // last element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              _saveNote();
                              debugPrint('Save button clicked');
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              _deleteNote();
                              debugPrint('Delete button clicked');
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  void getPriorityInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  String getPriorityString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priority[0];
        break;
      case 2:
        priority = _priority[1];
        break;
    }
    return priority;
  }

  void updateTitle() {
    note.title = titleController.text;
  }

  void updateDesc() {
    note.description = descController.text;
  }

  void _saveNote() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now()).toString();
    int result;
    if (note.id != null) {
      //update
      result = await databaseHelper.updateNote(note);
    } else {
      //insert
      result = await databaseHelper.insertNote(note);
    }
    if (result != 0) {
      //success
      _showAlertDialog('Todo Saved Successfully');
    } else {
      //failed
      _showAlertDialog('Problem Saving Todo');
    }
  }

  void _deleteNote() async {
    moveToLastScreen();
    if (note.id == null) {
      _showAlertDialog('No Todo deleted');
      return;
    }
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      //success
      _showAlertDialog('Todo Deleted Successfully');
    } else {
      //failed
      _showAlertDialog('Problem Deleting Todo');
    }
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void _showAlertDialog(String msg) {
    AlertDialog alertDialog = AlertDialog(
      title: Text('Status'),
      content: Text(msg),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
