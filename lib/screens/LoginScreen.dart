import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_user_login/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? userAuthToken;
  var isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _phoneController.text = "+91";
  }

  Future loginUser(String phone, BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async {
          Navigator.of(context).pop();
          print("varification complete");
          UserCredential result = await _auth.signInWithCredential(credential);
          User? user = result.user;
          // if (user != null) {
          //   Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => HomeScreen(user: user,)));
          // } else {
          //   print("Error");
          // }
          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (FirebaseAuthException exception) {
        },
        codeSent: (String verificationId, [int? forceResendingToken]) async {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return ScaffoldMessenger(
                  child: Builder(builder: (context){
                    return Scaffold(
                      backgroundColor: Colors.transparent,
                      body: AlertDialog(
                        title: Text("Give the code?"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                              controller: _codeController,
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: Text("Confirm"),
                            onPressed: () async {
                              final code = _codeController.text.trim();

                              AuthCredential credential = PhoneAuthProvider.credential(
                                  verificationId: verificationId, smsCode: code);
                              try {
                                UserCredential result = await _auth
                                    .signInWithCredential(credential);
                                User? user = result.user;
                                if (user != null) {
                                  user.getIdToken(true).then((String token) {
                                    setState(() {
                                      userAuthToken = token;
                                    });
                                    print('The user ID token is : ' +
                                        userAuthToken.toString());
                                  });
                                } else {
                                  print("Error");
                                }
                                if (code.isNotEmpty) {
                                  Navigator.pop(context);
                                }
                                _codeController.text = "";
                                setState(() {
                                  isLoading = false;
                                });
                              }
                              on FirebaseException catch (exception){
                                showSnackBar(exception.code.toString(),context);
                                print("exception--"+ exception.code);
                              }
                            },
                          )
                        ],
                      ),
                    );
                  })
                );
              });
        },
        codeAutoRetrievalTimeout: (String value) {},

      );
    }
    catch(e){
    }
  }

  //Without otp Dialog
/*   Future loginUser(String phone, BuildContext context) async{
    FirebaseAuth _auth = FirebaseAuth.instance;
    isLoading = true;
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async{
          UserCredential result = await _auth.signInWithCredential(credential);
          User? user = result.user;
          if(user != null){
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => HomeScreen(user: user,)
            ));
          }else{
            print("Error");
          }
          //This callback would gets called when verification is done automaticlly
        },
        verificationFailed: (FirebaseAuthException exception){
          print(exception);
        },
        codeSent: (String verificationId, [int? forceResendingToken]) async {
          AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otp);
          UserCredential result = await _auth.signInWithCredential(credential);
          User? user = result.user;
          if(user != null) {
            user.getIdToken(true).then((String token) {
              setState(()  {
                userAuthToken =  token;
              });
              print('The user ID token is : ' + userAuthToken.toString());
            });
          }else{
            print("Error");
          }
          isLoading = false;
        },
        codeAutoRetrievalTimeout: (String value) {}
    );
    //return userAuthToken;
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(32),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Text(
                "Login",
                style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 36,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey)),
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: "Mobile Number"),
                controller: _phoneController,
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text("LOGIN"),
                  onPressed: () {
                    final phone = _phoneController.text.trim();
                     loginUser(phone, context);
                  },
                ),
              ),
              SizedBox(height: 8,),
              isLoading?
                  Center(child: CircularProgressIndicator()):
              Column(
                children: [
                  userAuthToken == "" || userAuthToken != null ?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(onPressed: () {
                            setState(() {
                              userAuthToken = "";
                            });
                          }, child: Text("Clear Token")),
                          InkWell(
                            onTap: (){
                              Clipboard.setData(ClipboardData(text: userAuthToken))
                                  .then((value) {
                                showSnackBar("Token Copied Successfully",context);
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Copy Token",
                                  style: TextStyle(fontSize: 15, color: Colors.blue),
                                ),
                                SizedBox(width: 10,),
                                Icon(
                                  Icons.copy,
                                  color: Colors.blue,
                                )
                              ],
                            ),
                          )
                        ],
                      )
                  : SizedBox(),
                  SizedBox(height: 10,),
                  SelectableText(
                    "${userAuthToken == "" || userAuthToken == null ? "" : userAuthToken}",
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  )
                ],
              ),

            ],
          ),
        ),
      ),
    ));
  }


  showSnackBar(String text,BuildContext context){
    var snackBar = SnackBar(
      content: Text(text),
    );
    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
