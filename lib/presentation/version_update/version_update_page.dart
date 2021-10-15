import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class VersionUpdate extends StatefulWidget {
  @override
  _VersionUpdateState createState() => _VersionUpdateState();
}

class _VersionUpdateState extends State<VersionUpdate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(15),
        child: Center(
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(15, 55, 15, 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'バージョンアップのお知らせ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      '新しいバージョンのアプリがリリースされました。ストアよりアップデートしてご利用ください。',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 30),
                    ButtonTheme(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade300,
                              Colors.blue.shade500,
                              Colors.blue.shade700,
                            ],
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            final appStoreURL =
                                'https://apps.apple.com/jp/app/takutore/id1529380989';

                            final storeURL = Platform.isIOS ? appStoreURL : '';

                            launcher.launch(storeURL);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.all(0),
                            primary: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              '今すぐアップデートする',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -45,
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.info,
                    size: 80,
                    color: Colors.blue,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(45),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
