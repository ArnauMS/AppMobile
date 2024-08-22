// see Serializing JSON inside model classes in
// https://flutter.dev/docs/development/data-and-backend/json

import 'package:intl/intl.dart';
import 'package:timetracker_app/requests.dart';
import 'dart:convert' as convert;

final DateFormat _dateFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");

abstract class Activity {
  late int id;
  late String name;
  late List tags;
  DateTime? initialDate;
  DateTime? finalDate;
  late int duration;
  List<dynamic> children = List<dynamic>.empty(growable: true);

  Activity.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        initialDate = json['startTime'] == null || json['startTime'] == ""
            ? null
            : _dateFormatter.parse(json['startTime']),
        finalDate = json['endTime'] == null || json['endTime'] == ""
            ? null
            : _dateFormatter.parse(json['endTime']),
        duration = json['duration'] != null ? (json['duration']).round() : 0,
        tags = json['tags'] != null ? json['tags'] : "";
}

class Project extends Activity {
  Project.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    if (json.containsKey('children')) {
      // json has only 1 level because depth=1 or 0 in time_tracker
      for (Map<String, dynamic> jsonChild in json['children']) {
        if (jsonChild['isTask'] == false) {
          children.add(Project.fromJson(jsonChild));
          // condition on key avoids infinite recursion
        } else if (jsonChild['isTask'] == true) {
          children.add(Task.fromJson(jsonChild));
        } else {
          assert(false);
        }
      }
    }
  }
}

class Task extends Activity {
  late bool active;
  Task.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    active = json['active'];
    if (json.containsKey('timeRanges')) {
      for (Map<String, dynamic> jsonChild in json['timeRanges']) {
        children.add(Interval.fromJson(jsonChild));
      }
    }
  }
}

class Interval {
  late int id;
  DateTime? initialDate;
  DateTime? finalDate;
  late int duration;
  late bool active;

  Interval.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        initialDate = json['startTime'] == null
            ? null
            : _dateFormatter.parse(json['startTime']),
        finalDate = json['stopTime'] == null
            ? null
            : _dateFormatter.parse(json['stopTime']),
        duration = (json['duration']).round(),
        active = json['stopTime'] == null ? true : false;
}

Future<List<String>> getTagInfo(List<String> ids) async {
  List<String> result = [];
  for (int i = 0; i < ids.length; i++) {
    Future<Tree> futureTree = getTree(int.parse(ids[i]));
    Tree tree = await futureTree;
    result.add(tree.root.name +
        " => " +
        Duration(seconds: tree.root.duration).toString().split('.').first);
  }
  return result;
}

class Tree {
  late Activity root;

  Tree(Map<String, dynamic> dec) {
    // 1 level tree, root and children only, root is either Project or Task. If Project
    // children are Project or Task, that is, Activity. If root is Task, children are Interval.
    if (dec['isTask'] == false) {
      root = Project.fromJson(dec);
    } else {
      root = Task.fromJson(dec);
    }
  }

  String getRootName() {
    return root.name;
  }

  Future<Map<String, int>> getProjectsNamesAndIds(Map<String, int> aux) async {
    if (root is Project) {
      aux[root.name] = root.id;
      for (int i = 0; i < root.children.length; i++) {
        Future<Tree> futureTree = getTree(root.children[i].id);
        Tree tree = await futureTree;
        Future<Map<String, int>> futureNames = tree.getProjectsNamesAndIds(aux);
        aux = await futureNames;
      }
    }
    return aux;
  }
}

//Tree getTree() {
//  String strJson = "{"
//      "\"name\":\"root\", \"class\":\"project\", \"id\":0, \"initialDate\":\"2020-09-22 16:04:56\", \"finalDate\":\"2020-09-22 16:05:22\", \"duration\":26,"
//      "\"activities\": [ "
//      "{ \"name\":\"software design\", \"class\":\"project\", \"id\":1, \"initialDate\":\"2020-09-22 16:05:04\", \"finalDate\":\"2020-09-22 16:05:16\", \"duration\":16 },"
//      "{ \"name\":\"software testing\", \"class\":\"project\", \"id\":2, \"initialDate\": null, \"finalDate\":null, \"duration\":0 },"
//      "{ \"name\":\"databases\", \"class\":\"project\", \"id\":3,  \"finalDate\":null, \"initialDate\":null, \"duration\":0 },"
//      "{ \"name\":\"transportation\", \"class\":\"task\", \"id\":6, \"active\":false, \"initialDate\":\"2020-09-22 16:04:56\", \"finalDate\":\"2020-09-22 16:05:22\", \"duration\":10, \"intervals\":[] }"
//      "] "
//      "}";
//  Map<String, dynamic> decoded = convert.jsonDecode(strJson);
//  Tree tree = Tree(decoded);
//  return tree;
//}

testLoadTree() async {
  Future<Tree> futureTree = getTree(0); // getTree();
  Tree tree = await futureTree;
  print("root name ${tree.root.name}, duration ${tree.root.duration}");
  for (Activity act in tree.root.children) {
    print("child name ${act.name}, duration ${act.duration}");
  }
}

Tree getTreeTask() {
  String strJson = "{"
      "\"name\":\"transportation\",\"class\":\"task\", \"id\":6, \"active\":false, \"initialDate\":\"2020-09-22 13:36:08\", \"finalDate\":\"2020-09-22 13:36:34\", \"duration\":10,"
      "\"intervals\":["
      "{\"class\":\"interval\", \"id\":7, \"active\":false, \"initialDate\":\"2020-09-22 13:36:08\", \"finalDate\":\"2020-09-22 13:36:14\", \"duration\":6},"
      "{\"class\":\"interval\", \"id\":8, \"active\":false, \"initialDate\":\"2020-09-22 13:36:30\", \"finalDate\":\"2020-09-22 13:36:34\", \"duration\":4}"
      "]}";
  Map<String, dynamic> decoded = convert.jsonDecode(strJson);
  Tree tree = Tree(decoded);
  return tree;
}

void main() {
  testLoadTree();
}
