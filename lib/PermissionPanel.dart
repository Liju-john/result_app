import 'dart:async';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:result_app/settings/InternetCheck.dart';
import 'package:result_app/settings/Settings.dart';
import 'package:result_app/widgets/ToastWidget.dart';
import 'MysqlHelper.dart';

class PermissionPanel extends StatefulWidget {
  double screenwidth, screenheight;
  String currentdb = "",
      nextdb = "",
      previousDB = "",
      currentSession = "",
      cname,
      branch,
      section,
      branchNo;

  PermissionPanel(
      {this.screenwidth, this.screenheight, this.currentdb, this.branch});

  @override
  _PermissionPanelState createState() => _PermissionPanelState(
      this.screenwidth, this.screenheight, this.currentdb, this.branch);
}

class _PermissionPanelState extends State<PermissionPanel> {
  MysqlHelper mysqlHelper = MysqlHelper();
  bool secA = false, secB = false, secC = false, secD = false, secE = false;
  String currentdb = "",
      nextdb = "",
      previousDB = "",
      currentSession = "",
      cname,
      branch,
      section,
      branchNo;
  bool nonAdmin = false, sectionVisible = true, loadingClassSection = false;
  List<Data> data = [];
  int selectedPosition = 0;
  GlobalKey<FormState> _formKey = GlobalKey();
  List<NameList> nameData = [];
  Map branchinfo = {};
  TextEditingController tname, tid, tpwd;
  double screenwidth, screenheight;
  mysql.MySqlConnection connection;
  List<String> branchClassSection = [];
  String selectedClass,
      classSection = "",
      teacherBranch = "",
      iSelectedBranch,
      iSelectedClass,
      iSelectedSection;
  List<String> clist = [], iClist = [], iBranch = [], iSection = [];

  _PermissionPanelState(
      this.screenwidth, this.screenheight, this.currentdb, this.branch);

