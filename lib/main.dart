import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:takutore/presentation/version_update/version_update_page.dart';
import 'package:timeago/timeago.dart';
import 'presentation/auth/auth_page.dart';
import 'bottom_tab_navigator.dart';
import 'presentation/common/loading.dart';
import 'user_model.dart';
import 'main_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      builder: (context, widget) {
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
          home: ChangeNotifierProvider<MainModel>(
            create: (_) => MainModel()..checkVersion(),
            builder: (context, widget) {
              return !context.watch<MainModel>().isRequiredUpdate
                  ? Stack(
                      children: <Widget>[
                        context.watch<UserModel>().user != null
                            ? BottomTabNavigator()
                            : Auth(),
                        Loading(context.watch<UserModel>().isLoading),
                      ],
                    )
                  : VersionUpdate(); // page to prompt update.
            },
          ),
        );
      },
    );
  }
}
