import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:timewarpsoc/timeline_types.dart';
import 'package:timewarpsoc/db_logic.dart';

class TimelineSegView {
  TimelineSegView({Key key, this.index, this.data}){
    // switch case statement
  }

  final int index;
  final TimelineData data;

  Widget targetWidgetL; // left
  Widget targetWidgetM; // middle
  Widget targetWidgetR; // right
}

class TimelineVisual extends StatefulWidget {
  const TimelineVisual({ Key key }) : super(key: key);

  // Json handling and constructor need to be implemented

  @override
  _TimelineVisual createState() => _TimelineVisual();
}

class _TimelineVisual extends State<TimelineVisual> {
  Widget targetWidgetL; // left
  Widget targetWidgetM; // middle
  Widget targetWidgetR; // right

  @override
  Widget build(BuildContext context) {
    TimelineFirebaseDB db = TimelineFirebaseDB(); // TODO: Access a target database we have stored

    return MaterialApp(
        home:
        ListView.builder(
            itemCount: TimelineFirebaseDB.data.segments.length,
            itemBuilder: (context, index) {
              TimelineSegView segment = TimelineSegView(index: index, data: );

              return
                Container(
                  // color: Color(0xFF2244AA),
                    child: Row(
                        children: <Widget>[
                          segment.targetWidgetL, // targetWidgetL,
                          segment.targetWidgetM,
                          segment.targetWidgetR
                        ]
                    )
                );
            })
    );
  }
}