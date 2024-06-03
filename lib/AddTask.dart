import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:followup/EditTask.dart';
import 'package:followup/Recorder.dart';
import 'package:followup/constant/conurl.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'ListAll.dart';
import 'dashboard.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:followup/notification_services.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

TextEditingController title = TextEditingController();
TextEditingController startdate = TextEditingController();
TextEditingController deadlinedate = TextEditingController();
TextEditingController starttime = TextEditingController();
TextEditingController endtime = TextEditingController();
bool isButtonEnabled = false;
var pic;
String? id;
var mainid;
String? userid;
String? cmpid;
String? admintype;
String? titleaudio;
String? startdateaudio;
String? deadlinedateaudio;
String? starttimeaudio;
String? endtimeaudio;
List<dynamic>? assigntoaudio;
String? picaudio;
//String ?formattedEndDate;
String dropdowntext = 'Please select at least one assign';
Timer? _toastTimer;
var uuid = Uuid();
var uniqueId = uuid.v1();

class TaskForm extends StatelessWidget {
  final String audioPath;

  TaskForm({
    Key? key,
    required this.audioPath,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Follow Up',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AddTask(
        audioPath: audioPath,
      ),
    );
  }
}

class AddTask extends StatefulWidget {
  final String audioPath;

  const AddTask({
    Key? key,
    required this.audioPath,
  }) : super(key: key);

  @override
  _AddTaskState createState() => _AddTaskState(audioPath: audioPath);
}

class _AddTaskState extends State<AddTask> {
  String audioPath;

  _AddTaskState({required this.audioPath});
  ScrollController controller = ScrollController();
  int? randomNumber;
  // Generate a version 4 UUID

  

  void getdata() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    title.text = preferences.getString('titleaudio') ?? '';
    startdate.text = preferences.getString('startdateaudio') ?? '';
    deadlinedate.text = preferences.getString('deadlinedateaudio') ?? '';
    starttime.text = preferences.getString('starttimeaudio') ?? '';
    endtime.text = preferences.getString('endtimeaudio') ?? '';
    pic = preferences.getString('picaudio');
    String currentTime =
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";

