import 'package:flutter/material.dart';
import 'package:timetracker_app/page_activities.dart';
import 'package:timetracker_app/requests.dart';
import 'package:timetracker_app/tree.dart' hide getTree;

class PageTask extends StatefulWidget {
  @override
  int idDaddy;

  PageTask(this.idDaddy);

  @override
  _PageTaskState createState() => _PageTaskState();
}

class _PageTaskState extends State<PageTask> {
  String projectFather = "root";
  Map<String, int> projectsFather = new Map<String, int>();

  final name = TextEditingController();
  final tags = TextEditingController();
  late Future<Tree> futureTree;

  late int idDaddy;
  @override
  void initState() {
    idDaddy = widget.idDaddy;
    futureTree = getTree(idDaddy);
    futureTree.then((Tree tree) => projectFather = tree.getRootName());
    futureTree
        .then((Tree tree) => (tree.getProjectsNamesAndIds(projectsFather))
            .then((names) => projectsFather = names))
        .then((value) => _refresh());
  }

  void _refresh() async {
    setState(() {});
  }

  @override
  void dispose() {
    name.dispose();
    tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time Tracker"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              while (Navigator.of(context).canPop()) {
                print("pop");
                Navigator.of(context).pop();
              }
              PageActivities(0);
            }
          ),
        ],
      ),
      body: Container(
        child: Column(children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                'New Task',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'name',
            ),
            controller: name,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'tag 1, tag 2, tag 3...',
            ),
            controller: tags,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30.0),
              child: Text("Add to:"),
            ),
            DropdownButton(
              value: idDaddy,
              items: projectsFather
                  .map((project, id) {
                    return MapEntry(
                        project,
                        DropdownMenuItem<int>(
                          value: id,
                          child: Text(project),
                        ));
                  })
                  .values
                  .toList(),
              onChanged: (int? newValue) {
                setState(() {
                  idDaddy = newValue!;
                });
              }
            ),
          ],
        ),
        Row(mainAxisSize: MainAxisSize.min, children: [
          ElevatedButton(
            onPressed: () {
              createChild(idDaddy, name.text,
                  (tags.text).replaceAll(RegExp(r" "), ""), "task");
              Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (context) => PageActivities(0),
              ));
            },
            child: const Text('Create',
                style: TextStyle(
                  fontSize: 25,
                )
            ),
          )
        ])
      ])),
    );
  }
}
