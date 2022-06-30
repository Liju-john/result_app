import 'dart:async';
import 'package:age/age.dart';
import 'dart:io';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:result_app/MysqlHelper.dart';
import 'package:result_app/settings/InternetCheck.dart';
import 'package:result_app/settings/Settings.dart';
import 'package:result_app/widgets/ToastWidget.dart';

class VaccinePanel extends StatefulWidget {
  String currentdb = "", nextdb = "";
  bool admnoChange;
  double screenheight, screenwidth;
  mysql.MySqlConnection connection;
  String cname, section, branch, tid;

  VaccinePanel(
      {Key key,
      this.currentdb,
      this.nextdb,
      @required this.connection,
      @required this.cname,
      @required this.section,
      @required this.branch,
      this.screenheight,
      this.screenwidth,
      this.admnoChange,
      this.tid})
      : super(key: key);

  @override
  _VaccinePanelState createState() => _VaccinePanelState(
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

class _VaccinePanelState extends State<VaccinePanel> {
  String currentdb = "", nextdb = "", tid = "";
  List gencount=[];
  int tcCount=0;
  int eligible,notEligible,vaccinated;
  DateTime selectedDate = DateTime.now();
  String getdate="";
  File cameraFile;
  double screenheight, screenwidth;
  bool correctadmno = true, saveProgress = true, admnoChange = false;
  var myFormat = DateFormat('dd-MM-yyyy');
  MysqlHelper mysqlHelper = MysqlHelper();
  List<TextEditingController> snamecontroller = [],
      vnameController = [],
      dov1Controller = [],dobController = [],
      dov2Controller = [],
      dov3Controller = [],
      reasonController = [],
      remarkController=[],bidController=[],c1Controller=[],c2Controller=[],
      c3Controller=[];
  List<GlobalKey<FormState>> gk = [];
  List<VaccineData> data = [];
  String cname, section, branch;
  String selectedgen = "", selectedcat = "", selectedate = "", selectedRte = "";
  mysql.MySqlConnection connection;

  _VaccinePanelState(
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
        title: Text('Vaccine Detail',style: GoogleFonts.playball(
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
              Row(children: [dataBox(backColor: AppColor.BACKGROUND,border:
              false,height: 5)],),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                dataBox(data:"Girls",backColor: AppColor.BACKGROUND,border:
                false,),dataBox(data:gencount[0][1].toString(),backColor:
                AppColor.BACKGROUND,borderWidth: 2,bold: true),dataBox(data:
                  " +",border: false,backColor: AppColor.BACKGROUND),
                  dataBox
                    (data:"Boys",
                      backColor:
                  AppColor
                      .BACKGROUND,border:
                  false),dataBox(data:gencount[1][1].toString(),backColor:
                  AppColor.BACKGROUND,borderWidth: 2,bold: true),dataBox(data:
                  " =",border: false,backColor: AppColor.BACKGROUND),
                  dataBox
                    (data:"Total",
                      backColor:
                      AppColor
                          .BACKGROUND,border:
                      false),dataBox(data:(gencount[1][1]+gencount[0][1])
                        .toString(),
                      backColor:
                  AppColor.BACKGROUND,borderWidth: 2,bold: true,fsize: 18),
              ],),
              SizedBox(height: 4,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  dataBox(data:"Eligible",backColor: AppColor.BACKGROUND,border:
                  false,),dataBox(data:eligible.toString(),backColor:
                  AppColor.BACKGROUND,borderWidth: 2,bold: true),
                  dataBox
                    (data:"Vaccinated",
                      backColor:
                      AppColor
                          .BACKGROUND,border:
                      false),dataBox(data:vaccinated.toString(),backColor:
                  AppColor.BACKGROUND,borderWidth: 2,bold: true),
                  dataBox
                    (data:"Not eligible",
                      backColor:
                      AppColor
                          .BACKGROUND,border:
                      false),dataBox(data:(gencount[1][1]+gencount[0][1]-eligible)
                      .toString(),
                      backColor:
                      AppColor.BACKGROUND,borderWidth: 2,bold: true,fsize: 18),
                ],),
              SizedBox(height: 4,),
              Expanded(
                  flex: 1,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: data.length,
                    padding: const EdgeInsets.all(10.0),
                    itemBuilder: (context, position) {
                      selectedgen = data[position].gen;
                      snamecontroller.add(TextEditingController());
                      vnameController.add(TextEditingController());
                      dov1Controller.add(TextEditingController());
                      dov2Controller.add(TextEditingController());
                      dov3Controller.add(TextEditingController());
                      reasonController.add(TextEditingController());
                      remarkController.add(TextEditingController());
                      c1Controller.add(TextEditingController());
                      c2Controller.add(TextEditingController());
                      c3Controller.add(TextEditingController());
                      bidController.add(TextEditingController());
                      gk.add(GlobalKey<FormState>());
                      snamecontroller[position].text = data[position].sname;
                      if (selectedcat == "") {
                        selectedcat = "NA";
                      }
                      snamecontroller[position].addListener(() {
                        data[position].sname = snamecontroller[position].text;
                      });
                      dov1Controller[position].text=data[position].dov1;
                      dov2Controller[position].text=data[position].dov2;
                      c1Controller[position].text=data[position].c1;
                      c2Controller[position].text=data[position].c2;
                      c3Controller[position].text=data[position].c3;
                      remarkController[position].text=data[position].remark;
                      bidController[position].text=data[position].bid;
                      return ExpansionTile(
                        collapsedBackgroundColor: data[position]
                            .eligible=="Eligible"?Colors.yellow[400]:Colors
                            .orangeAccent,
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
                                  Row(
                                    children: [
                                      SizedBox(
                                          child: Text(
                                            'DOB',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900),
                                          ),
                                          width: screenwidth * 0.22),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: Text(data[position].dob,
                                            style: TextStyle(fontWeight:
                                            FontWeight.bold,fontSize: 18),)),

                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      SizedBox(
                                          child: Text(
                                            'Age',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900),
                                          ),
                                          width: screenwidth * 0.22),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: Text(data[position].age,
                                            style: TextStyle(fontWeight:
                                            FontWeight.bold,fontSize: 18),)),

                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      SizedBox(
                                          child: Text(
                                            'Aadhar No',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900),
                                          ),
                                          width: screenwidth * 0.22),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: Text(data[position].aadhar,
                                              style: TextStyle(fontWeight:
                                              FontWeight.bold,fontSize: 18)
                                          ))
                                    ],
                                  ),//
                                  SizedBox(height: 5,),
                                  Row(children: [
                                    SizedBox(
                                        child: Text(
                                          'Eligibility',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900),
                                        ),
                                        width: screenwidth * 0.22),
                                    Switch(inactiveTrackColor: Colors.red,
                                        activeTrackColor: Colors.green,
                                        inactiveThumbColor: Colors.orange,

                                        value: data[position]
                                      .eligible=="Eligible"?true:false,
                                      onChanged:(value){
                                        if(value)
                                        {
                                          data[position].eligible="Eligible";
                                        }
                                        else{data[position]
                                            .eligible="Not Eligible";
                                        data[position].dov1=data[position]
                                            .dov2=data[position].dov3= data[position]
                                            .c1=data[position].c2=data[position].c3=data[position]
                                            .bid=data[position]
                                            .vname=data[position]
                                            .remark=data[position]
                                            .reason=data[position].status="";

                                        }
                                        setState(() {
                                        });
                                      }),Text(data[position].eligible,style:
                                    TextStyle(fontWeight: FontWeight.w900,
                                        fontSize: 18),)
                                  ],),
                                  Visibility(visible:data[position]
                                      .eligible=="Eligible"?true:false,
                                      child:
                                  vaccineDetail
                      (position)),Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.blueAccent, width: 2),
                                          borderRadius: BorderRadius.circular(10)),
                                      child:data[position]
                                          .saveProgress?CircularProgressIndicator():TextButton
                                        (onPressed: (){
                                        if(data[position].eligible=="Eligible")
                                          {
                                        if(data[position].status=="")
                                      {
                                        ToastWidget.showToast("Select "
                                            "vaccination status", Colors.red);
                                      }
                                      else if(data[position].status=="Not Vaccinated")
                                      {

                                        if(data[position].reason=="")
                                          {
                                            ToastWidget.showToast("Select "
                                                "reason", Colors
                                                .red);
                                          }
                                        else
                                          {
                                            updateVaccineData(position);
                                          }
                                      }
                                      else
                                        {
                                          data[position]
                                              .remark=remarkController[position]
                                              .text;
                                          data[position]
                                              .bid=bidController[position]
                                              .text;
                                          data[position]
                                              .c1=c1Controller[position]
                                              .text;
                                          data[position]
                                              .c2=c2Controller[position]
                                              .text;
                                          data[position]
                                              .c3=c3Controller[position]
                                              .text;
                                          updateVaccineData(position);
                                        }
                                      }
                                        else
                                        {
                                          updateVaccineData(position);
                                        }
                                        }
                                       ,
                                          child: Text("Submit",style:
                                          TextStyle(fontWeight: FontWeight.w900),)))
                                 ]
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
  Widget vaccineDetail(int position)
  {
    return Column(children: [
      Widgets(data: data,position: position,type: "vname",),
    Row(
    children: [
    SizedBox(
    child: Text(
      'Beneficiary ID',
      style: TextStyle(
          fontWeight: FontWeight.w900),
    ),
    width: screenwidth * 0.22),
    Expanded(
    child: TextFormField(controller:
    bidController[position],),
    )
    ],
    ),
    Row(
    children: [
    SizedBox(
    child: Text(
    'DOV1',
    style: TextStyle(
    fontWeight: FontWeight.w900),
    ),
    width: screenwidth * 0.15),
      Widgets(content: "DOV1",data: data,position: position,date:data[position]
          .dov1,type: "dov",),
    /*dateRow("DOV1", position,data[position]
        .dov1),*/
    textTypeBox( c1Controller[position],
    "Certificate no.","certificate"
    ".svg",false)
    ],
    ),
    Row(
    children: [
    SizedBox(
    child: Text(
    'DOV2',
    style: TextStyle(
    fontWeight: FontWeight.w900),
    ),
    width: screenwidth * 0.15),
      Widgets(content: "DOV2",data: data,position: position,date:data[position]
          .dov2,type: "dov",)
    /*dateRow("DOV2", position,data[position]
        .dov2)*/,
      textTypeBox(c2Controller[position],
    "Certificate no.","certificate"
    ".svg",false)
    ],
    ),
    Row(
    children: [
    SizedBox(
    child: Text(
    'DOV3',
    style: TextStyle(
    fontWeight: FontWeight.w900),
  ),
  width: screenwidth * 0.15),
  /*dateRow("DOV3", position,data[position]
      .dov3),*/
      Widgets(content: "DOV3",data: data,position: position,date:data[position]
          .dov3,type: "dov",),
  textTypeBox(c3Controller[position],
  "Certificate no.","certificate"
  ".svg",false),
  ],
    ),
      Row(
        children: [
          textTypeBox(remarkController[position],
              "Teacher's remark, if any","remark"
                  ".svg",false),
        ],
      ),
      Row(children: [Text('Vaccination status',style: TextStyle(fontWeight:
      FontWeight.w900,fontSize: 15),)],),
      /*Column(
        children: [
          ListTile(
            title: const Text('1st Dose'),
            leading: Radio<String>(
                value:"1st Dose",
                groupValue: data[position].status,
                onChanged:(value){
                  if(data[position].dov1=="")
                    ToastWidget.showToast("Fill date of first dose", Colors
                        .red);
                  else
                    {
                  setState((){
                    if(data[position].status=="2nd Dose")
                        data[position].status="2nd Dose";
                    else if(data[position].status=="Booster")
                      data[position].status="Booster";
                    else
                    data[position].status=value;
                  });}
                }
            ),
          ),
          ListTile(
            title: const Text('2nd Dose'),
            leading: Radio<String>(
                value:"2nd Dose",
                groupValue: data[position].status,
                onChanged:(value){
                  if(data[position].dov1=="" || data[position].dov2=="")
                    ToastWidget.showToast("Date of first or second dose is "
                        "missing", Colors
                        .red);
                  else
                  {
                    setState((){
                      if(data[position].status=="Booster")
                      {
                        data[position].status="Booster";
                      }
                      else
                        data[position].status=value;
                    });}
                }
            ),
          ),
          ListTile(
            title: const Text('Booster'),
            leading: Radio<String>(
                value:"Booster",
                groupValue: data[position].status,
                onChanged:(value){
                  if(data[position].dov1=="" || data[position]
                      .dov2==""||data[position].dov3=="")
                    ToastWidget.showToast("Date of first or second or booster "
                        "dose is "
                        "missing", Colors
                        .red);
                  else
                  {
                    setState((){
                      data[position].status=value;
                    });}
                }
            ),
          ),
          ListTile(
            title: const Text('Not Vaccinated'),
            leading: Radio<String>(
                value:"Not Vaccinated",
                groupValue: data[position].status,
                onChanged:(value){
                  setState((){
                    data[position].dov1=data[position]
                        .dov2=data[position].dov3= data[position]
                        .c1=data[position].c2=data[position].c3="";
                    data[position].status=value;
                  });
                }
            ),
          ),
         Visibility(
           visible: data[position].status=="Not Vaccinated"?true:false,
             child: Container(
  padding: EdgeInsets.only(left: 2, right: 2),
  decoration: BoxDecoration(
  border: Border.all(
  color: Colors.grey[300], width: 2),
  borderRadius: BorderRadius.circular(15)),
  child: Row(
    children: [Text("Reason",style: TextStyle(fontWeight: FontWeight.w900,
        fontSize: 15)),SizedBox(width: 10,),
      DropdownButton<String>(
      value: data[position].reason==""?null:data[position].reason,
      hint: Text('Select'),
      icon: const Icon(Icons.arrow_downward,
      color: Colors.blue),
      iconSize: 24,
      elevation: 16,
      onChanged: (String newValue) {
      setState(() {
      FocusScope.of(context)
          .requestFocus(FocusNode());
      data[position].reason=newValue;
      });
      },
      items: <String>[
      "Parent's denied",
      'Covid positive',
      "Health problem","Other issue"
      ].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
      value: value,
      child: Row(children: [
      Text(value)
      ]),
      );
      }).toList(),
      ),
    ],
  ),
  ))
        ],
      )*/
      Widgets(data: data,position: position,type: "dose",)
    ],);
  }
  Widget dataBox({String data="",double borderWidth=1,double margin=0,double
  height=30,double width,double fsize=15, bool border=true,Color
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
  Widget textTypeBox(TextEditingController controller, String hintText,
      String iconName, bool validationRequired) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        validator: validationRequired
            ? (value) {
          return value.isNotEmpty ? null : "*required";
        }: null,
        decoration: InputDecoration(
          icon: new SvgPicture.asset(
            "assets/images/" + iconName,
            width: 30,
            height: 30,
          ),
          labelText: hintText,
        ),
      ),
    );
  }
  void controllerDispose() {
    for (int i = 0; i < snamecontroller.length; i++) {
      snamecontroller[i].dispose();
      vnameController[i].dispose();
      dov1Controller[i].dispose();
      dov3Controller[i].dispose();
      dov2Controller[i].dispose();
      reasonController[i].dispose();
      remarkController[i].dispose();
      c1Controller[i].dispose();
      c2Controller[i].dispose();
      c3Controller[i].dispose();
    }
  }

  void dispose() {
    super.dispose();
    controllerDispose();
  }

  void initState() {
    super.initState();
    getVaccineData();
  }

  Future updateVaccineData(int position) async {
    try {
      String query;
      setState(() {
        data[position].saveProgress = true;
      });
      query = "update `kpsbspin_master`.`vaccine_detail` set "
          "vname='${data[position].vname}',dov1='${data[position].dov1}',"
          "dov2='${data[position].dov2}',dov3='${data[position].dov3}',"
          "reason='${data[position].reason}',remark='${data[position].remark}',"
          "bid='${data[position].bid}',c1='${data[position].c1}',"
          "c2='${data[position].c2}',c3='${data[position].c3}',"
          "eligibility='${data[position].eligible}',status='${data[position]
          .status}' where rowid='${data[position].rowid}'";
      /*print(query);
      print(data[position].rowid);
      print("rollno" + data[position].rollno);
      print("eligible" + data[position].eligible);
      print("vname" + data[position].vname);
      print("reason" + data[position].reason);
      print("status" + data[position].status);
      print("remark" + data[position].remark);
      print("c1" + data[position].c1);
      print("c2" + data[position].c2);
      print("c3" + data[position].c3);
      print("dov1" + data[position].dov1);
      print("dov2" + data[position].dov2);
      print("dov3" + data[position].dov3);
      print("bid" + data[position].bid);*/
      var results = await connection.query(query);
      if(results.affectedRows>=0) {
        ToastWidget.showToast("saved", Colors.green[400]);
      }
      setState(() {
        data[position].saveProgress = false;
      });
    }catch(Exception)
    {
      data[position].saveProgress=false;
      setState(() {
      });
      ToastWidget.showToast(Exception.toString(),Colors.red);
    }
  }

  Future getVaccineData() async {
    try {
      String query;
      DateTime today = DateTime.now();
     List<VaccineData> data=[];
      query = "select `nominal`.rowid,rollno,sname,gen,vname,dov1,dov2,"
          "dov3,reason,"
          "remark,bid,c1,c2,c3,dob,addhar,eligibility,`kpsbspin_master`.`vaccine_detail`.status "
          "from `$currentdb`.`nominal`,`kpsbspin_master`.`vaccine_detail` "
          "where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and `nominal`"
          ".rowid=`vaccine_detail`.rowid order by "
          "rollno";
      var results = await connection.query(query);
      for (var rows in results) {
        DateTime birthday=new DateFormat
          ("dd-MM-yyyy").parse(rows[14]==""?"29-01-2022":rows[14]);
        AgeDuration age= Age.dateDifference(
            fromDate: birthday, toDate: today, includeToDate: false);
        data.add(VaccineData(
            rowid: rows[0].toString(),
            rollno: rows[1].toString(),
        sname: rows[2],gen:rows[3],vname:rows[4],dov1: rows[5],
            dov2:rows[6],
            dov3:rows[7],reason: rows[8],remark: rows[9],bid: rows[10],c1:
        rows[11],c2: rows[12],c3:rows[13],dob:rows[14],aadhar:rows[15],
            age:age.years.toString()+" years "+age.months.toString()+" months "
            +age.days.toString()+" days",eligible: rows[16],status: rows[17]));
      }
      query="select gen,count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' and section='$section' and branch='$branch' and "
          "rollno not in('',' ') and rollno is not null and session_status "
          "not in('TC after term1') group "
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
      query="select count(`kpsbspin_master`.`vaccine_detail`.status),cname,"
          "section from `$currentdb`.`nominal`,`kpsbspin_master`.`vaccine_detail`"
          "where cname='$cname' and section='$section' and branch='$branch' "
          "and rollno not in ('',' ') and rollno is not null and `nominal`"
          ".rowid=`vaccine_detail`.rowid"
          " and `kpsbspin_master`.`vaccine_detail`.status in ('1st dose','2nd dose','booster')";
      results=await connection.query(query);
      for(var rows in results)
      {
        vaccinated=rows[0];
      }
      query="select count(`kpsbspin_master`.`vaccine_detail`.status),cname,"
          "section from `$currentdb`.`nominal`,`kpsbspin_master`.`vaccine_detail`"
          "where cname='$cname' and section='$section' and branch='$branch' "
          "and rollno not in ('',' ') and rollno is not null and `nominal`"
          ".rowid=`vaccine_detail`.rowid"
          " and eligibility='eligible'";
      results=await connection.query(query);
      for(var rows in results)
      {
        eligible=rows[0];
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
          await getVaccineData();
        }
      } else if (Exception.runtimeType == TimeoutException ||
          Exception.runtimeType == SocketException) {
        ToastWidget.showToast(
            "Not able to connect!! Restart the application", Colors.red);
      } else {
        print(Exception.toString());
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
}

class VaccineData {
  String rowid,rollno,gen,sname,vname,aadhar,dob,dov1,dov2,dov3,reason,remark,
      bid,
      c1,c2,
      c3,age,status,eligible;
  bool saveProgress;
  VaccineData(
      {
        this.rowid,this.rollno,this.gen,this.sname,this.vname,this.dov1,this
      .dov2,this
          .dov3,this.reason,this.remark,
        this.bid,this.c1,this.c2,this.c3,this.dob,this.aadhar,this.age,
        this.status,this.eligible,this.saveProgress=false});
}
class Widgets extends StatefulWidget {
    List<VaccineData> data=[];
    int position;
    String type;
    String content,date;
    Widgets({this.data,this.position,this.type,this.content,this.date});
  @override
  _WidgetsState createState() => _WidgetsState(this.data,this.position,this
      .type,this.content,this.date);
}

class _WidgetsState extends State<Widgets> {
  List<VaccineData> data=[];
  DateTime selectedDate = DateTime.now();
  String getdate="";
  String content,date;
  int position;
  var myFormat = DateFormat('dd-MM-yyyy');
  String type;
  _WidgetsState(this.data,this.position,this
      .type,this.content,this.date);
  @override
  Widget build(BuildContext context) {
    return type=="vname"?Vname(position):type=="dose"?dose():dateRow(content,
        position, date);
  }
  Widget Vname(int position)
  {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              color: Colors.grey[300], width: 2),
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [Text("Vaccine name",style: TextStyle(fontWeight: FontWeight
            .w900,
            fontSize: 15)),SizedBox(width: 10,),
          DropdownButton<String>(
            value: data[position].vname==""?null:data[position].vname,
            hint: Text('Select'),
            icon: const Icon(Icons.arrow_downward,
                color: Colors.blue),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              setState(() {
                FocusScope.of(context)
                    .requestFocus(FocusNode());
                data[position].vname=newValue;
              });
            },
            items: <String>[
              "Covishield",
              'Covaxin',
              "Pfizer","Other"
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(children: [
                  Text(value)
                ]),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  Widget dateRow(String content,int position,String date) {
    return  Row(
      children: [Text( content=="DOV1"?data[position].dov1:
      content=="DOV2"?data[position].dov2:data[position]
          .dov3),
        IconButton(icon: Icon(Icons.calendar_today_sharp,color:Colors.blue),
            onPressed:()async{
              getdate="";
              DateTime d=
              date==""?DateTime.now():(new DateFormat
                ("dd-MM-yyyy hh:mm:ss").parse(date+" "
                  "00:00:00"));
              selectedDate=d;
              showDateDialog(context,child: datePicker(),onClicked: (){
                setState(() {
                  if(getdate.isNotEmpty)
                    content=="DOV1"?data[position].dov1=getdate:
                    content=="DOV2"?data[position].dov2=getdate:data[position]
                        .dov3=getdate;
                });
                Navigator
                    .pop(context);});
            }),
      ],
    );
  }
  Widget dose()
  {
    return Column(
      children: [
        ListTile(
          title: const Text('1st Dose'),
          leading: Radio<String>(
              value:"1st Dose",
              groupValue: data[position].status,
              onChanged:(value){
                if(data[position].dov1=="")
                  ToastWidget.showToast("Fill date of first dose", Colors
                      .red);
                else
                {
                  setState((){
                    if(data[position].status=="2nd Dose")
                      data[position].status="2nd Dose";
                    else if(data[position].status=="Booster")
                      data[position].status="Booster";
                    else
                      data[position].status=value;
                  });}
              }
          ),
        ),
        ListTile(
          title: const Text('2nd Dose'),
          leading: Radio<String>(
              value:"2nd Dose",
              groupValue: data[position].status,
              onChanged:(value){
                if(data[position].dov1=="" || data[position].dov2=="")
                  ToastWidget.showToast("Date of first or second dose is "
                      "missing", Colors
                      .red);
                else
                {
                  setState((){
                    if(data[position].status=="Booster")
                    {
                      data[position].status="Booster";
                    }
                    else
                      data[position].status=value;
                  });}
              }
          ),
        ),
        ListTile(
          title: const Text('Booster'),
          leading: Radio<String>(
              value:"Booster",
              groupValue: data[position].status,
              onChanged:(value){
                if(data[position].dov1=="" || data[position]
                    .dov2==""||data[position].dov3=="")
                  ToastWidget.showToast("Date of first or second or booster "
                      "dose is "
                      "missing", Colors
                      .red);
                else
                {
                  setState((){
                    data[position].status=value;
                  });}
              }
          ),
        ),
        ListTile(
          title: const Text('Not Vaccinated'),
          leading: Radio<String>(
              value:"Not Vaccinated",
              groupValue: data[position].status,
              onChanged:(value){
                setState((){
                  data[position].dov1=data[position]
                      .dov2=data[position].dov3= data[position]
                      .c1=data[position].c2=data[position].c3=data[position]
                      .bid=data[position].vname="";
                  data[position].status=value;
                });
              }
          ),
        ),
        Visibility(
            visible: data[position].status=="Not Vaccinated"?true:false,
            child: Container(
              padding: EdgeInsets.only(left: 2, right: 2),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey[300], width: 2),
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [Text("Reason",style: TextStyle(fontWeight: FontWeight.w900,
                    fontSize: 15)),SizedBox(width: 10,),
                  DropdownButton<String>(
                    value: data[position].reason==""?null:data[position].reason,
                    hint: Text('Select'),
                    icon: const Icon(Icons.arrow_downward,
                        color: Colors.blue),
                    iconSize: 24,
                    elevation: 16,
                    onChanged: (String newValue) {
                      setState(() {
                        FocusScope.of(context)
                            .requestFocus(FocusNode());
                        data[position].reason=newValue;
                      });
                    },
                    items: <String>[
                      "Parent's denied",
                      'Covid positive',
                      "Health problem","Other issue"
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(children: [
                          Text(value)
                        ]),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ))
      ],
    );
  }
  static void showDateDialog(BuildContext context,{Widget child,
    VoidCallback onClicked})=>showCupertinoModalPopup(context: context,
      builder: (context)=>CupertinoActionSheet(
        actions: [child],
        cancelButton: CupertinoActionSheetAction(child: Text("Done"),
          onPressed: onClicked,),
      ));
  Widget datePicker()=>SizedBox(height: 150,
    child: CupertinoDatePicker
      (
      backgroundColor: AppColor.BACKGROUND,
      initialDateTime: selectedDate,
      maximumYear: DateTime.now().year,
      mode: CupertinoDatePickerMode.date,
      onDateTimeChanged: (dateTime)=>setState(()
      {selectedDate=dateTime;
      getdate=myFormat.format(selectedDate).toString();
      }),
    ),
  );
}





