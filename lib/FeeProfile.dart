import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:result_app/widgets/ToastWidget.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

class StuddentFeeStructure extends StatefulWidget {
  double mheight,mwidth;
  String rowid,sname,mobileno,branch,fname;
  StuddentFeeStructure({Key key,this.rowid,this
      .sname,this.mobileno,this.branch,this.fname}) : super(key:
  key);

  @override
  State<StuddentFeeStructure> createState() => _StuddentFeeStructureState
    (this.rowid,this.sname,this.mobileno,this.branch,this.fname);
}

class _StuddentFeeStructureState extends State<StuddentFeeStructure> {
  String key="",secret="",qrurl;
  double mheight,mwidth,tf=0,af=0,pf=0,bf=0,famt=0,service=0;
  String orderid="",payid="";
  double prevbal=0,miscbal=0;
  bool loading=false;
  int prevInst=0,paid_installmentno,x=0;
  String ins_name="",branch="";
  List<FeeData> data=[];
  List<BusFeeData> bus=[];
  List<MainFeeData> mainFee=[];
  Map<String,dynamic> summary=Map();
  Map<int,String> insMonth=Map();
  String rowid,sname,mobileno,fname;
  _StuddentFeeStructureState(this.rowid,this.sname,this.mobileno,this.branch,this.fname);
  void initState(){
    super.initState();
    loadData();
  }
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
        builder: (context, orientation, deviceType) {
          return Scaffold(
              appBar: AppBar(
                elevation: 1,
                actions: [IconButton(onPressed: ()async{
                  setState(() {
                    this.data=[];
                    this.summary.clear();
                    tf=af=pf=bf=famt=prevbal=miscbal=0;
                    prevbal=miscbal=0;
                    prevInst=x=0;
                    ins_name="";
                    orderid=payid="";
                    insMonth.clear();
                  });
                  loadData();
                }, icon: Icon(Icons.refresh))],
                iconTheme: IconThemeData(
                  color: Colors.black, //change your color here
                ),
                toolbarHeight: 8.h,
                title: Column(
                  children: [
                    Text(sname,style: TextStyle(color: Colors.black, fontSize: 13.0.sp),),
                    Text("Total amount:-"+famt.toString(),style: TextStyle(color:
                    Colors.blue,fontWeight: FontWeight.bold,fontSize: 12.0.sp))
                  ],
                ),
                centerTitle: true,
                backgroundColor: Colors.white,
              ),
              body: data.length<=0?Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    [SpinKitThreeInOut(color: Colors.pinkAccent,),Text("Loading fee "
                        "structure..",style:
                    TextStyle
                      (fontWeight: FontWeight.bold),)
                    ],)):SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Text("Fee Detail",style: MyTextStyle(),),
                    SingleChildScrollView(
                      scrollDirection:Axis.horizontal,
                      child: DataTable(
                          headingRowColor:MaterialStateProperty.all<Color>(Colors
                              .grey[300]) ,
                          headingRowHeight: 3.h,
                          columnSpacing: 3.w,
                          border: TableBorder.all(color: Colors.black,),
                          columns: [DataColumn(label: Text("Fee Type",style:
                          MyTextStyle()
                            ,)),
                            DataColumn(label: Text("Fee",style: MyTextStyle())),
                            DataColumn(label: Text("Select",style: MyTextStyle()))],
                          rows:
                          mainFee.map(
                                  (e){
                                return  DataRow(
                                    cells: [
                                      DataCell(Text(e.feetype)),
                                      DataCell(Column(
                                        children: [
                                          Text("Fee:-"+e.feeamount),
                                          Text("Bal:-"+e.feebal,
                                            style:
                                            TextStyle
                                              (color: e.ppaid?Colors.green:Colors.red,
                                                fontWeight: FontWeight
                                                    .bold),),
                                        ],
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                      )),
                                      DataCell(IgnorePointer(
                                        ignoring: e.ppaid,
                                        child: Checkbox(value:e.paid, onChanged: (bool
                                        value) {
                                          double amt=double.parse(e.feebal);
                                          if(e.installment_no==-1)
                                          {
                                            value?summary["prev"]=["Previous Balance",e
                                                .feebal]:summary.remove("prev");
                                          }
                                          else if(e.installment_no==0)
                                          {
                                            value?summary["admission"]=["Admission Fees",e.feebal]
                                                :summary.remove("admission");
                                          }
                                          else if(e.installment_no==-2)
                                          {
                                            value?summary["misc"]=["Miscellaneous Fee",e.feebal]
                                                :summary.remove("misc");
                                          }
                                          if(value)
                                          {
                                            famt=famt+double.parse(e.feebal);
                                            if(e.installment_no==-1)
                                            {
                                              prevbal=0;
                                            }
                                            else if(e.installment_no==-2)
                                            {
                                              miscbal=0;
                                            }
                                          }
                                          else
                                          {
                                            famt=famt-double.parse(e.feebal);
                                            summary.remove(e.feetype);
                                            if(e.installment_no==-1)
                                            {
                                              prevbal=double.parse(e.feebal);
                                            }
                                            else if(e.installment_no==-2)
                                            {
                                              miscbal=double.parse(e.feebal);
                                            }
                                          }
                                          setState((){
                                            e.paid=value;
                                          });
                                        },),
                                      ))
                                    ]
                                );
                              }).toList()
                      ),
                    ),
                    Text("Tuition Fee Detail",style: MyTextStyle(),),
                    SingleChildScrollView(
                      scrollDirection:Axis.horizontal,
                      child: DataTable(
                          headingRowColor:MaterialStateProperty.all<Color>(Colors
                              .grey[300]) ,
                          headingRowHeight: 3.h,
                          columnSpacing: 3.w,
                          border: TableBorder.all(color: Colors.black,),
                          columns: [DataColumn(label: Text("Installment Name",style: MyTextStyle(),)),
                            DataColumn(label: Text("Tuition Fee",style: MyTextStyle())),
                            DataColumn(label: Text("Select",style: MyTextStyle()))],
                          rows:
                          data.map(
                                  (e){
                                return DataRow(
                                    cells: [
                                      DataCell(Text(e.feetype)),
                                      DataCell(Column(
                                        children: [
                                          Text("Fee:-"+e.feeamount),
                                          Text("Bal:-"+e.feebal,
                                            style:
                                            TextStyle
                                              (color: e.ppaid?Colors.green:Colors.red,
                                                fontWeight: FontWeight
                                                    .bold),),
                                        ],
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                      )),
                                      DataCell(IgnorePointer(
                                        ignoring: e
                                            .ppaid||prevbal!=0||miscbal!=0,
                                        child: Checkbox(value:e.paid, onChanged: (bool
                                        value) {
                                          double amt=double.parse(e.feebal);
                                          //if(e.installment_no>0&&e.installment_no<11){
                                          if(e.installment_no>0){
                                            if(ins_name.isEmpty)
                                            {
                                              if(prevInst+1==e
                                                  .installment_no){
                                                ins_name=e.feetype+" to "+e.feetype;
                                                prevInst=e.installment_no;}
                                              else{
                                                ToastWidget.showToast("Invalid "
                                                    "Selection", Colors.red);
                                                return null;
                                              }
                                            }
                                            else
                                            {
                                              if(prevInst+1==e.installment_no)
                                              {//forward direction
                                                if (e.installment_no - 1 != 0) {
                                                  ins_name =
                                                      ins_name.substring(0, ins_name
                                                          .indexOf("to")) + ""
                                                          "to " + (value ? insMonth[e
                                                          .installment_no] : insMonth[e
                                                          .installment_no - 1]);
                                                }
                                                else {
                                                  ins_name = "";
                                                  prevInst=x;
                                                }
                                                prevInst=e.installment_no;
                                              }else if(prevInst==e.installment_no)
                                                //backward direction
                                                  {
                                                if (e.installment_no - 1 != 0) {
                                                  ins_name =
                                                      ins_name.substring(0, ins_name
                                                          .indexOf("to")) + ""
                                                          "to " +  insMonth[e
                                                          .installment_no-1];
                                                  prevInst=e.installment_no-1;
                                                }
                                                else {
                                                  ins_name = "";
                                                  prevInst=x;
                                                }
                                              }
                                              else {
                                                ToastWidget.showToast("Invalid "
                                                    "Selection", Colors.red);
                                                return null;
                                              }
                                            }}
                                          if(e.installment_no==-1)
                                          {
                                            value?summary["prev"]=["Previous Balance",e
                                                .feebal]:summary.remove("prev");
                                          }
                                          else if(e.installment_no==0)
                                          {
                                            value?summary["admission"]=["Admission Fees",e.feebal]
                                                :summary.remove("admission");
                                          }
                                          else if(e.installment_no==-2)
                                          {
                                            value?summary["misc"]=["Miscellaneous Fee",e.feebal]
                                                :summary.remove("misc");
                                          }
                                          else
                                          {

                                            value?tf=tf+amt:tf=tf-amt;
                                            tf!=0?summary["tution_fees"]=[ins_name,
                                              tf.toString()]:summary.remove
                                              ("tution_fees");
                                          }
                                          if(value)
                                          {
                                            famt=famt+double.parse(e.feebal);
                                          }
                                          else
                                          {
                                            famt=famt-double.parse(e.feebal);
                                            summary.remove(e.feetype);
                                          }
                                          setState((){
                                            e.paid=value;
                                          });
                                        },),
                                      )
                                          ,onTap:(){
                                            if(prevbal>0||miscbal>0)
                                            {
                                              Fluttertoast.showToast(msg: "Kindly clear the previous dues/miscellaneous first",
                                                  toastLength: Toast.LENGTH_SHORT);
                                            }
                                          } )
                                    ]
                                );
                              }).toList()
                      ),
                    ),
                    Text("Bus Fee Detail",style: MyTextStyle(),),
                    SingleChildScrollView(
                      scrollDirection:Axis.horizontal,
                      child: DataTable(
                          headingRowHeight: 3.h,
                          columnSpacing: 3.w,
                          border: TableBorder.all(color: Colors.black,),
                          columns: [
                            DataColumn(label: Text("Installment Name",style: MyTextStyle(),)),
                            DataColumn(label: Text("Bus Fee",style: MyTextStyle())),
                            DataColumn(label: Text("Select",style: MyTextStyle()))],
                          rows:
                          bus.map(
                                  (e){
                                return  DataRow(
                                    cells: [
                                      DataCell(Text(e.feetype)),
                                      DataCell(Column(
                                        children: [
                                          Text("Fee:-"+e.busamount),
                                          Text("Bal:-"+e.busbal,style: TextStyle
                                            (color: e.ppaid?Colors.green:Colors.red,
                                              fontWeight: FontWeight
                                                  .bold,fontSize: 16),),
                                        ],
                                      )),
                                      DataCell(IgnorePointer(ignoring: e
                                          .ppaid,
                                        child: Checkbox(value:e.paid,
                                          onChanged: (bool
                                          value) {
                                            double amt=double.parse(e.busbal);
                                            value?bf=bf+amt:bf=bf-amt;
                                            bf==0?summary.remove("bus_fees")
                                                :(summary["bus_fees"]=["Bus Fees",
                                              bf.toString()]);
                                            value?famt=famt+amt:famt=famt-amt;
                                            setState((){
                                              e.paid=value;
                                            });
                                          },),
                                      ))
                                    ]
                                );
                              }).toList()
                      ),
                    ),
                    Text("Summary",style: MyTextStyle(),),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                            headingRowColor:MaterialStateProperty.all<Color>(Colors
                                .grey[300]) ,
                            headingRowHeight: 3.h,
                            columnSpacing: 3.w,
                            dataRowHeight: 4.h,
                            border: TableBorder.all(color: Colors.black,),
                            columns: [DataColumn(label: Text("Fee Type",style:
                            MyTextStyle(),)),
                              DataColumn(label: Text("Amount",style: MyTextStyle())),],
                            rows:
                            summary.entries.map((e) => DataRow(cells:
                            [DataCell(Text(e.value[0])),DataCell(Text(e.value[1]))])).toList()
                        )),
                    Row( mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Total:-",style: TextStyle(fontWeight: FontWeight
                            .bold,fontSize: 16),),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(famt.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                        ),
                        TextButton(
                          style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.pink)
                          ),
                          onPressed: () async {
                            if(famt<=0)
                            {
                              Fluttertoast.showToast(msg: "No fee selected",
                                  toastLength: Toast.LENGTH_SHORT);
                            }
                            else if(prevbal>0)
                            {
                              Fluttertoast.showToast(msg: "Kindly clear the previous "
                                  "balance first",
                                  toastLength: Toast.LENGTH_SHORT);
                            }
                            else if(miscbal>0 && tf>0)
                            {
                              Fluttertoast.showToast(msg: "Kindly clear the "
                                  "miscellaneous first",
                                  toastLength: Toast.LENGTH_SHORT);
                            }
                            else{
                              openGateway(famt);
                            }
                          },
                          child: Text('Generate QR',style: TextStyle(fontWeight: FontWeight
                              .bold,
                              fontSize: 15
                          ),),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              bottomNavigationBar:Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Note:- In case, if you don't get the receipt "
                    "after successful payment, then kindly wait for 3 "
                    "working days and then check under payment history. If "
                    "still you don't get then contact school.",
                  style:
                  TextStyle(fontWeight: FontWeight.bold,fontSize: 11),),
              )
          );});
  }
  TextStyle MyTextStyle()
  {
    return TextStyle(fontWeight: FontWeight.bold);
  }
  Future <void>  loadData() async{
    List<FeeData> data=[];
    List<BusFeeData> busdata=[];
    List<MainFeeData> maindata=[];
    var postdata={"rowid":this.rowid,"branch":this.branch};
    var url = Uri.parse('http://117.247.90.209/app/kpshome/studentfeeprofileexp.php');
    var response = await http.post(url, body: postdata);
    if (response.statusCode == 200) {
      var jasonData=json.decode(response.body);
      for(var rows in jasonData)
      {
        int ins=int.parse(rows["ins_no"]);
        String bal;
        if(ins==0)
        {
          bal=rows['admbal'].toString();
        }
        else if(ins==-1)
        {
          bal=rows['prevbal'].toString();
          prevbal=double.parse(bal);
        }
        else if(ins==-2)
        {
          bal=rows['miscbal'].toString();
          miscbal=double.parse(bal);
        }
        else
        {
          bal=rows['tfbal'].toString();
          insMonth[ins]=rows['feetype'];
          //if(ins>0&&ins<11)
          if(ins>0)
          {
            if(rows['tfbal']==0)
            {
              prevInst=ins;
            }
          }
        }
        if(ins!=0&&ins!=-1&&ins!=-2)
        {
          busdata.add(BusFeeData(feetype: rows['feetype'].toString(),feeamount:
          rows['feeamount'].toString(),busamount: rows['busamount'].toString(),
              busbal: rows['busbal'].toString(),feebal: rows['tfbal'].toString
                (),installment_no: int.parse(rows["ins_no"])));
          data.add(FeeData(feetype: rows['feetype'].toString(),feeamount:
          rows['feeamount'].toString(),busamount: rows['busamount'].toString(),
            busbal: rows['busbal'].toString(),feebal: bal,installment_no: int
                .parse(rows["ins_no"]),admbal:
            rows['admbal'],miscbal: rows['miscbal'],prevbal: rows['prevbal'],));
        }
        else
        {
          maindata.add(MainFeeData(feetype: rows['feetype'].toString(),
            feeamount:
            rows['feeamount'].toString(),busamount: rows['busamount'].toString(),
            busbal: rows['busbal'].toString(),feebal: bal,installment_no: int
                .parse(rows["ins_no"]),admbal:
            rows['admbal'],miscbal: rows['miscbal'],prevbal: rows['prevbal'],));
          /* print(rows['feetype'].toString());*/
        }
        key=rows['key'];
        secret=rows['secret'];
      }
      setState((){
        x=prevInst;
        this.data=[];
        this.data=data;
        this.bus=[];
        this.bus=busdata;
        this.mainFee=[];
        this.mainFee=maindata;
      });
    }
  }

  void openGateway(double fmt) async{
    /*ToastWidget.showLoaderDialog(context,loadingText: "Initializing payment"
        "...");*/

    DateTime date=DateTime.now().add(Duration(minutes: 5));
    int closeby=date.millisecondsSinceEpoch ~/ 1000;
    String des="";
    var notes={};
    summary.forEach((key, value) {
      des=des+" "+summary[key][0];
      notes[key]=summary[key][1]+"|"+summary[key][0];
    });
    String insName=tf==0?"":summary['tution_fees'][0];
    String inwords=getInWords(famt).trim();

    notes['other']="insname|"+insName+"--branch|"+this.branch+"--rowid|"+this
        .rowid+"--inwords|"+inwords+"--famt|"+famt.toString();


    var postdata={"fname":this.fname,"sname":this.sname,
      'notes':jsonEncode(notes),"close_by":closeby.toString(),
      "key":this.key,"secret":this.secret,"branch":this.branch,"fmt":(fmt*100).toString()};

    var url = Uri.parse('http://117.247.90.209/app/kpshome/rz.php');
    var response = await http.post(url, body: postdata);
    if(response.statusCode==200)
    {
      qrurl=response.body;
      showAlertDialog(context, qrurl,fmt,sname,fname);
    }
  }
  }
