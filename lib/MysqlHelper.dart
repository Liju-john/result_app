import 'package:mysql1/mysql1.dart';

class MysqlHelper
{
  Future Connect() async{
    final  MySqlConnection connection = await MySqlConnection.connect(ConnectionSettings(
        host: '59.94.37.73', port: 3306, user: 'remote', db: 'kpsbspin_master',
        password: 'result123#'));
    return connection;
  }
}