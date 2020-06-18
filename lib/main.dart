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
      create: (_) => UserModel()..checkUserSignIn(),
      child: Consumer<UserModel>(
        builder: (_, model, __) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: model.user != null ? BottomTabNavigator() : Auth(),
          );
        },
      ),
    );
  }
}
