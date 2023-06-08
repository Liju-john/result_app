import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:result_app/settings/Settings.dart';

import '../NominalPanel.dart';

class SelectDateRow extends StatefulWidget {
  List<NominalData> data;
  int position;
  String type;
  SelectDateRow(this.data,this.position,this.type);
  @override
  _SelectDateState createState() => _SelectDateState(this.data,this.position,
      this.type);
}

class _SelectDateState extends State<SelectDateRow> {
  DateTime selectedDate = DateTime.now();
  List<NominalData> data;
  int position;
  String type;
  _SelectDateState(this.data,this.position,this.type);
  var myFormat = DateFormat('dd-MM-yyyy');
  String getdate="";
  /*Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1990, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        getdate=myFormat.format(selectedDate).toString();
      });
  }*/
  static void showDateDialog(BuildContext context,{required Widget child,
  required VoidCallback onClicked})=>showCupertinoModalPopup(context: context,
      builder: (context)=>CupertinoActionSheet(
        actions: [child],
        cancelButton: CupertinoActionSheetAction(child: Text("Done"),
        onPressed: onClicked,),
      ));
  Widget datePicker()=>SizedBox(height: 150,
    child: CupertinoDatePicker
      (
      backgroundColor: AppColor.BACKGROUND,
      initialDateTime: selectedDate,
      maximumYear: DateTime.now().year,
      mode: CupertinoDatePickerMode.date,
      onDateTimeChanged: (dateTime)=>setState(()
      {selectedDate=dateTime;
      getdate=myFormat.format(selectedDate).toString();
      }),
        ),
  );
  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [Text(this.type=="dob"?data[position].dob:data[position].doa),
        IconButton(icon: Icon(Icons.calendar_today_sharp,color:Colors.blue),
            onPressed:()async{

          DateTime dob=
            data[position].dob==""?DateTime.now():(new DateFormat
              ("dd-MM-yyyy hh:mm:ss").parse(data[position].dob+" "
              "00:00:00"));
          DateTime doa=
            data[position].doa==""?DateTime.now():(new DateFormat
              ("dd-MM-yyyy hh:mm:ss").parse(data[position].doa+" "
              "00:00:00"));
          selectedDate=this.type=="dob"?dob:doa;
          showDateDialog(context,child: datePicker(),onClicked: (){
            setState(() {
          if(getdate.isNotEmpty)
            this.type=="dob"?data[position].dob=getdate:data[position].doa=getdate;
          });
            Navigator
              .pop(context);});
          //await _selectDate(context);
          /*setState(() {
          if(getdate.isNotEmpty)
            this.type=="dob"?data[position].dob:data[position].doa=getdate;
          });*/
        }),
      ],
    );
  }
}
