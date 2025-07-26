import 'package:flutter/material.dart';

class BottomNavigationIcon extends StatelessWidget {
  final String label;
  final String? imagePath;
  final IconData? icon;
  final Color iconColor;
  final bool isAddButton;
  final VoidCallback? onTap;

  const BottomNavigationIcon({
    super.key,
    required this.label,
    this.imagePath,
    this.icon,
    required this.iconColor,
    this.isAddButton = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          isAddButton
              ? Stack(
            alignment: Alignment.center,
            children: [
              imagePath != null
                  ? Image.asset(
                imagePath!,
                width: 50,
                height: 50,
                color: iconColor,
              )
                  : Icon(icon, color: iconColor, size: 50),
              const Positioned(
                top: 8,
                child: Icon(Icons.add, color: Color(0xFFFBF5E9), size: 20),
              ),
            ],
          )
              : imagePath != null
              ? Image.asset(
            imagePath!,
            width: 50,
            height: 50,
            color: iconColor,
          )
              : Icon(icon, color: iconColor, size: 50),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: iconColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
