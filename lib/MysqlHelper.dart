import 'package:mysql1/mysql1.dart';

class MysqlHelper
{
  Future Connect() async{
    final  MySqlConnection connection = await MySqlConnection.connect(ConnectionSettings(
        host: '103.117.180.182', port: 3306, user: 'kpsbspin_result', db: 'kpsbspin_master',password: 'result123#'));
    return connection;
  }
}