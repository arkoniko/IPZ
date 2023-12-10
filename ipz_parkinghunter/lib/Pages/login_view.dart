import 'package:flutter/material.dart';
import 'package:ipz_parkinghunter/components/login_button.dart';
import 'package:ipz_parkinghunter/components/login_password_boxes.dart';

class LoginPage extends StatelessWidget
{
  LoginPage({super.key});

  // text editting controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    // Interface name user widget
    return  Scaffold
    (
      backgroundColor: const Color.fromARGB(247, 247, 247, 247),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
               const SizedBox(height: 50),

              // logo
               const Icon(
                Icons.lock,
                size: 100,
               ),

               const SizedBox(height: 50),

               // Welcome back notification 
               const Text('Witaj z powrotem!',
               style: TextStyle(color: Color.fromARGB(255, 107, 107, 107),
               fontSize: 16,),
               ),

              const SizedBox(height: 25),

              // Username field
              LoginTextField(
                controller: usernameController,
                hintText: 'Login',
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
                    Text('Zapomniales hasła?',
                    style: TextStyle(color: Color.fromARGB(255, 107, 107, 107),),),
                  ],
                ),
              ),
              SizedBox(height: 25),

              LoginButton(),
            ],
            ),
        ),
      ),
    );
    
  }
} 