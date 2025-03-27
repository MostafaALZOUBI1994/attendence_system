import 'package:intl/intl.dart';

String formatTime(DateTime dateTime) {
  return DateFormat('hh:mm a').format(dateTime);
}

String formatDate(DateTime dateTime) {
  return DateFormat('MMMM d, yyyy').format(dateTime);
}

String formatDay(DateTime dateTime) {
  return DateFormat('EEEE').format(dateTime);
}