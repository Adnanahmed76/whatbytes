import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService{
  FirebaseAuth _auth=FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword( String email,String password)async{
    try{
      UserCredential credential=await _auth.createUserWithEmailAndPassword( email: email, password: password);
      return credential.user;
    }on FirebaseAuthException catch (e){
    if(e.code=="email- already in use"){
      AlertDialog(
        title: Text("The email address is already used"),

      );

    }else{
      AlertDialog(title: Text("An error Occured ${e.code}"),);
    }
    }
    return null;
  }
  Future<User?> signinWithEmailAndPassword(String email,String password)async{
    try{
      UserCredential credential=await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e){
      if(e.code=="User- not found "|| e.code=="Wrong password"){
        AlertDialog(title: Text("Invalid Email or password"),);

      }else{
        AlertDialog(title: Text("An error Occured"),);
      }
    }
    return null;
  }
}