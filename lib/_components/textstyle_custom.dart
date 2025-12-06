import 'package:flutter/material.dart';

class TextstyleCustom extends StatelessWidget {
  final String textt;
  const TextstyleCustom({super.key, required this.textt});

  @override
  Widget build(BuildContext context) {
    return Text(
      textt,
      style: TextStyle(
          color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
