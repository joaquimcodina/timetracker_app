import 'package:timetracker_app/page_intervals.dart';
import 'package:flutter/material.dart';
import 'package:timetracker_app/tree.dart' hide getTree;
// the old getTree()
import 'package:timetracker_app/requests.dart';
// has the new getTree() that sends an http request to the server
import 'dart:async';

class PageActivities extends StatefulWidget {
  int id;
  PageActivities(this.id);

  @override
  _PageActivitiesState createState() => _PageActivitiesState();
}

//S'encarrega de fer que es mostrin les dades.
//Quan l'estat canvii, la pàgina es tornarà a dibuixar automàticament
//amb les dades nvoes.
class _PageActivitiesState extends State<PageActivities> {
  late int id;
  late Future<Tree> futureTree;

  late Timer _timer;
  static const int periodeRefresh = 6;
  // better a multiple of periode in TimeTracker, 2 seconds

  @override
  void initState() {
    super.initState();
    id = widget.id;
    futureTree = getTree(id);
    _activateTimer();
  }

  //future with listview
  //https://medium.com/nonstopio/flutter-future-builder-with-list-view-builder-d7212314e8c9
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree>(
      future: futureTree,
      //this makes the tree of children, when available, go intro snapshop.data
      builder: (context, snapshot) {
        //anonymous function
        if(snapshot.hasData){
          return Scaffold(
            appBar: AppBar(
              title: snapshot.data!.root.id == 0 ? const Text("TimeTracker") : Text(snapshot.data!.root.name),
              actions: <Widget>[
                IconButton(icon: const Icon(Icons.home),
                  onPressed: () {
                    while(Navigator.of(context).canPop()){
                      print("pop");
                      Navigator.of(context).pop();
                    }
                    PageActivities(0);
                  }
                ),
              ],
            ),
            body: ListView.separated(
              //it's like ListView.builder() but better because it includes a separator between items
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.root.children.length,
              itemBuilder: (BuildContext context, int index) => _buildRow(snapshot.data!.root.children[index], index),
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          );
        }
        else if (snapshot.hasError){
          return Text("${snapshot.error}");
        }
        //By default, show a progress indicator
        return Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: const Center(
            child: CircularProgressIndicator(),
          )
        );
      }
    );
  }

  Widget _buildRow(Activity activity, int index) {
    String strDuration = Duration(seconds: activity.duration).toString().split('.').first;
    // split by '.' and taking first element of resulting list
    // removes the microseconds part
    assert (activity is Project || activity is Task);
    if (activity is Project) {
      return ListTile(
        title: Text(activity.name),
        trailing: Text(strDuration),
        onTap: () => _navigateDownActivities(activity.id),
      );
    }
    else {
      Task task = activity as Task;
      Widget trailing;
      trailing = Text(strDuration);

      return ListTile(
        title: Text(task.name),
        trailing: trailing,
        onTap: () => _navigateDownIntervals(task.id),
        onLongPress: () {
          if (task.active){
            stop(task.id);
            _refresh();
          }
          else {
            start(task.id);
            _refresh();
          }
        },
      );
    }
  }

  void _navigateDownActivities(int childId) {
    _timer.cancel();
    // we can not do just _refresh() because then the up arrow doesnt appear in the appbar
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => PageActivities(childId),
    )).then((var value) {
      _activateTimer();
      _refresh();
    });
    //https://stackoverflow.com/questions/49830553/how-to-go-back-and-refresh-the-previous-page-in-flutter?noredirect=1&lq=1
  }

  void _navigateDownIntervals(int childId) {
    _timer.cancel();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (context) => PageIntervals(childId),
    )).then((var value) {
      _activateTimer();
      _refresh();
    });
  }

  void _refresh() async {
    futureTree = getTree(id); // to be used in build()
    setState(() {});
  }

  void _activateTimer() {
    _timer = Timer.periodic(const Duration(seconds: periodeRefresh), (Timer t) {
      futureTree = getTree(id);
      setState(() {});
    });
  }

  @override
  void dispose() {
    // "The framework calls this method when this State object will never build again"
    // therefore when going up
    _timer.cancel();
    super.dispose();
  }
}