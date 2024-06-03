import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/material.dart';
import 'package:followup/AddTask.dart';
import 'package:followup/Notifications_screen.dart';
import 'package:followup/constant/conurl.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

import 'ListAll.dart';
import 'dashboard.dart';

class Viewnotification extends StatefulWidget {
  final String id;
  Viewnotification({required this.id});

  @override
  State<Viewnotification> createState() => _ViewnotificationState();
}

class _ViewnotificationState extends State<Viewnotification>
    with WidgetsBindingObserver {
  TextEditingController startdatenew = TextEditingController();
  TextEditingController starttimenew = TextEditingController();
  TextEditingController endtimenew = TextEditingController();
  TextEditingController endtdatenew = TextEditingController();
  TextEditingController titlenew = TextEditingController();
  TextEditingController selectassignenew = TextEditingController();

  final AudioPlayer audioPlayer = AudioPlayer();
  ScrollController controller = ScrollController();
  String? title;
  String? startdate;
  String? enddate;
  String? starttime;
  String? endtime;
  String? assign;
  String? imageUrl;
  String? audiourl;
  String? image;
  String? audio;
  String? admintype;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    fetchTaskData();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.stop();
    WidgetsBinding.instance?.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      audioPlayer.stop();
    }
  }

  void fetchTaskData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    admintype = preferences.getString('admintype');
    var urlString = AppString.constanturl + 'gettask';
    Uri uri = Uri.parse(urlString);
    var response = await http.post(uri, body: {
      "taskid": widget.id,
    });

    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      setState(() {
        title = jsondata['title'];
        startdate = jsondata['startdate'];
        enddate = jsondata['enddate'];
        starttime = jsondata['starttime'];
        endtime = jsondata['endtime'];
        assign = jsondata['assign'];
        image = jsondata['image'];
        audio = jsondata['audio'];

        if (image != '') {
          imageUrl = AppString.imageurl + '$image';
        }
        startdatenew.text = startdate.toString();
        starttimenew.text = starttime.toString();
        endtimenew.text = endtime.toString();
        endtdatenew.text = enddate.toString();
        titlenew.text = title.toString();
        selectassignenew.text = assign.toString();
        if (audio != '') {
          audiourl = AppString.audiourl + '$audio';
        }
      });
    }
  }

  void playAudio(String audioUrl) async {
    print('audiourl' '$audiourl');
    final String audio = audioUrl;
    audioPlayer.play(UrlSource(audio));
  }

  void pauseAudio() {
    audioPlayer.pause();
    print('Audio paused');
  }

  void backbutton() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListScreen(
          admin_type: admintype.toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              'View Task',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppString.appgraycolor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppString.appgraycolor),
              onPressed: () {
                audioPlayer.pause();
                //Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NotificationScreen(admin_type: admintype.toString())),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed logic for the floating button here
          // This code will be executed when the button is pressed
          audioPlayer.pause();
          //Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    NotificationScreen(admin_type: admintype.toString())),
          );
        },
        child: Icon(Icons.arrow_back,
            color: AppString.appgraycolor), // Change the icon as needed
        backgroundColor: Color(0xFFFFD700), // Change the color as needed
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .endFloat, // Adjust the position as needed

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    readOnly: true,
                    enabled: false,
                    controller: titlenew,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black, // Change the label color here
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .grey), // Change the bottom line color here
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blue), // Change the focused bottom line color here
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          readOnly: true,
                          enabled: false,
                          controller: startdatenew,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.date_range),
                            labelText: 'Start Date',
                            labelStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              color:
                                  Colors.black, // Change the label color here
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors
                                      .grey), // Change the bottom line color here
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors
                                      .blue), // Change the focused bottom line color here
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Flexible(
                        child: TextField(
                          enabled: false,
                          readOnly: true,
                          controller: starttimenew,
                          decoration: InputDecoration(
                            icon: Icon(Icons.timer),
                            labelText: 'Start Time',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color:
                                  Colors.black, // Change the label color here
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors
                                      .grey), // Change the bottom line color here
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors
                                      .blue), // Change the focused bottom line color here
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          readOnly: true,
                          enabled: false,
                          controller: endtdatenew,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.date_range),
                            labelText: 'End date',
                            labelStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              color:
                                  Colors.black, // Change the label color here
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors
                                      .grey), // Change the bottom line color here
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors
                                      .blue), // Change the focused bottom line color here
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          width:
                              16.0), // Adjust the spacing between the text fields
                      Flexible(
                        child: TextField(
                          enabled: false,
                          controller: endtimenew,
                          decoration: InputDecoration(
                            icon: Icon(Icons.timer),
                            labelText: 'End Time',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color:
                                  Colors.black, // Change the label color here
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors
                                      .grey), // Change the bottom line color here
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors
                                      .blue), // Change the focused bottom line color here
                            ),
                          ),

                          readOnly:
                              true, //set it true, so that user will not able to edit text
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    enabled: false,
                    controller: selectassignenew,
                    decoration: InputDecoration(
                      labelText: 'Assign Name',
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black, // Change the label color here
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .grey), // Change the bottom line color here
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blue), // Change the focused bottom line color here
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Image  :  ',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
                        ),
                      ),
                      SizedBox(
                          width:
                              16.0), // Adjust the spacing between the text fields
                      Flexible(
                        child: imageUrl != null
                            ? Image.network(
                                '$imageUrl',
                                height: 200, // Set the height
                                width: 300,
                              )
                            : Container(
                                width: 0,
                                height: 0,
                                //color: Colors.grey,
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Audio  :  ',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
                        ),
                      ),
                      SizedBox(
                          width:
                              10.0), // Adjust the spacing between the text fields
                      Flexible(
                        child: audio != ''
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFFD700),
                                ),
                                onPressed: () {
                                  String audioUrl = '$audiourl';
                                  playAudio(audioUrl);
                                },
                                child: Text('Play',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13.0,
                                        color: AppString.appgraycolor)),
                              )
                            : SizedBox(),
                      ),
                      SizedBox(width: 5.0),
                      Flexible(
                        child: audio != ''
                            ? Container(
                                //width: 150, // Set the width you desire
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFFD700),
                                  ),
                                  onPressed: () {
                                    pauseAudio();
                                  },
                                  child: Text(
                                    'Stop Audio',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13.0,
                                        color: AppString.appgraycolor),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
