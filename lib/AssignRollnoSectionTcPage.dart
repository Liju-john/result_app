import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:result_app/settings/InternetCheck.dart';
import 'package:result_app/settings/Settings.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:http/http.dart' as http;
import 'package:result_app/widgets/ToastWidget.dart';
import 'MysqlHelper.dart';

class AssignRollnoSection_TC_Panel extends StatefulWidget {
  String? previousDB,currentDB="",nextDB="";
  mysql.MySqlConnection? connection;
  double? screenHeight,screenWidth;
  String? cname,branch;
  AssignRollnoSection_TC_Panel({Key? key,this.currentDB,this.nextDB,this.connection,
    this.cname,this.branch,this.screenHeight,this.screenWidth,this.previousDB}) : super(key: key);

  @override
  _AssignRollnoSection_TC_PanelState createState() =>
      _AssignRollnoSection_TC_PanelState(this.currentDB,this.nextDB,this.connection,
      this.cname,this.branch,this.screenHeight,this.screenWidth,this.previousDB);
}

class _AssignRollnoSection_TC_PanelState extends State<AssignRollnoSection_TC_Panel> {
  final _formKey=GlobalKey<FormState>();
  String query="";
  final TextEditingController _searchName=TextEditingController();
  int maleCount=0,femaleCount=0,nonActiveCount=0,nonClearedCount=0;
  String? previousDB="",currentDB="",nextDB="",getdate="";
  List<bool> saving=[],savingTC=[],loadingSubject=[];
  DateTime selectedDate = DateTime.now();
  var myFormat = DateFormat('yyyy-MM-dd');
  mysql.MySqlConnection? connection;
  double? screenHeight,screenWidth;
  String? cname,branch,_selectedSection,_selectedSubject5,_selectedSubject6,_selectedMainSubject;
  List<Data>? data,dataBackup=[];
  List<String> nameList=[];
  List<String> _subject5=[],_subject6=[],_mainSubject=[];
  final List<TextEditingController> rollController=[];
  final List<TextEditingController> tcnocontroller=[],tcdatecontroller=[],tcreasoncontroller=[];
  MysqlHelper mysqlHelper=MysqlHelper();
  _AssignRollnoSection_TC_PanelState(this.currentDB,this.nextDB,this.connection,
      this.cname,this.branch,this.screenHeight,this.screenWidth,this.previousDB);

