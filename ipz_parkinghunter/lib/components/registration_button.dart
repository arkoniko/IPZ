import 'package:flutter/material.dart';

class RegistrationButton extends StatelessWidget {
  final VoidCallback onTap;
  final String buttonText;

  const RegistrationButton(
      {Key? key, required this.onTap, this.buttonText = 'Zarejestruj się'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(color: Colors.black),
          child: Center(
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
