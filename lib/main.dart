import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './auth/auth_page.dart';
import './bottom_tab_navigator.dart';
import 'user_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel>(
      create: (_) => UserModel()
        ..checkUserSignIn()
        ..confirmNotification(),
      child: Consumer<UserModel>(
        builder: (_, model, __) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primaryColor: Colors.red,
              appBarTheme: AppBarTheme(
                brightness: Brightness.light,
                color: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0.0,
                iconTheme: IconThemeData(
                  color: Colors.red,
                ),
                textTheme: TextTheme(
                  headline6: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              primarySwatch: Colors.red,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: model.user != null ? BottomTabNavigator() : Auth(),
          );
        },
      ),
    );
  }
}
