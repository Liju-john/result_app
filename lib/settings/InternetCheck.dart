import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:result_app/widgets/ToastWidget.dart';
import 'package:mysql1/mysql1.dart';
class NetworkStatus
{
  static int NETWORKTYPE=0;
  static void checkStatus()
  {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      if(result==ConnectivityResult.mobile)
      {
        NETWORKTYPE=1;
        //ToastWidget.showToast("Mobile Internet",Colors.green);
      }
      else if(result==ConnectivityResult.wifi)
      {
        NETWORKTYPE=2;
        //ToastWidget.showToast("Wifi Internet",Colors.blue);
      }
      else
      {
        NETWORKTYPE=0;
        ToastWidget.showToast("No Internet Connection",Colors.red);
      }
    });
  }
  static Future getConnectionSource()async
  {
    var result = await (Connectivity().checkConnectivity());
      if(result==ConnectivityResult.mobile)
      {
        NETWORKTYPE=1;
      }
      else if(result==ConnectivityResult.wifi)
      {
        NETWORKTYPE=2;
      }
      else
      {
        NETWORKTYPE=0;
      }

  }
}