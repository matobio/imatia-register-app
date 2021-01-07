import 'package:flutter/material.dart';
import '../../../screens/ring.dart';
import '../../oauth/aad_oauth.dart';
import '../../oauth/microsoft-oauth_config.dart';
import '../LocalStorageUtils.dart';
import '../EmployeesService.dart' as employeesService;
import '../AppUtils.dart' as AppUtils;
import '../NavigatorUtils.dart' as navigator;

final AadOAuth oauth = new AadOAuth(config);

Future<bool> login(BuildContext context) async {
  try {
    navigator.goTo(
        context,
        SpinKitRing(
          color: Colors.white,
        ));

    // final AadOAuth oauth = new AadOAuth(config);
    String accessToken = await oauth.getAccessToken();
    if (accessToken != null) {
      await employeesService.loginEmployee(accessToken);
      int employeeId = await employeesService.getEmployeeIdFromUserMail(accessToken);

      if (employeeId != null) {
        await saveToken(accessToken);
        await saveEmployeeId(employeeId);
        return true;
      }
    }
  } catch (e) {
    AppUtils.showError(context, e);
  }
  return false;
}

void logout(BuildContext context) async {
  await oauth.logout();
  cleanStorage();
  navigator.goToHomePage(context);
  AppUtils.showMessage(context, "Logged out");
}

Future<bool> checkLogin() async {
  // await oauth.loadTokenToCache();
  // if(oauth.tokenIsValid()){
  //   return true;
  // }
  // return false;

  /* Hago un query cualquiera para saber si estamos logueados*/

  Map<String, dynamic> result = await employeesService.getEmployeeTimes(0, 1);

  if (result == null || result['code'] != 0) {
    return false;
  }
  if (result['code'] == 0) {
    return true;
  }
  return false;
}

void autoLogin(BuildContext context) {
  checkLogin().then((result) {
    if (result == true) {
      navigator.goToCounterPage(context);
    } else {
      login(context).then((result) {
        if (result) {
          navigator.goToCounterPage(context);
        }
      });
    }
  });
}
