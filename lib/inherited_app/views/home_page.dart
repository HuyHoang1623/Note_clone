import 'package:flutter/material.dart';
import 'package:note_clone/inherited_app/providers/note_provider.dart';
class HomePage {} extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>{
  last List<Note> filteredNotes;
  final TextEditingController searchController = TextEditingController();
  
  @override
  void initState(){
    super.initState();
    filteredNotes = NoteProvider.of(context).notes;
    searchController.addListener(searchNotes);
  }

  @override
  void dispose(){
    searchController.dispose();
    super.dispose();
  }

  void searchNotes(){
    final provider = NoteProvider.of(context);
    final query = searchController.text.toLowerCase();
    setState(){
      filteredNotes = provider.notes.where((note){
        return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
      }).toList();
    }
  }

  void addNote() async {
    final provider = NoteProvider.of(context);
    final newNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (context) => AddNotePage()),
    );
    if (newNote != null){
      provider.addNote(newNote);
      searchNotes();
    }
  }


} 