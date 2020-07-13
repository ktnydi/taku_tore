import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takutore/molecule/teacher_cell.dart';
import '../teacher_detail/teacher_detail_page.dart';
import 'bookmark_model.dart';

class BookmarkList extends StatefulWidget {
  @override
  _BookmarkListState createState() => _BookmarkListState();
}

class _BookmarkListState extends State<BookmarkList> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookmarkModel>(
      create: (_) => BookmarkModel()..fetchBookmarks(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ブックマーク',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<BookmarkModel>(
          builder: (_, model, __) {
            if (model.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (model.teachers.isEmpty) {
              return Center(
                child: Text(
                  'ブックマークはありません。',
                ),
              );
            }

            final listTiles = model.teachers.map(
              (teacher) {
                return TeacherCell(teacher: teacher);
              },
            ).toList();
            return ListView.separated(
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) => listTiles[index],
              itemCount: listTiles.length,
            );
          },
        ),
      ),
    );
  }
}
