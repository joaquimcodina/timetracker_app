import 'package:timetracker_app/tree.dart';
import 'package:flutter/material.dart';

class PageActivities extends StatefulWidget {
  const PageActivities({super.key});

  @override
  _PageActivitiesState createState() => _PageActivitiesState();
}

//S'encarrega de fer que es mostrin les dades.
//Quan l'estat canvii, la pàgina es tornarà a dibuixar automàticament
//amb les dades nvoes.
class _PageActivitiesState extends State<PageActivities> {
  late Tree tree;

  @override
  void initState() {
    super.initState();
    tree = getTree();
  }

  //Dibuixa una vista de llista els elements de
  //la qual són els fills de l'arbre
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tree.root.name),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.home),
              onPressed: () {}
            // TODO go home page = root
          ),
          //TODO other actions
        ],
      ),
      body: ListView.separated(
        // it's like ListView.builder() but better
        // because it includes a separator between items
        padding: const EdgeInsets.all(16.0),
        itemCount: tree.root.children.length,
        itemBuilder: (BuildContext context, int index) =>
            _buildRow(tree.root.children[index], index),
        separatorBuilder: (BuildContext context, int index) =>
        const Divider(),
      ),
    );
  }

  Widget _buildRow(Activity activity, int index) {
    String strDuration = Duration(seconds: activity.duration)
        .toString()
        .split('.')
        .first;
    // split by '.' and taking first element of resulting list
    // removes the microseconds part
    assert (activity is Project || activity is Task);
    if (activity is Project) {
      return ListTile(
        title: Text('${activity.name}'),
        trailing: Text('$strDuration'),
        onTap: () => {},
        // TODO, navigate down to show children tasks and projects
      );
    } else {
      Task task = activity as Task;
      Widget trailing;
      trailing = Text('$strDuration');
      return ListTile(
        title: Text('${activity.name}'),
        trailing: trailing,
        onTap: () => {},
        // TODO, navigate down to show intervals
        onLongPress: () {},
        // TODO start/stop counting the time for this task
      );
    }
  }
}