import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../commonsUploadFragment.dart';

class ReviewFragment extends StatefulWidget {
  @override
  ReviewFragmentState createState() => ReviewFragmentState();
}

class ReviewFragmentState extends State<ReviewFragment> {
  InformationCollector collector = new InformationCollector();
  String text = "";

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SingleChildScrollView(
            child: Column(
              // TODO Preview of infos & media
              // Here, all the info entered by the user should be previewed. When
              // the submit button is pressed and not all the fields are filled
              // out, it is also marked here. Maybe the use of collapsible menus
              // can be used to summarize sections. User should also be warned when
              // category list is empty.
              children: [
                ElevatedButton(
                    onPressed: () {
                      submit();
                    },
                    child: Text("Submit"),
                ),
                Text(text),
              ],
            )
        )
    );
  }

  void submit () {
    if(checkInfos()){
      collector.submitData();
    } else {
      setState(() {
        text = "no";
      });
    }
  }

  bool checkInfos () {
    bool isOk = true;
    bool isWarning = false;
    if(collector.image == null) {
      isOk = false;
    }
    if(collector.fileName == null) {
      isOk = false;
    }
    if(collector.description == null) {
      isOk = false;
    }
    if(collector.license == null) {
      isOk = false;
    }
    if(collector.author == null) {
      isOk = false;
    }
    if(collector.title == null) {
      isOk = false;
    }
    if(collector.categories.length == 0) {
      isWarning = false;
    }
    if(collector.title == null) {
      isOk = false;
    }

    return isOk;
  }
}
