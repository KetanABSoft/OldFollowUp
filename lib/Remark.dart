import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:followup/constant/conurl.dart';
import 'package:followup/widgets/CustomListRemark.dart';

import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:followup/ListAll.dart';

import 'dashboard.dart';

TextEditingController remark = new TextEditingController();
String? userid;
String? cmpid;
String? admintype;
String? idemp;
ScrollController controller = ScrollController();
class Remarkdatanew {
  final String name;
  final String date;
  final String time;
  final String remark;

  Remarkdatanew(
      {required this.name,
      required this.date,
      required this.time,
      required this.remark,});

  factory Remarkdatanew.fromJson(Map<String, dynamic> json) {
    return Remarkdatanew(
      name: json['name'],
      date: json['date'],
      time: json['time'],
      remark: json['remark']
    );
  }
}

class Remark extends StatefulWidget {
  final String id;
  Remark({required this.id});

  @override
  State<Remark> createState() => _RemarkState();
}

class _RemarkState extends State<Remark> {
 
  List<Remarkdatanew> remarkk = [];
  dynamic selectedValue;
  int? selectedValueId;
  ScrollController controller = ScrollController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  var _sateMasterList;
  List<String> stateType = [];
  List<String> stateTypeid = [];
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  DateTime date = DateTime.now();
  @override
  void initState() {
    super.initState();
    getremark(widget.id);
    print(widget.id);
    print('widget.id');
    id = widget.id;
  }
 @override
  

  String? id;

  Future<void> getremark(String id) async {
     SharedPreferences preferences = await SharedPreferences.getInstance();
     admintype = preferences.getString('admintype');
  var urlString = AppString.constanturl + 'getlistremark';
  Uri uri = Uri.parse(urlString);
  var response = await http.post(uri, body: {
    "taskid": id,
    "admintype":admintype
  });

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    if (jsonData != null && jsonData.isNotEmpty) {
    List<Remarkdatanew> dataa = [];

    for (var item in jsonData.values) { // Access values of the map
      dataa.add(Remarkdatanew.fromJson(item));
    }

    setState(() {
      remarkk = dataa;
    });
    }
  } else {
    // Handle API error
  }
}

  void savedata(String remark) async {
    if(remark.isEmpty || remark==Null)  {
    Fluttertoast.showToast(
            backgroundColor: Color.fromARGB(255, 255, 94, 0),
            textColor: Colors.white,
            msg: 'Remark should be added.',
            toastLength: Toast.LENGTH_SHORT,
          );

    }else{
              SharedPreferences preferences = await SharedPreferences.getInstance();
              userid = preferences.getString('id');
              cmpid = preferences.getString('cmpid');
              admintype = preferences.getString('admintype');
              idemp = preferences.getString('idemp');

              print(idemp);
              print('idemp');
              var urlString = AppString.constanturl + 'addremark';
              Uri uri = Uri.parse(urlString);
              var response = await http.post(uri, body: {
                "id": '$id',
                "remark": remark,
                "userid": userid,
                "cmpid": cmpid,
                "admintype": admintype,
                "idemp": idemp,
              });
              var jsondata = jsonDecode(response.body);
              print(jsondata);
              if (jsondata['success'] == "success") {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  backgroundColor: Color.fromARGB(255, 0, 255, 55),
                  textColor: Colors.white,
                  msg: jsondata['message'],
                  toastLength: Toast.LENGTH_SHORT,
                );
              }
    }
    
  }

  final _formKey = GlobalKey<FormState>();

 

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD700),
        title: Text(
          'Add Remark',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
           color:AppString.appgraycolor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color:AppString.appgraycolor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
         floatingActionButton: FloatingActionButton(
      onPressed: () {
       
               Navigator.pop(context);
      },
      child: Icon(Icons.arrow_back,color:AppString.appgraycolor), // Change the icon as needed
      backgroundColor: Color(0xFFFFD700), // Change the color as needed
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Adjust the position as needed

      body:  Stack(
          children: <Widget>[
            
            Align(
              child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                child: Column(
                  children: [
                   TextFormField(
                  controller: remark,
                  decoration: const InputDecoration(
                    labelText: 'Remark',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.black,
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
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFD700),
              ),
                  child: Text('Save',style: TextStyle(fontFamily: 'Poppins',color:AppString.appgraycolor)),
                  onPressed: () {
                    savedata(remark.text);
                    remark.clear();
                     
                  },
                ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: ListView.builder(
                            shrinkWrap: true,
                            controller: controller,
                            itemCount: remarkk.length,
                            itemBuilder: (context, int index) {
                              final Remarkdatanew item = remarkk[index];

                              return GestureDetector(
                                child: CustomListRemark(
                                  trailingButtonOnTap: null,
                                  name: item.name,
                                  date: item.date,
                                  time: item.time,
                                  remark: item.remark,
                                  opacity: 1,
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ),
          ],
        ),
    );
  }
}

