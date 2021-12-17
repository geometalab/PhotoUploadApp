import 'package:flutter/material.dart';
import 'package:projects/controller/internal/ownWorkHelper.dart';
import 'package:projects/model/informationCollector.dart';
import 'package:projects/view/uploadFlow/selectItems.dart';
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
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: SelectItemFragment(0),
      ),
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
    await OwnWorkHelper().setOwnWork();
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
