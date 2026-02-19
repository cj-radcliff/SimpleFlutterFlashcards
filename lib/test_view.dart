import 'package:flutter/material.dart';

class TestView extends StatefulWidget {
  // Violation 1: Missing 'const' on constructor for a stateless-style widget
  TestView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TestViewState createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  // Violation 2: This controller is never disposed. (Memory Leak)
  final TextEditingController _controller = TextEditingController();

  void _handleSave() async {
    print("Saving data...");
    await Future.delayed(Duration(seconds: 2));

    // Violation 3: Using 'context' after an async gap without 'if (!mounted) return;'
    // This will crash if the user navigated away during the 2-second delay.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(controller: _controller),
          ElevatedButton(onPressed: _handleSave, child: Text("Save")),
          // Violation 4: Use of Container for simple spacing instead of SizedBox
          Container(height: 20),
        ],
      ),
    );
  }
}

