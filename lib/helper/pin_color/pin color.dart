import 'package:flutter/material.dart';

Color getPinColor(Map<String, dynamic> report) {
  // 1st check: disabled_facility
  if (report['disabled_facility'] == true) {
    return Colors.orange; // Disabled Parking
  }

  // 2nd check: electric_charging
  if (report['electric_charging'] == true) {
    return Colors.green; // Electric Charging
  }

  // 3rd check: paid or free
  final cost = report['parking_cost'];
  final isPaid = cost != null && cost != 0 && cost != '0' && cost != '';

  if (isPaid) {
    return Colors.blue; // Paid Parking
  }

  return Colors.white; // Free Parking
}