  void initState() {
    super.initState();
    loadNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.NAVIGATIONBAR,
        title: Text("Permission Panel",style: GoogleFonts.playball(
          fontSize: screenheight / 30,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],),),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
              onPressed: () async {
                await addTeacher();
              },
              child: Text(
                'Add Teacher',
                style: TextStyle(
                    color: Colors.yellow, fontWeight: FontWeight.w900),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenheight,
          child: Column(
            children: [
              SizedBox(
                  height: screenheight * 0.32,
                  child: Card(
                    elevation: 5,
                    color: Colors.blue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: Colors.green,
                        width: 3,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: screenwidth * 0.5,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              nameData.isEmpty
                                  ? Center(child: CircularProgressIndicator())
                                  : Expanded(
                                      child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: nameData.length,
                                          itemBuilder: (context, position) {
                                            return TextButton(
                                              child: Text(
                                                nameData[position].name,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.grey[600]),
                                              ),
                                              onPressed: () {
                                                selectedPosition = position;
                                                loadClassSection(position);
                                              },
                                            );
                                          }),
                                    ),
                            ],
                          ),
                        ),
                        SizedBox(
                            width: screenwidth * 0.4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: nameData.isEmpty
                                            ? Text("")
                                            : Column(
                                                children: [
                                                  Text(
                                                    nameData[selectedPosition]
                                                        .name,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Colors.purple),
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Text(
                                                    "ID:-" +
                                                        nameData[
                                                                selectedPosition]
                                                            .id,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900),
                                                  ),
                                                  Text(
                                                    "PWD:-" +
                                                        nameData[
                                                                selectedPosition]
                                                            .pwd,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900),
                                                  )
                                                ],
                                              ),
                                      )
                                    ]),
                                loadingClassSection
                                    ? Column(
                                        children: [
                                          SizedBox(
                                            height: 30,
                                          ),
                                          CircularProgressIndicator(),
                                        ],
                                      )
                                    : Expanded(
                                        child: branchClassSection.isEmpty
                                            ? Text("No classes assigned")
                                            : ListView.builder(
                                                scrollDirection: Axis.vertical,
                                                shrinkWrap: true,
                                                itemCount:
                                                    branchClassSection.length,
                                                itemBuilder:
                                                    (context, position) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8,
                                                            left: 8,
                                                            right: 4,
                                                            bottom: 8),
                                                    child: Text(
                                                      branchClassSection[
                                                          position],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900),
                                                    ),
                                                  );
                                                }),
                                      )
                              ],
                            ))
                      ],
                    ),
                  )),
              Text(
                "Assign Branch,Class and Section",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              SizedBox(
                height: screenheight * 0.52,
                child: Card(
                  elevation: 10,
                  color: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: Colors.teal,
                      width: 3,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text("Select Branch",
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                ),
                                SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: branchListWidget()),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text("Select Class",
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.underline)),
                                ),
                                classListWidget(),
                              ],
                            ),
                            //sectionWidget()
                            Expanded(
                              child: SizedBox(
                                height: screenheight * 0.39,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: sectionWidget(),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /*TextButton(onPressed: ()async{await assignClassSection();}, child: Text("Update class section")),*/
                          TextButton(
                              onPressed: () async {
                                //await loadPermission(selectedPosition);
                                await permissionWidget();
                              },
                              child: Text("Load permission"))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> permissionWidget() async {
    data.clear();
    iSelectedBranch = null;
    iClist.clear();
    iSection.clear();
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            Future loadPermission(int position) async {
              try {
                List<Data> data = [];
                this.data.clear();
                setState(() {});
                String query = 'select pname,pcol from permissions';
                var results = await connection.query(query);
                for (var rows in results) {
                  var res = await connection.query(
                      "select ${rows[1]} from `$currentdb`.`permission` "
                      "where id='${nameData[position].id}' and class='$iSelectedClass' and section='$iSelectedSection' and branch='${branchinfo[iSelectedBranch]}'");
                  if (res.length > 0) {
                    var r = res.first;
                    data.add(Data(
                        pname: rows[0],
                        pcol: rows[1],
                        taskSelected: r[0] == 1));
                  }
                }
                setState(() {
                  this.data = data;
                });
              } catch (Exception) {
                if (Exception.runtimeType == StateError) {
                  if (NetworkStatus.NETWORKTYPE == 0) {
                    ToastWidget.showToast("No internet connection", Colors.red);
                  } else {
                    ToastWidget.showToast("Reconnecting....!!!", Colors.red);
                    await getConnection();
                    await loadPermission(selectedPosition);
                  }
                } else if (Exception.runtimeType == TimeoutException ||
                    Exception.runtimeType == SocketException) {
                  ToastWidget.showToast(
                      "Not able to connect!! Restart the application",
                      Colors.red);
                } else {
                  ToastWidget.showToast(
                      Exception.runtimeType.toString() +
                          " " +
                          Exception.toString(),
                      Colors.red);
                }
              }
            }

            Future getTeacherSection() async {
              try {
                iSection.clear();
                String sql =
                    "select distinct section from `$currentdb`.`permission` "
                    "where id='${nameData[selectedPosition].id}' and branch='${branchinfo[iSelectedBranch]}'"
                    "and class='$iSelectedClass'";
                var result = await connection.query(sql);
                for (var r in result) {
                  iSection.add(r[0]);
                }
                setState(() {
                  iSelectedSection = iSection[0];
                });
                loadPermission(selectedPosition);
              } catch (Exception) {
                if (Exception.runtimeType == StateError) {
                  if (NetworkStatus.NETWORKTYPE == 0) {
                    ToastWidget.showToast("No internet connection", Colors.red);
                  } else {
                    ToastWidget.showToast("Reconnecting!!!", Colors.red);
                    await getConnection();
                    await getTeacherSection();
                  }
                } else if (Exception.runtimeType == TimeoutException ||
                    Exception.runtimeType == SocketException) {
                  ToastWidget.showToast(
                      "Not able to connect!! Restart the application",
                      Colors.red);
                } else {
                  ToastWidget.showToast(
                      Exception.runtimeType.toString() +
                          " " +
                          Exception.toString(),
                      Colors.red);
                  print(Exception.toString());
                }
              }
            }

            Future getTeacherClass(int branch) async {
              try {
                iClist.clear();
                String sql =
                    "select distinct class from `$currentdb`.`permission` "
                    "where id='${nameData[selectedPosition].id}' and branch='$branch'";
                var result = await connection.query(sql);
                for (var r in result) {
                  iClist.add(r[0]);
                }
                setState(() {
                  iSelectedClass = iClist[0];
                });
                await getTeacherSection();
              } catch (Exception) {
                if (Exception.runtimeType == StateError) {
                  if (NetworkStatus.NETWORKTYPE == 0) {
                    ToastWidget.showToast("No internet connection", Colors.red);
                  } else {
                    ToastWidget.showToast("Reconnecting !!!", Colors.red);
                    await getConnection();
                    await getTeacherClass(branchinfo[iSelectedBranch]);
                  }
                } else if (Exception.runtimeType == TimeoutException ||
                    Exception.runtimeType == SocketException) {
                  ToastWidget.showToast(
                      "Not able to connect!! Restart the application",
                      Colors.red);
                } else {
                  ToastWidget.showToast(
                      Exception.runtimeType.toString() +
                          " " +
                          Exception.toString(),
                      Colors.red);
                  print(Exception.toString());
                }
              }
            }

            return AlertDialog(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Center(
                child: Text(nameData[selectedPosition].name,
                    style: TextStyle(fontWeight: FontWeight.w900)),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  height: screenheight * 0.7,
                  width: screenwidth * 0.9,
                  child: Column(
                    children: [
                      DropdownButton<String>(
                        hint: Text(
                          "Please Select Branch",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        value: iSelectedBranch,
                        icon: const Icon(
                          Icons.arrow_downward,
                          color: Colors.blue,
                        ),
                        iconSize: 24,
                        elevation: 16,
                        onChanged: (String newValue) async {
                          setState(() {
                            iSelectedBranch = newValue;
                          });
                          await getTeacherClass(branchinfo[newValue]);
                        },
                        items: iBranch
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          );
                        }).toList(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<String>(
                            icon: const Icon(Icons.arrow_downward_outlined,
                                color: Colors.blue),
                            iconSize: 24,
                            elevation: 16,
                            disabledHint: Text(
                              "Please Wait",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                            value: iSelectedClass,
                            onChanged: (String newValue) async {
                              setState(() {
                                iSelectedClass = newValue;
                              });
                              await getTeacherSection();
                            },
                            items: iClist
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                              );
                            }).toList(),
                          ),
                          DropdownButton<String>(
                            icon: const Icon(Icons.arrow_downward_outlined,
                                color: Colors.blue),
                            iconSize: 24,
                            elevation: 16,
                            disabledHint: Text(
                              "Please wait",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                            value: iSelectedSection,
                            onChanged: (String newValue) async {
                              setState(() {
                                iSelectedSection = newValue;
                              });
                              await loadPermission(selectedPosition);
                            },
                            items: iSection
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                      Expanded(
                        child: data.isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: data.length,
                                itemBuilder: (context, position) {
                                  return ListTile(
                                    title: Text(data[position].pname),
                                    leading: Checkbox(
                                      value: data[position].taskSelected,
                                      onChanged: (bool value) {
                                        setState(() {
                                          data[position].taskSelected = value;
                                        });
                                      },
                                    ),
                                  );
                                }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                              onPressed: () async {
                                await savePermissionData(selectedPosition);
                              },
                              child: Text(
                                "Update",
                                style: TextStyle(fontWeight: FontWeight.w900),
                              )),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Close',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  Future<void> addTeacher() {
    tname = TextEditingController();
    tid = TextEditingController();
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
              child: Text('New Teacher',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            content: SingleChildScrollView(
                child: ListBody(children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              return value.isNotEmpty ? null : "*required";
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
                                  return value.isNotEmpty ? null : "*required";
                                },
                                controller: tid,
                                textCapitalization:
                                    TextCapitalization.characters,
                                keyboardType: TextInputType.phone,
                                decoration:
                                    InputDecoration(labelText: "Teacher's ID")))
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: TextFormField(
                                validator: (value) {
                                  return value.isNotEmpty ? null : "*required";
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
                            if (_formKey.currentState.validate()) {
                              await saveTeacher();
                              Navigator.of(context).pop();
                              await loadNames();
                            }
                          },
                        )
                      ],
                    )
                  ],
                ),
              )
            ])),
          );
        });
  }

  Widget sectionWidget() {
    return sectionVisible
        ? Column(
            children: [
              SizedBox(
                height: 5,
              ),
              nameData.isEmpty
                  ? Text("")
                  : Text(nameData[selectedPosition].name,
                      style: TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.purple),
                      maxLines: 1,
                      textAlign: TextAlign.center),
              ListTile(
                  title:
                      Text(selectedClass == null ? "" : selectedClass + " A"),
                  horizontalTitleGap: 5,
                  leading: Checkbox(
                    value: secA,
                    onChanged: (value) async {
                      setState(() {
                        secA = value;
                      });
                      if (value) {
                        await assignClassSection("A");
                      } else {
                        await deleteClassSection("A");
                      }
                    },
                  )),
              Visibility(
                visible: nonAdmin,
                child: ListTile(
                  title:
                      Text(selectedClass == null ? "" : selectedClass + " B"),
                  horizontalTitleGap: 5,
                  leading: Checkbox(
                    value: secB,
                    onChanged: (value) async {
                      setState(() {
                        secB = value;
                      });
                      if (value) {
                        await assignClassSection("B");
                      } else {
                        await deleteClassSection("B");
                      }
                    },
                  ),
                ),
              ),
              Visibility(
                visible: nonAdmin,
                child: ListTile(
                  title:
                      Text(selectedClass == null ? "" : selectedClass + " C"),
                  horizontalTitleGap: 5,
                  leading: Checkbox(
                    value: secC,
                    onChanged: (value) async {
                      setState(() {
                        secC = value;
                      });
                      if (value) {
                        await assignClassSection("C");
                      } else {
                        await deleteClassSection("C");
                      }
                    },
                  ),
                ),
              ),
              Visibility(
                visible: nonAdmin,
                child: ListTile(
                  title:
                      Text(selectedClass == null ? "" : selectedClass + " D"),
                  horizontalTitleGap: 5,
                  leading: Checkbox(
                    value: secD,
                    onChanged: (value) async {
                      setState(() {
                        secD = value;
                      });
                      if (value) {
                        await assignClassSection("D");
                      } else {
                        await deleteClassSection("D");
                      }
                    },
                  ),
                ),
              ),
              Visibility(
                visible: nonAdmin,
                child: ListTile(
                    title:
                        Text(selectedClass == null ? "" : selectedClass + " E"),
                    horizontalTitleGap: 5,
                    leading: Checkbox(
                      value: secE,
                      onChanged: (value) async {
                        setState(() {
                          secE = value;
                        });
                        if (value) {
                          await assignClassSection("E");
                        } else {
                          await deleteClassSection("E");
                        }
                      },
                    )),
              ),
            ],
          )
        : Column(
            children: [
              SizedBox(
                height: screenheight * 0.20,
              ),
              CircularProgressIndicator(),
            ],
          );
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
      onChanged: (String newValue) async {
        setState(() {
          branch = newValue;
        });
        await getClasses(branchinfo[branch]);
      },
      items: branchinfo.keys
          .cast<String>()
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        );
      }).toList(),
    );
  }

  Widget classListWidget() {
    return DropdownButton<String>(
      icon: const Icon(Icons.arrow_downward_outlined, color: Colors.blue),
      hint: Text(
        "Choose Class",
        style: TextStyle(
            color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      iconSize: 24,
      elevation: 16,
      disabledHint: Text(
        "Please wait",
        style: TextStyle(
            color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      value: selectedClass,
      onChanged: (String newValue) async {
        setState(() {
          selectedClass = newValue;
          if (selectedClass == 'Admin') {
            nonAdmin = false;
          } else {
            nonAdmin = true;
          }
        });
        await getAssignedSection();
      },
      items: clist.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        );
      }).toList(),
    );
  }

  /*Future loadPermission(int position) async{
    List<Data> data=[];
    this.data.clear();
    setState(() {
    });
    String query ='select pname,pcol from permissions';
    var results=await connection.query(query);
    for (var rows in results)
      {
        var res=await connection.query("select ${rows[1]} from `$currentdb`.`permission` where id='${nameData[position].id}'");
        if(res.length>0)
          {
            var r=res.first;
            data.add(Data(pname: rows[0],pcol: rows[1],taskSelected: r[0]==1));
          }
      }
    setState(() {
      this.data=data;
    });
  }*/
  Future loadNames() async {
    try {
      await getConnection();
      List<NameList> nameData = [];
      this.nameData.clear();
      String query = 'select id,ucase(name),pwd from `login` order by name';
      var results = await connection.query(query);
      for (var rows in results) {
        nameData.add(NameList(id: rows[0], name: rows[1], pwd: rows[2]));
      }
      setState(() {
        this.nameData = nameData;
      });
      //await loadPermission(0);
      await getBranch();
      await loadClassSection(0);
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast("Reconnecting!!!", Colors.red);
          await getConnection();
          await loadNames();
        }
      } else if (Exception.runtimeType == TimeoutException ||
          Exception.runtimeType == SocketException) {
        ToastWidget.showToast(
            "Not able to connect!! Restart the application", Colors.red);
      } else {
        ToastWidget.showToast(
            Exception.runtimeType.toString() + " " + Exception.toString(),
            Colors.red);
        print(Exception.toString());
      }
    }
  }

  Future getAssignedSection() async {
    setState(() {
      sectionVisible = false;
    });
    try {
      secA = secB = secC = secD = secE = false;
      String sql = "select section,class from `$currentdb`.`permission` where "
          "class='${selectedClass == "Admin" ? "ALL" : selectedClass}' and id='${nameData[selectedPosition].id}'"
          " and branch='${branchinfo[branch]}'";
      print(sql);
      var result = await connection.query(sql);
      for (var r in result) {
        if (r[0] == "A")
          secA = true;
        else if (r[0] == "B")
          secB = true;
        else if (r[0] == "C")
          secC = true;
        else if (r[0] == "D")
          secD = true;
        else if (r[0] == "E")
          secE = true;
        else if (r[1] == 'ALL') secA = true;
      }
      setState(() {
        sectionVisible = true;
      });
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast("Reconnecting!!!", Colors.red);
          await getConnection();
          await getAssignedSection();
        }
      } else if (Exception.runtimeType == TimeoutException ||
          Exception.runtimeType == SocketException) {
        ToastWidget.showToast(
            "Not able to connect!! Restart the application", Colors.red);
      } else {
        ToastWidget.showToast(
            Exception.runtimeType.toString() + " " + Exception.toString(),
            Colors.red);
        print(Exception.toString());
      }
    }
  }

  /* Future getTeacherSection() async
  {
    try {
      iSection.clear();
      String sql = "select distinct section from `$currentdb`.`permission` "
          "where id='${nameData[selectedPosition]
          .id}' and branch='${branchinfo[iSelectedBranch]}'"
          "and class='$iSelectedClass'";
      var result = await connection.query(sql);
      for (var r in result) {
        iSection.add(r[0]);
      }
      setState(() {
        iSelectedSection = iSection[0];
      });
    }catch(Exception)
    {
      if(Exception.runtimeType==StateError) {
        if(NetworkStatus.NETWORKTYPE==0)
        {
          ToastWidget.showToast("No internet connection", Colors.red);
        }
        else {
          ToastWidget.showToast("Reconnecting!!!", Colors.red);
          await getConnection();
          await getTeacherSection();
        }

      }
      else if(Exception.runtimeType==TimeoutException||Exception.runtimeType==SocketException)
      {
        ToastWidget.showToast("Not able to connect!! Restart the application", Colors.red);
      }
      else
      {
        ToastWidget.showToast(Exception.runtimeType.toString()+" "+Exception.toString(), Colors.red);
        print(Exception.toString());
      }
    }
  }
  Future getTeacherClass(int branch) async
  {
    iClist.clear();
    String sql="select distinct class from `$currentdb`.`permission` "
        "where id='${nameData[selectedPosition].id}' and branch='$branch'";
    var result=await connection.query(sql);
    for(var r in result)
    {
      iClist.add(r[0]);
    }
    setState(() {
      iSelectedClass=iClist[0];
    });
    print(iClist);
    print(sql);
    await getTeacherSection();
  }*/
  Future loadClassSection(int position) async {
    try {
      setState(() {
        loadingClassSection = true;
      });
      branchClassSection.clear();
      iBranch.clear();
      var branchMap = {1: "Koni", 2: "Narmada Nagar", 3: "Sakri", 4: "KV"};
      String branch = "";
      String sql =
          "select distinct branch from  `$currentdb`.`permission` where id='${nameData[position].id}'";
      var result = await connection.query(sql);
      for (var r in result) {
        branch = branch + "  " + '"${branchMap[r[0]]}"';
        iBranch.add(branchMap[r[0]]);
        String temp = "";
        sql =
            "select class,section from `$currentdb`.`permission` where id='${nameData[position].id}' and branch='${r[0]}'";
        var res = await connection.query(sql);
        for (var cr in res) {
          temp = temp + " " + cr[0] + "-" + cr[1];
        }
        branchClassSection.add(branchMap[r[0]] + " " + temp);
      }
      setState(() {
        loadingClassSection = false;
        this.classSection = classSection;
        teacherBranch = branch;
      });
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast("Reconnecting!!!", Colors.red);
          await getConnection();
          await loadClassSection(selectedPosition);
        }
      } else if (Exception.runtimeType == TimeoutException ||
          Exception.runtimeType == SocketException) {
        ToastWidget.showToast(
            "Not able to connect!! Restart the application", Colors.red);
      } else {
        ToastWidget.showToast(
            Exception.runtimeType.toString() + " " + Exception.toString(),
            Colors.red);
        print(Exception.toString());
      }
    }
  }

  Future getClasses(int branchno) async {
    try {
      setState(() {
        sectionVisible = false;
      });
      secA = secB = secC = secD = secE = false;
      clist.clear();
      String sql =
          "select cname from classdetail where branch like '%$branchno%'";
      var results = await connection.query(sql);
      clist.add("Admin");
      for (var r in results) {
        clist.add(r[0]);
      }
      setState(() {
        //selectedClass = clist[0];
        selectedClass = null;
      });
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast("Reconnecting!!!", Colors.red);
          await getConnection();
          await getClasses(branchinfo[branch]);
        }
      } else if (Exception.runtimeType == TimeoutException ||
          Exception.runtimeType == SocketException) {
        ToastWidget.showToast(
            "Not able to connect!! Restart the application", Colors.red);
      } else {
        ToastWidget.showToast(
            Exception.runtimeType.toString() + " " + Exception.toString(),
            Colors.red);
        print(Exception.toString());
      }
    }
  }

  Future saveTeacher() async {
    var postData = {"tname": tname.text, "tid": tid.text, "tpwd": tpwd.text};
    var url = Uri.parse('https://kpsbsp.in/result/addTeacher.php');
    var response = await http.post(url, body: postData);
    if (response.statusCode == 200) {
      ToastWidget.showToast(response.body, Colors.red);
    } else {
      ToastWidget.showToast(response.reasonPhrase, Colors.red);
    }
  }

  Future getConnection() async {
    if (connection != null) {
      await connection.close();
    }
    connection = await mysqlHelper.Connect();
  }

  Future deleteClassSection(String sec) async {
    try {
      setState(() {
        sectionVisible = false;
      });
      String sql;
      if (selectedClass == "Admin") {
        sql = "delete from `$currentdb`.`permission` "
            "where id='${nameData[selectedPosition].id}' "
            "and class='ALL' and branch='${branchinfo[branch]}'";
      } else {
        sql = "delete from `$currentdb`.`permission` "
            "where id='${nameData[selectedPosition].id}' "
            "and class='$selectedClass' and section='$sec' and branch='${branchinfo[branch]}'";
      }
      var result = await connection.query(sql);
      if (result.affectedRows >= 1) {
        ToastWidget.showToast("Deleted!!", Colors.green);
      } else {
        ToastWidget.showToast("Something went wrong", Colors.red);
      }
      await loadClassSection(selectedPosition);
      setState(() {
        sectionVisible = true;
      });
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast(
              "Operation cancelled reconnecting!!!", Colors.red);
          await getConnection();
          await getClasses(branchinfo[branch]);
        }
      } else if (Exception.runtimeType == TimeoutException ||
          Exception.runtimeType == SocketException) {
        ToastWidget.showToast(
            "Not able to connect!! Restart the application", Colors.red);
      } else {
        ToastWidget.showToast(
            Exception.runtimeType.toString() + " " + Exception.toString(),
            Colors.red);
        print(Exception.toString());
      }
    }
  }

  Future assignClassSection(String sec) async {
    try {
      setState(() {
        sectionVisible = false;
      });
      String sql;
      if (selectedClass == "Admin") {
        sql = "insert into `$currentdb`.`permission` (`id`,`branch`,`class`) "
            "values ('${nameData[selectedPosition].id}','${branchinfo[branch]}','ALL')";
      } else {
        sql =
            "insert into `$currentdb`.`permission` (`id`,`branch`,`class`,`section`)"
            "values('${nameData[selectedPosition].id}','${branchinfo[branch]}','$selectedClass','$sec')";
      }
      var result = await connection.query(sql);
      if (result.affectedRows >= 1) {
        ToastWidget.showToast("Updated!!", Colors.green);
      } else {
        ToastWidget.showToast("Something went wrong", Colors.red);
      }
      await loadClassSection(selectedPosition);
      setState(() {
        sectionVisible = true;
      });
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast(
              "Operation cancelled reconnecting!!!", Colors.red);
          await getConnection();
          await getClasses(branchinfo[branch]);
        }
      } else if (Exception.runtimeType == TimeoutException ||
          Exception.runtimeType == SocketException) {
        ToastWidget.showToast(
            "Not able to connect!! Restart the application", Colors.red);
      } else {
        ToastWidget.showToast(
            Exception.runtimeType.toString() + " " + Exception.toString(),
            Colors.red);
        print(Exception.toString());
      }
    }
  }

  /*Future assignClassSection() async
  {
    String s1="delete from `$currentdb`.`permission` where "
        "id='${nameData[selectedPosition].id}' "
        "and class='$selectedClass' and branch='${branchinfo[branch]}'";
    String s2="insert into `$currentdb`.`permission` ('id','branch','class','section') values";
    if(selectedClass=="Admin")
    {
      s2=s2+"('${nameData[selectedPosition].id}','${branchinfo[branch]}','ALL',''),";
    }
    else{
      if(secA)
      {
        s2=s2+"('${nameData[selectedPosition].id}','${branchinfo[branch]}','$selectedClass','A'),";
      }
      if(secB)
      {
        s2=s2+"('${nameData[selectedPosition].id}','${branchinfo[branch]}','$selectedClass','B'),";
      }
      if(secC)
      {
        s2=s2+"('${nameData[selectedPosition].id}','${branchinfo[branch]}','$selectedClass','C'),";
      }
      if(secD)
      {
        s2=s2+"('${nameData[selectedPosition].id}','${branchinfo[branch]}','$selectedClass','D'),";
      }
      if(secE)
      {
        s2=s2+"('${nameData[selectedPosition].id}','${branchinfo[branch]}','$selectedClass','E'),";
      }
    }
    print(s1);
    s2=s2.substring(0,s2.lastIndexOf(","));
    print(s2);
  }*/
  Future savePermissionData(int selectedPosition) async {
    try {
      await getBranch();
      String sql = "update `$currentdb`.`permission` set ";
      for (var i in data) {
        sql = sql + i.pcol + "= ${i.taskSelected},";
      }
      sql = sql.substring(0, sql.lastIndexOf(",")) +
          " where id='${nameData[selectedPosition].id}' and branch='${branchinfo[iSelectedBranch]}' "
              "and class='$iSelectedClass' and section='$iSelectedSection'";
      var result = await connection.query(sql);
      print(sql);
      if (result.affectedRows >= 1) {
        ToastWidget.showToast("Data Updated!!!", Colors.green);
      } else {
        ToastWidget.showToast("Not saved!!!", Colors.red);
      }
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast("Try agian  !!!", Colors.red);
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
    branchinfo.clear();
    try {
      String sql = "Select * from branchinfo";
      var results = await connection.query(sql);
      for (var rows in results) {
        branchinfo.addAll({rows[1].toString(): rows[0]});
      }
      setState(() {});
      await getClasses(1);
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
            Exception.runtimeType.toString() + " " + Exception.toString(),
            Colors.red);
        print(Exception.toString());
      }
    }
  }
}

class Data {
  String pname, pcol;
  bool taskSelected;

  Data({this.pname, this.pcol, this.taskSelected});
}

class NameList {
  String name, id, pwd;

  NameList({this.name, this.id, this.pwd});
}
