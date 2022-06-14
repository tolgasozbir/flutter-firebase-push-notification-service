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
    //notificationList.sort((a, b) => a.createdOn!.compareTo(b.createdOn!));
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
        getNotificationList();
      }
    });
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
              title: Text("${notification.message}"),
              subtitle: Text("${notification.createdOn.toDate().toString().substring(0,19)}"),
            ),
          )
          : Card(
            child: ListTile(
              tileColor: Color.fromARGB(255, 128, 192, 240),
              title: Text("${notification.message}", textAlign: TextAlign.right,),
              subtitle: Text("${notification.createdOn.toDate().toString().substring(0,19)}", textAlign: TextAlign.right,),
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