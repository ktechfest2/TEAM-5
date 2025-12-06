import 'package:flutter/material.dart';
import '../../_components/color.dart';

class ServicesPage extends StatelessWidget {
  final bool isMobile;
  const ServicesPage({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Services Page",
        style: TextStyle(fontSize: 22, color: auxColor),
      ),
    );
  }
}
