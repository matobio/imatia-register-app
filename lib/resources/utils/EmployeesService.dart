import 'dart:convert';
import 'package:http/http.dart';
import 'Constants.dart';
import 'models/DayHours.dart';
import 'models/MonthlyHours.dart';
import 'LocalStorageUtils.dart';

String _mapToQueryParams(Map<String, String> params) {
  final queryParams = <String>[];
  params.forEach((String key, String value) => queryParams.add("$key=$value"));
  return queryParams.join("&");
}

Future<void> loginEmployee(String accessToken) async {
  String urlParams = _mapToQueryParams({"user": accessToken, "pass": "pass"});

  Response response = await get("$SERVER_REST_URL$REST_SERVICE_PATH_LOGIN_EMPLOYEE?$urlParams",
      headers: {"Content-Type": "application/json"});

  return json.decode(response.body);
}

Future<int> getEmployeeIdFromUserMail(String accessToken) async {
  Response response = await post("$SERVER_REST_URL$REST_SERVICE_PATH_GET_EMPLOYEE_ID_FROM_THE_USER_MAIL",
      body: json.encode({"token": accessToken}), headers: {"Content-Type": "application/json"});

  if (response.statusCode != 200) {
    return null;
  }
  return int.parse(response.body);
}

Future<Map<String, dynamic>> getEmployeeLastTime() async {
  return await getEmployeeTimes(0, 1);
}

Future<Map<String, dynamic>> getEmployeeTimes(int offset, int pageSize) async {
  int employeeId = await getEmployeeId();
  String accessToken = await getToken();
  if (employeeId == null || accessToken == null) {
    return null;
  }

  Map<String, dynamic> params = {
    "entity": ENTITY_EMPLOYEE_PRESENCE_CONTROL_HOURS,
    "kv": {"IdEmpleado": employeeId, "employee_id": employeeId, "token": accessToken},
    "av": [],
    "offset": offset,
    "pageSize": pageSize,
    "orderBy": []
  };

  Response response = await post("$SERVER_REST_URL/advancedquery",
      body: json.encode(params), headers: {"Content-Type": "application/json"});

  if (response.statusCode != 200) {
    return null;
  }
  Map<String, dynamic> data = json.decode(response.body);
  return data;
}

Future<Map<String, dynamic>> getMonthlyTimes(int offset, int pageSize) async {
  int employeeId = await getEmployeeId();
  String accessToken = await getToken();

  Map<String, dynamic> params = {
    "entity": ENTITY_EMPLOYEE_PRESENCE_CONTROL_MONTH_HOURS,
    "kv": {"employee_id": employeeId, "token": accessToken},
    "av": [],
    "offset": offset,
    "pageSize": pageSize,
    "orderBy": []
  };

  Response response = await post("$SERVER_REST_URL/advancedquery",
      body: json.encode(params), headers: {"Content-Type": "application/json"});

  Map<String, dynamic> data = json.decode(response.body);
  if (response.statusCode != 200) {
    return null;
  }
  return data;
}

Future<bool> deleteTime(int presenceControlHoursId) async {
  String accessToken = await getToken();

  Map<String, dynamic> params = {
    "entity": ENTITY_EMPLOYEE_PRESENCE_CONTROL_HOURS,
    "kv": {"presence_control_hours_id": presenceControlHoursId, "token": accessToken},
  };

  Response response =
      await post("$SERVER_REST_URL/delete", body: json.encode(params), headers: {"Content-Type": "application/json"});

  Map<String, dynamic> data = json.decode(response.body);

  return response.statusCode == 200 && data['code'] == 0;
}

Future<Map<String, dynamic>> insertTime(DateTime initDate, DateTime endDate) async {
  String accessToken = await getToken();
  int employeeId = await getEmployeeId();

  Map<String, dynamic> params = {
    "employeeId": employeeId,
    "initDate": initDate.millisecondsSinceEpoch,
    "endDate": endDate.millisecondsSinceEpoch,
    "token": accessToken
  };

  Response response = await post("$SERVER_REST_URL$REST_SERVICE_PATH_INSERT_CONTROL_HOURS",
      body: json.encode(params), headers: {"Content-Type": "application/json"});

  if (response.statusCode != 200) {
    return null;
  }
  return json.decode(response.body);
}

Future<Map<String, dynamic>> updateTime(int presenceControlHoursId, DateTime initDate, DateTime endDate) async {
  String accessToken = await getToken();

  Map<String, dynamic> av = new Map();
  if (initDate != null) {
    av.putIfAbsent("init_date", () => initDate.millisecondsSinceEpoch);
  }
  if (endDate != null) {
    av.putIfAbsent("end_date", () => endDate.millisecondsSinceEpoch);
  }

  Map<String, dynamic> params = {
    "entity": ENTITY_EMPLOYEE_PRESENCE_CONTROL_HOURS,
    "kv": {"presence_control_hours_id": presenceControlHoursId, "token": accessToken},
    "av": av,
    "sqltypes": {"presence_control_hours_id": 4, "init_date": 93, "end_date": 93}
  };

  Response response =
      await post("$SERVER_REST_URL/update", body: json.encode(params), headers: {"Content-Type": "application/json"});

  if (response.statusCode != 200) {
    return null;
  }
  return json.decode(response.body);
}