  void initState() {
    super.initState();

    loadData();
  }
  @override
  Widget build(BuildContext context)
  {
    return
      Scaffold(
        backgroundColor: AppColor.BACKGROUND,
        appBar: AppBar(
          elevation: 0,
          title: Text('Assign rollno and section',style: GoogleFonts.playball(
            fontSize: screenHeight! / 30,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],),),
          backgroundColor: AppColor.NAVIGATIONBAR,
        ),
        body:Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Class:-  "+cname!,
                style: TextStyle(fontWeight: FontWeight.w900,color: Colors.teal,
                    fontSize: 18),)],),
            searchList(),
            legends(),
            SizedBox(height: 5,),
            dataBackup!.isEmpty?Center(child: CircularProgressIndicator
              (backgroundColor: Colors.red,)):data!.isEmpty?Text("Oops!!!!!"
                "\nNo "
                "such "
                "student found!!!",style: TextStyle(fontWeight: FontWeight
                .w900,
                color: Colors.redAccent),textAlign: TextAlign.center,)
                :Expanded(
              flex: 1,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: data!.length,
                  padding: const EdgeInsets.all(5.0),
                  itemBuilder: (context,position){
                    _selectedSection=data?[position].section==""?null:data?[position].section;
                    return rowData(position);
                  }),
            ),
          ],
        ),
      );
  }
  Widget searchList()
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        textCapitalization:TextCapitalization.characters,
        onChanged: (String val){
          this.data=dataBackup;
          final data=this.data?.where((data) {
            final sname=data.sname?.toLowerCase();
            final searchlower=val.toLowerCase();
            return sname!.contains(searchlower);
          }).toList();
          setState(() {
            this.data=data;
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
      hintText: "Type student name here...",
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)))
      ),),
    );
  }
  Widget search()
  {
    return Container(
      //height: (screenHeight/100),
      padding: EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: this._formKey,
            child: Container(
              height: (screenHeight!/100)*7,
              margin: EdgeInsets.symmetric(vertical: screenHeight!/100),
              child: TypeAheadFormField(
                suggestionsCallback: (pattern)=> nameList.where((item) =>
                item.toUpperCase().contains(pattern.toUpperCase())),
                itemBuilder: (_,String item){return ListTile(leading:Text
                  ((nameList.indexOf(item)+1).toString()),
                title: Text
                  (item),);},
                onSuggestionSelected: (String val)async{
                  this._searchName.text=val;
                  ToastWidget.showToast("Student found at "+(nameList.indexOf
                    (val)+1).toString(),Colors.green);
                },
                getImmediateSuggestions: true,
                hideSuggestionsOnKeyboardHide: false,
                hideOnEmpty: false,
                noItemsFoundBuilder: (context)=>Padding
                  (padding: const EdgeInsets.all(8.0), child: Text("No "
                    "student found"),),
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _searchName,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Type student name here...",
                    border: OutlineInputBorder()
                  )
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget legends()
  {
    return
        Card(
          color: Colors.deepPurpleAccent[100],
          child: Column(
            children: [
              Container(
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("Color Codes & Count",style: TextStyle
                    (fontWeight: FontWeight.bold,fontSize: 18),)],
                ),
              ),
              Container(
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Text("Girls",style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 18,color: Colors.green[200]),),
                  ),Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(femaleCount.toString(),style: TextStyle(fontWeight:
                  FontWeight.w900,fontSize:18,color: Colors.green[200]),),),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: Text("Boys",style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 18,color: Colors.amber),),
                    ),Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(maleCount
                          .toString(),style: TextStyle(fontWeight:
                      FontWeight.w900,fontSize:18,color: Colors.amber)),
                    )
                  ],
                ),
              ),
              /*Container(
                padding: EdgeInsets.only(left: 10),
                child: Row(
                  children: [Text("Boys",style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 18,color: Colors.amber),),Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(maleCount
                        .toString(),style: TextStyle(fontWeight:
                  FontWeight.w900,fontSize:18)),
                      )],
                ),
              ),*/

              //Previous year
              // Container(
              //   padding: EdgeInsets.only(left: 10),
              //   child: Row(
              //     children: [Text("Previous year non active students",style: TextStyle(
              //         fontWeight: FontWeight.bold,fontSize: 18,color: Colors
              //         .blueGrey),),Padding(
              //           padding: const EdgeInsets.only(left: 10),
              //           child: Text(nonActiveCount.toString(),style: TextStyle(fontWeight:
              //     FontWeight.w900,fontSize:18)),
              //         )],
              //   ),
              // ),
              // Container(
              //   padding: EdgeInsets.only(left: 10),
              //   child: Row(
              //     children: [Text("Previous year non cleared students",style: TextStyle(
              //         fontWeight: FontWeight.bold,fontSize: 18,color: Colors
              //         .redAccent),),Padding(
              //           padding: const EdgeInsets.only(left: 10),
              //           child: Text(nonClearedCount.toString(),style: TextStyle(fontWeight:
              //     FontWeight.w900,fontSize:18)),
              //         )],
              //   ),
              // ),
            ],
          ),
        );
  }
  Widget rowData(int position)
  {
    saving.add(false);
    loadingSubject.add(false);
    return
        Card(
          color: data?[position].gen=='F'?Colors.green[200]:
          data?[position].gen=='M'?Colors.amber:(data![position].notpromoted!?Colors.redAccent:Colors.blueGrey),
          child: Container(
            padding: EdgeInsets.only(left: 5,right: 2,top: 5,bottom: 5),
            child: Column(
              children: [
                Row(
                  children: [Text((position+1).toString()+".",style:
                  TextStyle
                    (fontWeight: FontWeight.w900),),SizedBox(width: 2,),
                    Text("Admno:- ",style: TextStyle(color:data?[position].gen==null?Colors.white:Colors.grey[700],fontWeight: FontWeight.bold)),
                    SizedBox(width:screenWidth!*0.13,child: Text(data![position].admno!,style: TextStyle(fontWeight: FontWeight.w900))),
                    SizedBox(width: 5,),
                    Text("Name:- ",style: TextStyle(color:data?[position].gen==null?Colors.white:Colors.grey[700],fontWeight: FontWeight.bold)),
                    Expanded(
                      child: SizedBox(width:screenWidth!*0.4,child: Text(data![position].sname!,
                          style: TextStyle(fontWeight: FontWeight.w900))),
                    )
                  ],
                ),//admno,name
                Visibility(
                  visible:data?[position].gen==null?false:true,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Rollno:- ",style: TextStyle(color:data?[position].gen==null?Colors.white:Colors.grey[700],fontWeight: FontWeight.bold)),
                    SizedBox(width: screenWidth!*0.2,child: rollTextField(position),),SizedBox(width: 5,),
                    Text("Section:- ",style: TextStyle(color:data?[position].gen==null?Colors.white:Colors.grey[700],fontWeight: FontWeight.bold)),
                    sectionDropDown(position)
                  ],
                ),),//rollno,section
                Visibility(
                  visible: data![position].tcEditButonVisibility!,
                  child: Row(children: [Text('Edit TC details'),
                    IconButton(icon: Icon(Icons.edit_rounded), onPressed: (){
                      setState(() {
                        data?[position].tcMenuVisibility=true;
                      });
                    })
                  ],),
                ),
                Visibility(
                  visible: data![position].nonactive!||data![position].notpromoted!,
                  child: Text("Previous Section:-"+(data![position].section=="Not active"||data![position].section==""?
                  "Not Assigned":data![position].section!),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                ),
                Visibility(
                  visible: data![position].nonactive!||data![position].notpromoted!,
                  child: Text("Previous Status:-"+(data![position].sessionStatus!),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                ),
                Visibility(
                  visible: data![position].tcMenuVisibility!||data![position]
                      .tcEditButonVisibility!||data?[position]
                      .gen==null||data?[position]
                      .sessionStatus=='Not active'||data?[position]
                      .sessionStatus=='TC'||data?[position]
                      .sessionStatus=='Not active'||data![position].assignButton!?false:true,
                  child: Row(
                    children: [
                      saving[position]?CircularProgressIndicator():TextButton(child: Text( data?[position].previousSection==""?"Assign":"Update"
                      ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),onPressed: ()async{
                        setState((){
                          FocusScope.of(context).requestFocus(FocusNode());
                          data?[position].previousSection=data![position].section;
                        });
                        await assignSectionRollNo(position);
                      },),
                      Visibility(visible: loadingSubject[position],
                          child: Text("Loading Subjects...",style: TextStyle
                            (color:Colors.purple,fontSize: 18,fontWeight: FontWeight.bold),)),
                      TextButton(child: Text( "Reset Rollno"
                        ,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),onPressed: ()async{
                        setState((){
                            FocusScope.of(context).requestFocus(FocusNode());
                            resetRollnoAlert(position);
                        });
                      },),
                    ],
                  ),
                ),
                tcControlPanel(position)
              ]
            ),
          ),
        );
  }
  Widget rollTextField(int position)
  {
          rollController.add(new TextEditingController());
          rollController[position].text=data![position].rollno!;
          return new TextFormField(style:TextStyle(fontWeight: FontWeight.w900),
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp('[0-9A-Z]+'))],
            controller: rollController[position],
              textCapitalization:TextCapitalization.characters ,
              onChanged: (value){
                data?[position].rollno=value;
          },
          );
  }
  Future loadData()async
  {
    try
    {
      nameList.clear();
      int cno;
      this.data=[];
      List<Data> data=[];
      String query="select rowid,sname,rollno,section,admno,gen,session_status,cno"
          " from `$currentDB`.`nominal` where "
          "cname='$cname' and branch='$branch' and status=1 order by gen,sname";
      var results=await connection!.query(query);
      for (var rows in results) {
        cno=rows[7];
        if (rows[6] == 'After Term I') {
          var result = await connection!.query(
              "select rowid,tcno,tcdate,reason from `kpsbspin_master`.`tcdetail` where rowid='${rows[0]}'");
          for (var row in result) {
            data.add(Data(
                rowid: rows[0].toString(),
                rollno: rows[2],
                sname: rows[1],
                section: rows[3],
                sessionStatus: rows[6],
                previousSection: rows[6],
                cno: rows[7].toString(),
                tcno: row[1].toString(),
                admno: rows[4],
                tcdate: row[2],
                tcreason: row[3]));
          }
        }
        else {
        data.add(Data(
            rowid: rows[0].toString(),
            sname: rows[1],
            rollno: rows[2],
            previousRollno: rows[2],
            section: rows[3],
            previousSection: rows[3],
            admno: rows[4],
            gen: rows[5],
            sessionStatus: rows[6],
          cno: rows[7].toString(),));}
      }
      // if(cno!=15&&previousDB!=""){//checking for nursery
      // if(cno==13)
      //   {
      //     cno=15;
      //   }
      // else if(cno==1)
      //   {
      //     cno=14;
      //   }
      // else
      //   {
      //     cno=cno-1;
      //   }
      // //previous year non active students
      // String q1="select rowid,sname,rollno,section,admno,gen,session_status,cno"
      //     " from `$previousDB`.`nominal` where "
      //     "cno='$cno' and branch='$branch' and session_status in('Not active') order by gen,sname";
      // var r1=await connection!.query(q1);
      // for (var rows in r1)
      //   {
      //     data.add(Data(sname: rows[1].toString(),admno: rows[4].toString(),
      //         section: rows[3].toString(),sessionStatus: rows[6].toString(),
      //         nonactive: true));
      //   }
      // //previous year not promoted students
      // String q2="select rowid,sname,rollno,section,admno,gen,session_status,cno"
      //     " from `$previousDB`.`nominal` where "
      //     "cno='$cno' and branch='$branch' and session_status in('Not yet promoted') order by gen,sname";
      // var r2=await connection!.query(q2);
      // for (var rows in r2)
      // {
      //   data.add(Data(sname: rows[1].toString(),admno: rows[4].toString(),
      //       section: rows[3].toString(),sessionStatus: rows[6].toString(),
      //      notpromoted: true));
      // }
      // this.nonClearedCount=r2.length;
      // }
      await loadDBSubjects();
      setState(() {
        this.data=data;
      });
      //experimental code
      int d=0;
      for (d=0;d<data.length;d++)
        {
          nameList.add(data![d].sname!);
        }
      dataBackup=this.data;
      int maleCount=dataBackup!.where((d){
        final x=d.gen==null?"":d.gen;
        return x!.contains("M");
      }).toList().length;
      int femaleCount=dataBackup!.where((d){
        final x=d.gen==null?"":d.gen;
        return x!.contains("F");
      }).toList().length;
      this.nonActiveCount=dataBackup!.where((d){
        return d.sessionStatus!.contains("Not active");
      }).toList().length;
      print(nonActiveCount);
      print(nonClearedCount);
      setState(() {
        this.maleCount=maleCount;
        this.femaleCount=femaleCount;
      });
    }catch(Exception,stack)
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
        print(Exception.toString());
        print(stack);
        ToastWidget.showToast(Exception.runtimeType.toString()+" "+Exception.toString(), Colors.red);
      }
    }
  }
  Future<void> resetRollnoAlert(int position) async
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
                            Text("You are about to reset rollno and section,"
                                "Are you sure about this?",style: TextStyle
                              (fontWeight: FontWeight.bold),),
                            Row( mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(onPressed: (){
                                  resetRollno(position);
                                  Navigator.of(context).pop();
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
  Future getConnection()async  {
    if(connection!=null)
    {
      await connection!.close();
    }
    connection=await mysqlHelper.Connect();
  }
  Widget tcControlPanel(int position)
  {
    savingTC.add(false);
    tcdatecontroller.add(TextEditingController());
    tcnocontroller.add(TextEditingController());
    tcreasoncontroller.add(TextEditingController());
    tcnocontroller[position].text=(data![position].tcno!=null?data![position].tcno:"")!;
    tcreasoncontroller[position].text=(data![position].tcreason!=null?data![position].tcreason:"")!;
    tcdatecontroller[position].text=(data![position].tcdate!=null?data![position].tcdate:"")!;
    return Visibility(
        visible: data![position].tcMenuVisibility!?true:false,
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
                ListTile(
                  title: const Text('After Term I'),
                  leading: Radio<String>(
                      value:"After Term I",
                      groupValue: data?[position].sessionStatus,
                      onChanged:(value){
                        setState((){
                          data?[position].sessionStatus=value!;
                        });
                      }
                  ),
                ),
                ListTile(
                  title: const Text('Before Term I'),
                  leading: Radio<String>(
                    value:"TC",
                    groupValue: data?[position].sessionStatus,
                    onChanged:(value){
                      setState((){
                        data?[position].sessionStatus=value!;
                      });
                    },
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:[Expanded(
                      child: TextFormField(controller: tcnocontroller[position],
                      decoration: InputDecoration(labelText:"TC NO"),),
                    )]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:[Expanded(
                      child: TextFormField(readOnly: true,controller: tcdatecontroller[position],
                          decoration: InputDecoration(labelText: "TC Date")),
                    ),
                      IconButton(icon: Icon(Icons.calendar_today_sharp), onPressed:()async
                      {
                        FocusScope.of(context).requestFocus(FocusNode());
                        selectedDate=
                        data?[position].tcdate==null?DateTime.now():(new
                        DateFormat
                          ("yyyy-MM-dd hh:mm:ss").parse(data![position]
                            .tcdate!+" "
                            "00:00:00"));
                        showDateDialog(context,child: datePicker(),onClicked: (){
                          setState(() {
                            if(getdate!.isNotEmpty)
                              data?[position].tcdate=getdate!;
                          });
                          Navigator
                              .pop(context);});
                        setState(() {
                          if(getdate!.isNotEmpty) {
                            data?[position].tcdate = getdate!;
                            getdate='';
                          }
                        });
                      })]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      Expanded(child: TextFormField(controller: tcreasoncontroller[position],
                          decoration: InputDecoration(labelText:"TC Reason")))]
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center,children: [TextButton(
                  onPressed: ()async{
                    FocusScope.of(context).requestFocus(FocusNode());
                    if(tcdatecontroller[position].text==""||tcnocontroller[position].text==""||tcdatecontroller[position].text=="")
                    {
                      ToastWidget.showToast('All Fields are compulsory', Colors.red);
                    }
                    else
                    {
                      data?[position].tcreason=tcreasoncontroller[position].text;
                      data?[position].tcno=tcnocontroller[position].text;
                     // await uploadTC(position);
                    }

                  },
                  child: savingTC[position]?CircularProgressIndicator():Text('Save',style: TextStyle(fontWeight: FontWeight.w900),),
                )],)
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
      (initialDateTime: selectedDate,
      backgroundColor: AppColor.BACKGROUND,
      maximumYear: DateTime.now().year,
      mode: CupertinoDatePickerMode.date,
      onDateTimeChanged: (dateTime)=>setState(()
      {
        selectedDate=dateTime;
        getdate=myFormat.format(selectedDate).toString();
      }),
    ),
  );
  Future assignSectionRollNo(int position)async
  {
    print(data?[position].section);
    setState(() {
      saving[position]=true;
    });
    if((data?[position].section==""||data?[position].rollno=="") && data?[position].section!='Not active')
    {
      ToastWidget.showToast("Either section is not selected or Rollno is missing",Colors.red);
      setState(() {
        saving[position]=false;
      });
      return;
    }

    var url;
    var postData={
      "branch":branch,
      "rollNo":data?[position].rollno,
      "section":data?[position].section,
      "rowid":data?[position].rowid,
      "cname":cname,
      "current_db":currentDB,
      "cno":data?[position].cno
    };
    if(cname=='I'|| cname=='II'|| cname=='III'|| cname=='IV'|| cname=='V'||
        cname=='KGI' || cname=='KGII'|| cname=='NUR')
    {
      url = Uri.parse(
          'http://117.247.90.209/app/result/rollno_assign/nur_v.php');
    }
    else if(cname=='VI'||cname=='VII'||cname=='VIII')
    {
      url = Uri.parse(
          'http://117.247.90.209/app/result/rollno_assign/vi_viii.php');
    }
    else if(cname=='IX'||cname=='X')
    {
      if((data?[position].subject5==null)&&data?[position].section!='Not active')
      {
        await loadAdditionalSubject(position);
        if(data?[position].subject5==null)
          {
            ToastWidget.showToast("Error in loading Subjects", Colors.red);
            return;
          }
      }
      postData.addAll({
        'subject5':data?[position].subject5,
        'subject6':data?[position].subject6
      });
      url = Uri.parse(
          'http://117.247.90.209/app/result/rollno_assign/ix_x.php');
    }
    else if(cname=='XI'||cname=='XII')
    {
      if(data?[position].mainSubject==null&&data?[position].section!='Not active')
      {
        await loadAdditionalSubject(position);
        if(data?[position].mainSubject==null)
        {
          ToastWidget.showToast("Error in loading Subjects", Colors.red);
          return;
        }
      }
      postData.addAll({
        'mainSubject':data?[position].mainSubject,
        'subject5':data?[position].subject5,
        'subject6':data?[position].subject6
      });
      url = Uri.parse(
          'http://117.247.90.209/app/result/rollno_assign/xi_xii.php');
    }
    var response=await http.post(url,body: postData);
    if(response.statusCode==200)
    {
      if(response.body=='NA Error')
      {
        ToastWidget.showToast("Cannot change to 'Not active', Already assigned TC", Colors.red);
        await loadData();
      }
      else if(response.body=='query error')
      {
        ToastWidget.showToast("Error in creating subject", Colors.red);
        await loadData();
      }
      else {
        ToastWidget.showToast(response.body, Colors.green);
      }
    }
    else
    {
      ToastWidget.showToast(response.reasonPhrase!,Colors.red);
    }
    setState(() {
      saving[position]=false;
    });
    print(response.body);
  }
  Future uploadTC(int position)async
  {
    setState(() {
      savingTC[position]=true;
    });
    var url;
    print(data?[position].sessionStatus);
    if(!(data?[position].sessionStatus=='TC' || data?[position].sessionStatus=='After Term I'))
      {
        ToastWidget.showToast("Select any one from above option", Colors.red);
        setState(() {
          savingTC[position]=false;
        });
        return;
      }
    var postData={
      "rowid":data?[position].rowid,
      "cname":cname,
      "current_db":currentDB,
      "cno":data?[position].cno,
      "sessionStatus":data?[position].sessionStatus,
      "previous_db":previousDB,
      "tcdate":data?[position].tcdate,
      "tcno":data?[position].tcno,
      "tcreason":data?[position].tcreason
    };
    url = Uri.parse(
        'http://117.247.90.209/app/result/rollno_assign/tc_assign.php');
    var response=await http.post(url,body: postData);
    if(response.statusCode==200)
    {
      if(response.body=='error')
        {
          ToastWidget.showToast("Something went wrong!!!", Colors.red);
        }
      else{
        setState(() {
          data?[position].tcMenuVisibility=false;
          data?[position].tcEditButonVisibility=true;
          ToastWidget.showToast(response.body, Colors.green);
        });
      }
      if(data?[position].sessionStatus=='TC')
        {
          await loadData();
        }
      }
    else
      {
        ToastWidget.showToast("Server Error", Colors.red);
        await loadData();
      }
    setState(() {
      savingTC[position]=false;
    });
  }
  Future loadDBSubjects()async
  {
    String querysub5="";
    String querysub6="";
    List<String>subject5=[],subject6=[],mainSubject=[];

    if(cname=='IX'||cname=='X')
    {
      querysub5="select distinct upper(subname) from `$currentDB`.`subjectList` where subno=5 and classflag like '%9to10%'";
      var sublist=await connection!.query(querysub5);
      for(var subrows in sublist)
      {
        subject5.add(subrows[0]);
      }
      querysub6="select distinct upper(subname) from `$currentDB`.`subjectList` where subno in ('6','7') and classflag like '%9to10%'";
      sublist=await connection!.query(querysub6);
      for(var subrows in sublist)
        {
          subject6.add(subrows[0]);
        }
      _subject5=subject5;
      _subject6=subject6;
    }
    else if(cname=='XI'||cname=='XII')
    {
      querysub5="select distinct upper(subname) from `$currentDB`.`subjectList` where subno=5 and classflag like '%11to12%'";
      var sublist=await connection!.query(querysub5);
      for(var subrows in sublist)
      {
        subject5.add(subrows[0]);
        subject6.add(subrows[0]);
      }
      subject6.add("NA");
      _subject5=subject5;
      _subject6=subject6;
      var mainsublist=await connection!.query("select distinct(subname) from `$currentDB`.`subjectList` where subno=2 and classflag like '%11to12%'");
      for(var subrows in mainsublist)
      {
        mainSubject.add(subrows[0]);

      }
      _mainSubject=mainSubject;
    }
  }
  Widget sectionDropDown(int position)
  {
        return
          DropdownButton<String>(
            value: _selectedSection,
            hint: Text('Assign'),
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            onChanged: (String? newValue) async {
              setState(() {
                data?[position].rollno=rollController[position].text;
                if(newValue=='TC'||newValue=='Not active')
                  {
                    //data?[position].tcMenuVisibility=true;
                    //data?[position].rollno="";
                    data?[position].assignButton=true;
                    data?[position].tcMenuVisibility=false;
                  }
                else
                  {
                    data?[position].tcMenuVisibility=false;
                    //data?[position].sessionStatus="";
                    data?[position].assignButton=false;
                    /*if(newValue=='Not active')
                      {
                        data?[position].rollno="";
                      }*/
                  }
                _selectedSection = newValue;
                data?[position].section = newValue!;
                FocusScope.of(context).requestFocus(FocusNode());
              });
              if ((cname == 'IX' || cname == 'X'||cname =='XI'||cname=='XII')
                  && (_selectedSection!='TC'&& _selectedSection!='Not active'))
              {
                setState(() {
                  loadingSubject[position]=true;
                });
                await loadAdditionalSubject(position);
                await subjectSelection(position);
              }
            },
            items: <String>['A', 'B', 'C', 'D', 'E', 'F','N', 'TC', 'Not '
                'active']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,style:TextStyle(fontWeight: FontWeight.w900)),
              );
            }).toList(),
          );
  }
  Future<void> subjectSelection(int position) async
  {
    _selectedSubject5=data?[position].subject5;
    _selectedSubject6=data?[position].subject6;
    _selectedMainSubject=data?[position].mainSubject;
    print(_selectedSubject5);
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
                        'Select Subjects', style: TextStyle(fontWeight: FontWeight.w900)),
                    content: SingleChildScrollView(
                        child: ListBody(
                            children: <Widget>[
                              Row(mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(data![position].sname!,style:TextStyle(fontWeight: FontWeight.w900,fontSize: 12)),
                                ],
                              ),//name of student
                              (cname=='XI'||cname=='XII')?Text("Main Subject",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 12),):Center(),
                              (cname=='XI'||cname=='XII')?DropdownButton<String>(
                                value: _selectedMainSubject,
                                hint:Text("Choose"),
                                icon: const Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,
                                onChanged: (String? newValue) async {
                                  setState(() {
                                    data?[position].mainSubject=newValue;
                                    _selectedMainSubject=data?[position].mainSubject;
                                  });
                                },
                                items: _mainSubject
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: SizedBox(width:screenWidth!*0.5,child: Text(value)),
                                  );
                                }).toList(),
                              ):Center(),//main subject
                              Text("Subject 5",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 12),),
                              DropdownButton<String>(
                                value: _selectedSubject5,
                                hint:Text("Choose"),
                                icon: const Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,
                                onChanged: (String? newValue) async {
                                  setState(() {
                                    data?[position].subject5=newValue!;
                                    _selectedSubject5=data?[position].subject5;
                                  });
                                },
                                items: _subject5
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: SizedBox(width:screenWidth!*0.5,child: Text(value)),
                                  );
                                }).toList(),
                              ),//V subject
                              Text("Subject 6",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 12),),
                              DropdownButton<String>(
                                value: _selectedSubject6,
                                hint: Text('Choose'),
                                icon: const Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,
                                onChanged: (String? newValue) async {
                                  setState(() {
                                    data?[position].subject6=newValue!;
                                    _selectedSubject6=data?[position].subject6;
                                  });
                                },
                                items: _subject6
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: SizedBox(width: screenWidth!*0.5,child: Text(value)),
                                  );
                                }).toList(),
                              ),//VI subject
                              Row( mainAxisAlignment: MainAxisAlignment.center,
                                children: [TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text("Ok",style: TextStyle(fontWeight: FontWeight.w900,color: Colors.green,fontSize: 17),)),
                                  TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text("Cancel",style: TextStyle(fontWeight: FontWeight.w900,color: Colors.red,fontSize: 17)))],)
                            ]
                        )
                    )
                );
              });
        }
    );
  }
  Future loadAdditionalSubject(int position) async
  {
    String sub5="",sub6="",mainSub="";
    if(cname=='IX' ||cname=='X')
    {
      var subject=await connection!.query("Select distinct subname from `$currentDB`.`ix_x` where subno='5' and rowid='${data?[position].rowid}'");
      for (var rows in subject)
      {
        sub5=rows[0];
      }
      subject=await connection!.query("Select distinct subname from `$currentDB`.`ix_x` where subno='6' and rowid='${data?[position].rowid}'");
      for (var rows in subject)
      {
        sub6=rows[0];
      }
    }
    else if(cname=='XI' ||cname=='XII')
    {
      var subject=await connection!.query("Select distinct subname from `$currentDB`.`xi_xii` where subno='2' and rowid='${data?[position].rowid}'");
      for (var rows in subject)
      {
        mainSub=rows[0];
      }
      subject=await connection!.query("Select distinct subname from `$currentDB`.`xi_xii` where subno='5' and rowid='${data?[position].rowid}'");
      for (var rows in subject)
      {
        sub5=rows[0];
      }
      subject=await connection!.query("Select distinct subname from `$currentDB`.`xi_xii` where subno='6' and rowid='${data?[position].rowid}'");
      for (var rows in subject)
      {
        sub6=rows[0];
      }
    }
    setState(() {
      data?[position].mainSubject=mainSub;
      data?[position].subject5=sub5;
      data?[position].subject6=sub6;
      loadingSubject[position]=false;
    });
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1990, 8),
        lastDate: DateTime(2101));
    if (picked != null )
      setState(() {
        selectedDate = picked;
        getdate=myFormat.format(selectedDate).toString();
        print(getdate);
      });
  }

   Future resetRollno(int position) async {
    var postData={
      "rowid":data?[position].rowid,
      "current_db":currentDB
    };
    var url = Uri.parse(
        'http://117.247.90.209/app/result/rollno_assign/reset_rollno.php');
    var response=await http.post(url,body: postData);
    if(response.statusCode==200)
    {
      ToastWidget.showToast(response.body, Colors.green);
      if(!(response.body.toString()=="Error"))
        {
          setState((){
            data?[position].rollno="";
            data?[position].section="";
          });
        }
    }
    else
      {
        ToastWidget.showToast("Connection error", Colors.red);
      }
   }

}
class Data
{
  String? sname,rollno="",section="",rowid,admno="",gen,previousSection="",
      previousRollno="", subject5="",subject6="",mainSubject="",sessionStatus="",cno="";
  String? tcno="",tcdate="",tcreason="";
  bool? tcMenuVisibility=false,tcEditButonVisibility=false,nonactive=false,
      notpromoted=false,assignButton=false;
  Data({this.rowid,this.sname,this.rollno,this.section,this.admno,this.gen,
    this.previousRollno,this.previousSection,this.subject5="",this.subject6="",
    this.mainSubject="",this.sessionStatus,this.tcno,this.tcdate,
    this.tcreason,this.cno,this.nonactive=false,this.notpromoted=false})
  {
    if(sessionStatus=='TC'||sessionStatus=='After Term I')
    {

      //this.tcMenuVisibility = true;
      //tcEditButonVisibility=true;
      assignButton=true;
      section='TC';
    }
    else if (sessionStatus=='Not active' && section=='')
      {
        assignButton=true;
        section='Not active';
      }
  }
}




