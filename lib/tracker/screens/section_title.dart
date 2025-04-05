import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;

  const SectionTitle({
    super.key,
    required this.text,
    this.fontSize = 18,
    this.fontWeight = FontWeight.bold,
    this.color = const Color(0xFF616161),
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.textAlign = TextAlign.left,
  });

  const SectionTitle.large({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.fontWeight = FontWeight.bold,
    this.color = Colors.black,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          fontFamily: 'Cera Pro',
        ),
      ),
    );
  }
}