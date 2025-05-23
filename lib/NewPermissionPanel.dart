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

class NewPermissionPanel extends StatefulWidget {
  double screenwidth, screenheight;
  String currentdb = "",
      nextdb = "",
      previousDB = "",
      currentSession = "",
      cname="",
      branch="",
      section="",
      branchNo="",uid="";
  String? loginbranch;

  NewPermissionPanel(
      {required this.screenwidth, required this.screenheight,
        required this.currentdb, required this.branch,required this.uid,this.loginbranch});

  @override
  _NewPermissionPanelState createState() => _NewPermissionPanelState(
      this.screenwidth, this.screenheight,
      this.currentdb, this.branch,this.uid,this.loginbranch);
}

class _NewPermissionPanelState extends State<NewPermissionPanel> {
  MysqlHelper mysqlHelper = MysqlHelper();
  bool secA = false, secB = false, secC = false, secD = false, secE = false;
  String? currentdb = "",
      nextdb = "",
      previousDB = "",
      currentSession = "",
      cname,
      branch,
      section,
      lbranch,lbranchno,
      branchNo,uid,loginbranch,adminSelectedBranch;
  bool nonAdmin = false, sectionVisible = true, loadingClassSection = false;
  final TextEditingController _searchName=TextEditingController();
  List<PermissionData> permissionData = [];
  List<TeacherSections> sectionData = [];
  int selectedPosition = 0;
  GlobalKey<FormState> _formKey = GlobalKey();
  List<NameList> nameData = [],dataBackup=[];
  Map branchinfo = {},newBranchinfo={};
  TextEditingController ? tname, tid, tpwd;
  double screenwidth, screenheight;
  mysql.MySqlConnection ? connection;
  List<String> branchClassSection = [];
  String? selectedClass,
      classSection = "",
      teacherBranch = "",
      iSelectedBranch,
      iSelectedClass,
      iSelectedSection;
  List<String> clist = [], iClist = [], iBranch = [], iSection = [];

  _NewPermissionPanelState(
      this.screenwidth, this.screenheight,
      this.currentdb, this.branch,this.uid,this.loginbranch);

