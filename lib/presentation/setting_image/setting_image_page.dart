import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/loading.dart';
import '../../atoms/rounded_button.dart';
import 'setting_image_model.dart';

class SettingImage extends StatelessWidget {
  Future fetchImageFile(BuildContext context, SettingImageModel model) async {
    try {
      await model.fetchImageFile();
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(error.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }

  Future uploadImage(BuildContext context, SettingImageModel model) async {
    try {
      await model.uploadImage();
      Navigator.pop(context);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(e.toString()),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }

  ImageProvider<dynamic> userIcon(SettingImageModel model) {
    if (model.imageFile == null) {
      return NetworkImage(model.currentUser.photoURL);
    }
    return FileImage(model.imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingImageModel>(
      create: (_) => SettingImageModel()..fetchCurrentUser(),
      child: Consumer<SettingImageModel>(
        builder: (_, model, __) {
          if (model.currentUser == null) return SizedBox();

          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Scaffold(
                appBar: AppBar(
                  title: Text('画像の変更'),
                ),
                body: Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              await this.fetchImageFile(context, model);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: userIcon(model),
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: 40,
                                    color: Colors.black54,
                                    child: Center(
                                      child: Icon(
                                        Icons.photo_camera,
                                        size: 24,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          RoundedButton(
                            color: Colors.white,
                            child: Text(
                              '画像を選択',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            onPressed: () async {
                              await this.fetchImageFile(context, model);
                            },
                          ),
                          SizedBox(height: 15),
                          RoundedButton(
                            color: Theme.of(context).primaryColor,
                            child: Text(
                              '保存',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              if (model.imageFile == null) return;

                              await this.uploadImage(context, model);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Loading(model.isLoading),
            ],
          );
        },
      ),
    );
  }
}
