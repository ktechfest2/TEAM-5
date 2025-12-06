import 'package:flutter/material.dart';
import '../../_components/color.dart';

class ChatPage extends StatelessWidget {
  final bool isMobile;
  const ChatPage({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Chat Page",
        style: TextStyle(fontSize: 22, color: auxColor),
      ),
    );
  }
}
