import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmanagementforgigworker/features/user_auth/firebase_auth_implementation.dart';
import 'package:taskmanagementforgigworker/pages/home_page.dart';
import 'package:taskmanagementforgigworker/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _auth=FirebaseAuthService();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Center(
            child: Icon(Icons.lock_person, size: 100, color: Colors.deepPurple),
          ),
          Center(
            child: Text(
              "Welcome Back ",
              style: TextStyle(fontSize: 25, color: Colors.blue),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border:
                    OutlineInputBorder(), // ✅ this gives a visible box border
                // optional icon
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: _passwordController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your Password',   
                border:
                    OutlineInputBorder(), // ✅ this gives a visible box border
                // optional icon
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: (){
              _signin();
            },
            child: Center(
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: Colors.blue),
                child: Center(
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
              child: Text(
            "or Log in with",
            style: TextStyle(color: Colors.grey),
          )),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/facebook.png", height: 40),
              const SizedBox(width: 20),
              Image.asset("images/social.png", height: 40),
              const SizedBox(width: 20),
              Image.asset("images/apple.png", height: 40),
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't Have An Account "),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RegisterPage()));
                },
                child: Text(
                  "Get Started",
                  style: TextStyle(color: Colors.blue),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
    void _signin()async{

    String email=_emailController.text;
    String password=_passwordController.text;

    User? user=await _auth.signinWithEmailAndPassword( email, password);

    if(user==null){
      print("USer is successully created");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
    }else{
      print("Some Erro happend");
    }

}

}