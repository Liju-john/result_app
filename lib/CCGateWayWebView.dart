

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

class CCGateWayWebView extends StatefulWidget {
  String paymentURL="",branch;
  CCGateWayWebView({Key ?key,required this.paymentURL,
   required this.branch});

  @override
  State<CCGateWayWebView> createState() => _CCGateWayWebViewState(this.paymentURL,
      this.branch);
}

class _CCGateWayWebViewState extends State<CCGateWayWebView> {
  late String paymentURL="",branch;
  bool _isLoadingPage = true,error=false;
  double _progressValue = 0;
  _CCGateWayWebViewState(this.paymentURL,this.branch);
  InAppWebViewController ? webView;
  Timer? loadingTimeoutTimer;
  final int maxLoadingTimeInSeconds = 15;
  void initState() {
    super.initState();
    startLoadingTimer();
  }
  @override
  void dispose() {
    loadingTimeoutTimer?.cancel();
    super.dispose();
  }
  void startLoadingTimer() {
    loadingTimeoutTimer?.cancel();
    loadingTimeoutTimer = Timer(Duration(seconds: maxLoadingTimeInSeconds), () {
      if (webView != null) {
        webView!.stopLoading();
        setState(() {
          error = true;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Sizer(
        builder: (context, orientation, deviceType) {
      return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.white,
            title: Text("Payment Page",style: TextStyle(color:
            Colors.blue,fontWeight: FontWeight.bold,)),
          ),
          body: Column(
            children: [
              Visibility(
                visible: _progressValue==1?false:true,
                child: LinearProgressIndicator(
                  value: _progressValue,
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              _isLoadingPage
                  ? Center(
                child: CircularProgressIndicator(),
              )
                  : SizedBox.shrink(),
              Expanded(child: Stack(
                children: [InAppWebView(
                  onWebViewCreated: (InAppWebViewController controller) {
                    webView = controller;
                  },
                  onProgressChanged: ( controller, int progress) {
                    setState(() {
                      this._progressValue = progress / 100;
                    });
                  },
                  onLoadStart: ( controller, Uri? uri)
                    async {
                    print("Started loading.....");
                      setState(() {
                        error=false;
                        _isLoadingPage=true;
                      });
                    loadingTimeoutTimer?.cancel();
                      startLoadingTimer();
                      if (uri!.path.contains("close.php")) {
                        String payid=await controller.evaluateJavascript(source:
                        "window.document.getElementById('payid').value;");
                        String stat=await controller.evaluateJavascript(source:
                        "window.document.getElementById('stat').value;");
                        controller.stopLoading();
                        Navigator.of(context).pop();
                        //print(payid);
                        return;
                      }
                    },
                  onLoadError: (controller, url, code, message) {
                    controller!.stopLoading();
                    setState(() {
                      error=true;
                    });
                  },
                  onLoadStop:(controller, Uri ? uri)
                  {
                    setState(() {
                      _isLoadingPage=false;
                    });
                    loadingTimeoutTimer?.cancel();
                  },
                  initialUrlRequest: URLRequest(
                      url: Uri.parse(this.paymentURL)
                  ),
                  onReceivedServerTrustAuthRequest: (controller, challenge) async {
                    print(challenge);
                    return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                  },

                ),
                  if(error)Positioned.fill(
                    child: Container(
                        color: Colors.white,
                        child: Center(child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [Lottie.asset('lib/images/error.json',),
                              Text("Oops Lost in space!!!!",
                                style: TextStyle(color: Colors
                                    .black,fontFamily: 'BebasNeue',fontSize: 20),),
                            ],
                          ),
                        ),)
                    ),
                  ),
                ]
              ),),
            ],
          )
      );
        }
    );
  }
}
