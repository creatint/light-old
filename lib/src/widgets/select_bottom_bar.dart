import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:light/src/widgets/selected_list_model.dart';

class SelectBottomBar<T> extends StatelessWidget {
  SelectBottomBar(
      {Key key,
      @required this.selectedList,
      @required this.list,
      this.handleSelectAll,
      this.handleCancel,
      this.handleEnter,
      this.buttonText});

  final VoidCallback handleSelectAll;
  final VoidCallback handleCancel;
  final VoidCallback handleEnter;
  final SelectedListModel<T> selectedList;
  final List<T> list;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    Color getButtonColor() {
      if (selectedList.isEmpty)
        return Theme.of(context).disabledColor;
      else
        return Theme.of(context).accentColor;
    }

    TextStyle getButtonTextStyle() {
      if (selectedList.isEmpty) {
        return Theme.of(context).textTheme.button;
      } else {
        return Theme.of(context).primaryTextTheme.button;
      }
    }

    return new Container(
      height: 48.0,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Container(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: new Text('已选${list.length}项')),
              new FlatButton(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  onPressed: handleSelectAll,
                  child: new Text(
                    selectedList.length >= list.length ? '全不选' : '全选',
                  )),
              new FlatButton(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  onPressed: handleCancel,
                  child: new Text('取消')),
            ],
          ),
          new FlatButton(
              color: getButtonColor(),
              onPressed: handleEnter,
              child: new Text(
                buttonText,
                style: getButtonTextStyle(),
              ))
        ],
      ),
    );
  }
}
