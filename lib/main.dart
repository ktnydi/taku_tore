import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:takutore/presentation/version_update/version_update_page.dart';
import 'package:timeago/timeago.dart';
import 'bottom_tab_navigator.dart';
import 'presentation/common/loading.dart';
import 'user_model.dart';
import 'main_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setLocaleMessages('ja', JaMessages());

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
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              color: Colors.white,
              elevation: 0.5,
              iconTheme: IconThemeData(
                color: Colors.red,
              ),
              toolbarTextStyle: TextStyle(
                color: Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Typography.material2018().black.headline6.color,
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
                        BottomTabNavigator(),
                        Loading(context.watch<UserModel>().isLoading),
                      ],
                    )
                  : VersionUpdate();
            },
          ),
        );
      },
    );
  }
}
