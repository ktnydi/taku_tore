import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import './auth/auth_page.dart';
import './bottom_tab_navigator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _store = Firestore.instance;

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
            final String currentUserUid = snapshot.data.uid;

            return StreamBuilder(
              stream: _store.document('users/$currentUserUid').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  DocumentSnapshot userSnapshot = snapshot.data;
                  final currentUser = userSnapshot.data;

                  return Provider<Map<String, dynamic>>.value(
                    value: currentUser,
                    child: BottomTabNavigator(),
                  );
                }
                return Container();
              },
            );
          }

          return Auth();
        },
      ),
    );
  }
}
