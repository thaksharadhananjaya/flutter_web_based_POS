
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'itemReport.dart';
import 'netProfit.dart';

class Report extends StatefulWidget {

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {

  int view=0;


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        view==0?Container(
          height: 5,
        ):Container(
          height: 5,
          width: 40,
          alignment: Alignment.center,
          child: IconButton(
              icon: Icon(Icons.arrow_back,color: Colors.black87,),
              onPressed: (){
                setState(() {
                  view=0;
                });
              }),
        ),
        view==0? Container(
            color: Colors.transparent,
            height: screenHeight-6,
            width: screenWidth-80,
            child:Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: screenHeight/3,
                  width: screenWidth/5,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue[200],
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5
                        )
                      ]
                  ),
                  child: FlatButton.icon(
                    onPressed: (){
                      setState(() {
                        view=1;
                      });
                    },
                    icon: Icon(Icons.store,color: Colors.black87,size: 50,),
                    label: AutoSizeText("Items",
                      style:  GoogleFonts.robotoCondensed(
                          fontSize: 40, fontWeight: FontWeight.w500,
                          color: Colors.black87
                      ), maxLines: 1,
                    ),
                  ),
                ),
                SizedBox(width: 180,),
                Container(
                  height: screenHeight/3,
                  width: screenWidth/5,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green[200],
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5
                        )
                      ]
                  ),
                  child: FlatButton.icon(
                      onPressed: (){
                        setState(() {
                          view=2;
                        });
                      },
                      icon: Icon(Icons.attach_money,color: Colors.black87,size: 50,),
                      label: AutoSizeText("Profit",
                        style:  GoogleFonts.robotoCondensed(
                            fontSize: 40, fontWeight: FontWeight.w500,
                            color: Colors.black87
                        ), maxLines: 1,
                      ),
                  ),
                )
              ],
            )
        ):(view==1? ItemReport():Profit()),
      ],
    );

  }
}



