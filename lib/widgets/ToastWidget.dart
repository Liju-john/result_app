import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastWidget
{
  static showToast(String message,Color bg)
  {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: bg,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  static showLoaderDialog(BuildContext context,{String loadingText="Loading"}) {
    AlertDialog alert = AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: WillPopScope(
          onWillPop: (){return Future.value(false);},
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(child:SpinKitThreeInOut(color: Colors.pink,),
                ),
                Text(loadingText,style: TextStyle(fontWeight: FontWeight.bold),)
              ],
            ),
          ),
        )
    );
    showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}