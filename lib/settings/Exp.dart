
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:result_app/MysqlHelper.dart' ;
import 'package:result_app/settings/InternetCheck.dart';
import 'package:result_app/settings/Settings.dart';
import 'package:result_app/widgets/ToastWidget.dart';

import 'Settings.dart';

class Exp extends StatefulWidget {
  double screenheight,screenwidth;
  mysql.MySqlConnection connection;
  String cname,section,branch;
 Exp({Key key, @required this.connection,@required this.cname,@required this.section,@required this.branch,this.screenheight,this.screenwidth}) : super(key: key);
  @override
  _ExpState createState() => _ExpState(this.connection,this.cname,this.section,this.branch,this.screenheight,this.screenwidth);
}

class _ExpState extends State<Exp> {
  mysql.MySqlConnection connection;
  String _selectedtask;
  MysqlHelper mysqlHelper=MysqlHelper();
  double screenheight,screenwidth;
  List<Data> data=[];
  List <TextEditingController> _controller=[];
  String cname,section,branch;
  _ExpState(this.connection,this.cname,this.section,this.branch,this.screenheight,this.screenwidth);
  void initState() {
    super.initState();

  }
  Future getConnection()async  {
    connection = await mysqlHelper.Connect();
  }
  @override
  Widget build(BuildContext context) {
      return Scaffold(
      backgroundColor: AppColor.BACKGROUND,
      appBar: AppBar(
        backgroundColor: AppColor.NAVIGATIONBAR,
        title: Text('Promote/Tc Panel'),
      ),
      body: Center(child: MaterialButton(child: Text("Click"),onPressed: ()async{await loadData();},color: Colors.amber,))
    );
  }
  Future loadData()async
  {try {
    await connection.query("set autocommit=0");
    var results = await connection.query(
        "update `kpsbspin_master`.`tcdetail` set tcno='2' where rowid='15'");
    results = await connection.query(
        "insert into `kpsbspin_master`.`tcdetail` (rowid) values('26')");
    await connection.query("commit");
    ToastWidget.showToast(results.affectedRows.toString(), Colors.red);
  }catch(Exception)
    {
      if(Exception.runtimeType==mysql.MySqlException)
        {
          ToastWidget.showToast(Exception.runtimeType.toString()+": "+Exception.toString(), Colors.red);
          await connection.query("rollback");
        }
      if(Exception.runtimeType==StateError) {
        if(NetworkStatus.NETWORKTYPE==0)
          {
            ToastWidget.showToast("No internet connection", Colors.red);
          }
        else {
          ToastWidget.showToast("Reconnecting to server, please wait!!!", Colors.red);
          await getConnection();
        }

      }
      if(Exception.runtimeType==TimeoutException)
        {
          ToastWidget.showToast(Exception.runtimeType.toString(), Colors.red);
        }
      if(Exception.runtimeType==SocketException)
      {
        ToastWidget.showToast(Exception.runtimeType.toString(), Colors.red);
      }
    }
  }
}
class Data
{
  String name;
  Data({this.name});
}