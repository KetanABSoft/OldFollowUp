import 'package:flutter/material.dart';
import 'package:followup/Lead_list.dart';
import 'package:followup/constant/conurl.dart';
import 'package:followup/dashboard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LeadForm extends StatefulWidget {
  final String? id;
  final String? task;

  LeadForm({required this.id, required this.task});

  @override
  State<LeadForm> createState() => _LeadFormState();
}

File? _selectedImage = null;
final picker = ImagePicker();

class _LeadFormState extends State<LeadForm> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController CustomerName = TextEditingController();
  TextEditingController CompanyName = TextEditingController();
  TextEditingController ContactNo = TextEditingController();
  TextEditingController MailId = TextEditingController();
  TextEditingController Website = TextEditingController();
  TextEditingController Description = TextEditingController();
  TextEditingController OwnerName = TextEditingController();

  LocationData? currentLocation;
  String? leadImageUrl = null;
  String? imageUrl = null;

  @override
  void initState() {
    getLocation();
    getlead(widget.id);
    super.initState();
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
                  //   onPressed: () {
                  //     _selectImageFromGallery();
                  //     Navigator.pop(context);
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
                      backgroundColor: Color(0xFFFFD700),
                    ),
                    onPressed: () {
                      _captureImage();
                      Navigator.pop(context);
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

  Future<void> _selectImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        imageUrl = null;
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        imageUrl = null;
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  // Widget _buildSelectedImage() {
  //   if (_selectedImage != null || imageUrl != null) {
  //     return imageUrl != null
  //         ? Image.network(imageUrl!)
  //         : Image.file(_selectedImage!);
  //   } else {
  //     return SizedBox();
  //   }
  // }

  Widget _buildSelectedImage() {
    if (_selectedImage != null || imageUrl != null) {
      return Container(
        height: 150, // Set the desired height here
        child: imageUrl != null
            ? Image.network(imageUrl!)
            : Image.file(_selectedImage!),
      );
    } else {
      return SizedBox();
    }
  }

  Future<void> getlead(id) async {
    var urlString = AppString.constanturl + 'getleaddetails';
    Uri uri = Uri.parse(urlString);
    var response = await http.post(uri, body: {
      "id": '$id',
    });
    var jsondata = jsonDecode(response.body);
    print(jsondata);
    CustomerName.text = jsondata['customer_name'] ?? "";
    CompanyName.text = jsondata['company_name'] ?? "";
    ContactNo.text = jsondata['contact_no'] ?? "";
    MailId.text = jsondata['mail_id'] ?? "";
    Website.text = jsondata['website'] ?? "";
    Description.text = jsondata['description'] ?? "";
    OwnerName.text = jsondata['owner_name'] ?? "";
    leadImageUrl = jsondata['lead_img'];
    if (leadImageUrl != null && leadImageUrl!.isNotEmpty) {
      setState(() {
        imageUrl = AppString.imageurl + '$leadImageUrl';
      });
    } else {
      setState(() {
        _selectedImage = null;
        imageUrl = null;
      });
    }
  }

  Future<void> getLocation() async {
    var location = Location();
    try {
      currentLocation = await location.getLocation();
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void savelead(customer_name, company_name, contact_no, mail_id, website, desc,
      owner_name) async {

  SharedPreferences preferences = await SharedPreferences.getInstance();
     id = preferences.getString('id');
    cmpid = preferences.getString('cmpid');

    var urlString = AppString.constanturl + 'create_lead';
    Uri uri = Uri.parse(urlString);
    var response = await http.post(uri, body: {
      "customer_name": customer_name,
      "company_name": company_name,
      "contact_number": contact_no,
      "mail_id": mail_id,
      "website": website,
      "description": desc,
      "owner_name": owner_name,
      "lat": '${currentLocation?.latitude}',
      "long": '${currentLocation?.longitude}',
      "emp_id": '${id}',
      "company_id": '${cmpid}',
    });

    var jsonResponse = json.decode(response.body);
    if (_selectedImage != null) {
      saveimage(jsonResponse['id']);
    }
    if (jsonResponse['result'] == "sucess") {
      Fluttertoast.showToast(
        backgroundColor: const Color.fromARGB(255, 0, 255, 55),
        textColor: Colors.white,
        msg: 'Lead Added Successfully.',
        toastLength: Toast.LENGTH_SHORT,
      );
      setState(() {
        _selectedImage == null;
        imageUrl == null;
        CustomerName.text = "";
        CompanyName.text = "";
        ContactNo.text = "";
        MailId.text = "";
        Description.text = "";
        OwnerName.text = "";
        Website.text = "";
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LeadList()),
      );
    }
  }

  // Future<void> saveimage(id) async {
  //   try {
  //     var urlString = AppString.constanturl + 'addLeadimage'; // Update the URL
  //     Uri uri = Uri.parse(urlString);
  //     var request = http.MultipartRequest('POST', uri);

  //     // Assuming _selectedImage is a File object representing the image you want to upload
  //     if (_selectedImage != null) {
  //       request.files.add(
  //         await http.MultipartFile.fromPath(
  //           'image', // Field name for the image in your API
  //           _selectedImage!.path,
  //         ),
  //       );
  //       request.fields['id'] = id.toString();
  //       var response = await request.send();
  //       if (response.statusCode == 200) {
  //         setState(() {
  //           _selectedImage = null;
  //           imageUrl = null;
  //         });
  //         print('Image uploaded successfully');
  //       } else {
  //         print('Image upload failed with status code: ${response.statusCode}');
  //       }
  //     } else {
  //       print('No image selected for upload');
  //     }
  //   } catch (e) {
  //     print('Error during image upload: $e');
  //   }
  // }

  Future<void> saveimage(id) async {
    try {
      var urlString = AppString.constanturl + 'addLeadimage'; // Update the URL
      Uri uri = Uri.parse(urlString);
      var request = http.MultipartRequest('POST', uri);

      // Assuming _selectedImage is an XFile from an image picker
      if (_selectedImage != null) {
        String imagePath = _selectedImage!.path; // Get the file path from XFile

        // Compress the selected image
        List<int> compressedImage = await FlutterImageCompress.compressWithList(
          File(imagePath).readAsBytesSync(),
          quality: 80, // Adjust the compression quality as needed
        );

        var compressedFile = File(imagePath)..writeAsBytesSync(compressedImage);

        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // Field name for the image in your API
            compressedFile.path, // Use the compressed image path
          ),
        );

        request.fields['id'] = id.toString();
        var response = await request.send();
        if (response.statusCode == 200) {
          setState(() {
            _selectedImage = null;
            imageUrl = null;
          });
          print('Image uploaded successfully');
        } else {
          print('Image upload failed with status code: ${response.statusCode}');
        }
      } else {
        print('No image selected for upload');
      }
    } catch (e) {
      print('Error during image upload: $e');
    }
  }

  void updatelead(customer_name, company_name, contact_no, mail_id, website,
      desc, owner_name) async {
    var urlString = AppString.constanturl + 'update_lead';
    Uri uri = Uri.parse(urlString);
    var response = await http.post(uri, body: {
      "customer_name": customer_name,
      "company_name": company_name,
      "contact_number": contact_no,
      "mail_id": mail_id,
      "website": website,
      "description": desc,
      "owner_name": owner_name,
      "lat": '${currentLocation?.latitude}',
      "long": '${currentLocation?.longitude}',
      "id": widget.id
    });

    var jsondata = jsonDecode(response.body);
    if (_selectedImage != null) {
      saveimage(widget.id);
    }
    if (jsondata['result'] == "sucess") {
      Fluttertoast.showToast(
        backgroundColor: const Color.fromARGB(255, 0, 255, 55),
        textColor: Colors.white,
        msg: 'Lead Updated Successfully.',
        toastLength: Toast.LENGTH_SHORT,
      );
      setState(() {
        _selectedImage == null;
        imageUrl == null;
        CustomerName.text = "";
        CompanyName.text = "";
        ContactNo.text = "";
        MailId.text = "";
        Description.text = "";
        OwnerName.text = "";
        Website.text = "";
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LeadList()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFD700), // Set app bar background color
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(
                    30), // Add curved border radius to the bottom
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10, // Set the blur radius of the shadow
                  offset: Offset(0, 2), // Set the offset of the shadow
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors
                  .transparent, // Set app bar background color to transparent
              elevation: 0, // Remove app bar shadow

              title: Text(
                //'Create lead',
                widget.task == 'view'
                    ? 'View Lead'
                    : (widget.task == 'edit' ? 'Edit Lead' : 'Create Lead'),

                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color:
                      AppString.appgraycolor, // Set app bar text color to white
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppString.appgraycolor),
                onPressed: () {
                  widget.task != ''
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeadList(),
                          ),
                        )
                      : Navigator.push(
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
                          children: [
                            TextFormField(
                              controller: CustomerName,
                              decoration: const InputDecoration(
                                labelText: 'Customer Name',
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(
                                    r'[a-zA-Z ]')), // Allow letters and spaces
                              ],
                             
                            ),
                            TextFormField(
                              controller: CompanyName,
                              decoration: const InputDecoration(
                                labelText: 'Company Name',
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Company Name is required';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: ContactNo,
                              decoration: const InputDecoration(
                                labelText: 'Contact number',
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')), // Allow only numbers
                                LengthLimitingTextInputFormatter(
                                    10), // Limit the length to 10 characters
                              ],
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Contact number is required';
                                }
                                if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                  return 'Invalid contact number format';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: MailId,
                              decoration: const InputDecoration(
                                labelText: 'Mail Id',
                                labelStyle: TextStyle(
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
                            TextFormField(
                              controller: Website,
                              decoration: const InputDecoration(
                                labelText: 'Website',
                                labelStyle: TextStyle(
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
                            TextFormField(
                              controller: Description,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: OwnerName,
                              decoration: const InputDecoration(
                                labelText: 'Owner name',
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            //(_selectedImage != null)
                            _buildSelectedImage(),
                            // : SizedBox(
                            //     height: 10,
                            //   ),
                            if (widget.task != 'view')
                              ElevatedButton(
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

                            if (widget.task != 'view')
                              (Row(
                                children: [
                                  Expanded(
                                    child: (widget.id != '0')
                                        ? ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFFFFD700),
                                            ),
                                            child: Text(
                                              'Update',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                color: AppString.appgraycolor,
                                              ),
                                            ),
                                            onPressed: () {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                updatelead(
                                                  CustomerName.text,
                                                  CompanyName.text,
                                                  ContactNo.text,
                                                  MailId.text,
                                                  Website.text,
                                                  Description.text,
                                                  OwnerName.text,
                                                );
                                              }
                                            },
                                          )
                                        : ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFFFFD700),
                                            ),
                                            child: Text('Save',
                                                style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    color: AppString
                                                        .appgraycolor)),
                                            onPressed: () {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                savelead(
                                                    CustomerName.text,
                                                    CompanyName.text,
                                                    ContactNo.text,
                                                    MailId.text,
                                                    Website.text,
                                                    Description.text,
                                                    OwnerName.text);
                                              }
                                            }),
                                  ),
                                  SizedBox(
                                      width:
                                          16), // You can adjust the spacing between buttons
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFFFFD700),
                                      ),
                                      child: Text(
                                        'Show list',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: AppString.appgraycolor,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => LeadList()),
                                        );
                                        setState(() {
                                          _selectedImage = null;
                                          imageUrl = null;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ))
                          ],
                        )))),
          ),
        ));
  }
}
