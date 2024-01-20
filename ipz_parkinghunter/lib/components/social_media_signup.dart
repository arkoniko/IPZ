import 'package:flutter/material.dart';
import 'package:ipz_parkinghunter/components/login_square_tile.dart';

class SocialMediaSignUp extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;

  const SocialMediaSignUp({
    Key? key,
    required this.onGooglePressed,
    required this.onApplePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onGooglePressed,
          child: SquareTile(imagePath: 'lib/images/google.png'),
        ),
        const SizedBox(width: 25),
        GestureDetector(
          onTap: onApplePressed,
          child: SquareTile(imagePath: 'lib/images/apple.png'),
        ),
      ],
    );
  }
}
