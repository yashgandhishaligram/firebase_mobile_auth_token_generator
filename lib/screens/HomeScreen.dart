import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {

  final User? user;
  String? userAuthToken;

  HomeScreen({this.user, this.userAuthToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("You are Logged in succesfully", style: TextStyle(color: Colors.lightBlue, fontSize: 32),),
            SizedBox(height: 16),
            Text("Mobile no. : ${user!.phoneNumber}", style: TextStyle(color: Colors.black ),),
            SizedBox(height: 10,),
            Text("$userAuthToken" , style: TextStyle(color: Colors.blue, ),),
          ],
        ),
      ),
    );
  }

}
