import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'loginscreen.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:followup/notification_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String? previoustime = preferences.getString('currentTime');
  DateTime previousDateTime;
  if (previoustime != null && previoustime.isNotEmpty) {
    previousDateTime = DateTime.parse(previoustime);
    // previousDateTime = DateTime.now();
  } else {
    previousDateTime = DateTime.now();
  }
  preferences.setString('preferencetime', previousDateTime.toString());

  DateTime currentTime = DateTime.now();
  preferences.setString('currentTime', currentTime.toString());

  var id = preferences.getString('id');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: id == null ? const loginScreen() : DashboardScreen(),
  ));
}

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print('foreground message');
//    await Firebase.initializeApp();
//       //FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//           print(message.toString());
//             try {
//       Map<String, dynamic> data = message.data;
//            notificationServices.showNotification(data);

//       print(data.toString());
//       // Handle the received message data
//      // sendPushNotification(data);
//     } catch (e) {
//       print('Exception: $e');
//     }
//       // });
//     //notificationServices.showNotification();
// }
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  try {
    Map<String, dynamic> data = message.data;
    notificationServices.showNotification(data);
    //notificationServices.showNotification(message);
  } catch (e) {
    print('Exception: $e');
  }
}
// Future<void> backgroundMessageHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();

//           try {
//       Map<String, dynamic> data = message.data;
//           notificationServices.showNotification(data);
//            //notificationServices.showNotification(message);

//     } catch (e) {
//       print('Exception: $e');
//     }
// }

NotificationServices notificationServices = NotificationServices();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: textmyapp(),
    );
  }
}

class textmyapp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => textmyappnew();
}

class textmyappnew extends State<textmyapp> {
  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    try {
      Map<String, dynamic> data = message.data;
      notificationServices.showNotification(data);
      //notificationServices.showNotification(message);
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Notification',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const loginScreen(),
    );
  }
}
