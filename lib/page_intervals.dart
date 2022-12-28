import 'package:flutter/material.dart';
import 'package:timetracker_app/tree.dart' as Tree hide getTree;
// to avoid collision with an Interval class in another library
import 'package:timetracker_app/requests.dart';
// to avoid collision with an Interval class in another library
import 'dart:async';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PageIntervals extends StatefulWidget {
  int id;
  PageIntervals(this.id);

  @override
  _PageIntervalsState createState() => _PageIntervalsState();
}

class _PageIntervalsState extends State<PageIntervals> {
  late int id;
  late Future<Tree.Tree> futureTree;

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Tree.Tree>(
      future: futureTree,
      //this makes the tree of children, when available, go into snapshot.data
      builder: (context, snapshot){
        //anonymous function
        if(snapshot.hasData){
          int numChildren = snapshot.data!.root.children.length;
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data!.root.name),
            ),
            body: ListView.separated(
              //it's like ListView.builder() but better because it includes a separator between items
              padding: const EdgeInsets.all(16.0),
              itemCount: numChildren,
              itemBuilder: (BuildContext context, int index) => _buildRow(snapshot.data!.root.children[index], index),
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          );
        }
        else if (snapshot.hasError){
          return Text("${snapshot.error}");
        }
        return Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: const Center(
            child: CircularProgressIndicator(),
          )
        );
      },
    );
  }

  Widget _buildRow(Tree.Interval interval, int index) {
    String strDuration = Duration(seconds: interval.duration).toString().split('.').first;
    String strInitialDate = interval.initialDate.toString().split('.')[0];
    // this removes the microseconds part
    String strFinalDate = interval.finalDate.toString().split('.')[0];
    return ListTile(
      leading: const Icon(MdiIcons.alphaICircle),
      title: Text('from $strInitialDate to $strFinalDate'),
      trailing: Text(strDuration),
    );
  }

  void _activateTimer() {
    _timer = Timer.periodic(const Duration(seconds: periodeRefresh), (Timer t) {
      futureTree = getTree(id);
      setState(() {});
    });
  }

  @override
  void dispose() {
    // "The framework calls this method when this State object will never build again" therefore when going up
    _timer.cancel();
    super.dispose();
  }
}