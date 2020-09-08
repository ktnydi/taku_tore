import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:version/version.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class MainModel extends ChangeNotifier {
  bool isRequiredUpdate = false;
  PackageInfo packageInfo;

  Future<void> checkVersion() async {
    final configName =
        Platform.isIOS ? 'support_version_ios' : 'support_version_android';
    final remoteConfig = await RemoteConfig.instance;
    await remoteConfig.fetch(expiration: const Duration(seconds: 0));
    await remoteConfig.activateFetched();
    final supportVersion = Version.parse(remoteConfig.getString(configName));
    final packageInfo = await PackageInfo.fromPlatform();
    this.packageInfo = packageInfo;
    final currentVersion = Version.parse(packageInfo.version);

    if (currentVersion < supportVersion) {
      this.isRequiredUpdate = true;
      notifyListeners();
    }
  }
}
