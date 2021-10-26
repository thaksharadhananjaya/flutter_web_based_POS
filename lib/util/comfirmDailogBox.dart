import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ComfirmDailogBox extends StatefulWidget {
  final String title, descriptions;
  final Widget yesButton;

  const ComfirmDailogBox({Key key, this.title, this.descriptions, this.yesButton}) : super(key: key);

  @override
  _ComfirmDailogBoxState createState() => _ComfirmDailogBoxState();
}

class _ComfirmDailogBoxState extends State<ComfirmDailogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }
  contentBox(context){
    return Stack(
      children: <Widget>[
        Container(
          width: 360,
          padding: EdgeInsets.only(left: Constants.padding,top: Constants.avatarRadius
              + Constants.padding, right: Constants.padding,bottom: Constants.padding
          ),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(color: Colors.black,offset: Offset(0,10),
                    blurRadius: 10
                ),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AutoSizeText(widget.title,style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),maxLines: 1,),
              SizedBox(height: 15,),
              Text(widget.descriptions,style: TextStyle(fontSize: 18, color: Colors.black45,fontWeight: FontWeight.w500),textAlign: TextAlign.center, ),
              SizedBox(height: 30,),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.yesButton,
                    SizedBox(width: 20,),
                    Container(
                      height: 32,
                      width: 75,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.blue
                      ),
                      child: FlatButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: Text("No",style: TextStyle(fontSize: 17, color: Colors.white),)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: Constants.avatarRadius,
            child: CircleAvatar(
              backgroundColor: Colors.red,
              radius: 45,
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                  child: Icon(Icons.delete,color: Colors.white, size: 48,)
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Constants {
  Constants._();

  static const double padding = 16.0;
  static const double avatarRadius = 50.0;
}