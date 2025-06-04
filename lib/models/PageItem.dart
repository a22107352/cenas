import 'package:flutter/cupertino.dart';

class PageItem {
  final String title;
  final IconData icon;
  final Widget widget;
  final Key key;

  PageItem({
    required this.title,
    required this.icon,
    required this.widget,
    required this.key,
  });
}
