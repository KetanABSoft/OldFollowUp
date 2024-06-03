import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CustomListRemark extends StatelessWidget {
  final String? name;
  final String? date;
  final String? time;
  final String? remark;
  final Function? trailingButtonOnTap;
  final double opacity;

  const CustomListRemark({
    Key? key,
    required this.name,
    required this.date,
    required this.time,
    required this.remark,
    required this.trailingButtonOnTap,
    required this.opacity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? id = "";
    ScrollController controller = ScrollController();

    Future getMobile() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      //setState(() {
      id = preferences.getString('id');

      //});
    }

    return Container(
      margin: EdgeInsets.only(top: 10.0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: (Color.fromARGB(255, 227, 239, 249)),
          boxShadow: [
            BoxShadow(
              blurRadius: 5.0,
              color: Color.fromARGB(255, 253, 253, 250),
            )
          ],
          borderRadius: BorderRadius.circular(15.0)),
      padding: EdgeInsets.only(
        left: 20,
        right: 0,
      ),
      child: Opacity(
        opacity: opacity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      padding: EdgeInsets.only(top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side child
                          Expanded(
                            child: Text(
                              "$name",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "$date $time",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                   // Divider(),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 1),
                      child: Text(
                        '$remark',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ],
            ),
            //when data comes from notification close button not show
            Spacer(),
            trailingButtonOnTap != null
                ? InkWell(
                    onTap: trailingButtonOnTap as void Function()?,
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  )
                : Container(),
            SizedBox(
              width: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