showAlertDialog(BuildContext context,String qrurl,double fmt,String sname,String fname) {
  // Create button
  Widget okButton = TextButton(
    child: Text("Okay"),
    style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            )
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        backgroundColor: MaterialStateProperty.all<Color>
          (Colors.black)
    ),
    onPressed: () {
        Navigator.of(context).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    scrollable: true,
    title: Text("Scan to pay"),
    content: WillPopScope(
      onWillPop: (){return Future.value(false);},
      child:FutureBuilder(
        future: precacheImage(NetworkImage(qrurl), context),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                /*Text("Student Name:-"+sname),
                Text("Father Name:-"+fname),
                Text("Amount:-"+fmt.toString()),*/
                Image.network(qrurl,
                  fit: BoxFit.cover,
                  ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Amount:-"+fmt.toString(),style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                  [SpinKitThreeInOut(color: Colors.pinkAccent,),Text("Generating QRCode..",style:
                  TextStyle
                    (fontWeight: FontWeight.bold),)
                  ],));
          }
        },
      ),),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
  String getInWords(double fmt)
  {

    var num = ["Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven"
      , "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen", ""];
    var des = ["", "Ten", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seve"
        "nty", "Eighty", "Ninety", " "];
    var dmls = ["", "", "Hundred", "Thousand", "", "Lakh", ""];
    //int x, temp, count, y ;
    String Words= '';
    int x = fmt.toInt();
    int temp = 0;
    int count = 0;
    if(x==0)
    {
      Words=Words+num[0];
    }
    else
    {
      while(x>0) {
        int y = x % 10;
        x = (x / 10).toInt();
        count = count + 1;
        temp = temp * 10 + y;
      }
      x = temp;
      temp = 0;
      while(x>0)
      {
        int y = x % 10;
        if (count == 3 || count == 1 || count == 4 || count == 6 )
        {
          if (y > 0) Words=Words+" "+num[y];
          count = count - 1;

        }
        else
        {
          if( count == 2 || count == 5 || count == 7 )
          {
            if( y == 1)
            {
              temp = temp * 10 + y;
              x = (x / 10).toInt();
              y =  x % 10;
              temp = temp * 10 + y;
              Words=Words+" "+num[temp];
              temp = 0;

            }
            else
            {
              Words=Words+" "+des[y];
              x =(x/10).toInt();
              y = x % 10;
              if (y > 0)  Words=Words+" "+num[y];
            }
            count = count - 2;
          }


        }
        if (count == 0) break;
        if (y == 0 && count == 2)
        {}
        else
        {

          Words=Words+" "+dmls[count];

        }
        x = (x/10).toInt();

      }

    }
    return Words;
  }
