import 'package:flutter/material.dart';
import 'package:takutore/presentation/search_teacher_list/search_teacher_list_page.dart';

class SearchTeacher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Flexible(
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '検索',
                ),
                onSubmitted: (value) {
                  if (value.isEmpty) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchTeacherList(text: value),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Image.asset(
                'images/algolia.png',
                height: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