Future<bool> startTiming() async {
  int employeeId = await getEmployeeId();
  String accessToken = await getToken();

  Map<String, dynamic> params = {"employeeId": employeeId, "token": accessToken};

  Response response = await post("$SERVER_REST_URL$REST_SERVICE_PATH_START_TIMING",
      body: json.encode(params), headers: {"Content-Type": "application/json"});

  return response.statusCode == 200 && json.decode(response.body)['code'] == 0;
}

Future<bool> stopTiming() async {
  int employeeId = await getEmployeeId();
  String accessToken = await getToken();

  Map<String, dynamic> params = {"employeeId": employeeId, "token": accessToken};

  Response response = await post("$SERVER_REST_URL$REST_SERVICE_PATH_STOP_TIMING",
      body: json.encode(params), headers: {"Content-Type": "application/json"});

  return response.statusCode == 200 && json.decode(response.body)['code'] == 0;
}

Future<Map<String, dynamic>> getEmployeeTimesBetween(DateTime initDate, DateTime endDate) async {
  int employeeId = await getEmployeeId();
  String accessToken = await getToken();

  Map<String, dynamic> params = {
    "entity": ENTITY_EMPLOYEE_PRESENCE_CONTROL_HOURS,
    "kv": {
      "IdEmpleado": employeeId,
      "employee_id": employeeId,
      "token": accessToken,
      "@basic_expression": {
        "lop": {"lop": "init_date", "op": ">=", "rop": initDate.millisecondsSinceEpoch},
        "op": "AND",
        "rop": {
          "lop": {"lop": "end_date", "op": "<=", "rop": endDate.millisecondsSinceEpoch},
          "op": "OR",
          "rop": {"lop": "end_date", "op": "IS NULL", "rop": null}
        }
      }
    },
    "sqltypes": {"init_date": 93, "end_date": 93}
  };

  Response response =
      await post("$SERVER_REST_URL/query", body: json.encode(params), headers: {"Content-Type": "application/json"});

  if (response.statusCode != 200) {
    return null;
  }
  return json.decode(response.body);
}

Future<List<DayHours>> getEmployeeTimesMapped(DateTime initDate, DateTime endDate) async {
  List<DayHours> result = new List();

  Map<String, dynamic> data = await getEmployeeTimesBetween(initDate, endDate);
  if (data != null && data["code"] == 0) {
    List<dynamic> list = data['data']['presence_control_hours_id'];
    list = list == null ? new List() : list;
    for (var i = 0; i < list.length; i++) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(data['data']['init_date'][i]);

      // Se hace esta comprobacion por si pudiera venir una hora sin fecha fin
      if (date.millisecondsSinceEpoch >= initDate.millisecondsSinceEpoch &&
          date.millisecondsSinceEpoch <= endDate.millisecondsSinceEpoch) {
        if (result.where((e) => e.weekday == date.weekday).length == 0) {
          String hoursOfDayString = data['data']['hours_day'][i];
          int hours = int.parse(hoursOfDayString.split("h")[0].trim());
          int minutes = int.parse(hoursOfDayString.split("h")[1].replaceAll("min", "").trim());

          double totalHours = hours + minutes / 60.0;
          if (totalHours >= 0) {
            result.add(DayHours(date.weekday, num.parse(totalHours.toStringAsFixed(2))));
          }
        }
      }
    }
  }

  // Rellenamos
  for (var i = DateTime.monday; i <= DateTime.friday; i++) {
    if (result.where((e) => e.weekday == i).length == 0) {
      result.add(DayHours(i, 0));
    }
  }

  result.sort((a, b) => a.weekday.compareTo(b.weekday));

  return result;
}

Future<List<MonthlyHours>> getEmployeeMonthlyTimes(int offset, int pagesize) async {
  Map<String, dynamic> data = await getMonthlyTimes(offset, pagesize);

  List<MonthlyHours> times = new List();
  List<dynamic> list = data['data']['month_numeric'];
  list = list == null ? new List() : list;
  for (var i = 0; i < list.length; i++) {
    times.add(MonthlyHours(data['data']['year'][i], data['data']['month_numeric'][i], data['data']['labor_hours'][i],
        data['data']['hours'][i]));
  }
  return times;
}

Future<List<MonthlyHours>> getEmployeeAnnualTimesMapped(int year) async {
  List<MonthlyHours> result = new List();

  List<MonthlyHours> data = await getEmployeeMonthlyTimes(0, 999999);

  for (var i = 0; i < data.length; i++) {
    if (data[i].year == year) {
      result.add(data[i]);
    }
  }

  return result;
}
