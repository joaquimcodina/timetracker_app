import 'package:timetracker_app/page_intervals.dart';
import 'package:flutter/material.dart';
import 'package:timetracker_app/tree.dart' hide getTree;
// the old getTree()
import 'package:timetracker_app/requests.dart';
// has the new getTree() that sends an http request to the server
import 'dart:async';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timetracker_app/add_activity.dart';

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
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(context: context, delegate: SearchByTag());
                  },
                ),
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
            body: Column (
              children: <Widget>[
                snapshot.data!.root.father.toString().split("\t")[0] != "" ?
                Row(
                    children: <Widget>[
                      Text('Father: ${snapshot.data!.root.father.toString().split("\t")[0]}\n'),
                    ]
                ) : Row(),
                snapshot.data!.root.initialDate!=null ? Row(
                    children: <Widget>[
                      Text('Initial Date: ${snapshot.data!.root.initialDate}\n'),
                    ]
                ) : Row(),
                snapshot.data!.root.finalDate!=null ?
                Row(
                    children: <Widget>[
                      Text('Final Date: ${snapshot.data!.root.finalDate}\n'),
                    ]
                ) : Row(),
                snapshot.data!.root.duration!=0 ?
                Row(
                    children: <Widget>[
                      Text('Duration: ${snapshot.data!.root.duration} seconds\n'),
                    ]
                ) : Row(),
                snapshot.data!.root.tags.isNotEmpty ?
                Row(
                    children: <Widget>[
                      Text('Tags: ${snapshot.data!.root.tags}'),
                    ]
                ) : Row(),
                Expanded(
                  child: ListView.separated(
                    //it's like ListView.builder() but better because it includes a separator between items
                    padding: const EdgeInsets.all(16.0),
                    itemCount: snapshot.data!.root.children.length,
                    itemBuilder: (BuildContext context, int index) => _buildRow(snapshot.data!.root.children[index], index),
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                  ),
                )
              ]
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (context) => AddActivity(father: snapshot.data!.root.name, id: snapshot.data!.root.id),
                ));
              },
              elevation: 15.0,
              child: const Icon(Icons.add),
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
      bool isActive = activity.active;
      return ListTile(
        leading: const Icon(MdiIcons.alphaPCircle),
        title: Text(activity.name),
        subtitle: Text("Tags ${activity.tags}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: () {}, icon : isActive ? const Icon(MdiIcons.clock, color: Colors.blue) : const Icon(null)),
            Text(strDuration)
          ],
        ),
        onTap: () => _navigateDownActivities(activity.id),
      );
    }
    else {
      Task task = activity as Task;
      Widget trailing;
      trailing = Text(strDuration);
      bool isActive = task.active;

      return ListTile(
        leading: const Icon(MdiIcons.alphaTCircle),
        title: Text(task.name),
        subtitle: Text("Tags ${task.tags}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                if (isActive) {
                  setState(() {
                    isActive = false;
                  });
                  stop(task.id);

                } else {
                  setState(() {
                    isActive = true;
                  });
                  start(task.id);
                }
                _refresh();
              },
              icon: isActive ? const Icon(MdiIcons.pause) : const Icon(MdiIcons.play),
            ),
            isActive ? const Icon(MdiIcons.clock, color: Colors.blue) : const Icon(null),
            trailing,
          ],
        ),
        onTap: () {
          _navigateDownIntervals(task.id);
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

class SearchByTag extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        if (query.isEmpty) {
          close(context, '');
        } else {
          query = '';
          showSuggestions(context);
        }
      },
    )
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, ''),
  );

  @override
  Widget buildResults(BuildContext context) => FutureBuilder<Tree> (
    future: getTree(int.parse(query)),
    builder: (context, snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return const Center(child: CircularProgressIndicator());
        default:
          if (snapshot.hasError) {
            return Container (
              color: Colors.white,
              alignment: Alignment.center,
              child: const Text (
                'Something went wrong!',
                style: TextStyle(fontSize: 28, color: Colors.black),
              )
            );
          }
          else{
            return buildResultSuccess(snapshot.data!);
          }
      }
    },
  );

  @override
  Widget buildSuggestions(BuildContext context) => FutureBuilder<List<String>>(
    future: searchByTag(query: query),
    builder: (context, snapshot) {
      if (query.isEmpty) return buildNotSuggestions();
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return const Center(child: CircularProgressIndicator());
        default:
          if(snapshot.hasError || snapshot.data!.isEmpty){
            return buildNotSuggestions();
          }
          else{
            return buildSuggestionsSuccess(snapshot.data!);
          }
      }
    },
  );

  Widget buildNotSuggestions() => const Center(
      child: Text(
        'No results!',
        style: TextStyle(fontSize: 28, color: Colors.black),
      )
  );

  Widget buildSuggestionsSuccess(List<String> suggestions) => ListView.builder(
    itemCount: suggestions.length,
    itemBuilder: (context, index) {
      final suggestion = suggestions[index];
      List<String> data = suggestion.toString().split(',');

      return ListTile(
        onTap: () {
          query = data[0];
          showResults(context);
        },
        leading: data[2]=='project' ? const Icon(MdiIcons.alphaPCircle) : const Icon(MdiIcons.alphaTCircle),
        title: RichText(
          text: TextSpan(
            text: data[1],
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      );
    },
  );

  Widget buildResultSuccess(Tree tree) => ListView(
    children: [
      Column (
          children: <Widget>[
            tree.root.father.toString().split("\t")[0] != "" ?
            Row(
                children: <Widget>[
                  Text('Father: ${tree.root.father.toString().split("\t")[0]}\n'),
                ]
            ) : Row(),
            tree.root.initialDate!=null ? Row(
                children: <Widget>[
                  Text('Initial Date: ${tree.root.initialDate}\n'),
                ]
            ) : Row(),
            tree.root.finalDate!=null ?
            Row(
                children: <Widget>[
                  Text('Final Date: ${tree.root.finalDate}\n'),
                ]
            ) : Row(),
            tree.root.duration!=0 ?
            Row(
                children: <Widget>[
                  Text('Duration: ${tree.root.duration} seconds\n'),
                ]
            ) : Row(),
            tree.root.tags.isNotEmpty ?
            Row(
                children: <Widget>[
                  Text('Tags: ${tree.root.tags}'),
                ]
            ) : Row(),
            /*Expanded(
              child: ListView.separated(
                //it's like ListView.builder() but better because it includes a separator between items
                padding: const EdgeInsets.all(16.0),
                itemCount: tree.root.children.length,
                itemBuilder: (BuildContext context, int index) => listChild(tree.root.children[index], index),
                separatorBuilder: (BuildContext context, int index) => const Divider(),
              ),
            )*/
          ]
      ),
    ],
  );

  Widget listChild(Activity activity, int index) {
    String strDuration = Duration(seconds: activity.duration).toString().split('.').first;
    assert (activity is Project || activity is Task);
    if (activity is Project) {
      return ListTile(
        leading: const Icon(MdiIcons.alphaPCircle),
        title: Text(activity.name),
        subtitle: Text("Tags ${activity.tags}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(strDuration)
          ],
        ),
      );
    }
    else {
      Task task = activity as Task;
      Widget trailing;
      trailing = Text(strDuration);

      return ListTile(
        leading: const Icon(MdiIcons.alphaTCircle),
        title: Text(task.name),
        subtitle: Text("Tags ${task.tags}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            trailing,
          ],
        ),
      );
    }
  }
}