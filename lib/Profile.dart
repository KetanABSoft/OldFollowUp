import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:followup/constant/conurl.dart';
import 'package:followup/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'loginscreen.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

import 'dart:async';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

String? userid;
String? image;
String? password;
String? admintype;
Future logout(BuildContext context) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.remove('id');
  preferences.remove('cmpid');
  preferences.remove('admintype');
  preferences.remove('idemp');
  Fluttertoast.showToast(
    backgroundColor: Colors.green,
    textColor: Colors.white,
    msg: 'Logout Successfully',
    toastLength: Toast.LENGTH_SHORT,
  );
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => loginScreen(),
    ),
  );
}

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: profilemanagement(),
    ),
  );
}

class profilemanagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Follow Up',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Profile(),
    );
  }
}

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _Profile();
}

class _Profile extends State<Profile> {
  late Future<String?> _imageUrlFuture;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureText = true;
  bool _obscureTextConfirm = true;

  void fetchadmin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    admintype = preferences.getString('admintype');
  }

  @override
  void initState() {
    super.initState();
    fetchadmin();
    _imageUrlFuture = employeeimage();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<String?> employeeimage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userid = preferences.getString('id');
    admintype = preferences.getString('admintype');
    //String apiUrl = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=get_employeeimage';
    String apiUrl = AppString.constanturl + 'get_employeeimage';
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {'id': userid, 'admintype': admintype},
    );

    var jsondata = jsonDecode(response.body);
    image = jsondata['image'];
    password = jsondata['password'];
    _passwordController.text = '$password';
    if (image != '') {
      return AppString.profileurl + '$image';
    } else {
      return null;
    }
  }

  final picker = ImagePicker();

  Future<String> uploadImage(File image) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(AppString.constanturl + 'updateprofile'),
    );

    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    request.fields['id'] = '$id';
    request.fields['admintype'] = '$admintype';
    var response = await request.send();

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => profilemanagement(),
        ),
      );
      var responseData = await response.stream.toBytes();
      var responseString = utf8.decode(responseData);
      return responseString;
    } else {
      return 'Error uploading image.';
    }
  }

  // Future<void> selectAndUploadImage() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     File image = File(pickedFile.path);
  //     String response = await uploadImage(image);
  //     print(response);
  //   }
  // }

  Future<void> selectAndUploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      XFile? compressedImage = await compressImage(pickedFile);

      if (compressedImage != null) {
        String response = await uploadImage(File(compressedImage.path));
        print(response);

        Fluttertoast.showToast(
          msg: 'Profile updated successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        print("Image compression failed.");
      }
    }
  }

  Future<XFile?> compressImage(XFile imageFile) async {
    final filePath = imageFile.path;
    final lastIndex = filePath.lastIndexOf('.');
    final fileExtension = filePath.substring(lastIndex + 1);

    if (fileExtension.toLowerCase() == 'jpg' ||
        fileExtension.toLowerCase() == 'jpeg' ||
        fileExtension.toLowerCase() == 'png') {
      final splitted = filePath.substring(0, lastIndex);
      final outPath = "${splitted}_out.jpg"; // Convert to JPEG format

      if (fileExtension.toLowerCase() == 'png') {
        // Convert PNG to JPEG
        final image = img.decodeImage(File(filePath).readAsBytesSync());
        final jpegImage = img.encodeJpg(image!);
        File(outPath).writeAsBytesSync(jpegImage);
      } else {
        // For JPEG images, simply copy the file
        File(filePath).copySync(outPath);
      }

      // Provide a unique target path for compressed image
      final compressedPath = "${splitted}_compressed.jpg";

      XFile? compressedData = await FlutterImageCompress.compressAndGetFile(
        outPath, // Use the JPEG file
        compressedPath, // Use a unique target path
        minWidth: 1000,
        minHeight: 1000,
        quality: 70,
      );
      return compressedData;
    } else {
      // Unsupported image format
      return null;
    }
  }

  // Future<XFile?> compressImage(XFile imageFile) async {
  //   final filePath = imageFile.path;
  //   final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
  //   final splitted = filePath.substring(0, lastIndex);
  //   final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
  //   XFile? compressedData = await FlutterImageCompress.compressAndGetFile(
  //     filePath,
  //     outPath,
  //     minWidth: 1000,
  //     minHeight: 1000,
  //     quality: 70,
  //   );

  //   return compressedData;
  // }

  Future<void> submitForm(String newPassword, String confirmPassword) async {
    if (_formKey.currentState!.validate()) {
      var urlString = AppString.constanturl + 'update_password';

      Uri uri = Uri.parse(urlString);
      var response = await http.post(uri, body: {
        "id": userid,
        "admintype": admintype,
        "password": newPassword,
        "confirmpassword": confirmPassword,
      });
      final jsondata = json.decode(response.body);
      if (jsondata['result'] == "failed") {
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

        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => DashboardScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Profile',style: TextStyle(fontFamily: 'Poppins')),
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back),
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => TaskManagementApp(),
      //         ),
      //       );
      //     },
      //   ),
      //   backgroundColor: Color(0xFFFFD700),
      // ),

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFD700),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppString.appgraycolor,
                fontSize: 20,
                // fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppString.appgraycolor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Add padding here

          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<String?>(
                  future: _imageUrlFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error fetching image');
                    } else {
                      final imageUrl = snapshot.data;

                      return CircleAvatar(
                        radius: 120,
                        backgroundImage: NetworkImage('$imageUrl'),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD700),
                      ),
                      onPressed: selectAndUploadImage,
                      child: const Text('Change Profile Image',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: AppString.appgraycolor)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD700),
                      ),
                      onPressed: () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            content: const Text('Are You Sure to Logout?',
                                style: TextStyle(fontFamily: 'Poppins')),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel',
                                    style: TextStyle(fontFamily: 'Poppins')),
                              ),
                              TextButton(
                                onPressed: () {
                                  logout(context);
                                  Navigator.pop(context, 'true');
                                },
                                child: const Text('OK',
                                    style: TextStyle(fontFamily: 'Poppins')),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Log Out',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: AppString.appgraycolor)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(
                                  _obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            obscureText: _obscureText,
                            controller: _newPasswordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a new password';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: TextStyle(
                                fontFamily: 'Poppins',
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureTextConfirm = !_obscureTextConfirm;
                                  });
                                },
                                child: Icon(
                                  _obscureTextConfirm
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            obscureText: _obscureTextConfirm,
                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm the password';
                              } else if (value != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFD700),
                            ),
                            onPressed: () {
                              submitForm(_newPasswordController.text,
                                  _confirmPasswordController.text);
                            },
                            child: const Text('Save',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: AppString.appgraycolor)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
