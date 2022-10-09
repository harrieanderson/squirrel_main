import 'package:flutter/material.dart';
import 'package:squirrel_main/services/auth.dart';
import 'package:squirrel_main/src/screens/login_screen.dart';
import 'package:squirrel_main/src/screens/navigation_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Authenticator().getCurrentUser() != null
          ? NavigationScreen(
              key: UniqueKey(),
            )
          : LoginScreen(),
    );
  }
}
