import 'package:flutter/material.dart';
import 'package:followup/constant/conurl.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:validators/validators.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;

import 'package:firebase_core/firebase_core.dart';
import 'package:followup/notification_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

String? token;

class loginScreen extends StatefulWidget {
  const loginScreen({Key? key}) : super(key: key);

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  
  TextEditingController _textEditingController = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  Future emplogin(String username, String password) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    //var urlString = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=employeelogin';
    
    var urlString = AppString.constanturl + 'employeelogin';

    Uri uri = Uri.parse(urlString);
    var response = await http.post(uri, body: {
      "username": username,
      "password": password,
    });

    final jsondata = json.decode(response.body);
    print("jsondata");
    print(jsondata);
    if (jsondata['result'] == "failure") {
      Fluttertoast.showToast(
        backgroundColor: Color.fromARGB(255, 255, 94, 0),
        textColor: Colors.white,
        msg: jsondata['message'],
        toastLength: Toast.LENGTH_SHORT,
      );
    } else if (jsondata['result'] == "success") {
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        textColor: Colors.white,
        msg: jsondata['message'],
        toastLength: Toast.LENGTH_SHORT,
      );
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('id', jsondata['userdata']['id']);
      preferences.setString('cmpid', jsondata['userdata']['company_id']);
      preferences.setString('admintype', jsondata['userdata']['admin_type']);
      preferences.setString('idemp', jsondata['userdata']['admin']);
    
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => DashboardScreen()));
    }
  }

  Future login(String username, String password) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    //var urlString = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=login';
    var urlString = AppString.constanturl + 'login';

    Uri uri = Uri.parse(urlString);
    var response = await http.post(uri, body: {
      "username": username,
      "password": password,
    });

    final jsondata = json.decode(response.body);
    print(jsondata);
    if (jsondata['result'] == "failure") {
      Fluttertoast.showToast(
        backgroundColor: Color.fromARGB(255, 255, 94, 0),
        textColor: Colors.white,
        msg: jsondata['message'],
        toastLength: Toast.LENGTH_SHORT,
      );
    } else if (jsondata['result'] == "success") {
      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        textColor: Colors.white,
        msg: jsondata['message'],
        toastLength: Toast.LENGTH_SHORT,
      );
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('id', jsondata['userdata']['id']);
      preferences.setString('cmpid', jsondata['userdata']['company_id']);
      preferences.setString('admintype', jsondata['userdata']['admin_type']);
      preferences.setString('idemp', jsondata['userdata']['id_emp']);

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => DashboardScreen()));
    }
  }

  @override
  void dispose() {
    _textEditingController.clear();
    super.dispose();
  }

  bool isEmailCorrect = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            // color: Colors.red.withOpacity(0.1),
            image: DecorationImage(
                image: NetworkImage(
                    // 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcShp2T_UoR8vXNZXfMhtxXPFvmDWmkUbVv3A40TYjcunag0pHFS_NMblOClDVvKLox4Atw&usqp=CAU',
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx7IBkCtYd6ulSfLfDL-aSF3rv6UfmWYxbSE823q36sPiQNVFFLatTFdGeUSnmJ4tUzlo&usqp=CAU'),
                fit: BoxFit.cover,
                opacity: 0.3)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie.network(
                  //     // 'https://assets6.lottiefiles.com/private_files/lf30_ulp9xiqw.json', //shakeing lock
                  //     'https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.flaticon.com%2Ffree-icon%2Flogin_6681204&psig=AOvVaw1U-9NZstj6-lwsTE_gu2cQ&ust=1687265068694000&source=images&cd=vfe&ved=0CBEQjRxqFwoTCMjL37uuz_8CFQAAAAAdAAAAABAK',
                  //     animate: true,
                  //     height: 120,
                  //     width: 600),
                  // logo here
                  Image.asset(
                    'assets/loginlogo.jpeg',
                    height: 120,
                    width: 120,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Log In Now',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text('Please login to continue using our app',
                      style: TextStyle(fontFamily: 'Poppins')
                      // style: GoogleFonts.indieFlower(
                      //   textStyle: TextStyle(
                      //       color: Colors.black.withOpacity(0.5),
                      //       fontWeight: FontWeight.w300,
                      //       // height: 1.5,
                      //       fontSize: 15),
                      // ),
                      ),

                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: isEmailCorrect! ? 280 : 200,
                    // _formKey!.currentState!.validate() ? 200 : 600,
                    // height: isEmailCorrect ? 260 : 182,
                    width: MediaQuery.of(context).size.width / 1.1,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 20, top: 20),
                          child: TextFormField(
                            controller: username,
                            onChanged: (val) {
                              setState(() {
                                isEmailCorrect = isEmail(val);
                              });
                            },
                            decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              prefixIcon: Icon(
                                Icons.person,
                                color: AppString.appgraycolor,
                              ),
                              filled: true,
                              fillColor: Color(0xFFFFD700),
                              labelText: "Email",
                              hintText: 'your-email@domain.com',
                              labelStyle: TextStyle(
                                color: (AppString.appgraycolor),
                              ),
                              // suffixIcon: IconButton(
                              //     onPressed: () {},
                              //     icon: Icon(Icons.close,
                              //         color: Colors.purple))
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: password,
                              obscuringCharacter: '*',
                              obscureText: true,
                              decoration: const InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: AppString.appgraycolor,
                                ),
                                filled: true,
                                fillColor: Color(0xFFFFD700),
                                labelText: "Password",
                                hintText: '*********',
                                labelStyle:
                                    TextStyle(color: AppString.appgraycolor),
                              ),
                              // validator: (value) {
                              //   if (value!.isEmpty && value!.length < 5) {
                              //     return 'Enter a valid password';
                              //     {
                              //       return null;
                              //     }
                              //   }
                              // },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),

                        // isEmailCorrect
                        //     ? ElevatedButton(
                        //         style: ElevatedButton.styleFrom(
                        //             shape: RoundedRectangleBorder(
                        //                 borderRadius:
                        //                     BorderRadius.circular(10.0)),
                        //             backgroundColor: isEmailCorrect == false
                        //                 ? Colors.red
                        //                 : Colors.purple,
                        //             padding: EdgeInsets.symmetric(
                        //                 horizontal: 131, vertical: 20)
                        //             // padding: EdgeInsets.only(
                        //             //     left: 120, right: 120, top: 20, bottom: 20),
                        //             ),
                        //         onPressed: () {
                        //           if (_formKey.currentState!.validate()) {
                        //             // If the form is valid, display a snackbar. In the real world,
                        //             // you'd often call a server or save the information in a database.
                        //             ScaffoldMessenger.of(context).showSnackBar(
                        //               const SnackBar(
                        //                   content: Text('Processing Data')),
                        //             );
                        //           }
                        //           // Navigator.push(
                        //           //     context,
                        //           //     MaterialPageRoute(
                        //           //         builder: (context) => loginScreen()));
                        //         },
                        //         child: Text(
                        //           'Log In',
                        //           style: TextStyle(fontSize: 17),
                        //         ))
                        //     : Container(),
                      ],
                    ),
                  ),

                  //this is button
                  // const SizedBox(
                  //   height: 30,
                  // ),
                  // ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //         shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(10.0)),
                  //         backgroundColor: Colors.purple,
                  //         padding: EdgeInsets.symmetric(
                  //             horizontal: MediaQuery.of(context).size.width / 3.3,
                  //             vertical: 20)
                  //         // padding: EdgeInsets.only(
                  //         //     left: 120, right: 120, top: 20, bottom: 20),
                  //         ),
                  //     onPressed: () {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) => loginScreen()));
                  //     },
                  //     child: Text(
                  //       'Sounds Good!',
                  //       style: TextStyle(fontSize: 17),
                  //     )), //
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          sharedPreferences.setString(
                              'username', username.text);
                          login(username.text, password.text);
                          username.clear();
                          password.clear();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => loginScreen()));
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                              color: AppString.appgraycolor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              fontFamily: 'poppins'),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 36, vertical: 18),
                          backgroundColor: Color(0xFFFFD700),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          sharedPreferences.setString(
                              'username', username.text);
                          emplogin(username.text, password.text);
                          username.clear();
                          password.clear();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => loginScreen()));
                        },
                        child: Text(
                          'Employee Login',
                          style: TextStyle(
                              color: AppString.appgraycolor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              fontFamily: 'poppins'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFD700),
                          padding: EdgeInsets.symmetric(
                              horizontal: 36, vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       'You have\'t any account?',
                  //       style: TextStyle(
                  //         color: Colors.black.withOpacity(0.6),
                  //       ),
                  //     ),
                  //     TextButton(
                  //       onPressed: () {},
                  //       child: Text(
                  //         'Sign Up',
                  //         style: TextStyle(
                  //             color: Colors.purple,
                  //             fontWeight: FontWeight.w500),
                  //       ),
                  //     )
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
