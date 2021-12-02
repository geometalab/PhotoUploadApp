import 'package:flutter/material.dart';
import 'package:projects/controller/OwnWorkHandler.dart';
import 'package:projects/model/informationCollector.dart';
import 'package:projects/view/uploadFlow/selecItems.dart';
import 'package:projects/view/uploadFlow/uploadProgressBar.dart';

class SimpleCategoriesPage extends StatefulWidget {
  @override
  _SimpleCategoriesPageState createState() => _SimpleCategoriesPageState();
}

class _SimpleCategoriesPageState extends State<SimpleCategoriesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: SelectItemFragment(0),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Text("Upload to Wikimedia"),
      actions: [
        IconButton(
            onPressed: () {
              upload();
            },
            icon: Icon(Icons.upload)),
      ],
    );
  }

  upload() async {
    InformationCollector collector = InformationCollector();
    showSendingProgressBar();
    await OwnWorkHandler().setOwnWork();
    collector.submitData();
  }

  UploadProgressBar? _sendingMsgProgressBar;
  void showSendingProgressBar() {
    _sendingMsgProgressBar = UploadProgressBar();
    _sendingMsgProgressBar!.show(context);
  }

  void hideSendingProgressBar() {
    if (_sendingMsgProgressBar != null) {
      _sendingMsgProgressBar!.hide();
    }
  }
}
