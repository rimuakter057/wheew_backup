import 'package:flutter/material.dart';
import 'core/app/app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize any services, dependencies, DB, etc.
  //await initDependencies();

  runApp(const App());
}

