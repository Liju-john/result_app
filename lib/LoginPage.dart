import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:result_app/MenuPage.dart';
import 'package:result_app/settings/InternetCheck.dart';
import 'package:result_app/settings/Settings.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:result_app/widgets/ToastWidget.dart';

import 'MysqlHelper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String id="", password="";
  mysql.MySqlConnection? connection;
  MysqlHelper mysqlHelper = MysqlHelper();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NetworkStatus.checkStatus();
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Text(
                'KPS Teacher App',
                style:GoogleFonts.playball(
                  fontSize: MediaQuery.of(context).size.height / 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],)/*TextStyle(
                  fontSize: MediaQuery.of(context).size.height / 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),*/
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                "assets/images/logo.png",
                height: MediaQuery.of(context).size.height / 4.8,
                width: MediaQuery.of(context).size.height / 4.8,
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildEmailRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            id = value;
          });
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.perm_identity_sharp,
              color: mainColor,
            ),
            labelText: 'User ID'),
      ),
    );
  }

  Widget _buildPasswordRow() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        keyboardType: TextInputType.text,
        obscureText: true,
        onChanged: (value) {
          setState(() {
            password = value;
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock_outlined,
            color: mainColor,
          ),
          labelText: 'Password',
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 1.4 * (MediaQuery.of(context).size.height / 20),
          width: 5 * (MediaQuery.of(context).size.width / 10),
          margin: EdgeInsets.only(bottom: 20),
          child: MaterialButton(
            elevation: 5.0,
            color: mainColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              //print("login called");
              await checkLogin();
            },
            child: Text(
              "Login",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: MediaQuery.of(context).size.height / 40,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.blueGrey[300]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Login Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height / 30,
                      ),
                    ),
                  ],
                ),
                _buildEmailRow(),
                _buildPasswordRow(),
                _buildLoginButton(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'Handcrafted by',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            children: const <TextSpan>[
                              TextSpan(
                                  text: '\nS',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xAFC10101),
                                      fontSize: 20)),
                              TextSpan(
                                  text: 'ujeet ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              TextSpan(
                                  text: 'T',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xAFC10101),
                                      fontSize: 20)),
                              TextSpan(
                                  text: 'iwari ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              TextSpan(
                                  text: '& ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: 'L',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xAFC10101),
                                      fontSize: 20)),
                              TextSpan(
                                  text: 'iju ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              TextSpan(
                                  text: 'J',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xAFC10101),
                                      fontSize: 20)),
                              TextSpan(
                                  text: 'ohn',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                        Text(
                          "Version:- 2.8",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future getConnection() async {
    if (connection != null) {
      await connection!.close();
    }
    connection = await mysqlHelper.Connect();
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.transparent,
      content: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.blue,
            backgroundColor: Colors.orange,
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future checkLogin() async {
    try {
      showLoaderDialog(context);
      await getConnection();
      String check = "select status from appinfo where version='2.8'";
      var res = await connection!.query(check);
      var r1 = res.first;
      if (r1[0] == 1) {
        String sql = "select count(*),name from login where id='$id'"
            " and pwd='$password'";
        var result = await connection!.query(sql);
        //print(sql);
        var row = result.first;
        Navigator.pop(context);
        if (row[0] == 1) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MenuPage(
                    connection: connection!,
                    uid: id,
                    uname: row[1],
                  )));
        } else {
          ToastWidget.showToast("Incorrect user ID or password", Colors.red);
        }
      } else if (r1[0] == 0) {
        ToastWidget.showToast("Update app to latest version", Colors.red);
        Navigator.pop(context);
      } else {
        ToastWidget.showToast(
            "Something went wrong. please try after some time", Colors.red);
      }

      //
    } catch (Exception) {
      print(Exception.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.BACKGROUND,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColor.NAVIGATIONBAR,
                        borderRadius: BorderRadius.only(
                          bottomLeft: const Radius.circular(70),
                          bottomRight: const Radius.circular(70),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildLogo(),
                      _buildContainer(),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
