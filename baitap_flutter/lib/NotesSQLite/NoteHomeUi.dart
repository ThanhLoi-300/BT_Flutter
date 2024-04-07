import 'package:baitap_flutter/NotesSQLite/AddOrUpdateNote.dart';
import 'package:flutter/material.dart';

import './database/NoteDbHelper.dart';

class NoteHomeUI extends StatefulWidget {
  const NoteHomeUI({super.key});

  @override
  State<NoteHomeUI> createState() => _NoteHomeUIState();
}

class _NoteHomeUIState extends State<NoteHomeUI> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> listNotes = [];

  deletedatabase(id) {
    NoteDbHelper.instance.delete(id);
  }

  void loadNoteList() async {
    final noteList = await NoteDbHelper.instance.queryAll();
    setState(() {
      listNotes = noteList;
    });
  }

  @override
  void initState() {
    super.initState();
    loadNoteList();
    //Thêm event cho thanh search
    searchController.addListener(() async {
      String query = searchController.text;
      List<Map<String, dynamic>> results;

      if (query.isEmpty) {
        results = await NoteDbHelper.instance.queryAll();
      } else {
        results = await NoteDbHelper.instance.searchNotes(query);
      }

      setState(() {
        listNotes = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.07,
          title: const Text('Note App')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Search',
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: listNotes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) {
                            return AddOrUpdateNote(
                              id: listNotes[index]['id'],
                            );
                          },
                        ));
                      },
                      icon: const Icon(Icons.edit)),
                  title: Text(listNotes[index]['title']),
                  subtitle: Text(listNotes[index]['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text( listNotes[index]['date'], ),
                      IconButton(
                        onPressed: () {
                          deletedatabase(listNotes[index]['id']);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(
                            builder: (context) {
                              return const NoteHomeUI();
                            },
                          ));
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              }),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return AddOrUpdateNote( id: null, );
            },
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
