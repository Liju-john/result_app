// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:result_app/settings/InternetCheck.dart';
// import 'package:result_app/settings/Settings.dart';
// import 'package:mysql1/mysql1.dart' as mysql;
// import 'package:http/http.dart' as http;
// import 'package:result_app/widgets/ToastWidget.dart';
// import 'AssignRollnoSectionTcPage.dart';
// import 'MysqlHelper.dart';
//
//
// class SectionDropDown extends StatefulWidget {
//   String previousDB,currentDB="",nextDB="";
//   List<Data> data=[];
//   List<String> subject5=[],subject6=[],mainSubject=[];
//   mysql.MySqlConnection connection;
//   int position;
//   String cname;
//   String section;
//   double screenWidth;
//   double screenHeight;
//   SectionDropDown({Key key,this.data,this.position,this.section,this.cname,
//     this.subject5,this.subject6,this.screenWidth,this.screenHeight,this.connection,
//     this.currentDB,this.nextDB,this.previousDB,this.mainSubject});
//   @override
//   _SectionDropDownState createState() => _SectionDropDownState(this.data,
//       this.position,this.section,this.cname,this.subject5,this.subject6,
//       this.screenWidth,this.screenHeight,this.connection,this.currentDB,this.nextDB,this.previousDB,this.mainSubject);
// }
//
// class _SectionDropDownState extends State<SectionDropDown> {
//   List<Data> data = [];
//   String previousDB,currentDB="",nextDB="";
//   mysql.MySqlConnection connection;
//   List<String> subject5= [],
//       subject6 = [],mainSubject=[];
//   int position;
//   double screenWidth;
//   double screenHeight;
//   bool loading=true;
//   String section, cname,_selectedSubject5,_selectedSubject6,_selectedMainSubject;
//
//   _SectionDropDownState(this.data, this.position,
//       this.section, this.cname,
//       this.subject5, this.subject6,
//       this.screenWidth,this.screenHeight,this.connection
//       ,this.currentDB,this.nextDB,this.previousDB,this.mainSubject);
//
//   @override
//   Widget build(BuildContext context) {
//     FocusScope.of(context).requestFocus(FocusNode());
//     return DropdownButton<String>(
//       value: section,
//       hint: Text('Assign'),
//       icon: const Icon(Icons.arrow_downward),
//       iconSize: 24,
//       elevation: 16,
//       onChanged: (String newValue) async {
//         setState(() {
//           section = newValue;
//           data[position].section = newValue;
//         });
//         if ((cname == 'IX' || cname == 'X'||cname =='XI'||cname=='XII') && (section!='TC'&& section!='INACTIVE'))
//         {
//           await loadAdditionalSubject(position);
//           await subjectSelection(position);
//         }
//       },
//       items: <String>['A', 'B', 'C', 'D', 'E', 'F', 'TC', 'INACTIVE']
//           .map<DropdownMenuItem<String>>((String value) {
//         return DropdownMenuItem<String>(
//           value: value,
//           child: Text(value),
//         );
//       }).toList(),
//     );
//   }
//
//   //load previous subject if they have any
//   Future loadAdditionalSubject(int position) async
//   {
//     String sub5,sub6,mainSub;
//     if(cname=='IX' ||cname=='X')
//     {
//       var subject=await connection.query("Select distinct subname from `$currentDB`.`ix_x` where subno='5' and rowid='${data[position].rowid}'");
//       for (var rows in subject)
//       {
//         sub5=rows[0];
//       }
//       subject=await connection.query("Select distinct subname from `$currentDB`.`ix_x` where subno='6' and rowid='${data[position].rowid}'");
//       for (var rows in subject)
//       {
//         sub6=rows[0];
//       }
//     }
//     else if(cname=='XI' ||cname=='XII')
//     {
//       var subject=await connection.query("Select distinct subname from `$currentDB`.`xi_xii` where subno='2' and rowid='${data[position].rowid}'");
//       for (var rows in subject)
//       {
//         mainSub=rows[0];
//       }
//       subject=await connection.query("Select distinct subname from `$currentDB`.`xi_xii` where subno='5' and rowid='${data[position].rowid}'");
//       for (var rows in subject)
//       {
//         sub5=rows[0];
//       }
//       subject=await connection.query("Select distinct subname from `$currentDB`.`xi_xii` where subno='6' and rowid='${data[position].rowid}'");
//       for (var rows in subject)
//       {
//         sub6=rows[0];
//       }
//     }
//     setState(() {
//       data[position].mainSubject=mainSub;
//       data[position].subject5=sub5;
//       data[position].subject6=sub6;
//     });
//   }
//
// //for class ix to xii
//   Future<void> subjectSelection(int position) async
//   {
//     _selectedSubject5=data[position].subject5;
//     _selectedSubject6=data[position].subject6;
//     _selectedMainSubject=data[position].mainSubject;
//     print(_selectedSubject5);
//     return showDialog<void>(
//         context: context,
//         barrierDismissible: false, // user must tap button!
//         builder: (context) {
//           return StatefulBuilder(
//               builder: (context,setState){
//                 return AlertDialog(
//                     elevation: 10,
//                     shape: RoundedRectangleBorder(
//                       borderRadius:
//                       BorderRadius.circular(20.0),),
//                     title: Text(
//                         'Select Subjects', style: TextStyle(fontWeight: FontWeight.w900)),
//                     content: SingleChildScrollView(
//                         child: ListBody(
//                             children: <Widget>[
//                               Row(mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(data[position].sname,style:TextStyle(fontWeight: FontWeight.w900,fontSize: 12)),
//                                 ],
//                               ),//name of student
//                               (cname=='XI'||cname=='XII')?Text("Main Subject",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 12),):Center(),
//                               (cname=='XI'||cname=='XII')?DropdownButton<String>(
//                                 value: _selectedMainSubject,
//                                 hint:Text("Choose"),
//                                 icon: const Icon(Icons.arrow_downward),
//                                 iconSize: 24,
//                                 elevation: 16,
//                                 onChanged: (String newValue) async {
//                                   setState(() {
//                                     data[position].mainSubject=newValue;
//                                     _selectedMainSubject=data[position].subject5;
//                                   });
//                                 },
//                                 items: mainSubject
//                                     .map<DropdownMenuItem<String>>((String value) {
//                                   return DropdownMenuItem<String>(
//                                     value: value,
//                                     child: SizedBox(width:screenWidth*0.5,child: Text(value)),
//                                   );
//                                 }).toList(),
//                               ):Center(),//main subject
//                               Text("Subject 5",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 12),),
//                               DropdownButton<String>(
//                                 value: _selectedSubject5,
//                                 hint:Text("Choose"),
//                                 icon: const Icon(Icons.arrow_downward),
//                                 iconSize: 24,
//                                 elevation: 16,
//                                 onChanged: (String newValue) async {
//                                   setState(() {
//                                     data[position].subject5=newValue;
//                                     _selectedSubject5=data[position].subject5;
//                                   });
//                                 },
//                                 items: subject5
//                                     .map<DropdownMenuItem<String>>((String value) {
//                                   return DropdownMenuItem<String>(
//                                     value: value,
//                                     child: SizedBox(width:screenWidth*0.5,child: Text(value)),
//                                   );
//                                 }).toList(),
//                               ),//V subject
//                               Text("Subject 6",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 12),),
//                               DropdownButton<String>(
//                                 value: _selectedSubject6,
//                                 hint: Text('Choose'),
//                                 icon: const Icon(Icons.arrow_downward),
//                                 iconSize: 24,
//                                 elevation: 16,
//                                 onChanged: (String newValue) async {
//                                   setState(() {
//                                     data[position].subject6=newValue;
//                                     _selectedSubject6=data[position].subject6;
//                                   });
//                                 },
//                                 items: subject6
//                                     .map<DropdownMenuItem<String>>((String value) {
//                                   return DropdownMenuItem<String>(
//                                     value: value,
//                                     child: SizedBox(width: screenWidth*0.5,child: Text(value)),
//                                   );
//                                 }).toList(),
//                               ),//VI subject
//                               Row( mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text("Ok",style: TextStyle(fontWeight: FontWeight.w900,color: Colors.green,fontSize: 17),)),
//                                   TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text("Cancel",style: TextStyle(fontWeight: FontWeight.w900,color: Colors.red,fontSize: 17)))],)
//                             ]
//                         )
//                     )
//                 );
//               });
//         }
//     );
//   }
// }