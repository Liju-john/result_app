import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:result_app/settings/Settings.dart';
class ViewDocs extends StatefulWidget {
  double screenheight;
  String rowid,sname,doc_name;
  ViewDocs({Key ? key,required this.screenheight, required this.rowid,
    required this.doc_name,required this.sname});

  @override
  State<ViewDocs> createState() => _ViewDocsState(this.screenheight,this.rowid,
      this.doc_name,this.sname);
}

class _ViewDocsState extends State<ViewDocs> {
  String _localPath="",_fileName="";
  String rowid,sname,doc_name;
  bool loading=true;
  double screenheight;
  @override
  void initState() {
    super.initState();
    _initFile();
  }
  _ViewDocsState(this.screenheight,this.rowid,this.doc_name,this.sname);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(this.sname,style: GoogleFonts.ptSerif(
              fontSize: screenheight / 40,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],),
            ),
            Text(this.doc_name,style: GoogleFonts.oswald(
              fontSize: screenheight / 50,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],),
            ),
          ],
        ),
        backgroundColor: AppColor.NAVIGATIONBAR,
      ),
      body: loading?Center(child: CircularProgressIndicator(),):PDFView(
        filePath: _localPath,
        // Replace with the actual URL of your PHP endpoint serving the PDF file
      ),
    );
  }
  Future<void> _initFile() async {
    loading=true;
    setState(() {
    });
    final directory = await getApplicationDocumentsDirectory();
    final fileName = "temp.pdf";
    final localPath = '${directory.path}/$fileName';
    var postData={"rowid":this.rowid,"doc_name":this.doc_name};
    print(postData);
    var url = Uri.parse('$serverAdd/result/viewDocumentPDF.php');
    var response = await http.post(url, body: postData);
    if (response.statusCode == 200) {
      final file = File(localPath);
      await file.writeAsBytes(response.bodyBytes,flush: true);
    }
    loading=false;
    setState(() {
      _localPath = localPath;
    });
    print(_localPath);
  }
}
