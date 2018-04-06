import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

///列表元素
class SearchItem  extends StatelessWidget{
  SearchItem({
    @required this.title,
    this.style,
    this.subtitle,
    this.value,
    this.onTap,
    this.cover,
  });
  final String title;
  final TextStyle style;
  final String subtitle;
  final  cover;
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: cover,
      title: new Text(title, style: style,),
      subtitle: subtitle != null ? new Text(subtitle) : null,
      onTap: onTap,
    );
  }
}
