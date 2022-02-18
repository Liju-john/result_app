import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:result_app/MarksEntryPage.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:result_app/widgets/ToastWidget.dart';

class MarksEntryBox extends StatefulWidget {
  mysql.MySqlConnection connection;
  Data data;
  String currentdb = "",
      nextdb = "",
      mm = "",
      tabname = "",
      markscolname,
      subject;
  int position;
  String cat;
  String cname, section, branch;
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
      this.subject});
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
      this.subject);
}

class _MarksEntryBoxState extends State<MarksEntryBox> {
  Data data;
  mysql.MySqlConnection connection;
  int position;
  String marks, cat, mm, tabname, markscolname, cname, currentdb, subject;
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
      this.subject);
  TextEditingController _controller;
  @override
  Widget build(BuildContext context) {
    return row();
  }

  Widget field() {
    String _marks;
    _controller = TextEditingController();
    _controller.text = data.marks;
    return TextFormField(
      controller: _controller,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.characters,
      keyboardType: cat == 'specific participation'
          ? TextInputType.text
          : TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        cat != 'specific participation'
            ? FilteringTextInputFormatter.allow(RegExp('[0-9.-]+'))
            : FilteringTextInputFormatter.allow(RegExp('[A-Z .,]'))
      ],
      style: TextStyle(color: data.err, fontWeight: FontWeight.bold),
      onFieldSubmitted: (text) async {
        setState(() {
          _marks = validateMarks(text);
          if (_marks == 'ERROR') {
            ToastWidget.showToast("Invalid marks", Colors.red);
            data.err = Colors.red;
          } else {
            data.err = Colors.black;
            /* updateMarks(
                data.rowid.toString(),
                _marks,
                data.rollno);*/
          }
          data.marks = _marks;
        });
      },
    );
  }

  Widget row() {
    String _marks;
    _controller = TextEditingController();
    _controller.text = data.marks;
    return Card(
      color: position % 2 == 0
          ? (data.marks == 'AB' ? Colors.red : Colors.blue[100])
          : (data.marks == 'AB' ? Colors.red : Colors.blue[200]),
      child: Row(
        children: [
          SizedBox(
            width: 5,
          ),
          Text(
            '${data.rollno}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 20,
          ),
          Flexible(
              fit: FlexFit.tight,
              child: Text('${data.name}',
                  style: TextStyle(fontWeight: FontWeight.w800))),
          SizedBox(
            width: 20,
          ),
          Flexible(
            fit: FlexFit.loose,
            child: TextField(
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(color: data.err, fontWeight: FontWeight.bold),
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
                data.marks = _marks;
                setState(() {
                  print(text);
                  _marks = validateMarks(text);
                  if (_marks == 'ERROR') {
                    ToastWidget.showToast("Invalid marks", Colors.red);
                    data.err = Colors.red;
                  } else {
                    data.err = Colors.black;
                    updateMarks(data.rowid.toString(), _marks, data.rollno);
                  }
                  data.marks = _marks;
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
        else if (marks > double.parse(mm) || marks < -1)
          return 'ERROR';
        else
          return text;
      } else
        return text;
    } else {
      return text;
    }
  }

  void updateMarks(String rowid, String marks, String rollno) async {
    try {
      String updateTab = tabname;
      String sql = "";
      if (cname == 'VI' ||
          cname == 'VII' ||
          cname == 'VIII' ||
          cname == 'IX' ||
          cname == 'X' ||
          cname == 'XI' ||
          cname == 'XII') {
        if (subject == 'coscholastic') {
          updateTab = tabname + "coscho";
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
      print(sql);
      var results = await connection.query(sql);
      if (results.affectedRows >= 0) {
        ToastWidget.showToast("saved", Colors.green[400]);
      }
    } catch (Exception) {}
  }
}
