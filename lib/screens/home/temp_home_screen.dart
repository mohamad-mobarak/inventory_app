import 'package:flutter/material.dart';

class TempHomeScreen extends StatelessWidget {
  final String title;

  const TempHomeScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