class BusFeeData {
  String feetype,feeamount,busamount,feebal,busbal;
  int installment_no;
  bool paid=false,ppaid=false;
  BusFeeData({this.feetype,this.feeamount,this.busamount,this.feebal,this
      .busbal,this.installment_no}){
    if(double.parse(this.busbal)==0)
    {
      this.paid=true;
      this.ppaid=true;
    }
  }
}
class FeeData{
  String feetype,feeamount,busamount,feebal,busbal,prevbal,admbal,miscbal;
  bool paid=false,ppaid=false;
  int installment_no;
  FeeData({this.feetype,this.feeamount,this.busamount,this.feebal,this
      .busbal,this.installment_no,this.prevbal,this.admbal,this.miscbal}){
    if(double.parse(this.feebal)==0)
    {
      this.paid=true;
      this.ppaid=true;
    }
  }
}
class MainFeeData{
  String feetype,feeamount,busamount,feebal,busbal,prevbal,admbal,miscbal;
  bool paid=false,ppaid=false;
  int installment_no;
  MainFeeData({this.feetype,this.feeamount,this.busamount,this.feebal,this
      .busbal,this.installment_no,this.prevbal,this.admbal,this.miscbal}){
    if(double.parse(this.feebal)==0)
    {
      this.paid=true;
      this.ppaid=true;
    }
  }
}
