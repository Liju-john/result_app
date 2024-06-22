import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:result_app/settings/InternetCheck.dart';
import 'package:result_app/settings/Settings.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:http/http.dart' as http;
import 'package:result_app/widgets/ToastWidget.dart';

import 'MysqlHelper.dart';

class PromoteTC_Panel extends StatefulWidget {
  String currentdb="",nextdb="";
  mysql.MySqlConnection connection;
  double screenheight,screenwidth;
  String cname,section,branch,nextSession,currentSession;
  PromoteTC_Panel({Key? key,required this.currentdb,required this.nextdb,required this.connection,required this.cname,
    required this.section,required this.branch,required this.screenheight,required this.screenwidth,required this.nextSession,required this.currentSession}) : super(key: key);
  @override
  _PromoteTC_PanelState createState() => _PromoteTC_PanelState(this.currentdb,
      this.nextdb,this.connection,this.cname,this.section,this.branch,
      this.screenheight,this.screenwidth,this.nextSession,this.currentSession);
}

// ignore: camel_case_types
class _PromoteTC_PanelState extends State<PromoteTC_Panel> {
  String currentdb="",nextdb="";
  DateTime selectedDate = DateTime.now();
  bool saveProgress=true;
  MysqlHelper mysqlHelper=MysqlHelper();
  var myFormat = DateFormat('yyyy-MM-dd');
  double screenheight,screenwidth;
String ?_selectedtask="",_previousSelectedStatus,nextSession,currentSession;
  final List<TextEditingController> tcnocontroller=[],tcdatecontroller=[],tcreasoncontroller=[];
  List <Data> data=[];
  int onroll=0,migrated=0;
  mysql.MySqlConnection connection;
  String cname,section,branch,selectedate="",getdate="";
  _PromoteTC_PanelState(this.currentdb,this.nextdb,this.connection,this.cname,
      this.section,this.branch,this.screenheight,this.screenwidth,this.nextSession,this.currentSession);
  void initState() {
    super.initState();
    loadData();
  }
  void dispose ()
  {
    super.dispose();
    controllerDispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BACKGROUND,
      appBar: AppBar(
        backgroundColor: AppColor.NAVIGATIONBAR,
        title: Text('Migration Panel',style: GoogleFonts.playball(
          fontSize: screenheight / 30,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],),),
      ),
      body: Column(
        children: [
          Row( children: [
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Text("On roll: "),
            ),Text(onroll.toString(),
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text("Migrated Students: "),
            ),Expanded(
              child: Text(migrated.toString(),
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
            )],),
          data.isEmpty?Center(child: CircularProgressIndicator()):Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
                itemCount: data.length,
                padding: const EdgeInsets.all(5.0),
                itemBuilder: (context,position){
              return rowData(position);
            }),
          ),
        ],
      ),
    );
  }
  Widget rowData(int position)
  {
    _selectedtask=data[position].selectstat;
    tcdatecontroller.add(TextEditingController());
    tcnocontroller.add(TextEditingController());
    tcreasoncontroller.add(TextEditingController());
    tcnocontroller[position].text=(data[position].tcno != null ? data[position].tcno : "")!;
    tcreasoncontroller[position].text=(data[position].tcreason !=null?data[position].tcreason:"")!;
    tcdatecontroller[position].text=(data[position].tcdate!=null?data[position].tcdate:"")!;
    return
      Card(
        color: Colors.yellow[50],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text(data[position].rollno,style: TextStyle(fontWeight: FontWeight.w900),),
              SizedBox(width: 20,),
              SizedBox(width:screenwidth*0.3, child:Text(data[position].name,style: TextStyle(fontWeight: FontWeight.w900)),),
              SizedBox(width: 10,),Text('Status:-',style: TextStyle(fontSize: 10,fontWeight: FontWeight.w900),),SizedBox(width: 2,),
              SizedBox(width:screenwidth*0.3, child: Text(data[position].status,style: TextStyle(fontSize:11,fontWeight: FontWeight.w900,color: data[position].stcolor),))],),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [Text('Select'),SizedBox(width: 10,),
                  DropdownButton<String>(
                    value:_selectedtask==""?null:_selectedtask,
                    hint: Text('Change'),
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    onChanged: (String ? newValue) async {
                      setState(() {
                        _selectedtask= newValue;
                        _previousSelectedStatus=data[position].selectstat==""?"FIRST_TIME":data[position].selectstat;
                        data[position].selectstat=_selectedtask!;
                        if(newValue=='Promote and TC'||newValue=='Failed and TC')
                          {
                            data[position].tcMenuVisibility=true;
                          }
                        else
                          {
                            data[position].tcMenuVisibility=false;
                            data[position].tcEditButonVisibility=false;
                          }
                      });
                    },
                    items: <String>['Promote','Repeat','GIT','Promote and '
                        'TC','Fai'
                  'led and TC','Reset']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),SizedBox(width: 10,),
                  Visibility(
                    visible: data[position].saveProgress,
                    child: MaterialButton(onPressed: (){
                      setState(() {
                        /*if(data[position].selectstat=='Promote and TC' ||data[position].selectstat=='Failed and TC')
                          {
                            ToastWidget.showToast('Option not available', Colors
                                .red);
                            *//*if(tcdatecontroller[position].text==""||tcnocontroller[position].text==""||tcdatecontroller[position].text=="")
                              {
                                ToastWidget.showToast('All Fields are compulsory', Colors.red);
                              }
                            else
                              {
                                data[position].tcno=tcnocontroller[position].text;
                                data[position].tcreason=tcreasoncontroller[position].text;
                                data[position].tcdate=tcdatecontroller[position].text;
                                data[position].tcMenuVisibility=false;
                                data[position].tcEditButonVisibility=true;
                                uploadData(position);
                              }*//*
                          }
                        else
                          {
                            uploadData(position);
                          }*/
                        uploadData(position);
                      });

                    },child:Icon(Icons.done_outline_sharp),
                      color:Colors.greenAccent[200],),
                  ),
                  Visibility(visible: !data[position].saveProgress, child:CircularProgressIndicator(backgroundColor: Colors.red,))
                ,
                ],
              ),
            ),
          /*Visibility(
            visible: data[position].tcEditButonVisibility,
            child: Row(children: [Text('Edit TC details'),
              IconButton(icon: Icon(Icons.edit_rounded), onPressed: (){
                setState(() {
                  data[position].tcMenuVisibility=true;
                  _previousSelectedStatus=data[position].selectstat;
                });
              })
            ],),
          ),*/
          //tcControlPanel(position)
          ],
        ),
      );
  }
  Future loadData() async
  {
    try {
      List<Data> data = [];
      this.data = [];
      //session_status not in ('TC after term1')
      var results = await connection.query(
          "Select rowid,rollno,sname,session_status,cno,cname,busstop,"
              "dis_remark,discount_type"
              " from `$currentdb`.`nominal` where cname='$cname' and section='$section'"
              " and branch='$branch'  and rollno is not"
              " null and status =1 order by rollno asc");
      for (var rows in results) {
        onroll=onroll+1;
        if(rows[3]!='Not yet promoted')
          {
            migrated=migrated+1;
          }
        data.add(Data(
            rowid: rows[0],
            rollno: rows[1],
            name: rows[2],
            status: rows[3],
            cno: rows[4],
            cname: rows[5],
            busstop: rows[6],
            sibling_rid: rows[7],
            discount_type: rows[8]),
        );
      }
      setState(() {
        this.data = data;
      });
    }catch(Exception)
    {
      if(Exception.runtimeType==StateError) {
        if(NetworkStatus.NETWORKTYPE==0)
        {
          ToastWidget.showToast("No internet connection", Colors.red);
        }
        else {
          ToastWidget.showToast("Reconnecting to server, please wait!!!", Colors.red);
          await getConnection();
          await loadData();
        }

      }
      else if(Exception.runtimeType==TimeoutException||Exception.runtimeType==SocketException)
      {
        ToastWidget.showToast("Not able to connect!! Restart the application", Colors.red);
      }
      else
        {
          ToastWidget.showToast(Exception.runtimeType.toString()+" "+Exception.toString(), Colors.red);
    }
    }
  }
  void countMigrated()
  {
    migrated=0;
    data.forEach((element) {

      if(element.status!='Not yet promoted')
        {
          migrated=migrated+1;
        }
    });
  }
  Widget tcControlPanel(int position)
 {
   return Visibility(
     visible: data[position].tcMenuVisibility,
       child: Card(
         elevation: 10,
         shape:RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(15.0)),
         color: Colors.amber[200],
         child: Padding(
           padding: const EdgeInsets.all(8.0),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.start,
                 children:[SizedBox(width:5),Text('TC NO'),SizedBox(width:5),
                   SizedBox(width: screenwidth*0.4,child: TextFormField(controller: tcnocontroller[position],))]
               ),
               Row(
                   mainAxisAlignment: MainAxisAlignment.start,
                   children:[SizedBox(width:5),Text('TC Date'),SizedBox(width:5),
                     SizedBox(width: screenwidth*0.4,child: TextFormField(enabled: false,controller: tcdatecontroller[position],)),IconButton(icon: Icon(Icons.calendar_today_sharp), onPressed:()async
                   {
                     selectedDate=
                     data[position].tcdate==null?DateTime.now():(new
                     DateFormat
                       ("yyyy-MM-dd hh:mm:ss").parse(data[position]
                         .tcdate!+" "
                         "00:00:00"));
                     showDateDialog(context,child: datePicker(),onClicked: (){
                       setState(() {
                         if(getdate.isNotEmpty)
                           data[position].tcdate=getdate;
                       });
                       Navigator
                           .pop(context);});
                     setState(() {
                       print(getdate);
                       if(getdate.isNotEmpty) {
                         data[position].tcdate = getdate;
                         getdate='';
                       }
                     });
                   })]
               ),
               Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children:[SizedBox(width:5),Text('Reason'),SizedBox(width:5),
                     Expanded(child: TextFormField(controller: tcreasoncontroller[position],))]
               ),

             ],
           ),
         ),
       ));
}
  static void showDateDialog(BuildContext context,{required Widget child,
    required VoidCallback onClicked})=>showCupertinoModalPopup(context: context,
      builder: (context)=>CupertinoActionSheet(
        actions: [child],
        cancelButton: CupertinoActionSheetAction(child: Text("Done"),
          onPressed: onClicked,),
      ));
  Widget datePicker()=>SizedBox(height: 150,
    child: CupertinoDatePicker
      (backgroundColor: AppColor.BACKGROUND,
      initialDateTime: selectedDate,
      maximumYear: DateTime.now().year,
      mode: CupertinoDatePickerMode.date,
      onDateTimeChanged: (dateTime)=>setState(()
      {
        selectedDate=dateTime;
        getdate=myFormat.format(selectedDate).toString();
      }),
    ),
  );
  void controllerDispose()
  {
    for(int i=0;i<tcnocontroller.length;i++)
    {
      tcreasoncontroller[i].dispose();
      tcnocontroller[i].dispose();
      tcdatecontroller[i].dispose();
    }
  }
  Future uploadData(int position) async{
    String  st="";
    if(data[position].selectstat=="")
    {
      data[position].stcolor=Colors.purple;
      data[position].status='Not yet promoted';
      ToastWidget.showToast("OOPS!!!, no option selected",Colors.red);
    }
    /*else if(data[position].selectstat=='Promote'||data[position]
        .selectstat=='Failed'||data[position].selectstat=='Repeat')*/
    else
    {
      /*if(data[position].cno==12)
        {
          ToastWidget.showToast("Go with TC option", Colors.red);
          return;
        }*/
      if(data[position].selectstat=='Promote')
        {
          st="Promoted";
        }
      else
        {
          st=data[position].selectstat;
        }
      var postData= {
        "current_db":currentdb,
        "next_db":nextdb,
        "next_session":nextSession,
        "current_session":currentSession,
        "previous_status": _previousSelectedStatus,
        "rowid":data[position].rowid.toString(),
        "cno":data[position].cno.toString(),
        "busstop":data[position].busstop,
        "newstatus":st,
        "branchno":branch,
        "sibling_rid":data[position].sibling_rid,
        "discount_type":data[position].discount_type
      };
      if(data[position].selectstat=='Reset')
      {
        setState(() {
          data[position].saveProgress=false;
        });
        var url=Uri.parse('http://117.247.90.209/app/result/promotereset.php');
        var response=await http.post(url,body: postData);
        if(response.statusCode==200)
          {
            showAlertDialog(context, response.body,data[position].stcolor as Color);
            data[position].selectstat="";
            data[position].status="Not yet promoted";
            data[position].stcolor=Colors.purple;
            migrated=migrated==0?0:migrated-1;
          }
        setState(() {
          data[position].saveProgress=true;
        });
        return;
      }
      if(_previousSelectedStatus==null||_previousSelectedStatus==data[position].selectstat)
        {
          ToastWidget.showToast("No changes made!!!!",Colors.purpleAccent);
        }
      else
        {
          setState(() {
            data[position].saveProgress=false;
          });
          print(postData);
          var url=Uri.parse('http://117.247.90.209/app/result/promotenew.php');
          var response=await http.post(url,body: postData);
          if(response.statusCode==200)
          {
            data[position].status=st;
            if(st=='Promoted')
              {
                data[position].stcolor=Colors.green;
              }
            else if(st=='Repeat')
              {
                data[position].stcolor=Colors.blue;
              }
            else if(st=='Failed'||st=='Promote and TC'||st=='Failed and TC')
              {
                data[position].stcolor=Colors.red;
              }
            showAlertDialog(context, response.body,data[position].stcolor as Color);
            countMigrated();
            print(response.body);
            //ToastWidget.showToast(response.body,Colors.green);
          }
          else
          {
            showAlertDialog(context, "Something Went Wrong, try again !!!!${response.reasonPhrase}",Colors.red);
            //ToastWidget.showToast("Something Went Wrong, try again !!!!${response.reasonPhrase}",Colors.red);
          }
          setState(() {
            data[position].saveProgress=true;
          });
          //_previousSelectedStatus=data[position].selectstat;
        }
    }
   }

  showAlertDialog(BuildContext context,String msg,Color col) {
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Rounded border
      ),
      title: Text('Message'),
      content: Text(msg,style:
      TextStyle(fontWeight: FontWeight.bold,color:col),),
      actions: [
        // Download Button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Close the dialog
          },
          child: Text('Okay', style: TextStyle(
            fontSize: 18, // Increase button font size
            color: Colors.blue, // Change button text color
          ),),
        ),
      ],
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future getConnection()async  {
    if(connection!=null)
    {
      await connection.close();
    }
    connection=await mysqlHelper.Connect();
  }
}
class Data
{
  int rowid=0;
  bool tcMenuVisibility=false,tcEditButonVisibility=false,saveProgress=true;
  String rollno,name,status,selectstat="",cname,busstop,sibling_rid,
      discount_type;
  String ?tcno="",tcdate="",tcreason="";
  Color? stcolor;
  int cno=0;
  Data({required this.rowid,required this.rollno,required this.name,
    required this.status, this.tcno,this.tcdate,this.tcreason,
    required this.cno,required this.cname,
    required this.busstop,required this.sibling_rid,required this.discount_type})
  {
    if(this.status=='Not yet promoted')
      {
        selectstat="";
        stcolor=Colors.purple;
      }
    else if(this.status=='Promoted')
      {
        selectstat='Promote';
        stcolor=Colors.green;
      }
    else if(this.status=='Repeat')
    {
      selectstat='Repeat';
      stcolor=Colors.blue;
    }
    else if(this.status=='GIT')
    {
      selectstat='GIT';
      stcolor=Colors.red;
    }
    else if(this.status=='Not active')
    {
      selectstat='Not active';
      stcolor=Colors.teal[900];
    }
    else if(this.status=='Promote and TC'||this.status=='Failed and TC'||this.status=='Failed')
    {
      selectstat=this.status;
      //tcMenuVisibility=true;
      //tcEditButonVisibility=true;
      stcolor=Colors.red;
    }
  }
}