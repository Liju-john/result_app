import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:result_app/MarksEntryBox.dart';
import 'package:result_app/MysqlHelper.dart';
import 'package:result_app/settings/Settings.dart';
import 'package:result_app/widgets/ToastWidget.dart';

class MarksEntryPannel extends StatefulWidget {
  mysql.MySqlConnection? connection;
  String? currentdb = "", nextdb = "";
  double? screenheight, screenwidth;
  String? loginbranch;
  String? cname, section, branch,branchno,uid,uname,term1,term2;
  MarksEntryPannel(
      {this.connection,
      this.cname,
      this.section,
      this.branch,
      this.currentdb,
      this.nextdb,
      this.screenheight,
      this.screenwidth,
        this.branchno,this.uid,this.uname,this.term1,
        this.term2,this.loginbranch});
  @override
  _MarksEntryPannelState createState() => _MarksEntryPannelState(
      this.connection,
      this.cname,
      this.section,
      this.branch,
      this.currentdb,
      this.nextdb,
      this.screenheight,
      this.screenwidth,this.branchno,this.uid,this.uname,this.term1,
      this.term2,this.loginbranch);
}
class _MarksEntryPannelState extends State<MarksEntryPannel> {
  MysqlHelper mysqlHelper = MysqlHelper();
  String? currentdb = "", nextdb = "";
  double? screenheight, screenwidth;
  String? loginbranch;
  String? subject, cat, markscolname, cname, section,
      branch, branchno,uid,uname,term1,term2;
  String tabname="", classflag="";
  String ?term;
  List<String> sublist = [], catlist = [];
  bool loading = true;
  bool catlodaing = true;
  String mm = '';
  List<TextEditingController> _controllers = [];
  List<Data> data = [];
  mysql.MySqlConnection? connection;
  _MarksEntryPannelState(this.connection, this.cname, this.section, this.branch,
      this.currentdb, this.nextdb, this.screenheight, this.screenwidth,this
          .branchno,this.uid,this.uname,this.term1,this.term2,this.loginbranch);
  void initState() {
    super.initState();
  }

