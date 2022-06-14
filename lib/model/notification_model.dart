class NotificationModel {
  var createdOn;
  String? message;
  String? title;
  String? senderToken;

  NotificationModel({this.createdOn, this.message, this.title, this.senderToken});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    createdOn = json["createdOn"];
    message = json['message'];
    title = json['title'];
    senderToken = json['senderToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.createdOn;
    data['message'] = this.message;
    data['title'] = this.title;
    data['senderToken'] = this.senderToken;
    return data;
  }
}
