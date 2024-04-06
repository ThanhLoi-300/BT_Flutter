import 'package:baitap_flutter/NotesSQLite/AddOrUpdateNote.dart';
import 'package:flutter/material.dart';

import './database/NoteDbHelper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NoteHomeUI extends StatefulWidget {
  const NoteHomeUI({super.key});

  @override
  State<NoteHomeUI> createState() => _NoteHomeUIState();
}

class _NoteHomeUIState extends State<NoteHomeUI> {

  deletedatabase(snap, index) {
    NoteDbHelper.instance.delete(snap.data![index][NoteDbHelper.colid]);
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.07,
          title: const Text('Note App')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: FutureBuilder(
            future: NoteDbHelper.instance.queryAll(),
            builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
              if (snap.hasData) {
                return ListView.builder(
                  itemCount: snap.data!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: IconButton(
                            onPressed: () {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(
                                builder: (context) {
                                  return AddOrUpdateNote(
                                    id: snap.data![index]['id'],
                                  );
                                },
                              ));
                            },
                            icon: const Icon(Icons.edit)),
                        title:
                            Text(snap.data![index][NoteDbHelper.coltittle]),
                        subtitle: Text(
                            snap.data![index][NoteDbHelper.coldescription]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              snap.data![index][NoteDbHelper.coldate]
                                  .toString()
                                  .substring(0, 10),
                            ),
                            IconButton(
                              onPressed: () {
                                deletedatabase(snap, index);
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

                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return AddOrUpdateNote(
                id: null,
              );
            },
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
