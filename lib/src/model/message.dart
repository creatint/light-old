import 'dart:convert';

///ping：ping/pong
///事件：event
///文件：file
///文本：text
///图片：image
///语音：voice
///视频：video
///位置：location
///链接：link
enum MessageType {
  ping,
  pong,
  event,
  file,
  text,
  image,
  voice,
  video,
  location,
  link
}

class Message {
  Message(
      {this.version,
      this.topicId,
      this.toAccount,
      this.toUsername,
      this.fromAccount,
      this.fromUsername,
      this.msgId,
      this.msgType,
      this.timestamp,
      this.data});

  final double version;
  final String topicId;
  final String msgId;
  final String toAccount;
  final String toUsername;
  final String fromAccount;
  final String fromUsername;
  final MessageType msgType;
  final int timestamp;
  final String data;

  String getContent() {
    return data;
  }
}
