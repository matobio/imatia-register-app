import 'package:elastic_hours/screens/home_page.dart';
import 'package:elastic_hours/screens/ring.dart';
import 'package:flutter/material.dart';
import 'package:elastic_hours/resources/utils/LocalStorageUtils.dart';
import 'package:elastic_hours/resources/oauth/aad_oauth.dart';
import 'package:elastic_hours/resources/oauth/microsoft-oauth_config.dart';
import 'package:elastic_hours/resources/utils/EmployeeDataGetter.dart';
import 'AppUtils.dart';

final AadOAuth oauth = new AadOAuth(config);

Future<bool> login(BuildContext context) async {
  try {
    Navigator.push( context, MaterialPageRoute(builder: (context) => SpinKitRing(color: Colors.white,)), );
    
    // final AadOAuth oauth = new AadOAuth(config);
    String accessToken = await oauth.getAccessToken();
    if(accessToken != null){
      await loginEmployee(accessToken);
      int employeeId = await getEmployeeIdFromUserMail(accessToken);

      if(employeeId != null){
        await saveToken(accessToken);
        await saveEmployeeId(employeeId);
        return true;
      }
    }
  } catch (e) {
    showError(context,e);
  }
  return false;
}

void logout(BuildContext context) async {
  // final AadOAuth oauth = new AadOAuth(config);
  await oauth.logout();
  cleanStorage();
  Navigator.push( context, MaterialPageRoute(builder: (context) => MyHomePage()), );
  showMessage(context, "Logged out");
}

Future<bool> checkLogin() async {

  
  await oauth.loadTokenToCache();
  if(oauth.tokenIsValid()){
    return true;
  }
  return false;
}