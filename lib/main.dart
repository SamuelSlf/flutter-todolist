import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/Item.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'TODO App', theme: ThemeData(), home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var taskController = TextEditingController();
  FocusNode myFocusNode;
  bool adding = false;

  _HomePageState() {
    load();
  }

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();

    myFocusNode.addListener(() {
      if (!myFocusNode.hasFocus)
        setState(() {
          adding = false;
        });
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  void setText() {
    myFocusNode.requestFocus();
  }

  void addItem() {
    widget.items.add(Item(title: taskController.text, done: false));

    taskController.text = "";
    myFocusNode.unfocus();

    save();
  }

  void removeItem(int index) {
    widget.items.removeAt(index);
    save();
  }

  void save() async {
    var preferences = await SharedPreferences.getInstance();
    await preferences.setString('todolist', jsonEncode(widget.items));
  }

  Future load() async {
    var preferences = await SharedPreferences.getInstance();
    var data = preferences.getString('todolist');

    if (data != null) {
      Iterable dataDecoded = jsonDecode(data);

      List<Item> result = dataDecoded.map((a) => Item.fromJson(a)).toList();

      setState(() {
        widget.items = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextFormField(
            controller: taskController,
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            focusNode: myFocusNode,
            decoration: InputDecoration(
              labelText: "Todo List",
              labelStyle: TextStyle(
                color: Colors.white,
              ),
            ),
            onFieldSubmitted: (term) {
              addItem();
            },
          ),
          actions: <Widget>[
            Visibility(
              child: IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  myFocusNode.unfocus();
                },
              ),
              visible: adding,
            ),
            Visibility(
              child: IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  addItem();
                },
              ),
              visible: adding,
            )
          ],
        ),
        body: ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = widget.items[index];
            return Dismissible(
              child: CheckboxListTile(
                title: Text(item.title),
                key: Key(item.title),
                value: item.done,
                onChanged: (value) {
                  setState(() {
                    item.done = value;
                    save();
                  });
                },
              ),
              key: Key(item.title),
              background: Container(
                color: Colors.red.withOpacity(0.8),
              ),
              onDismissed: (direction) {
                removeItem(index);
              },
            );
          },
        ),
        floatingActionButton: Visibility(
          visible: !adding,
          child: FloatingActionButton(
            onPressed: () {
              FocusScope.of(context).requestFocus(myFocusNode);

              setState(() {
                adding = true;
              });
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.blue,
          ),
        ));
  }
}
