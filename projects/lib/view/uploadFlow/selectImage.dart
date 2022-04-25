import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects/controller/internal/imageDataExtractor.dart';
import 'package:projects/model/informationCollector.dart';
import 'package:projects/view/articles/uploadGuide.dart';
import 'package:projects/style/textStyles.dart';

// TODO check if same file type, if not disallow upload and display message
// TODO handle batch uploads when opened as an external intent in simple mode (just say no)

class SelectImageFragment extends StatefulWidget {
  @override
  _SelectImageFragmentState createState() => _SelectImageFragmentState();
}

class _SelectImageFragmentState extends State<SelectImageFragment> {
  // TODO? Support Video Files?
  // TODO? Support Audio Files?

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
            contentContainer(imageSelectWidget()),
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget imageSelectWidget() {
    if (collector.images.isNotEmpty) {
      return FutureBuilder(
          future: ImageDataExtractor().futureCollector(),
          builder: (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
            // TODO image still loads delayed even with future builder
            if (snapshot.hasData) {
              if (snapshot.data == null) {
                collector.clear();
                showImagesLoadErrorPopup(context);
                throw ("Image infos are null");
              }
              if (snapshot.data!.isEmpty) {
                collector.clear();
                showImagesLoadErrorPopup(context);
              }
              List<Widget> imageInfos = List.empty(growable: true);
              for (int i = 0; i < snapshot.data!.length; i++) {
                imageInfos.add(imageInfoWidget(snapshot.data![i]));
                if (i + 1 > snapshot.data!.length) {
                  imageInfos.add(Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                  ));
                }
              }
              return Column(
                children: imageInfos +
                    [
                      TextButton(
                          onPressed: () async {
                            _openImagePicker();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add),
                              Text("Add more images")
                            ],
                          ))
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
                  _openImagePicker();
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
                    XFile? image =
                        await _picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      collector.images = [image];
                    }
                    setState(() {});
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

  Widget imageInfoWidget(Map imageInfo) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Row(
              children: [
                SizedBox(
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageInfo['image'],
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 6)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dimensions: ${imageInfo['width']} x ${imageInfo['height']}',
                        style: smallLabel,
                        softWrap: false,
                      ),
                      Text(
                        'File name: ${imageInfo['fileName']}',
                        style: smallLabel,
                        softWrap: false,
                      ),
                      Text(
                        'File type: ${imageInfo['fileType']}',
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
                    collector.images.removeWhere((element) =>
                        File(element.name).toString().substring(6) ==
                        imageInfo['fileName']);
                    if (collector.images.isEmpty) {
                      collector.fileType = null;
                    }
                  });
                },
                icon: Icon(Icons.delete)),
          ],
        ));
  }

  Widget introText() {
    // TODO revise text
    double paragraphSpacing = 2.0;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16),
        ),
        Text("Before you start...",
            style: articleTitle, textAlign: TextAlign.center),
        Padding(padding: EdgeInsets.symmetric(vertical: paragraphSpacing)),
        Text(
          "Make sure that you are aware of what content can and should be "
          "uploaded to Wikimedia Commons. ",
          style: objectDescription,
          textAlign: TextAlign.center,
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: paragraphSpacing)),
        Text(
            "Once uploaded, you cannot delete any content you submitted to "
            "Commons. You may only upload works that are created entirely by you, "
            "with a few exceptions. ",
            style: objectDescription,
            textAlign: TextAlign.center),
        Padding(padding: EdgeInsets.symmetric(vertical: paragraphSpacing)),
        Text(
            "If you are not familiar with the Upload "
            "guidelines, you can learn more through the upload guide.",
            style: objectDescription,
            textAlign: TextAlign.center),
        TextButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => UploadGuideFragment()));
          },
          child: Text("Learn more"),
        ),
      ],
    );
  }

  _openImagePicker() async {
    collector.images.addAll(await _picker.pickMultiImage() ?? List.empty());
    setState(()  {
      if(collector.images.length >= 10) {
        collector.images.removeRange(10, 99999);
      }
    });
  }

  showImagesLoadErrorPopup(BuildContext context) {
    // TODO test if this even works lol
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Can't load images"),
            content: Text("Make sure all your images are the same file type."),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Okay"))
            ],
          );
        });
  }
}
