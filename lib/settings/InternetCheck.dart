import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:result_app/widgets/ToastWidget.dart';
class NetworkStatus
{
  static int NETWORKTYPE=0;
  static void checkStatus() async
  {
    // final connectivityResult = await (Connectivity().checkConnectivity());
    StreamSubscription<List<ConnectivityResult>> subscription =
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      // Received changes in available connectivity types!
      print(result);
      if(result[0]==ConnectivityResult.mobile)
      {
        NETWORKTYPE=1;
        ToastWidget.showToast("Mobile Internet",Colors.green);
      }
      else if(result[0]==ConnectivityResult.wifi)
      {
        NETWORKTYPE=2;
        ToastWidget.showToast("Wifi Internet",Colors.blue);
      }
      else
      {
        NETWORKTYPE=0;
        ToastWidget.showToast("No Internet Connection",Colors.red);
      }
    });
  }
  // static Future getConnectionSource()async
  // {
  //   var result = await (Connectivity().checkConnectivity());
  //     if(result==ConnectivityResult.mobile)
  //     {
  //       NETWORKTYPE=1;
  //     }
  //     else if(result==ConnectivityResult.wifi)
  //     {
  //       NETWORKTYPE=2;
  //     }
  //     else
  //     {
  //       NETWORKTYPE=0;
  //     }
  //
  // }
}