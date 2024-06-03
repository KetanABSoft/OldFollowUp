import 'dart:async';

import 'package:flutter/material.dart';
import 'package:followup/constant/conurl.dart';
import 'package:followup/widgets/list_of_notifications.dart';
import 'dashboard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/customListTile.dart';

import 'package:intl/intl.dart';

String? timer;
String? id;
String? adminttype;
String? admin_type;
String? admin;
String? cmpid;
String? selectedId;

Future<List<Data>> fetchData({String? selectedValue}) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  id = preferences.getString('id');
  // print(id);
  cmpid = preferences.getString('cmpid');
  adminttype = preferences.getString('admintype');

  String previousDateTime = preferences.getString('preferencetime') ?? "";
  print("Previous Time: $previousDateTime");

  String currentTime = preferences.getString('preferencetime') ?? "";

  var url = Uri.parse(AppString.constanturl + 'getnotifications');
  final response = await http.post(url, body: {
    "id": id,
    "cmpid": cmpid,
    "admintype": adminttype,
    "employee": selectedValue != null ? selectedValue : '',
    "date": currentTime,
  });

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    print(jsonResponse);
    return jsonResponse.map((data) => Data.fromJson(data)).toList();
  } else {
    throw Exception('Unexpected error occurred!');
  }
}

TextEditingController msg = new TextEditingController();

class Data {
  final String id;
  final String title;
  final String date;
  final String deadline;
  final String starttime;
  final String endtime;
  final String assign;
  final String created_by;
  final String assignid;
  final String status;

  Data(
      {required this.id,
      required this.title,
      required this.date,
      required this.deadline,
      required this.starttime,
      required this.endtime,
      required this.assign,
      required this.created_by,
      required this.assignid,
      required this.status});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      deadline: json['deadline'],
      starttime: json['starttime'],
      endtime: json['endtime'],
      assign: json['assign'],
      created_by: json['created_by'] ?? "",
      assignid: json['assignid'],
      status: json['status'],
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      home: NotificationScreen(admin_type: adminttype.toString())));
}

class NotificationScreen extends StatelessWidget {
  final String admin_type;

  NotificationScreen({required this.admin_type});
  // const ChatScreen({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      title: 'Follow Up',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashBoard(admin_type: admin_type),
    );
  }
}

class DashBoard extends StatefulWidget {
  final String admin_type;

  const DashBoard({Key? key, required this.admin_type}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoard();
}

class _DashBoard extends State<DashBoard> {
  List<dynamic> dropdownItems = [];
  List<Data> data = [];
  dynamic selectedValue;
  int? selectedValueId;
  Timer? timer;
  ScrollController controller = ScrollController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  var _sateMasterList;
  List<String> stateType = [];
  List<String> stateTypeid = [];
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  DateTime date = DateTime.now();

  //newdate = DateFormat('yyyy-MM-dd').format(dateTime);
  TimeOfDay time = TimeOfDay.now();

  var dropdownvalue;

  Future<void> fetchDropdownData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    userid = preferences.getString('id');
    cmpid = preferences.getString('cmpid');
    adminttype = preferences.getString('admintype');
    //String apiUrl = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=get_employee';
    String apiUrl = AppString.constanturl + 'get_employee';
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {'id': userid, 'cmpid': cmpid, 'admintype': adminttype},
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

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchDropdownData();
    selectedValue = 'Select Employee';

    fromDateController.text = DateFormat('dd-MM-yyyy').format(date);
    toDateController.text = DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
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
                'Notifications',
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
                icon: Icon(
                  Icons.arrow_back,
                  color: AppString.appgraycolor,
                ),
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
        body: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                child: Column(
                  children: [
                    Expanded(
                      child: data.isEmpty // Check if the data list is empty
                          ? FutureBuilder<List<Data>>(
                              future: fetchData(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      controller: controller,
                                      itemCount: snapshot.data!.length,
                                      padding: EdgeInsets.only(
                                          top: 10,
                                          bottom: 80,
                                          left: 15,
                                          right: 15),
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          child: CustomNotification(
                                            trailingButtonOnTap: null,
                                            id: snapshot.data![index].id,
                                            title: snapshot.data![index].title,
                                            date: snapshot.data![index].date,
                                            deadline:
                                                snapshot.data![index].deadline,
                                            starttime:
                                                snapshot.data![index].starttime,
                                            endtime:
                                                snapshot.data![index].endtime,
                                            assign:
                                                snapshot.data![index].assign,
                                            created_by: snapshot
                                                .data![index].created_by,
                                            assignid:
                                                snapshot.data![index].assignid,
                                            status:
                                                snapshot.data![index].status,
                                            admintype: '$adminttype',
                                            mainid: '$id',
                                            opacity: 1,
                                          ),
                                        );
                                      });
                                } else if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                }
                                // By default show a loading spinner.

                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            )
                          : FutureBuilder<List<Data>>(
                              future: fetchData(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      controller: controller,
                                      itemCount: data.length,
                                      padding: EdgeInsets.only(
                                          top: 10,
                                          bottom: 80,
                                          left: 15,
                                          right: 15),
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          child: CustomNotification(
                                            trailingButtonOnTap: null,
                                            id: data[index].id,
                                            title: data[index].title,
                                            date: data[index].date,
                                            deadline: data[index].deadline,
                                            starttime: data[index].starttime,
                                            endtime: data[index].endtime,
                                            assign: data[index].assign,
                                            created_by: data[index].created_by,
                                            assignid: data[index].assignid,
                                            status: data[index].status,
                                            admintype: '$adminttype',
                                            mainid: '$id',
                                            opacity: 1,
                                          ),
                                        );
                                      });
                                } else if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                }
                                // By default show a loading spinner.

                                return const Center(
                                    child: Text("No data found"));
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
