import 'dart:convert';

import 'package:baitap_flutter/NotesSQLite/NoteHomeUi.dart';
import 'package:baitap_flutter/NotesSQLite/database/NoteDbHelper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddOrUpdateNote extends StatefulWidget {
  var id;

  AddOrUpdateNote({super.key, required this.id});

  @override
  State<AddOrUpdateNote> createState() => _AddOrUpdateNoteState();
}

class _AddOrUpdateNoteState extends State<AddOrUpdateNote> {
  Future<bool> insertdatabase(String title, String description) async {
    List<Map<String, dynamic>> list = await NoteDbHelper.instance.queryAll();

    bool titleExists =
        list.any((note) => note[NoteDbHelper.coltittle] == title);
    debugPrint("Title ");
    if (titleExists) {
      debugPrint("Title already exists");
      return true;
    } else {
      NoteDbHelper.instance.insert({
        NoteDbHelper.coltittle: title,
        NoteDbHelper.coldescription: description,
        NoteDbHelper.coldate: DateTime.now().toString(),
      });
      debugPrint("Insert successfully");
      return false;
    }
  }

  Future<bool> updatedatabase(int id, String title, description) async {
    List<Map<String, dynamic>> notes = await NoteDbHelper.instance.queryAll();
    bool checkTitle = false;

    for (var note in notes) {
      if (note[NoteDbHelper.coltittle] == title &&
          note[NoteDbHelper.colid] != id) {
        checkTitle = true;
        break;
      }
    }
    if (checkTitle) {
      return true;
    } else {
      NoteDbHelper.instance.update({
        NoteDbHelper.colid: id,
        NoteDbHelper.coltittle: title,
        NoteDbHelper.coldescription: description,
        NoteDbHelper.coldate: DateTime.now().toString(),
      });
      return false;
    }
  }

  void handleSaveButton(id, title, desc) async {
    bool isExist = await (widget.id == null
        ? insertdatabase(title, desc)
        : updatedatabase(widget.id, title, desc));

    if (!isExist) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return const NoteHomeUI();
        },
      ));
    } else {
      Fluttertoast.showToast(
        msg: 'Tiêu đề đã tồn tại',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    TextEditingController timeController = TextEditingController();

    Map<String, dynamic> note = {};

    fetchNoteData() async {
      if (widget.id != null) {
        note = (await NoteDbHelper.instance.getDataById(widget.id))!;
        titleController.text = note['title'];
        descController.text = note['description'];
        timeController.text = note['date'];
      }
    }

    fetchNoteData();

    return Scaffold(
        appBar: AppBar(
            toolbarHeight: MediaQuery.of(context).size.height * 0.07,
            title: const Text('Note Info')),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: "Enter Title",
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    hintText: "Enter Description",
                  )),
              const SizedBox(
                height: 10,
              ),
              TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    hintText: "Enter Time",
                  )),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  TextButton(
                      onPressed: () {
                        if (titleController.text.isEmpty ||
                            descController.text.isEmpty ||
                            timeController.text.isEmpty) {
                          Fluttertoast.showToast(
                            msg: 'Vui lòng điền đầy đủ',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        } else {
                          handleSaveButton(widget.id, titleController.text,
                              descController.text);
                        }
                      },
                      child: Text(widget.id == null ? 'Create' : 'Save')),
                  const SizedBox(width: 10),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel')),
                ],
              )
            ],
          ),
        ));
  }
}
