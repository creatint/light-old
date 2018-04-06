import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:light/src/model/message.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({this.isTopic: false, this.appAccount, this.username});

  final bool isTopic;
  final String appAccount;
  final String username;

  @override
  _ChatScreenState createState() => new _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = <Message>[];
  final List<MessageItem> _messageItems = <MessageItem>[];
  final TextEditingController _textController = new TextEditingController();
  final Random random = new Random(new DateTime.now().millisecondsSinceEpoch);
  final ScrollPhysics _scrollPhysics = new BouncingScrollPhysics();

  void _handleTextSubmitted(String text) {
    print('handleTextSubmit text=$text');
    _textController.clear();
    text = text?.trim();
    if (null == text || text.isEmpty) {
      return;
    }
    Message message = new Message(
        fromAccount: widget.appAccount,
        fromUsername: widget.username,
        data: text);
    MessageItem item =
        new MessageItem(message: message, isSelf: random.nextBool());
    setState(() {
      _messageItems.insert(0, item);
      _messages.insert(0, message);
    });
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Flexible(
              child: new ConstrainedBox(
                constraints:
                    new BoxConstraints(maxHeight: 130.0, minHeight: 30.0),
                child: new Container(
//                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: new SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    reverse: true,
                    child: new TextField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _textController,
                      onSubmitted: _handleTextSubmitted,
                      decoration: new InputDecoration(
                          border: InputBorder.none, hintText: "Send a message"),
                    ),
                  ),
                ),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => _handleTextSubmitted(_textController.text)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar() {
    return new AppBar(
      title: new Text('Yotaku'),
    );
  }

  Widget buildMessages() {
    return new Flexible(
      child: new Container(
        color: const Color.fromRGBO(242, 245, 250, 1.0), //聊天背景
        child: new ListView.builder(
          physics: _scrollPhysics,
          padding: new EdgeInsets.symmetric(vertical: 8.0),
          reverse: true,
          itemBuilder: (_, int index) => new MessageItem(
                message: _messages[index],
                isSelf: random.nextBool(),
//              isSelf: widget.appAccount == _messages[index].fromAccount,
              ),
          itemCount: _messages.length,
        ),
      ),
    );
  }

  Widget buildBody() {
    return new Column(
      children: <Widget>[
        buildMessages(),
        new Divider(
          height: 1.0,
        ),
        new Flexible(
          child: new Container(
            child: _buildTextComposer(),
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    print('initState');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Friendlychat")),
      body: new Column(
        children: <Widget>[
          buildMessages(),
          new Divider(height: 1.0),
          new Container(
            decoration: new BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }
}

class MessageItem extends StatelessWidget {
  MessageItem({Key key, @required this.message, @required this.isSelf});

  final Message message;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = <Widget>[
      new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new CircleAvatar(
          child: new Text('C'),
        ),
      ),
      new Expanded(
        child: new Column(
          crossAxisAlignment:
              isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            new Offstage(
              child: new Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: new Text('Creaty')),
              offstage: isSelf,
            ),
            new Container(
                margin: isSelf
                    ? const EdgeInsets.only(left: 65.0)
                    : const EdgeInsets.only(right: 65.0),
                padding: const EdgeInsets.all(8.0),
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        new BorderRadius.all(const Radius.circular(14.0))),
                child: new Text(message.getContent()))
          ],
        ),
      )
    ];
    if (isSelf) {
      widgets = widgets.reversed.toList();
    }
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }
}
