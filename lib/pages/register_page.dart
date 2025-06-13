
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmanagementforgigworker/features/user_auth/firebase_auth_implementation.dart';
import 'package:taskmanagementforgigworker/pages/home_page.dart';
import 'package:taskmanagementforgigworker/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

final FirebaseAuthService _auth=FirebaseAuthService();

  TextEditingController _nameControleer = TextEditingController();
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
              "Get started ",
              style: TextStyle(fontSize: 25, color: Colors.blue),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: _nameControleer,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your name',
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
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your Email',
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
              _signUp();
            },
            child: Center(
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: Colors.blue),
                child: Center(
                  child: Text(
                    "Sign Up",
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
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already Have An Account"),
              SizedBox(
                width: 5,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.blue),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
  void _signUp()async{
    String username=_nameControleer.text;
    String email=_emailController.text;
    String password=_passwordController.text;

    User? user=await _auth.signUpWithEmailAndPassword( email, password);

    if(user==null){
      print("USer is successully created");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage()));
    }else{
      print("Some Erro happend");
    }

  }
}
