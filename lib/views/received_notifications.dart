import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_push_notification_service/model/notification_model.dart';
import 'package:firebase_push_notification_service/services/firebase_manager.dart';
import 'package:firebase_push_notification_service/services/local_notification.dart';
import 'package:flutter/material.dart';

class ReceivedNotifications extends StatefulWidget {
  const ReceivedNotifications({Key? key}) : super(key: key);

  @override
  State<ReceivedNotifications> createState() => _ReceivedNotificationsState();
}

class _ReceivedNotificationsState extends State<ReceivedNotifications> {

  String token = "";
  List<String> tokenList = [];
  List<NotificationModel> notificationList = [];
  TextEditingController tfBody = TextEditingController();

  @override
  void initState() {
    super.initState();
    LocalNotification.init();
    notificationForeground();
    foregroundMessage();
    getDeviceToken();
    getTokenList();
    getNotificationList();
  }

  getNotificationList() async {
    notificationList = await FirebaseManager.getAllNotificationMessages();
    setState(() {});
  }

  getTokenList() async {
    tokenList = await FirebaseManager.getTokens();
    //print(tokenList);
  }

  getDeviceToken() async {
    token = await FirebaseMessaging.instance.getToken() ?? "";
    setState(() {
      
    });
  }

  void notificationForeground(){
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        LocalNotification.showNotification(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
        );
      }
    });
  }

  void foregroundMessage(){
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        LocalNotification.showNotification(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
        );
      }
    });
  }

  void getUser() async {
    //final userDoc = FirebaseFirestore.instance.collection("Users").snapshots().map((e) => e.docs.map((doc) => doc.data())).toList();
    final userDoc = await FirebaseFirestore.instance.collection("Users").get();
    var i = 0;
    for (var item in userDoc.docs) {
      print("Token Count : ${i++}");
      print(item["token"]);
      tokenList.add(item["token"]);
    }
    if (!tokenList.contains(token)) {
      FirebaseManager.createUser(token);
      tokenList.add(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Notifications"),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody(){
    return Column(
      children: [
        listViewNotifications(),
        sendNotificationSection()
      ],
    );
  }

  Expanded listViewNotifications() {
    return Expanded(
      child: ListView.builder(
        itemCount: notificationList.length,
        itemBuilder: (BuildContext context, int index) {
          NotificationModel notification = notificationList[index];
          return notification.senderToken != token 
          ? Card(
            child: ListTile(
              title: Text("Message : ${notification.message}"),
              subtitle: Text("Date ${notification.date}"),
            ),
          )
          : Card(
            child: ListTile(
              tileColor: Colors.blue,
              title: Text("Message : ${notification.message}", textAlign: TextAlign.right,),
              subtitle: Text("Date ${notification.date}", textAlign: TextAlign.right,),
            ),
          ); 
        },
      ),
    );
  }

  Padding sendNotificationSection() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            notificationTextField(),
            sendButton()
          ],
        ),
      );
  }

  Expanded notificationTextField() {
    return Expanded(
      child: TextField(
        controller: tfBody,
        decoration: InputDecoration(
          border: OutlineInputBorder()
        ),
      )
    );
  }

  IconButton sendButton() {
    return IconButton(
      onPressed: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        if (tfBody.text.isNotEmpty) {
          FirebaseManager().callOnFcmApiSendPushNotifications(tokenList, title: "A new message", body: tfBody.text);
          FirebaseManager.createSaveNotifications(token, "A new message", tfBody.text);
          getNotificationList();
        }
        tfBody.clear();
      }, 
      icon: Icon(Icons.send)
    );
  }



}