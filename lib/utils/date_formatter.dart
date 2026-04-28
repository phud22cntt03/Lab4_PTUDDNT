import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String dayLabel(DateTime dateTime) {
    return DateFormat('EEE, MMM d').format(dateTime);
  }

  static String fullDate(DateTime dateTime) {
    return DateFormat('EEEE, MMM d').format(dateTime);
  }

  static String hourLabel(DateTime dateTime, {required bool use24HourFormat}) {
    return use24HourFormat
        ? DateFormat('HH:mm').format(dateTime)
        : DateFormat('h a').format(dateTime);
  }

  static String timeLabel(DateTime dateTime, {required bool use24HourFormat}) {
    return use24HourFormat
        ? DateFormat('HH:mm').format(dateTime)
        : DateFormat('h:mm a').format(dateTime);
  }

  static String lastUpdated(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Never';
    }
    return DateFormat('MMM d, HH:mm').format(dateTime);
  }
}
