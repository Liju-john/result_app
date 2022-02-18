import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:result_app/settings/InternetCheck.dart';
import 'package:result_app/settings/Settings.dart';
import 'package:result_app/widgets/ToastWidget.dart';
import 'package:http/http.dart' as http;

import 'MysqlHelper.dart';

class AddNewStudent extends StatefulWidget {
  String previousDB,currentdb = "", nextdb = "";
  mysql.MySqlConnection connection;
  double screenheight, screenwidth;
  String branch;
  List<String> cnameList = [];

  AddNewStudent(
      {Key key,
      this.currentdb,
      this.nextdb,
      this.connection,
      this.cnameList,
      this.branch,
      this.screenheight,
      this.screenwidth,this.previousDB})
      : super(key: key);

  @override
  _AddNewStudentState createState() => _AddNewStudentState(
      this.currentdb,
      this.nextdb,
      this.connection,
      this.cnameList,
      this.branch,
      this.screenheight,
      this.screenwidth,this.previousDB);
}

class _AddNewStudentState extends State<AddNewStudent> {
  List<Data> data=[];
  bool saveProgress = true,
      isAdmnoUnique = true,
      checkAdmnoLoading = true,
      admnoYesNOVisible = false,
      admnoRecheck = true,searchProgress=false,showWarning=false,showOk=false;
  MysqlHelper mysqlHelper = MysqlHelper();
  DateTime selectedDate = DateTime.now();
  var myFormat = DateFormat('dd-MM-yyyy');
  String getdate = "";
  String previousDB,currentdb = "", nextdb = "", _cat, _gen, _rte,
  selectedClass, admno;
  mysql.MySqlConnection connection;
  double screenheight, screenwidth;
  List<String> cnameList = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController fnameController = TextEditingController();
  TextEditingController mnameController = TextEditingController();
  TextEditingController mobController = TextEditingController();
  TextEditingController admnoController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController doaController = TextEditingController();
  TextEditingController casteController = TextEditingController();
  TextEditingController aadharController = TextEditingController();
  String branch;
  GlobalKey<FormState> _formKey = GlobalKey();

  _AddNewStudentState(this.currentdb, this.nextdb, this.connection,
      this.cnameList, this.branch, this.screenheight, this.screenwidth,this.previousDB);

