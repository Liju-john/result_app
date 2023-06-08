import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:result_app/DocumentPanel.dart';
import 'package:result_app/MysqlHelper.dart';
import 'package:result_app/settings/InternetCheck.dart';
import 'package:result_app/widgets/DropDownWidgetNominalPage.dart';
import 'package:result_app/widgets/SelectDateNominal.dart';
import 'package:result_app/settings/Settings.dart';
import 'package:result_app/widgets/ToastWidget.dart';

class NominalPanel extends StatefulWidget {
  String currentdb = "", nextdb = "";
  bool admnoChange;
  double screenheight, screenwidth;
  mysql.MySqlConnection connection;
  String cname, section, branch, tid;

  NominalPanel(
      {Key? key,
      required this.currentdb,
      required this.nextdb,
      required this.connection,
      required this.cname,
      required this.section,
      required this.branch,
        required this.screenheight,
        required this.screenwidth,
        required this.admnoChange,
        required this.tid})
      : super(key: key);

  @override
  _NominalPanelState createState() => _NominalPanelState(
      this.currentdb,
      this.nextdb,
      this.connection,
      this.cname,
      this.section,
      this.branch,
      this.screenheight,
      this.screenwidth,
      this.admnoChange,
      this.tid);
}

class _NominalPanelState extends State<NominalPanel> {
  String currentdb = "", nextdb = "", tid = "";
  List<PhyDocData> phyData = [];
  List<VaccineData> vData = [];
  List gencount=[];
  int tcCount=0;
  File ? cameraFile;
  double screenheight, screenwidth;
  bool correctadmno = true, saveProgress = true, admnoChange = false;
  var myFormat = DateFormat('dd-MM-yyyy');
  MysqlHelper mysqlHelper = MysqlHelper();
  List<TextEditingController> snamecontroller = [],
      fnameController = [],
      mnamecontroller = [],
      admnocontroller = [],
      mobcontroller = [],
      castecontroller = [],
      aadharcontroller=[];
  List<GlobalKey<FormState>> gk = [];
  List<NominalData> data = [];
  String cname, section, branch;
  String selectedgen = "", selectedcat = "", selectedate = "", selectedRte = "";
  mysql.MySqlConnection connection;

