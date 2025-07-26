import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Books List'),
        backgroundColor: Color(0xFFFBF5E9),
        foregroundColor: Color(0xFF7A7166), // uses your predefined color
      ),
      backgroundColor: Color(0xFFFBF5E9),
      body: const Center(
        child: Text(
          'Here will be your books',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFF7A7166),
          ),
        ),
      ),
    );
  }
}
