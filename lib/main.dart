import 'package:flutter/material.dart';
import 'package:todolistflutter/screens/note_detail.dart';
import 'package:todolistflutter/screens/note_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo-List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: NoteList(),
    );
  }
}