    if (starttime.text == '') {
      setState(() {
        starttime.text = currentTime;
      });
    }
    if (endtime.text == '') {
      setState(() {
        endtime.text = currentTime;
      });
    }
    if (startdate.text == '') {
      setState(() {
        DateTime date = DateTime.now();
        startdate.text = DateFormat('dd-MM-yyyy').format(date);
      });
    }
    if (deadlinedate.text == '') {
      setState(() {
        DateTime date = DateTime.now();
        deadlinedate.text = DateFormat('dd-MM-yyyy').format(date);
      });
    }
  }

  Future<void> saveSelectedValuesToPrefs(List<dynamic> values) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> stringValues =
        values.map((value) => value.toString()).toList();
    await preferences.setStringList('selectedValues', stringValues);
  }

  Future<List<dynamic>> getSelectedValuesFromPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? stringValues = preferences.getStringList('selectedValues');
    dynamicValues = stringValues?.map((value) => value).toList() ?? [];
    return dynamicValues;
  }

  void startContinuousToast() {
    // Create a Timer that will repeatedly call showContinuousToast every 5 seconds
    _toastTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      showContinuousToast();
    });
  }

  void stopContinuousToast() {
    _toastTimer?.cancel();
  }

  void showContinuousToast() {
    // Display the toast message
    Fluttertoast.showToast(
      msg: 'Please wait while task is adding',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void initState() {
    super.initState();
    getdata();
    //generateRandomNumber();
    getSelectedValuesFromPrefs().then((values) {
      setState(() {
        selectedData = values;
      });
    });
    // String currentTime =
    //     "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";

    WidgetsBinding.instance!.addPostFrameCallback((_) {});
    fetchDropdownData();
  }

//void notification
  void savedata(String titlenew, String startdate, String deadlinedate,
      String starttime, String endtime) async {
    print('hii');
    print(titlenew);
    print(startdate);
    setState(() {
      isLoading = false; // Show loader
    });
    int num = 0;
    // DateTime currentDate = DateTime.now(); // Get the current date
    //String formattedDate = DateFormat('dd-MM-yyyy').format(currentDate); // Format the date
    if (titlenew.isEmpty || titlenew == Null) {
      num = 1;
      print('Title should be add');
      Fluttertoast.showToast(
        backgroundColor: Color.fromARGB(255, 255, 94, 0),
        textColor: Colors.white,
        msg: 'Title should be add',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else if (dynamicValues == null || dynamicValues.isEmpty) {
      if (selectedValue == null || selectedValue.isEmpty) {
        num = 1;
        // dropdowntext= 'Please select at least one assign';
        print('Please select at least one assign');
        Fluttertoast.showToast(
          backgroundColor: Color.fromARGB(255, 255, 94, 0),
          textColor: Colors.white,
          msg: 'Please select at least one assign',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } else {
      startContinuousToast();
      isButtonEnabled = true;
      num = 0;
    }

    if (num == 0) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      userid = preferences.getString('id');
      cmpid = preferences.getString('cmpid');

      admintype = preferences.getString('admintype');

      if (selectedValue == null || selectedValue!.isEmpty) {
        selectedValue = dynamicValues;
      } else {
        selectedValue = selectedValue;
      }
      String commaSeparatedString = selectedValue.join(', ');
      //var urlString = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=addtask';
      var urlString = AppString.constanturl + 'addtask';
      Uri uri = Uri.parse(urlString);

      var response = await http.post(uri, body: {
        "title": titlenew,
        "startdate": startdate,
        "deadlinedate": deadlinedate,
        "starttime": starttime,
        "endtime": endtime,
        "assign": commaSeparatedString,
        "company": cmpid,
        "createdby": userid,
        "admintype": admintype,
      });

      var jsonResponse = json.decode(response.body);
      if (jsonResponse is List) {
        // Handle the case when the response contains multiple IDs
        List<String> ids =
            jsonResponse.map((item) => item['id'].toString()).toList();
        for (int i = 0; i < ids.length; i++) {
          String id = ids[i];
          if (pic != '') {
            await sendimage([id]);
          } // Call the sendImage function with the ID
          await _uploadAudio(id);
          break;
        }

        setState(() {
          image = null;
          _selectedAudio = null;
          audio = null;
          selectedValue.clear();
          selectedValue = "";
          dynamicValues.clear;
          dynamicValues = "";
          stopContinuousToast();
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListScreen(
              admin_type: admintype.toString(),
            ),
          ),
        );
        setState(() {
          isButtonEnabled = false;
          isLoading = false; // Hide loader after the operation is done
        });
        Fluttertoast.showToast(
          backgroundColor: const Color.fromARGB(255, 0, 255, 55),
          textColor: Colors.white,
          msg: 'Task Added Successfully',
          toastLength: Toast.LENGTH_SHORT,
        );
        //stopContinuousToast();

        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.remove('titleaudio');
        preferences.remove('startdateaudio');
        preferences.remove('deadlinedateaudio');
        preferences.remove('starttimeaudio');
        preferences.remove('endtimeaudio');
        preferences.remove('picaudio');
        preferences.remove('assigntoaudio');
        preferences.remove('selectedValues');
      } else if (jsonResponse is Map) {
        // Handle the case when the response contains a single ID
        String idAsString = jsonResponse['id'].toString();
        int id = int.tryParse(idAsString) ?? 0;
        print('map'); // Provide a default value if parsing fails
      } else {
        print('Invalid JSON response');
      }
    } else {}
  }

  GlobalKey<FormFieldState<dynamic>> dropdown1Key =
      GlobalKey<FormFieldState<dynamic>>();
  XFile? image;
  final ImagePicker picker = ImagePicker();
  dynamic selectedValue;
  dynamic dynamicValues;
  File? _selectedAudio = null;
  bool isLoading = false;
  List<dynamic> dropdownData = [];
  List<dynamic> selectedData = [];

  // Future<void> requestStoragePermission() async {
  //   PermissionStatus status = await Permission.storage.request();

  //    if (await Permission.storage.request().isGranted) {
  //     // Permission granted, you can proceed with accessing external storage
  //     // For example, you can call a function to select and read audio files
  //     _selectAudio();
  //   } else if (await Permission.storage.request().isPermanentlyDenied) {

  //   openAppSettings();
  //       } else {
  //         // The storage permission is denied, but not permanently
  //         // You can show an explanation dialog and request the permission again
  //         // Or you can choose to proceed without the permission
  //       }

  // }

  Future<void> requestStoragePermission() async {
    PermissionStatus status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      print(' 1st denied');
      // Permission granted, you can proceed with accessing both external and internal storage
      _selectAudio();
    } else if (status.isDenied) {
      print(' 2nd denied');
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
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      // Permission permanently denied or restricted, open app settings to enable the permission
      _selectAudio();
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) => AlertDialog(
      //     title: Text('Permission Denied'),
      //     content: Text('Please open app settings and enable storage permission manually.'),
      //     actions: <Widget>[
      //       ElevatedButton(
      //         child: Text('OK'),
      //         onPressed: () {
      //           Navigator.of(context).pop();
      //           openAppSettings();
      //         },
      //       ),
      //     ],
      //   ),
      // );
    }
  }

  Future<void> sendimage(List<String> ids) async {
    if (image != null) {
      print(image!.path);
      // var uri = Uri.parse("http://testfollowup.absoftwaresolution.in/getlist.php?Type=addimage");
      var uri = Uri.parse(AppString.constanturl + "addimage");

      for (var id in ids) {
        // print('iddddd: $id');
        print(uniqueId);
        var newuniq = uuid.v1();
        var request = http.MultipartRequest('POST', uri);

        var multipartFile = await http.MultipartFile.fromPath(
            'image', image!.path,
            filename: '${newuniq}_image.jpg');

        request.files.add(multipartFile);
        request.fields['id'] = id;

        await request.send().then((result) {
          http.Response.fromStream(result).then((response) async {
            final jsonData = jsonDecode(response.body);
            // Handle the response data as needed
          });
        });
      }
    } else {
      print('No Image selected.');
    }
  }

  //we can upload image from camera or from gallery based on parameter
  Future sendImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    // if (mounted) {
    //   // Check if the widget is still mounted
    //   setState(() {
    //     image = img;
    //   });
    // }

    // if (img != null) {
    //   pic = await http.MultipartFile.fromPath("image", img.path);

    // }

    if (img != null) {
      XFile? compressedImage = await compressImage(XFile(img.path));

      setState(() {
        // Update your state with the compressed image
        image = compressedImage;
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
    print('_selectedAudio' + audioPath);
    String filePath = audioPath; // Replace with the actual file path
    File file = File(filePath);

    if (file.existsSync()) {
      int fileSizeInBytes = file.lengthSync();
      double fileSizeInKB = fileSizeInBytes / 1024; // Convert bytes to KB

      print('File Size: ${fileSizeInKB.toStringAsFixed(2)} KB');
    } else {
      print('File does not exist.');
    }
    if (_selectedAudio != null) {
      id = id;
      //final url = Uri.parse('http://testfollowup.absoftwaresolution.in/getlist.php?Type=addaudio');
      final url = Uri.parse(AppString.constanturl + 'addaudio');
      var request = http.MultipartRequest('POST', url);
      request.files.add(
          await http.MultipartFile.fromPath('audio', _selectedAudio!.path));
      request.fields['id'] = id;
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Audio uploaded successfully.');
      } else {
        print('Failed to upload audio. Error: ${response.reasonPhrase}');
      }
    } else if (audioPath != null) {
      final url = Uri.parse(AppString.constanturl + 'addaudio');
      var request = http.MultipartRequest('POST', url);

      // Open the audio file
      var file = File(audioPath);
      if (await file.exists()) {
        // Create a new MultipartFile from the audio file
        var audio = await http.MultipartFile.fromPath('audio', file.path);

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
      } else {
        // Audio file does not exist
        print('Audio file not found.');
      }
    } else {
      print('No audio file selected.');
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

  void myAudio() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text('Please choose media to select',
              style: TextStyle(fontFamily: 'Poppins')),
          content: Container(
            height: MediaQuery.of(context).size.height / 6,
            child: Column(
              children: [
                // ElevatedButton(
                //   onPressed:()=>{
                //     requestStoragePermission(),
                //   Navigator.of(context).pop()},

                //   child: Row(
                //     children: [
                //       Icon(Icons.audio_file),
                //       Text('From Files'),
                //     ],
                //   ),
                // ),
                ElevatedButton(
                  onPressed: () {
                    // Handle audio recording
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyApp(
                          title: title.text,
                          startdate: startdate.text,
                          deadlinedate: deadlinedate.text,
                          starttime: starttime.text,
                          endtime: endtime.text,
                          image: image.toString(),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.record_voice_over),
                      Text('Recorder', style: TextStyle(fontFamily: 'Poppins')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //we can upload image from camera or from gallery based on parameter

  //we can upload image from camera or from gallery based on parameter

  DateTime date = DateTime.now();

  //newdate = DateFormat('yyyy-MM-dd').format(dateTime);
  TimeOfDay time = TimeOfDay.now();

  TextEditingController startdate = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var dropdownvalue;
  @override
  void dispose() {
    // _timer?.cancel();

    super.dispose();
  }

  Future<void> fetchDropdownData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userid = preferences.getString('id');
    cmpid = preferences.getString('cmpid');
    admintype = preferences.getString('admintype');
    //String apiUrl = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=get_employee';
    String apiUrl = AppString.constanturl + 'get_employee';
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {'id': userid, 'cmpid': cmpid, 'admintype': admintype},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        dropdownData = json.decode(response.body);
      });
    } else {
      print(
          'Error fetching dropdown data. Status code: ${response.statusCode}');
    }
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Widget MyLoaderWidget() {
    return Center(
      child: CircularProgressIndicator(), // or your preferred loader widget
    );
  }

  @override
  Widget build(BuildContext context) {
    String audioPath = widget.audioPath;
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
              'Add Task',
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
          padding: const EdgeInsets.all(8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: title,
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
                            decoration: const InputDecoration(
                              icon: Icon(Icons.date_range),
                              labelText: 'Start Date',
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
                            controller: startdate,
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                DateTime currentDateWithoutTime = DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day);
                                DateTime pickedDateWithoutTime = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day);

                                if (pickedDateWithoutTime
                                        .isAfter(currentDateWithoutTime) ||
                                    pickedDateWithoutTime.isAtSameMomentAs(
                                        currentDateWithoutTime)) {
                                  DateTime pickedStartDate = pickedDate;

                                  DateTime pickedEndDate = pickedStartDate;

                                  String formattedStartDate =
                                      DateFormat('dd-MM-yyyy')
                                          .format(pickedStartDate);

                                  String formattedEndDate =
                                      DateFormat('dd-MM-yyyy')
                                          .format(pickedEndDate);

                                  DateTime pickedEndDate2 =
                                      DateFormat('dd-MM-yyyy')
                                          .parse(deadlinedate.text);

                                  if (pickedEndDate2.isAfter(pickedStartDate)) {
                                    setState(() {
                                      startdate.text = DateFormat('dd-MM-yyyy')
                                          .format(pickedStartDate);
                                      deadlinedate.text =
                                          DateFormat('dd-MM-yyyy')
                                              .format(pickedEndDate2);
                                    });
                                  } else {
                                    setState(() {
                                      startdate.text = formattedStartDate;
                                      deadlinedate.text =
                                          formattedEndDate.toString();
                                    });
                                  }
                                } else {
                                  // Display an error message or take appropriate action
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Invalid Date',
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
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Flexible(
                          child: TextField(
                            controller: starttime,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.timer),
                              labelText: 'Start Time',
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
                            readOnly: true,
                            onTap: () async {
                              DateTime now = DateTime.now();
                              print("iwontcorrecttime");

                              DateFormat dateFormat = DateFormat(
                                  'dd-MM-yyyy'); // Format for the start date

                              DateTime selectedStartDate =
                                  startdate.text.isNotEmpty
                                      ? dateFormat.parse(startdate.text)
                                      : DateTime(0);
                              print(selectedStartDate);
                              print(DateTime(now.year, now.month, now.day));
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
                                      starttime.text = formattedTime;
                                      endtime.text = endTimenew;
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
                                      (pickedTime.hour ==
                                              currentTimeOfDay.hour &&
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
                                      DateTime(
                                          now.year,
                                          now.month,
                                          now.day,
                                          pickedTime.hour + 1,
                                          pickedTime.minute),
                                    );
                                    // Delay the execution of setState
                                    Future.delayed(Duration.zero, () {
                                      setState(() {
                                        starttime.text = formattedTime;
                                        endtime.text = endTimenew;
                                      });
                                    });
                                  }
                                } else {
                                  print("Time is not selected");
                                }
                              }
                            },
                          ),
                        )
                        // Flexible(
                        //   child: TextField(
                        //     controller: starttime,
                        //     decoration: const InputDecoration(
                        //       icon: Icon(Icons.timer),
                        //       labelText: 'Start Time',
                        //       labelStyle: TextStyle(
                        //         fontFamily: 'Poppins',
                        //         color: Colors.grey,
                        //       ),
                        //       enabledBorder: UnderlineInputBorder(
                        //         borderSide: BorderSide(color: Colors.grey),
                        //       ),
                        //       focusedBorder: UnderlineInputBorder(
                        //         borderSide: BorderSide(color: Colors.blue),
                        //       ),
                        //     ),
                        //     readOnly: true,
                        //     onTap: () async {
                        //       TimeOfDay? pickedTime = await showTimePicker(
                        //         initialTime: TimeOfDay.now(),
                        //         context: context,
                        //       );

                        //      if (pickedTime != null) {
                        //       DateTime now = DateTime.now();
                        //       TimeOfDay currentTimeOfDay = TimeOfDay.fromDateTime(now);

                        //       if (pickedTime.hour < currentTimeOfDay.hour ||
                        //           (pickedTime.hour == currentTimeOfDay.hour && pickedTime.minute < currentTimeOfDay.minute)) {
                        //         // Show error dialog
                        //         showDialog(
                        //           context: context,
                        //           builder: (context) {
                        //             return AlertDialog(
                        //               title: Text('Invalid Time', style: TextStyle(fontFamily: 'Poppins')),
                        //               content: Text('Please select the correct time.', style: TextStyle(fontFamily: 'Poppins')),
                        //               actions: [
                        //                 TextButton(
                        //                   onPressed: () {
                        //                     Navigator.pop(context);
                        //                   },
                        //                   child: Text('OK', style: TextStyle(fontFamily: 'Poppins')),
                        //                 ),
                        //               ],
                        //             );
                        //           },
                        //         );
                        //       } else {
                        //         // Update the UI with the picked time
                        //         String formattedTime = DateFormat('HH:mm:ss').format(
                        //           DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
                        //         );

                        //         // Delay the execution of setState
                        //         Future.delayed(Duration.zero, () {
                        //           setState(() {
                        //             starttime.text = formattedTime;
                        //           });
                        //         });
                        //       }
                        //     } else {
                        //       print("Time is not selected");
                        //     }

                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Flexible(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.date_range),
                              labelText: 'End Date',
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
                            controller: deadlinedate,
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime(2100),
                              );

                              if (pickedDate != null) {
                                DateTime currentDateWithoutTime = DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day);
                                DateTime pickedDateWithoutTime = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day);
                                DateTime startDate = DateFormat('dd-MM-yyyy')
                                    .parse(startdate.text);
                                print(DateFormat('HH:mm:ss')
                                    .format(DateTime.now()));

                                // Check if pickedDate is after the curformattedTimerent date
                                if (pickedDateWithoutTime
                                        .isAfter(currentDateWithoutTime) ||
                                    pickedDateWithoutTime.isAtSameMomentAs(
                                        currentDateWithoutTime)) {
                                  // DateTime starttimenew=DateTime(int.parse(starttime.text));
                                  int starttimenew = int.parse(
                                      starttime.text.split(":")[0] +
                                          starttime.text.split(":")[1]);
                                  int endtimenew = int.parse(
                                      endtime.text.split(":")[0] +
                                          endtime.text.split(":")[1]);

                                  // DateTime endtimenew=DateTime(int.parse(endtime.text));

                                  DateTime now = DateTime.now();

                                  // Check if picked end date is after or equal to start date
                                  if (pickedDateWithoutTime
                                          .isAfter(startDate) ||
                                      (pickedDateWithoutTime
                                              .isAtSameMomentAs(startDate) &&
                                          starttimenew <= endtimenew)) {
                                    setState(() {
                                      String formattedDate =
                                          DateFormat('dd-MM-yyyy')
                                              .format(pickedDate);
                                      deadlinedate.text = formattedDate;
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
                                              'End date time should be grater than start date time. Please select the correct date.',
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
                                  print("helllo666");
                                  // Display an error message for invalid date
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Invalid Date',
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
                              }
                            },
                          ),
                        ),

                        //                 Flexible(
                        //                   child: TextFormField(
                        //                     decoration: const InputDecoration(
                        //                       icon: Icon(Icons.date_range),
                        //                       labelText: 'End Date',
                        //                       labelStyle: TextStyle(
                        //                         fontFamily: 'Poppins',
                        //                         color: Colors.grey,
                        //                       ),
                        //                       enabledBorder: UnderlineInputBorder(
                        //                         borderSide: BorderSide(color: Colors.grey),
                        //                       ),
                        //                       focusedBorder: UnderlineInputBorder(
                        //                         borderSide: BorderSide(color: Colors.blue),
                        //                       ),
                        //                     ),
                        //                     controller: deadlinedate,
                        //                     readOnly: true,
                        //                     onTap: () async {
                        //                       DateTime? pickedDate = await showDatePicker(
                        //                         context: context,
                        //                         initialDate: DateTime.now(),
                        //                         firstDate: DateTime(1950),
                        //                         lastDate: DateTime(2100),
                        //                       );

                        //                        if (pickedDate != null) {
                        // // Check if pickedDate is after the current date

                        //               // Extract date components without time
                        //               DateTime currentDateWithoutTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                        //               DateTime pickedDateWithoutTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);

                        //               if (pickedDateWithoutTime.isAfter(currentDateWithoutTime) || pickedDateWithoutTime.isAtSameMomentAs(currentDateWithoutTime)) {
                        //                                                 //String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                        //                             setState(() {
                        //                           String formattedDate =
                        //                               DateFormat('dd-MM-yyyy')
                        //                                   .format(pickedDate);
                        //                           deadlinedate.text = formattedDate;
                        //                         });
                        //                         } else {
                        //                           // Display an error message or take appropriate action
                        //                           showDialog(
                        //                             context: context,
                        //                             builder: (context) {
                        //                               return AlertDialog(
                        //                                 title: Text('Invalid Date',style: TextStyle(fontFamily: 'Poppins')),
                        //                                 content: Text('Please select the correct date.',style: TextStyle(fontFamily: 'Poppins')),
                        //                                 actions: [
                        //                                   TextButton(
                        //                                     onPressed: () {
                        //                                       Navigator.pop(context);
                        //                                     },
                        //                                     child: Text('OK',style: TextStyle(fontFamily: 'Poppins')),
                        //                                   ),
                        //                                 ],
                        //                               );
                        //                             },
                        //                           );
                        //                         }
                        //                       } else {}
                        //                     },
                        //                   ),
                        //                 ),
                        const SizedBox(width: 16.0),
                        Flexible(
                          child: TextField(
                            controller: endtime,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.timer),
                              labelText: 'End Time',
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
                            readOnly: true,
                            onTap: () async {
                              // TimeOfDay? pickedTime = await showTimePicker(
                              //   initialTime: TimeOfDay.now(),
                              //   context: context,
                              // );

                              DateTime now = DateTime.now();
                              DateFormat dateFormat = DateFormat(
                                  'dd-MM-yyyy'); // Format for the start date

                              DateTime selectedStartDate =
                                  startdate.text.isNotEmpty
                                      ? dateFormat.parse(startdate.text)
                                      : DateTime(0);
                              DateTime selectedendtDate =
                                  deadlinedate.text.isNotEmpty
                                      ? dateFormat.parse(deadlinedate.text)
                                      : DateTime(0);
                              print("justcheck");
                              print(selectedStartDate);
                              print(selectedendtDate);
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
                                  //    Future.delayed(Duration.zero, () {
                                  setState(() {
                                    endtime.text = formattedTime;
                                  });
                                  //  });
                                }
                              } else {
                                TimeOfDay? pickedTime = await showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                );
                                if (pickedTime != null) {
                                  DateTime currentDateWithoutTime = DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day);

                                  DateTime now = DateTime.now();
                                  TimeOfDay currentTimeOfDay =
                                      TimeOfDay.fromDateTime(now);
                                  print(currentDateWithoutTime);
                                  DateTime selectedendtDate =
                                      deadlinedate.text.isNotEmpty
                                          ? dateFormat.parse(deadlinedate.text)
                                          : DateTime(0);

                                  if ((pickedTime.hour <
                                          currentTimeOfDay.hour ||
                                      (pickedTime.hour ==
                                              currentTimeOfDay.hour &&
                                          pickedTime.minute <
                                              currentTimeOfDay.minute))) {
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
                                        endtime.text = formattedTime;
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
                    SizedBox(height: 16.0),
                    MultiSelectDialogField(
                      items: dropdownData
                          .map((item) =>
                              MultiSelectItem(item['id'], item['firstname']))
                          .toList(),
                      initialValue: selectedData,
                      onConfirm: (values) {
                        setState(() {
                          selectedValue = values;
                        });
                        saveSelectedValuesToPrefs(selectedValue);
                      },
                      title: const Text(
                        'Select Assign',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                        ),
                      ),
                      buttonText: Text('Select Assign',
                          style: TextStyle(fontFamily: 'Poppins')),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        const SizedBox(width: 16.0),
                        Flexible(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFD700),
                            ),
                            onPressed: () {
                              //myAudio();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyApp(
                                    title: title.text,
                                    startdate: startdate.text,
                                    deadlinedate: deadlinedate.text,
                                    starttime: starttime.text,
                                    endtime: endtime.text,
                                    image: image.toString(),
                                  ),
                                ),
                              );
                            },
                            child: const Text('Upload Audio',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppString.appgraycolor,
                                )),
                          ),
                        ),
                        const SizedBox(width: 36.0),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () {
                              myAlert();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFD700),
                            ),
                            child: Text('Upload Photo',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppString.appgraycolor,
                                )),
                          ),
                        ),
                      ],
                    ),
                    _selectedAudio != null
                        ? Text(path.basename(_selectedAudio!.path),
                            style: TextStyle(fontFamily: 'Poppins'))
                        : audioPath != false && audioPath != AppString.audiourl
                            ? Text(path.basename(audioPath.toString()),
                                style: TextStyle(fontFamily: 'Poppins'))
                            : const Text(''),
                    const SizedBox(height: 16.0),
                    image != null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(image!.path),
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                height: 150,
                              ),
                            ),
                          )
                        : const SizedBox(
                            height: 10,
                          ),
                    image != null
                        ? //Text(path.basename(image!.path),style: TextStyle(fontFamily: 'Poppins'))
                        Text('')
                        : const Text(''),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD700),
                      ),
                      // onPressed: isLoading
                      //     ? null
                      //     : () {

                      //             savedata(
                      //           title.text,
                      //           startdate.text,
                      //           deadlinedate.text,
                      //           starttime.text,
                      //           endtime.text,
                      //         );

                      //       },
                      onPressed: isButtonEnabled
                          ? null
                          : () {
                              savedata(
                                title.text,
                                startdate.text,
                                deadlinedate.text,
                                starttime.text,
                                endtime.text,
                              );
                            },

                      child: isLoading
                          ? CircularProgressIndicator() // Show loader when isLoading is true
                          : Text('Save',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppString.appgraycolor,
                              )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TaskTextField extends StatelessWidget {
  final String hintText;
  final BorderRadius borderRadius;

  const TaskTextField({
    required this.hintText,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }
}

// void main() {
//   runApp(MaterialApp(
//       home: TaskForm(
//     audioPath: AppString.audiourl,
//   )));
// }
