import 'package:flutter/material.dart';
import 'package:timetracker_app/page_activities.dart';
import 'package:timetracker_app/requests.dart';
import 'package:timetracker_app/tree.dart' hide getTree;

class PageSearch extends StatefulWidget {
  PageSearch();

  @override
  _PageSearchState createState() => _PageSearchState();
}

class _PageSearchState extends State<PageSearch> {
  late String tag = "";
  String activitiesString = "";
  List<String> activities = [];
  List<String> tag_info = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'search a tag',
            ),
            onChanged: (String input) {
              tag = input;
            },
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                searchByTag(tag).then((String value) {
                  activitiesString = value;
                  activities = activitiesString.split(",");
                  Future<List<String>> result = getTagInfo(activities); //ninini
                  result.then((res) {
                    tag_info = res;
                    setState(() {});
                  });
                });
              }),
          IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                while (Navigator.of(context).canPop()) {
                  print("pop");
                  Navigator.of(context).pop();
                }
                PageActivities(0);
              }),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: activities.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: new ListTile(
              title: Text(tag_info[index]),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
