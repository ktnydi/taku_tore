import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './auth/auth_page.dart';
import './bottom_tab_navigator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<FirebaseUser>(
        stream: _auth.onAuthStateChanged,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // TODO: Fix following processing called twice.
          if (snapshot.data != null) {
            FirebaseUser currentUser = snapshot.data;
            return Provider<Object>.value(
              value: currentUser,
              child: BottomTabNavigator(),
            );
          }

          return Auth();
        },
      ),
    );
  }
}
