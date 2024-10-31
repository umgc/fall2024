import 'package:flutter/material.dart';

class CustomTitle extends StatelessWidget {
  final String? titleText; // Optional title parameter

  const CustomTitle({super.key, this.titleText}); // Constructor

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
          titleText ?? 'ClearAssist', // Use custom title if provided, else default to 'ClearAssist'
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? customTitle;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    this.customTitle,
    this.showBackButton = true, // Default to showing back button
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.5), // Dark, mostly opaque background
      elevation: 0,
      centerTitle: true,
      title: CustomTitle(titleText: customTitle),
      leading: showBackButton
          ? BackButton(color: Colors.white) // Adds a back button with white color
          : null, // If showBackButton is false, no back button is shown
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0); // Standard AppBar height
}
