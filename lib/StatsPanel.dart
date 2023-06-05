import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:result_app/MysqlHelper.dart';
import 'package:result_app/settings/InternetCheck.dart';
import 'package:result_app/settings/Settings.dart';
import 'package:result_app/widgets/ToastWidget.dart';
import 'package:share_plus/share_plus.dart';

class StatsPanel extends StatefulWidget {
  String currentdb = "", nextdb = "";
  bool admnoChange;
  double screenheight, screenwidth;
  mysql.MySqlConnection connection;
  String cname, section, branch, tid,user;

  StatsPanel(
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
      this.tid,this.user})
      : super(key: key);

  @override
  _StatsPanelState createState() => _StatsPanelState(
      this.currentdb,
      this.nextdb,
      this.connection,
      this.cname,
      this.section,
      this.branch,
      this.screenheight,
      this.screenwidth,
      this.admnoChange,
      this.tid,this.user
  );
}

class _StatsPanelState extends State<StatsPanel> {
  String currentdb = "", nextdb = "";
  bool admnoChange,loading=true;
  double screenheight, screenwidth;
  mysql.MySqlConnection connection;
  String user,cname, section, branch, tid;
  int boysCount=0,girlsCount=0,girlsGenRte=0,girlsGenNa=0,girlsSTRte=0,
      girlsSTNa=0,girlsSCRte=0,girlsSCNa=0,girlsObcRte=0,girlsObcNa=0,
      boysGenRte=0,boysGenNa=0,boysSTRte=0,boysSTNa=0,boysSCRte=0,boysSCNa=0,
  boysObcRte=0,boysObcNa=0;
  MysqlHelper mysqlHelper = MysqlHelper();
  _StatsPanelState(
      this.currentdb,
      this.nextdb,
      this.connection,
      this.cname,
      this.section,
      this.branch,
      this.screenheight,
      this.screenwidth,
      this.admnoChange,
      this.tid,this.user);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BACKGROUND,
      appBar: AppBar(
        title: Text('Class Summary',style: GoogleFonts.playball(
        fontSize: screenheight / 30,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],),),
        backgroundColor: AppColor.NAVIGATIONBAR,
      ),
      body: loading?Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text("Calculating...")
        ],
      ),):SingleChildScrollView(scrollDirection: Axis.vertical,child: classSummary())
    );
  }
  Widget classSummary()
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment:MainAxisAlignment.center,children: [dataBox
          (data:cname+"-"+section,
            height: 40,border:
        false,bold: true,fsize: 20,textColor: Colors.purple),
        ],),
        Row(children: [dataBox(border: false,width: screenwidth*0.2),
          dataBox
            (data: "Girls", borderWidth: 2,
              width: screenwidth*0.39,bold: true,fsize: 18,height: 35),
          dataBox
            (data: "Boys",width: screenwidth*0.39,borderWidth: 2,bold: true,fsize:
          18,height:
          35)
        ],),
        Row(children: [dataBox(border: false,width: screenwidth*0.2),
          dataBox
            (data: "RTE",
              borderWidth: 2,
              width: screenwidth*0.13,bold: true,fsize: 15,height: 50),
          dataBox
            (data: "NON RTE",width: screenwidth*0.13,borderWidth: 2,bold: true,
              fsize:15,height:50),
          dataBox
            (data: "Total",width: screenwidth*0.13,borderWidth: 2,bold: true,
              fsize:15,height: 50),
          dataBox
            (data: "RTE",
              borderWidth: 2,
              width: screenwidth*0.13,bold: true,fsize: 15,height:50),
          dataBox
            (data: "NON RTE",width: screenwidth*0.13,borderWidth: 2,bold: true,
              fsize:15,height: 50),
          dataBox
            (data: "Total",width: screenwidth*0.13,borderWidth: 2,bold: true,
              fsize:15,height: 50)
        ],),
        Row(children: [dataBox(data:"General",width: screenwidth*0.2,
            borderWidth: 2,bold: true,fsize: 15,height: 35),
          dataBox
            (data: girlsGenRte.toString(),
              borderWidth: 2, width: screenwidth*0.13,bold: true,fsize: 15,
              height: 35),
          dataBox
            (data: girlsGenNa.toString(),width: screenwidth*0.13,
              borderWidth: 2, bold: true, fsize:15,height: 35),
          dataBox
            (data: (girlsGenRte+girlsGenNa).toString(),width: screenwidth*0.13,
              borderWidth: 2, bold: true, fsize:18,height: 35,textColor:
              Colors.pink),
          dataBox
            (data: boysGenRte.toString(),
              borderWidth: 2,
              width: screenwidth*0.13,bold: true,fsize: 15,height: 35),
          dataBox
            (data: boysGenNa.toString(),width: screenwidth*0.13,borderWidth: 2,bold:
          true,
              fsize:15,height: 35),
          dataBox
            (data: (boysGenRte+boysGenNa).toString(),width: screenwidth*0.13,
              borderWidth: 2,bold: true,
              fsize:18,height: 35,textColor: Colors.blue)
        ],), //general
        Row(children: [dataBox(data:"ST",width: screenwidth*0.2,
            borderWidth: 2,bold: true,fsize: 15,height: 35),
          dataBox
            (data: girlsSTRte.toString(),
              borderWidth: 2,
              width: screenwidth*0.13,bold: true,fsize: 15,height: 35),
          dataBox
            (data: girlsSTNa.toString(),width: screenwidth*0.13,borderWidth: 2,bold:
          true,
              fsize:15,height: 35),
          dataBox
            (data: (girlsSTRte+girlsSTNa).toString(),width: screenwidth*0.13,
              borderWidth: 2,
              bold:
              true,
              fsize:18,height: 35,textColor: Colors.pink),
          dataBox
            (data: boysSTRte.toString(),
              borderWidth: 2,
              width: screenwidth*0.13,bold: true,fsize: 15,height: 35),
          dataBox
            (data: boysSTNa.toString(),width: screenwidth*0.13,borderWidth: 2,bold:
          true,
              fsize:15,height: 35),
          dataBox
            (data: (boysSTRte+boysSTNa).toString(),width: screenwidth*0.13,
              borderWidth: 2,
              bold: true,
              fsize:18,height: 35,textColor: Colors.blue)
        ],),// ST
        Row(children: [dataBox(data:"SC",width: screenwidth*0.2,
            borderWidth: 2,bold: true,fsize: 15,height: 35),
          dataBox
            (data: girlsSCRte.toString(),
              borderWidth: 2,
              width: screenwidth*0.13,bold: true,fsize: 15,height: 35),
          dataBox
            (data: girlsSCNa.toString(),width: screenwidth*0.13,borderWidth: 2,bold:
          true,
              fsize:15,height: 35),
          dataBox
            (data: (girlsSCRte+girlsSCNa).toString(),width: screenwidth*0.13,
              borderWidth: 2,
              bold: true,
              fsize:18,height: 35,textColor: Colors.pink),
          dataBox
            (data: boysSCRte.toString(),
              borderWidth: 2,
              width: screenwidth*0.13,bold: true,fsize: 15,height: 35),
          dataBox
            (data: boysSCNa.toString(),width: screenwidth*0.13,borderWidth: 2,bold:
          true,
              fsize:15,height: 35),
          dataBox
            (data: (boysSCNa+boysSCRte).toString(),width: screenwidth*0.13,
              borderWidth: 2,
              bold: true,
              fsize:18,height: 35,textColor: Colors.blue)
        ],),//SC
        Row(children: [dataBox(data:"OBC",width: screenwidth*0.2,
            borderWidth: 2,bold: true,fsize: 15,height: 35),
          dataBox
            (data: girlsObcRte.toString(),
              borderWidth: 2,
              width: screenwidth*0.13,bold: true,fsize: 15,height: 35),
          dataBox
            (data: girlsObcNa.toString(),width: screenwidth*0.13,borderWidth:
          2,bold:
          true,
              fsize:15,height: 35),
          dataBox
            (data: (girlsObcRte+girlsObcNa).toString(),width: screenwidth*0.13,
              borderWidth: 2,
              bold: true,
              fsize:18,height: 35,textColor: Colors.pink),
          dataBox
            (data: boysObcRte.toString(),
              borderWidth: 2,
              width: screenwidth*0.13,bold: true,fsize: 15,height: 35),
          dataBox
            (data: boysObcNa.toString(),width: screenwidth*0.13,borderWidth: 2,bold:
          true,
              fsize:15,height: 35),
          dataBox
            (data: (boysObcNa+boysObcRte).toString(),width: screenwidth*0.13,
              borderWidth: 2,
              bold: true,
              fsize:18,height: 35,textColor: Colors.blue)
        ],),//OBC
        Row(children: [dataBox(data:"",width: screenwidth*0.46,border: false,
            height: 35),
          dataBox
            (data: (girlsGenRte+girlsGenNa+girlsSTRte+girlsSTNa+girlsSCRte
              +girlsSCNa+girlsObcNa+girlsObcRte)
              .toString(),width:
          screenwidth*0.13,
              borderWidth: 2,
              bold: true,
              fsize:18,height: 35,textColor: Colors.pink),
          dataBox(data:"",width: screenwidth*0.26,border: false,
              height: 35),
          dataBox
            (data: (boysGenRte+boysGenNa+boysSTRte+boysSTNa+boysSCRte
              +boysSCNa+boysObcNa+boysObcRte)
              .toString(),width:
          screenwidth*0.13,
              borderWidth: 2,
              bold: true,
              fsize:18,height: 35,textColor: Colors.blue),
        ],),//subtotal
        Row(children: [dataBox(border: false,height: 40)],),
        Row(children: [dataBox(data:"",width: 10,border: false),
        dataBox(data:"Total as per above data:-",border: false,bold: true),
        dataBox(data: (boysObcRte+boysObcNa+boysGenRte+boysGenNa+boysSTNa
            +boysSTRte+boysSCRte+boysSCNa+girlsObcRte+girlsObcNa+girlsSCNa
            +girlsSCRte+girlsSTNa+girlsSTRte+girlsGenNa+girlsGenRte)
            .toString()
            ,border:
        false,bold: true,fsize: 18)],),
        Row(children: [dataBox(data:"",width: 10,border: false),
          dataBox(data:"Total as per nominal:-",border: false,bold: true),dataBox(data:
          (boysCount+girlsCount).toString(),border: false,bold: true,fsize: 18
          )],),
        Row(children: [dataBox(data:"",width: 10,border: false),
          dataBox(data:"Discrepancy:-",border: false,bold: true),dataBox(data:
          ((boysCount+girlsCount)-(boysObcRte+boysObcNa+boysGenRte+boysGenNa+boysSTNa
              +boysSTRte+boysSCRte+boysSCNa+girlsObcRte+girlsObcNa+girlsSCNa
              +girlsSCRte+girlsSTNa+girlsSTRte+girlsGenNa+girlsGenRte)).toString(),border: false,bold: true,
  fsize: 18
          )],),
        /*Row(children: [MaterialButton(onPressed: () async {
          await callJsp();
          *//*String path=await callJsp();
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>BillPdf(filepath:path)));*//*
        },child: Text("Click here"),)],)*/
      ],
    );
  }
  /*Future <String> callJsp() async
  {
    String billno="23134";
    String selectedDb=this.currentdb;
    String cname="I";
    var postdata={"cname":cname,
      "selectedDb":this.currentdb,"billno":billno};
    var url = Uri.parse('http://117.247.90.209:8080/erp-1.0/FetchBill');
    var response = await http.post(url, body: postdata);
    if(response.statusCode==200)
    {
      //var jasonData=json.decode(response.body);
      final bytes = response.bodyBytes;
      *//*Directory directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/example2.pdf');*//*
      var path="/storage/emulated/0/Download/example2.pdf";
      final file=File(path);
      await file.writeAsBytes(bytes, flush: true);
      //final url = Uri.parse("file://"+file.path);
      print('PDF file saved to ${file.path}');
      *//*if (await canLaunchUrl(url)) {
        print("inside");
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }*//*
      await Share.shareFiles([file.path], text: 'Sharing PDF file');
    }
  }*/


  Future loadData() async {
    try {
      String query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and gen='m' and "
          "session_status not in ('after term I')";
      var results = await connection.query(query);
      for (var rows in results){
        boysCount=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and gen='f'"
          "and session_status not in ('after term I')";
      results = await connection.query(query);
      for (var rows in results){
        girlsCount=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='yes' and "
          "cat='general' and gen='m' and "
          "session_status not in ('after term I')";
      results = await connection.query(query);
      for (var rows in results){
        boysGenRte=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='no' and "
          "cat='general' and gen='m' and "
          "session_status not in ('after term I')";
      results = await connection.query(query);
      for (var rows in results){
        boysGenNa=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='yes' and "
          "cat='general' and gen='f' and "
          "session_status not in ('after term I')";
      results = await connection.query(query);
      for (var rows in results){
        girlsGenRte=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='no' and "
          "cat='general' and gen='f' and "
          "session_status not in ('after term I')";
      results = await connection.query(query);
      for (var rows in results){
        girlsGenNa=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='yes' and "
          "cat='sc' and gen='m' and "
          "session_status not in ('after term I')";
      results = await connection.query(query);
      for (var rows in results){
        boysSCRte=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='no' and "
          "cat='sc' and gen='m' and "
          "session_status not in ('After Term I')";
      results = await connection.query(query);
      for (var rows in results){
        boysSCNa=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='yes' and "
          "cat='sc' and gen='f' and "
          "session_status not in ('After Term I')";
      results = await connection.query(query);
      for (var rows in results){
        girlsSCRte=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='no' and "
          "cat='sc' and gen='f' and "
          "session_status not in ('After Term I')";
      results = await connection.query(query);
      for (var rows in results){
        girlsSCNa=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='yes' and "
          "cat='st' and gen='m' and "
          "session_status not in ('After Term I')";
      results = await connection.query(query);
      for (var rows in results){
        boysSTRte=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='no' and "
          "cat='st' and gen='m' and "
          "session_status not in ('After Term I')";
      results = await connection.query(query);
      for (var rows in results){
        boysSTNa=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='yes' and "
          "cat='st' and gen='f' and "
          "session_status not in ('After Term I')";
      results = await connection.query(query);
      for (var rows in results){
        girlsSTRte=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='no' and "
          "cat='st' and gen='f' and "
          "session_status not in ('After Term I')";
      results = await connection.query(query);
      for (var rows in results){
        girlsSTNa=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='yes' and "
          "cat='obc' and gen='m' and "
          "session_status not in ('After Term I')";
      results = await connection.query(query);
      for (var rows in results){
        boysObcRte=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='no' and "
          "cat='obc' and gen='m' and "
          "session_status not in ('After Term I')";
      results = await connection.query(query);
      for (var rows in results){
        boysObcNa=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='yes' and "
          "cat='obc' and gen='f' and "
          "session_status not in ('After Term I')";
      results = await connection.query(query);
      for (var rows in results){
        girlsObcRte=rows[0];
      }
      query="select count(gen) from `$currentdb`.`nominal` where "
          "cname='$cname' "
          "and section='$section' and branch='$branch'  and rollno "
          "not in ('',' ') and rollno is not null and  rte='no' and "
          "cat='obc' and gen='f' and "
          "session_status not in ('After Term I')";
      results = await connection.query(query);
      for (var rows in results){
        girlsObcNa=rows[0];
      }
      setState(() {
        loading=false;
      });
    } catch (Exception) {
      if (Exception.runtimeType == StateError) {
        if (NetworkStatus.NETWORKTYPE == 0) {
          ToastWidget.showToast("No internet connection", Colors.red);
        } else {
          ToastWidget.showToast(
              "Reconnecting to server, please wait!!!", Colors.red);
          print(Exception.toString());
          await getConnection();
          await loadData();
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
  Widget dataBox({String data="",double borderWidth=1,double margin=0,double
  height=30,double width,double fsize=15, bool border=true,Color
  borderColor=Colors.black,Color textColor=Colors.black,Color
  backColor=Colors.white,bool bold=false})
  {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.all(margin),
      padding: EdgeInsets.all(3.0),
      decoration: BoxDecoration(
          border: border?Border.all(color: borderColor,width: borderWidth):null
      ),
      child: Text(data,textAlign: TextAlign.center,style:TextStyle(color: textColor,
          fontSize: fsize,
          fontWeight: bold?FontWeight.w900:null),),
    );
  }
  void initState() {
    super.initState();
    loadData();
  }

  Future getConnection() async {
    if (connection != null) {
      await connection.close();
    }
    connection = await mysqlHelper.Connect();
  }
}
