import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:timewarpsoc/ui_beauty.dart';

/* Top View holds the logo and a current time view */

class TopView extends StatefulWidget { // Stateful keeps track of an updated clock count
  const TopView({Key key}) : super(key: key);

  static const TextStyle logoScript = TextStyle( fontSize: 9, color: Color(0xFF1a495e), decoration: TextDecoration.none, fontFamily: 'IMFellDoublePicaSC');
  static const TextStyle bigTimeScript = TextStyle( fontSize: 13, color: Color(0xFF14ff9c), decoration: TextDecoration.none, fontFamily: 'JosefinSlab');
  static const TextStyle smallTimeScript = TextStyle( fontSize: 7, color: Color(0xFF14ff9c), decoration: TextDecoration.none, fontFamily: 'JosefinSlab');
  static const Color bkColor = Color(0xFF16ab9c);

  @override
  _TopView createState() => _TopView();
}

class _TopView extends State<TopView>{
  @override
  Widget build(BuildContext context) {
    return Container (
      color: TopView.bkColor,
      margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
      height: 50,
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.baseline,
        children: <Widget>[
          Expanded(flex: 1, child:
              Text("\nTime\n Warp\n Society\n", style: TopView.logoScript, textAlign: TextAlign.center,)),
          Expanded(flex: 3, child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            Text("12:23:34", style: TopView.bigTimeScript, textAlign: TextAlign.center),
            Text("8-3-20", style: TopView.smallTimeScript, textAlign: TextAlign.center),
            // Text("\n\n where do we go today?", style: TopView.smallTimeScript, textAlign: TextAlign.center),
          ],))
        ],
      ),
    );
  }
}

class BrowseTableView extends StatefulWidget { //
  const BrowseTableView({Key key}) : super(key: key);

  static const Color bkColor = Color(0xFF193947);

  @override
  _BrowseTableView createState() => _BrowseTableView();
}

class _BrowseTableView extends State<BrowseTableView> {
  @override
  Widget build(BuildContext context) {
    return Container (
        color: BrowseTableView.bkColor,
        margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
        height: 285,
        // Insert a list view over here referencing the 'SearchRecord' collection
    );
  }
}

class BottomView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container (
        color: TopView.bkColor,
        margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
        height: 50
    );
  }
}


class HomeVisual extends StatefulWidget {
  const HomeVisual({Key key}) : super(key: key);

  static const Color fullBk = Color(0xFF1a495e);
  static const Color topBk = Color(0xFF16ab9c);
  static const Color midBk = Color(0xFF80c4bd);
  static const Color botBk = Color(0xFF1f78a1);

  @override
  _HomeVisual createState() => _HomeVisual();
}

class _HomeVisual extends State<HomeVisual> {

  @override
  Widget build(BuildContext context) {
    // TODO: if else statement for screen orientation, app needs to change
    return MaterialApp(
      home:
      Container(
        color: HomeVisual.fullBk,
        child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 10)),
              TopView(),
              Padding(padding: EdgeInsets.only(top: 10)),
              BrowseTableView(),
              Padding(padding: EdgeInsets.only(top: 10)),
              BottomView()
            ],
        )
      )
    );
  }
}