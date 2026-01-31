import 'package:flutter/material.dart';

import 'core/router/routes.dart';
import 'helper/responsive_helper/responsive_helper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const App());
}


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),

      routerConfig: AppRouter.router,

      /// ✅ INIT RESPONSIVE HELPER HERE
      builder: (context, child) {
        ResponsiveHelper.init(context);
        return child!;
      },
    );
  }
}

/*class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),

      routerConfig: AppRouter.router, // ✅ connect GoRouter
    );
  }
}*/

