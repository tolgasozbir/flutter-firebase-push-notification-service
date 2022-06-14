class NotificationModel {
  String? date;
  String? message;
  String? title;
  String? senderToken;

  NotificationModel({this.date, this.message, this.title, this.senderToken});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    date = json["date"];
    message = json['message'];
    title = json['title'];
    senderToken = json['senderToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['message'] = this.message;
    data['title'] = this.title;
    data['senderToken'] = this.senderToken;
    return data;
  }
}
