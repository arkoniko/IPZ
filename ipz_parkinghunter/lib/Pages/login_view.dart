import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ipz_parkinghunter/Pages/registration_view.dart';
import 'package:ipz_parkinghunter/components/login_button.dart';
import 'package:ipz_parkinghunter/components/login_password_boxes.dart';
import 'package:ipz_parkinghunter/components/login_square_tile.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editting controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // sign user in method
  void SignUserIn() async {
    // Loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    // Signing in
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      // Wrong email or password
      // For now the if instruction does not working
      if (e.code == 'user-not-found') {
        wrongDataMessage();
      } else if (e.code == 'wrong-password') {
        wrongPasswordMessage();
      }
    }
  }

  void wrongDataMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text("Nieprawidlowe dane do logowania"),
        );
      },
    );
  }

  void wrongPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text("Nieprawidlowe dane do logowania"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Interface name user widget
    return Scaffold(
      backgroundColor: const Color.fromARGB(247, 247, 247, 247),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),

              // logo
              const Icon(
                Icons.account_circle_sharp,
                size: 150,
              ),

              const SizedBox(height: 50),

              // Welcome back notification
              const Text(
                'Witaj z powrotem!',
                style: TextStyle(
                  color: Color.fromARGB(255, 107, 107, 107),
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              // Email field
              LoginTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // Password texbox
              LoginTextField(
                controller: passwordController,
                hintText: 'Haslo',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Zapomniales hasła?',
                      style: TextStyle(
                        color: Color.fromARGB(255, 107, 107, 107),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              LoginButton(
                onTap: SignUserIn,
              ),

              const SizedBox(height: 50),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Color.fromARGB(255, 107, 107, 107),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Lub zaloguj sie za pomoca',
                        style: TextStyle(
                            color: Color.fromARGB(255, 107, 107, 107)),
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

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // google button
                  SquareTile(imagePath: 'lib/images/google.png'),

                  // apple button
                  const SizedBox(width: 25),

                  SquareTile(imagePath: 'lib/images/apple.png'),
                ],
              ),

              const SizedBox(height: 50),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Nie masz konta?'),
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationPage()),
                    );
                  },
                  child: Text(
                    ' Zarejestruj się teraz!',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                )
              ])
            ],
          ),
        ),
      ),
    );
  }
}
