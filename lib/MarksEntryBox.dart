import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:result_app/MarksEntryPage.dart';
import 'package:mysql1/mysql1.dart' as mysql;

class MarksEntryBox extends StatefulWidget {
  mysql.MySqlConnection? connection;
  Data? data;
  String ?loginBranch;
  String? currentdb = "",
      nextdb = "",
      mm = "",
      tabname = "",
      markscolname,
      subject,term1,term2,exam;
  int? position;
  String? cat;
  String? cname, section, branch,uid,uname;
  MarksEntryBox(
      {this.connection,
      this.data,
      this.cat,
      this.mm,
      this.position,
      this.tabname,
      this.markscolname,
      this.cname,
      this.currentdb,
      this.subject,
        this.uid,this.uname,this.term1,this.term2,
        this.exam,this.loginBranch});
  @override
  _MarksEntryBoxState createState() => _MarksEntryBoxState(
      this.connection,
      this.data,
      this.cat,
      this.mm,
      this.position,
      this.tabname,
      this.markscolname,
      this.cname,
      this.currentdb,
      this.subject,
      this.uid,this.uname,this.term1,this.term2,
      this.exam,this.loginBranch);
}

class _MarksEntryBoxState extends State<MarksEntryBox> {
  Data? data;
  mysql.MySqlConnection? connection;
  int? position;
  bool readonly=false;
  String? marks, cat, mm, tabname,loginBranch,
      uid,uname,markscolname, cname, currentdb, subject,term1,term2,exam;
  _MarksEntryBoxState(
      this.connection,
      this.data,
      this.cat,
      this.mm,
      this.position,
      this.tabname,
      this.markscolname,
      this.cname,
      this.currentdb,
      this.subject,
      this.uid,
      this.uname,
      this.term1,
      this.term2,this.exam,this.loginBranch);
  TextEditingController? _controller;
  @override
  Widget build(BuildContext context) {
    return row();
  }

  Widget row() {
    if(exam=='term1' && term1=="0")
      readonly=true;
    else if(exam=='term2' && term2=="0")
      {
        readonly=true;
      }
    else readonly=false;
    String _marks="";
    _controller = TextEditingController();
    _controller?.text = (data!.marks!=null?data!.marks!:"")!;
    return Card(
      color: position! % 2 == 0
          ? (data!.marks == 'AB' ? Colors.red : Colors.blue[100])
          : (data!.marks == 'AB' ? Colors.red : Colors.blue[200]),
      child: Row(
        children: [
          SizedBox(
            width: 5,
          ),
          Text(
            '${data!.rollno}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 20,
          ),
          Flexible(
              fit: FlexFit.tight,
              child: Text('${data!.name}',
                  style: TextStyle(fontWeight: FontWeight.w800))),
          SizedBox(
            width: 20,
          ),
          Flexible(
            fit: FlexFit.loose,
            child: TextField(
              readOnly: readonly,
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(color: data!.err, fontWeight: FontWeight.bold),
              keyboardType: cat == 'specific participation'
                  ? TextInputType.text
                  : TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                cat != 'specific participation'
                    ? FilteringTextInputFormatter.allow(RegExp('[0-9.-]+'))
                    : FilteringTextInputFormatter.allow(RegExp('[0-9A-Z .,]'))
              ],
              controller: _controller,
              textInputAction: TextInputAction.next,
              onSubmitted: (text) async {
                data!.marks = _marks;
                setState(() {
                  print(text);
                  _marks = validateMarks(text);
                  if (_marks == 'ERROR') {
                    showTopSnackbar(context, "Invalid marks",Colors.red);
                    //ToastWidget.showToast("Invalid marks", Colors.red);
                    data!.err = Colors.red;
                  } else {
                    data!.err = Colors.black;
                    updateMarks(data!.rowid.toString(), _marks, data!.rollno!);
                  }
                  data!.marks = _marks;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  String validateMarks(String text) {
    double marks = 0;
    final numPattern = RegExp("[0-9.-]+");
    if (numPattern.hasMatch(text) && cat!='specific participation') {
      marks = double.parse(text);
      if (mm != '') {
        if (marks == -1)
          return 'AB';
        else if (marks > double.parse(mm!) || marks < -1)
          return 'ERROR';
        else
          return text;
      } else
        return text;
    } else {
      return text;
    }
  }
  Future <void> _showDownloadingDialog(BuildContext context,String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: ()async=>false,
          child: Container(
            child: AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              actions: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [CircularProgressIndicator(),Text(message,style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),),SizedBox(height: 10,)],)

              ],
            ),
          ),
        );
      },
    );
  }
  void updateMarks(String rowid, String marks, String rollno) async {
    try {
      //_showDownloadingDialog(context, "Saving Marks");
      String updateTab = tabname!;
      String sql = "";
      if (cname == 'VI' ||
          cname == 'VII' ||
          cname == 'VIII' ||
          cname == 'IX' ||
          cname == 'X' ||
          cname == 'XI' ||
          cname == 'XII') {
        if (subject == 'coscholastic') {
          updateTab = tabname! + "coscho";
          sql = "update `$currentdb`.`$updateTab` set $markscolname='$marks' "
              "where rowid='$rowid' and rollno='$rollno'";
        } else {
          sql = "update `$currentdb`.`$updateTab` set $markscolname='$marks' "
              "where rowid='$rowid' and rollno='$rollno' and subname='$subject'";
        }
      } else {
        sql =
            "update `$currentdb`.`$updateTab` set $markscolname='$marks' where rowid='$rowid' and rollno='$rollno'";
      }
      //print(sql);
      var results = await connection!.query(sql).timeout(Duration(seconds: 8));
      if (results.affectedRows! >= 0) {
        showTopSnackbar(context, "Marks Saved",Colors.white);
        //Navigator.pop(context);
        //ToastWidget.showToast("saved", Colors.green[400]!);
      }
    } catch (Exception) {
      showTopSnackbar(context, "Connection Error!!! Server not reachable.",Colors.red);
      /*Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>
            NewMenuPage(connection: connection,uid: uid,uname: uname,
              loginbranch: this.loginBranch,)),
      );*/
      Navigator.of(context).popUntil((route) => route.isFirst);
      //Navigator.of(context).pop();
      // Navigator.of(context).pushReplacement(MaterialPageRoute(
      //     builder: (context) => LoginPage()));
    }
  }
  void showTopSnackbar(BuildContext context,String message,Color col) {
    final snackBar = SnackBar(
      content: Center(
        child: Container(
          alignment: Alignment.center,
          width: 100,
          decoration: BoxDecoration(
            color: Color.fromRGBO(0, 255, 0, 0.5), // Set the desired background color
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(message,style:
            TextStyle(color: col,fontWeight: FontWeight.w900),),
          ),
        ),
      ),
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide.none,
      ),
      elevation: 0,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
