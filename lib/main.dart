import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  messaging.setForegroundNotificationPresentationOptions(
        alert: true,
      badge: true,
      sound: true,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  String notificationMessage = "Waiting";
  AndroidNotificationChannel? channel;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  String token = "";
  List<String> tokenList = [];
  TextEditingController tfTitle = TextEditingController();
  TextEditingController tfBody = TextEditingController();

  Future<void> getToken() async {
    String? gettoken = await FirebaseMessaging.instance.getToken();
    token = gettoken ?? "";
    setState(() {
      
    });
    print(token);
  }


  @override
  void initState() {
    super.initState();
    // FirebaseMessaging.instance.getInitialMessage().then((value) {
    //   setState(() {
    //     notificationMessage = "${value?.notification?.title ?? ""} ${value?.notification?.body ?? ""} Coming From Terminated State";
    //   });
    // });
    // FirebaseMessaging.onMessage.listen((event) {
    //   setState(() { });
    //   notificationMessage = "${event.notification?.title ?? ""} ${event.notification?.body ?? ""} Coming From Foreground";
    // });    
    // FirebaseMessaging.onMessageOpenedApp.listen((event) {
    //   setState(() { });
    //   notificationMessage = "${event.notification?.title ?? ""} ${event.notification?.body ?? ""} Coming From Background";
    // });

    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high);
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin!.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id,
              channel!.name,
              icon: 'launch_background',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print('noti click navigate');
    }); 
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: buildBody(),
      ),
    );
  }

  Center buildBody() {
    return Center(
        child: Container(
          child: Column(
            children: [

              Text(notificationMessage),
              ElevatedButton(
                onPressed: getToken, 
                child: Text("Get Token!")
              ),                 
              
              ElevatedButton(
                onPressed: createUser, 
                child: Text("Add User!")
              ),              
              ElevatedButton(
                onPressed: getUser, 
                child: Text("Fetch Users!")
              ),              


              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                child: TextField(
                  controller: tfTitle,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("title")
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                child: TextField(
                  controller: tfBody,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("body")
                  )
                ),
              ),

              ElevatedButton(
                onPressed: (){
                  callOnFcmApiSendPushNotifications(tokenList, body: "${tfBody.text}",title: "${tfTitle.text}");
                }, 
                child: Text("Send Notification!")
              ),
            ],
          ),
        ),
      );
  }

  void createUser() async {
    final userDoc = FirebaseFirestore.instance.collection("Users").doc();
    final user = {
      "id" : userDoc.id,
      "token":"$token"
    };
    await FirebaseMessaging.instance.subscribeToTopic('android');
    await userDoc.set(user);

  }  

  void getUser() async {
    //final userDoc = FirebaseFirestore.instance.collection("Users").snapshots().map((e) => e.docs.map((doc) => doc.data())).toList();
    final userDoc = await FirebaseFirestore.instance.collection("Users").get();
    var i = 0;
    for (var item in userDoc.docs) {
      print("index ${i++}");
      print(item["token"]);
      tokenList.add(item["token"]);
    }
  }

  Future<void> callOnFcmApiSendPushNotifications(List<String> tokens,{required String title, required String body}) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    for (var i = 0; i < tokens.length; i++) {
        final data = {
      // "to": "/topics/android",
        "to": "${tokens[i]}",
        "notification": {
          "title": title,
          "body": body,
        },
      };

      final headers = {
        'content-type': 'application/json',
        'Authorization':
            'key=AAAA63o0nPI:APA91bEArHVU7mRtbUclx2pQy4w9M7xaReM4ikf3DOxojgqTgB8hVRdaQ4P-idxhB-paBkVp84Y3loUxAf6Ug1AZfPatOTcq0GFD0fA8FvatHIfi-1vAR-9tA2chftb6XmhFNLr99gv7' // 'key=YOUR_SERVER_KEY'
      };

      final response = await http.post(Uri.parse(postUrl),
          body: json.encode(data),
          encoding: Encoding.getByName('utf-8'),
          headers: headers);

      if (response.statusCode == 200) {
        // on success do sth
        print('test ok push CFM');
      } else {
        print(' CFM error');
        // on failure do sth
      }
    }
  }
}