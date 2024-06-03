import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:followup/constant/conurl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

// import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';

import 'EditRecorder.dart';
import 'ListAll.dart';
import 'TaskCompleted.dart';
import 'Recorder.dart';
import 'TaskReceive.dart';
import 'TaskSend.dart';
import 'dashboard.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

TextEditingController titlee = new TextEditingController();
TextEditingController start_date = new TextEditingController();
TextEditingController deadline_date = new TextEditingController();
TextEditingController start_time = new TextEditingController();
TextEditingController end_time = new TextEditingController();

String? taskk;
String? title;
String? startdate;
String? enddate;
String? starttime;
String? endtime;
String? assign;
String? assignid;
String? imageUrl;
String? audiourl;
String? image;
String? audio;
var mainid;
String? userid;
String? cmpid;
String? admintype;
String? audiopathh;
String? audioo;
bool _isUploading = false;

class Edit extends StatefulWidget {
  final String task;
  final String id;
  final String audiopath;
  final String backto;
  Edit(
      {required this.id,
      required this.task,
      required this.audiopath,
      required this.backto});

  @override
  State<Edit> createState() => _EditState();
}

// class _EditState extends State<Edit> {
class _EditState extends State<Edit> with WidgetsBindingObserver {
  void updatedata(String titlee, String start_date, String deadline_date,
      String start_time, String end_time) async {
    if (mounted) {
      var urlString = AppString.constanturl + 'updatetask';
      Uri uri = Uri.parse(urlString);
      var response = await http.post(uri, body: {
        "id": id,
        "title": titlee,
        "startdate": start_date,
        "deadlinedate": deadline_date,
        "starttime": start_time,
        "endtime": end_time,
        "assign": _selectedValue,
      });

      mainid = id;
      var jsondata = jsonDecode(response.body);
      if (jsondata['success'] == "success") {
        print(pic);
        if (pic != '') {
          sendimage(mainid);
        }

        _uploadAudio(mainid);
        // _handleSubmit();
        Fluttertoast.showToast(
          backgroundColor: Color.fromARGB(255, 0, 255, 55),
          textColor: Colors.white,
          msg: jsondata['message'],
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        Fluttertoast.showToast(
          backgroundColor: Color.fromARGB(255, 236, 81, 9),
          textColor: Colors.white,
          msg: jsondata['message'],
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }

  List<dynamic> dropdownItems = [];
  dynamic _selectedValue;
  final AudioPlayer audioPlayer = AudioPlayer();
  // PlayerState audioPlayerState = PlayerState.STOPPED;
  final _formKey = GlobalKey<FormState>();
  // XFile? image;
  XFile? imageee;
  final ImagePicker picker = ImagePicker();
  File? _selectedAudio;
  File? _audio;
  dynamic asssign;
//  var img;
  var pic;
  ScrollController controller = ScrollController();
  List<String> stateType = [];
  List<String> stateTypeid = [];
  var _sateMasterList;

  @override
  void initState() {
    super.initState();
    id = widget.id;
    task = widget.task;
    audioo = widget.audiopath;
    gettaskdata();
    fetchDropdownData();
    WidgetsBinding.instance?.addObserver(this);
  }

  Future<void> fetchDropdownData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userid = preferences.getString('id');
    cmpid = preferences.getString('cmpid');
    admintype = preferences.getString('admintype');
    String apiUrl = AppString.constanturl + 'get_employee';
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {'id': userid, 'cmpid': cmpid, 'admintype': admintype},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      _sateMasterList = jsonData;
      for (int i = 0; i < _sateMasterList.length; i++) {
        stateTypeid.add(_sateMasterList[i]["id"]);
        stateType.add(_sateMasterList[i]["firstname"]);
        setState(() {});
      }
    } else {
      print(
          'Error fetching dropdown data. Status code: ${response.statusCode}');
    }
  }

  String? id;
  String? task;
  void gettaskdata() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    audiopathh = preferences.getString('audiopathh');
    //var urlString = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=gettask';
    var urlString = AppString.constanturl + 'gettask';
    Uri uri = Uri.parse(urlString);
    var response = await http.post(uri, body: {
      "taskid": '$id',
    });
    var jsondata = jsonDecode(response.body);
    title = jsondata['title'];
    startdate = jsondata['startdate'];
    enddate = jsondata['enddate'];
    starttime = jsondata['starttime'];
    endtime = jsondata['endtime'];
    assign = jsondata['assign'];
    assignid = jsondata['assignid'];
    image = jsondata['image'];
    audio = jsondata['audio'];

    titlee.text = '$title';
    start_date.text = '$startdate';
    deadline_date.text = '$enddate';
    start_time.text = '$starttime';
    end_time.text = '$endtime';
    _selectedValue = '$assign';

    if (image != '') {
      imageUrl = AppString.imageurl + '$image';
    }
    if (audio != '') {
      audiourl = AppString.audiourl + '$audio';
    }
  }

  @override
  void dispose() {
    audioPlayer.stop();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      audioPlayer.stop();
    }
  }

