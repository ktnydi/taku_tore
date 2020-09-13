import 'package:flutter/material.dart';

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
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '検索',
                ),
                onSubmitted: (value) {
                  // TODO: search teachers.
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
