import 'package:flutter/material.dart';

class SquareTileCustom extends StatelessWidget {
  final imgPath;
  const SquareTileCustom({super.key, this.imgPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .95,
      // height: MediaQuery.of(context).size.width * .9,
      height: 350,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(border: Border.all(color: const Color.fromRGBO(230, 223, 223, 0.126)),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white),
      // child: Image.asset(imgPath, fit: BoxFit.cover,)
      child: imgPath
    );
  }
}
