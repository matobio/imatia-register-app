import 'package:elastic_hours/screens/weekly/weekly_page.dart';
import 'package:flutter/material.dart';
import 'package:elastic_hours/resources/utils/Login.dart';
import '../resources/oauth/aad_oauth.dart';
import '../resources/oauth/microsoft-oauth_config.dart';
import 'counter/counter_page.dart';
import 'monthly/monthly_page.dart';
import 'times/times_page.dart';



class AppDrawer extends StatefulWidget {
  

  @override
  _AppDrawerState createState() => _AppDrawerState();
}


class _AppDrawerState extends State<AppDrawer> {

  final AadOAuth oauth = new AadOAuth(config);
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
          child: Column(
               children: <Widget>[
                Expanded(
                  child:  ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      _createHeader(),
                      _createDrawerItem(
                          icon: Icons.timer,
                          text: 'Contador',
                          onTap: () => Navigator.push( context, MaterialPageRoute(builder: (context) => CounterPage(title: "Contador")), )
                        ),
                      _createDrawerItem(
                          icon: Icons.access_time,
                          text: 'Tiempos',
                          onTap: () => Navigator.push( context, MaterialPageRoute(builder: (context) => TimesPage(title: "Tiempos")), )
                      ),
                      _createDrawerItem(
                          icon: Icons.calendar_today,
                          text: 'Mensual',
                          onTap: () => Navigator.push( context, MaterialPageRoute(builder: (context) => MonthlyPage(title: "Mensual")), )
                      ),
                      _createDrawerItem(
                          icon: Icons.view_week,
                          text: 'Semanal',
                          onTap: () => Navigator.push( context, MaterialPageRoute(builder: (context) => WeeklyPage(title: "Semanal")), )
                      ),
                    ]
                  )
                ),
                Container(
                  alignment: FractionalOffset.bottomCenter,
                  child: Column(
                      children: <Widget>[
                        Divider(),
                        ListTile(
                          title: Row(
                            children: <Widget>[
                              Icon(Icons.exit_to_app),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text('Salir'),
                              )
                            ],
                          ),
                          onTap: (){
                            logout(context);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
      );
  }
}


Widget _createHeader() {
  return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
          // color: Colors.lime,
          image: DecorationImage(
              fit: BoxFit.fill,
              image:  AssetImage('lib/resources/images/wallpaper-material-design-2.jpg'))),
      child: Stack(children: <Widget>[
        Positioned(
            bottom: 12.0,
            left: 16.0,
            child: Text("",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500))),
      ]));
}

Widget _createDrawerItem(
    {IconData icon, String text, GestureTapCallback onTap}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Icon(icon),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(text),
        )
      ],
    ),
    onTap: onTap,
  );
}