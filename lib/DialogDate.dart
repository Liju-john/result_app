import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogDate extends StatefulWidget {
  @override
  _DialogDateState createState() => _DialogDateState();
}

class _DialogDateState extends State<DialogDate> {
  @override
  Widget build(BuildContext context) {
    return
      Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
      child: Container(
        height: 600.0,
        width: 400.0,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text('Nothing')
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text('Awesome', style: TextStyle(color: Colors.red),),
            ),
            Padding(padding: EdgeInsets.only(top: 50.0)),
            FlatButton(onPressed: (){
              Navigator.of(context).pop();
            },
                child: Text('Got It!', style: TextStyle(color: Colors.purple, fontSize: 18.0),))
          ],
        ),
      ),
    );
  }
}
