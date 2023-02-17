import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:http/http.dart' as http;
import 'package:result_app/settings/Settings.dart';
import 'package:url_launcher/url_launcher.dart';

import 'FeeProfile.dart';
class OutstandingPanel extends StatefulWidget {
  String currentdb="",nextdb="";
  mysql.MySqlConnection connection;
  double screenheight,screenwidth;
  String cname,section,branch;
  OutstandingPanel({Key key,this.currentdb,this.nextdb,this.connection,
    this.cname,this.section,this.branch,this.screenheight,this.screenwidth}) : super(key: key);

  @override
  State<OutstandingPanel> createState() => _OutstandingPanelState(this.currentdb,
      this.nextdb,this.connection,this.cname,this.section,this.branch,
      this.screenheight,this.screenwidth);
}

class _OutstandingPanelState extends State<OutstandingPanel> {
  String currentdb="",nextdb="";
  String url="assets/images/logo.png";
  List <Data> data=[];
  String insno="";
  String _selectedMonth;
  Map<String, String> months = {
    'April': "1",
    'June': "2",
    'July': "3",
    'August': "4",
    'September': "5",
    'October': "6",
    'November': "7",
    'December': "8",
    'January': "9",
    'February': "10",
    'March':  "11",
  };
  mysql.MySqlConnection connection;
  String cname,section,branch,selectedate="",getdate="";
  double screenheight,screenwidth;
  _OutstandingPanelState(this.currentdb,this.nextdb,this.connection,this.cname,
      this.section,this.branch,this.screenheight,this.screenwidth);
  void initState(){
    super.initState();
    //loadData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BACKGROUND,
      appBar: AppBar(
        backgroundColor: AppColor.NAVIGATIONBAR,
        title: Text('Fees Paid Detail',style: GoogleFonts.playball(
          fontSize: screenheight / 30,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],),),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0,10,0),
              child: Row(
                children: [Text("Installment Month"),SizedBox(width: 10,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButton(
                      hint: Text('Select a month'),
                      value: _selectedMonth,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedMonth = newValue;
                          insno=months[newValue];
                        });
                        loadData();
                      },
                      items: months.keys.map((month) {
                        return DropdownMenuItem(
                          child: Text(month),
                          value: month,
                        );
                      }).toList(),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        // adjust the width and height according to your needs
                        child: Text("RTE",style: TextStyle(fontWeight: FontWeight.bold),),
                        decoration: BoxDecoration(
                          color: Colors.orange, // replace with your desired color
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      Divider(height: 3,),
                      Container(
                        child: Text("NON RTE",style: TextStyle(fontWeight: FontWeight.bold),),
                        decoration: BoxDecoration(
                          color: Colors.tealAccent, // replace with your desired color
                          shape: BoxShape.rectangle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            data.isEmpty?Center(child: CircularProgressIndicator()):Expanded(
              child: ListView.builder(
    scrollDirection: Axis.vertical,
    itemCount: data.length,
    padding: const EdgeInsets.all(5.0),
    itemBuilder: (context,position){
              return rowData(position);
    }
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget rowData(int position)
  {
    return Card(
      color: data[position].rte=='YES'?Colors.orange:
      data[position].balance=="0"?Colors.lightGreen:Colors.tealAccent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text("Rollno: "),
                Text(data[position].rollno,style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(width: 10,),
                Text("Name: "),
                Flexible(
                  child: Text(data[position].sname,style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                )],
            ),
            Divider(thickness: 2,),
            Row(
              children: [SizedBox(width: this.screenwidth*0.20,
                child:Text("Receivable",textAlign: TextAlign.center,),),
                SizedBox(width: this.screenwidth*0.20,
                  child:Text("Paid",textAlign: TextAlign.center,),),
                SizedBox(width: this.screenwidth*0.20,
                  child:Text("Balance",textAlign: TextAlign.center,),)],
            ),

            Row(
              children: [SizedBox(width: this.screenwidth*0.20,
                child:Text(data[position].total,textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w900)),),
                SizedBox(width: this.screenwidth*0.20,
                  child:Text(data[position].paid,textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w900,color: Colors.black)),),
                SizedBox(width: this.screenwidth*0.20,
                  child:Text(data[position].balance,textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w900,fontSize: 18,color: Colors.red)),),
                SizedBox(width: this.screenwidth*0.15,
                  child:IconButton(icon:Icon(Icons.call,color: Colors.black),
                    onPressed: () => launch('tel:+91'+data[position].mobileno),)),
                SizedBox(width: this.screenwidth*0.15,
                    child:IconButton(icon:Icon(Icons.qr_code,color: Colors.black),
                      onPressed: () =>
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => StuddentFeeStructure(
                                rowid: data[position]
                                    .rowid,
                                sname: data[position].sname,mobileno: data[position].mobileno,
                                branch:this.branch,fname:data[position].fname,
                              ))),)),
              ],
            ),
            ],
        ),
      ),
    );
  }
  Future loadData() async
  {
    List<Data> data=[];
    this.data=[];
    var postdata={"branch":this.branch,"cname":this.cname,
      "section":this.section,"insno":insno,
      "current_db":this.currentdb};
    var url = Uri.parse('http://117.247.90.209/app/result/outstanding.php');
    var response = await http.post(url, body: postdata);
    if(response.statusCode==200)
      {
        var jasonData=json.decode(response.body);
        for(var rows in jasonData)
          {
           data.add(Data(sname: rows["sname"],rollno: rows["rollno"],
               total: rows["total"],balance: rows["balance"],paid:rows["paid"],
               rte: rows["rte"],mobileno: rows['mobileno'],rowid: rows['rowid'],fname: rows['fname']));
          }
      }
    setState(() {
      this.data=data;
    });
  }
}
class Data{
  String sname,rollno,rte,total,paid,balance,mobileno,rowid,fname;
  Data({this.sname,this.rollno,
    this.rte,this.total,this.paid,this.balance,this.mobileno,this.rowid,this.fname}){}
}
