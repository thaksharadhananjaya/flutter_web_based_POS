import 'package:flutter/material.dart';
import 'package:smart_pos/pos.dart';
import 'package:smart_pos/report.dart';
import 'package:smart_pos/return.dart';

import 'inventory.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: screenHeight,
            width: 80,
            color: Colors.white,
            child: Column(
              children: [
                Column(
                  children: [
                    Container(
                        width: 80,
                        height: 100,
                        color: index == 0
                            ? Colors.grey.withOpacity(0.7)
                            : Colors.white,
                        child: FlatButton.icon(
                            onPressed: () {
                              setState(() {
                                index = 0;
                              });
                            },
                            padding: EdgeInsets.all(0),
                            icon: Icon(
                              Icons.home,
                              size: 40,
                            ),
                            label: Text(""))),
                    Container(
                        width: 80,
                        height: 100,
                        color: index == 1
                            ? Colors.grey.withOpacity(0.7)
                            : Colors.white,
                        child: FlatButton.icon(
                            onPressed: () {
                              setState(() {
                                index = 1;
                              });
                            },
                            padding: EdgeInsets.all(0),
                            icon: Icon(
                              Icons.store,
                              size: 40,
                            ),
                            label: Text(""))),
                    Container(
                        width: 80,
                        height: 100,
                        color: index == 2
                            ? Colors.grey.withOpacity(0.7)
                            : Colors.white,
                        child: FlatButton.icon(
                            onPressed: () {
                              setState(() {
                                index = 2;
                              });
                            },
                            padding: EdgeInsets.all(0),
                            icon: Icon(Icons.insert_chart, size: 40),
                            label: Text(""))),
                    Container(
                        width: 80,
                        height: 100,
                        color: index == 3
                            ? Colors.grey.withOpacity(0.7)
                            : Colors.white,
                        child: FlatButton.icon(
                          onPressed: () {
                            setState(() {
                              index = 3;
                            });
                          },
                          padding: EdgeInsets.all(0),
                          icon: Icon(Icons.assignment_returned, size: 40),
                          label: Text(""),
                        )),
                  ],
                ),
              ],
            ),
          ),
          index == 0
              ? POS()
              : (index == 1 ? Inventory() : (index == 2 ? Report() : Return())),
        ],
      ),
    );
  }
}
