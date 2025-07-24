import 'package:flutter/material.dart';
import 'package:note/models/navigator.dart';
import '../db/notes_database.dart';
import '../models/note.dart';
import 'add_edit_note_screen.dart';
import 'package:intl/intl.dart';

class NotesListScreen extends StatefulWidget {
  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  late List<Note> allNotes;
  List<Note> filteredNotes = [];
  bool isLoading = false;
  String searchQuery = '';
  bool isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);
    allNotes = await NotesDatabase.instance.readAllNotes();
    filterNotes();
    setState(() => isLoading = false);
  }

  void filterNotes() {
    setState(() {
      if (searchQuery.isEmpty) {
        filteredNotes = allNotes;
      } else {
        filteredNotes = allNotes.where((note) {
          return note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              note.content.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: isSearchVisible
            ? TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xff04325d)),
                ),
                style: TextStyle(color: Color(0xff04325d)),
                textAlign: TextAlign.center,
                onChanged: (val) {
                  searchQuery = val;
                  filterNotes();
                },
              )
            : Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(
              isSearchVisible ? Icons.close : Icons.search,
              color: Color(0xff04325d),
            ),
            onPressed: () {
              setState(() {
                isSearchVisible = !isSearchVisible;
                if (!isSearchVisible) {
                  searchQuery = '';
                  filterNotes();
                }
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredNotes.isEmpty
          ? Center(child: Text('You have no notes yet'))
          : ListView.builder(
              itemCount: filteredNotes.length,
              padding: EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Dismissible(
                    key: Key(note.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: slideRightBackground(),
                    confirmDismiss: (direction) async {
                      bool confirm = false;
                      await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                          contentPadding: EdgeInsets.fromLTRB(24, 0, 24, 0),
                          actionsPadding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                          title: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.redAccent,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Are you sure?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          content: Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                            child: Text(
                              'This note will be permanently deleted.',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  icon: Icon(Icons.cancel, color: Colors.grey),
                                  label: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                SizedBox(width: 12),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: Icon(Icons.delete),
                                  label: Text('Delete'),
                                  onPressed: () {
                                    confirm = true;
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                      if (confirm) {
                        await NotesDatabase.instance.delete(note.id!);
                        refreshNotes();
                      }
                      return confirm;
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Color(note.color).withOpacity(0.2),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        title: Text(
                          note.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              note.content.length > 60
                                  ? '${note.content.substring(0, 60)}...'
                                  : note.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              DateFormat.yMMMd().add_jm().format(
                                note.createdTime,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: Color(0xff04325d)),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditNoteScreen(note: note),
                              ),
                            );
                            refreshNotes();
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff04325d),
        onPressed: () {
          AppNavigator.fade(context, AddEditNoteScreen());
          refreshNotes();
        },
        child: Icon(Icons.add, color: Color.fromARGB(255, 255, 255, 255)),
      ),
    );
  }

  Widget slideRightBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete, color: Colors.white, size: 28),
          SizedBox(width: 8),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
