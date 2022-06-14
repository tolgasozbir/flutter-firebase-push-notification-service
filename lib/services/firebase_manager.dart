import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_push_notification_service/model/notification_model.dart';
import 'package:http/http.dart' as http;

class FirebaseManager {
  static void createUser(String token) async {
    final userDoc = FirebaseFirestore.instance.collection("Users").doc();
    final user = {
      "id" : userDoc.id,
      "token":"$token"
    };
    await FirebaseMessaging.instance.subscribeToTopic('general');
    await userDoc.set(user);
  }

  static void createSaveNotifications(String token, String title, String body) async {
    final notificationDoc = FirebaseFirestore.instance.collection("Notifications").doc();
    final notification = {
      "date":"${DateTime.now().toString().substring(0,19)}",
      "senderToken":"$token",
      "title" : "$title",
      "message" : "$body"
    };
    await notificationDoc.set(notification);
  }

  static Future<List<NotificationModel>> getAllNotificationMessages() async {
    final notificationDoc = await FirebaseFirestore.instance.collection("Notifications").orderBy("date").get();
    List<NotificationModel> notificationList = [];
    for (var item in notificationDoc.docs) {
      notificationList.add(NotificationModel.fromJson(item.data()));
    }
    return notificationList;
  }

  static Future<List<String>> getTokens() async {
    String? token = await FirebaseMessaging.instance.getToken() ?? "";
    List<String> tokenList = [];
    //final userDoc = FirebaseFirestore.instance.collection("Users").snapshots().map((e) => e.docs.map((doc) => doc.data())).toList();
    final userDoc = await FirebaseFirestore.instance.collection("Users").get();
    for (var item in userDoc.docs) {
      tokenList.add(item["token"]);
    }
    if (!tokenList.contains(token)) {
      FirebaseManager.createUser(token);
      tokenList.add(token);
    }
    return tokenList;
  }

  Future<void> callOnFcmApiSendPushNotifications(List<String> tokens,{required String title, required String body}) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    for (var i = 0; i < tokens.length; i++) {
        final data = {
      // "to": "/topics/android",
      // "to": "/topics/general",
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
        print('CFM error');
        // on failure do sth
      }
    }
  }

}