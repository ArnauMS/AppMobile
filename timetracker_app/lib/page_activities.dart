import 'package:timetracker_app/page_info.dart';
import 'package:timetracker_app/page_project.dart';
import 'package:timetracker_app/page_search.dart';
import 'package:timetracker_app/page_task.dart';
import 'package:timetracker_app/tree.dart' hide getTree;
import 'package:flutter/material.dart';
import 'package:timetracker_app/PageIntervals.dart';
import 'package:timetracker_app/requests.dart';
// has the new getTree() that sends an http request to the server
import 'dart:async';

enum SampleItem { project, task }

class PageActivities extends StatefulWidget {
  int id;

  PageActivities(this.id);

  @override
  _PageActivitiesState createState() => _PageActivitiesState();
}

class _PageActivitiesState extends State<PageActivities> {
  late int id;
  late Future<Tree> futureTree;
  SampleItem? selectedMenu;
  late Timer _timer;
  static const int periodeRefresh = 2;

  @override
  void initState() {
    super.initState();
    id = widget.id;
    futureTree = getTree(id);
    _activateTimer();
  }

  // future with listview
  // https://medium.com/nonstopio/flutter-future-builder-with-list-view-builder-d7212314e8c9
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree>(
      future: futureTree,
      // this makes the tree of children, when available, go into snapshot.data
      builder: (context, snapshot) {
        List list = _sortActivities(snapshot);
        // anonymous function
        if (snapshot.hasData) {
          return Scaffold(
              appBar: AppBar(
                title: Text(snapshot.data!.root.name == "root"
                    ? "Time Tracker"
                    : snapshot.data!.root.name),
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (context) => PageSearch(),
                        ));
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
                // it's like ListView.builder() but better because it includes a separator between items
                padding: const EdgeInsets.all(16.0),
                itemCount: snapshot.data!.root.children.length,
                itemBuilder: (BuildContext context, int index) =>
                    _buildRow(snapshot.data!.root.children[list[index]], index),
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
              floatingActionButton: FloatingActionButton(
                  onPressed: () {},
                  child: PopupMenuButton<SampleItem>(
                      child: const Icon(Icons.add),
                      onSelected: (SampleItem item) {
                        setState(() {
                          selectedMenu = item;
                          print(selectedMenu);
                          if (selectedMenu == SampleItem.project) {
                            Navigator.of(context).push(MaterialPageRoute<void>(
                              builder: (context) => PageProject(id),
                            ));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute<void>(
                              builder: (context) => PageTask(id),
                            ));
                          }
                        });
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<SampleItem>>[
                            const PopupMenuItem<SampleItem>(
                              value: SampleItem.project,
                              child: Text('New Project'),
                            ),
                            const PopupMenuItem<SampleItem>(
                              value: SampleItem.task,
                              child: Text('New Task'),
                            ),
                          ])));
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // By default, show a progress indicator
        return Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }

  Widget _buildRow(Activity activity, int index) {
    String strDuration =
        Duration(seconds: activity.duration).toString().split('.').first;
    // split by '.' and taking first element of resulting list removes the microseconds part
    if (activity is Project) {
      return ListTile(
        leading: Icon(Icons.folder_outlined),
        title: Text('${activity.name}'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (context) => PageInfo(activity),
              ));
            },
          ),
          Text('$strDuration'),
        ]),
        onTap: () => _navigateDownActivities(activity.id),
      );
    } else {
      Task task = activity as Task;
      // at the moment is the same, maybe changes in the future
      Widget trailing;
      trailing = Text('$strDuration',
          style: TextStyle(color: task.active ? Colors.green : Colors.black));

      return ListTile(
        title: Text('${activity.name}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (context) => PageInfo(activity),
                ));
              },
            ),
            IconButton(
              icon: Icon(
                  ((activity as Task).active) ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                _refresh();
                if ((activity as Task).active) {
                  stop(activity.id);
                  _refresh(); // to show immediately that task has started
                } else {
                  start(activity.id);
                  _refresh(); // to show immediately that task has stopped
                }
              },
            ),
            trailing,
          ],
        ),
        onTap: () => _navigateDownIntervals(activity.id),
      );
    }
  }

  void _navigateDownActivities(int childId) {
    _timer.cancel();
    // we can not do just _refresh() because then the up arrow doesnt appear in the appbar
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageActivities(childId),
    ))
        .then((var value) {
      _activateTimer();
      _refresh();
    });
  }

  void _navigateDownIntervals(int childId) {
    _timer.cancel();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
      builder: (context) => PageIntervals(childId),
    ))
        .then((var value) {
      _activateTimer();
      _refresh();
    });
  }

  void _activateTimer() {
    _timer = Timer.periodic(Duration(seconds: periodeRefresh), (Timer t) {
      futureTree = getTree(id);
      setState(() {});
    });
  }

  void _refresh() async {
    futureTree = getTree(id); // to be used in build()
    setState(() {});
  }

  @override
  void dispose() {
    // "The framework calls this method when this State object will never build again"
    // therefore when going up
    _timer.cancel();
    super.dispose();
  }

  List _sortActivities(snapshot) {
    List sortedIds = [0];
    bool added = false;
    for (int i = 1;
        snapshot.hasData && i < snapshot.data.root.children.length;
        i++) {
      int x = 0;
      while ((x < sortedIds.length) && (!added)) {
        if (snapshot.data!.root.children[i].finalDate == null) {
          sortedIds.add(i);
          added = true;
        } else {
          DateTime data = DateTime.parse(
              (snapshot.data!.root.children[i].finalDate).toString());
          if (snapshot.data!.root.children[sortedIds[x]].finalDate == null) {
            sortedIds.insert(x, i);
            added = true;
          } else {
            DateTime data2 = DateTime.parse(
                (snapshot.data!.root.children[sortedIds[x]].finalDate)
                    .toString());
            if (data2.compareTo(data) < 0) {
              sortedIds.insert(x, i);
              added = true;
            }
          }
        }
        x++;
      }
      added = false;
    }
    return sortedIds;
  }
}
