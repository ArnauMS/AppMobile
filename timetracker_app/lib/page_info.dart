import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetracker_app/page_activities.dart';
import 'package:timetracker_app/tree.dart';

class PageInfo extends StatefulWidget {
  Activity activity;
  PageInfo(this.activity);

  @override
  _PageInfoState createState() => _PageInfoState(activity);
}

class _PageInfoState extends State<PageInfo> {
  Activity activity;
  _PageInfoState(this.activity);

  @override
  Widget build(BuildContext context) {
    String initDate = '';
    String finDate = '';
    String tags = '';

    initDate = activity?.initialDate != null
        ? 'Initial date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(activity.initialDate!)}'
        : "Initial date: not started";

    finDate = activity?.finalDate != null
        ? 'Final date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(activity.finalDate!)}'
        : "Final date: not finished";

    tags = activity.tags != null
        ? 'Tags: ${activity.tags.join(", ")}'
        : "Tags: null";

    return Scaffold(
      appBar: AppBar(
        title: Text(activity.name == "root" ? "Time Tracker" : activity.name),
        actions: <Widget>[
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
      body: Container(
          child: Column(children: <Widget>[
        Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
              child: Text(
                'Name: ' + activity.name,
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
              child: Text(
                tags,
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
              child: Text(
                initDate,
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
              child: Text(
                finDate,
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(30, 15, 15, 15),
              child: Text(
                "Duration: " +
                    Duration(seconds: activity.duration)
                        .toString()
                        .split('.')
                        .first,
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ])),
    );
  }
}