  _NominalPanelState(
      this.currentdb,
      this.nextdb,
      this.connection,
      this.cname,
      this.section,
      this.branch,
      this.screenheight,
      this.screenwidth,
      this.admnoChange,
      this.tid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BACKGROUND,
      appBar: AppBar(
        title: Text('Nominal',style: GoogleFonts.playball(
          fontSize: screenheight / 30,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],),
        ),
        backgroundColor: AppColor.NAVIGATIONBAR,
      ),
      body: data.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
            children: [
              Row(children: [dataBox(backColor: AppColor.BACKGROUND!,border:
              false,height: 5)],),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                dataBox(data:"Girls",backColor: AppColor.BACKGROUND!,border:
                false,),dataBox(data:gencount[0][1].toString(),backColor:
                AppColor.BACKGROUND!,borderWidth: 2,bold: true),dataBox(data:
                  " +",border: false,backColor: AppColor.BACKGROUND!),
                  dataBox
                    (data:"Boys",
                      backColor:
                  AppColor
                      .BACKGROUND!,border:
                  false),dataBox(data:gencount[1][1].toString(),backColor:
                  AppColor.BACKGROUND!,borderWidth: 2,bold: true),dataBox(data:
                  " =",border: false,backColor: AppColor.BACKGROUND!),
                  dataBox
                    (data:"Total",
                      backColor:
                      AppColor
                          .BACKGROUND!,border:
                      false),dataBox(data:(gencount[1][1]+gencount[0][1])
                        .toString(),
                      backColor:
                  AppColor.BACKGROUND!,borderWidth: 2,bold: true,fsize: 18),
              ],),
              SizedBox(height: 4,),
              Visibility(visible: tcCount>0?true:false, child: Column(
                children: [
                  Row
                    (mainAxisAlignment: MainAxisAlignment.center, children:
                  [SizedBox
                    (width: 5,),
                    dataBox(data: "Taken TC After Term I",border: false,
                        backColor:
                    AppColor
                        .BACKGROUND!,textColor: Colors.red),dataBox(data: tcCount
                      .toString(),
                      borderWidth:
                      2,bold: true,borderColor: Colors.red,textColor: Colors.red,
                      backColor: AppColor.BACKGROUND!
                  )],),
                  SizedBox(height: 4,),
                ],
              )),
              Expanded(
                  flex: 1,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: data.length,
                    padding: const EdgeInsets.all(10.0),
                    itemBuilder: (context, position) {
                      selectedgen = data[position].gen;
                      selectedRte = data[position].rte;
                      selectedate = data[position].rte;
                      selectedcat = data[position].cat;
                      snamecontroller.add(TextEditingController());
                      fnameController.add(TextEditingController());
                      mnamecontroller.add(TextEditingController());
                      admnocontroller.add(TextEditingController());
                      mobcontroller.add(TextEditingController());
                      castecontroller.add(TextEditingController());
                      aadharcontroller.add(TextEditingController());
                      gk.add(GlobalKey<FormState>());
                      snamecontroller[position].text = data[position].sname;
                      fnameController[position].text = data[position].fname;
                      mnamecontroller[position].text = data[position].mname;
                      admnocontroller[position].text = data[position].admno;
                      mobcontroller[position].text = data[position].mobileno;
                      castecontroller[position].text = data[position].caste;
                      aadharcontroller[position].text=data[position].addhar;
                      if (selectedcat == "") {
                        selectedcat = "NA";
                      }
                      snamecontroller[position].addListener(() {
                        data[position].sname = snamecontroller[position].text;
                      });
                      return ExpansionTile(
                        collapsedBackgroundColor:
                            data[position].session_status=='After Term I'?Colors.limeAccent:(
                            position % 2 == 0 ?
                            Colors.blue[100] :
                            Colors
                        .blue[200]),
                        backgroundColor: Colors.grey[300],
                        leading: Text(
                          data[position].rollno.toString(),
                          style: TextStyle(
                              color: Colors.teal,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        title: Text(
                          data[position].sname.toString(),
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        maintainState: true,
                        children: [
                          Form(
                            key: gk[position],
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 5.0),
                              child: Column(
                                children:  [
                                  Visibility(
                                    visible: data[position].session_status=='After Term I'?true:false,
                                      child: Text("Current status:- Taken TC "
                                          "after "
                                          "term I",style:
                                      TextStyle(
                                          fontWeight: FontWeight.w900,color: Colors
                                          .red),)),
                                  SizedBox(width: 5),
                                  Row(
                                    children: [
                                      SizedBox(
                                          child: Text(
                                            'Name',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900),
                                          ),
                                          width: screenwidth * 0.22),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: TextFormField(
                                        validator: (value) {
                                          return value!.isNotEmpty
                                              ? null
                                              : "*required";
                                        },
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        controller: snamecontroller[position],
                                      ))
                                    ],
                                  ), // for name
                                  Row(
                                    children: [
                                      SizedBox(
                                          child: Text(
                                            "Father Name",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900),
                                          ),
                                          width: screenwidth * 0.22),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: TextFormField(
                                        validator: (value) {
                                          return value!.isNotEmpty
                                              ? null
                                              : "*required";
                                        },
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        controller: fnameController[position],
                                      ))
                                    ],
                                  ), //for fname
                                  Row(
                                    children: [
                                      SizedBox(
                                          child: Text(
                                            "Mother Name",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900),
                                          ),
                                          width: screenwidth * 0.22),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: TextFormField(
                                        validator: (value) {
                                          return value!.isNotEmpty
                                              ? null
                                              : "*required";
                                        },
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        controller: mnamecontroller[position],
                                      ))
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0,10,0,10),
                                    child: Row(
                                      children: [ SizedBox(
                                        child: Text(
                                          "Age",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900),
                                        ),
                                          width:screenwidth * 0.22
                                      ),
                                        SizedBox(width: 10,),
                                        Text(data[position].age,style: TextStyle(fontSize: 18),),
                                      ],
                                    ),
                                  ),//for age
                                  Row(
                                    children: [
                                      SizedBox(
                                          child: Text(
                                            "Admission no",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900),
                                          ),
                                          width: screenwidth * 0.22),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: TextFormField(
                                        readOnly: admnoChange ? false : true,
                                        validator: (value) {
                                          return value!.isNotEmpty
                                              ? correctadmno
                                                  ? null
                                                  : "Admission number already Exists"
                                              : "*required";
                                        },
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        controller: admnocontroller[position],
                                      )),
                                    ],
                                  ), //for admno
                                  Row(
                                    children: [ Text(
                                      "Date of Adm",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900),
                                    ),
                                      SizedBox(width: 10,),
                                      SelectDateRow(data, position,'doa'),],),
                                  Row(
                                    children: [
                                      Text(
                                        "Religion",
                                        style: TextStyle(fontWeight: FontWeight.w900),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: TextFormField(
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        controller: castecontroller[position],
                                      )),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Mobile No",
                                        style: TextStyle(fontWeight: FontWeight.w900),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: TextFormField(
                                              validator: (value) {
                                                return value!.isNotEmpty
                                                    ? (value
                                                    .length==10?null:"invalid number")
                                                    :"*required";
                                              },
                                              keyboardType: TextInputType.phone,
                                              textCapitalization:
                                                  TextCapitalization.characters,
                                              controller: mobcontroller[position],
                                              inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp('[0-9+]+'))
                                          ]))
                                    ],
                                  ), //for phone,Caste
                                  SizedBox(
                                    height: 5,
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      width: screenwidth,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "DOB",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900),
                                          ),
                                          SelectDateRow(data, position,'dob'),
                                          //calling row consist of datecontrol
                                          Text(
                                            'Gender',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          NominalDropDownMenu(
                                              data,
                                              position,
                                              selectedRte,
                                              selectedgen,
                                              selectedcat,
                                              "GEN"),
                                          SizedBox(
                                            width: 10,
                                          )
                                        ],
                                      ),
                                    ),
                                  ), //for DOB,gender,
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    width: screenwidth,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Category",
                                          style:
                                              TextStyle(fontWeight: FontWeight.w900),
                                        ),
                                        NominalDropDownMenu(
                                            data,
                                            position,
                                            selectedRte,
                                            selectedgen,
                                            selectedcat,
                                            "CAT"),
                                        Text(
                                          "RTE",
                                          style:
                                              TextStyle(fontWeight: FontWeight.w900),
                                        ),
                                        NominalDropDownMenu(
                                            data,
                                            position,
                                            selectedRte,
                                            selectedgen,
                                            selectedcat,
                                            "RTE"),
                                      ],
                                    ),
                                  ), //rte,category
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                          child: Text(
                                            "Aadhar No",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900),
                                          ),
                                          width: screenwidth * 0.22),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: TextFormField(
                                            validator: (value) {
                                              return value!.isNotEmpty
                                                  ? (value!
                                                  .length==12?null:"invalid aadhar "
                                                  "no")
                                                  : null;
                                            },
                                              keyboardType: TextInputType.number,
                                            controller: aadharcontroller[position],
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.allow(
                                                    RegExp('[0-9+]+'))]
                                          ))
                                    ],
                                  ),//adharno
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      /*Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.blueAccent, width: 2),
                                            borderRadius: BorderRadius.circular(10)),
                                        child: TextButton(
                                            onPressed: () async {
                                              vacineDetailWidget(position);
                                            },
                                            child: Text(
                                              'Vaccine Detail',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 20,
                                                  color: Colors.green),
                                            )), //for save data
                                      ),
                                      SizedBox(width: 10,),*/
                                     /* Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.blueAccent, width: 2),
                                            borderRadius: BorderRadius.circular(10)),
                                        child: TextButton(
                                            onPressed: () async {
                                              await isUniqueAdmno(
                                                  data[position].admno,
                                                  admnocontroller[position].text);
                                              if (gk[position]
                                                  .currentState
                                                  .validate()) {
                                                setState(() {
                                                  saveProgress = false;
                                                  data[position].admno =
                                                      admnocontroller[position].text;
                                                  data[position].sname =
                                                      snamecontroller[position].text;
                                                  data[position].caste =
                                                      castecontroller[position].text;
                                                  data[position].fname =
                                                      fnameController[position].text;
                                                  data[position].mname =
                                                      mnamecontroller[position].text;
                                                  data[position].mobileno =
                                                      mobcontroller[position].text;
                                                  data[position].addhar=
                                                  aadharcontroller[position].text;
                                                  updateNominalData(position);
                                                });
                                              } else {
                                                ToastWidget.showToast(
                                                    "Something went wrong",
                                                    Colors.red);
                                              }
                                            },
                                            child: saveProgress
                                                ? Text(
                                                    'Save',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w900,
                                                        fontSize: 20,
                                                        color: Colors.green),
                                                  )
                                                : CircularProgressIndicator(
                                                    backgroundColor: Colors.red,
                                                  )), //for save data
                                      )*/
                                    ],
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    }),
              ),
            ],
          ),
    );
  }
  Widget dataBox({String data="",double borderWidth=1,double margin=0,double
  height=30,double ? width,double fsize=15, bool border=true,Color
  borderColor=Colors.black,Color textColor=Colors.black,Color
  backColor=Colors.white,bool bold=false})
  {
    return Container(
      alignment:Alignment.center,
      width: width,
      height: height,
      margin: EdgeInsets.all(margin),
      padding: EdgeInsets.all(3.0),
      decoration: BoxDecoration(
          color: backColor,
          border: border?Border.all(color: borderColor,width: borderWidth):null
      ),
      child: Text(data,textAlign: TextAlign.center,style:TextStyle(color: textColor,
          fontSize: fsize,
          fontWeight: bold?FontWeight.w900:null),),
    );
  }

  void controllerDispose() {
    for (int i = 0; i < snamecontroller.length; i++) {
      snamecontroller[i].dispose();
      fnameController[i].dispose();
      mnamecontroller[i].dispose();
      mobcontroller[i].dispose();
      admnocontroller[i].dispose();
    }
  }

  void dispose() {
    super.dispose();
    controllerDispose();
  }

  void initState() {
    super.initState();
    getNominalData();
  }

  Future<void> uploadDocument(var image, int position, String doctype) async {
    final bytes = File(image).readAsBytesSync();
    String img64 = base64Encode(bytes);
    var postData = {
      "rowid": data[position].rowid,
      "tid": tid,
      "photo": img64,
      "doctype": doctype
    };
    var url = Uri.parse('http://117.247.90.209/app/result/docupload.php');
    var response = await http.post(url, body: postData);
    if (response.statusCode == 200) {
      ToastWidget.showToast(response.body, Colors.green);
    } else {
      ToastWidget.showToast("Please try again!!!", Colors.red);
    }
  }

  // Future<void> documentUploadWidget(int position) async {
  //   this.phyData.clear();
  //   bool showLoadingProgress=false;
  //   XFile cameraFile = null;
  //   String doctype = null;
  //   return showDialog<void>(
  //       context: this.context,
  //       barrierDismissible: false,
  //       builder: (context) {
  //         return StatefulBuilder(builder: (context, setState) {
  //           Future downloadDocument() async {
  //             try {
  //               List<PhyDocData> pdata = [];
  //               setState(() {});
  //               String query = "select doctype,doc from phydoc where "
  //                   "rowid='${data[position].rowid}'";
  //               var results = await connection.query(query);
  //               for (var rows in results) {
  //                 pdata
  //                     .add(PhyDocData(dtype: rows[0], doc: rows[1].toString()));
  //               }
  //               this.phyData = pdata;
  //               setState(() {});
  //             } catch (Exception) {
  //               print(Exception);
  //             }
  //           }
  //
  //           return AlertDialog(
  //             elevation: 10,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20.0),
  //             ),
  //             title: Center(
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(
  //                     data[position].rollno,
  //                     style: TextStyle(fontWeight: FontWeight.w900),
  //                   ),
  //                   Text(data[position].sname)
  //                 ],
  //               ),
  //             ),
  //             content: SingleChildScrollView(
  //               child: SizedBox(
  //                 height: screenheight * 0.7,
  //                 width: screenwidth * 0.9,
  //                 child: Column(
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         DropdownButton<String>(
  //                           value: doctype,
  //                           hint: Text("Document type"),
  //                           icon: const Icon(
  //                             Icons.arrow_downward,
  //                             color: Colors.blue,
  //                           ),
  //                           iconSize: 24,
  //                           elevation: 16,
  //                           onChanged: (String newValue) async {
  //                             setState(() {
  //                               doctype = newValue;
  //                             });
  //                           },
  //                           items: <String>[
  //                             'Photo',
  //                             'TC',
  //                             'BC',
  //                             'CC',
  //                             'Adhar'
  //                                 ' Number',
  //                             'Other'
  //                           ].map<DropdownMenuItem<String>>((String value) {
  //                             return DropdownMenuItem<String>(
  //                               value: value,
  //                               child: Text(value),
  //                             );
  //                           }).toList(),
  //                         ),
  //                         Visibility(
  //                           visible: doctype == null ? false : true,
  //                           child: ElevatedButton(
  //                               style: ButtonStyle(
  //                                   backgroundColor:
  //                                       MaterialStateProperty.all<Color>(
  //                                           Colors.deepPurpleAccent),
  //                                   shape: MaterialStateProperty.all<
  //                                           RoundedRectangleBorder>(
  //                                       RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.circular(18.0),
  //                                   ))),
  //                               onPressed: () async {
  //                                 cameraFile = await ImagePicker().pickImage(
  //                                     source: ImageSource.camera,
  //                                     imageQuality: 10);
  //                                 setState(() {});
  //                               },
  //                               child: Icon(Icons.camera)),
  //                         ),
  //                         ElevatedButton(
  //                             style: ButtonStyle(
  //                                 backgroundColor:
  //                                     MaterialStateProperty.all<Color>(
  //                                         Colors.deepPurpleAccent),
  //                                 shape: MaterialStateProperty.all<
  //                                         RoundedRectangleBorder>(
  //                                     RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(18.0),
  //                                 ))),
  //                             onPressed: () async {
  //                               showLoadingProgress=true;
  //                               downloadDocument();
  //                               setState(() {});
  //                             },
  //                             child: Text("Load"))
  //                       ],
  //                     ),
  //                     cameraFile == null
  //                         ? Text("")
  //                         : Column(
  //                             children: [
  //                               new Image.file(
  //                                 File(cameraFile.path),
  //                                 height: screenheight * 0.2,
  //                                 width: screenwidth * 0.2,
  //                               ),
  //                               ElevatedButton(
  //                                   style: ButtonStyle(
  //                                       backgroundColor:
  //                                           MaterialStateProperty.all<Color>(
  //                                               Colors.deepPurpleAccent),
  //                                       shape: MaterialStateProperty.all<
  //                                               RoundedRectangleBorder>(
  //                                           RoundedRectangleBorder(
  //                                         borderRadius:
  //                                             BorderRadius.circular(18.0),
  //                                       ))),
  //                                   onPressed: () async {
  //                                     uploadDocument(
  //                                         cameraFile.path, position, doctype);
  //                                     await downloadDocument();
  //                                     cameraFile=null;
  //                                     setState((){});
  //                                   },
  //                                   child: Icon(Icons.cloud_upload)),
  //                             ],
  //                           ),
  //                     Expanded(
  //                       child: showLoadingProgress==false?Text(""):phyData
  //                           .isEmpty
  //                           ? Center(child: CircularProgressIndicator())
  //                           : ListView.builder(
  //                               scrollDirection: Axis.vertical,
  //                               itemCount: phyData.length,
  //                               itemBuilder: (context, position) {
  //                                 return Column(
  //                                   children: [
  //                                     Text(
  //                                       phyData[position].dtype,
  //                                       style: TextStyle(
  //                                           fontWeight: FontWeight.w900),
  //                                     ),
  //                                     InkWell(
  //                                       child: Image.memory(
  //                                         base64Decode(phyData[position].doc),
  //                                         height: screenheight * 0.2,
  //                                         width: screenwidth * 0.2,
  //                                       ),
  //                                       onTap: () {
  //                                         Navigator.of(context).push(
  //                                             MaterialPageRoute(
  //                                                 builder: (context) =>
  //                                                     ShowImage(
  //                                                       data: base64Decode(
  //                                                           phyData[position]
  //                                                               .doc),
  //                                                     )));
  //                                       },
  //                                     ),
  //                                   ],
  //                                 );
  //                               }),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         });
  //       });
  // }
  Future<void> vacineDetailWidget(int position) async {
    return showDialog<void>(
        context: this.context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            Future downloadDocument() async {
              try {
                List<VaccineData> vData = [];
                setState(() {});
                String query = "select vname,dov1,dov2,remark from "
                    "vaccine_detail "
                    "where "
                    "rowid='${data[position].rowid}'";
                var results = await connection.query(query);
                for (var rows in results) {
                 vData.add(VaccineData(vname:rows[0],dov1:rows[1],dov2: rows[2],
                     remark: rows[3]));
                }
                setState(() {});
              } catch (Exception) {
                print(Exception);
              }
            }
            return AlertDialog(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data[position].rollno,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(data[position].sname)
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  height: screenheight * 0.7,
                  width: screenwidth * 0.9,
                  child: Column(
                    children: [
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  Future updateNominalData(int position) async {
    setState(() {
      saveProgress = false;
    });
    var postData = {
      "rowid": '${data[position].rowid}',
      "sname": '${data[position].sname}',
      "fname": '${data[position].fname}',
      "mname": '${data[position].mname}',
      "admno": '${data[position].admno}',
      "rte": '${data[position].rte}',
      "mobileno": '${data[position].mobileno}',
      "dob": '${data[position].dob}',
      "gen": '${data[position].gen}',
      "cat": '${data[position].cat}',
      "caste": '${data[position].caste}',
      "doa":'${data[position].doa}',
      "aadhar":'${data[position].addhar}'
    };
    var url = Uri.parse('http://117.247.90.209/app/result/updateNominal.php');
    var response = await http.post(url, body: postData);
    if (response.statusCode == 200) {
      ToastWidget.showToast(response.body, Colors.green);
    } else {
      ToastWidget.showToast("Something Went Wrong!!!!", Colors.red);
    }
    setState(() {
      saveProgress = true;
    });
  }

  Future getNominalData() async {
    try {
      String query;
     List<NominalData> data=[];
      query = "select rowid,rollno,admno,sname,mname,fname,dob,cat,caste,gen,"
          "mobileno,rte,doa,addhar,session_status from `$currentdb`.`nominal` "
          "where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null order by rollno";
      var results = await connection.query(query);
      for (var rows in results) {
        DateTime birthDate=new DateFormat("dd-MM-yyyy").parse(rows[6]==""?"29-01-2022":rows[6]);
        DateTime currentDate = DateTime.now();
        int years = currentDate.year - birthDate.year;
        int months = currentDate.month - birthDate.month;
        int days = currentDate.day - birthDate.day;

        if (days < 0) {
          months--;
          days += DateTime(currentDate.year, currentDate.month - 1, 0).day;
        }

        if (months < 0) {
          years--;
          months += 12;
        }
        data.add(NominalData(
            rowid: rows[0].toString(),
            rollno: rows[1].toString(),
            admno: rows[2].toString(),
            sname: rows[3].toString(),
            mname: rows[4].toString(),
            fname: rows[5].toString(),
            dob: rows[6].toString(),
            cat: rows[7].toString(),
            caste: rows[8].toString(),
            gen: rows[9],
            mobileno: rows[10],
            rte: rows[11],
            doa:rows[12],
            addhar:rows[13],
            session_status: rows[14],
        age: "${years} years ${months} months ${days} days"));
        if(rows[14]=='After Term I')
          {
            tcCount+=1;
          }
      }
      query="select gen,count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' and section='$section' and branch='$branch' and "
          "rollno not in('',' ') and rollno is not null and session_status "
          "not in('after term I') group "
          "by gen order by gen";
      results=await connection.query(query);
      for(var rows in results)
      {
        gencount.add([rows[0],rows[1]]);
      }
      if(gencount.length<2)
        {
          if(gencount[0]=='M')
            {
              gencount.add(['F',0]);
            }
          else
            {
              gencount.add(['M',0]);
            }
        }
      this.data=data;
      setState(() {});
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast(
              "Reconnecting to server, please wait!!!", Colors.red);
          await getConnection();
          await getNominalData();
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
    if (connection != null) {
      await connection.close();
    }
    connection = await mysqlHelper.Connect();
  }

  Future isUniqueAdmno(String admno, String value) async {
    try {
      int count = 0;
      if (admno == value) {
        setState(() {
          correctadmno = true;
        });
        return true;
      } else {
        var results = await connection.query(
            "select count(*) from `kpsbspin_master`.`studmaster` where admno='$value'");
        for (var row in results) {
          count = row[0];
        }
        if (count > 0) {
          setState(() {
            correctadmno = false;
          });
          return false;
        } else {
          setState(() {
            correctadmno = true;
          });
          return true;
        }
      }
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast(
              "Reconnecting to server, please wait!!!", Colors.red);
          await getConnection();
          await getNominalData();
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
}

class NominalData {
  String rowid,
      rollno,
      admno,
      sname,
      mname,
      fname,
      dob,
      cat,
      caste,
      gen,
      mobileno,
      rte,
      doa,
      addhar,session_status,age;

  NominalData(
      {
        required this.rowid,
        required this.rollno,
        required this.admno,
        required this.sname,
        required this.mname,
        required this.fname,
        required this.dob,
        required this.cat,
        required this.caste,
        required this.gen,
        required this.mobileno,
        required this.rte,
        required this.doa,
        required this.addhar,
        required this.session_status,
      required this.age});
}

class PhyDocData {
  String dtype, doc, rowid;

  PhyDocData({required this.dtype, required this.doc, required this.rowid});
}
class VaccineData
{
  String vname,dov1,dov2,remark;
  VaccineData({required this.vname,required this.dov1,required this.dov2,required this.remark});
}

class ShowImage extends StatefulWidget {
  ShowImage({Key? key, required this.data}) : super(key: key);
  Uint8List data;

  @override
  _ShowImageState createState() => _ShowImageState(this.data);
}

class _ShowImageState extends State<ShowImage> {
  Uint8List ? data = null;

  _ShowImageState(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(child: Image.memory(data!));
  }
}
