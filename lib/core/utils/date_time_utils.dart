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

String formatToArabic(String dateString) {
  final DateTime parsedDate = DateFormat('EEEE, MMMM d, y', 'en').parse(dateString);

  return DateFormat('EEEE، d MMMM، y', 'ar').format(parsedDate);
}

String formatToEnglish(String dateString) {
  final DateTime parsedDate = DateFormat('EEEE, MMMM d, y', 'en').parse(dateString);

  return DateFormat('EEEE، d MMMM، y', 'en').format(parsedDate);
}