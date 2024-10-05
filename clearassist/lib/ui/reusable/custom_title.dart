import 'package:flutter/material.dart';

class CustomTitle extends StatelessWidget {
  final String? titleText; // Optional title parameter

  CustomTitle({this.titleText}); // Constructor

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icons/app_icon.png', // Replace with your app icon
          fit: BoxFit.contain,
          height: 32,
          color: Colors.white,
        ),
        const SizedBox(width: 10),
        Text(
          titleText ?? 'ClearAssist', // Use custom title if provided, else default to 'Settings'
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}
