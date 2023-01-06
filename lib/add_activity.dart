import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'dart:math';
import 'package:timetracker_app/requests.dart';

const List<String> type = <String>['Project', 'Task'];
String typeSelected = "Project";

class AddActivity extends StatelessWidget {
  int? id;
  String? father;
  AddActivity({super.key, this.father, this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Activity'),
      ),
      body: MyCustomForm(father: father, id: id)
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  int? id;
  String? father;
  MyCustomForm({super.key, this.father, this.id});

  @override
  MyCustomFormState createState() => MyCustomFormState(father: father, id: id);
}

class MyCustomFormState extends State<MyCustomForm> {
  int? id;
  String? father;
  MyCustomFormState({key, this.father, this.id});
  final name = TextEditingController();
  late TextfieldTagsController _controller;

  late double _distanceToField;
  final _formKey = GlobalKey<FormState>();
  String activityName = "";
  String activityTag = "";
  //String typeSelected = "Project";
  Map<String, dynamic> newActivity = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose(); //tags controller
    name.dispose();
  }

  @override
  void initState(){
    super.initState();
    _controller = TextfieldTagsController();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                onSaved: (newValue) => activityName = newValue!,
                controller: name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please, enter activity name';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter activity name',
                ),
              ),
            ),
            Row(
              children: <Widget> [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Text("Father: ${father!}"),
                ), //Content Report
              ],
            ),
            Row(
              children: <Widget> [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: const Text("Type"),
                ),
                DropdownType(onChanged: (String? value) { typeSelected = value!; },)
              ],
            ),
            TextFieldTags(
              textfieldTagsController: _controller,
              textSeparators: const [' ', ','],
              letterCase: LetterCase.normal,
              validator: (String tag) {
                if (_controller.getTags!.contains(tag)) {
                  return 'you already entered that';
                }
                return null;
              },
              inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
                return ((context, sc, tags, onTagDelete) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: tec,
                      focusNode: fn,
                      decoration: InputDecoration(
                        isDense: true,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 3.0,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 3.0,
                          ),
                        ),
                        helperStyle: const TextStyle(
                          color: Colors.blue,
                        ),
                        hintText: _controller.hasTags ? '' : "Enter tags...",
                        errorText: error,
                        prefixIconConstraints:
                        BoxConstraints(maxWidth: _distanceToField * 0.74),
                        prefixIcon: tags.isNotEmpty
                            ? SingleChildScrollView(
                          controller: sc,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                              children: tags.map((String tag) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20.0),
                                    ),
                                    color: Colors.blue,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        child: Text(
                                          tag,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        onTap: () {
                                          //print("$tag selected");
                                        },
                                      ),
                                      const SizedBox(width: 4.0),
                                      InkWell(
                                        child: const Icon(
                                          Icons.cancel,
                                          size: 14.0,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          onTagDelete(tag);
                                        },
                                      )
                                    ],
                                  ),
                                );
                              }).toList()),
                        )
                            : null,
                      ),
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                    ),
                  );
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                _controller.clearTags();
              },
              child: const Text('CLEAR TAGS'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget> [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );
                        _formKey.currentState!.save(); //guarda tots els elements del formulari
                        if (newActivity['class'] == "Project"){ //class = project
                          newActivity['name'] = activityName;
                          newActivity['id'] = Random().nextInt(99999999) + 10;
                          newActivity['class'] = typeSelected;
                          newActivity['tags'] = _controller.getTags;
                          newActivity['father'] = id;
                        }
                        else{ //class = task
                          newActivity['name'] = activityName;
                          newActivity['id'] = Random().nextInt(99999999) + 10;
                          newActivity['class'] = typeSelected;
                          newActivity['tags'] = _controller.getTags;
                          newActivity['father'] = id;
                        }
                        addActivity(newActivity);
                        Navigator.of(context).pop();
                        typeSelected = "Project";
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }
}

class DropdownType extends StatefulWidget {
  final ValueChanged<String?>? onChanged;
  const DropdownType({super.key, required this.onChanged});

  @override
  State<DropdownType> createState() => _DropdownTypeState();
}

class _DropdownTypeState extends State<DropdownType> {
  String dropdownValue = type.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
          typeSelected = dropdownValue;
        });
      },
      items: type.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      //onChanged: widget.onChanged,
    );
  }
}