  void showTopSnackbar(BuildContext context,String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  void dispose() {
    super.dispose();
    controllerDispose();
    //connection!.close();
  }

  String validateMarks(String text) {
    double marks = 0;
    final numPattern = RegExp("[0-9.-]+");
    if (numPattern.hasMatch(text)) {
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

  void controllerDispose() {
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    String _marks;
    return Scaffold(
        backgroundColor: AppColor.BACKGROUND,
        appBar: AppBar(
          elevation: 0,
          title: Text('Marks Entry Panel',style: GoogleFonts.playball(
            fontSize: screenheight! / 30,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],),),
          backgroundColor: AppColor.NAVIGATIONBAR,
        ),
        body: Center(
          child: Column(children: [
            Container(
              color: Colors.blue[200],
              height: 120,
              child: Card(
                color: Colors.blue[100],
                shadowColor: Colors.blue,
                elevation: 10,
                child: _header(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Rollno',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.purpleAccent[700]),
                ),
                SizedBox(
                  width: 20,
                ),
                Flexible(
                    fit: FlexFit.tight,
                    child: Text('Name',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.purpleAccent[700]))),
                Flexible(
                    fit: FlexFit.tight,
                    child: Text('Marks',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.purpleAccent[700]))),
              ],
            ),
            data.isEmpty & loading
                ? Column(
                  children: [
                    CircularProgressIndicator(),
                    Text("Select 'Term' to continue.....",style:
                    TextStyle(color:Colors.red,fontSize: 20,fontWeight: FontWeight.bold),)
                  ],
                )
                : Expanded(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        addRepaintBoundaries: false,
                        itemCount: data.length,
                        padding: const EdgeInsets.all(15.0),
                        itemBuilder: (context, position) {
                          _controllers.add(new TextEditingController());
                          _controllers[position].text =
                              '${data[position].marks}' == 'null'
                                  ? ''
                                  : '${data[position].marks}';
                          return Column(
                            children: [
                              MarksEntryBox(connection: connection,data: data[position],
                                cat: cat,mm: mm,position: position,tabname: tabname,
                                markscolname: markscolname,currentdb: currentdb,
                              cname: cname,subject: subject,uid:uid,
                                uname:uname,term2: term2,term1: term1,exam: term,),
                              Divider(
                                height: 10,
                                thickness: 2,
                                color: Colors.orange,
                              ),
                            ],
                          );
                        }),
                  ),
          ]),
        ));
  }

  Widget _header() {
    return SizedBox(
        height: 50,
        width: double.infinity,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Term',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.purple[400]),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  DropdownButton<String>(
                    value: term,
                    hint: Text('Select Term',style: TextStyle(color: Colors.red),),
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    onChanged: (String? newValue) async {
                      setState(() {
                        term = newValue!;
                      });
                      await getSubject();
                    },
                    items: <String>['term1', 'term2']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: SizedBox(
                            width: screenwidth! * 0.2, child: Text(value)),
                      );
                    }).toList(),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Subject',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.purple[400]),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  DropdownButton<String>(
                    icon: const Icon(Icons.arrow_downward_outlined),
                    iconSize: 24,
                    elevation: 16,
                    disabledHint: Text(
                      "Waiting for term selection",
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                    hint: Text("Select subject"),
                    value: subject,
                    onChanged: (String? newValue) {
                      setState(() {
                        subject = newValue;
                      });
                      getCategory(subject!);
                    },
                    items:
                        sublist.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Category',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[400]),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      DropdownButton<String>(
                        icon: const Icon(Icons.arrow_downward_outlined),
                        iconSize: 24,
                        elevation: 16,
                        hint: Text("Select category"),
                        disabledHint: Text(
                          "Loading category",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        value: cat,
                        onChanged: (String? newValue) {
                          setState(() {
                            cat = newValue;
                          });
                          _loadSubjectMarks();
                        },
                        items: catlist
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: SizedBox(
                                width: screenwidth! * 0.5,
                                child: Text(
                                  value,
                                  softWrap: true,
                                  maxLines: 2,
                                )),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'MM',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[400]),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '$mm',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                    ]))
          ],
        ));
  }

  Future<List<String>> getSubject() async {
    try {
      sublist.clear();
      List<String> sublis = [];
      if (cname == 'I' ||
          cname == 'II' ||
          cname == 'III' ||
          cname == 'IV' ||
          cname == 'V') {
        if (term == 'term1') {
          tabname = '${GlobalSetting.alias}i_vterm1';
          classflag = "('1to2','3to5')";
        } else if (term == 'term2') {
          tabname = '${GlobalSetting.alias}i_vterm2';
          classflag = "('1to2','3to5')";
        }
      } else if (cname == 'NUR' || cname == 'KGI' || cname == 'KGII') {
        if (term == 'term1') {
          tabname = '${GlobalSetting.alias}nur_kgterm1';
        } else if (term == 'term2') {
          tabname = '${GlobalSetting.alias}nur_kgterm2';
        }
        classflag = "('nurkg')";
      } else if (cname == 'VI' || cname == 'VII' || cname == 'VIII') {
        tabname = '${GlobalSetting.alias}vi_viii';
        classflag = "('6to8')";
      } else if (cname == 'IX'|| cname == 'X') {
        tabname = '${GlobalSetting.alias}ix_x';
        classflag = "('ixtox')";
      } else if (cname == 'XI' || cname == 'XII') {
        tabname = '${GlobalSetting.alias}xi_xii';
        classflag = "('xitoxii')";
      }
      //print("select distinct(subname) from `$currentdb`.`${GlobalSetting.alias}subjectstructure` where classflag in $classflag and examname='$term'");
      var results = await connection!.query(
          "select distinct(subname) from `$currentdb`.`${GlobalSetting.alias}subjectstructure` where classflag in $classflag and examname='$term'");
      for (var row in results) {
        sublis.add(row[0]);
      }
      setState(() {
        sublist = sublis;
        subject = sublist[0];
      });
      await getCategory(subject!);
      return sublist;
    } catch (Exception) {}
    throw Exception("Error in code");
  }

  Future<List<Data>> _loadSubjectMarks() async {
    String sql="";
    try {
      setState(() {
        data.clear();
      });

      var colQuery = await connection!.query(
          "select colname,mm from `$currentdb`.`${GlobalSetting.alias}subjectstructure` where subname='$subject' "
          "and cat='$cat' and examname='$term' and classflag in $classflag");
      for (var row in colQuery) {
        markscolname = row[0];
        setState(() {
          mm = row[1];
        });
      }
      if (cname == 'I' ||
          cname == 'II' ||
          cname == 'III' ||
          cname == 'IV' ||
          cname == 'V') {
        if(term=='term1')
          {
              sql= "select t1.rollno,t2.sname,$markscolname,t1.rowid from `$currentdb`.`$tabname` t1 , "
                  "`$currentdb`.`nominal` t2 where t1.rowid = t2.rowid and cname='$cname' "
                  "and section='$section' and t1.rollno not in('',' ') and t1.branch= '$branchno'"
                  " and session_status not in('Not active') AND STATUS=1 order by t1.rollno";
          }
        else if(term=='term2')
          {
            sql= "select t1.rollno,t2.sname,$markscolname,t1.rowid from `$currentdb`.`$tabname` t1 , "
                "`$currentdb`.`nominal` t2 where t1.rowid = t2.rowid and cname='$cname' "
                "and section='$section' and t1.rollno not in('',' ') and t1.branch= '$branchno'"
                " and session_status not in('Not active','after term I') AND STATUS=1 order"
                " by t1.rollno";
          }
        var results = await connection!.query(sql);
        setState(() {
          for (var row in results) {
            Data data = Data(
                rollno: row[0],
                name: row[1],
                marks: row[2],
                rowid: row[3].toString());
            this.data.add(data);
          }
        });
        setState(() {
          loading = false;
        });

        return this.data;
      } else if (cname == 'NUR' || cname == 'KGI' || cname == 'KGII') {
        if(term=='term1')
          {
            sql= "select t1.rollno,t2.sname,$markscolname,t1.rowid from `$currentdb`.`$tabname` t1 , `$currentdb`.`nominal` t2 "
                "where t1.rowid = t2.rowid and cname='$cname' and section='$section' and t1.rollno not in('',' ')"
                " and t1.branch= '$branchno' and session_status not in('Not active') AND STATUS=1 order by t1.rollno";
          }
        else if(term=='term2')
          {
            sql= "select t1.rollno,t2.sname,$markscolname,t1.rowid from `$currentdb`.`$tabname` t1 , `$currentdb`.`nominal` t2 "
                "where t1.rowid = t2.rowid and cname='$cname' and section='$section' and t1.rollno not in('',' ')"
                " and t1.branch= '$branchno' and session_status not in('Not "
                "active','after term I') AND STATUS=1 order by t1.rollno";
          }
        var results = await connection!.query(sql);
        setState(() {
          for (var row in results) {
            Data data = Data(
                rollno: row[0],
                name: row[1],
                marks: row[2],
                rowid: row[3].toString());
            this.data.add(data);
          }
        });
        setState(() {
          loading = false;
        });
        //connection!.close();
        return this.data;
      } else if (cname == 'VI' || cname == 'VII' || cname == 'VIII') {

        if (subject == "coscholastic") {
          if(term=='term1')
            {
              sql =
              "select t1.rollno,t2.sname,$markscolname,t1.rowid,'subno' from `$currentdb`.`${GlobalSetting.alias}vi_viiicoscho` t1 ,"
                  " `$currentdb`.`nominal` t2 where t1.rowid = t2.rowid and cname='$cname' and section='$section' "
                  " and t1.branch='$branchno' and "
                  "session_status not in('Not active') AND STATUS=1 order by t1.rollno";
            }
          else if(term=='term2')
            {
              sql =
              "select t1.rollno,t2.sname,$markscolname,t1.rowid,'subno' from `$currentdb`.`${GlobalSetting.alias}vi_viiicoscho` t1 ,"
                  " `$currentdb`.`nominal` t2 where t1.rowid = t2.rowid and cname='$cname' and section='$section' "
                  " and t1.branch='$branchno' and session_status not in('Not "
                  "active','after term I') AND STATUS=1 order by t1.rollno";
            }
        } else {
          if(term=='term1')
            {
              sql =
              "select t1.rollno,t2.sname,$markscolname,t1.rowid,subno from `$currentdb`.`$tabname` t1 ,"
                  " `$currentdb`.`nominal` t2 where t1.rowid = t2.rowid and cname='$cname' and section='$section' "
                  "and subname='$subject' and t1.branch='$branchno' and session_status"
                  "  not in('Not active') AND STATUS=1 order by t1.rollno";
            }
          else if(term=='term2')
            {
              sql =
              "select t1.rollno,t2.sname,$markscolname,t1.rowid,subno from `$currentdb`.`$tabname` t1 ,"
                  " `$currentdb`.`nominal` t2 where t1.rowid = t2.rowid and cname='$cname' and section='$section' "
                  " and subname='$subject' and t1.branch='$branchno' and "
                  "session_status not in('Not active','after term I') AND STATUS=1 order by t1.rollno";
            }

        }
        var results = await connection!.query(sql);
        setState(() {
          for (var row in results) {
            Data data = Data(
                rollno: row[0],
                name: row[1],
                marks: row[2],
                rowid: row[3].toString(),
                subno: row[4]);
            this.data.add(data);
          }
        });
        setState(() {
          loading = false;
        });
        //connection!.close();
        return this.data;
      } else if (cname == 'IX'|| cname == 'X') {
        String sql="";
        if (subject == "coscholastic") {
          if(term=='term1')
            {
              sql =
              "select t1.rollno,t2.sname,$markscolname,t1.rowid,'subno' from `$currentdb`.`${GlobalSetting.alias}ix_xcoscho` t1 ,"
                  " `$currentdb`.`nominal` t2 where t1.rowid = t2.rowid and cname='$cname' and section='$section' "
                  " and t1.branch='$branchno' and session_status not in('Not active')"
                  " AND STATUS=1 order by t1.rollno";
            }
          else if(term=='term2')
            {
              sql =
              "select t1.rollno,t2.sname,$markscolname,t1.rowid,'subno' from `$currentdb`.`${GlobalSetting.alias}ix_xcoscho` t1 ,"
                  " `$currentdb`.`nominal` t2 where t1.rowid = t2.rowid and cname='$cname' and section='$section' "
                  " and t1.branch='$branchno' and session_status not in('Not "
                  "active','after term I') AND STATUS=1 order by t1.rollno";
            }

        } else {
          if(term=='term1')
          {
            sql =
            "select t1.rollno,t2.sname,$markscolname,t1.rowid,subno from `$currentdb`.`$tabname` t1 , "
                "`$currentdb`.`nominal` t2 where t1.rowid = t2.rowid and  t1.subname='$subject' "
                " and cname ='$cname' and t2.section='$section' "
                "and session_status not in('Not active') AND STATUS=1 order by rollno";
          }
          else if(term=='term2')
          {
            sql =
            "select t1.rollno,t2.sname,$markscolname,t1.rowid,subno from `$currentdb`.`$tabname` t1 , "
                "`$currentdb`.`nominal` t2 where t1.rowid = t2.rowid and  t1.subname='$subject' "
                " and cname ='$cname' and t2.section='$section' and "
                "session_status not in('Not active','after term I') AND STATUS=1 order by "
                "rollno";
          }
        }
        var results = await connection!.query(sql);
        setState(() {
          for (var row in results) {
            Data data = Data(
                rollno: row[0],
                name: row[1],
                marks: row[2],
                rowid: row[3].toString(),
                subno: row[4]);
            this.data.add(data);
          }
        });
        setState(() {
          loading = false;
        });

        return this.data;
      } else if (cname == 'XI'||cname == 'XII') {
        String sql="";
        if (subject == "coscholastic") {
          if(term=='term1')
          {
            sql =
            "select t1.rollno,t2.sname,$markscolname,t1.rowid,'subno' from `$currentdb`.`${GlobalSetting.alias}xi_xiicoscho` t1 ,"
                " `$currentdb`.`nominal` t2 where t1.rowid = t2.rowid and cname='$cname' and section='$section' "
                " and t1.branch='$branchno' and session_status "
                "not in('Not active') AND STATUS=1 order by t1.rollno";
          }
          else if(term=='term2')
          {
            sql =
            "select t1.rollno,t2.sname,$markscolname,t1.rowid,'subno' from `$currentdb`.`${GlobalSetting.alias}xi_xiicoscho` t1 ,"
                " `$currentdb`.`nominal` t2 where t1.rowid = t2.rowid and cname='$cname' and section='$section' "
                " and t1.branch='$branchno' and session_status not in('Not "
                "active','after term I') AND STATUS=1 order by t1.rollno";
          }

        } else {
          if(term=='term1')
          {
            sql =
            "select t1.rollno,t2.sname,$markscolname,t1.rowid,subno from `$currentdb`.`$tabname` t1 , "
                "`$currentdb`.`nominal` t2 where t1.rowid = t2.rowid and  t1.subname='$subject' "
                " and cname ='$cname' and t2.section='$section' "
                "and session_status not in('Not active') AND STATUS=1 order by rollno";
          }
          else if(term=='term2')
          {
            sql =
            "select t1.rollno,t2.sname,$markscolname,t1.rowid,subno from `$currentdb`.`$tabname` t1 , "
                "`$currentdb`.`nominal` t2 where t1.rowid = t2.rowid and  t1.subname='$subject' "
                " and cname ='$cname' and t2.section='$section' and "
                "session_status not in('Not active','after term I') AND STATUS=1 order by "
                "rollno";
          }

        }
        var results = await connection!.query(sql);
        setState(() {
          for (var row in results) {
            Data data = Data(
                rollno: row[0],
                name: row[1],
                marks: row[2],
                rowid: row[3].toString(),
                subno: row[4]);
            this.data.add(data);
          }
        });
        setState(() {
          loading = false;
        });
        //connection!.close();
        return this.data;
      }
    } catch (Exception) {
      print(Exception.toString());
    }
    throw Exception("Error in code");
  }

  Future getCategory(String subject) async {
    try {
      setState(() {
        catlist.clear();
      });
      List<String> cat = [];
      var results = await connection!.query(
          "select cat from `$currentdb`.`${GlobalSetting.alias}subjectstructure` where examname='$term' and classflag in $classflag and subname='" +
              subject +
              "'");
      for (var row in results) {
        cat.add(row[0]);
      }
      setState(() {
        catlist = cat;
        catlodaing = false;
        this.cat = catlist[0]; //to set the category selected......
        _loadSubjectMarks();
      });
    } catch (Exception) {}
  }

  Future getConnection() async {
    if (connection != null) {
      await connection!.close();
    }
    connection = await mysqlHelper.Connect();
  }
}

class Data {
  String? rollno,marks,subno,rowid,name;
  Color err;
  Data(
      {this.rollno,
      this.name,
      this.marks,
      this.subno,
      this.rowid,
      this.err = Colors.black});
}
