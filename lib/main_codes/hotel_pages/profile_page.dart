import 'package:flutter/material.dart';
import '../../_components/color.dart';

class ProfilePage extends StatelessWidget {
  final bool isMobile;
  const ProfilePage({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Profile Page",
        style: TextStyle(fontSize: 22, color: auxColor),
      ),
    );
  }
}
