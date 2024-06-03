//  import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:followup/EditTask.dart';
import 'package:followup/ListAll.dart';
import 'package:followup/Remark.dart';
import 'package:followup/ViewTask.dart';
import 'package:followup/viewNotification.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:followup/constant/conurl.dart';
// import 'package:followup/EditTask.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

String? admintype;
String? mainid;

void deletedata(String id) async {
  print(id);
  //var urlString = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=deletetask';
  var urlString = AppString.constanturl + 'deletetask';
  Uri uri = Uri.parse(urlString);
  var response = await http.post(uri, body: {"id": id});
  var jsondata = jsonDecode(response.body);
  print(jsondata);
  if (jsondata['success'] == "success") {
    Fluttertoast.showToast(
      backgroundColor: Color.fromARGB(255, 0, 255, 55),
      textColor: Colors.white,
      msg: jsondata['message'],
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}

void completetask(String id) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  admintype = preferences.getString('admintype');
  mainid = preferences.getString('id');
  print(admintype);
  print('mainid');
  //var urlString = 'http://testfollowup.absoftwaresolution.in/getlist.php?Type=completetask';
  var urlString = AppString.constanturl + 'completetask';
  Uri uri = Uri.parse(urlString);
  var response = await http
      .post(uri, body: {"id": id, "mainid": mainid, "admintype": admintype});
  var jsondata = jsonDecode(response.body);
  print(jsondata);
  if (jsondata['success'] == "success") {
    Fluttertoast.showToast(
      backgroundColor: Color.fromARGB(255, 0, 255, 55),
      textColor: Colors.white,
      msg: jsondata['message'],
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}

class CustomNotification extends StatelessWidget {
  final String? id;
  final String? title;
  final String? date;
  final String? deadline;
  final String? starttime;
  final String? endtime;
  final String? assign;
  final String? created_by;
  final String? assignid;
  final String? admintype;
  final String? mainid;
  final String? status;
  final Function? trailingButtonOnTap;
  final double opacity;

  const CustomNotification({
    Key? key,
    required this.id,
    required this.title,
    required this.date,
    required this.deadline,
    required this.starttime,
    required this.endtime,
    required this.assign,
    required this.created_by,
    required this.assignid,
    required this.admintype,
    required this.mainid,
    required this.status,
    required this.trailingButtonOnTap,
    required this.opacity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //String? id = "";
    ScrollController controller = ScrollController();
    return InkWell(
      onTap: () async {
        var urlString = AppString.constanturl + 'viewed_notification';
        Uri uri = Uri.parse(urlString);
        var response = await http.post(uri, body: {"id": id});
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Viewnotification(id: '$id')),
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Opacity(
          opacity: opacity,
          // child: Padding(
          //   padding: EdgeInsets.all(16.0),
          child: Column(children: [
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 77, 77, 174),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0), // Adjust the radii as needed
                  topRight: Radius.circular(10.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  color: Color.fromARGB(255, 77, 77, 174),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${created_by}',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Container(
                        width: 120,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Text(
                              '${date} ${starttime}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Assigned a task to  ${assign}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Task - ${title}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
