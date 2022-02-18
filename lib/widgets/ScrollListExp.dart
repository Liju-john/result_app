import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:result_app/widgets/ToastWidget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ScrollListExp extends StatefulWidget {

  @override
  _ScrollListExpState createState() => _ScrollListExpState();
}

class _ScrollListExpState extends State<ScrollListExp> {
  final controller=ItemScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scroll list demo"),),
      body: ScrollablePositionedList.builder(
          itemCount: 5000,
          shrinkWrap: true,
          itemScrollController: controller,
          itemBuilder:
    (context,index){
        return Card(child: Container(alignment: Alignment.center,
          padding: EdgeInsets.only(left: 5,right: 2,top: 5,bottom: 5),
            child: Text(index.toString(),style: TextStyle(color: Colors.blue
            ,fontWeight: FontWeight.w900,fontSize: 20),)));
    }),
      floatingActionButton: FloatingActionButton(child: Text("Click here"),
    onPressed: ()async{
        await scrollToIndex(4500);
        ToastWidget.showToast("clcked", Colors.red);
    },),
    );
  }
  Future scrollToIndex(int index) async
  {
    controller.scrollTo(index: index, duration: Duration(seconds: 1));
  }
}
