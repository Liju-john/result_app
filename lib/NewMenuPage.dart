import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:result_app/AddNewStudentPage.dart';
import 'package:result_app/AssignRollnoSectionTcPage.dart';
import 'package:result_app/MarksEntryPage.dart';
import 'package:result_app/Outstanding.dart';
import 'package:result_app/ProfilePhoto.dart';
import 'package:result_app/SchoolStatsPanel.dart';
import 'package:result_app/SearchDeletePannel.dart';
import 'package:result_app/StatsPanel.dart';
import 'package:result_app/settings/InternetCheck.dart';
import 'package:result_app/widgets/ToastWidget.dart';
import 'MysqlHelper.dart';
import 'NewPermissionPanel.dart';
import 'NominalPanel.dart';
import 'PromoteTC_Panel.dart';
import 'VaccinePanel.dart';
import 'settings/Settings.dart';

class NewMenuPage extends StatefulWidget {
  mysql.MySqlConnection? connection;
  String? uid = "", uname = "",loginbranch="";

  NewMenuPage({this.connection, this.uid, this.uname,this.loginbranch});

  @override
  _NewMenuPageState createState() =>
      _NewMenuPageState(this.connection, this.uid, this.uname,this.loginbranch);
}

class _NewMenuPageState extends State<NewMenuPage> {
  mysql.MySqlConnection? connection;
  String? currentdb = "",
      nextdb = "",
      previousDB = "",
      currentSession = "",
      next_Session="",
      uname,term1,term2,loginbranch;
  double? screenwidth, screenheight;
  int? connectionType;
  String? uid = '';
  GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController? tname, tpwd;
  //String uid='9584935413';
  //String uid='8982437151';
  String? user;
  bool loading = true, session_visible = false, admnoChange = false;
  MysqlHelper mysqlHelper = MysqlHelper();
  String? selectedclass, selectedsection, sessionRemark;
  List<String> clist = [],
      sectionlist = [],
      branchlist = [],
      tasklist = [],
      dbList = [],
      sessiondblist = [];
      var branches=new LinkedHashMap();
  //String uname='121';
  String? branch, branchno;
  String? section;

