import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects/fragments/articles/uploadGuideFragment.dart';
import 'package:projects/style/textStyles.dart';

import '../commonsUploadFragment.dart';

class SelectImageFragment extends StatefulWidget {
  @override
  SelectImageFragmentState createState() => SelectImageFragmentState();
}

class SelectImageFragmentState extends State<SelectImageFragment> {
  // TODO? Support Video Files?
  // TODO? Support Audio Files?
  // TODO? Support multiple Files?

  final ImagePicker _picker = ImagePicker();
  final InformationCollector collector = new InformationCollector();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            contentContainer(introText()),
            contentContainer(imageSelect()),
          ],
        ),
      ),
    );
  }

  Widget contentContainer(Widget? child) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            )),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget imageSelect() {
    if (collector.image != null) {
      return FutureBuilder(
          future: futureCollector(),
          builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
            // TODO image still loads delayed even with future builder
            if (snapshot.hasData) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: snapshot.data!['image'],
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 6)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dimensions: ${snapshot.data!['width']} x ${snapshot.data!['height']}',
                              style: smallLabel,
                              softWrap: false,
                            ),
                            Text(
                              'File name: ${snapshot.data!['fileName']}',
                              style: smallLabel,
                              softWrap: false,
                            ),
                            Text(
                              'File type: ${snapshot.data!['fileType']}',
                              style: smallLabel,
                              softWrap: false,
                            )
                          ],
                        ),
                      )
                    ],
                  )),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          collector.image = null;
                        });
                      },
                      icon: Icon(Icons.delete)),
                ],
              );
            } else {
              return LinearProgressIndicator();
            }
          });
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(2),
            child: TextButton(
                onPressed: () async {
                  collector.image =
                      await _picker.pickImage(source: ImageSource.gallery);
                },
                child: SizedBox(
                  width: 200,
                  height: 40,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.file_copy_outlined),
                        Padding(padding: EdgeInsets.only(left: 5)),
                        Text("Select Image from Files"),
                      ]),
                )),
          ),
          SizedBox(
              width: 100,
              child: Row(children: <Widget>[
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    "OR",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Expanded(child: Divider()),
              ])),
          Padding(
              padding: EdgeInsets.all(2),
              child: TextButton(
                  onPressed: () async {
                    collector.image =
                        await _picker.pickImage(source: ImageSource.camera);
                  },
                  child: SizedBox(
                    width: 200,
                    height: 40,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.camera_alt_outlined),
                          Padding(padding: EdgeInsets.only(left: 5)),
                          Text("Capture a Photo"),
                        ]),
                  ))),
        ],
      );
    }
  }

  Future<Map> futureCollector() async {
    Map<String, dynamic> map = new Map();
    map['image'] = Image.file(File(collector.image!.path), height: 100);
    var decodedImage =
        await decodeImageFromList(await collector.image!.readAsBytes());
    map['width'] = decodedImage.width;
    map['height'] = decodedImage.height;
    map['fileName'] = File(collector.image!.name).toString().substring(6);
    String fileName = map['fileName'].toString().split(".")[1];
    map['fileType'] = "." + fileName.substring(0, fileName.length - 1);
    return map;
  }

  Widget introText() {
    // TODO revise text
    double paragraphSpacing = 2.0;
    return Column(
      children: [
        Text(
          "Before you start...",
          style: articleTitle,
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: paragraphSpacing)),
        Text(
          "Make sure that you are aware of what content can and should be "
          "uploaded to Wikimedia Commons. ",
          style: objectDescription,
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: paragraphSpacing)),
        Text(
          "Once uploaded, you cannot delete any content you submitted to "
          "Commons. You may only upload works that are created entirely by you, "
          "with a few exceptions. ",
          style: objectDescription,
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: paragraphSpacing)),
        Text(
          "If you are not familiar with the Upload "
          "guidelines, you can learn more through the upload guide.",
          style: objectDescription,
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => UploadGuideFragment()));
          },
          child: Text("Learn more"),
        ),
      ],
    );
  }
}
