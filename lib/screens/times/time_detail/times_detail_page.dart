import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import '../../../resources/utils/AppUtils.dart';
import '../../../resources/utils/EmployeesService.dart' as employeesService;

import '../utils/TimeModel.dart';

const appName = 'DateTimeField Example';

class InsertTimePage extends StatefulWidget {
  InsertTimePage({Key key, this.time}) : super(key: key);

  final TimeModel time;

  @override
  _InsertTimePageState createState() => _InsertTimePageState(time);
}

class _InsertTimePageState extends State<InsertTimePage> {
  final TimeModel time;
  final DateFormat formatDate = DateFormat("yyyy-MM-dd");
  final DateFormat formatHour = DateFormat("HH:mm");
  final formKey = GlobalKey<FormState>();

  final TextEditingController dateControler = TextEditingController();
  final TextEditingController initHourController = TextEditingController();
  final TextEditingController endHourController = TextEditingController();

  _InsertTimePageState(this.time);

  bool _isInserting() {
    return this.time == null;
  }

  @override
  void initState() {
    if (!_isInserting()) {
      this.dateControler.text =
          this.time.initDate == null ? "" : formatDate.format(DateTime.fromMillisecondsSinceEpoch(this.time.initDate));
      this.initHourController.text =
          this.time.initDate == null ? "" : formatHour.format(DateTime.fromMillisecondsSinceEpoch(this.time.initDate));
      this.endHourController.text =
          this.time.endDate == null ? "" : formatHour.format(DateTime.fromMillisecondsSinceEpoch(this.time.endDate));
    } else {
      this.dateControler.text = formatDate.format(DateTime.now()); // Load default date
    }
    super.initState();
  }

  @override
  void dispose() {
    dateControler.dispose();
    initHourController.dispose();
    endHourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Insertar tiempo")),
        body: ListView(
          padding: EdgeInsets.all(15),
          children: <Widget>[
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _getDateField("Fecha", this.dateControler),
                  SizedBox(height: 24),
                  _getHourField("Hora inicio", this.initHourController),
                  SizedBox(height: 24),
                  _getHourField("Hora fin", this.endHourController),
                  SizedBox(height: 24),
                  _getInsertButton(),
                ],
              ),
            )
          ],
        ));
  }

  Widget _getInsertButton() {
    String text = "ACTUALIZAR";
    Color color = Colors.orange;
    if (_isInserting()) {
      color = Colors.green;
      text = "INSERTAR";
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        RaisedButton(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          color: color,
          onPressed: _buttonAction,
        )
      ],
    );
  }

  Future _buttonAction() async {
    DateTime date = this.convertToDate(this.dateControler.text, this.formatDate);
    DateTime initHour = this.convertToDate(this.initHourController.text, this.formatHour);
    DateTime endHour = this.convertToDate(this.endHourController.text, this.formatHour);
    DateTime initDate =
        initHour == null ? null : new DateTime(date.year, date.month, date.day, initHour.hour, initHour.minute);
    DateTime endDate =
        endHour == null ? null : new DateTime(date.year, date.month, date.day, endHour.hour, endHour.minute);

    Map<String, dynamic> response;
    if (_isInserting()) {
      response = await employeesService.insertTime(initDate, endDate);
      if (this._checkResult(response)) {
        this.initHourController.text = "";
        this.endHourController.text = "";
      }
    } else {
      response = await employeesService.updateTime(this.time.presenceControlHoursId, initDate, endDate);
      if (this._checkResult(response)) {
        Navigator.pop(context); // Volvemos a la pantalla anterior
      }
    }
  }

  bool _checkResult(Map<String, dynamic> response) {
    if (response == null || response['code'] != 0) {
      String message = "No se ha podido realizar la acción";
      if (response != null && response['message'] != null) {
        message = response['message'];
      }
      showMessage(context, message);
      return false;
    }
    return true;
  }

  Widget _getDateField(String labelText, TextEditingController controller) {
    return Column(children: <Widget>[
      Column(
        children: <Widget>[
          DateTimeField(
            keyboardType: TextInputType.datetime,
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              icon: Icon(Icons.calendar_today),
            ),
            format: this.formatDate,
            onShowPicker: (context, currentValue) {
              return showDatePicker(
                  context: context,
                  locale: const Locale('es', 'ES'),
                  firstDate: DateTime(1900),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100));
            },
          ),
        ],
      ),
    ]);
  }

  Widget _getHourField(String labelText, TextEditingController controller) {
    return Column(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              child: DateTimeField(
                keyboardType: TextInputType.datetime,
                enableInteractiveSelection: false,
                controller: controller,
                decoration: InputDecoration(
                  labelText: labelText,
                  icon: Icon(Icons.timer),
                ),
                format: this.formatHour,
                onShowPicker: (context, currentValue) async {
                  final time = await _showTimePicker(currentValue);
                  return DateTimeField.convert(time);
                },
              ),
            )
          ],
        ),
      ],
    );
  }

  Future<TimeOfDay> _showTimePicker(DateTime currentValue) async {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child),
    );
  }

  DateTime convertToDate(String text, DateFormat format) {
    try {
      var d = format.parseStrict(text);
      return d;
    } catch (e) {
      return null;
    }
  }
}
