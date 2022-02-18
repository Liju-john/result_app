import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
class DateDialog
{
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;
  getCalendar(BuildContext context)
  {
    Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
      child: Container(
        height: 600.0,
        width: 400.0,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: TableCalendar(
                firstDay: DateTime.utc(1990, 01, 01),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  // Use `selectedDayPredicate` to determine which day is currently selected.
                  // If this returns true, then `day` will be marked as selected.

                  // Using `isSameDay` is recommended to disregard
                  // the time-part of compared DateTime objects.
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    // Call `setState()` when updating the selected day
                    // setState(() {
                    //   _selectedDay = selectedDay;
                    //   _focusedDay = focusedDay;
                    //   print(_focusedDay);
                    //});
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    // Call `setState()` when updating calendar format
                    // setState(() {
                    //   _calendarFormat = format;
                    // });
                  }
                },
              )
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text('Awesome', style: TextStyle(color: Colors.red),),
            ),
            Padding(padding: EdgeInsets.only(top: 50.0)),
            FlatButton(onPressed: (){
              Navigator.of(context).pop();
            },
                child: Text('Got It!', style: TextStyle(color: Colors.purple, fontSize: 18.0),))
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (BuildContext context) => errorDialog);
  }

}