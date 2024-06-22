import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:result_app/settings/Settings.dart';
import 'package:result_app/widgets/ToastWidget.dart';
class ProfilePhoto extends StatefulWidget {
  String currentdb = "", nextdb = "";
  double screenheight, screenwidth;
  mysql.MySqlConnection connection;
  String cname, section, branch, tid;
  ProfilePhoto({Key? key,
    required this.currentdb,
    required this.nextdb,
    required this.connection,
    required this.cname,
    required this.section,
    required this.branch,
    required this.screenheight,
    required this.screenwidth,
    required this.tid});

  @override
  State<ProfilePhoto> createState() => _ProfilePhotoState(
      this.currentdb,
      this.nextdb,
      this.connection,
      this.cname,
      this.section,
      this.branch,
      this.screenheight,
      this.screenwidth,
      this.tid
  );
}

class _ProfilePhotoState extends State<ProfilePhoto> {
  String currentdb = "", nextdb = "";
  double screenheight, screenwidth;
  mysql.MySqlConnection connection;
  String cname, section, branch, tid;
  bool loadData=true;
  File ? cameraFile;
  List<Data> data=[];
  double _progressValue=0;
  late ProgressDialog progressDialog;
  _ProfilePhotoState( this.currentdb,
      this.nextdb,
      this.connection,
      this.cname,
      this.section,
      this.branch,
      this.screenheight,
      this.screenwidth,
      this.tid);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    progressDialog = ProgressDialog(context,isDismissible: true);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BACKGROUND,
      appBar: AppBar(
        title: Text('Profile Pictures',style: GoogleFonts.playball(
          fontSize: screenheight / 30,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],),
        ),
        backgroundColor: AppColor.NAVIGATIONBAR,
      ),
      body: this.data.isEmpty?Center(child: CircularProgressIndicator(),):
      ListView.builder(itemCount: this.data.length,
          itemBuilder:(context,position){
        return Card(
          color:data[position].photoExist?Colors.green[200]:Colors.white60,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Text("Sno:- "),
                  Text((position+1).toString(),style: TextStyle(fontWeight: FontWeight.w900)),
                  Text("  Rollno: "),
                  Text(data[position].rollno,style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(width: 10,),
                  Text("Name: "),
            Flexible(
              child: Text(data[position].sname,style: TextStyle(fontWeight: FontWeight.w900),
              ),)
                ],),
                Divider(thickness: 2,),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                  IconButton(onPressed: () async {
                    await _getImage(context,position);
                  }, icon: Icon(Icons.remove_red_eye)),
                  IconButton(onPressed: () async {
                    await _requestCameraPermission(position,"camera");
                  }, icon: Icon(Icons.camera_enhance_rounded)),
                    IconButton(onPressed: () async {
                      await _requestCameraPermission(position,"gallery");
                    }, icon: Icon(Icons.image))
                ],)
              ],
            ),
          )
        );
      }),
    );
  }
  Future<void> _requestCameraPermission(int position,String type) async {
    // Request camera permission
    var status = await Permission.camera.status;
    if (status.isDenied) {
      await Permission.camera.request();
    }
    else if(status.isPermanentlyDenied)
    {
      openAppSettings();
    }
    else if (status.isGranted)
    {
      var image =null;

      if(type=="camera")
        {
          image=await ImagePicker().pickImage(source: ImageSource.camera);
        }
      else if(type=="gallery")
        {
          image=await ImagePicker().pickImage(source: ImageSource.gallery);
        }
      if (image != null) {
        CroppedFile file=await _cropImage(File(image.path)) as CroppedFile;
        //await sendImageToServer(XFile(file.path));
        await uploadImage(position,XFile(file.path));
        //await sendImageToServer(image);
        File(image.path!).delete();
        File(file.path!).delete();
      }
    }
  }
  Future<CroppedFile?> _cropImage(File image) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: AppColor.NAVIGATIONBAR,
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    return croppedFile;
  }
  Future<void> uploadImage(int position,XFile image) async {
    try {
      final dio = Dio();
      await progressDialog.show();
      progressDialog.update(progress: 0.0,
          message: "Uploading started...");
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
        ),
        "rowid":data[position].rowid,
        "type":"pp",
        "doc_name":"Profile Photo","tid":this.tid
      });
      final response = await dio.post(
        'https://kpsinfosys.in/app/media/upload.php',
        data: formData,
        onSendProgress: (int sent, int total) {
          final progress = ((sent / total) * 100).toInt();
          progressDialog.update(progress: progress.toDouble(),
          message: "Uploading...${progress}");
        },
      );
      progressDialog.update(progress: 0.0,
          message: "");
      await progressDialog.hide();
      if(response.data.toString().toLowerCase().contains("uploaded"))
        {
          data[position].photoExist=true;
        }
      setState(() {
      });
      ToastWidget.showToast(response.data+"", Colors.green);
    } catch (e) {
      ToastWidget.showToast(e.toString()+"", Colors.red);
      progressDialog.update(progress: 0,
          message: "Failed");
      await progressDialog.hide();
    }
  }
  Future getData() async{
  try {
    loadData=true;
    List<Data> data=[];
    this.data.clear();
    String query="SELECT n.rowid,n.rollno,n.sname,"
        "ifnull(t.doc_name,0),n.branch FROM `$currentdb`.`nominal` n "
        "left join kpsbspin_master.`document_detail` t "
        "on n.rowid=t.rowid and t.doc_name='Profile photo' "
        "where n.branch='$branch' and "
        "n.cname='$cname' and n.section='$section' and"
        " n.rollno not in('',' ') and n.rollno is not null order by n.rollno;";
    var results = await connection.query(query);
    for (var rows in results)
      {
        data.add(Data(rowid:rows[0].toString() ,
            rollno: rows[1].toString(),
            sname: rows[2].toString(), photoExist: rows[3].toString()!="0"));
      }
    this.data=data;
    setState(() {
    });
    loadData=false;
  } catch (e) {
    print(e);
  } finally {
  }
  }
  Future<void> _getImage(BuildContext context,int position) async {
    try {
      final dio = Dio();
      await progressDialog.show();
      progressDialog.update(progress: 0.0,
          message: "Downloading....");
      final formData = FormData.fromMap({
        "imageName":data[position].rowid.toString()+"_pp.jpg"
      });
      Response response = await dio.post(
        'https://kpsinfosys.in/app/media/getImage.php',
        data: formData,
        options: Options(responseType: ResponseType.bytes,
          followRedirects: false,),
        onReceiveProgress: (int rec,int total)
          {
            if (total != -1) {
              final progress = ((rec / total) * 100).toInt();
              progressDialog.update(progress: progress.toDouble(),
                  message: "Downloading ${progress}%");
            }
          },
      );
      await progressDialog.hide();
      // Show dialog with the image
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Row(children: [
              Text(data[position].rollno,style: TextStyle(color: Colors.white),),
              Expanded(child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(data[position].sname,
                  style: TextStyle(color: Colors.white)),
            ))],),
            content: Image.memory(response.data),
          );
        },
      );
    } catch (error) {
      print('Error loading image: $error');
    }
  }
}
class Data{
 String rowid="",rollno="",sname="";
 bool photoExist=false;
 Data({required this.rowid,required this.rollno,
   required this.sname,required this.photoExist});
}
