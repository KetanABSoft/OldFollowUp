import 'package:flutter/material.dart';
import 'package:followup/constant/conurl.dart';
import 'package:followup/create_lead.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeadList extends StatefulWidget {
  const LeadList({super.key});

  @override
  State<LeadList> createState() => _LeadListState();
}

class fetchlead {
  final String? id;
  final String? customer_name;
  final String? company_name;
  final String? mobile;
  final String? mail;
  final String? date;

  fetchlead(
      {required this.id,
      required this.customer_name,
      required this.company_name,
      required this.mobile,
      required this.mail,
      required this.date});

  factory fetchlead.fromJson(Map<String, dynamic> json) {
    return fetchlead(
      id: json['id'],
      customer_name: json['customer_name'],
      company_name: json['company_name'],
      mobile: json['contact_no'],
      mail: json['mail_id'],
      date: json['date'],
    );
  }
}

class _LeadListState extends State<LeadList> {
  List<fetchlead> leads = [];
  ScrollController controller = ScrollController();
  bool isDeleteAlertOpen = false;

  @override
  void initState() {
    fetchleads();
    super.initState();
  }

  String? id;
  String? cmpid;
  String? adminttype;

  Future<void> fetchleads() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id');
    cmpid = preferences.getString('cmpid');
    adminttype = preferences.getString('admintype');

    var url = Uri.parse(AppString.constanturl + 'list_of_leads');
    final response = await http.post(url, body: {
      "id": id,
      "cmpid": cmpid,
      "admintype": adminttype,
    });

    // final response =
    // await http.get(Uri.parse(AppString.constanturl + 'list_of_leads'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List<fetchlead> items = [];

      if (jsonData is List) {
        for (var item in jsonData) {
          items.add(fetchlead.fromJson(item));
        }
      } else if (jsonData is Map<String, dynamic>) {
        items.add(fetchlead.fromJson(jsonData));
      }

      setState(() {
        leads = items;
      });
    } else {}
  }

  void deleteLead(id) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        isDeleteAlertOpen = true;
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop(false);
          },
          child: AlertDialog(
            content: Text("Are you sure you want to delete this lead?"),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFD700),
                ),
                child: Text("Cancel",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppString.appgraycolor,
                    )),
                onPressed: () {
                  Navigator.of(context)
                      .pop(false); // Return false to indicate cancellation
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFD700),
                ),
                child: Text("Delete",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppString.appgraycolor,
                    )),
                onPressed: () {
                  Navigator.of(context)
                      .pop(true); // Return true to indicate confirmation
                },
              ),
            ],
          ),
        );
      },
    );

    if (confirmed ?? false) {
      var urlString = AppString.constanturl + 'delete_lead';
      Uri uri = Uri.parse(urlString);
      var response = await http.post(uri, body: {"id": id});
      var jsondata = jsonDecode(response.body);

      if (jsondata['success'] == "success") {
        Fluttertoast.showToast(
          backgroundColor: Color.fromARGB(255, 0, 255, 55),
          textColor: Colors.white,
          msg: jsondata['message'],
          toastLength: Toast.LENGTH_SHORT,
        );
      }
      fetchleads();
    } else {
      isDeleteAlertOpen = false;
    }
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
                'Lead List',
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
                      builder: (context) => LeadForm(id: '0', task: ''),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        body: Builder(builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async {
                if (isDeleteAlertOpen) {
                  Navigator.of(context).maybePop();
                  return false;
                } else {
                  Navigator.of(context).pop();
                  return true;
                }
              },
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ListView.builder(
                      controller: controller,
                      shrinkWrap: true,
                      itemCount: leads.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LeadForm(
                                    id: '${leads[index].id ?? ''}',
                                    task: 'view',
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 14,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 45,
                                    color: Color.fromARGB(255, 77, 77, 174),
                                    padding: EdgeInsets.only(
                                        top: 1, left: 10, bottom: 2),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${leads[index].customer_name ?? ''}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Spacer(), // This spacer will push the buttons to the right
                                        IconButton(
                                          icon: Icon(Icons.visibility),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => LeadForm(
                                                  id: '${leads[index].id ?? ''}',
                                                  task: 'view',
                                                ),
                                              ),
                                            );
                                          },
                                          color: Colors.white,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => LeadForm(
                                                  id: '${leads[index].id ?? ''}',
                                                  task: 'edit',
                                                ),
                                              ),
                                            );
                                          },
                                          color: Colors.white,
                                        ),

                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            deleteLead(
                                                '${leads[index].id ?? ''}');
                                          },
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Opacity(
                                    opacity: 1,
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start, // Align children to the left
                                                children: [
                                                  Text(
                                                    '${leads[index].company_name ?? ''}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                                child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .end, // Align children to the left
                                              children: [
                                                Text(
                                                  '${leads[index].mobile ?? ''}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            )),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start, // Align children to the left
                                                children: [
                                                  Text(
                                                    '${leads[index].mail ?? ''}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                                child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .end, // Align children to the left
                                              children: [
                                                Text(
                                                  '${leads[index].date ?? ''}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            )),
                                          ],
                                        ),
                                      ]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ));
        }));
  }
}
