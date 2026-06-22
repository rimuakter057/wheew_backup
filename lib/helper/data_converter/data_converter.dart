import 'package:intl/intl.dart';

// Suppose createdAt language looks like: "2026-02-08T14:30:00.000Z"
String formatTime(String createdAt) {
  if (createdAt.isEmpty) return "";

  try {
    final dt = DateTime.parse(createdAt).toLocal(); // local time
    final formatted = DateFormat.jm().format(
      dt,
    ); // 12-hour format, e.g., 2:30 PM
    return formatted;
  } catch (e) {
    return createdAt; // fallback, যদি parse না হয়
  }
}
