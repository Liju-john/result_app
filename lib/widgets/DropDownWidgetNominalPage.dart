import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:result_app/NominalPanel.dart';

import '../MarksEntryPage.dart';

class NominalDropDownMenu extends StatefulWidget {
  List<NominalData> data;
  int position;
  BuildContext cont;
  String selectedRte;
  String selectedGender;
  String selectedcategory;
  String type;
  NominalDropDownMenu(this.data,this.position,this.selectedRte,this.selectedGender,this.selectedcategory,this.type);
  @override
  _NominalDropDownMenuState createState() => _NominalDropDownMenuState(this.data,this.position,this.selectedRte,this.selectedGender,this.selectedcategory,this.type);
}

class _NominalDropDownMenuState extends State<NominalDropDownMenu> {
  List<NominalData> data;
  String type;
  DateTime selectedDate = DateTime.now();
  var myFormat = DateFormat('dd-MM-yyyy');
  String getdate="";
  int position;
  String selectedRte="";
  String selectedGender="";
  String selectedcategory="";
  _NominalDropDownMenuState(this.data,this.position,this.selectedRte,this.selectedGender,this.selectedcategory,this.type);
  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    return  getDropDown(position);
  }

  Widget getDropDown(int position)
  {
    if(type=="RTE") {
      return DropdownButton<String>(
      value:selectedRte,
      icon: const Icon(Icons.arrow_downward,color: Colors.blue,),
      iconSize: 24,
      elevation: 16,
      onChanged: (String newValue) async {
        setState(() {
          selectedRte = newValue;
          data[position].rte=newValue;
        });
      },
      items: <String>['YES','NO']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );}
    else if(type=='CAT')
      {
        return DropdownButton<String>(
          value:selectedcategory,
          icon: const Icon(Icons.arrow_downward,color: Colors.blue),
          iconSize: 24,
          elevation: 16,
          onChanged: (String newValue) async {
            setState(() {
              selectedcategory = newValue;
              data[position].cat=newValue;
            });
          },
          items: <String>['NA','GENERAL','SC','ST','OBC']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        );
      }
    else if(type=='GEN')
      {
        return DropdownButton<String>(
          value:selectedGender,
          icon: const Icon(Icons.arrow_downward,color: Colors.blue,),
          iconSize: 24,
          elevation: 16,
          onChanged: (String newValue) async {
            setState(() {
              selectedGender = newValue;
              data[position].gen=newValue;
            });
          },
          items: <String>['F','M']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        );
      }
    else if(type=='CALE')
      {
        print("else");
      }

  }
}