  void initState() {
    super.initState();
    getBranch();
    //loadNames();
    //newGetBranch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.NAVIGATIONBAR,
        title: Text("Permission Panel",style: GoogleFonts.playball(
          fontSize: screenheight / 30,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],),),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
              onPressed: () async {
                lbranch==null? ToastWidget.showToast("Select Branch first", Colors.red):await addTeacher();
              },
              child: Text(
                'Add Teacher',
                style: TextStyle(
                    color: Colors.yellow, fontWeight: FontWeight.w900),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Text("Branch",style: TextStyle(fontWeight: FontWeight.w900),),
                  SizedBox(width: 10,),
                  userBranch(),
                ],
              ),
            ),
            search(),
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
                                            autofocus: false,
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
                                    ),
                              OutlinedButton(style:OutlinedButton.styleFrom(
                                foregroundColor: Colors.red, side: BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ) ,
                                  child: Text("Delete Teacher",),
                                  onPressed: (){
                                    deleteTeacherAlert(selectedPosition);
                                  },),
                            ],
                          ))
                    ],
                  ),
                )),
            Text(
              "Assign Branch,Class and Section",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
            Card(
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
                            /*Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text("Select Branch",
                                  style: TextStyle(
                                      decoration:
                                          TextDecoration.underline)),
                            ),
                            SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: branchListWidget()),*/
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> deleteTeacherAlert(int position) async
  {

    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (context) {
          return StatefulBuilder(
              builder: (context,setState){
                return AlertDialog(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(20.0),),
                    title: Text(
                        'Alert', style: TextStyle(fontWeight: FontWeight.w900)),
                    content: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text("You are about to delete ${nameData[selectedPosition].name}. "
                                "Are you sure about this?",style: TextStyle
                              (fontWeight: FontWeight.bold),),
                            Row( mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(onPressed: () async {
                                 await deleteTeacher();
                                  Navigator.of(context).pop();
                                 await loadNames();
                                }, child: Text("Ok",style: TextStyle(fontWeight: FontWeight.w900,color: Colors.green,fontSize: 17),)),
                                TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text("Cancel",style: TextStyle(fontWeight: FontWeight.w900,color: Colors.red,fontSize: 17)))],)

                          ],
                        )
                    )
                );
              });
        }
    );
  }
  Future<void> permissionWidget(int pos) async {
    permissionData.clear();
    iSelectedBranch = null;
    iClist.clear();
    iSection.clear();
    Future loadPermission() async {
      try {
        showLoadingDialog(context);
        List<PermissionData> data = [];
        this.permissionData.clear();
        setState(() {});
        String query = 'select menu from '
            'kpsbspin_master.teacher_app_menu';
        var results = await connection!.query(query);
        for (var rows in results) {
          var res = await connection!.query(
              "select permission,e1,e2 from `$currentdb`.`teacher_app_perm` "
                  "where id='${sectionData[pos].tecaherID}' and "
                  "cname='${sectionData[pos].cname}' "
                  "and section='${sectionData[pos].section=="*"?"":sectionData[pos].section}' "
                  "and branch='${branchinfo[lbranch]}' "
                  "and permission='${rows[0]}'");
             var r = res.length>0?res.first[0]:"";
             bool e1=res.length>0?(res.first[1]==1?true:false):false;
             bool e2=res.length>0?(res.first[2]==1?true:false):false;
            data.add(PermissionData(
                pname: rows[0],
                taskSelected: r==rows[0],e1: e1,e2:e2));
        }
        Navigator.of(context).pop();
        setState(() {
          this.permissionData = data;
        });
      } catch (Exception) {
        if (Exception.runtimeType == StateError) {
          if (NetworkStatus.NETWORKTYPE == 0) {
            ToastWidget.showToast("No internet connection", Colors.red);
          } else {
            ToastWidget.showToast("Reconnecting....!!!", Colors.red);
            await getConnection();
            await loadPermission();
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
    await loadPermission();
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
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
                      Expanded(
                        child: permissionData.isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: permissionData.length,
                                itemBuilder: (context, position) {
                                  return ListTile(
                                    title: permissionData[position].pname=='Marks Entry'?Text(""):Text(permissionData[position].pname),
                                    leading: permissionData[position].pname=='Marks Entry'?
                                        TextButton(onPressed: () async{
                                         await showExamTermDialog(position, pos);
                                        },
                                            child: Text(permissionData[position].pname)):
                                    Checkbox(
                                      value: permissionData[position].taskSelected,
                                      onChanged: (bool ? value) async {
                                        permissionData[position].taskSelected = value!;
                                        await savePermissionData(position,pos);
                                        setState((){
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
    Map<String, bool> newMap = {};
    branchinfo.keys.forEach((key) {
      newMap[key] = false;
    });
    String? addTeacherBranch;
    FocusScope.of(context).unfocus();
    tname = TextEditingController();
    tid = TextEditingController();
    tpwd = TextEditingController();
    return showDialog<void>(
        context: context,
        builder: (context) {return StatefulBuilder(builder: (context, setState)
        {
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
                    Text("Select Branch"),
                    Container(
                      width: double.maxFinite,
                      height: 150,
                      child: ListView.builder(
                        itemCount: branchinfo.keys.length,
                        itemBuilder: (BuildContext context, int index) {
                          String value = branchinfo.keys.elementAt(index);
                          return ListTile(
                            title: Text(value),
                            leading: Checkbox(
                              value: newMap[value] ?? false,
                              onChanged: (bool? val) {
                                setState(() {
                                  newMap[value] = val ?? false;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
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
                            //FocusScope.of(context).requestFocus(FocusNode());
                            if (_formKey.currentState!.validate()) {
                              //await saveTeacher("");
                              String b="";
                              newMap.keys.forEach((element) {
                                if(newMap[element]==true)
                                  {
                                   b=b+branchinfo[element]+"_"+element+"-";
                                  }
                              });
                              if(b.isNotEmpty)
                                {
                                    b=b.substring(0,b.length-1);
                                    Navigator.of(context).pop();
                                    await saveTeacher(b);
                                    await loadNames();
                                }
                              else
                                {
                                  ToastWidget.showToast("Branch is not selected!!", Colors.red);
                                }
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
        });});
  }
  Widget userBranch() {
    return DropdownButton<String>(
      value: lbranch,
      hint: Text("Choose Branch"),
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
          lbranch = newValue;
        });
        await loadNames();
        await getClasses(int.parse(branchinfo[lbranch]));
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
              Container(
                height: screenheight * 0.4,
                child: sectionData.isEmpty?null:
                ListView.builder(
                  itemCount: sectionData.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(child: Visibility(
                          visible:sectionData[index].checked??false,
                          child: TextButton(onPressed: (){
                            permissionWidget(index);
                          },
                              child: Text("Edit Permissions")),
                        )),
                        Expanded(
                          child: CheckboxListTile(
                              contentPadding: EdgeInsets.only(left: 5,right: 50),
                            title: Text(sectionData[index].section??""),
                              value: sectionData[index].checked,
                              onChanged:(bool ? value){
                              setState(() {
                                sectionData[index].checked=value;
                              });
                              },),
                        ),
                      ],
                    );
                  },),
              )

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
  Widget search()
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        textCapitalization:TextCapitalization.characters,
        onChanged: (String val){
          this.nameData=dataBackup;
          final data=this.nameData?.where((data) {
            final sname=data.name?.toLowerCase();
            final searchlower=val.toLowerCase();
            return sname!.contains(searchlower);
          }).toList();
          setState(() {
            this.nameData=data!;
          });
        },
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: "Type name here to search...",
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)))
        ),),
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
      onChanged: (String ? newValue) async {
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
      onChanged: (String ? newValue) async {
        setState(() {
          selectedClass = newValue;
          if (selectedClass == 'ALL') {
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
      this.dataBackup=[];
      selectedPosition=0;
      String query = "select id,ucase(name),pwd from `login` "
          "where branch like '%${lbranch}%' order by name";
      var results = await connection!.query(query);
      for (var rows in results) {
        nameData.add(NameList(id: rows[0], name: rows[1], pwd: rows[2]));
      }
      dataBackup=nameData;
      setState(() {
        this.nameData = nameData;
      });
      await loadClassSection(selectedPosition);
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
    sectionData.clear();
    setState(() {
      sectionVisible = false;
    });
    try {
      if(nonAdmin)
        {
      String sql = "select section from `$currentdb`.`sections` where "
          "cname='${selectedClass}'"
          " and branch like '%${branchinfo[lbranch]}%'";
      var result = await connection!.query(sql);
      for (var r in result) {
        String p=selectedClass??"";
        bool checkValue=branchClassSection.isEmpty?false:
        branchClassSection[0].
        contains(p+"-"+r[0]);
        sectionData.add(TeacherSections(
            tecaherID: nameData[selectedPosition].id,
            section: r[0],cname: selectedClass,checked: checkValue));
      }
        }
      else
        {
          String p=selectedClass??"";
          bool checkValue=branchClassSection.isEmpty?false:
          branchClassSection[0].
          contains(p+"-");
        sectionData.add(TeacherSections(
            tecaherID: nameData[selectedPosition].id,
            section: "*",cname: selectedClass,checked: checkValue));}
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

  Future loadClassSection(int position) async {
    try {
      sectionData.clear();
      setState(() {
        loadingClassSection = true;
        selectedClass=null;
      });
      branchClassSection.clear();
      String temp = "";
      String sql =
      "select distinct cname,section from `$currentdb`.`teacher_app_perm`"
          " where id='${nameData[position].id}' and branch='${branchinfo[lbranch]}'";
      var res = await connection!.query(sql);
      for (var cr in res) {
        temp = temp + " " + cr[0] + "-" + cr[1];
      }
      branchClassSection.add(temp);
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
      clist.clear();
      String sql =
          "select cname from "
          "kpsbspin_master.classdetail where branch like '%$branchno%'";
      var results = await connection!.query(sql);
      clist.add("ALL");
      for (var r in results) {
        clist.add(r[0]);
      }
      setState(() {
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

  Future saveTeacher(String branch) async {
    var postData = {"tname": tname!.text,
      "tid": tid!.text,
      "tpwd": tpwd!.text,
    "branch":branch};
    print(postData);
    var url = Uri.parse('$serverAdd/result/addTeacher.php');
    var response = await http.post(url, body: postData);
    if (response.statusCode == 200) {
      ToastWidget.showToast(response.body, Colors.red);
    } else {
      ToastWidget.showToast(response.reasonPhrase!, Colors.red);
    }
  }
  Future deleteTeacher() async {
    var postData = {"tname": nameData[selectedPosition].name,
      "tid": nameData[selectedPosition].id,
      "current_db":currentdb};
    var url = Uri.parse('$serverAdd/result/deleteTeacher.php');
    var response = await http.post(url, body: postData);
    if (response.statusCode == 200) {
      ToastWidget.showToast(response.body, Colors.red);
    } else {
      ToastWidget.showToast(response.reasonPhrase!, Colors.red);
    }
  }

  Future getConnection() async {
    if (connection != null) {
      await connection!.close();
    }
    connection = await mysqlHelper.Connect();
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
      var result = await connection!.query(sql);
      if (result.affectedRows! >= 1) {
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

  Future savePermissionData(int per_position,sec_pos) async {
    try {
      String sql = "";
      showLoadingDialog(context);
      if(permissionData[per_position].pname=='Marks Entry')
        {
          print(permissionData[per_position].e1);
          print(permissionData[per_position].e2);
          sql="delete from $currentdb.teacher_app_perm where"
              " id='${nameData[selectedPosition].id}'"
              " and permission='${permissionData[per_position].pname}'"
              " and branch='${branchinfo[lbranch]}'"
              " and cname='${sectionData[sec_pos].cname}'"
              " and section='${sectionData[sec_pos].section=="*"?"":sectionData[sec_pos].section}'";
          var result=await connection!.query(sql);
          if((permissionData[per_position].e1??false) || (permissionData[per_position].e2??false))
            {
              //"delete and insert";
              int e1=permissionData[per_position].e1??false?1:0;
              int e2=permissionData[per_position].e2??false?1:0;
              permissionData[per_position].taskSelected=true;
              sql = "insert into $currentdb.teacher_app_perm "
                  "(id,branch,cname,section,permission,e1,e2) values "
                  "('${nameData[selectedPosition].id}',"
                  "'${branchinfo[lbranch]}',"
                  "'${sectionData[sec_pos].cname}',"
                  "'${sectionData[sec_pos].section=="*"?"":sectionData[sec_pos].section}',"
                  "'${permissionData[per_position].pname}',"
                  "'${e1}',"
                  "'${e2}')";
              result = await connection!.query(sql);
            }
          else
            {
              permissionData[per_position].taskSelected=false;
            }
          if (result.affectedRows! >= 1) {
            ToastWidget.showToast("updated", Colors.green);
          } else {
            ToastWidget.showToast("Something went wrong", Colors.red);
          }
        }
      else
        {
          if (permissionData[per_position].taskSelected) {
            sql = "insert into $currentdb.teacher_app_perm "
                "(id,branch,cname,section,permission) values "
                "('${nameData[selectedPosition].id}',"
                "'${branchinfo[lbranch]}',"
                "'${sectionData[sec_pos].cname}',"
                "'${sectionData[sec_pos].section=="*"?"":sectionData[sec_pos].section}',"
                "'${permissionData[per_position].pname}')";
          }
          else
          {
            sql="delete from $currentdb.teacher_app_perm where"
                " id='${nameData[selectedPosition].id}'"
                " and permission='${permissionData[per_position].pname}'"
                " and branch='${branchinfo[lbranch]}'"
                " and cname='${sectionData[sec_pos].cname}'"
                " and section='${sectionData[sec_pos].section=="*"?"":sectionData[sec_pos].section}'";
          }
          var result = await connection!.query(sql);
          if (result.affectedRows! >= 1) {
            ToastWidget.showToast("updated", Colors.green);
          } else {
            ToastWidget.showToast("Something went wrong", Colors.red);
          }
        }
      setState(() {
      });
    Navigator.of(context).pop();
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
    try {
    branchinfo.clear();
    List<String>? keyValuePairs = loginbranch?.split('-');
    for(String pair in keyValuePairs!)
    {
      List<String> parts = pair.split('_');
      branchinfo.addAll({parts[1]:parts[0]});
    }
      setState(() {});
      //await getClasses(1);
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
  void showLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.0),
                Text('Loading...'),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> showExamTermDialog(int permPosition,sectionpos) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState){
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [Text("Term 1"),
                      Checkbox(value: permissionData[permPosition].e1,
                          onChanged:(bool ? value){
                          setState(() {
                            permissionData[permPosition].e1=value;
                          });
                          }),
                    ],
                  ),
                  Row(
                    children: [Text("Term 2"),
                      Checkbox(value: permissionData[permPosition].e2,
                          onChanged:(bool ? value){
                            setState(() {
                              permissionData[permPosition].e2=value;
                            });
                          }),
                    ],
                  ),
                  TextButton(onPressed: () async {
                      Navigator.of(context).pop();
                      await savePermissionData(permPosition,sectionpos);
                  }, child: Text("Save"))
                ],
              ),
            ),
          );
        }
        );
      },
    );
  }
}

class PermissionData {
  String pname;
  bool ?e1,e2;
  bool taskSelected;


  PermissionData({required this.pname, required this.taskSelected,
    this.e1,this.e2});
}

class NameList {
  String name, id, pwd;
  NameList({required this.name, required this.id, required this.pwd});
}
class TeacherSections{
 String? cname,section,tecaherID;
 bool? checked;
 TeacherSections({this.cname,this.section,this.checked,this.tecaherID});
}
