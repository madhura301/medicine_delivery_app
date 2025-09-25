import 'package:flutter/material.dart';

class ChemistProfilePage extends StatelessWidget {
  const ChemistProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chemist Profile"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Chemist Profile Details Here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
