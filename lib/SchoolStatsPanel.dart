import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:result_app/settings/Settings.dart';
import "package:collection/collection.dart" as mycolle;
class SchoolStatsPanel extends StatefulWidget {
  String currentdb = "", nextdb = "";
  double screenheight, screenwidth;
  mysql.MySqlConnection connection;
  String  branch,user,branchname;
  SchoolStatsPanel (
      {Key key,
        this.currentdb,
        this.nextdb,
        @required this.connection,
        @required this.branch,this.branchname,
        this.screenheight,
        this.screenwidth})
      : super(key: key);

  @override
  _SchoolStatsPanelState createState() => _SchoolStatsPanelState(this.currentdb,
      this.nextdb,
      this.connection,
      this.branch,this.branchname,
      this.screenheight,
      this.screenwidth);
}

class _SchoolStatsPanelState extends State<SchoolStatsPanel> {
  String currentdb = "", nextdb = "";
  double screenheight, screenwidth;
  bool loading=true;
  int sum=0;
  mysql.MySqlConnection connection;
  String  branch,user,branchname;
  List data=[],genderData=[];
  _SchoolStatsPanelState(this.currentdb,
      this.nextdb,
      this.connection,
      this.branch,this.branchname,
      this.screenheight,
      this.screenwidth);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColor.BACKGROUND,
      appBar: AppBar(
        title: Text('School Summary',style: GoogleFonts.playball(
          fontSize: screenheight / 30,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],),),
        backgroundColor: AppColor.NAVIGATIONBAR,
      ),
      body:loading?Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text("Calculating...")
        ],
      ),): Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [dataBox(data: branchname,border: false,bold: true,
              backColor: AppColor.BACKGROUND)],),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [dataBox(data: "Class",bold: true,height: 50,
              width: 50),
            dataBox(data: "Section",bold: true,height: 50,
                width: 50,fsize: 12),dataBox(data: "Gender",bold: true,height:
            50,fsize: 12,
                width: 50),dataBox(data: "Rte",bold: true,
                height: 50,
                width: 50,fsize: 15),dataBox(data: "Category",bold: true,
                height: 50,
                width: 50,fsize:10),dataBox(data: "Count",bold: true,
                height: 50,
                width: 50,fsize: 15)],),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: data.length,
                itemBuilder: (context, position) {
                double fs=15;
                Color col=data[position][2]=='F'?Colors.pink:Colors.blue;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  dataBox(data: data[position][0].toString(),bold: true,height: 35,
                      width: 50,fsize: fs,textColor: col),
                  dataBox(data: data[position][1].toString(),bold: true,height: 35,
                      width: 50,fsize: fs,textColor: col),
                  dataBox(data: data[position][2].toString(),bold: true,
                      height: 35,
                      width: 50,fsize: fs,textColor: col),
                  dataBox(data: data[position][3].toString(),bold: true,
                      height: 35,
                      width: 50,fsize: fs,textColor: col),
                  dataBox(data: data[position][4].toString().substring
                    (0,data[position][4].toString().length>4?3:null),bold: true,
                      height: 35,
                      width: 50,fsize: fs,textColor: col,
                      backColor: data[position][4].toString().length<1?Colors
                          .redAccent:Colors.white),
                  dataBox(data: data[position][5].toString(),bold: true,
                      height: 35,
                      width: 50,fsize: fs,textColor: col)
                ],
              );
            }),
          ),
          dataBox(height: 15,border: false,backColor: AppColor.BACKGROUND),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [dataBox(data: "Class",bold: true,height: 50,
              width: 50),
            dataBox(data: "Section",bold: true,height: 50,
                width: 50,fsize: 12),dataBox(data: "Gender",bold: true,height:
            50,fsize: 12, width: 50),
            dataBox(data: "Sub-Total",bold: true,height:
            50,fsize: 12, width: 50),
              dataBox(data: "Total",bold: true,
                height: 50,
                width: 50,fsize: 15)],),
          Expanded(
            child: ListView.builder(
              itemCount: genderData.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, position) {
                  double fs=15;
                  Color col=position%2==0?Colors.grey[400]:Colors.grey[350];
                return  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [dataBox(data: genderData[position][0]
                      .toString(),
                      bold: true,height: 35,
                      width: 50,fsize: fs,backColor: col), dataBox(data:
                  genderData[position][1].toString(),
                      bold: true,height: 35,
                      width: 50,fsize: fs,backColor: col),
                    Column(
                      children: [
                        dataBox(data: genderData[position][2][0][0].toString(),
                            bold: true,
                            height: 17.5,
                            width: 50,fsize: 10,backColor: col),
                        dataBox(data: genderData[position][2][1][0].toString(),
                            bold: true,
                            height: 17.5,
                            width: 50,fsize: 10,backColor: col),
                      ],
                    ),
                    Column(
                      children: [
                        dataBox(data: genderData[position][2][0][1].toString(),
                            bold: true,
                            height: 17.5,
                            width: 50,fsize: 10,backColor: col),
                        dataBox(data: genderData[position][2][1][1].toString(),
                            bold: true,
                            height: 17.5,
                            width: 50,fsize: 10,backColor: col),
                      ],
                    ),
                    dataBox(data:
                    (genderData[position][2][0][1]+genderData[position][2
                      ][1][1]).toString(),
                        bold: true,
                        height: 35,
                        width: 50,fsize: 20,backColor: col),
                  ],
                );
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [dataBox(data:"Total strength",bold: true,fsize: 20,
                height: 30),dataBox(data: sum.toString(),bold: true,fsize: 20,
                height: 30)],
          )
        ],
      ),);
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
  Future loadData()async
  {
    loading=true;
    setState(() {

    });
    List data=[],genderData=[],section=[],cname=[];
    String sql="select cname,section,gen,rte,cat,count(cat) from "+currentdb+""
        ".nominal where branch="+branch+" and rollno is not null and rollno "
        "not in('',' ') group by cname,section,gen,rte,cat order by cno,"
        "section,gen,rte,cat";
    var results = await connection.query(sql);
    for (var rows in results){
      data.add([rows[0],rows[1],rows[2],rows[3],rows[4],rows[5]]);
    }
    /*sql="select cname,section,gen,count(gen) from "+currentdb+".nominal where branch="+branch+" and rollno is not null and rollno "
        "not in('',' ') group by cname,section,gen order by cname,section,gen";
    results=await connection.query(sql);
    for(var rows in results)
      {
       genderData.add([rows[0],rows[1],rows[2],rows[3]]);
      }*/
    sql="select distinct cname from "+currentdb+".nominal where "
        "branch='"+branch+"' order by cno";
    results=await connection.query(sql);
    List genCount=[];
    for (var cname in results)
      {
        sql="select distinct section from "+currentdb+".nominal where "
            "branch='"+branch+"' and cname ='"+cname[0]+"' and section not in "
            "('',' ') order by section";
        var res=await connection.query(sql);
        for (var section in res)
          {
            List gen=[];
            sql="select gen,count(*) from "+currentdb+".nominal "
                "where branch='"+branch+"' and cname ='"+cname[0]+"' "
                "and section='"+section[0]+"' and "
                "session_status not in ('TC after term1') group by gen";
            var r2=await connection.query(sql);
            for(var count in r2)
              {
                gen.add([count[0],count[1]]);
                sum=sum+count[1];
              }
            if(gen.length<2) {
              if (gen[0] == 'F')
              {
                gen.add(['M',0]);
              }
              else
                {
                  gen.add(['F',0]);
                }
            }
            genCount.add([cname[0],section[0],gen]);
          }
      }
    setState(() {
      this.data=data;
      this.genderData=genCount;
      loading=false;
    });
  }
}
class Data
{
  /*String cname="",section="",gen="",rte="",cat="",count="";
  Data({var data={this.cname:""}});*/
}