import 'package:flutter/material.dart';
import 'package:elastic_hours/resources/utils/EmployeeDataGetter.dart';
import '../drawer.dart';
import 'TimeModel.dart';
import 'times_detail_page.dart';

class TimesPage extends StatefulWidget {
  TimesPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TimesPageState createState() => _TimesPageState();
}

class _TimesPageState extends State<TimesPage> {

  int offset = 0;
  int pagesize = 20;
  final _biggerFont = const TextStyle(fontSize: 18.0);
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;
  List<TimeModel> listOfTimes = new List();

  Future<List<TimeModel>> _queryTimes()  async {
      
    Map<String,dynamic> data = await getEmployeeTimes(this.offset, this.pagesize);

    List<TimeModel> times = new List();
    List<dynamic> list = data['data']['presence_control_hours_id'];
    for( var i = 0 ; i < list.length; i++ ) { 
      times.add(TimeModel( data['data']['presence_control_hours_id'][i], data['data']['init_date'][i], data['data']['end_date'][i], data['data']['hours'][i] ));
    } 
    return times;
  }

  Future<void> _refreshTimes() async{
    this.offset = 0;
    this.listOfTimes = new List();
    this._getMoreData();
  }

  void _getMoreData() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      List<TimeModel>  times = await _queryTimes();
      this.offset = this.offset + this.pagesize;

      setState(() {
        isLoading = false;
        listOfTimes.addAll(times);
      });
    }
  }

  @override
  void initState() {
    this._getMoreData();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==  _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshTimes,
        child: Container(
          child: _buildList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetailTimePage(null);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void navigateToDetailTimePage(TimeModel time){
    Navigator.push( context, MaterialPageRoute(builder: (context) => InsertTimePage(time: time)), );
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: listOfTimes.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == listOfTimes.length) {
          return _buildProgressIndicator();
        } else {
          return _buildRow(listOfTimes[index], index);
        }
      },
      controller: _scrollController,
    );
  }

  Future<bool> _deleteTime(int presenceControlHoursId, int index) async{
    
     bool res = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar"),
          content: const Text("Se va a eliminar la entrada de tiempo. ¿Desear continuar?"),
          actions: <Widget>[
            FlatButton(
              onPressed: ()  {
                deleteTime(presenceControlHoursId).then((result) {
                  if(result == true){
                    setState(() {
                      listOfTimes.removeAt(index);
                    });
                    Navigator.of(context).pop(true);
                  }
                });
              },
              child: const Text("ACEPTAR")
            ),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCELAR"),
            ),
          ],
        );
      },
    );
    return res;
  }

  Widget _buildRow(TimeModel pair, int index) {
    return Dismissible(
      key: Key(UniqueKey().toString()),
      background: Container(color: Colors.white),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (DismissDirection direction) async {
        return _deleteTime(pair.presenceControlHoursId, index);
      },
      child: 
      InkWell(
        onTap: (){
          navigateToDetailTimePage(pair);
        },
        child: Container(
          child: 
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Center(
                                    child: 
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          pair.getEndDate(),
                                          style: _biggerFont,
                                        ),
                                      )
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child:
                                Row(
                                  children: <Widget>[
                                    Center(
                                    child: 
                                      Padding(
                                        padding: EdgeInsets.only(top: 5),
                                        child: Text(
                                          pair.getInitDate(),
                                          style: _biggerFont,
                                        ),
                                      )
                                    ),
                                  ],
                                ),
                            ),
                          ],
                        ),
                      ), 
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            child: 
                              Padding(
                                padding: EdgeInsets.only(left: 20, right: 30),
                                child: Text(
                                  pair.getDate(),
                                  style: _biggerFont,
                                ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 5,right: 5),
                            child: 
                              Text(
                                pair.getHours(),
                                style: _biggerFont,
                              ),
                            )
                        ],
                      )
                    ],
                  ),
                ],
              ),
              Divider(),
            ],
          )
        ),
      ),
      
    );
  }
  
}


