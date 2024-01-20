import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ipz_parkinghunter/components/registration_button.dart';
import 'package:ipz_parkinghunter/components/registration_text_field.dart';
import 'package:ipz_parkinghunter/components/social_media_signup.dart';

class RegistrationPage extends StatefulWidget {
  RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void registerUser() async {
    // Registration logic
    // ...
  }

  void signInWithGoogle() async {
    // Google sign-in logic
    // ...
  }

  void signInWithApple() async {
    // Apple sign-in logic
    // ...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(247, 247, 247, 247),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),

                const Icon(Icons.account_circle_sharp, size: 150),

                const SizedBox(height: 50),

                const Text('Utwórz nowe konto',
                    style: TextStyle(
                        color: Color.fromARGB(255, 107, 107, 107),
                        fontSize: 16)),
                const SizedBox(height: 25),
                RegistrationTextField(
                    controller: emailController, hintText: 'Email'),
                const SizedBox(height: 10),
                RegistrationTextField(
                    controller: passwordController,
                    hintText: 'Hasło',
                    obscureText: true),
                const SizedBox(height: 10),
                RegistrationTextField(
                  controller: confirmPasswordController,
                  hintText: 'Potwierdź hasło',
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                RegistrationButton(onTap: registerUser),
                const SizedBox(height: 50),
                // Divider with text "Or log in with" in the middle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Lub zaloguj się za pomocą',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                SocialMediaSignUp(
                    onGooglePressed: signInWithGoogle,
                    onApplePressed: signInWithApple),

                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Masz już konto?'),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(
                            context); // Navigate back to the login screen
                      },
                      child: const Text(
                        ' Zaloguj się!',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
