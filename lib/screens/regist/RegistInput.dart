import 'package:flutter/material.dart';

class Registinput extends StatelessWidget{
  final String hintText;

  const Registinput({
    Key? key,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: hintText,
      )
    );
  }
}