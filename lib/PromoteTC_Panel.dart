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
  String cname,section,branch;
  PromoteTC_Panel({Key key,this.currentdb,this.nextdb,this.connection,this.cname,this.section,this.branch,this.screenheight,this.screenwidth}) : super(key: key);
  @override
  _PromoteTC_PanelState createState() => _PromoteTC_PanelState(this.currentdb,this.nextdb,this.connection,this.cname,this.section,this.branch,this.screenheight,this.screenwidth);
}

// ignore: camel_case_types
class _PromoteTC_PanelState extends State<PromoteTC_Panel> {
  String currentdb="",nextdb="";
  DateTime selectedDate = DateTime.now();
  bool saveProgress=true;
  MysqlHelper mysqlHelper=MysqlHelper();
  var myFormat = DateFormat('yyyy-MM-dd');
  double screenheight,screenwidth;
String _selectedtask,_previousSelectedStatus;
  final List<TextEditingController> tcnocontroller=[],tcdatecontroller=[],tcreasoncontroller=[];
  List <Data> data=[];
  mysql.MySqlConnection connection;
  String cname,section,branch,selectedate="",getdate="";
  _PromoteTC_PanelState(this.currentdb,this.nextdb,this.connection,this.cname,this.section,this.branch,this.screenheight,this.screenwidth);
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
        title: Text('Promote/Tc Panel',style: GoogleFonts.playball(
          fontSize: screenheight / 30,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],),),
      ),
      body: data.isEmpty?Center(child: CircularProgressIndicator()):ListView.builder(
        scrollDirection: Axis.vertical,
          itemCount: data.length,
          padding: const EdgeInsets.all(5.0),
          itemBuilder: (context,position){
        return rowData(position);
      }),
    );
  }
  Widget rowData(int position)
  {
    _selectedtask=data[position].selectstat;
    tcdatecontroller.add(TextEditingController());
    tcnocontroller.add(TextEditingController());
    tcreasoncontroller.add(TextEditingController());
    tcnocontroller[position].text=data[position].tcno;
    tcreasoncontroller[position].text=data[position].tcreason;
    tcdatecontroller[position].text=data[position].tcdate;
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
                    value:_selectedtask,
                    hint: Text('Change'),
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    onChanged: (String newValue) async {
                      setState(() {
                        _selectedtask= newValue;
                        _previousSelectedStatus=data[position].selectstat==null?"FIRST_TIME":data[position].selectstat;
                        data[position].selectstat=_selectedtask;
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
                    items: <String>['Promote','Repeat','Promote and TC','Failed and TC','Not active']
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
                        if(data[position].selectstat=='Promote and TC' ||data[position].selectstat=='Failed and TC')
                          {
                            if(tcdatecontroller[position].text==""||tcnocontroller[position].text==""||tcdatecontroller[position].text=="")
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
                              }
                          }
                        else
                          {
                            uploadData(position);
                          }

                      });

                    },child:Icon(Icons.done_outline_sharp),
                      color:Colors.greenAccent[200],),
                  ),
                  Visibility(visible: !data[position].saveProgress, child:CircularProgressIndicator(backgroundColor: Colors.red,))
                ,
                ],
              ),
            ),
          Visibility(
            visible: data[position].tcEditButonVisibility,
            child: Row(children: [Text('Edit TC details'),
              IconButton(icon: Icon(Icons.edit_rounded), onPressed: (){
                setState(() {
                  data[position].tcMenuVisibility=true;
                  _previousSelectedStatus=data[position].selectstat;
                });
              })
            ],),
          ),
          tcControlPanel(position)
          ],
        ),
      );
  }
  Future loadData() async
  {
    try {
      List<Data> data = [];
      this.data = [];
      var results = await connection.query(
          "Select rowid,rollno,sname,session_status,cno,cname from "
              "`$currentdb`.`nominal` where cname='$cname' and section='$section'"
              " and branch='$branch' and rollno not in('',' ') and rollno is not"
              " null and session_status not in ('TC after term1') order by rollno asc");
      for (var rows in results) {
        if (rows[3] == 'Promote and TC'||rows[3] == 'Failed and TC') {
          var result = await connection.query(
              "select rowid,tcno,tcdate,reason from `kpsbspin_master`.`tcdetail` where rowid='${rows[0]}'");
          for (var row in result) {
            data.add(Data(
                rowid: rows[0],
                rollno: rows[1],
                name: rows[2],
                status: rows[3],
                cno: rows[4],
                cname: rows[5],
                tcno: row[1],
                tcdate: row[2],
                tcreason: row[3]));
          }
        }
        else {
          data.add(Data(
              rowid: rows[0],
              rollno: rows[1],
              name: rows[2],
              status: rows[3],
              cno: rows[4],
              cname: rows[5]));
        }
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
                         .tcdate+" "
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
  static void showDateDialog(BuildContext context,{Widget child,
    VoidCallback onClicked})=>showCupertinoModalPopup(context: context,
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
    if(data[position].selectstat==null)
    {
      data[position].stcolor=Colors.purple;
      data[position].status='Not yet promoted';
      ToastWidget.showToast("OOPS!!!, no option selected",Colors.red);
    }
    else if(data[position].selectstat=='Promote')
    {
      if(data[position].cno==12)
        {
          ToastWidget.showToast("Go with TC option", Colors.red);
          return;
        }
      var postData= {
        "current_db":currentdb,
        "next_db":nextdb,
        "previous_status": _previousSelectedStatus,
        "rowid":data[position].rowid.toString(),
        "cno":data[position].cno.toString(),
        "newstatus":"Promoted",
        "branchno":branch
      };
      if(_previousSelectedStatus==null||_previousSelectedStatus==data[position].selectstat)
        {
          ToastWidget.showToast("No changes made!!!!",Colors.purpleAccent);
        }
      else
        {
          setState(() {
            data[position].saveProgress=false;
          });
          var url=Uri.parse('https://kpsbsp.in/result/promote.php');
          var response=await http.post(url,body: postData);
          if(response.statusCode==200)
          {
            data[position].stcolor=Colors.green;
            data[position].status='Promoted';
            ToastWidget.showToast(response.body,Colors.green);
          }
          else
          {
            ToastWidget.showToast("Something Went Wrong, try again !!!!${response.reasonPhrase}",Colors.red);
          }
          setState(() {
            data[position].saveProgress=true;
          });
          //_previousSelectedStatus=data[position].selectstat;
        }
      /*String deletetcquery="delete from `kpsbspin_master`.`tcdetail` where rowid='${data[position].rowid}'";
      await connection.query(deletetcquery);
      await connection.query("update session_tab  set session_status='Not yet promoted' where rowid='${data[position].rowid}'");
      await connection.query("update `kpsbspin_master`.`studmaster` set stat='' where rowid='${data[position].rowid}'");*/
    }
    else if(data[position].selectstat=='Promote and TC'||data[position].selectstat=='Failed and TC')
    {
      var postData= {
        "current_db":currentdb,
        "next_db":nextdb,
      "rowid":data[position].rowid.toString(),
        "tcdate":data[position].tcdate,
        "tcno":data[position].tcno,
        "cname":data[position].cname,
        "tcreason":data[position].tcreason,
        "cno":data[position].cno.toString(),
        "newstatus":data[position].selectstat
      };
      if(_previousSelectedStatus!=null)// if promote is already not selected
      {
        setState(() {
          data[position].saveProgress=false;
        });
          var url=Uri.parse('https://kpsbsp.in/result/tc.php');
          var response=await http.post(url,body: postData);
          if(response.statusCode==200)
          {
            data[position].stcolor=Colors.red;
            data[position].status=data[position].selectstat;
            print(response.body);
            ToastWidget.showToast(response.body,Colors.green);
          }
          else
          {
            ToastWidget.showToast("Something Went Wrong, try again !!!!",Colors.red);
          }
        setState(() {
          data[position].saveProgress=true;
        });
      }
      else
        {
          ToastWidget.showToast("No changes made!!!!",Colors.purpleAccent);
        }
      /*String tcinsertquery="insert into `kpsbspin_master`.`tcdetail` values('${data[position].rowid}','${data[position].tcdate}','${data[position].tcno}','TC taken after ${data[position].cname}','${data[position].tcreason}','${data[position].cno}')";
      String checktcquery="select count(*) from `kpsbspin_master`.`tcdetail` where rowid='${data[position].rowid}'";
      String deletetcquery="delete from `kpsbspin_master`.`tcdetail` where rowid='${data[position].rowid}'";
      var results=await connection.query(checktcquery);
      for (var rows in results)
        {
          if(rows[0]>=1)
            {
              await connection.query(deletetcquery);
            }
          await connection.query(tcinsertquery);
          await connection.query("update `kpsbspin_master`.`studmaster` set stat='TC' where rowid='${data[position].rowid}'");
          await connection.query("update session_tab  set session_status='${data[position].status}' where rowid='${data[position].rowid}'");
        }*/
    }
    else if(data[position].selectstat=='Repeat')
    {
      var postData= {
        "current_db":currentdb,
        "next_db":nextdb,
        "previous_status": _previousSelectedStatus,
        "rowid":data[position].rowid.toString(),
        "cno":data[position].cno.toString(),
        "newstatus":data[position].selectstat,
        "branchno":branch
      };
      if(_previousSelectedStatus==null||_previousSelectedStatus==data[position].selectstat)
      {
        ToastWidget.showToast("No changes made!!!!",Colors.purpleAccent);
      }
      else
      {
        setState(() {
          data[position].saveProgress=false;
        });
        var url=Uri.parse('https://kpsbsp.in/result/repeat.php');
        var response=await http.post(url,body: postData);
        if(response.statusCode==200)
        {
          data[position].stcolor=Colors.blue;
          data[position].status='Repeat';
          ToastWidget.showToast(response.body,Colors.green);
        }
        else
        {
          ToastWidget.showToast("Something Went Wrong, try again !!!!",Colors.red);
        }
        setState(() {
          data[position].saveProgress=true;
        });
    }
    }
    else if(data[position].selectstat=='Not active')
      {
        var postData= {
          "current_db":currentdb,
          "next_db":nextdb,
          "previous_status": _previousSelectedStatus,
          "rowid":data[position].rowid.toString(),
          "cno":data[position].cno.toString(),
          "newstatus":data[position].selectstat,
          "branchno":branch
        };
        if(_previousSelectedStatus==null||_previousSelectedStatus==data[position].selectstat)
        {
          ToastWidget.showToast("No changes made!!!!",Colors.purpleAccent);
        }
        else
        {
          setState(() {
            data[position].saveProgress=false;
          });
          var url=Uri.parse('https://kpsbsp.in/result/notActive.php');
          var response=await http.post(url,body: postData);
          if(response.statusCode==200)
          {
            data[position].stcolor=Colors.teal[900];
            data[position].status='Not active';
            ToastWidget.showToast(response.body,Colors.green);
          }
          else
          {
            ToastWidget.showToast("Something Went Wrong, try again !!!!",Colors.red);
          }
          setState(() {
            data[position].saveProgress=true;
          });
        }
      }
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
  int rowid;
  bool tcMenuVisibility=false,tcEditButonVisibility=false,saveProgress=true;
  String rollno,name,status,selectstat,cname;
  String tcno="",tcdate="",tcreason="";
  Color stcolor;
  int cno;
  Data({this.rowid,this.rollno,this.name,this.status,this.tcno,this.tcdate,this.tcreason,this.cno,this.cname})
  {
    if(this.status=='Not yet promoted')
      {
        selectstat=null;
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
    else if(this.status=='Not active')
    {
      selectstat='Not active';
      stcolor=Colors.teal[900];
    }
    else if(this.status=='Promote and TC'||this.status=='Failed and TC')
    {
      selectstat=this.status;
      //tcMenuVisibility=true;
      tcEditButonVisibility=true;
      stcolor=Colors.red;
    }

  }
}