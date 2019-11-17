import 'package:intl/intl.dart';

class TimeModel {
   int presenceControlHoursId;
   int initDate;
   int endDate;
   String hours;

  TimeModel(presenceControlHoursId, initDate,endDate,hours){
    this.presenceControlHoursId = presenceControlHoursId;
    this.initDate = initDate;
    this.endDate = endDate;
    this.hours = hours;
  }

  String getDate(){
    if(this.initDate == null){
      return "";
    }
    return DateFormat('yyyy/MM/dd').format(DateTime.fromMillisecondsSinceEpoch(this.initDate));
  }

  String getInitDate(){
    if(this.initDate == null){
      return "";
    }
    return DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(this.initDate));
  }

  String getEndDate(){
    if(this.endDate == null){
      return "";
    }
    return DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(this.endDate));
  }

  String getHours(){
    if(this.endDate == null){
      return "";
    }
    return this.hours;
  }
}