  //  Future<void> playAudio() async {
  //   await audioPlayer.play('$audiourl', isLocal: false);
  // }

  void playAudio(String audioUrl) async {
    print(audiourl);
    final String audio = audioUrl;
    audioPlayer.play(UrlSource(audio));
  }

  void pauseAudio() {
    audioPlayer.pause();
    print('Audio paused');
  }

  Future<void> _selectAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        _selectedAudio = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadAudio(String id) async {
    // if (_selectedAudio != null) {
    //   id = id;
    //   //final url = Uri.parse('http://testfollowup.absoftwaresolution.in/getlist.php?Type=addaudio');
    //   final url = Uri.parse(AppString.constanturl + 'updateaudio');
    //   var request = http.MultipartRequest('POST', url);
    //   request.files.add(
    //       await http.MultipartFile.fromPath('audio', _selectedAudio!.path));
    //   request.fields['id'] = id;
    //   var response = await request.send();
    //   if (response.statusCode == 200) {
    //     print('Audio uploaded successfully.');
    //   } else {
    //     print('Failed to upload audio. Error: ${response.reasonPhrase}');
    //   }
    // } else
    if (audioo != '') {
      print(audioo);
      print('audioo');
      final url = Uri.parse(AppString.constanturl + 'updateaudio');
      var request = http.MultipartRequest('POST', url);

      //if (await file.exists()) {
      // Create a new MultipartFile from the audio file
      var audio = await http.MultipartFile.fromPath('audio', audioo.toString());

      // Add the audio file to the request
      request.files.add(audio);

      // Add other request fields as needed
      request.fields['id'] = id;

      try {
        // Send the request and get the response
        var response = await request.send();

        if (response.statusCode == 200) {
          // Audio uploaded successfully
          print('Audio uploaded successfully.');
        } else {
          // Failed to upload audio
          print('Failed to upload audio. Error: ${response.reasonPhrase}');
        }
      } catch (e) {
        // Exception occurred during the upload process
        print('Failed to upload audio. Error: $e');
      }
    }
  }

