import 'package:flutter/material.dart';
import '../router/routes.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'My App',

      routerConfig: AppRouter.router, // ✅ connect GoRouter
    );
  }
}