  _NewMenuPageState(this.connection, this.uid, this.uname,this.loginbranch);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //NetworkStatus.checkStatus();
    getSessionList();
  }

  @override
  Widget build(BuildContext context) {
    screenwidth = MediaQuery.of(context).size.width;
    screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColor.BACKGROUND,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.NAVIGATIONBAR,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dashboard",
              style: GoogleFonts.playball(
                fontSize: MediaQuery.of(context).size.height / 30,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],),
              textAlign: TextAlign.start,
            ),
            Text("WELCOME " + uname!.toUpperCase(),
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.refresh),
              iconSize: 25,
              onPressed: () async {
                ToastWidget.showToast("Please Wait....", Colors.redAccent);
                await getSessionList();
                ToastWidget.showToast("Refreshed", Colors.green);
              })
        ],
      ),
      body: Column(
        children: [
          Visibility(visible: session_visible, child: sessionRowWidget()),
          Card(
            elevation: 10,
            color: Colors.blue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                color: Colors.red,
                width: 3,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(children: [
                      Text(currentSession!,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900)),
                      Container(
                          width: screenwidth! * 0.7,
                          padding: EdgeInsets.only(left: 2, right: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Branch',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              branchListWidget(),
                            ],
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          width: screenwidth! * 0.7,
                          padding: EdgeInsets.only(left: 2, right: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Class',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w900)),
                              classListWidget(),
                            ],
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                          width: screenwidth! * 0.7,
                          padding: EdgeInsets.only(left: 2, right: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Section',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w900)),
                              sectionListWidget(),
                            ],
                          )),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          tasklist.isEmpty
              ? Text(
                  "No Task Assigned...",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                )
              : taskListWidget()
        ],
      ),
    );
  }

  Widget sessionRowWidget() {
    return Card(
        elevation: 10,
        color: Colors.green[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: Colors.teal,
            width: 3,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Choose session',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [sessionListDropDown()],
            ),
          ],
        ));
  }

  Widget branchListWidget() {
    return DropdownButton<String>(
      value: branch,
      disabledHint: Text(
        "Please wait",
        style: TextStyle(
            color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      icon: const Icon(
        Icons.arrow_downward,
        color: Colors.blue,
      ),
      iconSize: 24,
      elevation: 16,
      onChanged: (String? newValue) async {
        setState(() {
          branch = newValue;
        });
        getClasses();
      },
      items: branchlist.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget taskListWidget() {
    return Expanded(
      flex:1,
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: Colors.purple,
            width: 3,
          ),
        ),
        color: Colors.yellow[100],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Task List',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: tasklist.length,
                  padding: const EdgeInsets.all(15.0),
                  itemBuilder: (context, position) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blueAccent[700]!,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(10)),
                                child: TextButton(
                                  onPressed: () {
                                    navigateMenu(tasklist[position]);
                                  },
                                  child: Text(tasklist[position],
                                      style: TextStyle(color: Colors.teal)),
                                ))
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  // Branch list
  Widget sessionListDropDown() {
    return DropdownButton<String>(
      value: currentSession,
      hint: Text('Select Session'),
      icon: const Icon(Icons.arrow_downward, color: Colors.blue),
      iconSize: 24,
      elevation: 16,
      onChanged: (String? newValue) async {
        setState(() {
          currentSession = newValue;
        });
        tasklist.clear();
        await nextSession();
        await getBranch();
      },
      items: sessiondblist.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  //Class drop down
  Widget classListWidget() {
    return DropdownButton<String>(
      icon: const Icon(Icons.arrow_downward_outlined, color: Colors.blue),
      iconSize: 24,
      hint: Text("Narmada nagar"),
      elevation: 16,
      disabledHint: Text(
        "Please wait",
        style: TextStyle(
            color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      value: selectedclass,
      onChanged: (String? newValue) {
        setState(() {
          selectedsection = null;
          selectedclass = newValue;
        });
        getSection();
      },
      items: clist.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  // section drop down
  Widget sectionListWidget() {
    return DropdownButton<String>(
      icon: const Icon(Icons.arrow_downward_outlined, color: Colors.blue),
      iconSize: 24,
      elevation: 16,
      hint: Text("Narmada Nagar"),
      disabledHint: Text(
        "No sections",
        style: TextStyle(
            color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      value: selectedsection,
      onChanged: (String? newValue) {
        setState(() {
          selectedsection = newValue;
        });
        getTaskList();
      },
      items: sectionlist.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Future getSessionList() async {
    int rowID=0;
    try {
      //await getConnection();
      this.dbList = [];
      List<String> sessiondblist = [];
      var result = await connection!.query(
          "Select id,db,session from `kpsbspin_master`.`db_names` where remark=1"); // to set the default database
      for (var rows in result) {
        GlobalSetting.CURRENT_DB_ID=rows[0];
        currentSession = rows[2];
        currentdb = rows[1];
        rowID = rows[0];
      }
      result = await connection!.query(
          "Select session,db from `kpsbspin_master`.`db_names` where id=${rowID + 1}"); //to set the next database
      for (var row in result) {
        nextdb = row[1];
        next_Session=row[0];
      }
      result = await connection!.query(
          "Select session,db from `kpsbspin_master`.`db_names` where id=${rowID - 1}"); //to set the previous database
      for (var row in result) {
        previousDB = row[1];
      }
      result = await connection!.query(
          "Select session_permission from `kpsbspin_master`.`login` where id='$uid'"); // to get session_permission of user
      for (var rows in result) {
        if (rows[0] == 1) {
          session_visible = true;
          result = await connection!.query(
              "select session from `kpsbspin_master`.`db_names` where status=1"); // to get the list of session available
          for (rows in result) {
            sessiondblist.add(rows[0]);
          }
          this.sessiondblist = sessiondblist;
        }
      }
      await getBranch();
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast(
              "Reconnecting to server, please wait!!!", Colors.red);
          await getConnection();
          await getSessionList();
        }
      } else if (Exception.runtimeType == TimeoutException ||
          Exception.runtimeType == SocketException) {
        ToastWidget.showToast(
            "Not able to connect!! Restart the application", Colors.red);
      } else {
        ToastWidget.showToast(
            Exception.runtimeType.toString() + " " + Exception.toString(),
            Colors.red);
      }
    }
  }

  Future getTaskList() async {
    try {
      this.tasklist = [];
      List<String> tasklist = [];
      String query="", checkSearch="";
      if (user == 'admin') {
        query =
            "select  permission,e1,e2 from `$currentdb`.`teacher_app_perm` "
                "where id='$uid' and branch='$branchno'";
      } else {
        query =
            "select  permission,e1,e2 from `$currentdb`.`teacher_app_perm`"
                " where id='$uid' and branch='$branchno' "
                "and cname='$selectedclass' and section='$selectedsection'";
      }
      var result = await connection!.query(query);
      for (var row in result) {
       tasklist.add(row[0]);
       if(row[0]=='Marks Entry')
         {
           term1=row[1].toString();
           term2=row[2].toString();
         }
      }
      setState(() {
        this.tasklist = tasklist;
      });
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast(
              "Reconnecting to server, please wait!!!", Colors.red);
          await getConnection();
          await getTaskList();
        }
      } else if (Exception.runtimeType == TimeoutException ||
          Exception.runtimeType == SocketException) {
        ToastWidget.showToast(
            "Not able to connect!! Restart the application", Colors.red);
      } else {
        ToastWidget.showToast(
            Exception.runtimeType.toString() + " " + Exception.toString(),
            Colors.red);
      }
    }
  }

  Future getBranch() async {
    try {
      branchlist = [];
      List<String> br = [];
      List<String>? keyValuePairs = loginbranch?.split('-');
      for(String pair in keyValuePairs!)
        {
          List<String> parts = pair.split('_');
          branches[parts[1]]=parts[0];
          br.add(parts[1]);
        }
      /*var result = await connection!.query(
          "Select DISTINCT t1.branch,t2.branch from `$currentdb`.`teacher_app_perm`"
              " t1,kpsbspin_master.branchinfo t2 where t1.branch=t2.branchno and id='$uid'");
      for (var row in result) {
        branches[row[1].toString()]=row[0].toString();
        br.add(row[1]);
      }*/
      setState(() {
        branchlist = br;
        branch = branchlist[0];
      });
      getClasses();
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast(
              "Reconnecting to server, please wait!!!", Colors.red);
          await getConnection();
          await getBranch();
        }
      } else if (Exception.runtimeType == TimeoutException ||
          Exception.runtimeType == SocketException) {
        ToastWidget.showToast(
            "Not able to connect!! Restart the application", Colors.red);
      } else {
        ToastWidget.showToast(
            "No Task Assigned, Contact Developers", Colors.red);
      }
    }
  }

  Future getClasses() async {
    //print("Called getClasses");
    try {
      String query="";
      branchno=branches[branch];
      this.clist = [];
      setState(() {
        selectedclass = '';
      });
      List<String> clist = [];
      var result = await connection!.query(
          "Select distinct cname from `$currentdb`.`teacher_app_perm` where id='$uid' and branch='$branchno'");
      for (var row in result) {
        if (row[0] == 'ALL') {
          query =
              "Select distinct cname from classdetail where branch like '%$branchno%'";
          user = 'admin';
        } else {
          query =
              "Select distinct cname from `$currentdb`.`teacher_app_perm` where branch='$branchno' and id='$uid'";
          user = 'teacher';
        }
      }
      var result1 = await connection!.query(query);
      for (var cn in result1) {
        clist.add(cn[0]);
      }
      setState(() {
        this.clist = clist;
        selectedclass = this.clist[0];
      });
      //get the alias which works from session id 6
      if (GlobalSetting.CURRENT_DB_ID>=6)
        {
          query="select * from kpsbspin_master.branchinfo where branchno="+branchno!;
          result1=await connection!.query(query);
          for(var r in result1)
            {
              GlobalSetting.alias=r['alias'];
            }
        }
      getSection();
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast(
              "Reconnecting to server, please wait!!!", Colors.red);
          await getConnection();
          await getClasses();
        }
      } else if (Exception.runtimeType == TimeoutException ||
          Exception.runtimeType == SocketException) {
        ToastWidget.showToast(
            "Not able to connect!! Restart the application", Colors.red);
      } else {
        ToastWidget.showToast(
            Exception.runtimeType.toString() + " " + Exception.toString(),
            Colors.red);
      }
    }
  }

  Future getSection() async {
    String query="";
    sectionlist.clear();
    try {
      setState(() {
        selectedsection = '';
      });

      List<String> seclist = [];
      if (user == 'admin') {
        seclist.add("ALL");
        // query =
        //     "select distinct section from `$currentdb`.`nominal` where "
        //         "cname='$selectedclass' and section not in ('') and section "
        //         "is not null and branch='$branchno' order by section";
        query = "select section from `$currentdb`.`sections` where "
            "cname='${selectedclass}'"
            " and branch like '%${branchno}%' order by section";
      } else {
        query =
            "select distinct section from `$currentdb`.`teacher_app_perm` where id='$uid' and cname='$selectedclass' and branch='$branchno' order by section";
      }
      var results = await connection!.query(query);
      for (var sec in results) {
        seclist.add(sec[0]);
      }
      setState(() {
        sectionlist = seclist;
        if (sectionlist.isNotEmpty) {
          selectedsection = sectionlist[0];
        }
      });
      await getTaskList();
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast(
              "Reconnecting to server, please wait!!!", Colors.red);
          await getConnection();
          await getSection();
        }
      } else if (Exception.runtimeType == TimeoutException ||
          Exception.runtimeType == SocketException ||
          Exception.runtimeType == StateError) {
        ToastWidget.showToast(
            "Not able to connect!! Restart the application", Colors.red);
      } else {
        ToastWidget.showToast(
            Exception.runtimeType.toString() + " " + Exception.toString(),
            Colors.red);
      }
    }
  }

  Future nextSession() async {
    try {
      currentdb = "";
      nextdb = "";
      previousDB = "";
      int id;
      var results = await connection!.query(
          "select id,db from `kpsbspin_master`.`db_names` where session='$currentSession'");
      for (var rows in results) {
        id = rows[0];
        GlobalSetting.CURRENT_DB_ID=id;
        currentdb = rows[1];
        results = await connection!.query(
            "select db,session from `kpsbspin_master`.`db_names` where id='${id + 1}'");
        for (rows in results) {
          nextdb = rows[0];
          next_Session=rows[1];
        }
        results = await connection!.query(
            "Select session,db from `kpsbspin_master`.`db_names` where id=${id - 1}"); //to set the previous database
        for (var row in results) {
          previousDB = row[1];
        }
      }
      ToastWidget.showToast("Session Changed", Colors.green);
      print("Current" + currentdb! + " next" + nextdb!);
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast(
              "Reconnecting to server, please wait!!!", Colors.red);
          await getConnection();
          await nextSession();
        }
      } else if (Exception.runtimeType == TimeoutException ||
          Exception.runtimeType == SocketException) {
        ToastWidget.showToast(
            "Not able to connect!! Restart the application", Colors.red);
      } else {
        ToastWidget.showToast(
            Exception.runtimeType.toString() + " " + Exception.toString(),
            Colors.red);
      }
    }
  }
  Future<void> _changePwdDialog(){
    tname = TextEditingController();
    tpwd = TextEditingController();
    return showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Center(
              child: Text('Change Password',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            content: SingleChildScrollView(
               child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              validator: (value) {
                                return value!.isNotEmpty ? null : "*required";
                              },
                              controller: tname,
                              textCapitalization: TextCapitalization.characters,
                              decoration:
                              InputDecoration(labelText: "Teacher's Name"),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: TextFormField(
                                  validator: (value) {
                                    return value!.isNotEmpty ? null : "*required";
                                  },
                                  controller: tpwd,
                                  textCapitalization:
                                  TextCapitalization.characters,
                                  decoration:
                                  InputDecoration(labelText: "Password")))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            child: Text("Save"),
                            onPressed: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              if (_formKey.currentState!.validate()) {
                                Navigator.of(context).pop();
                              }
                            },
                          )
                        ],
                      )
                    ],
                  ),
                )
            ),
          );
        });
  }
  Future getConnection() async {
    setState(() {
      loading = true;
    });
    if (connection != null) {
      await connection!.close();
      print("Reached");
    }
    connection = await mysqlHelper.Connect();
    setState(() {
      loading = false;
    });
  }

  Future<void> navigateMenu(String tasklist) async {
    if (tasklist == 'Marks Entry') {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MarksEntryPannel(
                connection: connection,
                section: selectedsection,
                cname: selectedclass,
                branch: branch,
                screenheight: screenheight!,
                screenwidth: screenwidth!,
                currentdb: currentdb,
                nextdb: nextdb,branchno: branches[branch],
            uid: this.uid,uname: this.uname,term1: term1,term2: term2,
              )));
    } else if (tasklist == 'Rollno and Sections') {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AssignRollnoSection_TC_Panel(
                currentDB: currentdb,
                nextDB: nextdb,
                connection: connection,
                cname: selectedclass,
                branch: branchno,
                screenHeight: screenheight!,
                screenWidth: screenwidth!,
                previousDB: previousDB,
              )));
    } else if (tasklist == 'Nominal') {
      if (nextdb == "") {
        ToastWidget.showToast("No sections available", Colors.red);
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NominalPanel(
                currentdb: currentdb!,
                nextdb: nextdb!,
                connection: connection!,
                section: selectedsection!,
                cname: selectedclass!,
                branch: branchno!,
                screenheight: screenheight!,
                screenwidth: screenwidth!,
                admnoChange: admnoChange,
                tid: uid!,currentSession:currentSession!)));
      }
    }
    else if (tasklist == 'Profile Photo') {
      if (nextdb == "") {
        ToastWidget.showToast("No sections available", Colors.red);
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfilePhoto(
                currentdb: currentdb!,
                nextdb: nextdb!,
                connection: connection!,
                section: selectedsection!,
                cname: selectedclass!,
                branch: branchno!,
                screenheight: screenheight!,
                screenwidth: screenwidth!,
                tid: uid!)));
      }
    }
    else if (tasklist == 'Vaccine Detail') {
      if (nextdb == "") {
        ToastWidget.showToast("No sections available", Colors.red);
      } else {
        // Navigator.of(context).push(MaterialPageRoute(
        //     builder: (context) => VaccinePanel(
        //         currentdb: currentdb!,
        //         nextdb: nextdb!,
        //         connection: connection!,
        //         section: selectedsection!,
        //         cname: selectedclass!,
        //         branch: branchno!,
        //         screenheight: screenheight!,
        //         screenwidth: screenwidth!,
        //         admnoChange: admnoChange,
        //         tid: uid!)));
      }
    }
    else if (tasklist == 'Class Summary') {
      if (nextdb == "") {
        ToastWidget.showToast("No sections available", Colors.red);
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => StatsPanel(
                currentdb: currentdb!,
                nextdb: nextdb!,
                connection: connection!,
                section: selectedsection!,
                cname: selectedclass!,
                branch: branchno!,
                screenheight: screenheight!,
                screenwidth: screenwidth!,
                admnoChange: admnoChange,
                tid: uid!,user: user!,)));
      }
    }
    else if (tasklist == 'School Summary') {
      if (nextdb == "") {
        ToastWidget.showToast("No sections available", Colors.red);
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SchoolStatsPanel(
              currentdb: currentdb!,
              nextdb: nextdb!,
              connection: connection!,
              branch: branchno!,
              branchname:branch!,
              screenheight: screenheight!,
              screenwidth: screenwidth!,
            )));
      }
    }
    else if (tasklist == 'Promote') {
      if (nextdb == "") {
        ToastWidget.showToast("Cant access", Colors.red);
      } else
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PromoteTC_Panel(
                  currentdb: currentdb!,
                  nextdb: nextdb!,
                  connection: connection!,
                  section: selectedsection!,
                  cname: selectedclass!,
                  branch: branchno!,
                  screenheight: screenheight!,
                  screenwidth: screenwidth!,
                  nextSession: next_Session!,
              currentSession: currentSession!,
                )));
    } else if (tasklist == "Add New Student") {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddNewStudent(
                currentdb: currentdb,
                nextdb: nextdb,
                connection: connection,
                cnameList: clist,
                branch: branchno,
                screenheight: screenheight!,
                screenwidth: screenwidth!,
            previousDB: previousDB,
              )));
    } else if (tasklist == "Search") {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SearchDeletePanel(
                currentdb: currentdb!,
                nextdb: nextdb!,
                screenheight: screenheight!,
                screenwidth: screenwidth!,branches: branches,
            connection: connection!,
              )));
    } else if (tasklist == "Permission Manager") {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => NewPermissionPanel(
                screenwidth: screenwidth!,
                screenheight: screenheight!,
                currentdb: currentdb!,
                branch: branch!,
                uid: uid!,
            loginbranch: loginbranch,
              )));
    }
    else if(tasklist=="Fees Details")
      {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context)=>OutstandingPanel(
              currentdb: currentdb!,
              nextdb: nextdb!,
              connection: connection!,
              section: selectedsection!,
              cname: selectedclass!,
              branch: branchno!,
              screenheight: screenheight!,
              screenwidth: screenwidth!,
            )));
      }
  }
}
