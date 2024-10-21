import 'package:flutter/material.dart';
import 'package:intelligrade/ui/header.dart';
import 'package:intelligrade/ui/custom_navigation_bar.dart';
import 'package:intelligrade/controller/main_controller.dart';
import 'package:intelligrade/controller/essay_generation.dart'; // Import the target page

class EssayEditPage extends StatefulWidget {
  const EssayEditPage({super.key});

  static MainController controller = MainController();

  @override
  _EssayEditPage createState() => _EssayEditPage();
}

class _EssayEditPage extends State<EssayEditPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex =
        ModalRoute.of(context)?.settings.arguments as int? ?? 0;
    return Scaffold(
      appBar: const AppHeader(title: "Edit Essay"),
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
              child: EssayGeneration(
                title:
                    'Create an Essay Assignment', // Pass the required parameters
              ),
            ),
          ],
        );
      }),
    );
  }
}
