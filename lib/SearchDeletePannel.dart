import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:result_app/settings/InternetCheck.dart';
import 'package:result_app/settings/Settings.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:http/http.dart' as http;
import 'package:result_app/widgets/ToastWidget.dart';

import 'MysqlHelper.dart';

class SearchDeletePanel extends StatefulWidget {
  String currentdb="",nextdb="";
  double screenheight,screenwidth;
  var branches=new LinkedHashMap();
  mysql.MySqlConnection connection;
  SearchDeletePanel({Key? key, required this.currentdb,required this.nextdb,required this.connection,
    required this.screenwidth,required this.screenheight,required this.branches});
  @override
  _SearchDeletePanelState createState() =>
      _SearchDeletePanelState(this.currentdb,this.nextdb,this.connection,
          this.screenwidth,this.screenheight,this.branches);
}

class _SearchDeletePanelState extends State<SearchDeletePanel> {
  List<Data> data=[];
  int searchResultLength=0;
  bool studentListRowVisible=false,showProgressBar=true,deleteComplete=true;
  MysqlHelper mysqlHelper=MysqlHelper();
  String currentdb="",nextdb="",searchBy="Name";
  double screenheight,screenwidth;
  var branches=new LinkedHashMap();
  TextEditingController searchController=TextEditingController();
  mysql.MySqlConnection connection;
  _SearchDeletePanelState(this.currentdb,this.nextdb,this.connection,this
      .screenwidth,this.screenheight,this.branches);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BACKGROUND,
      appBar:AppBar(
        elevation: 0,
        backgroundColor:AppColor.NAVIGATIONBAR,
        title:Text("Find Student", style: GoogleFonts.playball(
          fontSize: screenheight / 30,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],),),),
      body: Column(
        children: [
          searchKeywordWidget(),
          Expanded(
            child: Visibility(visible: studentListRowVisible,
                child: data.isEmpty?Center(child: showProgressBar?CircularProgressIndicator():
                Text("No Record Found",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 25),)):
                searchResultsWidget()),
          )
        ],
      ),
    );
  }

  Widget searchKeywordWidget()
  {
    return
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.only(bottom: 5),
            width: screenwidth,
            decoration: BoxDecoration(color: Colors.red[50],border: Border.all(color: Colors.grey,width: 2),borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Row(
                    children: [
                      Text("Search by"),
                      SizedBox(width: 5,),
                      DropdownButton<String>(
                        value: searchBy,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        onChanged: (String? newValue) async {
                          setState(() {
                            searchBy = newValue!;
                            searchController.text="";
                          });
                        },
                        items: <String>['Admno','Name']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )],
                  ),
                   Row(
                     children: [SizedBox(width: screenwidth*0.5,
                       child: TextFormField(
                       controller: searchController,
                       decoration: InputDecoration(hintText: "Enter ${searchBy=="Admno"?"Admno":"Name"}"),
                   ),
                     ),
                     TextButton(onPressed: ()async{
                       FocusScope.of(context).requestFocus(FocusNode());
                       if(searchController.text.length>=3) {
                         setState(() {
                           studentListRowVisible = true;
                         });
                         await loadData();
                       }
                       else
                       {
                         ToastWidget.showToast("Minimum 3 characters needed",Colors.purple);
                       }
                     },
                       child: Row(
                       children: [SvgPicture.asset("assets/images/search.svg",height: 30,width: 30,),SizedBox(width: 5,),
                       Text("Search",style: TextStyle(fontWeight: FontWeight.w900,color: Colors.yellow[900]),)],
                     ),),
                      ],)
                  ],
                ),
              ],
            ),
          ),
        );
  }
  Widget searchResultsWidget()
  {
    return
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.deepPurple[300]!,width: 2),borderRadius: BorderRadius.circular(15),color: Colors.white),
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: data.length,
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (context, position)
              {
                return
                    ExpansionTile(
                      leading: Text(data[position].admno,style: TextStyle(fontWeight: FontWeight.w900,fontSize: 15),),
                        title: Text(data[position].sname),
                      childrenPadding:const EdgeInsets.all(8.0),
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [SizedBox(child: Text('Father Name',),width: screenwidth*0.22),
                                SizedBox(width: 10,),Text(data[position].fname,style: TextStyle(fontWeight: FontWeight.w900))],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [SizedBox(child: Text('Mother Name',),width: screenwidth*0.22),
                                SizedBox(width: 10,),Text(data[position].mname,style: TextStyle(fontWeight: FontWeight.w900))],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [SizedBox(child: Text('Current class',),width: screenwidth*0.22),
                                SizedBox(width: 10,),Text(data[position].cname,style: TextStyle(fontWeight: FontWeight.w900))],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [SizedBox(child: Text('Section',),width: screenwidth*0.22),
                                SizedBox(width: 10,),Text(data[position].section,style: TextStyle(fontWeight: FontWeight.w900))],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [SizedBox(child: Text('Mobile no',),width: screenwidth*0.22),
                                SizedBox(width: 10,),Text(data[position].mobileno,style: TextStyle(fontWeight: FontWeight.w900))],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              children: [SizedBox(child: Text('Branch',),width: screenwidth*0.22),
                                SizedBox(width: 10,),Text(data[position].branch,style: TextStyle(fontWeight: FontWeight.w900))],
                            ),
                           //delete student comented in both php and flutter
                           //  SizedBox(height: 10,),
                           // deleteComplete?Row(
                           //    mainAxisSize: MainAxisSize.min,
                           //    children: [
                           //      TextButton(
                           //        onPressed: ()async{
                           //          await deleteConfirmation(position);
                           //        },
                           //      //color: Colors.yellow[600],
                           //      child: Row(
                           //        children: [Column(
                           //          children: [
                           //            Icon(Icons.delete,color: Colors.red,size: 30,),
                           //            Text("Delete",style: TextStyle(fontWeight: FontWeight.w900,color: Colors.red,fontSize: 12))
                           //          ],
                           //        ),
                           //          //SizedBox(width: 5,),
                           //          ],
                           //      ),),],
                           //  ):Row(
                           //   mainAxisSize: MainAxisSize.min,
                           //   children: [CircularProgressIndicator(backgroundColor: Colors.red,)],),
                          ],
                        )
                      ],
                    );
              }),
        ),
      );
  }
  Future<void> deleteConfirmation(int position) async
  {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 10,
          backgroundColor: Colors.red[200],
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20.0),),
          title: Text('Alert',style: TextStyle(fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you surely want to delete this student.This will delete the student permanently'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('NO',style: TextStyle(fontWeight: FontWeight.w900,color: Colors.green,fontSize: 20)),
              onPressed: () async{
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('YES',style: TextStyle(fontWeight: FontWeight.w900,color: Colors.red,fontSize: 20)),
              onPressed: () async{
                Navigator.of(context).pop();
                setState(() {
                  studentListRowVisible = true;
                });
                await deleteStudent(position);
                await loadData();
              },
            ),
          ],
        );
      },
    );
  }
  Future deleteStudent(int position) async
  {
      setState(() {
        deleteComplete=false;
      });
      var postData=
      {
        "current_db":currentdb, "next_db":nextdb,
        "rowid":data[position].rowid,
        "cname":data[position].cname
      };
      var url=Uri.parse('http://117.247.90.209/app/result/deleteStudent.php');
      var response=await http.post(url,body: postData);
      if(response.statusCode==200)
      {
        ToastWidget.showToast(response.body, Colors.red);
      }
      else
        {
          ToastWidget.showToast(response.reasonPhrase!, Colors.red);
        }
      setState(() {
        deleteComplete=true;
      });
  }
  Future getConnection()async {
    if(connection!=null)
    {
      await connection.close();
    }
    connection=await mysqlHelper.Connect();
  }
  /*Future loadDataPhp()async
  {
    this.data.clear();
    List<Data> data=[];
    var postData=
    {
      "current_db":currentdb, "next_db":nextdb,
      "searchBy":searchBy=='Name'?"sname":"admno",
      "searchKeyword":searchController.text
    };
    var url=Uri.parse('http://117.247.90.209/app/result/search.php');
    var response=await http.post(url,body: postData);
    if(response.statusCode==200)
    {
      print(response.body);
      var jasonData=json.decode(response.body);
      for(var rows in jasonData)
        {
          data.add(Data(rowid: rows['rowid'],sname: rows['sname'],fname: rows['fname'],mname: rows['mname'],admno: rows['admno'],cname: rows['cname'],section: rows['section']));
        }
    }
    else
    {
      ToastWidget.showToast("Something Went Wrong!!!!",Colors.red);
    }
    this.data=data;
    setState(() {

    });
  }*/
  Future loadData()async
  {
    await getConnection();
    String branchName;
    String columnName=searchBy=='Name'?"sname":"admno";
    this.data.clear();
    List<Data> data=[];
    setState(() {
        showProgressBar=true;
    });
    var branchnames=LinkedHashMap();
      for(String k in branches.keys)
        {
            branchnames[branches[k]]=k;
        }
      print(branchnames);
    try {
        String query="select t2.rowid,sname,fname,mname,cname,section,mobileno,t2.branch,"
            "admno from `$currentdb`.`session_tab` t1,`kpsbspin_master`.`studmaster` t2,"
            "`kpsbspin_master`.`classdetail` t3 where t1.cno=t3.cno and t1.rowid=t2.rowid "
            "and $columnName like '%${searchController.text}%' limit 50";
        var result=await connection.query(query);
        searchResultLength=result.length;
        for(var rows in result)
          {
            /*if (rows[7] == '1') {
              branchName='Koni';
            }
            if (rows[7] == '2') {
              branchName='Narmada Nagar';
            }
            if (rows[7] == '3') {
              branchName='Sakri';
            }
            if (rows[7] == '4') {
              branchName='KV';
            }*/
            branchName=branchnames[rows[7]];
            data.add(Data(rowid: rows[0].toString(),sname: rows[1],fname: rows[2]
                ,mname: rows[3],cname: rows[4],section: rows[5],mobileno:rows[6],
                branch: branchName,admno: rows[8]));
          }
        if(data.length==50)
          {
            ToastWidget.showToast("Only showing first 50 names", Colors.purple);
          }
        setState(() {
          this.data=data;
        });
        if(data.length==0)
          {
            setState(() {
              showProgressBar=false;
            });
          }
        connection.close();
    }catch(Exception)
    {
      if(Exception.runtimeType==StateError) {
        if(NetworkStatus.NETWORKTYPE==0)
        {
          ToastWidget.showToast("No internet connection", Colors.red);
        }
        else {
          ToastWidget.showToast("Reconnecting to server, please wait!!!", Colors.red);
          await connection.close();
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
        ToastWidget.showToast("Device error", Colors.red);
      }
    }
  }
}

class Data
{
  String sname="",fname="",mname="",rowid="",cname="",admno="",section="",mobileno="",branch="";
  Data({required this.sname,required this.fname,required this.mname,
    required this.rowid,required this.cname,required this.admno,
    required this.section,required this.mobileno,required this.branch});
}
