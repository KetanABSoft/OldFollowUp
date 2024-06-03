

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';


class NotificationServices {
  static FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
   final  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
 void requestNotificationPermission() async {
     
  }

   void main() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
   Future<void> configure() async {
    // Request permission to receive notifications
    // NotificationSettings settings = await _firebaseMessaging.requestPermission(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );

      NotificationSettings settings = await _firebaseMessaging.requestPermission(
  alert: true,
  announcement: false,
  badge: true,
  carPlay: false,
  criticalAlert: false,
  provisional: false,
  sound: true,
);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Handle messages in the foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground Message Received: ${message.notification?.body}');
                 try {
      Map<String, dynamic> data = message.data;
        showNotification(data);
    } catch (e) {
      print('Exception: $e');
    }
      });

      // Handle messages when the app is in the background
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    }
  }

   Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Background Message Received: ${message.notification?.body}');

             try {
      Map<String, dynamic> data = message.data;
        showNotification(data);
    } catch (e) {
      print('Exception: $e');
    }
  }

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

 FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print(message.toString());
            try {
      Map<String, dynamic> data = message.data;
        showNotification(data);
    } catch (e) {
      print('Exception: $e');
    }
       });
}

  void initLocalNotifications () async {
    var androidInitializationSettings = AndroidInitializationSettings('@drawable/favicon');
    var iosInitializationSettings = DarwinInitializationSettings();
    var initializationSetting = InitializationSettings (
    android: androidInitializationSettings
    
    //iOS: iosInitializationSettings
    );
    await flutterLocalNotificationsPlugin.initialize(
    initializationSetting,
    onDidReceiveNotificationResponse: (payload) {
    }
    );
  }
  void firebaseInit(){
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
                 try {
      Map<String, dynamic> data = message.data;
        showNotification(data);
    } catch (e) {
      print('Exception: $e');
    }
      //  showNotification();
       });
  }
   showNotification(Map<String, dynamic> data) async {
 print(data.toString());
  //dynamic dataTemp = data;

  
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/favicon');
 
    // const IOSInitializationSettings initializationSettingsIOS =
    //     IOSInitializationSettings(
    //   requestSoundPermission: false,
    //   requestBadgePermission: false,
    //   requestAlertPermission: false,
    // );
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    
    );
 
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
 
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high channel',
      'Very important notification!!',
      description: 'the first notification',
      importance: Importance.max,
    );
    var storedata;
    if (data.length > 0) {
      for (dynamic type in data.keys) {
       storedata=(data[type]) ;
   
 }
    }
   final body = json.decode(storedata.toString());
   final String message = body['message'];
   final String title = body['title'];
   

    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      message,
   
      NotificationDetails(
        android: AndroidNotificationDetails(channel.id, channel.name,
            channelDescription: channel.description),
      ),
    );
  }
}