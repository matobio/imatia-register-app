import 'package:flutter/material.dart';
import '../resources/utils/AppUtils.dart' as AppUtils;
import '../resources/utils/login/LoginService.dart' as loginService;
import 'counter/counter_page.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    loginService.checkLogin().then((result) {
      if (result == true) {
        _navigateToFirstPage();
      } else {
        loginService.login(context).then((result) {
          if (result) {
            _navigateToFirstPage();
          }
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              "Login with Microsoft",
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          ListTile(
            leading: Icon(Icons.launch),
            title: Text('Login'),
            onTap: _login,
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  void _navigateToFirstPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CounterPage(title: "Contador")),
    );
  }

  void _login() async {
    if (await loginService.login(context)) {
      _navigateToFirstPage();
    } else {
      AppUtils.showMessage(context, "No se ha podido iniciar sessión");
    }
  }

  void _logout() async {
    loginService.logout(context);
  }
}
