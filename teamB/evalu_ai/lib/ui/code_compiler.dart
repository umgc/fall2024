import 'package:flutter/material.dart';
import 'package:intelligrade/ui/header.dart';
import 'package:intelligrade/ui/custom_navigation_bar.dart';
import 'package:intelligrade/ui/grading_page.dart'; // Import the target page
import 'package:intelligrade/controller/main_controller.dart';

class CodeCompilerPage extends StatefulWidget {
  const CodeCompilerPage({super.key});

  static MainController controller = MainController();

  @override
  _CodeCompilerPage createState() => _CodeCompilerPage();
}

class _CodeCompilerPage extends State<CodeCompilerPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex =
        ModalRoute.of(context)?.settings.arguments as int? ?? 0;
    return Scaffold(
      appBar: const AppHeader(title: "Compile Code"),
      body: LayoutBuilder(builder: (context, constraints) {
        return Row(
          children: [
            Container(
              width: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueGrey,
                  width: 0.5,
                ),
              ),
              child: CustomNavigationBar(selectedIndex: selectedIndex),
            ),
            // Replace the button with the EssayGeneration page
            Expanded(
              child: GradingPage(
                title:
                    'Compile Code Submissions', // Pass the required parameters
              ),
            ),
          ],
        );
      }),
    );
  }
}
