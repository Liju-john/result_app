
import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:http/http.dart' as http;


const String enckey="ABCDF123456789532152145632ADBSA1";
const String enciv="ABC123AFABC123AF";
Future<void> EncDec(String data)
async {
  // final plainText = data;
  // //final key = Key.fromSecureRandom(32);
  // final key=Key.fromUtf8("ABCDF123456789532152145632ADBSA1");
  // //final iv = IV.fromSecureRandom(16);
  // final iv =IV.fromUtf8("ABC123AFABC123AF");
  // final encrypter = Encrypter(AES(key,mode: AESMode.cbc));
  //
  // final encrypted = encrypter.encrypt(plainText, iv: iv);
  // //final decrypted = encrypter.decrypt(encrypted, iv: iv);
  //
  // //print(decrypted);
  // //print(encrypted.bytes);
  // //print(encrypted.base16);
  // //print(encrypted);
  // //print('data sent');
  //data=encrypt(data);
  //print(decrypt(data));
  var postData={"data":data};
  var url=Uri.parse('https://kpsinfosys.in/app/kpshome/enc.php');
  var response=await http.post(url,body: postData);
  //print(postData);
  if(response.statusCode==200)
  {
    print(response.body);
    print(decrypt(response.body));
  }
}

String encrypt(String data) {
  final plainText = data;
  //final key = Key.fromSecureRandom(32);
  final key=Key.fromUtf8(enckey);
  //final iv = IV.fromSecureRandom(16);
  final iv =IV.fromUtf8(enciv);
  final encrypter = Encrypter(AES(key,mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  return encrypted.base64;
}
String decrypt(String data) {
  final plainText = data;
  //final key = Key.fromSecureRandom(32);
  final key=Key.fromUtf8(enckey);
  //final iv = IV.fromSecureRandom(16);
  final iv =IV.fromUtf8(enciv);
  final encrypter = Encrypter(AES(key,mode: AESMode.cbc));
  //final encrypted = encrypter.encrypt(plainText, iv: iv);
  final decrypted = encrypter.decrypt64(plainText, iv: iv);
  return decrypted;
}







