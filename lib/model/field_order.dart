import 'package:sport_booking_project/model/sport_field.dart';
import 'package:sport_booking_project/model/user.dart';

class FieldOrder {
  SportField field;
  User user;
  String selectedDate;
  List<String> selectedTime;
  bool paidStatus;

  FieldOrder(
      {required this.field,
      required this.user,
      required this.selectedDate,
      required this.selectedTime,
      this.paidStatus = false});
}
