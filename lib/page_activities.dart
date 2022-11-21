import 'package:timetracker_app/tree.dart';
import 'package:flutter/material.dart';
import 'package:timetracker_app/tree.dart' as Tree;

// to avoid collision with an Interval class in another library
class PageActivities extends StatefulWidget {
  const PageActivities({super.key});

  @override
  _PageActivitiesState createState() => _PageActivitiesState();
}

//S'encarrega de fer que es mostrin les dades.
//Quan l'estat canvii, la pàgina es tornarà a dibuixar automàticament
//amb les dades nvoes.
class _PageActivitiesState extends State<PageActivities> {
  late Tree.Tree tree;

  @override
  void initState() {
    super.initState();
    tree = Tree.getTreeTask();
    // the root is a task and the children its intervals
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
              onPressed: () {} // TODO go home page = root
          ),
          //TODO other actions
        ],
      ),
      body: ListView.separated(
        // it's like ListView.builder() but better because it includes a
        // separator between items
        padding: const EdgeInsets.all(16.0),
        itemCount: tree.root.children.length, // number of intervals
        itemBuilder: (BuildContext context, int index) =>
            _buildRow(tree.root.children[index], index),
        separatorBuilder: (BuildContext context, int index) =>
        const Divider(),
      ),
    );
  }

  Widget _buildRow(Tree.Interval interval, int index) {
    String strDuration = Duration(seconds: interval.duration).toString().split('.').first;
    String strInitialDate = interval.initialDate.toString().split('.')[0];
    // this removes the microseconds part
    String strFinalDate = interval.finalDate.toString().split('.')[0];
    return ListTile(
      title: Text('from ${strInitialDate} to ${strFinalDate}'),
      trailing: Text('$strDuration'),
    );
  }
}