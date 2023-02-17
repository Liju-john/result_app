import 'package:flutter/cupertino.dart';

class PaymentQR extends StatefulWidget {
  String url;
  PaymentQR({Key key,this.url}) : super(key: key);

  @override
  State<PaymentQR> createState() => _PaymentQRState(this.url);
}

class _PaymentQRState extends State<PaymentQR> {
    String url;
  _PaymentQRState(this.url);
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
