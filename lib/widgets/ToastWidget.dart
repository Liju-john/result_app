import 'package:flutter/material.dart';
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
}