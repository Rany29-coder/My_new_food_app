import 'package:flutter/material.dart';

class AppWidget {
  static TextStyle boldTextFieldStyle = const TextStyle(
    color: Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: "Poppins",
  );

  static TextStyle headlineTextFieldStyle = const TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: "Poppins",
  );

  static TextStyle lightlineTextFieldStyle = const TextStyle(
    color: Colors.grey,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: "Poppins",
  );

  static TextStyle semiboldTextFieldStyle = const TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: "Poppins",
  );

  static Widget showItem({
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            imagePath,
            height: 50,
            width: 50,
            fit: BoxFit.cover,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