  void initState() {
    // TODO: implement initState
    super.initState();
    selectedClass = cnameList[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.BACKGROUND,
        appBar: AppBar(
          title: Text(
            'New Student',
            style: GoogleFonts.playball(
              fontSize: screenheight / 30,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          backgroundColor: AppColor.NAVIGATIONBAR,
        ),
        body: Card(
            elevation: 10,
            color: Colors.blue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: BorderSide(
                color: Colors.red,
                width: 3,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(mainAxisSize: MainAxisSize.min,
                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: textTypeBox(nameController, "Name",
                                    "name.svg", true, false)),
                            SizedBox(
                              width: 5,
                            ),
                  Visibility(visible: showOk,
                      child:new SvgPicture.asset
                    ("assets/images/correct.svg",width: 30,height:
                  30,)),
                            Visibility(visible: showWarning,
                                child:new SvgPicture.asset
                                  ("assets/images/warning.svg",width: 30,height:
                                30,)),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.blueAccent),
                        borderRadius:
                        BorderRadius.circular(10)),
                    child:
                            searchProgress?CircularProgressIndicator(backgroundColor: Colors.red,):
                            TextButton(
                                onPressed: () async {
                                  _getStudentList();

                                },
                                child: Text(
                                  'Search',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: Colors.blue),
                                )))
                          ],
                        ), //name
                        Row(
                          children: [
                            Expanded(
                                child: textTypeBox(fnameController,
                                    "Father Name", "father.svg", false, false)),
                            SizedBox(
                              width: 5,
                            )
                          ],
                        ), //fname
                        Row(
                          children: [
                            Expanded(
                                child: textTypeBox(mnameController,
                                    "Mother Name", "mother.svg", false, false)),
                            SizedBox(
                              width: 5,
                            )
                          ],
                        ), //mname
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: admnoTextBox(admnoController,
                                    "Admission Number", "admission.svg")),
                            Visibility(
                                visible: admnoYesNOVisible,
                                child: new SvgPicture.asset(
                                  "assets/images/${isAdmnoUnique ? "success.svg" : "error.svg"}",
                                  width: 30,
                                  height: 30,
                                )),
                            SizedBox(
                              width: 5,
                            ),
                            checkAdmnoLoading
                                ? Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.blueAccent),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: TextButton(
                                        onPressed: () async {
                                          if (admnoController.text == "") {
                                            ToastWidget.showToast(
                                                "No admission number entered",
                                                Colors.red);
                                          } else {
                                            //FocusScope.of(context).unfocus();
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                            await isUniqueAdmno(
                                                admnoController.text);
                                          }
                                        },
                                        child: Text(
                                          'Check',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                              color: Colors.blue),
                                        )))
                                : CircularProgressIndicator(
                                    backgroundColor: Colors.red,
                                  )
                          ],
                        ), //admno,check
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: aadharController,
                              validator: (value) {
                                return value.isNotEmpty
                                    ? value.length == 12
                                        ? null
                                        : "12 digits required"
                                    : null;
                              },
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9]+'))
                              ],
                              decoration: InputDecoration(
                                icon: new SvgPicture.asset(
                                  "assets/images/idcard.svg",
                                  width: 35,
                                  height: 35,
                                ),
                                labelText: "Aadhar card",
                              ),
                            )),
                            SizedBox(
                              width: 5,
                            )
                          ],
                        ), //Aadhar number
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                validator: (value) {
                                  return value.isNotEmpty ? null : "*required";
                                },
                                readOnly: true,
                                controller: doaController,
                                decoration: InputDecoration(
                                    icon: new SvgPicture.asset(
                                      "assets/images/doa.svg",
                                      width: 30,
                                      height: 30,
                                    ),
                                    labelText: "Date of admission"),
                              ),
                            ),
                            IconButton(
                                icon: SvgPicture.asset(
                                  "assets/images/calendar.svg",
                                  height: 40,
                                  width: 40,
                                ),
                                onPressed: () async {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  getdate = "";
                                  showDateDialog(context, child: datePicker(),
                                      onClicked: () {
                                    setState(() {
                                      if (getdate.isNotEmpty)
                                        doaController.text = getdate;
                                    });
                                    Navigator.pop(context);
                                  });
                                }),
                          ],
                        ), //DOA
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                validator: (value) {
                                  return value.isNotEmpty ? null : "*required";
                                },
                                readOnly: true,
                                controller: dobController,
                                decoration: InputDecoration(
                                    icon: new SvgPicture.asset(
                                      "assets/images/birthday.svg",
                                      width: 30,
                                      height: 30,
                                    ),
                                    labelText: "Date of birth"),
                              ),
                            ),
                            IconButton(
                                icon: SvgPicture.asset(
                                  "assets/images/calendar.svg",
                                  height: 40,
                                  width: 40,
                                ),
                                onPressed: () async {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  /* await _selectDate(context);
                    if(getdate.isNotEmpty)
                    {
                      setState(() {
                        dobController.text=getdate;
                      });
                    }*/
                                  getdate = "";
                                  showDateDialog(context, child: datePicker(),
                                      onClicked: () {
                                    setState(() {
                                      if (getdate.isNotEmpty)
                                        dobController.text = getdate;
                                    });
                                    Navigator.pop(context);
                                  });
                                }),
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.blue),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Class",
                                        style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 17),
                                      )
                                    ],
                                  ),
                                  Container(
                                      child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/images/class.svg",
                                        width: 20,
                                        height: 20,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      classListWidget()
                                    ],
                                  )),
                                ],
                              ),
                            )
                          ],
                        ), //dob,class
                        Row(
                          children: [
                            Expanded(
                                child: textTypeBox(casteController, "Religion",
                                    "group.svg", false, false)),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: numTypeBox(mobController,
                                    "Mobile Number", "phone-call.svg"))
                          ],
                        ), //religion,phone
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 2, right: 2),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey[300], width: 2),
                                  borderRadius: BorderRadius.circular(15)),
                              child: DropdownButton<String>(
                                value: _cat,
                                hint: Row(children: [
                                  new SvgPicture.asset(
                                    "assets/images/category.svg",
                                    width: 30,
                                    height: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('Category')
                                ]),
                                icon: const Icon(Icons.arrow_downward,
                                    color: Colors.blue),
                                iconSize: 24,
                                elevation: 16,
                                onChanged: (String newValue) {
                                  setState(() {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    _cat = newValue;
                                  });
                                },
                                items: <String>[
                                  'NA',
                                  'GENERAL',
                                  'SC',
                                  'ST',
                                  'OBC'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Row(children: [
                                      Icon(
                                        Icons.select_all,
                                        color: Colors.green,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(value)
                                    ]),
                                  );
                                }).toList(),
                              ),
                            ), //category
                            Container(
                              padding: EdgeInsets.only(left: 2, right: 2),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey[300], width: 2),
                                  borderRadius: BorderRadius.circular(15)),
                              child: DropdownButton<String>(
                                value: _rte,
                                hint: Row(children: [
                                  new SvgPicture.asset(
                                    "assets/images/rte.svg",
                                    width: 30,
                                    height: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text('RTE')
                                ]),
                                icon: const Icon(Icons.arrow_downward,
                                    color: Colors.blue),
                                iconSize: 24,
                                elevation: 16,
                                onChanged: (String newValue) {
                                  setState(() {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    _rte = newValue;
                                  });
                                },
                                items: <String>[
                                  'NO',
                                  'YES'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Row(children: [
                                      value == 'YES'
                                          ? SvgPicture.asset(
                                              "assets/images/yes.svg",
                                              width: 20,
                                              height: 20,
                                            )
                                          : SvgPicture.asset(
                                              "assets/images/no.svg",
                                              width: 20,
                                              height: 20,
                                            ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(value)
                                    ]),
                                  );
                                }).toList(),
                              ),
                            ) //rte
                          ],
                        ), //cat,rte
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 2, right: 2),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey[300], width: 2),
                                    borderRadius: BorderRadius.circular(15)),
                                child: DropdownButton<String>(
                                  value: _gen,
                                  hint: Row(children: [
                                    new SvgPicture.asset(
                                      "assets/images/gender.svg",
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Gender',
                                    )
                                  ]),
                                  icon: const Icon(Icons.arrow_downward,
                                      color: Colors.blue),
                                  iconSize: 24,
                                  elevation: 16,
                                  onChanged: (String newValue) {
                                    setState(() {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      _gen = newValue;
                                    });
                                  },
                                  items: <String>['F', 'M']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Row(children: [
                                        value == 'F'
                                            ? new SvgPicture.asset(
                                                "assets/images/female.svg",
                                                width: 20,
                                                height: 20,
                                              )
                                            : new SvgPicture.asset(
                                                "assets/images/male.svg",
                                                width: 20,
                                                height: 20,
                                              ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(value)
                                      ]),
                                    );
                                  }).toList(),
                                ),
                              ), //gender
                              saveProgress
                                  ? Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.blueAccent),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: TextButton(
                                          onPressed: () async {
                                            if (_cat != null ||
                                                _rte != null ||
                                                _gen != null) {
                                              if (_formKey.currentState
                                                  .validate()) {
                                                await _saveNominal();
                                              }
                                            } else {
                                              ToastWidget.showToast(
                                                  "RTE or category or gender is not selected",
                                                  Colors.red);
                                            }
                                          },
                                          child: Text(
                                            'Save',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 25,
                                                color: Colors.green),
                                          )))
                                  : CircularProgressIndicator(
                                      backgroundColor: Colors.red,
                                    ),
                              SizedBox(
                                width: screenwidth * 0.2,
                              )
                            ]), //gender,dob
                        SizedBox(
                          height: 10,
                        ),
                      ]),
                ),
              ),
            )));
  }

  Future<void> _checkStudentDialog() {
    return showDialog<void>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context,setState){
          return AlertDialog(
            backgroundColor: AppColor.BACKGROUND,
            scrollable: true,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Center(
              child: Text('Student List',
                style: GoogleFonts.playball(
                  fontSize: screenheight / 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),),
            ),
            content:Container(
              height: screenheight*0.5,
              child: ListView.builder(itemCount: data.length,itemBuilder: (context,
                  position){
                return Card(
                  color: position%2==0?Colors.lime:Colors.grey,
                  child: Container(
                    padding: EdgeInsets.only(left: 5,right: 2,top: 5,bottom: 5),
                    child: Column(children: [
                    Row(
                    children: [Text("Session:-"),
                    Text(data[position].session,style: TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),Row(
                      children: [Text("Admno:-"),
                        Text(data[position]
                            .admno,style: TextStyle(fontWeight: FontWeight.w900),),
                      ],
                    ),Row(
                      children: [Text("Name:-"),
                        Expanded(
                          child: Text(data[position]
                            .sname,style: TextStyle(fontWeight: FontWeight.w900),),
                        ),
                      ],
                    ),Row(
                      children: [Text("Father Name:-"),
                        Expanded(child: Text(data[position].fname,style: TextStyle(fontWeight: FontWeight.w900))),
                      ],
                    ),Row(
                      children: [
                        Text("Mother Name:-"),
                        Expanded(
                          child: Text(data[position]
                            .mname,style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),Row(
                      children: [Text("DOB:-"),
                        Expanded(child: Text(data[position].dob,style: TextStyle(fontWeight: FontWeight.w900))),
                      ],
                    ),Row(
                      children: [Text("Branch:-"),
                        Text(data[position].branch,style: TextStyle(fontWeight:
                        FontWeight.w900)),
                      ],
                    )
                      ,Row(
                  children: [Text("Class:-"),
                    Text(data[position].cname,style: TextStyle
                      (fontWeight: FontWeight.w900)),]),
                      Row(
                      children: [Text("Session Status:-"),
                        Expanded(
                          child: Text(data[position].session_satus,style: TextStyle
                            (fontWeight: FontWeight.w900)),
                        ),
                      ],
                    )
                ],),
                  ),);
              }),
            )
          );
        });});
  }

  Widget textTypeBox(TextEditingController controller, String hintText,
      String iconName, bool validationRequired, bool onTap) {
    return TextFormField(
      style: onTap
          ? TextStyle(color: isAdmnoUnique ? Colors.black : Colors.red)
          : null,
      textCapitalization: TextCapitalization.characters,
      controller: controller,
      onTap: onTap
          ? () {
              admnoRecheck = true;
              setState(() {
                isAdmnoUnique = true;
                admnoYesNOVisible = false;
              });
            }
          : null,
      validator: validationRequired
          ? (value) {
              return value.isNotEmpty ? null : "*required";
            }
          : null,
      decoration: InputDecoration(
        icon: new SvgPicture.asset(
          "assets/images/" + iconName,
          width: 30,
          height: 30,
        ),
        labelText: hintText,
      ),
    );
  }

  Widget numTypeBox(
      TextEditingController controller, String hintText, String iconName) {
    return TextFormField(
      keyboardType: TextInputType.phone,
      controller: controller,
      validator: (value) {
        return value.isNotEmpty
            ? value.length == 10
                ? null
                : "10 digits required"
            : "*required";
      },
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp('[0-9]+'))
      ],
      decoration: InputDecoration(
        icon: new SvgPicture.asset(
          "assets/images/" + iconName,
          width: 30,
          height: 30,
        ),
        labelText: hintText,
      ),
    );
  }

  Widget admnoTextBox(
      TextEditingController controller, String hintText, String iconName) {
    return TextFormField(
      keyboardType: TextInputType.number,
      style: TextStyle(color: isAdmnoUnique ? Colors.black : Colors.red),
      onTap: () {
        admnoRecheck = true;
        setState(() {
          isAdmnoUnique = true;
          admnoYesNOVisible = false;
        });
      },
      controller: controller,
      validator: (value) {
        return value.isNotEmpty ? null : "*required";
      },
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp('[0-9]+'))
      ],
      decoration: InputDecoration(
        icon: new SvgPicture.asset(
          "assets/images/" + iconName,
          width: 30,
          height: 30,
        ),
        labelText: hintText,
      ),
    );
  }

  Widget classListWidget() {
    return DropdownButton<String>(
      icon: const Icon(Icons.arrow_downward_outlined, color: Colors.blue),
      iconSize: 24,
      elevation: 16,
      value: selectedClass,
      onChanged: (String newValue) {
        setState(() {
          FocusScope.of(context).requestFocus(FocusNode());
          selectedClass = newValue;
        });
      },
      items: cnameList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1990, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        getdate = myFormat.format(selectedDate).toString();
      });
  }

  static void showDateDialog(BuildContext context,
          {Widget child, VoidCallback onClicked}) =>
      showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoActionSheet(
                actions: [child],
                cancelButton: CupertinoActionSheetAction(
                  child: Text("Done"),
                  onPressed: onClicked,
                ),
              ));

  Widget datePicker() => SizedBox(
        height: 150,
        child: CupertinoDatePicker(
          initialDateTime: DateTime.now(),
          backgroundColor: AppColor.BACKGROUND,
          maximumYear: DateTime.now().year,
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (dateTime) => setState(() {
            selectedDate = dateTime;
            getdate = myFormat.format(selectedDate).toString();
          }),
        ),
      );

  Future _saveNominal() async {
    try {
      setState(() {
        saveProgress = false;
      });
      if (admnoRecheck) // if check button is not pressed
      {
        await isUniqueAdmno(admnoController.text);
      }

      if (!isAdmnoUnique) {
        ToastWidget.showToast("Admission number already exists", Colors.red);
      } else {
        //post data
        var postData = {
          "current_db": currentdb,
          "next_db": nextdb,
          "sname": '${nameController.text}',
          "fname":
              '${fnameController.text == null ? "" : fnameController.text}',
          "mname":
              '${mnameController.text == null ? "" : mnameController.text}',
          "admno": this.admno,
          "rte": _rte,
          "mobileno": '${mobController.text}',
          "dob": '${dobController.text}',
          "gen": _gen,
          "cat": _cat,
          "caste":
              '${casteController.text == null ? "" : casteController.text}',
          "cname": selectedClass,
          "branch": branch,
          "doa": '${doaController.text}',
          "aadhar":
              '${aadharController.text == null ? "" : aadharController.text}'
        };
        /* for(var i in postData.entries)
            {
              print(i);
            }*/
        var url = Uri.parse('https://kpsbsp.in/result/addStudent.php');
        var response = await http.post(url, body: postData);
        if (response.statusCode == 200) {
          ToastWidget.showToast(response.body, Colors.green);
          setState(() {
            nameController.text = "";
            fnameController.text = "";
            mnameController.text = "";
            admnoController.text = "";
            dobController.text = "";
            doaController.text = "";
            aadharController.text = "";
            casteController.text = "";
            mobController.text = "";
            _rte = null;
            _gen = null;
            _cat = null;
          });
        } else {
          ToastWidget.showToast(response.reasonPhrase, Colors.green);
        }
      }
      setState(() {
        saveProgress = true;
        showOk=false;
        showWarning=false;
      });
    } catch (Exception) {
      setState(() {
        saveProgress = true;
        showOk=false;
        showWarning=false;
      });
      ToastWidget.showToast(Exception.toString(), Colors.red);
    }
  }
  Future _getStudentList() async{
    //rowid,sname,fname,mname,admno,dob
    try{
    List<Data> data=[];
    setState(() {
      searchProgress=true;
      showOk=false;
      showWarning=false;
    });
    var postData = {
      "previous_db":previousDB,
      "current_db": currentdb,
      "next_db": nextdb,
      "sname": '${nameController.text}'};
    var url = Uri.parse('https://kpsbsp.in/result/findDuplicateStudent.php');
    var response = await http.post(url, body: postData);
    if (response.statusCode == 200) {
      var jasonData=json.decode(response.body);
      for(var rows in jasonData)
      {
        String session= rows['session'].toString().substring(rows['session'].toString()
            .indexOf("_s")+2,rows['session'].toString()
            .indexOf("_s")+4)+"-"+rows['session'].toString().substring
          (rows['session'].toString()
            .indexOf("_s")+4,rows['session'].toString()
            .indexOf("_s")+6);
        String branch=rows['branch'].toString()=="1"?"Koni":(rows['branch']
            .toString()=="2"?"Narmada nagar":(rows['branch'].toString()
            =="3"?"Sakri":"KV"));
       data.add(Data(rowid: rows['rowid'],sname: rows['sname'],fname:
       rows['fname'],
           mname:
       rows['mname'],admno: rows['admno'],dob: rows['dob'],session:session,
           session_satus: rows['session_status'],cname:
           rows['cname'],branch: branch));
      }
    }
    if(data.length<=0)
      {
        setState(() {
          searchProgress=false;
          if(nameController.text!="")
          showOk=true;
        });
      }
    else
    setState(() {
      this.data=data;
      _checkStudentDialog();
      searchProgress=false;
      showWarning=true;
    });
    }catch(Exception)
    {
      ToastWidget.showToast(Exception.toString(), Colors.red);
      print(Exception.toString());
      setState(() {
        searchProgress=false;
      });

    }
  }

  Future isUniqueAdmno(String admno) async {
    try {
      if (branch == '1') {
        this.admno = admno;
      } else if (branch == '2') {
        this.admno = "NN" + admno;
      } else if (branch == '3') {
        this.admno = "AC" + admno;
      } else if (branch == '4') {
        this.admno = "KV" + admno;
      }
      print(this.admno);
      int count = 0;
      setState(() {
        checkAdmnoLoading = false;
      });
      var results = await connection.query("select count(*) from "
          "`kpsbspin_master`.`studmaster` where admno='${this.admno}'");
      for (var row in results) {
        count = row[0];
      }
      if (count > 0) {
        admnoRecheck = false;
        setState(() {
          admnoYesNOVisible = true;
          isAdmnoUnique = false;
          checkAdmnoLoading = true;
          return;
        });
      } else {
        admnoRecheck = false;
        setState(() {
          admnoYesNOVisible = true;
          checkAdmnoLoading = true;
          isAdmnoUnique = true;
          return;
        });
      }
      /*setState(() {
          checkAdmnoLoading=true;
        });*/
      //admnoRecheck=true;
    } catch (Exception) {
      admnoRecheck = true;
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast(
              "Reconnecting to server, please wait!!!", Colors.red);
          await getConnection();
          await isUniqueAdmno(admno);
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

  Future getConnection() async {
    connection = await mysqlHelper.Connect();
  }
}
class Data
{
  String rowid="",admno="",sname="",fname="",mname="",dob="",session="",
      session_satus='',cname='',branch='';
  Data({this.rowid,this.admno,this.sname,this.fname,this.mname,this.dob,this
      .session,this.session_satus,this.cname,this.branch});
}
