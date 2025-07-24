// lib/screens/add_edit_note_screen.dart
import 'package:flutter/material.dart';
import 'package:note/models/navigator.dart';
import 'package:note/screens/notes_list_screen.dart';
import '../models/note.dart';
import '../db/notes_database.dart';
import 'dart:math';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String content;

  @override
  void initState() {
    super.initState();
    title = widget.note?.title ?? '';
    content = widget.note?.content ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => AppNavigator.fade(context, NotesListScreen()),
              color: Colors.black54,
            ),
            Text(isEditing ? 'Edit Note' : 'New Note'),
          ],
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await NotesDatabase.instance.delete(widget.note!.id!);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Note Tittle',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) => setState(() => title = val),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please Fill The Field' : null,
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: TextFormField(
                  initialValue: content,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Contant',
                    filled: true,
                    fillColor: Colors.white,
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (val) => setState(() => content = val),
                  maxLines: null,
                  expands: true,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please Fill The Field'
                      : null,
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff04325d),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  icon: Icon(
                    isEditing ? Icons.save : Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Add Note',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final newNote = Note(
                        id: widget.note?.id,
                        title: title,
                        content: content,
                        createdTime: widget.note?.createdTime ?? DateTime.now(),
                        color: widget.note?.color ?? _getRandomColorValue(),
                      );

                      if (isEditing) {
                        await NotesDatabase.instance.update(newNote);
                      } else {
                        await NotesDatabase.instance.create(newNote);
                      }

                      AppNavigator.fade(context, NotesListScreen());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getRandomColorValue() {
    final colors = [
      Colors.amber,
      Colors.teal,
      Colors.lightBlue,
      Colors.orange,
      Colors.purple,
      Colors.green,
      Colors.indigo,
    ];
    final random = Random();
    return colors[random.nextInt(colors.length)].value;
  }
}