  Future<void> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, you can proceed with accessing external storage
      // For example, you can call a function to select and read audio files
      _selectAudio();
    } else if (status.isDenied) {
      // Permission denied by the user, handle accordingly
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Permission Denied',
              style: TextStyle(fontFamily: 'Poppins')),
          content: Text('Please grant permission to access external storage.',
              style: TextStyle(fontFamily: 'Poppins')),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK', style: TextStyle(fontFamily: 'Poppins')),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, open app settings to enable the permission
      _selectAudio();
    }
  }

  Future sendImage(ImageSource media) async {
    var imgg = await picker.pickImage(source: media);
    // setState(() {
    //   imageee = imgg;
    // });

    // if (imgg != null) {
    //   pic = await http.MultipartFile.fromPath("image", imgg.path);
    // }
    if (imgg != null) {
      XFile? compressedImage = await compressImage(XFile(imgg.path));

      setState(() {
        // Update your state with the compressed image
        imageee = compressedImage;
      });

      if (compressedImage != null) {
        pic = await http.MultipartFile.fromPath("image", compressedImage.path);

        // Continue with your HTTP request or other logic
      }
    }
  }

  Future<XFile?> compressImage(XFile file) async {
    final filePath = file.path;

    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, lastIndex);
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      minWidth: 1000,
      minHeight: 1000,
      quality: 70,
    );

    return compressedFile;
  }

  Future sendimage(String id) async {
    print(imageee);
    if (pic != null) {
      print(pic);
      var uri = AppString.constanturl + "updateimage";

      id = id;
      var request = http.MultipartRequest('POST', Uri.parse(uri));

      request.files.add(pic);
      request.fields['id'] = id;

      await request.send().then((result) {
        http.Response.fromStream(result).then((response) async {
          final jsondata = jsonDecode(response.body);
        });
      });
    } else {
      print('No Image selected.');
    }
  }

  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Please choose media to select',
                style: TextStyle(fontFamily: 'Poppins')),
            content: Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Color.fromARGB(
                  //         255, 150, 131, 236), // Set the button color to purple
                  //   ),
                  //   //if user click this button, user can upload image from gallery
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //     sendImage(ImageSource.gallery);
                  //   },
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.image),
                  //       Text('From Gallery'),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 10.0,
                  // ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFFFFD700), // Set the button color to purple
                    ),
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      sendImage(ImageSource.camera);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.camera, color: AppString.appgraycolor),
                        Text('From Camera',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppString.appgraycolor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget build(BuildContext context) {
    taskk = widget.task;
    admintype = widget.task;
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
              'Update Task',
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
                Navigator.pop(context);
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
          Navigator.pop(context);
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
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titlee,
                    maxLines: null,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: start_date,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.date_range),
                            labelText: 'Start Date',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey, // Change the label color here
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
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime(2100));

                            //  if (pickedDate != null) {
                            //     if (pickedDate.isAfter(DateTime.now())) {
                            //       String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                            //       start_date.text = formattedDate;
                            //     } else {
                            if (pickedDate != null) {
                              // Check if pickedDate is after the current date
                              // Extract date components without time
                              DateTime currentDateWithoutTime = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day);
                              DateTime pickedDateWithoutTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day);

                              // if (pickedDateWithoutTime.isAfter(currentDateWithoutTime) || pickedDateWithoutTime.isAtSameMomentAs(currentDateWithoutTime)) {
                              //   String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                              //   start_date.text = formattedDate;
                              // }

                              if (pickedDateWithoutTime
                                      .isAfter(currentDateWithoutTime) ||
                                  pickedDateWithoutTime.isAtSameMomentAs(
                                      currentDateWithoutTime)) {
                                DateTime pickedStartDate =
                                    pickedDate; // Assuming you have a valid pickedDate
                                DateTime pickedEndDate = pickedStartDate.add(
                                    Duration(
                                        days:
                                            1)); // Add one day to the start date

                                String formattedStartDate =
                                    DateFormat('dd-MM-yyyy')
                                        .format(pickedStartDate);
                                String formattedEndDate =
                                    DateFormat('dd-MM-yyyy')
                                        .format(pickedEndDate);

                                setState(() {
                                  start_date.text = formattedStartDate;
                                  deadline_date.text = formattedEndDate;
                                });
                              } else {
                                // Display an error message or take appropriate action
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Invalid Date',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                      content: Text(
                                          'Please select the correct date.',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('OK',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins')),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Flexible(
                        child: TextField(
                          controller:
                              start_time, //editing controller of this TextField
                          decoration: const InputDecoration(
                            icon: Icon(Icons.timer),
                            labelText: 'Start Time',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey, // Change the label color here
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
                          onTap: () async {
                            DateFormat dateFormat = DateFormat(
                                'dd-MM-yyyy'); // Format for the start date
                            DateTime selectedStartDate =
                                start_date.text.isNotEmpty
                                    ? dateFormat.parse(start_date.text)
                                    : DateTime(0);
                            DateTime now = DateTime.now();

                            if (selectedStartDate.isAfter(
                                DateTime(now.year, now.month, now.day))) {
                              TimeOfDay? pickedTime = await showTimePicker(
                                initialTime: TimeOfDay.now(),
                                context: context,
                              );

                              if (pickedTime != null) {
                                DateTime now = DateTime.now();

                                // Update the UI with the picked time
                                String formattedTime =
                                    DateFormat('HH:mm:ss').format(
                                  DateTime(now.year, now.month, now.day,
                                      pickedTime.hour, pickedTime.minute),
                                );
                                String endTimenew =
                                    DateFormat('HH:mm:ss').format(
                                  DateTime(now.year, now.month, now.day,
                                      pickedTime.hour + 1, pickedTime.minute),
                                );
                                // Delay the execution of setState
                                Future.delayed(Duration.zero, () {
                                  setState(() {
                                    start_time.text = formattedTime;
                                    end_time.text = endTimenew;
                                  });
                                });
                                //}
                              } else {
                                print("Time is not selected");
                              }
                            } else {
                              TimeOfDay? pickedTime = await showTimePicker(
                                initialTime: TimeOfDay.now(),
                                context: context,
                              );

                              if (pickedTime != null) {
                                DateTime now = DateTime.now();
                                TimeOfDay currentTimeOfDay =
                                    TimeOfDay.fromDateTime(now);

                                if (pickedTime.hour < currentTimeOfDay.hour ||
                                    (pickedTime.hour == currentTimeOfDay.hour &&
                                        pickedTime.minute <
                                            currentTimeOfDay.minute)) {
                                  // Show error dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Invalid Time',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                        content: Text(
                                            'Please select the correct time.',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('OK',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins')),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  // Update the UI with the picked time
                                  String formattedTime =
                                      DateFormat('HH:mm:ss').format(
                                    DateTime(now.year, now.month, now.day,
                                        pickedTime.hour, pickedTime.minute),
                                  );

                                  String endTimenew =
                                      DateFormat('HH:mm:ss').format(
                                    DateTime(now.year, now.month, now.day,
                                        pickedTime.hour + 1, pickedTime.minute),
                                  );
                                  // Delay the execution of setState
                                  Future.delayed(Duration.zero, () {
                                    setState(() {
                                      start_time.text = formattedTime;
                                      end_time.text = endTimenew;
                                    });
                                  });
                                }
                              } else {
                                print("Time is not selected");
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: deadline_date,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.date_range),
                            labelText: 'End Date',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey, // Change the label color here
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
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime(2100));

                            // if (pickedDate != null) {

                            if (pickedDate != null) {
                              // Extract date components without time
                              DateTime currentDateWithoutTime = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day);
                              DateTime pickedDateWithoutTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day);
                              DateTime startDate = DateFormat('dd-MM-yyyy')
                                  .parse(start_date.text);

                              if (pickedDateWithoutTime
                                      .isAfter(currentDateWithoutTime) ||
                                  pickedDateWithoutTime.isAtSameMomentAs(
                                      currentDateWithoutTime)) {
                                //String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                //     setState(() {
                                //   String formattedDate =
                                //       DateFormat('dd-MM-yyyy')
                                //           .format(pickedDate);
                                //   deadline_date.text = formattedDate;
                                // });
                                int starttimenew = int.parse(
                                    start_time.text.split(":")[0] +
                                        start_time.text.split(":")[1]);
                                int endtimenew = int.parse(
                                    end_time.text.split(":")[0] +
                                        end_time.text.split(":")[1]);

                                if (pickedDateWithoutTime.isAfter(startDate) ||
                                    (pickedDateWithoutTime
                                            .isAtSameMomentAs(startDate) &&
                                        starttimenew < endtimenew)) {
                                  setState(() {
                                    String formattedDate =
                                        DateFormat('dd-MM-yyyy')
                                            .format(pickedDate);
                                    deadline_date.text = formattedDate;
                                  });
                                } else {
                                  print("helllo1111");
                                  // Display an error message for invalid end date
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Invalid End Date',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                        content: Text(
                                            'Please select the correct date.',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('OK',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins')),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              } else {
                                // Display an error message or take appropriate action
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Invalid Date',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                      content: Text(
                                          'Please select the correct date.',
                                          style:
                                              TextStyle(fontFamily: 'Poppins')),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('OK',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins')),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            } else {}
                          },
                        ),
                      ),
                      const SizedBox(
                          width:
                              16.0), // Adjust the spacing between the text fields
                      Flexible(
                        child: TextField(
                          controller:
                              end_time, //editing controller of this TextField
                          decoration: const InputDecoration(
                            icon: Icon(Icons.timer),
                            labelText: 'End Time',
                            labelStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey, // Change the label color here
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
                          onTap: () async {
                            DateFormat dateFormat = DateFormat(
                                'dd-MM-yyyy'); // Format for the start date

                            DateTime selectedStartDate =
                                start_date.text.isNotEmpty
                                    ? dateFormat.parse(start_date.text)
                                    : DateTime(0);
                            DateTime selectedendtDate =
                                deadline_date.text.isNotEmpty
                                    ? dateFormat.parse(deadline_date.text)
                                    : DateTime(0);

                            if (selectedendtDate.isAfter(selectedStartDate)) {
                              TimeOfDay? pickedTime = await showTimePicker(
                                initialTime: TimeOfDay.now(),
                                context: context,
                              );
                              if (pickedTime != null) {
                                DateTime now = DateTime.now();

                                String formattedTime =
                                    DateFormat('HH:mm:ss').format(
                                  DateTime(now.year, now.month, now.day,
                                      pickedTime.hour, pickedTime.minute),
                                );

                                // Delay the execution of setState
                                //   // Delay the execution of setState
                                Future.delayed(Duration.zero, () {
                                  setState(() {
                                    end_time.text = formattedTime;
                                  });
                                });
                              }
                            } else {
                              TimeOfDay? pickedTime = await showTimePicker(
                                initialTime: TimeOfDay.now(),
                                context: context,
                              );
                              if (pickedTime != null) {
                                DateTime now = DateTime.now();
                                TimeOfDay currentTimeOfDay =
                                    TimeOfDay.fromDateTime(now);

                                if (pickedTime.hour < currentTimeOfDay.hour ||
                                    (pickedTime.hour == currentTimeOfDay.hour &&
                                        pickedTime.minute <
                                            currentTimeOfDay.minute)) {
                                  // Show error dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Invalid Time',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                        content: Text(
                                            'Please select the correct time.',
                                            style: TextStyle(
                                                fontFamily: 'Poppins')),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('OK',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins')),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  String formattedTime =
                                      DateFormat('HH:mm:ss').format(
                                    DateTime(now.year, now.month, now.day,
                                        pickedTime.hour, pickedTime.minute),
                                  );

                                  // Delay the execution of setState
                                  //   // Delay the execution of setState
                                  Future.delayed(Duration.zero, () {
                                    setState(() {
                                      end_time.text = formattedTime;
                                    });
                                  });
                                }
                              } else {
                                print("Time is not selected");
                              }
                            }

                            // if (pickedTime != null) {
                            // DateTime now = DateTime.now();
                            // TimeOfDay currentTimeOfDay = TimeOfDay.fromDateTime(now);

                            // if (pickedTime.hour < currentTimeOfDay.hour ||
                            //     (pickedTime.hour == currentTimeOfDay.hour && pickedTime.minute < currentTimeOfDay.minute)) {
                            //   // Show error dialog
                            //   showDialog(
                            //     context: context,
                            //     builder: (context) {
                            //       return AlertDialog(
                            //         title: Text('Invalid Time', style: TextStyle(fontFamily: 'Poppins')),
                            //         content: Text('Please select the correct time.', style: TextStyle(fontFamily: 'Poppins')),
                            //         actions: [
                            //           TextButton(
                            //             onPressed: () {
                            //               Navigator.pop(context);
                            //             },
                            //             child: Text('OK', style: TextStyle(fontFamily: 'Poppins')),
                            //           ),
                            //         ],
                            //       );
                            //     },
                            //   );
                            // }else{
                            //       DateTime parsedTime = DateFormat.jm()
                            //      .parse(pickedTime.format(context).toString());
                            //                   String formattedTime =
                            //     DateFormat('HH:mm:ss').format(parsedTime);
                            //   setState(() {
                            //   end_time.text =
                            //       formattedTime; //set the value of text field.
                            // });
                            //                 }

                            //               } else {

                            //               }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(children: [
                    const Flexible(
                      child: Text(
                        ' Select Assign  :',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                  ]),

                  const SizedBox(height: 16.0),
                  DropdownSearch<dynamic>(
                    // mode: Mode.DIALOG,
                    // label: "Select Category",
                    // showSearchBox: true,
                    //showSelectedItem: true,
                    items: stateType,
                    onChanged: (dynamic value) {
                      setState(() {
                        _selectedValue = value;
                      });
                    },
                    selectedItem: _selectedValue,
                  ),
                  const SizedBox(height: 16.0),

                  //SizedBox(height: 10.0),
                  // imageee != null
                  //     ? Padding(
                  //         padding: const EdgeInsets.symmetric(horizontal: 20),
                  //         child: ClipRRect(
                  //           borderRadius: BorderRadius.circular(8),
                  //           child: Image.file(
                  //             //to show image, you type like this.
                  //             File(imageee!.path),
                  //             fit: BoxFit.cover,
                  //             width: MediaQuery.of(context).size.width,
                  //             height: 150,
                  //           ),
                  //         ),
                  //       )
                  //     : SizedBox(height: 10),
                  // imageee != null
                  //     ? //Text(path.basename(imageee!.path))
                  //     Text(''): Text(''),
                  Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Audio  :  ',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
                        ),
                      ),
                      const SizedBox(
                          width:
                              10.0), // Adjust the spacing between the text fields
                      Flexible(
                        child: audio != ''
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(
                                      0xFFFFD700), // Set the button color to purple
                                ),
                                onPressed: () {
                                  String audioUrl = '$audiourl';
                                  playAudio(audioUrl);
                                },
                                child: Text(
                                  'Play',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13.0,
                                      color: AppString.appgraycolor),
                                ),
                              )
                            : SizedBox(),
                      ),
                      const SizedBox(
                          width:
                              5.0), // Adjust the spacing between the text fields
                      Flexible(
                        child: audio != ''
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(
                                        0xFFFFD700) // Set the button color to purple
                                    ),
                                onPressed: () {
                                  pauseAudio();
                                },
                                child: Text('Stop Audio',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13.0,
                                        color: AppString.appgraycolor)),
                              )
                            : SizedBox(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFFFFD700), // Set the button color to purple
                    ),
                    //onPressed: requestStoragePermission,
                    onPressed: () {
                      //myAudio();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditRecord(id: '$id', task: '$task'),
                        ),
                      );
                    },
                    child: const Text('Upload Audio',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppString.appgraycolor)),
                  ),
                  SizedBox(height: 16),
                  _selectedAudio != null
                      ? Text(path.basename(_selectedAudio!.path),
                          style: TextStyle(fontFamily: 'Poppins'))
                      : audioo != false && audioo != null
                          ? Text(path.basename(audioo.toString()),
                              style: TextStyle(fontFamily: 'Poppins'))
                          : const Text(''),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Image  :  ',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
                        ),
                      ),
                      const SizedBox(
                          width:
                              16.0), // Adjust the spacing between the text fields
                      Flexible(
                        child: GestureDetector(
                            onTap: () {
                              if (imageUrl != null) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Image.network(imageUrl!),
                                    );
                                  },
                                );
                              }
                            },
                            child: imageee == null
                                ? Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: imageUrl != null
                                        ? Image.network(
                                            imageUrl!,
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(
                                            Icons.image,
                                            size: 48,
                                            color: Colors.white,
                                          ))
                                : Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        //to show image, you type like this.
                                        File(imageee!.path),
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 150,
                                      ),
                                    ))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFFFFD700), // Set the button color to purple
                    ),
                    onPressed: () {
                      myAlert();
                    },
                    child: Text('Upload Photo',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppString.appgraycolor)),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xFFFFD700), // Set the button color to purple
                      ),
                      child: Text('Save',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              color: AppString.appgraycolor)),
                      onPressed: () {
                        updatedata(titlee.text, start_date.text,
                            deadline_date.text, start_time.text, end_time.text);
                        titlee.clear();
                        start_date.clear();
                        deadline_date.clear();
                        start_time.clear();
                        end_time.clear();
                        task == 'all'
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DashBoard(
                                      admin_type: admintype ??
                                          ''), // Provide a default value if admintype is null
                                ),
                              )
                            : task == 'completed'
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CompletedTask(
                                          admin_type:
                                              '$admintype'), // Provide a default value if admintype is null
                                    ),
                                  )
                                : task == 'receive'
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReceiveTask(
                                              admin_type:
                                                  '$admintype'), // Provide a default value if admintype is null
                                        ),
                                      )
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SendTask(
                                              admin_type: '$admintype'),
                                        ),
                                      );
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
