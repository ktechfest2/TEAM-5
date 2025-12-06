import 'package:flutter/material.dart';
// import 'package:flutter_application_testme/Components/color.dart';

class ButtonStyleCustom extends StatelessWidget {
  final String textid;
  final buttoncolor;
  final textcolor;
  final Function()? onTap;
  const ButtonStyleCustom(
      {super.key,
      required this.textid,
      required this.onTap,
      required this.buttoncolor,
      required this.textcolor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            // color: clientColor,
            color: buttoncolor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
              child: Text(textid,
                  style: TextStyle(
                    color: textcolor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )))),
    );
  }
}
