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
                      itemCount: numChildren,
                      itemBuilder: (BuildContext context, int index) => _buildRow(snapshot.data!.root.children[index], index),
                      separatorBuilder: (BuildContext context, int index) => const Divider(),
                    ),
                  )
                ]
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
      title: Text('Initial Date: $strInitialDate\nFinal Date: $strFinalDate'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          strFinalDate.contains("null") ? const Icon(MdiIcons.clock, color: Colors.blue) : const Icon(null),
          Text(strDuration),
        ],
      ),
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