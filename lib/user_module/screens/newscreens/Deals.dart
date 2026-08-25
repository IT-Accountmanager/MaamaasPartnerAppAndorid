import 'package:flutter/material.dart';

class Deals extends StatefulWidget {
  const Deals({super.key});

  @override
  State<Deals> createState() => _DealsState();
}

class _DealsState extends State<Deals> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("deals"),),
      body: SafeArea(child: Column(
        children: [
          Center(child: Text("Deals"))
        ],
      )),
    );
  }
}
