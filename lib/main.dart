import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart';
import 'presentation/auth/auth_page.dart';
import 'bottom_tab_navigator.dart';
import 'presentation/common/loading.dart';
import 'user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setLocaleMessages('ja', JaMessages());
  await DotEnv().load('.env');

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
                color: Colors.white,
                elevation: 0.5,
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
            home: Stack(
              children: <Widget>[
                model.user != null ? BottomTabNavigator() : Auth(),
                Loading(model.isLoading),
              ],
            ),
          );
        },
      ),
    );
  }
}
