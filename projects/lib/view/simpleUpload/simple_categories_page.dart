import 'package:flutter/material.dart';
import 'package:projects/controller/internal/own_work_helper.dart';
import 'package:projects/model/datasets.dart';
import 'package:projects/model/information_collector.dart';
import 'package:projects/view/uploadFlow/select_items_fragment.dart';
import 'package:projects/view/uploadFlow/upload_progress_bar.dart';

class SimpleCategoriesPage extends StatefulWidget {
  const SimpleCategoriesPage({Key? key}) : super(key: key);

  @override
  _SimpleCategoriesPageState createState() => _SimpleCategoriesPageState();
}

class _SimpleCategoriesPageState extends State<SimpleCategoriesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: const Padding(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: SelectItemFragment(SelectItemsFragmentUseCase.category),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text("Upload to Wikimedia"),
      actions: [
        IconButton(
            onPressed: () {
              upload();
            },
            icon: const Icon(Icons.upload)),
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
