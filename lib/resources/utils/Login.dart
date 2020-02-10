import 'package:flutter/material.dart';
import '../../screens/home_page.dart';
import '../../screens/ring.dart';
import '../../resources/utils/LocalStorageUtils.dart';
import '../../resources/oauth/aad_oauth.dart';
import '../../resources/oauth/microsoft-oauth_config.dart';
import '../../resources/utils/EmployeeDataGetter.dart';
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
  
  await oauth.logout();
  cleanStorage();
  Navigator.push( context, MaterialPageRoute(builder: (context) => MyHomePage()), );
  showMessage(context, "Logged out");
}

Future<bool> checkLogin() async {

  
  // await oauth.loadTokenToCache();
  // if(oauth.tokenIsValid()){
  //   return true;
  // }
  // return false;
  
  /* Hago un query cualquiera para saber si estamos logueados*/

  Map<String,dynamic> result = await getEmployeeTimes(0, 1);

  if(result == null || result['code'] != 0){
    return false;
  }
  if(result['code'] == 0){
    return true;
  }
  return false;
}