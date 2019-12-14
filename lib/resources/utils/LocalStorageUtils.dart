import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> saveToken(String accessToken) async {
  final storage = new FlutterSecureStorage();
  await storage.write(key: "accessToken", value: accessToken);
}

Future<String> getToken() async {
  final storage = new FlutterSecureStorage();
  return await storage.read(key: "accessToken");
}

Future<void> saveEmployeeId(int employeeId) async {
  final storage = new FlutterSecureStorage();
  await storage.write(key: "employee_id", value: employeeId.toString());
}

Future<int> getEmployeeId() async {
  final storage = new FlutterSecureStorage();
  String employeeId = await storage.read(key: "employee_id");

  if(employeeId == null){
    return null;
  }
  return int.parse(employeeId);
}

void cleanStorage(){
  final storage = new FlutterSecureStorage();
  storage.deleteAll();
}